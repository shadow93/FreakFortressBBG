// FF2 Music Module
public Action:Command_StartMusic(client, args)
{
    if(Enabled2)
    {
        if(args)
        {
            decl String:pattern[MAX_TARGET_LENGTH];
            GetCmdArg(1, pattern, sizeof(pattern));
            new String:targetName[MAX_TARGET_LENGTH];
            new targets[MAXPLAYERS], matches;
            new bool:targetNounIsMultiLanguage;
            if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage))<=0)
            {
                ReplyToTargetError(client, matches);
                return Plugin_Handled;
            }

            if(matches>1)
            {
                for(new target; target<matches; target++)
                {
                    StartMusic(targets[target]);
                }
            }
            else
            {
                StartMusic(targets[0]);
            }
            CReplyToCommand(client, "{olive}[FF2]{default} Started boss music for %s.", targetName);
        }
        else
        {
            nomusic=false;
            StartMusic();
            CReplyToCommand(client, "{olive}[FF2]{default} Started boss music for all clients.");
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action:Command_StopMusic(client, args)
{
    if(Enabled2)
    {
        if(args)
        {
            decl String:pattern[MAX_TARGET_LENGTH];
            GetCmdArg(1, pattern, sizeof(pattern));
            new String:targetName[MAX_TARGET_LENGTH];
            new targets[MAXPLAYERS], matches;
            new bool:targetNounIsMultiLanguage;
            if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage))<=0)
            {
                ReplyToTargetError(client, matches);
                return Plugin_Handled;
            }

            if(matches>1)
            {
                for(new target; target<matches; target++)
                {
                    StopMusic(targets[target], true, true);
                }
            }
            else
            {
                StopMusic(targets[0], true, true);
            }
            CReplyToCommand(client, "{olive}[FF2]{default} Stopped boss music for %s.", targetName);
        }
        else
        {
            nomusic=true;
            StopMusic(_, true, true);
            CReplyToCommand(client, "{olive}[FF2]{default} Stopped boss music for all clients.");
        }
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action:MusicTogglePanelCmd(client, args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }
    
    if(args)
    {
        decl String:cmd[64];
        GetCmdArgString(cmd, sizeof(cmd));
        if(StrContains(cmd, "off", false)!=-1 || StrContains(cmd, "disable", false)!=-1 || StrContains(cmd, "0", false)!=-1)
        {
            ToggleBGM(client, false);
        }
        else if(StrContains(cmd, "on", false)!=-1 || StrContains(cmd, "enable", false)!=-1 || StrContains(cmd, "1", false)!=-1)
        {
            if(CheckClientSoundOptions(client, SoundException_BossMusic)!=FF2Setting_Disabled)
            {
                CReplyToCommand(client, "{olive}[FF2]{default} You already have boss themes enabled...");
                return Plugin_Handled;
            }
            ToggleBGM(client, true);
        }
        CPrintToChat(client, "{olive}[FF2]{default} %t", "ff2_music", CheckClientSoundOptions(client, SoundException_BossMusic)==FF2Setting_Disabled ? "off" : "on");
        return Plugin_Handled;
    }

    MusicTogglePanel(client);
    return Plugin_Handled;    
}

public Action:MusicTogglePanel(client)
{
    if(!Enabled || !IsValidClient(client))
    {
        return Plugin_Continue;
    }

    char title[128];
    new Handle:togglemusic = CreateMenu(MusicTogglePanelH);
    Format(title,sizeof(title), "%t", "theme_menu");
    SetMenuTitle(togglemusic, title, title);
    Format(title, sizeof(title), "%t", CheckClientSoundOptions(client, SoundException_BossMusic)!=FF2Setting_Disabled ? "themes_disable" : "themes_enable");
    AddMenuItem(togglemusic, title, title);    
    if(CheckClientSoundOptions(client, SoundException_BossMusic)!=FF2Setting_Disabled)
    {
        Format(title, sizeof(title), "%t", "theme_skip");
        AddMenuItem(togglemusic, title, title);
        Format(title, sizeof(title), "%t", "theme_shuffle");
        AddMenuItem(togglemusic, title, title);
        Format(title, sizeof(title), "%t", "theme_select");
        AddMenuItem(togglemusic, title, title);
    }
    SetMenuExitButton(togglemusic, true);
    DisplayMenu(togglemusic, client, MENU_TIME_FOREVER);
    return Plugin_Continue;
}    


public MusicTogglePanelH(Handle:menu, MenuAction:action, client, selection)
{
    if(IsValidClient(client) && action==MenuAction_Select)
    {
        switch(selection)
        {    
            case 0:
            {
                ToggleBGM(client, CheckClientSoundOptions(client, SoundException_BossMusic)!=FF2Setting_Disabled ? false : true);               
                CPrintToChat(client, "{olive}[FF2]{default} %t", "ff2_music", CheckClientSoundOptions(client, SoundException_BossMusic)==FF2Setting_Disabled ? "off" : "on");
            }
            case 1: Command_SkipSong(client, 0);
            case 2: Command_ShuffleSong(client, 0);
            case 3: Command_Tracklist(client, 0);
        }
    }
}

ToggleBGM(client, bool:enable)
{
    if(enable)
    {
        SetClientSoundOptions(client, SoundException_BossMusic, FF2Setting_Enabled);
        if(CheckRoundState()==FF2RoundState_RoundRunning)
        {
            PrepareBGM(client);
        }      
    }
    else
    {
        SetClientSoundOptions(client, SoundException_BossMusic, FF2Setting_Disabled);
        StopMusic(client, true, nomusic);    
    }

}

public void PlayMusic(int client, char[] music, float time, bool loop, char[] name, char[] artist)
{
    PlayBGM(client, music, time, loop, name, artist);
}

PlayBGM(client, String:music[], Float:time, bool:loop=true, char[] name="", char[] artist="")
{
    if(CheckRoundState()!=FF2RoundState_RoundRunning || (!client && MapHasMusic()) || StrEqual(currentBGM[client], "ff2_stop_music", true))
    {
        PlayBGMAt[client]=INACTIVE;
        return;
    }
            
    Action action;
    Call_StartForward(OnMusic);
    char temp[3][PLATFORM_MAX_PATH];
    float time2=time;
    strcopy(temp[0], sizeof(temp[]), music);
    strcopy(temp[1], sizeof(temp[]), name);
    strcopy(temp[2], sizeof(temp[]), artist);
    Call_PushStringEx(temp[0], sizeof(temp[]), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_PushFloatRef(time2);
    Call_PushStringEx(temp[1], sizeof(temp[]), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_PushStringEx(temp[2], sizeof(temp[]), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_Finish(action);
    switch(action)
    {
        case Plugin_Stop, Plugin_Handled:
        {
            PlayBGMAt[client]=INACTIVE;
            return;
        }
        case Plugin_Changed:
        {
            strcopy(music, PLATFORM_MAX_PATH, temp[0]);
            time=time2;
            strcopy(name, 256, temp[1]);
            strcopy(artist, 256, temp[2]);
        }
    }

    if(CheckClientSoundOptions(client, SoundException_BossMusic)!=FF2Setting_Disabled)
    {
        char bgm[PLATFORM_MAX_PATH];
        Format(bgm, PLATFORM_MAX_PATH, "#%s", music);
        strcopy(currentBGM[client], PLATFORM_MAX_PATH, bgm);
        ClientCommand(client, "playgamesound \"%s\"", bgm);
    }
    
    if(!name[0])
    {
        Format(name[0], 256, "%t", "unknown_song");
    }
    
    if(!artist[0])
    {
        Format(artist[0], 256, "%t", "unknown_artist");
    }
    
    CPrintToChat(client, "{olive}[FF2]{default} %t", "track_info", artist, name);
    
    if(loop && time>1)
    {
        if(PlayBGMAt[client]!=INACTIVE)
        {
            PlayBGMAt[client]+=time;
        }
        else
        {
            PlayBGMAt[client]=GetEngineTime()+time;
        }
    }
}


public Action Command_SkipSong(int client, int args)
{
    if(!client)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return Plugin_Handled;
    }
    
    
    if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_please wait");
        return Plugin_Handled;
    }

    if(StrEqual(currentBGM[client], "ff2_stop_music", true)|| CheckClientSoundOptions(client, SoundException_BossMusic)==FF2Setting_Disabled)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_music_disabled");
        return Plugin_Handled;
    }
    
    CReplyToCommand(client, "{olive}[FF2]{default} %t", "track_skipped");
    
    StopMusic(client, true);
    
    char id3[4][256];
    KvRewind(BossKV[characterIdx[0]]);
    if(KvJumpToKey(BossKV[characterIdx[0]], "sound_bgm"))
    {
        char music[PLATFORM_MAX_PATH];
        int index;
        do
        {
            index++;
            Format(music, 10, "time%i", index);
        }
        while(KvGetFloat(BossKV[characterIdx[0]], music)>1);

        if(!index)
        {
            ReplyToCommand(client, "[FF2] %t", "ff2_no_music");        
            return Plugin_Handled;        
        }
        
        cursongId[client]++;
        if(cursongId[client]>=index)
        {
            cursongId[client]=1;
        }
        
        Format(music, 10, "time%i", cursongId[client]);
        float time=KvGetFloat(BossKV[characterIdx[0]], music);
        Format(music, 10, "path%i", cursongId[client]);
        KvGetString(BossKV[characterIdx[0]], music, music, sizeof(music));
        
        Format(id3[0], sizeof(id3[]), "name%i", cursongId[client]);
        KvGetString(BossKV[characterIdx[0]], id3[0], id3[2], sizeof(id3[]));
        Format(id3[1], sizeof(id3[]), "artist%i", cursongId[client]);
        KvGetString(BossKV[characterIdx[0]], id3[1], id3[3], sizeof(id3[]));

        decl String:temp[PLATFORM_MAX_PATH];
        Format(temp, sizeof(temp), "sound/%s", music);
        if(FileExists(temp, true))
        {
            PlayBGM(client, music, time, _, id3[2], id3[3]);
        }
        else
        {
            decl String:bossName[64];
            KvRewind(BossKV[characterIdx[0]]);
            KvGetString(BossKV[characterIdx[0]], "filename", bossName, sizeof(bossName));
            LogToFile(bLog, "[FF2 Bosses] Character %s is missing BGM file '%s'!", bossName, temp);
            if(PlayBGMAt[client]!=INACTIVE)
            {
                PlayBGMAt[client]+=time;
            }
            else
            {
                PlayBGMAt[client]=GetEngineTime()+time;
            }
        } 
    }
    return Plugin_Handled;
}
    
public Action Command_ShuffleSong(int client, int args)
{
    if(!client)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return Plugin_Handled;
    }
    
    if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_please wait");
        return Plugin_Handled;
    }
    
    if(StrEqual(currentBGM[client], "ff2_stop_music", true)|| CheckClientSoundOptions(client, SoundException_BossMusic)==FF2Setting_Disabled)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_music_disabled");
        return Plugin_Handled;
    }
    
    CReplyToCommand(client, "{olive}[FF2]{default} %t", "track_shuffle");
    StartMusic(client);
    return Plugin_Handled;
}

public Action Command_Tracklist(int client, int args)
{
    if(!client)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return Plugin_Handled;
    }

    if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_please wait");
        return Plugin_Handled;
    }
    
    if(StrEqual(currentBGM[client], "ff2_stop_music", true)|| CheckClientSoundOptions(client, SoundException_BossMusic)==FF2Setting_Disabled)
    {
        ReplyToCommand(client, "[FF2] %t", "ff2_music_disabled");
        return Plugin_Handled;
    }

    char id3[6][256];
    new Handle:trackList = CreateMenu(Command_TrackListH);
    SetMenuTitle(trackList, "%t", "track_select");
    KvRewind(BossKV[characterIdx[0]]);
    if(KvJumpToKey(BossKV[characterIdx[0]], "sound_bgm"))
    {
        decl String:music[PLATFORM_MAX_PATH];
        new index;
        do
        {
            index++;
            Format(music, 10, "time%i", index);
        }
        while(KvGetFloat(BossKV[characterIdx[0]], music)>1);

        if(!index)
        {
            ReplyToCommand(client, "[FF2] %t", "ff2_no_music");        
            return Plugin_Handled;        
        }
        
        for(new trackIdx=1;trackIdx<=index-1;trackIdx++)
        {
            Format(id3[0], sizeof(id3[]), "name%i", trackIdx);
            KvGetString(BossKV[characterIdx[0]], id3[0], id3[2], sizeof(id3[]));
            Format(id3[1], sizeof(id3[]), "artist%i", trackIdx);
            KvGetString(BossKV[characterIdx[0]], id3[1], id3[3], sizeof(id3[]));
            GetSongTime(trackIdx, id3[5], sizeof(id3[]));
            if(!id3[3])
            {
                Format(id3[3], sizeof(id3[]), "%t", "unknown_artist");
            }
            if(!id3[2])
            {
                Format(id3[2], sizeof(id3[]), "%t", "unknown_song");
            }
            Format(id3[4], sizeof(id3[]), "%s - %s (%s)", id3[3], id3[2], id3[5]);
            CRemoveTags(id3[4], sizeof(id3[]));
            AddMenuItem(trackList, id3[4], id3[4]);
        }
    }  
    
    SetMenuExitButton(trackList, true);
    DisplayMenu(trackList, client, MENU_TIME_FOREVER);
    return Plugin_Handled;
}

stock float GetSongLength(char[] trackIdx)
{
    float duration;
    char bgmTime[128];
    KvGetString(BossKV[characterIdx[0]], trackIdx, bgmTime, sizeof(bgmTime));
    if(StrContains(bgmTime, ":", false)!=-1) // new-style MM:SS:MSMS
    {
        char time2[32][32];
        int count = ExplodeString(bgmTime, ":", time2, sizeof(time2), sizeof(time2));
        if (count > 0)
        {
            for (int i = 0; i < count; i+=3)
            {
                char newTime[64];
                int mins=StringToInt(time2[i])*60;
                int secs=StringToInt(time2[i+1]);
                int milsecs=StringToInt(time2[i+2]);
                Format(newTime, sizeof(newTime), "%i.%i", mins+secs, milsecs);
                duration=StringToFloat(newTime);                   
            }
        }
    }
    else // old style seconds
    {
        duration=KvGetFloat(BossKV[characterIdx[0]], trackIdx);
    }
    return duration;
}

stock void GetSongTime(int trackIdx, char[] timeStr, length)
{
    char songIdx[32];
    Format(songIdx, sizeof(songIdx), "time%i", trackIdx);
    int time=RoundToFloor(GetSongLength(songIdx));
    if(time/60>9)
    {
        IntToString(time/60, timeStr, length);
    }
    else
    {
        Format(timeStr, length, "0%i", time/60);
    }

    if(time%60>9)
    {
        Format(timeStr, length, "%s:%i", timeStr, time%60);
    }
    else
    {
        Format(timeStr, length, "%s:0%i", timeStr, time%60);
    }
}

public int Command_TrackListH(Handle menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End:
        {
            CloseHandle(menu);
        }
        
        case MenuAction_Select:
        {
            StopMusic(param1, true);
            KvRewind(BossKV[characterIdx[0]]);
            if(KvJumpToKey(BossKV[characterIdx[0]], "sound_bgm"))
            {
                char music[PLATFORM_MAX_PATH];
                int track=param2+1;
                Format(music, 10, "time%i", track);

                float time=GetSongLength(music);
                Format(music, 10, "path%i", track);
                KvGetString(BossKV[characterIdx[0]], music, music, sizeof(music));

                char id3[4][256];
                Format(id3[0], sizeof(id3[]), "name%i", track);
                KvGetString(BossKV[characterIdx[0]], id3[0], id3[2], sizeof(id3[]));
                Format(id3[1], sizeof(id3[]), "artist%i", track);
                KvGetString(BossKV[characterIdx[0]], id3[1], id3[3], sizeof(id3[]));
        
                char temp[PLATFORM_MAX_PATH];
                Format(temp, sizeof(temp), "sound/%s", music);
                if(FileExists(temp, true))
                {
                    PlayBGM(param1, music, time, _, id3[2], id3[3]);
                }
                else
                {
                    char bossName[64];
                    KvRewind(BossKV[characterIdx[0]]);
                    KvGetString(BossKV[characterIdx[0]], "filename", bossName, sizeof(bossName));
                    LogToFile(bLog, "[FF2 Bosses] Character %s is missing BGM file '%s'!", bossName, temp);
                    if(PlayBGMAt[param1]!=INACTIVE)
                    {
                        PlayBGMAt[param1]+=time;
                    }
                    else
                    {
                        PlayBGMAt[param1]=GetEngineTime()+time;
                    }
                }
            }
        }            
    }
}

void StartMusic(int client=0)
{
    if(client<=0)  //Start music for all clients
    {
        StopMusic(_, true);
        for(client=MaxClients;client;client--)
        {
            if(!IsValidClient(client))
            {
                continue;
            }
            PrepareBGM(client);
        }
    }
    else    
    {
        StopMusic(client, true);
        PrepareBGM(client);
    }
}

void PrepareBGM(int client)
{
    if(CheckRoundState()!=FF2RoundState_RoundRunning || (!client && MapHasMusic()) || StrEqual(currentBGM[client], "ff2_stop_music", true))
    {
        PlayBGMAt[client]=INACTIVE;
        return;
    }

    KvRewind(BossKV[characterIdx[0]]);
    if(KvJumpToKey(BossKV[characterIdx[0]], "sound_bgm"))
    {
        char music[PLATFORM_MAX_PATH];
        int index;
        do
        {
            index++;
            Format(music, 10, "time%i", index);
        }
        while(KvGetFloat(BossKV[characterIdx[0]], music)>1);

        index=GetRandomInt(1, index-1);
        Format(music, 10, "time%i", index);
        
        float time=GetSongLength(music);

        Format(music, 10, "path%i", index);
        KvGetString(BossKV[characterIdx[0]], music, music, sizeof(music));
        
        cursongId[client]=index;
        
        // manual song ID
        char id3[4][256];
        Format(id3[0], sizeof(id3[]), "name%i", index);
        KvGetString(BossKV[characterIdx[0]], id3[0], id3[2], sizeof(id3[]));
        Format(id3[1], sizeof(id3[]), "artist%i", index);
        KvGetString(BossKV[characterIdx[0]], id3[1], id3[3], sizeof(id3[]));
        
        char temp[PLATFORM_MAX_PATH];
        Format(temp, sizeof(temp), "sound/%s", music);
        if(FileExists(temp, true))
        {
            PlayBGM(client, music, time, _, id3[2], id3[3]);
        }
        else
        {
            char bossName[64];
            KvRewind(BossKV[characterIdx[0]]);
            KvGetString(BossKV[characterIdx[0]], "filename", bossName, sizeof(bossName));
            LogToFile(bLog, "[FF2 Bosses] Character %s is missing BGM file '%s'!", bossName, temp);
            if(PlayBGMAt[client]!=INACTIVE)
            {
                PlayBGMAt[client]+=time;
            }
            else
            {
                PlayBGMAt[client]=GetEngineTime()+time;
            }
        }
    }  
}

void StopMusic(int client=0, bool endloop=false, bool permanent=false)
{
    if(client<=0)  //Stop music for all clients
    {
        for(client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client))
            {
                StopSound(client, SNDCHAN_AUTO, currentBGM[client]);
                StopSound(client, SNDCHAN_AUTO, currentBGM[client]);
            }

            if(PlayBGMAt[client]!=INACTIVE && endloop)
            {
                PlayBGMAt[client]=INACTIVE;
            }
            strcopy(currentBGM[client], PLATFORM_MAX_PATH, !permanent ? "" : "ff2_stop_music");
        }
    }
    else
    {
        StopSound(client, SNDCHAN_AUTO, currentBGM[client]);
        StopSound(client, SNDCHAN_AUTO, currentBGM[client]);

        if(PlayBGMAt[client]!=INACTIVE && endloop)
        {
            PlayBGMAt[client]=INACTIVE;
        }
        strcopy(currentBGM[client], PLATFORM_MAX_PATH, !permanent ? "" : "ff2_stop_music");
    }
}
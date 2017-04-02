// sounds
public Action:VoiceTogglePanelCmd(client, args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }

    VoiceTogglePanel(client);
    return Plugin_Handled;
}

public Action:VoiceTogglePanel(client)
{
    if(!Enabled || !IsValidClient(client))
    {
        return Plugin_Continue;
    }

    new Handle:panel=CreatePanel();
    SetPanelTitle(panel, "Turn the Freak Fortress 2 voices...");
    DrawPanelItem(panel, "On");
    DrawPanelItem(panel, "Off");
    SendPanelToClient(panel, client, VoiceTogglePanelH, MENU_TIME_FOREVER);
    CloseHandle(panel);
    return Plugin_Continue;
}

public VoiceTogglePanelH(Handle:menu, MenuAction:action, client, selection)
{
    if(IsValidClient(client))
    {
        if(action==MenuAction_Select)
        {
            if(selection==2)
            {
                SetClientSoundOptions(client, SoundException_BossVoice, FF2Setting_Disabled);
            }
            else
            {
                SetClientSoundOptions(client, SoundException_BossVoice, FF2Setting_Enabled);
            }

            CPrintToChat(client, "{olive}[FF2]{default} %t", "ff2_voice", selection==2 ? "off" : "on");
            if(selection==2)
            {
                CPrintToChat(client, "%t", "ff2_voice2");
            }
        }
    }
}

stock bool:RandomSound(const String:sound[], String:file[], length, boss=0)
{
    if(boss<0 || characterIdx[boss]<0 || !BossKV[characterIdx[boss]])
    {
        return false;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(!KvJumpToKey(BossKV[characterIdx[boss]], sound))
    {
        KvRewind(BossKV[characterIdx[boss]]);
        return false;  //Requested sound not implemented for this boss
    }

    new String:key[4];
    new sounds;
    while(++sounds)  //Just keep looping until there's no keys left
    {
        IntToString(sounds, key, sizeof(key));
        KvGetString(BossKV[characterIdx[boss]], key, file, length);
        if(!file[0])
        {
            sounds--;  //This sound wasn't valid, so don't include it
            break;  //Assume that there's no more sounds
        }
    }

    if(!sounds)
    {
        return false;  //Found sound, but no sounds inside of it
    }

    IntToString(GetRandomInt(1, sounds), key, sizeof(key));
    KvGetString(BossKV[characterIdx[boss]], key, file, length);  //Populate file
    return true;
}

stock bool:FindSound(const String:sound[], String:file[], length, boss=0, bool:ability=false, slot=0)
{
    if(boss<0 || characterIdx[boss]<0 || !BossKV[characterIdx[boss]])
    {
        return false;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(!KvJumpToKey(BossKV[characterIdx[boss]], "sounds"))
    {
        KvRewind(BossKV[characterIdx[boss]]);
        return false;  //Boss doesn't have any sounds
    }

    new i;
    decl String:sounds[MaxAbilities][PLATFORM_MAX_PATH];
    while(KvGotoNextKey(BossKV[characterIdx[boss]]))  //Just keep looping until there's no keys left
    {
        if(KvGetNum(BossKV[characterIdx[boss]], sound))
        {
            if(!ability || KvGetNum(BossKV[characterIdx[boss]], "slot")==slot)
            {
                KvGetSectionName(BossKV[characterIdx[boss]], sounds[i], PLATFORM_MAX_PATH);
                i++;
            }
        }
    }

    if(!i)
    {
        return false;  //No sounds matching what we want
    }

    strcopy(file, length, sounds[GetRandomInt(0, i-1)]);
    return true;
}

stock bool:RandomSoundAbility(const String:sound[], String:file[], length, boss=0, slot=0)
{
    if(boss==-1 || characterIdx[boss]==-1 || !BossKV[characterIdx[boss]])
    {
        return false;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(!KvJumpToKey(BossKV[characterIdx[boss]], sound))
    {
        return false;  //Sound doesn't exist
    }

    new String:key[10];
    new sounds, matches, match[MaxAbilities];
    while(++sounds)
    {
        IntToString(sounds, key, 4);
        KvGetString(BossKV[characterIdx[boss]], key, file, length);
        if(!file[0])
        {
            break;  //Assume that there's no more sounds
        }

        Format(key, sizeof(key), "slot%i", sounds);
        if(KvGetNum(BossKV[characterIdx[boss]], key, 0)==slot)
        {
            match[matches]=sounds;  //Found a match: let's store it in the array
            matches++;
        }
    }

    if(!matches)
    {
        return false;  //Found sound, but no sounds inside of it
    }

    IntToString(match[GetRandomInt(0, matches-1)], key, 4);
    KvGetString(BossKV[characterIdx[boss]], key, file, length);  //Populate file
    return true;
}

//Ugly compatability layer since SoundHook's arguments changed in 1.8
#if SOURCEMOD_V_MAJOR==1 && SOURCEMOD_V_MINOR<=7
public Action:SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &client, &channel, &Float:volume, &level, &pitch, &flags)
#else
public Action:SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &client, &channel, &Float:volume, &level, &pitch, &flags, String:soundEntry[PLATFORM_MAX_PATH], &seed)
#endif
{
    if(!Enabled || !IsValidClient(client) || channel<1)
    {
        return Plugin_Continue;
    }

    new boss=GetBossIndex(client);
    if(boss==-1)
    {
        return Plugin_Continue;
    }

    if(channel==SNDCHAN_VOICE && !(FF2Flags[Boss[boss]] & FF2FLAG_TALKING))
    {
        decl String:newSound[PLATFORM_MAX_PATH];
        if(RandomSound("catch_phrase", newSound, sizeof(newSound), boss) || FindSound("catch_phrase", newSound, sizeof(newSound), boss))
        {
            strcopy(sound, PLATFORM_MAX_PATH, newSound);
            return Plugin_Changed;
        }
        if(bBlockVoice[characterIdx[boss]])
        {
            return Plugin_Stop;
        }
    }
    return Plugin_Continue;
}


stock EmitSoundToAllExcept(SoundException:type=SoundException_BossMusic, const String:sample[], entity=SOUND_FROM_PLAYER, channel=SNDCHAN_AUTO, level=SNDLEVEL_NORMAL, flags=SND_NOFLAGS, Float:volume=SNDVOL_NORMAL, pitch=SNDPITCH_NORMAL, speakerentity=-1, const Float:origin[3]=NULL_VECTOR, const Float:dir[3]=NULL_VECTOR, bool:updatePos=true, Float:soundtime=0.0)
{
    new clients[MaxClients], total;
    for(new client=1; client<=MaxClients; client++)
    {
        if(IsValidClient(client) && IsClientInGame(client))
        {
            if(CheckClientSoundOptions(client, type)!=FF2Setting_Disabled)
            {
                clients[total++]=client;
            }
        }
    }

    if(!total)
    {
        return;
    }

    EmitSound(clients, total, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}
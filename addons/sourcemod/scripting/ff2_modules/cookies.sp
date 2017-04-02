stock void PrepareCookies(Handle cookie[10])
{
    cookie[Cookie_DisplayInfo] = RegClientCookie("ff2_info_toggle", "FF2 Info Toggle", CookieAccess_Protected);    
    cookie[Cookie_BossToggle] = RegClientCookie("ff2_boss_toggle", "FF2 Boss Toggle", CookieAccess_Protected);    
    cookie[Cookie_CompanionToggle] = RegClientCookie("ff2_companion_toggle", "FF2 Companion Boss Toggle", CookieAccess_Protected);        
    cookie[Cookie_Difficulty] = RegClientCookie("ff2_difficulty", "FF2 Difficulty Settings", CookieAccess_Protected);
    cookie[Cookie_QueuePoints] = RegClientCookie("ff2_queue_points", "FF2 Queue Points", CookieAccess_Protected);
    cookie[Cookie_ToggleMusic] = RegClientCookie("ff2_music", "FF2 Music Settings", CookieAccess_Protected);
    cookie[Cookie_ToggleVoice] = RegClientCookie("ff2_voice", "FF2 Voice Settings", CookieAccess_Protected);
    cookie[Cookie_SkillGroup] = RegClientCookie("ff2_voice", "FF2 Player Ranks", CookieAccess_Protected);
}

bool:GetClientClassinfoCookie(client)
{
    if(!IsValidClient(client) || IsFakeClient(client))
    {
        return false;
    }

    if(!AreClientCookiesCached(client))
    {
        return true;
    }
    
    return GetClientSetting(client, FF2Cookie[Cookie_DisplayInfo], _)!=FF2Setting_Disabled ? true : false;
}

void PrepareStatTrakCookie()
{
    winCookie = RegClientCookie("ff2_boss_wins", "FF2 Boss Win Tracker", CookieAccess_Public);        
    lossCookie = RegClientCookie("ff2_boss_losses", "FF2 Boss Loss Tracker", CookieAccess_Public);        
    killCookie = RegClientCookie("ff2_boss_kills", "FF2 Boss Kill Tracker", CookieAccess_Public);
    deathCookie = RegClientCookie("ff2_boss_kills", "FF2 Boss Death Tracker", CookieAccess_Public);
    bossslainCookie = RegClientCookie("ff2_bosses_killed", "FF2 Bosses Slain Tracker", CookieAccess_Public);
    mvpCookie = RegClientCookie("ff2_mvps", "FF2 MVP Tracker", CookieAccess_Public);
    for(int i = 0; i < MAXPLAYERS; i++)
    {
        bossWins[i]=0;
        bossDefeats[i]=0;
        bossKills[i]=0;
        bossDeaths[i]=0;
        bossesSlain[i]=0;
        mvpCount[i]=0;
    }
    
    for(int client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
            continue;
        if(!AreClientCookiesCached(client))
            continue;
        LoadStatCookie(client);
        LoadClientPrefCookies(client);
    }
}

ShowBossStats(winningTeam)
{
    for(new client=0;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
        {
            continue;
        }
        
        if(IsBoss(client))
        {
            if(winningTeam==BossTeam)
            {
                bossWins[client]++;
            }
            else
            {
                bossDefeats[client]++;
            }
            SaveBossStatCookie(client);
            CPrintToChatAll("{olive}[FF2] %t", "boss_stats", client, bossWins[client], bossDefeats[client]);
        }
        else
        {
            SavePlayerStatCookie(client);
        }
    }
}

stock void SaveBossStatCookie(int client)
{
    char statCookie[256];
    IntToString(bossWins[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, winCookie, statCookie);
    IntToString(bossDefeats[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, lossCookie, statCookie);
    IntToString(bossKills[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, killCookie, statCookie);
    IntToString(bossDeaths[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, deathCookie, statCookie);
}

stock void SavePlayerStatCookie(int client)
{
    char statCookie[256];
    IntToString(bossesSlain[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, bossslainCookie, statCookie);
    IntToString(mvpCount[client], statCookie, sizeof(statCookie));
    SetClientCookie(client, mvpCookie, statCookie);
}

stock void LoadStatCookie(int client)
{
    char statCookie[256];
    GetClientCookie(client, winCookie, statCookie, sizeof(statCookie));
    bossWins[client] = StringToInt(statCookie);
    GetClientCookie(client, lossCookie, statCookie, sizeof(statCookie));
    bossDefeats[client] = StringToInt (statCookie);
    GetClientCookie(client, killCookie, statCookie, sizeof(statCookie));
    bossKills[client] = StringToInt(statCookie);
    GetClientCookie(client, deathCookie, statCookie, sizeof(statCookie));
    bossDeaths[client] = StringToInt(statCookie);
    GetClientCookie(client, bossslainCookie, statCookie, sizeof(statCookie));
    bossesSlain[client] = StringToInt(statCookie);
    GetClientCookie(client, mvpCookie, statCookie, sizeof(statCookie));
    mvpCount[client] = StringToInt(statCookie);
}

public void OnClientCookiesCached(int client)
{
    LoadStatCookie(client);
    LoadClientPrefCookies(client);
}

stock void LoadClientPrefCookies(int client)
{
    decl String:sEnabled[5];
    // !ff2toggle
    GetClientCookie(client, FF2Cookie[Cookie_BossToggle], sEnabled, sizeof(sEnabled));
    BossCookieSetting[client]=FF2Prefs:StringToInt(sEnabled);
    // !ff2companion
    GetClientCookie(client, FF2Cookie[Cookie_CompanionToggle], sEnabled, sizeof(sEnabled));
    CompanionCookieSetting[client]=FF2Prefs:StringToInt(sEnabled);
    // !ff2difficulty
    GetClientCookie(client, FF2Cookie[Cookie_Difficulty], sEnabled, sizeof(sEnabled));
    FF2ClientDifficulty[client]=FF2Difficulty:StringToInt(sEnabled);    
}

stock FF2Prefs GetClientSetting(int client, Handle cookiename, FF2Prefs clientsetting=FF2Setting_None)
{
    if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return FF2Setting_Unknown;
    }

    char setting[5];
    GetClientCookie(client, cookiename, setting, sizeof(setting));
    
    if(clientsetting!=FF2Setting_None)
    {
        clientsetting=view_as<FF2Prefs>(StringToInt(setting));
    }
    
    return view_as<FF2Prefs>(StringToInt(setting));
}

stock void SetClientSetting(int client, Handle cookiename=null, FF2Prefs clientsetting=FF2Setting_None, FF2Prefs setting, bool save=false)
{
    if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return;
    }
    
    if(clientsetting!=FF2Setting_None)
    {
        clientsetting=setting;
    }

    if(save && cookiename!=null)
    {
        char cookievalue[5];
        IntToString(view_as<int>(setting), cookievalue, sizeof(cookievalue));
        SetClientCookie(client, cookiename, cookievalue);
    }
}

stock CheckInfoCookies(client, cookie)
{
    if(!IsValidClient(client))
    {
        return false;
    }

    if(IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return true;
    }
    
    //FF2Cookie[Cookie_DisplayInfo]

    decl String:cookies[24];
    decl String:cookieValues[8][5];
    GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
    ExplodeString(cookies, " ", cookieValues, 8, 5);
    new value=StringToInt(cookieValues[cookie+4]);
    return (value>0 ? value : 0);
}

stock SetInfoCookies(client, cookie, value)
{
    if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return;
    }

    decl String:cookies[24];
    decl String:cookieValues[8][5];
    GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
    ExplodeString(cookies, " ", cookieValues, 8, 5);
    Format(cookies, sizeof(cookies), "%s %s %s %s", cookieValues[0], cookieValues[1], cookieValues[2], cookieValues[3]);
    for(new i; i<cookie; i++)
    {
        Format(cookies, sizeof(cookies), "%s %s", cookies, cookieValues[i+4]);
    }

    Format(cookies, sizeof(cookies), "%s %i", cookies, value);
    for(new i=cookie+1; i<4; i++)
    {
        Format(cookies, sizeof(cookies), "%s %s", cookies, cookieValues[i+4]);
    }
    SetClientCookie(client, FF2Cookies, cookies);
}


stock FF2Prefs CheckClientSoundOptions(int client, SoundException type)
{
    if(!IsValidClient(client))
    {
        return FF2Setting_Unknown;
    }

    if(IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return FF2Setting_Unknown;
    }

    char cookievalue[5];
    GetClientCookie(client, FF2Cookie[type==SoundException_BossVoice ? Cookie_ToggleVoice : Cookie_ToggleMusic], cookievalue, sizeof(cookievalue));

    return view_as<FF2Prefs>(StringToInt(cookievalue));
}

stock void SetClientSoundOptions(int client, SoundException type, FF2Prefs setting)
{
    if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
    {
        return;
    }
    
    char cookievalue[5];
    IntToString(view_as<int>(setting), cookievalue, sizeof(cookievalue));
    SetClientCookie(client, FF2Cookie[type==SoundException_BossVoice ? Cookie_ToggleVoice : Cookie_ToggleMusic], cookievalue);
}
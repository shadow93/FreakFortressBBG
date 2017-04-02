// core
public EnableFF2()
{
    Enabled=true;
    Enabled2=true;

    //Cache cvars
    SetConVarString(FindConVar("ff2_version"), PLUGIN_VERSION);
    Announce=GetConVarFloat(cvarAnnounce);
    PointType=GetConVarInt(cvarPointType);
    PointDelay=GetConVarInt(cvarPointDelay);
    if(PointDelay<0)
    {
        PointDelay*=-1;
    }
    GoombaDamage=GetConVarFloat(cvarGoombaDamage);
    reboundPower=GetConVarFloat(cvarGoombaRebound);
    AliveToEnable=GetConVarInt(cvarAliveToEnable);
    BossCrits=GetConVarBool(cvarCrits);
    if(GetConVarInt(cvarFirstRound)!=-1)
    {
        arenaRounds=GetConVarInt(cvarFirstRound) ? 0 : 1;
    }
    else
    {
        arenaRounds=GetConVarInt(cvarArenaRounds);
    }
    circuitStun=GetConVarFloat(cvarCircuitStun);
    countdownHealth=GetConVarInt(cvarCountdownHealth);
    countdownPlayers=GetConVarInt(cvarCountdownPlayers);
    countdownTime=GetConVarInt(cvarCountdownTime);
    lastPlayerGlow=GetConVarBool(cvarLastPlayerGlow);
    bossTeleportation=GetConVarBool(cvarBossTeleporter);
    shieldCrits=GetConVarInt(cvarShieldCrits);
    allowedDetonations=GetConVarInt(cvarCaberDetonations);

    //Set some Valve cvars to what we want them to because
    SetConVarFloat(FindConVar("weapon_medigun_chargerelease_rate"), 12.0);
    SetConVarInt(FindConVar("tf_spec_xray"), 2);
    SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
    SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
    SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
    SetConVarInt(FindConVar("mp_forcecamera"), 0);
    SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), 0.0);
    SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), 0.3);
    SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), 0.0);
    SetConVarInt(FindConVar("tf_feign_death_duration"), 7);
        
    new Float:time=Announce;
    if(time>1.0)
    {
        AnnounceAt=GetEngineTime()+time;
    }
    
    CacheWeapons();
    CheckToChangeMapDoors();
    CheckToTeleportToSpawn();
    FindCharacters();
    
    MapHasMusic(true);
    strcopy(FF2CharSetString, 2, "");

    if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
    {
        ServerCommand("smac_removecvar sv_cheats");
        ServerCommand("smac_removecvar host_timescale");
    }

    bMedieval=FindEntityByClassname(-1, "tf_logic_medieval")!=-1 || bool:GetConVarInt(FindConVar("tf_medieval"));
    FindHealthBar();

    #if defined _steamtools_included
    if(steamtools)
    {
        new String:gameDesc[64];
        Format(gameDesc, sizeof(gameDesc), (DeadRunMode ? "Freak Fortress 2 Deathrun (%s)" : FF2x10 ? "Freak Fortress 2 x10 (%s)" : "Freak Fortress 2 (%s)"), PLUGIN_VERSION);            
        Steam_SetGameDescription(gameDesc);
    }
    #endif

    changeGamemode=0;
}

public DisableFF2()
{
    Enabled=false;
    Enabled2=false;

    DisableSubPlugins();

    SetConVarFloat(FindConVar("weapon_medigun_chargerelease_rate"), weapon_medigun_chargerelease_rate);
    SetConVarInt(FindConVar("tf_spec_xray"), tf_spec_xray);
    SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
    SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
    SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
    SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), tf_dropped_weapon_lifetime);
    SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), tf_feign_death_activate_damage_scale);
    SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), tf_feign_death_damage_scale);
    SetConVarInt(FindConVar("tf_feign_death_duration"), tf_feign_death_duration);
    SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
    SetConVarString(sName, hName);
    
    for(new client=1; client<=MaxClients; client++)
    {
        if(PlayBGMAt[client]!=INACTIVE)
        {
            PlayBGMAt[client]=INACTIVE;
        }
    }

    if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
    {
        ServerCommand("smac_addcvar sv_cheats replicated ban 0 0");
        ServerCommand("smac_addcvar host_timescale replicated ban 1.0 1.0");
    }

    #if defined _steamtools_included
    if(steamtools)
    {
        Steam_SetGameDescription("Team Fortress");
    }
    #endif

    changeGamemode=0;
}

EnableSubPlugins(bool:force=false)
{
    if(areSubPluginsEnabled && !force)
    {
        return;
    }

    areSubPluginsEnabled=true;
    new String:path[PLATFORM_MAX_PATH], String:filename[PLATFORM_MAX_PATH], String:filename_old[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "plugins/freaks");
    new FileType:filetype;
    new Handle:directory=OpenDirectory(path);
    while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
    {
        if(filetype==FileType_File && StrContains(filename, ".smx", false)!=-1)
        {
            Format(filename_old, sizeof(filename_old), "%s/%s", path, filename);
            ReplaceString(filename, sizeof(filename), ".smx", ".ff2", false);
            Format(filename, sizeof(filename), "%s/%s", path, filename);
            DeleteFile(filename);
            RenameFile(filename, filename_old);
        }
    }

    directory=OpenDirectory(path);
    while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
    {
        if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
        {
            ServerCommand("sm plugins load freaks/%s", filename);
        }
    }
}

DisableSubPlugins(bool:force=false)
{
    if(!areSubPluginsEnabled && !force)
    {
        return;
    }

    new String:path[PLATFORM_MAX_PATH], String:filename[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, path, sizeof(path), "plugins/freaks");
    new FileType:filetype;
    new Handle:directory=OpenDirectory(path);
    while(ReadDirEntry(directory, filename, sizeof(filename), filetype))
    {
        if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
        {
            InsertServerCommand("sm plugins unload freaks/%s", filename);  //ServerCommand will not work when switching maps
        }
    }
    ServerExecute();
    areSubPluginsEnabled=false;
}

public LoadCharacter(const String:characterName[])
{
    new String:extensions[][]={".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy"};
    new String:config[PLATFORM_MAX_PATH];

    BuildPath(Path_SM, config, sizeof(config), "configs/freak_fortress_2/%s.cfg", characterName);
    if(!FileExists(config))
    {
        LogToFile(eLog,"[FF2] Character %s does not exist!", characterName);
        return;
    }
    BossKV[Specials]=CreateKeyValues("characterName");
    FileToKeyValues(BossKV[Specials], config);

    cfgversion[Specials]=KvGetNum(BossKV[Specials], "version", 1);
    // v1 abilities
    for(new i=1; ; i++)
    {
        Format(config, sizeof(config), "ability%i", i);
        if(KvJumpToKey(BossKV[Specials], config))
        {
            new String:plugin_name[64];
            KvGetString(BossKV[Specials], "plugin_name", plugin_name, 64);
            BuildPath(Path_SM, config, sizeof(config), "plugins/freaks/%s.ff2", plugin_name);
            if(!FileExists(config))
            {
                LogToFile(bLog, "[FF2 Bosses] Character %s needs plugin %s!", characterName, plugin_name);
                return;
            }
        }
        else
        {
            break;
        }
    }
    // v2 abilities
    if(KvJumpToKey(BossKV[Specials], "abilities"))
    {
        while(KvGotoNextKey(BossKV[Specials]))
        {
            decl String:pluginName[64];
            KvGetSectionName(BossKV[Specials], pluginName, sizeof(pluginName));
            BuildPath(Path_SM, config, sizeof(config), "plugins/freak_fortress_2/%s.smx", pluginName);
            if(!FileExists(config))
            {
                LogError("[FF2] Character %s needs plugin %s!", characterName, pluginName);
                return;
            }
        }
    }
    KvRewind(BossKV[Specials]);
    
    new String:key[PLATFORM_MAX_PATH], String:section[64];
    KvSetString(BossKV[Specials], "filename", characterName);
    KvGetString(BossKV[Specials], "name", config, PLATFORM_MAX_PATH);
    bBlockVoice[Specials]=bool:KvGetNum(BossKV[Specials], "sound_block_vo", 0);
    #if defined FILECHECK_ENABLED
    bSkipFileChecks[Specials]=bool:KvGetNum(BossKV[Specials], "skip_filechecks", 0);
    #endif
    BossSpeed[Specials]=KvGetFloat(BossKV[Specials], "maxspeed", float(GetConVarInt(cvarDefaultMoveSpeed)));
    KvGotoFirstSubKey(BossKV[Specials]);

    // v1 bosses
    while(KvGotoNextKey(BossKV[Specials]))
    {
        KvGetSectionName(BossKV[Specials], section, sizeof(section));
        if(!strcmp(section, "download"))
        {
            for(new i=1; ; i++)
            {
                IntToString(i, key, sizeof(key));
                KvGetString(BossKV[Specials], key, config, PLATFORM_MAX_PATH);
                if(!config[0])
                {
                    break;
                }
                #if defined FILECHECK_ENABLED
                if(bSkipFileChecks[Specials])
                {
                    if(!FileExists(config, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, config);
                    AddFileToDownloadsTable(config);
                }
                else
                {
                    if(FileExists(config, true))
                        AddFileToDownloadsTable(config);
                    else
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, config);
                }
                #else
                AddFileToDownloadsTable(config);
                #endif
            }
        }
        else if(!strcmp(section, "mod_download"))
        {
            for(new i=1; ; i++)
            {
                IntToString(i, key, sizeof(key));
                KvGetString(BossKV[Specials], key, config, sizeof(config));
                if(!config[0])
                {
                    break;
                }

                for(new extension; extension<sizeof(extensions); extension++)
                {
                    Format(key, sizeof(key), "%s%s", config, extensions[extension]);
                    #if defined FILECHECK_ENABLED
                    if(bSkipFileChecks[Specials])
                    {
                        if(!FileExists(key, true) && StrContains(key, ".phy")==-1)
                            LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                        AddFileToDownloadsTable(key);
                    }
                    else
                    {
                        if(FileExists(key, true))
                            AddFileToDownloadsTable(key);
                        else
                        {
                            if(StrContains(key, ".phy")==-1)
                            {
                                LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                            }
                        }
                    }
                    #else
                    AddFileToDownloadsTable(key);
                    #endif
                }
            }
        }
        else if(!strcmp(section, "mat_download"))
        {
            for(new i=1; ; i++)
            {
                IntToString(i, key, sizeof(key));
                KvGetString(BossKV[Specials], key, config, PLATFORM_MAX_PATH);
                if(!config[0])
                {
                    break;
                }
                Format(key, sizeof(key), "%s.vtf", config);
                #if defined FILECHECK_ENABLED
                if(bSkipFileChecks[Specials])
                {
                    if(!FileExists(key, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                    AddFileToDownloadsTable(key);
                }
                else
                {
                    if(FileExists(key, true))
                        AddFileToDownloadsTable(key);
                    else
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                }
                #else
                AddFileToDownloadsTable(key);
                #endif
                Format(key, sizeof(key), "%s.vmt", config);
                #if defined FILECHECK_ENABLED
                if(bSkipFileChecks[Specials])
                {
                    if(!FileExists(key, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                    AddFileToDownloadsTable(key);
                }
                else
                {
                    if(FileExists(key, true))
                        AddFileToDownloadsTable(key);
                    else
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                }
                #else
                AddFileToDownloadsTable(key);
                #endif
            }
        }
    }
    
    // v2 bosses
    while(KvGotoNextKey(BossKV[Specials]))
    {
        KvGetSectionName(BossKV[Specials], section, sizeof(section));
        if(StrEqual(section, "downloads"))
        {
            while(KvGotoNextKey(BossKV[Specials]))
            {
                KvGetSectionName(BossKV[Specials], key, sizeof(key));
                if(KvGetNum(BossKV[Specials], "model"))
                {
                    for(new extension; extension<sizeof(extensions); extension++)
                    {
                        Format(key, sizeof(key), "%s%s", key, extensions[extension]);
                        #if defined FILECHECK_ENABLED
                        if(bSkipFileChecks[Specials])
                        {
                            if(!FileExists(key, true))
                                LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                            AddFileToDownloadsTable(key);
                        }
                        else
                        {
                            if(FileExists(key, true))
                                AddFileToDownloadsTable(key);
                            else
                                LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                        }
                        #else
                        AddFileToDownloadsTable(key);
                        #endif
                    }

                    if(KvGetNum(BossKV[Specials], "phy"))
                    {
                        Format(key, sizeof(key), "%s.phy", key);
                        #if defined FILECHECK_ENABLED
                        if(bSkipFileChecks[Specials])
                        {
                            if(!FileExists(key, true))
                                LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                            AddFileToDownloadsTable(key);
                        }
                        else
                        {
                            if(FileExists(key, true))
                                AddFileToDownloadsTable(key);
                            else
                                LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                        }
                        #else
                        AddFileToDownloadsTable(key);
                        #endif
                    }
                }
                else if(KvGetNum(BossKV[Specials], "material"))
                {
                    Format(key, sizeof(key), "%s.vmt", key);
                    #if defined FILECHECK_ENABLED
                    if(bSkipFileChecks[Specials])
                    {
                        if(!FileExists(key, true))
                            LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                        AddFileToDownloadsTable(key);
                    }
                    else
                    {
                        if(FileExists(key, true))
                            AddFileToDownloadsTable(key);
                        else
                            LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                    }
                    #else
                    AddFileToDownloadsTable(key);
                    #endif

                    Format(key, sizeof(key), "%s.vtf", key);
                    #if defined FILECHECK_ENABLED
                    if(bSkipFileChecks[Specials])
                    {
                        if(!FileExists(key, true))
                            LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                        AddFileToDownloadsTable(key);
                    }
                    else
                    {
                        if(FileExists(key, true))
                            AddFileToDownloadsTable(key);
                        else
                            LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                    }
                    #else
                    AddFileToDownloadsTable(key);
                    #endif
                }
                #if defined FILECHECK_ENABLED
                else if(bSkipFileChecks[Specials])
                {
                    if(!FileExists(key, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s'", characterName, key);
                    AddFileToDownloadsTable(key);
                }
                else
                {
                    if(FileExists(key, true))
                        AddFileToDownloadsTable(key);
                    else
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'!", characterName, key);
                }
                #else
                AddFileToDownloadsTable(key);
                #endif
            }
        }
    }
    Specials++;
}

public PrecacheCharacter(characterIndex)
{
    char file[PLATFORM_MAX_PATH], filePath[PLATFORM_MAX_PATH], bossName[64], key[8], section[16], sndFile[PLATFORM_MAX_PATH];
    
    KvRewind(BossKV[characterIndex]);
    KvGetString(BossKV[characterIndex], "filename", bossName, sizeof(bossName));
    KvGotoFirstSubKey(BossKV[characterIndex]);
    
    //v1 bosses
    while(KvGotoNextKey(BossKV[characterIndex]))
    {
        KvGetSectionName(BossKV[characterIndex], section, sizeof(section));
        if(StrEqual(section, "sound_bgm"))
        {
            for(new i=1; ; i++)
            {
                Format(key, sizeof(key), "path%d", i);
                KvGetString(BossKV[characterIndex], key, file, sizeof(file));
                if(!file[0])
                {
                    break;
                }
                
                Format(filePath, sizeof(filePath), "sound/%s", file);  //Sounds doesn't include the sound/ prefix, so add that
                if(bSkipFileChecks[characterIndex])
                {
                    if(!FileExists(filePath, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s' in section '%s'", bossName, file, section);
                    Format(sndFile, sizeof(sndFile), "#%s", file);
                    PrecacheSound(sndFile);
                }
                else
                {
                    if(FileExists(filePath, true))
                    {
                        Format(sndFile, sizeof(sndFile), "#%s", file);
                        PrecacheSound(sndFile);
                    }
                    else
                    {
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
                    }
                }
            }
        }
        else if(StrEqual(section, "mod_precache") || !StrContains(section, "sound_") || StrEqual(section, "catch_phrase"))
        {
            for(new i=1; ; i++)
            {
                IntToString(i, key, sizeof(key));
                KvGetString(BossKV[characterIndex], key, file, sizeof(file));
                if(!file[0])
                {
                    break;
                }

                if(StrEqual(section, "mod_precache"))
                {
                    if(bSkipFileChecks[characterIndex])
                    {
                        if(!FileExists(file, true))
                            LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s' in section '%s'", bossName, file, section);
                        PrecacheModel(file);
                    }
                    else
                    {
                        if(FileExists(file, true))
                        {
                            PrecacheModel(file);
                        }
                        else
                        {
                            LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
                        }
                    }
                }
                else
                {
                    Format(filePath, sizeof(filePath), "sound/%s", file);  //Sounds doesn't include the sound/ prefix, so add that
                    if(bSkipFileChecks[characterIndex])
                    {
                        if(!FileExists(filePath, true))
                            LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s' in section '%s'", bossName, file, section);
                        PrecacheSound(file);
                    }
                    else
                    {
                        if(FileExists(filePath, true))
                        {
                            PrecacheSound(file);
                        }
                        else
                        {
                            LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
                        }
                    }
                }
            }
        }
    }
    
    //v2 bosses
    if(KvJumpToKey(BossKV[characterIndex], "sounds"))
    {
        while(KvGotoNextKey(BossKV[characterIndex]))
        {
            if(KvGetNum(BossKV[characterIndex], "precache") || KvGetNum(BossKV[characterIndex], "time"))
            {
                KvGetSectionName(BossKV[characterIndex], file, sizeof(file));
                #if defined FILECHECK_ENABLED
                Format(filePath, sizeof(filePath), "sound/%s", file);  //Sounds doesn't include the sound/ prefix, so add that
                if(bSkipFileChecks[characterIndex])
                {
                    if(!FileExists(filePath, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s' in section '%s'", bossName, file, section);
                    PrecacheSound(file);
                }
                else
                {
                    if(FileExists(filePath, true))
                    {
                        PrecacheSound(file);
                    }
                    else
                    {
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
                    }
                }
                #else
                PrecacheSound(file);
                #endif
            }
        }
    }

    if(KvJumpToKey(BossKV[characterIndex], "downloads"))
    {
        while(KvGotoNextKey(BossKV[characterIndex]))
        {
            if(KvGetNum(BossKV[characterIndex], "precache"))
            {
                KvGetSectionName(BossKV[characterIndex], file, sizeof(file));
                
                #if defined FILECHECK_ENABLED
                if(bSkipFileChecks[characterIndex])
                {
                    if(!FileExists(file, true))
                        LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for '%s' in section '%s'", bossName, file, section);
                    PrecacheModel(file);
                }
                else
                {
                    if(FileExists(file, true))
                    {
                        PrecacheModel(file);
                    }
                    else
                    {
                        LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
                    }
                }
                #else
                PrecacheModel(file);
                #endif
            }
        }
    }
}

public bool:PickCharacter(boss, companion)
{
    if(boss==companion)
    {
        characterIdx[boss]=Incoming[boss];
        Incoming[boss]=-1;
        if(characterIdx[boss]!=-1)  //We've already picked a boss through Command_SetNextBoss
        {
            new Action:action;
            Call_StartForward(OnSpecialSelected);
            Call_PushCell(boss);
            new characterIndex=characterIdx[boss];
            Call_PushCellRef(characterIndex);
            decl String:newName[64];
            KvRewind(BossKV[characterIdx[boss]]);
            KvGetString(BossKV[characterIdx[boss]], "name", newName, sizeof(newName));
            Call_PushStringEx(newName, sizeof(newName), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
            Call_PushCell(true);  //Preset
            Call_Finish(action);
            if(action==Plugin_Changed)
            {
                if(newName[0])
                {
                    decl String:characterName[64];
                    new foundExactMatch=-1, foundPartialMatch=-1;
                    for(new character; BossKV[character] && character<MaxBosses; character++)
                    {
                        KvRewind(BossKV[character]);
                        KvGetString(BossKV[character], "name", characterName, sizeof(characterName));
                        if(StrEqual(newName, characterName, false))
                        {
                            foundExactMatch=character;
                            break;  //If we find an exact match there's no reason to keep looping
                        }
                        else if(StrContains(newName, characterName, false)!=-1)
                        {
                            foundPartialMatch=character;
                        }

                        //Do the same thing as above here, but look at the filename instead of the boss name
                        KvGetString(BossKV[character], "filename", characterName, sizeof(characterName));
                        if(StrEqual(newName, characterName, false))
                        {
                            foundExactMatch=character;
                            break;  //If we find an exact match there's no reason to keep looping
                        }
                        else if(StrContains(newName, characterName, false)!=-1)
                        {
                            foundPartialMatch=character;
                        }
                    }

                    if(foundExactMatch!=-1)
                    {
                        characterIdx[boss]=foundExactMatch;
                    }
                    else if(foundPartialMatch!=-1)
                    {
                        characterIdx[boss]=foundPartialMatch;
                    }
                    else
                    {
                        return false;
                    }
                    PrecacheCharacter(characterIdx[boss]);
                    return true;
                }
                characterIdx[boss]=characterIndex;
                PrecacheCharacter(characterIdx[boss]);
                return true;
            }
            PrecacheCharacter(characterIdx[boss]);
            return true;
        }

        for(new tries; tries<100; tries++)
        {
            if(ChancesString[0])
            {
                new characterIndex=chancesIndex;  //Don't touch chancesIndex since it doesn't get reset
                new i=GetRandomInt(0, chances[characterIndex-1]);
                while(characterIndex>=2 && i<chances[characterIndex-1])
                {
                    characterIdx[boss]=chances[characterIndex-2]-1;
                    characterIndex-=2;
                }
            }
            else
            {
                characterIdx[boss]=GetRandomInt(0, Specials-1);
            }

            KvRewind(BossKV[characterIdx[boss]]);
            if(KvGetNum(BossKV[characterIdx[boss]], "blocked"))
            {
                characterIdx[boss]=-1;
                continue;
            }
            break;
        }
    }
    else
    {
        decl String:bossName[64], String:companionName[64];
        KvRewind(BossKV[characterIdx[boss]]);
        KvGetString(BossKV[characterIdx[boss]], "companion", companionName, sizeof(companionName), "=Failed companion name=");

        new character;
        while(character<Specials)  //Loop through all the bosses to find the companion we're looking for
        {
            KvRewind(BossKV[character]);
            KvGetString(BossKV[character], "name", bossName, sizeof(bossName), "=Failed name=");
            if(StrEqual(bossName, companionName, false))
            {
                characterIdx[companion]=character;
                break;
            }

            KvGetString(BossKV[character], "filename", bossName, sizeof(bossName), "=Failed name=");
            if(StrEqual(bossName, companionName, false))
            {
                characterIdx[companion]=character;
                break;
            }
            character++;
        }

        if(character==Specials)  //Companion not found
        {
            return false;
        }
    }

    new Action:action;
    Call_StartForward(OnSpecialSelected);
    Call_PushCell(companion);
    new characterIndex=characterIdx[companion];
    Call_PushCellRef(characterIndex);
    decl String:newName[64];
    KvRewind(BossKV[characterIdx[companion]]);
    KvGetString(BossKV[characterIdx[companion]], "name", newName, sizeof(newName));
    Call_PushStringEx(newName, sizeof(newName), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_PushCell(false);  //Not preset
    Call_Finish(action);
    if(action==Plugin_Changed)
    {
        if(newName[0])
        {
            decl String:characterName[64];
            new foundExactMatch=-1, foundPartialMatch=-1;
            for(new character; BossKV[character] && character<MaxBosses; character++)
            {
                KvRewind(BossKV[character]);
                KvGetString(BossKV[character], "name", characterName, sizeof(characterName));
                if(StrEqual(newName, characterName, false))
                {
                    foundExactMatch=character;
                    break;  //If we find an exact match there's no reason to keep looping
                }
                else if(StrContains(newName, characterName, false)!=-1)
                {
                    foundPartialMatch=character;
                }

                //Do the same thing as above here, but look at the filename instead of the boss name
                KvGetString(BossKV[character], "filename", characterName, sizeof(characterName));
                if(StrEqual(newName, characterName, false))
                {
                    foundExactMatch=character;
                    break;  //If we find an exact match there's no reason to keep looping
                }
                else if(StrContains(newName, characterName, false)!=-1)
                {
                    foundPartialMatch=character;
                }
            }

            if(foundExactMatch!=-1)
            {
                characterIdx[companion]=foundExactMatch;
            }
            else if(foundPartialMatch!=-1)
            {
                characterIdx[companion]=foundPartialMatch;
            }
            else
            {
                return false;
            }
            PrecacheCharacter(characterIdx[companion]);
            return true;
        }
        characterIdx[companion]=characterIndex;
        PrecacheCharacter(characterIdx[companion]);
        return true;
    }
    PrecacheCharacter(characterIdx[companion]);
    return true;
}

FindCompanion(boss, players, bool:omit[])
{
    static playersNeeded=3;
    new String:companionName[64];
    KvRewind(BossKV[characterIdx[boss]]);
    KvGetString(BossKV[characterIdx[boss]], "companion", companionName, sizeof(companionName));
    if(strlen(companionName))  // Count companions
    {
        TotalCompanions++;
        if(playersNeeded<players) //Only continue if we have enough players and if the boss has a companion
        {
            Companions++;
            new companion=GetRandomValidClient(omit);
            Boss[companion]=companion;  //Woo boss indexes!
            omit[companion]=true;
        
            if(PickCharacter(boss, companion))  //TODO: This is a bit misleading
            {
                playersNeeded++;
                Companions++;
                TotalCompanions++;
                FindCompanion(companion, players, omit);  //Make sure this companion doesn't have a companion of their own
            }
            else  //Can't find the companion's character, so just play without the companion
            {
                LogToFile(bLog, "[FF2 Bosses] Could not find boss %s!", companionName);
                Boss[companion]=0;
                omit[companion]=false;
            }
        }
    }
    playersNeeded=3;  //Reset the amount of players needed back to 3 after we're done
}

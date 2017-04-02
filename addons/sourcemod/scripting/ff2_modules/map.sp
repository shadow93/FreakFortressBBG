stock bool:IsFF2Map()
{
    new String:config[PLATFORM_MAX_PATH];
    GetCurrentMap(currentmap, sizeof(currentmap));
    if(FileExists("bNextMapToFF2"))
    {
        return true;
    }
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, MapCFG);
    if(!FileExists(config))
    {
        BuildPath(Path_SM, config, sizeof(config), "%s/%s", ConfigPath, MapCFG);
        if(FileExists(config))
            LogToFile(eLog,"[FF2] Please move '%s' from '%s' to '%s'! Disabling Plugin!", MapCFG, ConfigPath, DataPath);
        else
            LogToFile(eLog,"[FF2] Unable to find %s, disabling plugin.", config);
        return false;
    }

    new Handle:file=OpenFile(config, "r");
    if(file==INVALID_HANDLE)
    {
        LogToFile(eLog,"[FF2] Error reading maps from %s, disabling plugin.", config);
        return false;
    }

    new tries;
    while(ReadFileLine(file, config, sizeof(config)) && tries<100)
    {
        tries++;
        if(tries==100)
        {
            LogToFile(eLog,"[FF2] Breaking infinite loop when trying to check the map.");
            return false;
        }

        Format(config, strlen(config)-1, config);
        if(!strncmp(config, "//", 2, false))
        {
            continue;
        }

        if(!StrContains(currentmap, config, false) || !StrContains(config, "all", false))
        {
            CloseHandle(file);
            return true;
        }
    }
    CloseHandle(file);
    return false;
}

stock bool MapHasMusic(bool forceRecalc=false)  //SAAAAAARGE
{
    static bool hasMusic;
    static bool found;
    if(forceRecalc)
    {
        found=false;
        hasMusic=false;
    }

    if(!found)
    {
        int entity=-1;
        char name[64];
        while((entity=FindEntityByClassname2(entity, "info_target"))!=-1)
        {
            GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
            if(!strcmp(name, "hale_no_music", false) || !StrContains(chkcurrentmap, "vsh_megaman") || DeadRunMode)
            {
                hasMusic=true;
            }
        }
        found=true;
    }
    return hasMusic;
}

stock bool CheckToChangeMapDoors()
{
    if(!Enabled || !Enabled2)
    {
        return;
    }

    char config[PLATFORM_MAX_PATH];
    checkDoors=false;
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, DoorCFG);
    if(!FileExists(config))
    {
        BuildPath(Path_SM, config, sizeof(config), "%s/%s", ConfigPath, DoorCFG);
        if(FileExists(config))
            LogToFile(eLog,"[FF2] Please move '%s' from '%s' to '%s'!", DoorCFG, ConfigPath, DataPath);
        if(!strncmp(currentmap, "vsh_lolcano_pb1", 15, false))
        {
            checkDoors=true;
        }
        return;
    }

    Handle file=OpenFile(config, "r");
    if(file==null)
    {
        if(!strncmp(currentmap, "vsh_lolcano_pb1", 15, false))
        {
            checkDoors=true;
        }
        return;
    }
    while(!IsEndOfFile(file) && ReadFileLine(file, config, sizeof(config)))
    {
        Format(config, strlen(config)-1, config);
        if(!strncmp(config, "//", 2, false))
        {
            continue;
        }

        if(StrContains(currentmap, config, false)>=0 || !StrContains(config, "all", false))
        {
            delete file;
            checkDoors=true;
            return;
        }
    }
    delete file;
}

SearchForItemPacks()
{
    new bool:foundAmmo = false, bool:foundHealth = false;
    new ent = -1;
    decl Float:pos[3];
    while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);

        if (Enabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            new ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", 0, 4);
            foundAmmo = true;
        }
        
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);

        if (Enabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            new ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", 0, 4);
        }
        
        foundAmmo = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "Item_ammopack_small")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundAmmo = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
    }
    ent = -1;
    while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
    {
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
    }
    if (!foundAmmo) SpawnRandomAmmo();
    if (!foundHealth) SpawnRandomHealth();
}

SpawnRandomAmmo()
{
    new iEnt = MaxClients + 1;
    decl Float:vPos[3];
    decl Float:vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
        {
            continue;
        }

        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

        new iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_ammopack_medium") : CreateEntityByName("item_ammopack_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
    }
}

SpawnRandomHealth()
{
    new iEnt = MaxClients + 1;
    decl Float:vPos[3];
    decl Float:vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
        {
            continue;
        }

        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

        new iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_healthkit_medium") : CreateEntityByName("item_healthkit_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
    }
}

stock SwitchEntityTeams(String:entityname[], bossteam=3, mercteam=2, restore=false)
{
    new ent=-1;
    while((ent=FindEntityByClassname2(ent, entityname))!=-1)
    {
        if(restore)
        {
            if(_:GetEntityTeamNum(ent)!=oldTeam[ent])
            {
                SetEntityTeamNum(ent, oldTeam[ent]);        
            }
        }
        else
        {
            if(_:GetEntityTeamNum(ent)==oldTeam[ent])
            {
            
                SetEntityTeamNum(ent, _:GetEntityTeamNum(ent)==mercteam ? bossteam : mercteam);
            }
        }
    }
}

stock SaveOriginalEntityTeam(String:entityname[])
{
    new ent=-1;
    while((ent=FindEntityByClassname2(ent, entityname))!=-1)
    {
        oldTeam[ent]=_:GetEntityTeamNum(ent);
    }
}

public SwitchTeams(bossteam, mercteam, bool:respawn)
{
    if(BossTeam!=bossteam && MercTeam!=mercteam)
    {
        SetTeamScore(bossteam, GetTeamScore(bossteam));
        SetTeamScore(mercteam, GetTeamScore(mercteam));
        MercTeam=mercteam;
        BossTeam=bossteam;
    
        if(Maptype(chkcurrentmap)==Maptype_VSH || Maptype(chkcurrentmap)==MapType_PropHunt || Maptype(chkcurrentmap)==Maptype_Deathrun)
        {
            if(bossteam==_:TFTeam_Red && mercteam==_:TFTeam_Blue)
            {
            
                SwitchEntityTeams("info_player_teamspawn", _:TFTeam_Red, _:TFTeam_Blue);
                SwitchEntityTeams("obj_sentrygun", _:TFTeam_Red, _:TFTeam_Blue);
                SwitchEntityTeams("obj_dispenser", _:TFTeam_Red, _:TFTeam_Blue);
                SwitchEntityTeams("obj_teleporter", _:TFTeam_Red, _:TFTeam_Blue);
                SwitchEntityTeams("filter_activator_tfteam", _:TFTeam_Red, _:TFTeam_Blue);
    
                if(respawn)
                {
                    for(new client=1;client<=MaxClients;client++)
                    {
                        if(!IsValidClient(client) || TF2_GetClientTeam(client)<=TFTeam_Spectator || TF2_GetPlayerClass(client)==TFClass_Unknown)
                            continue;
                        TF2_RespawnPlayer(client);
                    }
                }
            }
            else
            {
                SwitchEntityTeams("info_player_teamspawn", _, _, true);
                SwitchEntityTeams("obj_sentrygun", _, _, true);
                SwitchEntityTeams("obj_dispenser", _, _, true);
                SwitchEntityTeams("obj_teleporter", _, _, true);
                SwitchEntityTeams("filter_activator_tfteam", _, _, true);
            }
        }
    }
}
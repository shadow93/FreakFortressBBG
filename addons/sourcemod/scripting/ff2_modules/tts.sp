// spawn teleport

void CheckToTeleportToSpawn()
{
    if(!IsMapTTSBlackListed())
    {
        char config[PLATFORM_MAX_PATH];
        GetCurrentMap(currentmap, sizeof(currentmap));
        bSpawnTeleOnTriggerHurt = false;
        BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, SpawnTeleportCFG);

        if(!FileExists(config))
        {
            BuildPath(Path_SM, config, sizeof(config), "%s/%s", ConfigPath, SpawnTeleportCFG);
            if(FileExists(config))
                LogToFile(eLog,"[FF2] Please move '%s' from '%s' to '%s'!", SpawnTeleportCFG, ConfigPath, DataPath);
            else
                LogToFile(eLog,"[FF2] Unable to find '%s', will not activate teleport to spawn.", config);
            return;
        }

        Handle fileh=OpenFile(config, "r");
        if(fileh==null)
        {
            return;
        }
        while(!IsEndOfFile(fileh) && ReadFileLine(fileh, config, sizeof(config)))
        {
            Format(config, strlen(config) - 1, config);
            if(!strncmp(config, "//", 2, false))
            {
            continue;
            }

            if(StrContains(currentmap, config, false)>=0 || !StrContains(config, "all", false))
            {
                LogMessage("[FF2] enabling teleport to spawn for %s", currentmap);
                bSpawnTeleOnTriggerHurt = true;
                delete fileh;
                return;
            }
        }
        delete fileh;    
    }
}

stock bool IsMapTTSBlackListed()
{
    char config[PLATFORM_MAX_PATH];
    GetCurrentMap(currentmap, sizeof(currentmap));
    bSpawnTeleOnTriggerHurt = false;
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, SpawnTeleportBlacklistCFG);
    if(!FileExists(config))
    {
        LogToFile(eLog,"[FF2] Unable to find %s, will not use map blacklist.", config);
        return false;
    }
    
    Handle fileh=OpenFile(config, "r");
    if(fileh==null)
    {
        return false;
    }
    while(!IsEndOfFile(fileh) && ReadFileLine(fileh, config, sizeof(config)))
    {
        Format(config, strlen(config) - 1, config);
        if(!strncmp(config, "//", 2, false))
        {
            continue;
        }
        if(StrContains(currentmap, config, false)>=0 || !StrContains(config, "all", false))
        {
            LogMessage("[FF2] %s is blacklisted and will be teleported to the nearest control point instead!", currentmap);
            MapBlackListed=true;
            bSpawnTeleOnTriggerHurt = true;
            delete fileh;
            return true;
        }
        else
        {
            MapBlackListed=false;
        }
    }
    delete fileh;
    
    return MapBlackListed;
}

/*
    TeleportToMultiMapSpawn()

    [X][2]
       [0] = RED spawnpoint entref
       [1] = BLU spawnpoint entref
*/
static ArrayList s_hSpawnArray = null;

stock void OnPluginStart_TeleportToMultiMapSpawn()
{
    s_hSpawnArray = new ArrayList(2);
}

stock void teamplay_round_start_TeleportToMultiMapSpawn()
{
    s_hSpawnArray.Clear();
    int iInt = 0, iSkip[TF_MAX_PLAYERS] = {0,...}, iEnt = MaxClients + 1;
    while((iEnt = FindEntityByClassname2(iEnt, (!MapBlackListed) ? "info_player_teamspawn" : "team_control_point")) != -1)
    {
        TFTeam iTeam = GetEntityTeamNum(iEnt);
        int iClient = GetClosestPlayerTo(iEnt, iTeam);
        if (iClient)
        {
            bool bSkip = false;
            for (int i = 0; i < TF_MAX_PLAYERS; i++)
            {
                if (iSkip[i] == iClient)
                {
                    bSkip = true;
                    break;
                }
            }
            if (bSkip)
                continue;
            iSkip[iInt++] = iClient;
            int iIndex = s_hSpawnArray.Push(EntIndexToEntRef(iEnt));
            s_hSpawnArray.Set(iIndex, iTeam, 1);       // Opposite team becomes an invalid ent
        }
    }
}

/*
    Teleports a client to spawn, but only if it's a spawn that someone spawned in at the start of the round.

    Useful for multi-stage maps like vsh_megaman
*/
stock int TeleportToMultiMapSpawn(int iClient, TFTeam iTeam = TFTeam_Unassigned)
{
    int iSpawn, iIndex;
    TFTeam iTeleTeam;
    if (iTeam <= TFTeam_Spectator)
        iSpawn = EntRefToEntIndex(GetRandBlockCellEx(s_hSpawnArray));
    else
    {
        do
            iTeleTeam = view_as<TFTeam>(GetRandBlockCell(s_hSpawnArray, iIndex, 1));
        while (iTeleTeam != iTeam);
        iSpawn = EntRefToEntIndex(GetArrayCell(s_hSpawnArray, iIndex, 0));
    }
    TeleMeToYou(iClient, iSpawn);
    return iSpawn;
}

/*
    Returns 0 if no client was found.
*/
stock int GetClosestPlayerTo(int iEnt, TFTeam iTeam = TFTeam_Unassigned)
{
    int iBest;
    float flDist, flTemp, vLoc[3], vPos[3];
    GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vLoc);
    for(int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (IsValidClient(iClient))
        {
            if (iTeam > TFTeam_Unassigned && GetEntityTeamNum(iClient) != iTeam)
                continue;
            GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", vPos);
            flTemp = GetVectorDistance(vLoc, vPos);
            if (!iBest || flTemp < flDist)
            {
                flDist = flTemp;
                iBest = iClient;
            }
        }
    }
    return iBest;
}

/*
    Teleports one entity to another.
    Doesn't necessarily have to be players.

    Returns true if a player teleported to a ducking player
*/
stock bool TeleMeToYou(int iMe, int iYou, bool bAngles = false)
{
    float vPos[3], vAng[3];
    vAng = NULL_VECTOR;
    GetEntPropVector(iYou, Prop_Send, "m_vecOrigin", vPos);
    if (bAngles)
        GetEntPropVector(iYou, Prop_Send, "m_angRotation", vAng);
    bool bDucked = false;
    if (IsValidClient(iMe) && IsValidClient(iYou) && GetEntProp(iYou, Prop_Send, "m_bDucked"))
    {
        float vCollisionVec[3];
        vCollisionVec[0] = 24.0;
        vCollisionVec[1] = 24.0;
        vCollisionVec[2] = 62.0;
        SetEntPropVector(iMe, Prop_Send, "m_vecMaxs", vCollisionVec);
        SetEntProp(iMe, Prop_Send, "m_bDucked", 1);
        SetEntityFlags(iMe, GetEntityFlags(iMe) | FL_DUCKING);
        bDucked = true;
    }
    TeleportEntity(iMe, vPos, vAng, NULL_VECTOR);
    return bDucked;
}

stock int GetRandBlockCell(ArrayList hArray, int &iSaveIndex, int iBlock = 0, bool bAsChar = false, int iDefault = 0)
{
    int iSize = hArray.Length;
    if (iSize > 0)
    {
        iSaveIndex = GetRandomInt(0, iSize - 1);
        return hArray.Get(iSaveIndex, iBlock, bAsChar);
    }
    iSaveIndex = -1;
    return iDefault;
}

// Get a random value while ignoring the save index.
stock int GetRandBlockCellEx(ArrayList hArray, int iBlock = 0, bool bAsChar = false, int iDefault = 0)
{
    int iIndex;
    return GetRandBlockCell(hArray, iIndex, iBlock, bAsChar, iDefault);
}

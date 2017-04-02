public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    decl String:plugin[PLATFORM_MAX_PATH];
    GetPluginFilename(myself, plugin, sizeof(plugin));
    if(!StrContains(plugin, "freaks/"))  //Prevent plugins/freaks/freak_fortress_2.ff2 from loading if it exists -.-
    {
        strcopy(error, err_max, "There is a duplicate copy of freak_fortress_2 running in the freaks folder! Please remove it");
        return APLRes_Failure;
    }

    CreateNative("FF2_IsFF2Enabled", Native_IsFF2Enabled);
    CreateNative("FF2_GetFF2Version", Native_GetFF2Version);
    CreateNative("FF2_GetBossUserId", Native_GetBossUserId);    
    CreateNative("FF2_GetBossIndex", Native_GetBossIndex);
    CreateNative("FF2_GetBossTeam", Native_GetBossTeam);
    CreateNative("FF2_GetBossTeam2", Native_GetBossTeam);                   // v2 native
    CreateNative("FF2_GetBossSpecial", Native_GetBossSpecial);
    CreateNative("FF2_SetBossSpecial", Native_SetBossSpecial);
    CreateNative("FF2_GetSpecialKV", Native_GetSpecialKV);
    CreateNative("FF2_GetRoundState", Native_GetRoundState);
    CreateNative("FF2_GetBossHealth", Native_GetBossHealth);
    CreateNative("FF2_SetBossHealth", Native_SetBossHealth);
    CreateNative("FF2_GetBossMaxHealth", Native_GetBossMaxHealth);
    CreateNative("FF2_SetBossMaxHealth", Native_SetBossMaxHealth);
    CreateNative("FF2_GetBossLives", Native_GetBossLives);
    CreateNative("FF2_SetBossLives", Native_SetBossLives);
    CreateNative("FF2_GetBossMaxLives", Native_GetBossMaxLives);
    CreateNative("FF2_SetBossMaxLives", Native_SetBossMaxLives);
    CreateNative("FF2_GetBossCharge", Native_GetBossCharge);    
    CreateNative("FF2_SetBossCharge", Native_SetBossCharge);    
    CreateNative("FF2_GetBossRageDamage", Native_GetBossRageDamage);
    CreateNative("FF2_SetBossRageDamage", Native_SetBossRageDamage);
    CreateNative("FF2_GetRageDist", Native_GetBossRageDistance);            // v1 native
    CreateNative("FF2_GetBossRageDistance", Native_GetBossRageDistance);    // v2 native
    CreateNative("FF2_GetClientDamage", Native_GetClientDamage);
    CreateNative("FF2_SetClientDamage", Native_SetClientDamage);
    CreateNative("FF2_GetFF2flags", Native_GetFF2Flags);        // v1 native
    CreateNative("FF2_GetFF2Flags", Native_GetFF2Flags);        // v2 native
    CreateNative("FF2_SetFF2flags", Native_SetFF2Flags);          // v1 native
    CreateNative("FF2_SetFF2Flags", Native_SetFF2Flags);        // v2 native
    CreateNative("FF2_GetQueuePoints", Native_GetQueuePoints);
    CreateNative("FF2_SetQueuePoints", Native_SetQueuePoints);
    CreateNative("FF2_StartMusic", Native_StartMusic);
    CreateNative("FF2_StopMusic", Native_StopMusic);
    CreateNative("FF2_RandomSound", Native_RandomSound);
    CreateNative("FF2_FindSound", Native_FindSound);
    CreateNative("FF2_GetClientGlow", Native_GetClientGlow);
    CreateNative("FF2_EnableClientGlow", Native_SetClientGlow);
    CreateNative("FF2_Debug", Native_Debug);
    CreateNative("FF2_GetAlivePlayers", Native_GetAlivePlayers);  // v1 native
    CreateNative("FF2_GetBossPlayers", Native_GetBossPlayers);    // v1 native
    CreateNative("FF2_HasAbility", Native_HasAbility);
    CreateNative("FF2_HasAbility2", Native_HasAbility2);
    CreateNative("FF2_DoAbility", Native_DoAbility);            //v1 native
    CreateNative("FF2_UseAbility", Native_UseAbility);            //v2 native
    CreateNative("FF2_GetAbilityArgument", Native_GetAbilityArgument);        //v1 native
    CreateNative("FF2_GetAbilityArgument2", Native_GetAbilityArgument2);    //v2 native
    CreateNative("FF2_GetAbilityArgumentFloat", Native_GetAbilityArgumentFloat);        //v1 native
    CreateNative("FF2_GetAbilityArgumentFloat2", Native_GetAbilityArgumentFloat2);        //v2 native
    CreateNative("FF2_GetAbilityArgumentString", Native_GetAbilityArgumentString);        //v1 native
    CreateNative("FF2_GetAbilityArgumentString2", Native_GetAbilityArgumentString2);    //v2 native
    CreateNative("FF2_GetClientDifficultyLevel", Native_GetDifficulty);
    CreateNative("FF2_SetClientDifficultyLevel", Native_SetDifficulty);
    
    //v1 forwards
    OnAbility=CreateGlobalForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);  //Boss, plugin name, ability name, status
    PreAbility=CreateGlobalForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled
    //v2 forwards
    OnAbility2=CreateGlobalForward("FF2_OnUseAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_Cell);  //Boss, plugin name, ability name, slot, status
    //PreAbility2=CreateGlobalForward("FF2_PreUseAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled
    
    //Forwards shared by both versions
    OnMusic=CreateGlobalForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef, Param_String, Param_String);
    OnTriggerHurt=CreateGlobalForward("FF2_OnTriggerHurt", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
    OnSpecialSelected=CreateGlobalForward("FF2_OnSpecialSelected", ET_Hook, Param_Cell, Param_CellByRef, Param_String, Param_Cell);  //Boss, character index, character name, preset
    OnAddQueuePoints=CreateGlobalForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
    OnLoadCharacterSet=CreateGlobalForward("FF2_OnLoadCharacterSet", ET_Hook, Param_CellByRef, Param_String);
    OnLoseLife=CreateGlobalForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);  //Boss, lives left, max lives
    OnAlivePlayersChanged=CreateGlobalForward("FF2_OnAlivePlayersChanged", ET_Hook, Param_Cell, Param_Cell);  //Players, bosses
    OnParseUnknownVariable=CreateGlobalForward("FF2_OnParseUnknownVariable", ET_Hook, Param_String, Param_FloatByRef);  //Variable, value
    
    RegPluginLibrary("freak_fortress_2");

    AskPluginLoad_VSH();
    #if defined _steamtools_included
    MarkNativeAsOptional("Steam_SetGameDescription");
    #endif

    #if defined _tf2attributes_included
    MarkNativeAsOptional("TF2Attrib_SetByDefIndex");
    MarkNativeAsOptional("TF2Attrib_RemoveByDefIndex");
    #endif
    return APLRes_Success;
}

/**************
 * FF2 Natives*
 **************/
public Action:Timer_UseBossCharge(Handle:timer, Handle:data)
{
    BossCharge[ReadPackCell(data)][ReadPackCell(data)]=ReadPackFloat(data);
    return Plugin_Continue;
}

//Natives aren't inlined because of https://github.com/50DKP/FF2-Official/issues/263

public Native_GetRoundState(Handle:plugin, numParams)
{
    return _:CheckRoundState();
}

public FF2RoundState:CheckRoundState()
{
    switch(GameRules_GetRoundState())
    {
        case RoundState_Init, RoundState_Pregame:
        {
            return FF2RoundState_Loading;
        }
        case RoundState_StartGame, RoundState_Preround:
        {
            return FF2RoundState_Setup;
        }
        case RoundState_RoundRunning, RoundState_Stalemate:  //Oh Valve.
        {
            return FF2RoundState_RoundRunning;
        }
        default:
        {
            return FF2RoundState_RoundEnd;
        }
    }
    return FF2RoundState_Loading;  //Compiler bug-doesn't recognize 'default' as a valid catch-all
}

public bool IsFF2Enabled()
{
    return Enabled;
}

public Native_IsFF2Enabled(Handle:plugin, numParams)
{
    return IsFF2Enabled();
}

public bool GetFF2Version()
{
    new version[3];  //Blame the compiler for this mess -.-
    version[0]=StringToInt(MAJOR_REVISION);
    version[1]=StringToInt(MINOR_REVISION);
    version[2]=StringToInt(STABLE_REVISION);
    SetNativeArray(1, version, sizeof(version));
    #if !defined DEV_REVISION
        return false;
    #else
        return true;
    #endif
}

public Native_GetFF2Version(Handle:plugin, numParams)
{
    return GetFF2Version();
}

public int GetBossUserId(boss)
{
    if(boss>=0 && boss<=MaxClients && IsValidClient(Boss[boss]))
    {
        return GetClientUserId(Boss[boss]);
    }
    return -1;
}

public Native_GetBossUserId(Handle:plugin, numParams)
{
    return GetBossUserId(GetNativeCell(1));
}

public GetBossIndex(client)
{
    if(client>0 && client<=MaxClients)
    {
        for(new boss; boss<=MaxClients; boss++)
        {
            if(Boss[boss]==client)
            {
                return boss;
            }
        }
    }
    return -1;
}

public Native_GetBossIndex(Handle:plugin, numParams)
{
    return GetBossIndex(GetNativeCell(1));
}

public FF2Difficulty:GetClientDifficultyLevel(client)
{
    return FF2ClientDifficulty[client];
}

public Native_GetDifficulty(Handle:plugin, numParams)
{
    return _:GetClientDifficultyLevel(GetNativeCell(1));
}

public SetClientDifficultyLevel(client, FF2Difficulty:difficulty, bool:persistent)
{
    FF2ClientDifficulty[client]=difficulty;
    if(persistent)
    {
        decl String:sEnabled[5];
        IntToString(_:difficulty, sEnabled, sizeof(sEnabled));
        SetClientCookie(client, FF2Cookie[Cookie_Difficulty], sEnabled);    
    }
}

public Native_SetDifficulty(Handle:plugin, numParams)
{
    SetClientDifficultyLevel(GetNativeCell(1), FF2Difficulty:GetNativeCell(2), bool:GetNativeCell(3));
}

public TFTeam:GetBossTeam()
{
    return TFTeam:BossTeam;
}

public Native_GetBossTeam(Handle:plugin, numParams)
{
    return _:GetBossTeam();
}

public bool:GetBossSpecial(boss, String:bossName[], length, clientMeaning)
{
    if(clientMeaning)  //characters.cfg
    {
        if(boss<0 || !BossKV[boss])
        {
            return false;
        }
        KvRewind(BossKV[boss]);
        KvGetString(BossKV[boss], "name", bossName, length);
    }
    else  //Special[] array
    {
        if(boss<0 || characterIdx[boss]<0 || !BossKV[characterIdx[boss]])
        {
            return false;
        }
        KvRewind(BossKV[characterIdx[boss]]);
        KvGetString(BossKV[characterIdx[boss]], "name", bossName, length);
    }
    return true;
}

public Native_GetBossSpecial(Handle:plugin, numParams)
{
    new length=GetNativeCell(3);
    decl String:bossName[length];
    new bool:bossExists=GetBossSpecial(GetNativeCell(1), bossName, length, GetNativeCell(4));
    SetNativeString(2, bossName, length);
    return bossExists;
}

public bool:SetBossSpecial(boss, String:bossName[], clientMeaning)
{
    if(clientMeaning)  //characters.cfg
    {
        if(boss<0 || !BossKV[boss])
        {
            return false;
        }
        KvRewind(BossKV[boss]);
        KvSetString(BossKV[boss], "name", bossName);
    }
    else  //Special[] array
    {
        if(boss<0 || characterIdx[boss]<0 || !BossKV[characterIdx[boss]])
        {
            return false;
        }
        KvRewind(BossKV[characterIdx[boss]]);
        KvSetString(BossKV[characterIdx[boss]], "name", bossName);
    }
    return true;
}

public Native_SetBossSpecial(Handle:plugin, numParams)
{
    decl String:bossName[512];
    GetNativeString(2, bossName, 512);
    new bool:bossExists=SetBossSpecial(GetNativeCell(1), bossName, GetNativeCell(3));
    return bossExists;
}

public Handle:GetSpecialKV(boss, bool:bossMeaning)
{
    if(bossMeaning)  //characters.cfg
    {
        if(boss!=-1 && boss<Specials)
        {
            if(BossKV[boss]!=INVALID_HANDLE)
            {
                KvRewind(BossKV[boss]);
            }
            return BossKV[boss];
        }
    }
    else  //Special[] array
    {
        if(boss!=-1 && boss<=MaxClients && characterIdx[boss]!=-1 && characterIdx[boss]<MaxBosses)
        {
            if(BossKV[characterIdx[boss]]!=INVALID_HANDLE)
            {
                KvRewind(BossKV[characterIdx[boss]]);
            }
            return BossKV[characterIdx[boss]];
        }
    }
    return INVALID_HANDLE;
}

public Native_GetSpecialKV(Handle:plugin, numParams)
{
    return _:GetSpecialKV(GetNativeCell(1), bool:GetNativeCell(2));
}

public GetBossHealth(boss)
{
    return BossHealth[boss];
}

public Native_GetBossHealth(Handle:plugin, numParams)
{
    return GetBossHealth(GetNativeCell(1));
}

public SetBossHealth(boss, health)
{
    BossHealth[boss]=health;
}

public Native_SetBossHealth(Handle:plugin, numParams)
{
    SetBossHealth(GetNativeCell(1), GetNativeCell(2));
}

public GetBossMaxHealth(boss)
{
    return BossHealthMax[boss];
}

public Native_GetBossMaxHealth(Handle:plugin, numParams)
{
    return GetBossMaxHealth(GetNativeCell(1));
}

public SetBossMaxHealth(boss, health)
{
    BossHealthMax[boss]=health;
}

public Native_SetBossMaxHealth(Handle:plugin, numParams)
{
    SetBossMaxHealth(GetNativeCell(1), GetNativeCell(2));
}

public GetBossLives(boss)
{
    return BossLives[boss];
}

public Native_GetBossLives(Handle:plugin, numParams)
{
    return GetBossLives(GetNativeCell(1));
}

public SetBossLives(boss, lives)
{
    BossLives[boss]=lives;
}

public Native_SetBossLives(Handle:plugin, numParams)
{
    SetBossLives(GetNativeCell(1), GetNativeCell(2));
}

public GetBossMaxLives(boss)
{
    return BossLivesMax[boss];
}

public Native_GetBossMaxLives(Handle:plugin, numParams)
{
    return GetBossMaxLives(GetNativeCell(1));
}

public SetBossMaxLives(boss, lives)
{
    BossLivesMax[boss]=lives;
}

public Native_SetBossMaxLives(Handle:plugin, numParams)
{
    SetBossMaxLives(GetNativeCell(1), GetNativeCell(2));
}

public Float:GetBossCharge(boss, slot)
{
    return BossCharge[boss][slot];
}

public Native_GetBossCharge(Handle:plugin, numParams)
{
    return _:GetBossCharge(GetNativeCell(1), GetNativeCell(2));
}

public SetBossCharge(boss, slot, Float:charge)  //FIXME: This duplicates logic found in Timer_UseBossCharge
{
    BossCharge[boss][slot]=charge;
}

public Native_SetBossCharge(Handle:plugin, numParams)
{
    SetBossCharge(GetNativeCell(1), GetNativeCell(2), Float:GetNativeCell(3));
}

public GetBossRageDamage(boss)
{
    return BossRageDamage[boss];
}

public Native_GetBossRageDamage(Handle:plugin, numParams)
{
    return GetBossRageDamage(GetNativeCell(1));
}

public SetBossRageDamage(boss, damage)
{
    BossRageDamage[boss]=damage;
}

public Native_SetBossRageDamage(Handle:plugin, numParams)
{
    SetBossRageDamage(GetNativeCell(1), GetNativeCell(2));
}

public Float:GetBossRageDistance(boss, const String:pluginName[], const String:abilityName[])
{
    if(!BossKV[characterIdx[boss]])  //Invalid boss
    {
        return 0.0;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(!abilityName[0])  //Return the global rage distance if there's no ability specified
    {
        return KvGetFloat(BossKV[characterIdx[boss]], "ragedist", GetConVarFloat(cvarDefaultRageDist));
    }

    decl String:ability[10];
    new Float:distance;
    for(new key=1; key<MaxAbilities; key++)
    {
        Format(ability, sizeof(ability), "ability%i", key);
        if(KvJumpToKey(BossKV[characterIdx[boss]], ability))
        {
            decl String:possibleMatch[64];  //See if the ability that we're currently in matches the specified ability
            KvGetString(BossKV[characterIdx[boss]], "name", possibleMatch, sizeof(possibleMatch));
            if(StrEqual(abilityName, possibleMatch))
            {
                if((distance=KvGetFloat(BossKV[characterIdx[boss]], "dist", -1.0))<0)  //Dist doesn't exist, return the global rage distance instead
                {
                    KvRewind(BossKV[characterIdx[boss]]);
                    distance=KvGetFloat(BossKV[characterIdx[boss]], "ragedist", GetConVarFloat(cvarDefaultRageDist));
                }
                return distance;
            }
            KvGoBack(BossKV[characterIdx[boss]]);
        }
    }
    return 0.0;
}

public Native_GetBossRageDistance(Handle:plugin, numParams)
{
    decl String:pluginName[64], String:abilityName[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    return _:GetBossRageDistance(GetNativeCell(1), pluginName, abilityName);
}

public GetClientDamage(client)
{
    return Damage[client];
}

public Native_GetClientDamage(Handle:plugin, numParams)
{
    return GetClientDamage(GetNativeCell(1));
}

public SetClientDamage(client, damage)
{
    Damage[client]=damage;
}

public Native_SetClientDamage(Handle:plugin, numParams)
{
    SetClientDamage(GetNativeCell(1), GetNativeCell(2));
}

public GetFF2Flags(client)
{
    return FF2Flags[client];
}

public Native_GetFF2Flags(Handle:plugin, numParams)
{
    return GetFF2Flags(GetNativeCell(1));
}

public SetFF2Flags(client, flags)
{
    FF2Flags[client]=flags;
}

public Native_SetFF2Flags(Handle:plugin, numParams)
{
    SetFF2Flags(GetNativeCell(1), GetNativeCell(2));
}

public Native_GetQueuePoints(Handle:plugin, numParams)
{
    return GetClientQueuePoints(GetNativeCell(1));
}

public Native_SetQueuePoints(Handle:plugin, numParams)
{
    SetClientQueuePoints(GetNativeCell(1), GetNativeCell(2));
}

public Native_StartMusic(Handle:plugin, numParams)
{
    new client=GetNativeCell(1);
    StartMusic(client);
}

public Native_StopMusic(Handle:plugin, numParams)
{
    StopMusic(GetNativeCell(1), true, nomusic);
}

public bool:ReturnRandomSound(const String:kv[], String:sound[], length, boss, slot)
{
    new bool:soundExists;
    if(StrEqual(kv, "sound_ability"))
    {
        soundExists=RandomSoundAbility(kv, sound, length, boss, slot);
    }
    else
    {
        soundExists=RandomSound(kv, sound, length, boss);
    }
    return soundExists;
}

public Native_RandomSound(Handle:plugin, numParams)
{
    decl String:kv[64];
    GetNativeString(1, kv, sizeof(kv));

    new length=GetNativeCell(3);
    decl String:sound[length];
    new bool:soundExists=ReturnRandomSound(kv, sound, length, GetNativeCell(4), GetNativeCell(5));
    SetNativeString(2, sound, length);
    return soundExists;
}

public Native_FindSound(Handle:plugin, numParams)
{
    decl String:kv[64];
    GetNativeString(1, kv, sizeof(kv));

    new length=GetNativeCell(3);
    decl String:sound[length];
    new bool:soundExists=FindSound(kv, sound, length, GetNativeCell(4), bool:GetNativeCell(5), GetNativeCell(6));
    SetNativeString(2, sound, length);
    return soundExists;
}

public Float:GetClientGlow(client)
{
    return GlowTimer[client];
}

public Native_GetClientGlow(Handle:plugin, numParams)
{
    return _:GetClientGlow(GetNativeCell(1));
}

public SetClientGlow(client, Float:time1, Float:time2)
{
    EnableClientGlow(client, time1, time2);
}

EnableClientGlow(client, Float:time1, Float:time2=-1.0)
{
    if(IsValidClient(client))
    {
        GlowTimer[client]+=time1;
        if(time2>=0)
        {
            GlowTimer[client]=time2;
        }

        if(GlowTimer[client]<=0.0)
        {
            GlowTimer[client]=0.0;
            SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
        }
        else
        {
            SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
        }
    }
}

public Native_SetClientGlow(Handle:plugin, numParams)
{
    SetClientGlow(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

public Native_Debug(Handle:plugin, numParams)
{
    return GetConVarBool(cvarDebug);
}

public GetAlivePlayers()
{
    return GetAlivePlayerCount(2);
}

public Native_GetAlivePlayers(Handle:plugin, numParams)
{
    return GetAlivePlayers();
}

public GetBossPlayers()
{
    return GetAlivePlayerCount(1)+GetAlivePlayerCount(3);
}

public Native_GetBossPlayers(Handle:plugin, numParams)
{
    return GetBossPlayers();
}

public bool:HasAbility(boss, const String:pluginName[], const String:abilityName[], version)
{
    if(boss==-1 || characterIdx[boss]==-1 || !BossKV[characterIdx[boss]])  //Invalid boss
    {
        return false;
    }
    
    if(version>1)
    {
        KvRewind(BossKV[characterIdx[boss]]);
        if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities")
        && KvJumpToKey(BossKV[characterIdx[boss]], pluginName)
        && KvJumpToKey(BossKV[characterIdx[boss]], abilityName))
        {
            return true;
        }
    }
    else
    {
        KvRewind(BossKV[characterIdx[boss]]);
        if(!BossKV[characterIdx[boss]])
        {
            LogToFile(eLog,"Failed KV: %i %i", boss, characterIdx[boss]);
            return false;
        }

        new String:ability[12];
        for(new i=1; i<MaxAbilities; i++)
        {
            Format(ability, sizeof(ability), "ability%i", i);
            if(KvJumpToKey(BossKV[characterIdx[boss]], ability))  //Does this ability number exist?
            {
                new String:abilityName2[64];
                KvGetString(BossKV[characterIdx[boss]], "name", abilityName2, sizeof(abilityName2));
                if(StrEqual(abilityName, abilityName2))  //Make sure the ability names are equal
                {
                    new String:pluginName2[64];
                    KvGetString(BossKV[characterIdx[boss]], "plugin_name", pluginName2, sizeof(pluginName2));
                    if(!pluginName[0] || !pluginName2[0] || StrEqual(pluginName, pluginName2))  //Make sure the plugin names are equal
                    {
                        return true;
                    }
                }
                KvGoBack(BossKV[characterIdx[boss]]);
            }
        }
    }
    return false;
}

public Native_HasAbility(Handle:plugin, numParams)
{
    decl String:pluginName[64], String:abilityName[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    return HasAbility(GetNativeCell(1), pluginName, abilityName, 1);
}

public Native_HasAbility2(Handle:plugin, numParams)
{
    decl String:pluginName[64], String:abilityName[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    return HasAbility(GetNativeCell(1), pluginName, abilityName, 2);
}

public Native_DoAbility(Handle:plugin, numParams)    // v1
{
    new String:plugin_name[64];
    new String:ability_name[64];
    GetNativeString(2,plugin_name,64);
    GetNativeString(3,ability_name,64);
    UseAbility(GetNativeCell(1), plugin_name, ability_name, GetNativeCell(4), GetNativeCell(5));
}

public Native_UseAbility(Handle:plugin, numParams)    // v2
{
    decl String:pluginName[64], String:abilityName[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    UseAbility2(GetNativeCell(1), pluginName, abilityName, GetNativeCell(4), GetNativeCell(5));
}

public Native_GetAbilityArgument(Handle:plugin, numParams)    // v1
{
    new String:plugin_name[64];
    new String:ability_name[64];
    GetNativeString(2,plugin_name,64);
    GetNativeString(3,ability_name,64);
    return GetAbilityArgument(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5));
}

public GetAbilityArgumentWrapper(boss, const String:pluginName[], const String:abilityName[], const String:argument[], defaultValue)
{
    return GetAbilityArgument2(boss, pluginName, abilityName, argument, defaultValue);
}

public Native_GetAbilityArgument2(Handle:plugin, numParams)    // v2
{
    decl String:pluginName[64], String:abilityName[64], String:argument[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    GetNativeString(4, argument, sizeof(argument));
    return GetAbilityArgumentWrapper(GetNativeCell(1), pluginName, abilityName, argument, GetNativeCell(5));
}

public Native_GetAbilityArgumentFloat(Handle:plugin, numParams)    // v1
{
    new String:plugin_name[64];
    new String:ability_name[64];
    GetNativeString(2,plugin_name,64);
    GetNativeString(3,ability_name,64);
    return _:GetAbilityArgumentFloat(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5));
}

public Float:GetAbilityArgumentFloatWrapper(boss, const String:pluginName[], const String:abilityName[], const String:argument[], Float:defaultValue)
{
    return GetAbilityArgumentFloat2(boss, pluginName, abilityName, argument, defaultValue);
}

public Native_GetAbilityArgumentFloat2(Handle:plugin, numParams)    //v2
{
    decl String:pluginName[64], String:abilityName[64], String:argument[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    GetNativeString(4, argument, sizeof(argument));
    return _:GetAbilityArgumentFloatWrapper(GetNativeCell(1), pluginName, abilityName, argument, Float:GetNativeCell(5));
}

public Native_GetAbilityArgumentString(Handle:plugin, numParams)    //v1
{
    new String:plugin_name[64];
    GetNativeString(2,plugin_name,64);
    new String:ability_name[64];
    GetNativeString(3,ability_name,64);
    new dstrlen=GetNativeCell(6);
    new String:s[dstrlen+1];
    GetAbilityArgumentString(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),s,dstrlen);
    SetNativeString(5,s,dstrlen);
}

public GetAbilityArgumentStringWrapper(boss, const String:pluginName[], const String:abilityName[], const String:argument[], String:abilityString[], length, const String:defaultValue[])
{
    GetAbilityArgumentString2(boss, pluginName, abilityName, argument, abilityString, length, defaultValue);
}

public Native_GetAbilityArgumentString2(Handle:plugin, numParams)    //v2
{
    decl String:pluginName[64], String:abilityName[64], String:defaultValue[64], String:argument[64];
    GetNativeString(2, pluginName, sizeof(pluginName));
    GetNativeString(3, abilityName, sizeof(abilityName));
    GetNativeString(4, argument, sizeof(argument));
    GetNativeString(7, defaultValue, sizeof(defaultValue));
    new length=GetNativeCell(6);
    decl String:abilityString[length];
    GetAbilityArgumentStringWrapper(GetNativeCell(1), pluginName, abilityName, argument, abilityString, length, defaultValue);
    SetNativeString(5, abilityString, length);
}
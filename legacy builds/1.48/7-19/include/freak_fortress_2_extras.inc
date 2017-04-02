#if defined _FF2_Extras_included
 #endinput
#endif
#define _FF2_Extras_included

// REQUIRED FOR REFLECTIVE CALL:
stock Handle:FindFF2Core()
{
    new String: buffer[256];
    new String: path[PLATFORM_MAX_PATH];
    new Handle: iter = GetPluginIterator();
    new Handle: pl = INVALID_HANDLE;

    while (MorePlugins(iter))
    {
        pl = ReadPlugin(iter);
        GetPluginFilename(pl, buffer, sizeof(buffer));
        if (!StrContains(buffer, "freak_fortress_2", false))
            break;
        else
            pl = INVALID_HANDLE;
    }

    CloseHandle(iter);

    return pl;
}

/**
 * Retrieve the countdown time left
 * @return Time left
 **/
stock FF2_GetCountdownTime()
{
    new Handle:plugin = FindFF2Core()
    if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "GetCountdownTime");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_Finish(timeleft);
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:GetCountdownTime()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:GetCountdownTime(). Make sure this plugin exists!");
    }
}

/**
 * Add or remove time to the countdown timer
 * @param newTime	Time to add or remove
 * @noreturn 
 **/
stock FF2_SetCountdownTime(newTime)
{
	new Handle:plugin = FindFF2Core();
	if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "SetCountdownTime");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_PushCell(newTime);
			Call_Finish();
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:SetCountdownTime()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:SetCountdownTime(). Make sure this plugin exists!");
    }
}

/**
 * Get the boss's move speed
 * @param boss	Boss index
 * @return 		Boss's move speed
 **/
stock FF2_GetBossMoveSpeed(boss)
{
	new Handle:plugin = FindFF2Core();
	if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "GetBossMoveSpeed");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_PushCell(boss);
			Call_Finish(BossSpeed[Special[boss]]);
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:GetBossMoveSpeed()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:GetBossMoveSpeed(). Make sure this plugin exists!");
    }
}

/**
 * Set the boss's move speed
 * @param boss	Boss index
 * @param speed New move speed
 * @noreturn
 **/
stock FF2_SetBossMoveSpeed(boss, Float:speed)
{
	new Handle:plugin = FindFF2Core();
	if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "SetBossMoveSpeed");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_PushCell(boss);
			Call_PushCell(speed);
			Call_Finish();
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:GetBossMoveSpeed()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:GetBossMoveSpeed(). Make sure this plugin exists!");
	}
}

/**
 * Get the non-boss team
 * @return 		Non-boss team number
 **/
stock FF2_GetNonBossTeam()
{
	new Handle:plugin = FindFF2Core();
	if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "GetNonBossTeam");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_Finish(MercTeam);
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:GetNonBossTeam()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:GetNonBossTeam(). Make sure this plugin exists!");
	}
}

/**
 * Switch the boss and non-boss team
 * @param bossteam 	New boss team number
 * @param mercteam  New non-boss team number
 * @param respawn	Respawn if true, don't respawn if false
 * @noreturn
 **/
stock FF2_SwitchTeams(bossteam, mercteam, bool:respawn)
{
	new Handle:plugin = FindFF2Core();
	if (plugin != INVALID_HANDLE)
    {
        new Function:func = GetFunctionByName(plugin, "SwitchTeams");
        if (func != INVALID_FUNCTION)
        {
            Call_StartFunction(plugin, func);
			Call_PushCell(bossteam);
			Call_PushCell(mercteam);
			Call_PushCell(respawn);
			Call_Finish();
        }
        else
            LogError("ERROR: Unable to initialize freak_fortress_2:SwitchTeams()");
    }
    else
    {
        LogError("ERROR: Unable to initialize freak_fortress_2:SwitchTeams(). Make sure this plugin exists!");
	}
}

/**
 * Make a weapon or wearable visible to everyone
 **/
stock PrepareItem(client, entity, const String:classname[], visibility=false)
{
	if(!visibility)
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	else
	{
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1); // Magic!
	}
	
	if (StrContains(classname, "tf_wearable")==-1)
	{
		EquipPlayerWeapon(client, entity);
	}
	else
	{
		Wearable_EquipWearable(client, entity);
	}
}

/**
 *	Make a weapon visible to everyone
 **/
stock PrepareWeapon(client, weapon, visibility=false)
{
	if(!visibility)
	{
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(weapon, Prop_Send, "m_flModelScale", 0.001);
	}
	else
	{
		SetEntProp(weapon, Prop_Send, "m_bValidatedAttachedEntity", 1); // Magic!
	}
	EquipPlayerWeapon(client, weapon);
}

new Handle:S93SF_equipWearable = INVALID_HANDLE;
stock Wearable_EquipWearable(client, wearable)
{
	if(S93SF_equipWearable==INVALID_HANDLE)
	{
		new Handle:config=LoadGameConfigFile("equipwearable");
		if(config==INVALID_HANDLE)
		{
			LogError("[FF2] EquipWearable gamedata could not be found; make sure /gamedata/equipwearable.txt exists.");
			return;
		}

		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(config, SDKConf_Virtual, "EquipWearable");
		CloseHandle(config);
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		if((S93SF_equipWearable=EndPrepSDKCall())==INVALID_HANDLE)
		{
			LogError("[FF2] Couldn't load SDK function (CTFPlayer::EquipWearable). SDK call failed.");
			return;
		}
	}
	SDKCall(S93SF_equipWearable, client, wearable);
}

stock SpawnWeapon(client, String:name[], index, level, quality, String:attribute[], visible = 1, bool:preserve = false)
{
	if(StrEqual(name,"saxxy", false)) // if "saxxy" is specified as the name, replace with appropiate name
	{ 
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Scout: ReplaceString(name, 64, "saxxy", "tf_weapon_bat", false);
			case TFClass_Soldier: ReplaceString(name, 64, "saxxy", "tf_weapon_shovel", false);
			case TFClass_Pyro: ReplaceString(name, 64, "saxxy", "tf_weapon_fireaxe", false);
			case TFClass_DemoMan: ReplaceString(name, 64, "saxxy", "tf_weapon_bottle", false);
			case TFClass_Heavy: ReplaceString(name, 64, "saxxy", "tf_weapon_fists", false);
			case TFClass_Engineer: ReplaceString(name, 64, "saxxy", "tf_weapon_wrench", false);
			case TFClass_Medic: ReplaceString(name, 64, "saxxy", "tf_weapon_bonesaw", false);
			case TFClass_Sniper: ReplaceString(name, 64, "saxxy", "tf_weapon_club", false);
			case TFClass_Spy: ReplaceString(name, 64, "saxxy", "tf_weapon_knife", false);
		}
	}
	
	if(StrEqual(name, "tf_weapon_shotgun", false)) // If using tf_weapon_shotgun for Soldier/Pyro/Heavy/Engineer
	{
		switch(TF2_GetPlayerClass(client))
		{
			case TFClass_Soldier:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_soldier", false);
			case TFClass_Pyro:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_pyro", false);
			case TFClass_Heavy:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_hwg", false);
			case TFClass_Engineer:	ReplaceString(name, 64, "tf_weapon_shotgun", "tf_weapon_shotgun_primary", false);
		}
	}

	new Handle:weapon = TF2Items_CreateItem((preserve ? PRESERVE_ATTRIBUTES : OVERRIDE_ALL) | FORCE_GENERATION);
	TF2Items_SetClassname(weapon, name);
	TF2Items_SetItemIndex(weapon, index);
	TF2Items_SetLevel(weapon, level);
	TF2Items_SetQuality(weapon, quality);
	new String:attributes[32][32];
	new count = ExplodeString(attribute, ";", attributes, 32, 32);
	if(count%2!=0)
	{
		count--;
	}
	
	if(count>0)
	{
		TF2Items_SetNumAttributes(weapon, count/2);
		new i2 = 0;
		for(new i = 0; i < count; i += 2)
		{
			new attrib = StringToInt(attributes[i]);
			if (attrib == 0)
			{
				LogError("Bad weapon attribute passed: %s ; %s", attributes[i], attributes[i+1]);
				return -1;
			}
			TF2Items_SetAttribute(weapon, i2, attrib, LibraryExists("tf2x10") ? StringToFloat(attributes[i+1])*10.0 : StringToFloat(attributes[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(weapon, 0);
	}

	if (weapon == INVALID_HANDLE)
	{
		PrintToServer("[sarysapub1] Error: Invalid weapon spawned. client=%d name=%s idx=%d attr=%s", client, name, index, attribute);
		return -1;
	}

	new entity = TF2Items_GiveNamedItem(client, weapon);
	CloseHandle(weapon);
	
	PrepareItem(client, entity, name, visible);
	
	return entity;
}
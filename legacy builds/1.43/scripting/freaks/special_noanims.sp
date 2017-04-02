/*
special_noanims:	arg0 - unused.
					arg1 - 1=Custom Model Rotates (def.0)

rage_new_weapon:	arg0 - slot (def.0)
					arg1 - weapon's classname
					arg2 - weapon's index
					arg3 - weapon's attributes
					arg4 - weapon's slot (0 - primary. 1 - secondary. 2 - melee. 3 - pda. 4 - spy's watches)
					arg5 - weapon's ammo (set to 1 for clipless weapons, then set the actual ammo using clip)
					arg6 - force switch to this weapon
					arg7 - weapon's clip
*/
#pragma semicolon 1

#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>
#tryinclude <freak_fortress_2_extras>
#define PLUGIN_VERSION "1.11"

#define NEWWEAPON_PREFIX "rage_new_weapon%d"

new String:ability_new_weapon[16];

public Plugin:myinfo=
{
	name="Freak Fortress 2: special_noanims",
	author="RainBolt Dash, Wliu",
	description="FF2: New Weapon and No Animations abilities",
	version=PLUGIN_VERSION
};

public OnPluginStart2()
{
	new version[3];
	FF2_GetFF2Version(version);
	if(version[0]==1 && (version[1]<10 || (version[1]==10 && version[2]<3)))
	{
		SetFailState("This subplugin depends on at least FF2 v1.10.3");
	}

	HookEvent("teamplay_round_start", OnRoundStart);
}

public Action:FF2_OnAbility2(client, const String:plugin_name[], const String:ability_name[], status)
{
	for (new ability_suffix=0; ability_suffix<10; ability_suffix++)
	{
		Format(ability_new_weapon, sizeof(ability_new_weapon), NEWWEAPON_PREFIX, ability_suffix);
		if(!strcmp(ability_name, "rage_new_weapon") || FF2_HasAbility(client, this_plugin_name, ability_new_weapon))
		{
			Rage_New_Weapon(client, ability_name);
		}
	}
	return Plugin_Continue;
}

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(0.41, Timer_Disable_Anims);
	CreateTimer(9.31, Timer_Disable_Anims);
	return Plugin_Continue;
}

public Action:Timer_Disable_Anims(Handle:timer)
{
	new client;
	for(new boss; (client=GetClientOfUserId(FF2_GetBossUserId(boss)))>0; boss++)
	{
		if(FF2_HasAbility(boss, this_plugin_name, "special_noanims"))
		{
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
			SetEntProp(client, Prop_Send, "m_bCustomModelRotates", FF2_GetAbilityArgument(boss, this_plugin_name, "special_noanims", 1, 0));
		}
	}
	return Plugin_Continue;
}

Rage_New_Weapon(boss, const String:ability_name[])
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}

	decl String:classname[64], String:attributes[256];
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 1, classname, sizeof(classname));
	FF2_GetAbilityArgumentString(boss, this_plugin_name, ability_name, 3, attributes, sizeof(attributes));

	new slot=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 4);
	TF2_RemoveWeaponSlot(client, slot);
	new weapon=SpawnWeapon(client, classname, FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 2), 101, 5, attributes, bool:FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 8));
	if(FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 6))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}

	new ammo=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 5, 0);
	new clip=FF2_GetAbilityArgument(boss, this_plugin_name, ability_name, 7, 0);
	if(ammo || clip)
	{
		FF2_SetAmmo(client, weapon, ammo, clip);
	}
}

#if !defined _FF2_Extras_included
stock SpawnWeapon(client, String:name[], index, level, quality, String:attribute[], visible = 1, bool:preserve = false)
{
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
			TF2Items_SetAttribute(weapon, i2, attrib, StringToFloat(attributes[i+1]));
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
	
	// sarysa addition
	if (!visible)
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	
	if (StrContains(name, "tf_wearable") != 0)
		EquipPlayerWeapon(client, entity);
	else
		Wearable_EquipWearable(client, entity);
	return entity;
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
#endif
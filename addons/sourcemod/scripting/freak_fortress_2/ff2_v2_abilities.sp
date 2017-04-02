#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <morecolors>
#include <tf2items>

#define FF2_V2
#include <freak_fortress_2_extras>
#include <freak_fortress_2>
#include <freak_fortress_2_subplugin>

#define CBS_MAX_ARROWS 9

#define SOUND_SLOW_MO_START "replay/enterperformancemode.wav"  //Used when Ninja Spy enters slow mo
#define SOUND_SLOW_MO_END "replay/exitperformancemode.wav"  //Used when Ninja Spy exits slow mo
#define SOUND_DEMOPAN_RAGE "ui/notification_alert.wav"  //Used when Demopan rages

#define PROJECTILE		"model_projectile_replace"
#define OBJECTS			"spawn_many_objects_on_kill"
#define OBJECTS_DEATH	"spawn_many_objects_on_death"

#define PLUGIN_VERSION "2.0.0"

public Plugin:myinfo=
{
	name="Freak Fortress 2: Stock Abilities",
	author="RainBolt Dash",
	description="FF2: Common abilities used by many bosses",
	version=PLUGIN_VERSION,
};

new Handle:OnSuperJump;
new Handle:OnRage;
new Handle:OnWeighdown;

new Handle:gravityDatapack[MAXPLAYERS+1];

new Handle:jumpHUD;

new bool:enableSuperDuperJump[MAXPLAYERS+1];
new Float:UberRageCount[MAXPLAYERS+1];
new TFTeam:BossTeam=TFTeam_Blue;

new Handle:cvarOldJump;
new Handle:cvarBaseJumperStun;

new bool:oldJump;
new bool:removeBaseJumperOnStun;

#define FLAG_ONSLOWMO			(1<<0)

new FF2Flags[MAXPLAYERS+1];
new CloneOwnerIndex[MAXPLAYERS+1]=-1;

new Handle:SlowMoTimer;
new oldTarget;

new Handle:cvarTimeScale;
new Handle:cvarCheats;
new Handle:cvarKAC;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	OnSuperJump=CreateGlobalForward("FF2_OnSuperJump", ET_Hook, Param_Cell, Param_CellByRef);  //Boss, super duper jump
	OnRage=CreateGlobalForward("FF2_OnRage", ET_Hook, Param_Cell, Param_FloatByRef);  //Boss, distance
	OnWeighdown=CreateGlobalForward("FF2_OnWeighdown", ET_Hook, Param_Cell);  //Boss
	return APLRes_Success;
}

public OnPluginStart2()
{
	cvarOldJump=CreateConVar("ff2_oldjump", "0", "Use old VSH jump equations", _, true, 0.0, true, 1.0);
	cvarBaseJumperStun=CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);

	HookConVarChange(cvarOldJump, CvarChange);
	HookConVarChange(cvarBaseJumperStun, CvarChange);

	jumpHUD=CreateHudSynchronizer();

	HookEvent("object_deflected", OnDeflect, EventHookMode_Pre);
	HookEvent("teamplay_round_win", OnRoundEnd);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookEvent("player_death", OnPlayerDeath);

	PrecacheSound("items/pumpkin_pickup.wav");

	cvarTimeScale=FindConVar("host_timescale");
	cvarCheats=FindConVar("sv_cheats");
	cvarKAC=FindConVar("kac_enable");

	LoadTranslations("ff2_1st_set.phrases");
	LoadTranslations("freak_fortress_2_help.phrases");
	
	PrecacheSound(SOUND_SLOW_MO_START, true);
	PrecacheSound(SOUND_SLOW_MO_END, true);
	PrecacheSound(SOUND_DEMOPAN_RAGE, true);
	
	AutoExecConfig(true, "freak_fortress_2/default_abilities");
}

public OnConfigsExecuted()
{
	oldJump=GetConVarBool(cvarOldJump);
	removeBaseJumperOnStun=GetConVarBool(cvarBaseJumperStun);
}

public CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar==cvarOldJump)
	{
		oldJump=bool:StringToInt(newValue);
	}
	else if(convar==cvarBaseJumperStun)
	{
		removeBaseJumperOnStun=bool:StringToInt(newValue);
	}
}

public Action:OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(FF2_IsFF2Enabled())
	{
		for(new client; client<MaxClients; client++)
		{
			FF2Flags[client]=0;
			CloneOwnerIndex[client]=-1;
			enableSuperDuperJump[client]=false;
			UberRageCount[client]=0.0;
		}

		CreateTimer(0.41, Timer_Disable_Anims);
		CreateTimer(9.31, Timer_Disable_Anims);
		CreateTimer(0.3, Timer_GetBossTeam, _, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(9.11, StartBossTimer, _, TIMER_FLAG_NO_MAPCHANGE);  //TODO: Investigate.
	}
	return Plugin_Continue;
}

public Action:OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(FF2_IsFF2Enabled())
	{
		for(new client; client<=MaxClients; client++)
		{
			if(client<=0 || client>MaxClients || !IsClientInGame(client))
				continue;
			if(CloneOwnerIndex[client]!=-1 && TF2_GetClientTeam(client)==BossTeam)
			{
				CloneOwnerIndex[client]=-1;
				FF2_SetFF2Flags(client, FF2_GetFF2Flags(client) & ~FF2FLAG_CLASSTIMERDISABLED);
			}
		
			if(FF2Flags[client] & FLAG_ONSLOWMO)
			{
				if(SlowMoTimer)
				{
					KillTimer(SlowMoTimer);
				}
				Timer_StopSlowMo(INVALID_HANDLE, -1);
				return Plugin_Continue;
			}
		}
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	FF2Flags[client]=0;
	if(CloneOwnerIndex[client]!=-1)
	{
		CloneOwnerIndex[client]=-1;
		FF2_SetFF2Flags(client, FF2_GetFF2Flags(client) & ~FF2FLAG_CLASSTIMERDISABLED);
	}
}

public Action:StartBossTimer(Handle:timer)  //TODO: What.
{
	for(new boss; FF2_GetBossUserId(boss)!=-1; boss++)
	{
		if(FF2_HasAbility2(boss, this_plugin_name, "charge_teleport"))
		{
			FF2_SetBossCharge(boss, FF2_GetAbilityArgument2(boss, this_plugin_name, "charge_teleport", "slot", 1), -1.0*FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, "charge_teleport", "cooldown", 5.0));
		}
	}
}

public Action:Timer_GetBossTeam(Handle:timer)
{
	if(cvarKAC && GetConVarBool(cvarKAC))
	{
		SetConVarBool(cvarKAC, false);
	}
	BossTeam=FF2_GetBossTeam2();
	return Plugin_Continue;
}

public FF2_OnAbility2(boss, const String:plugin_name[], const String:ability_name[], slot, status)
{
	if(!slot)  //Rage
	{
		if(!boss)  //Boss indexes are just so amazing
		{
			new Float:distance=FF2_GetBossRageDistance(boss, this_plugin_name, ability_name);
			new Float:newDistance=distance;

			new Action:action;
			Call_StartForward(OnRage);
			Call_PushCell(boss);
			Call_PushFloatRef(newDistance);
			Call_Finish(action);
			if(action==Plugin_Handled || action==Plugin_Stop)
			{
				return;
			}
			else if(action==Plugin_Changed)
			{
				distance=newDistance;
			}
		}
	}

	if(StrEqual(ability_name, "charge_weightdown"))
	{
		Charge_WeighDown(boss, slot);
	}
	else if(StrEqual(ability_name, "charge_bravejump"))
	{
		Charge_BraveJump(ability_name, boss, slot, status);
	}
	else if(StrEqual(ability_name, "charge_teleport"))
	{
		Charge_Teleport(ability_name, boss, slot, status);
	}
	else if(StrEqual(ability_name, "rage_uber"))
	{
		new client=GetClientOfUserId(FF2_GetBossUserId(boss));
		TF2_AddCondition(client, TFCond_Ubercharged, FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 5.0));
		SetEntProp(client, Prop_Data, "m_takedamage", 0);
		CreateTimer(FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 5.0), Timer_StopUber, boss);
	}
	else if(StrEqual(ability_name, "rage_stun"))
	{
		Rage_Stun(ability_name, boss);
	}
	else if(StrEqual(ability_name, "rage_stunsg"))
	{
		Rage_StunSentry(ability_name, boss);
	}
	else if(StrEqual(ability_name, "rage_instant_teleport"))
	{
		new client=GetClientOfUserId(FF2_GetBossUserId(boss));
		new Float:position[3];
		new bool:otherTeamIsAlive;

		for(new target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target) && target!=client && !(FF2_GetFF2Flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
			{
				otherTeamIsAlive=true;
				break;
			}
		}

		if(!otherTeamIsAlive)
		{
			return;
		}

		new target, tries;
		do
		{
			tries++;
			target=GetRandomInt(1, MaxClients);
			if(tries==100)
			{
				return;
			}
		}
		while(!IsValidEdict(target) || target==client || (FF2_GetFF2Flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM) || !IsPlayerAlive(target));

		GetEntPropVector(target, Prop_Data, "m_vecOrigin", position);
		TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
		TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
	}
	if(StrEqual(ability_name, "special_democharge"))
	{
		if(status)
		{
			new client=GetClientOfUserId(FF2_GetBossUserId(boss));
			new Float:charge=FF2_GetBossCharge(boss, 0);
			SetEntPropFloat(client, Prop_Send, "m_flChargeMeter", 100.0);
			TF2_AddCondition(client, TFCond_Charging, 0.25);
			if(charge>10.0 && charge<90.0)
			{
				FF2_SetBossCharge(boss, 0, charge-0.4);
			}
		}
	}
	else if(StrEqual(ability_name, "rage_cloneattack"))
	{
		Rage_Clone(ability_name, boss);
	}
	else if(StrEqual(ability_name, "rage_tradespam"))
	{
		CreateTimer(0.0, Timer_Demopan_Rage, 1);
	}
	else if(StrEqual(ability_name, "rage_cbs_bowrage"))
	{
		Rage_Bow(boss);
	}
	else if(StrEqual(ability_name, "rage_explosive_dance"))
	{
		SetEntityMoveType(GetClientOfUserId(FF2_GetBossUserId(boss)), MOVETYPE_NONE);
		new Handle:data;
		CreateDataTimer(0.15, Timer_Prepare_Explosion_Rage, data);
		WritePackString(data, ability_name);
		WritePackCell(data, boss);
		ResetPack(data);
	}
	else if(StrEqual(ability_name, "rage_matrix_attack"))
	{
		Rage_Slowmo(boss, ability_name);
	}
	if(StrEqual(ability_name, "rage_overlay"))
	{
		Rage_Overlay(boss, ability_name);
	}
	if(StrEqual(ability_name, "rage_new_weapon"))
	{
		Rage_New_Weapon(boss, ability_name);
	}
}

public Action:Timer_Disable_Anims(Handle:timer)
{
	new client;
	for(new boss; (client=GetClientOfUserId(FF2_GetBossUserId(boss)))>0; boss++)
	{
		if(FF2_HasAbility2(boss, this_plugin_name, "special_noanims"))
		{
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);
			SetEntProp(client, Prop_Send, "m_bCustomModelRotates", FF2_GetAbilityArgument2(boss, this_plugin_name, "special_noanims", "rotate model", 0));
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
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "classname", classname, sizeof(classname));
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "attributes", attributes, sizeof(attributes));

	new slot=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "slot");
	TF2_RemoveWeaponSlot(client, slot);

	new index=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "index");
	new weapon=SpawnWeapon(client, classname, index, 101, 5, attributes);
	if(StrEqual(classname, "tf_weapon_builder") && index!=735)  //PDA, normal sapper
	{
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
	}
	else if(StrEqual(classname, "tf_weapon_sapper") || index==735)  //Sappers, normal sapper
	{
		SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
		SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
		SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
	}

	if(FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "set as active weapon"))
	{
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	}

	new ammo=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "ammo", 0);
	new clip=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "clip", 0);
	if(ammo || clip)
	{
		FF2_SetAmmo(client, weapon, ammo, clip);
	}
}

Rage_Overlay(boss, const String:ability_name[])
{
	decl String:overlay[PLATFORM_MAX_PATH];
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "overlay", overlay, PLATFORM_MAX_PATH);
	Format(overlay, PLATFORM_MAX_PATH, "r_screenoverlay \"%s\"", overlay);
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
	for(new target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && TF2_GetClientTeam(target)!=BossTeam)
		{
			ClientCommand(target, overlay);
		}
	}

	CreateTimer(FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 6.0), Timer_Remove_Overlay);
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
}

public Action:Timer_Remove_Overlay(Handle:timer)
{
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
	for(new target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && TF2_GetClientTeam(target)!=BossTeam)
		{
			ClientCommand(target, "r_screenoverlay \"\"");
		}
	}
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}

Rage_Clone(const String:ability_name[], boss)
{
	new Handle:bossKV[8];
	decl String:bossName[32];
	new bool:changeModel=bool:FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "custom model");
	new weaponMode=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "allow weapons");
	decl String:model[PLATFORM_MAX_PATH];
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "model", model, sizeof(model));
	new class=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "class");
	new Float:ratio=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "ratio", 0.0);
	new String:classname[64]="tf_weapon_bottle";
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "classname", classname, sizeof(classname));
	new index=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "index", 191);
	new String:attributes[64]="68 ; -1";
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "attributes", attributes, sizeof(attributes));
	new ammo=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "ammo", -1);
	new clip=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "clip", -1);
	new health=FF2_GetAbilityArgument2(boss, this_plugin_name, ability_name, "health", 0);

	new Float:position[3], Float:velocity[3];
	GetEntPropVector(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Data, "m_vecOrigin", position);

	FF2_GetBossSpecial(boss, bossName, sizeof(bossName));

	new maxKV;
	for(maxKV=0; maxKV<8; maxKV++)
	{
		if(!(bossKV[maxKV]=FF2_GetSpecialKV(maxKV)))
		{
			break;
		}
	}

	new alive, dead;
	new Handle:players=CreateArray();
	for(new target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target))
		{
			new TFTeam:team=TF2_GetClientTeam(target);
			if(team>TFTeam_Spectator && team!=TFTeam_Blue)
			{
				if(IsPlayerAlive(target))
				{
					alive++;
				}
				else if(FF2_GetBossIndex(target)==-1)  //Don't let dead bosses become clones
				{
					PushArrayCell(players, target);
					dead++;
				}
			}
		}
	}

	new totalMinions=(ratio ? RoundToCeil(alive*ratio) : MaxClients);  //If ratio is 0, use MaxClients instead
	new config=GetRandomInt(0, maxKV-1);
	new clone, temp;
	for(new i=1; i<=dead && i<=totalMinions; i++)
	{
		temp=GetRandomInt(0, GetArraySize(players)-1);
		clone=GetArrayCell(players, temp);
		RemoveFromArray(players, temp);

		FF2_SetFF2Flags(clone, FF2_GetFF2Flags(clone)|FF2FLAG_ALLOWSPAWNINBOSSTEAM|FF2FLAG_CLASSTIMERDISABLED);
		TF2_ChangeClientTeam(clone, BossTeam);
		TF2_RespawnPlayer(clone);
		CloneOwnerIndex[clone]=boss;
		TF2_SetPlayerClass(clone, (class ? (TFClassType:class) : (TFClassType:KvGetNum(bossKV[config], "class", 0))), _, false);

		if(changeModel)
		{
			if(model[0]=='\0')
			{
				KvGetString(bossKV[config], "model", model, sizeof(model));
			}
			SetVariantString(model);
			AcceptEntityInput(clone, "SetCustomModel");
			SetEntProp(clone, Prop_Send, "m_bUseClassAnimations", 1);
		}

		switch(weaponMode)
		{
			case 0:
			{
				TF2_RemoveAllWeapons(clone);
			}
			case 1:
			{
				new weapon;
				TF2_RemoveAllWeapons(clone);
				if(classname[0]=='\0')
				{
					classname="tf_weapon_bottle";
				}

				if(attributes[0]=='\0')
				{
					attributes="68 ; -1";
				}

				weapon=SpawnWeapon(clone, classname, index, 101, 0, attributes);
				if(StrEqual(classname, "tf_weapon_builder") && index!=735)  //PDA, normal sapper
				{
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
				}
				else if(StrEqual(classname, "tf_weapon_sapper") || index==735)  //Sappers, normal sapper
				{
					SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
					SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
					SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
				}

				if(IsValidEdict(weapon))
				{
					SetEntPropEnt(clone, Prop_Send, "m_hActiveWeapon", weapon);
					SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", -1);
				}

				FF2_SetAmmo(clone, weapon, ammo, clip);
			}
		}

		if(health)
		{
			SetEntProp(clone, Prop_Data, "m_iMaxHealth", health);
			SetEntProp(clone, Prop_Data, "m_iHealth", health);
			SetEntProp(clone, Prop_Send, "m_iHealth", health);
		}

		velocity[0]=GetRandomFloat(300.0, 500.0)*(GetRandomInt(0, 1) ? 1:-1);
		velocity[1]=GetRandomFloat(300.0, 500.0)*(GetRandomInt(0, 1) ? 1:-1);
		velocity[2]=GetRandomFloat(300.0, 500.0);
		TeleportEntity(clone, position, NULL_VECTOR, velocity);

		PrintHintText(clone, "%t", "Seeldier Rage Message", bossName);

		SetEntProp(clone, Prop_Data, "m_takedamage", 0);
		SDKHook(clone, SDKHook_OnTakeDamage, SaveMinion);
		CreateTimer(4.0, Timer_Enable_Damage, GetClientUserId(clone));

		new Handle:data;
		CreateDataTimer(0.1, Timer_EquipModel, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(data, GetClientUserId(clone));
		WritePackString(data, model);
	}
	CloseHandle(players);

	new entity, owner;
	while((entity=FindEntityByClassname(entity, "tf_wearable"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && TF2_GetClientTeam(owner)==BossTeam)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}

	while((entity=FindEntityByClassname(entity, "tf_wearable_demoshield"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && TF2_GetClientTeam(owner)==BossTeam)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}

	while((entity=FindEntityByClassname(entity, "tf_powerup_bottle"))!=-1)
	{
		if((owner=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"))<=MaxClients && owner>0 && TF2_GetClientTeam(owner)==BossTeam)
		{
			TF2_RemoveWearable(owner, entity);
		}
	}
}

public Action:Timer_EquipModel(Handle:timer, any:pack)
{
	ResetPack(pack);
	new client=GetClientOfUserId(ReadPackCell(pack));
	if(client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		decl String:model[PLATFORM_MAX_PATH];
		ReadPackString(pack, model, PLATFORM_MAX_PATH);
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public Action:Timer_Enable_Damage(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	if(client)
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
		FF2_SetFF2Flags(client, FF2_GetFF2Flags(client) & ~FF2FLAG_ALLOWSPAWNINBOSSTEAM);
		SDKUnhook(client, SDKHook_OnTakeDamage, SaveMinion);
	}
	return Plugin_Continue;
}

public Action:SaveMinion(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if(attacker>MaxClients)
	{
		decl String:edict[64];
		if(GetEdictClassname(attacker, edict, sizeof(edict)) && StrEqual(edict, "trigger_hurt", false))
		{
			new target, Float:position[3];
			new bool:otherTeamIsAlive;
			for(new clone=1; clone<=MaxClients; clone++)
			{
				if(IsValidEdict(clone) && IsClientInGame(clone) && IsPlayerAlive(clone) && TF2_GetClientTeam(clone)!=BossTeam)
				{
					otherTeamIsAlive=true;
					break;
				}
			}

			new tries;
			do
			{
				tries++;
				target=GetRandomInt(1, MaxClients);
				if(tries==100)
				{
					return Plugin_Continue;
				}
			}
			while(otherTeamIsAlive && (!IsValidEdict(target) || TF2_GetClientTeam(target)==BossTeam || !IsPlayerAlive(target)));

			GetEntPropVector(target, Prop_Data, "m_vecOrigin", position);
			TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
			TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:Timer_Demopan_Rage(Handle:timer, any:count)  //TODO: Make this rage configurable
{
	if(count==13)  //Rage has finished-reset it in 6 seconds (trade_0 is 100% transparent apparently)
	{
		CreateTimer(6.0, Timer_Demopan_Rage, 0);
	}
	else
	{
		decl String:overlay[PLATFORM_MAX_PATH];
		Format(overlay, sizeof(overlay), "r_screenoverlay \"freak_fortress_2/demopan/trade_%i\"", count);

		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);  //Allow normal players to use r_screenoverlay
		for(new client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && TF2_GetClientTeam(client)!=BossTeam)
			{
				ClientCommand(client, overlay);
			}
		}
		SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);  //Reset the cheat permissions

		if(count)
		{
			EmitSoundToAll(SOUND_DEMOPAN_RAGE, _, _, _, _, _, _, _, _, _, false);
			CreateTimer(count==1 ? 1.0 : 0.5/float(count), Timer_Demopan_Rage, count+1);  //Give a longer delay between the first and second overlay for "smoothness"
		}
		else  //Stop the rage
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

Rage_Bow(boss)
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
	new weapon=SpawnWeapon(client, "tf_weapon_compound_bow", 1005, 100, 5, "6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19");
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
	new TFTeam:team=(FF2_GetBossTeam2()==TFTeam_Blue ? TFTeam_Red : TFTeam_Blue);

	new otherTeamAlivePlayers;
	for(new target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && TF2_GetClientTeam(target)==team && IsPlayerAlive(target))
		{
			otherTeamAlivePlayers++;
		}
	}

	FF2_SetAmmo(client, weapon, ((otherTeamAlivePlayers>=CBS_MAX_ARROWS) ? CBS_MAX_ARROWS : otherTeamAlivePlayers)-1, 1);  //Put one arrow in the clip
}

public Action:Timer_Prepare_Explosion_Rage(Handle:timer, Handle:data)
{
	new boss=ReadPackCell(data);
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));

	decl String:ability_name[64];
	ReadPackString(data, ability_name, sizeof(ability_name));

	CreateTimer(0.13, Timer_Rage_Explosive_Dance, boss, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	new Float:position[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", position);

	new String:sound[PLATFORM_MAX_PATH];
	FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "sound", sound, PLATFORM_MAX_PATH);
	if(strlen(sound))
	{
		EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
		EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
		for(new target=1; target<=MaxClients; target++)
		{
			if(IsClientInGame(target) && target!=client)
			{
				EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
				EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
			}
		}
	}
	return Plugin_Continue;
}

public Action:Timer_Rage_Explosive_Dance(Handle:timer, any:boss)
{
	static count;
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	count++;
	if(count<=35 && IsPlayerAlive(client))
	{
		SetEntityMoveType(boss, MOVETYPE_NONE);
		new Float:bossPosition[3], Float:explosionPosition[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
		explosionPosition[2]=bossPosition[2];
		for(new i; i<5; i++)
		{
			new explosion=CreateEntityByName("env_explosion");
			DispatchKeyValueFloat(explosion, "DamageForce", 180.0);

			SetEntProp(explosion, Prop_Data, "m_iMagnitude", 280, 4);
			SetEntProp(explosion, Prop_Data, "m_iRadiusOverride", 200, 4);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", client);

			DispatchSpawn(explosion);

			explosionPosition[0]=bossPosition[0]+GetRandomInt(-350, 350);
			explosionPosition[1]=bossPosition[1]+GetRandomInt(-350, 350);
			if(!(GetEntityFlags(boss) & FL_ONGROUND))
			{
				explosionPosition[2]=bossPosition[2]+GetRandomInt(-150, 150);
			}
			else
			{
				explosionPosition[2]=bossPosition[2]+GetRandomInt(0,100);
			}
			TeleportEntity(explosion, explosionPosition, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explosion, "Explode");
			AcceptEntityInput(explosion, "kill");

			/*proj=CreateEntityByName("tf_projectile_rocket");
			SetVariantInt(BossTeam);
			AcceptEntityInput(proj, "TeamNum", -1, -1, 0);
			SetVariantInt(BossTeam);
			AcceptEntityInput(proj, "SetTeam", -1, -1, 0);
			SetEntPropEnt(proj, Prop_Send, "m_hOwnerEntity",boss);
			decl Float:position[3];
			new Float:rot[3]={0.0,90.0,0.0};
			new Float:see[3]={0.0,0.0,-1000.0};
			GetEntPropVector(boss, Prop_Send, "m_vecOrigin", position);
			position[0]+=GetRandomInt(-250,250);
			position[1]+=GetRandomInt(-250,250);
			position[2]+=40;
			TeleportEntity(proj, position, rot,see);
			SetEntDataFloat(proj, FindSendPropOffs("CTFProjectile_Rocket", "m_iDeflected") + 4, 300.0, true);
			DispatchSpawn(proj);
			CreateTimer(0.1,Timer_Rage_Explosive_Dance_Boom,EntIndextoEntRef(proj));*/
		}
	}
	else
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		count=0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

Rage_Slowmo(boss, const String:ability_name[])
{
	FF2_SetFF2Flags(boss, FF2_GetFF2Flags(boss)|FF2FLAG_CHANGECVAR);
	SetConVarFloat(cvarTimeScale, FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "timescale", 0.1));
	new Float:duration=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 1.0)+1.0;
	SlowMoTimer=CreateTimer(duration, Timer_StopSlowMo, boss);
	FF2Flags[boss]=FF2Flags[boss]|FLAG_ONSLOWMO;
	UpdateClientCheatValue(1);

	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(client)
	{
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(AttachParticle(client, BossTeam==TFTeam_Blue ? "scout_dodge_blue" : "scout_dodge_red", 75.0)));
	}

	EmitSoundToAll(SOUND_SLOW_MO_START, _, _, _, _, _, _, _, _, _, false);
	EmitSoundToAll(SOUND_SLOW_MO_START, _, _, _, _, _, _, _, _, _, false);
}

public Action:Timer_StopSlowMo(Handle:timer, any:boss)
{
	SlowMoTimer=INVALID_HANDLE;
	oldTarget=0;
	SetConVarFloat(cvarTimeScale, 1.0);
	UpdateClientCheatValue(0);
	if(boss!=-1)
	{
		FF2_SetFF2Flags(boss, FF2_GetFF2Flags(boss) & ~FF2FLAG_CHANGECVAR);
		FF2Flags[boss]&=~FLAG_ONSLOWMO;
	}
	EmitSoundToAll(SOUND_SLOW_MO_END, _, _, _, _, _, _, _, _, _, false);
	EmitSoundToAll(SOUND_SLOW_MO_END, _, _, _, _, _, _, _, _, _, false);
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:velocity[3], Float:angles[3], &weapon)
{
	new boss=FF2_GetBossIndex(client);
	if(boss==-1 || !(FF2Flags[boss] & FLAG_ONSLOWMO))
	{
		return Plugin_Continue;
	}

	if(buttons & IN_ATTACK)
	{
		new Float:bossPosition[3], Float:endPosition[3], Float:eyeAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);
		bossPosition[2]+=65;
		GetClientEyeAngles(client, eyeAngles);

		new Handle:trace=TR_TraceRayFilterEx(bossPosition, eyeAngles, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf);
		TR_GetEndPosition(endPosition, trace);
		endPosition[2]+=100;
		SubtractVectors(endPosition, bossPosition, velocity);
		NormalizeVector(velocity, velocity);
		ScaleVector(velocity, 2012.0);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
		new target=TR_GetEntityIndex(trace);
		if(target && target<=MaxClients)
		{
			new Handle:data;
			CreateDataTimer(0.15, Timer_Rage_SlowMo_Attack, data);
			WritePackCell(data, GetClientUserId(client));
			WritePackCell(data, GetClientUserId(target));
			ResetPack(data);
		}
		CloseHandle(trace);
	}
	return Plugin_Continue;
}

public Action:Timer_Rage_SlowMo_Attack(Handle:timer, Handle:data)
{
	new client=GetClientOfUserId(ReadPackCell(data));
	new target=GetClientOfUserId(ReadPackCell(data));
	if(client && target && IsClientInGame(client) && IsClientInGame(target))
	{
		new Float:clientPosition[3], Float:targetPosition[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", clientPosition);
		GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);
		if(GetVectorDistance(clientPosition, targetPosition)<=1500 && target!=oldTarget)
		{
			SetEntProp(client, Prop_Send, "m_bDucked", 1);
			SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
			SDKHooks_TakeDamage(target, client, client, 900.0);
			TeleportEntity(client, targetPosition, NULL_VECTOR, NULL_VECTOR);
			oldTarget=target;
		}
	}
}

public bool:TraceRayDontHitSelf(entity, mask)
{
	if(!entity || entity>MaxClients)
	{
		return true;
	}

	if(FF2_GetBossIndex(entity)==-1)
	{
		return true;
	}
	return false;
}

//Unused single rocket shoot charge
/*Charge_RocketSpawn(const String:ability_name[],index,slot,action)
{
	if(FF2_GetBossCharge(index,0)<10)
		return;
	new boss=GetClientOfUserId(FF2_GetBossUserId(index));
	new Float:see=FF2_GetAbilityArgumentFloat2(index,this_plugin_name,ability_name,1,5.0);
	new Float:charge=FF2_GetBossCharge(index,slot);
	switch(action)
	{
		case 2:
		{
			SetHudTextParams(-1.0, 0.93, 0.15, 255, 255, 255, 255);
			if(charge+1<see)
				FF2_SetBossCharge(index,slot,charge+1);
			else
				FF2_SetBossCharge(index,slot,see);
			ShowSyncHudText(boss, chargeHUD, "%t","charge_status",RoundFloat(charge*100/see));
		}
		case 3:
		{
			FF2_SetBossCharge(index,0,charge-10);
			decl Float:position[3];
			decl Float:rot[3];
			decl Float:velocity[3];
			GetEntPropVector(boss, Prop_Send, "m_vecOrigin", position);
			GetClientEyeAngles(boss,rot);
			position[2]+=63;

			new proj=CreateEntityByName("tf_projectile_rocket");
			SetVariantInt(BossTeam);
			AcceptEntityInput(proj, "TeamNum", -1, -1, 0);
			SetVariantInt(BossTeam);
			AcceptEntityInput(proj, "SetTeam", -1, -1, 0);
			SetEntPropEnt(proj, Prop_Send, "m_hOwnerEntity",boss);
			new Float:speed=FF2_GetAbilityArgumentFloat2(index,this_plugin_name,ability_name,3,1000.0);
			velocity[0]=Cosine(DegToRad(rot[0]))*Cosine(DegToRad(rot[1]))*speed;
			velocity[1]=Cosine(DegToRad(rot[0]))*Sine(DegToRad(rot[1]))*speed;
			velocity[2]=Sine(DegToRad(rot[0]))*speed;
			velocity[2]*=-1;
			TeleportEntity(proj, position, rot,velocity);
			SetEntDataFloat(proj, FindSendPropOffs("CTFProjectile_Rocket", "m_iDeflected") + 4, FF2_GetAbilityArgumentFloat2(index,this_plugin_name,ability_name,5,150.0), true);
			DispatchSpawn(proj);
			new String:s[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString2(index,this_plugin_name,ability_name,4,s,PLATFORM_MAX_PATH);
			if(strlen(s)>5)
				SetEntityModel(proj,s);
			FF2_SetBossCharge(index,slot,-5*FF2_GetAbilityArgumentFloat2(index,this_plugin_name,ability_name,2,5.0));
			if(FF2_RandomSound("sound_ability",s,PLATFORM_MAX_PATH,index,slot))
			{
				EmitSoundToAll(s, boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, position, NULL_VECTOR, true, 0.0);
				EmitSoundToAll(s, boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, position, NULL_VECTOR, true, 0.0);

				for(new i=1; i<=MaxClients; i++)
					if(IsClientInGame(i) && i!=boss)
					{
						EmitSoundToClient(i,s, boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, position, NULL_VECTOR, true, 0.0);
						EmitSoundToClient(i,s, boss, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, boss, position, NULL_VECTOR, true, 0.0);
					}
			}
		}
	}
}
*/

Rage_Stun(const String:ability_name[], boss)
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	new Float:bossPosition[3], Float:targetPosition[3];
	new Float:duration=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 5.0);
	new Float:distance=FF2_GetBossRageDistance(boss, this_plugin_name, ability_name);
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", bossPosition);

	for(new target=1; target<=MaxClients; target++)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && TF2_GetClientTeam(target)!=BossTeam)
		{
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPosition);
			if(!TF2_IsPlayerInCondition(target, TFCond_Ubercharged) && (GetVectorDistance(bossPosition, targetPosition)<=distance))
			{
				if(removeBaseJumperOnStun)
				{
					TF2_RemoveCondition(target, TFCond_Parachute);
				}
				TF2_StunPlayer(target, duration, 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
				CreateTimer(duration, RemoveEntity, EntIndexToEntRef(AttachParticle(target, "yikes_fx", 75.0)));
			}
		}
	}
}

public Action:Timer_StopUber(Handle:timer, any:boss)
{
	SetEntProp(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Data, "m_takedamage", 2);
	return Plugin_Continue;
}

Rage_StunSentry(const String:ability_name[], boss)
{
	new Float:bossPosition[3], Float:sentryPosition[3];
	GetEntPropVector(GetClientOfUserId(FF2_GetBossUserId(boss)), Prop_Send, "m_vecOrigin", bossPosition);
	new Float:duration=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "duration", 7.0);
	new Float:distance=FF2_GetBossRageDistance(boss, this_plugin_name, ability_name);

	new sentry;
	while((sentry=FindEntityByClassname(sentry, "obj_sentrygun"))!=-1)
	{
		GetEntPropVector(sentry, Prop_Send, "m_vecOrigin", sentryPosition);
		if(GetVectorDistance(bossPosition, sentryPosition)<=distance)
		{
			SetEntProp(sentry, Prop_Send, "m_bDisabled", 1);
			CreateTimer(duration, RemoveEntity, EntIndexToEntRef(AttachParticle(sentry, "yikes_fx", 75.0)));
			CreateTimer(duration, Timer_EnableSentry, EntIndexToEntRef(sentry));
		}
	}
}

public Action:Timer_EnableSentry(Handle:timer, any:sentryid)
{
	new sentry=EntRefToEntIndex(sentryid);
	if(FF2_GetRoundState()==1 && sentry>MaxClients)
	{
		SetEntProp(sentry, Prop_Send, "m_bDisabled", 0);
	}
	return Plugin_Continue;
}

Charge_BraveJump(const String:ability_name[], boss, slot, status)
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	new Float:charge=FF2_GetBossCharge(boss, slot);
	new Float:multiplier=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, ability_name, "multiplier", 1.0);

	switch(status)
	{
		case 1:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "Super Jump Cooldown", -RoundFloat(charge));
		}
		case 2:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			if(enableSuperDuperJump[boss])
			{
				SetHudTextParams(-1.0, 0.88, 0.15, 255, 64, 64, 255);
				FF2_ShowSyncHudText(client, jumpHUD, "%t", "Super Duper Jump");
			}
			else
			{
				FF2_ShowSyncHudText(client, jumpHUD, "%t", "Super Jump Charge", RoundFloat(charge));
			}
		}
		case 3:
		{
			new bool:superJump=enableSuperDuperJump[boss];
			new Action:action;
			Call_StartForward(OnSuperJump);
			Call_PushCell(boss);
			Call_PushCellRef(superJump);
			Call_Finish(action);
			if(action==Plugin_Handled || action==Plugin_Stop)
			{
				return;
			}
			else if(action==Plugin_Changed)
			{
				enableSuperDuperJump[client]=superJump;
			}

			new Float:position[3], Float:velocity[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

			if(oldJump)
			{
				if(enableSuperDuperJump[boss])
				{
					velocity[2]=750+(charge/4)*13.0+2000;
					enableSuperDuperJump[boss]=false;
				}
				else
				{
					velocity[2]=750+(charge/4)*13.0;
				}
				SetEntProp(client, Prop_Send, "m_bJumping", 1);
				velocity[0]*=(1+Sine((charge/4)*FLOAT_PI/50));
				velocity[1]*=(1+Sine((charge/4)*FLOAT_PI/50));
			}
			else
			{
				new Float:angles[3];
				GetClientEyeAngles(client, angles);
				if(enableSuperDuperJump[boss])
				{
					velocity[0]+=Cosine(DegToRad(angles[0]))*Cosine(DegToRad(angles[1]))*500*multiplier;
					velocity[1]+=Cosine(DegToRad(angles[0]))*Sine(DegToRad(angles[1]))*500*multiplier;
					velocity[2]=(750.0+175.0*charge/70+2000)*multiplier;
					enableSuperDuperJump[boss]=false;
				}
				else
				{
					velocity[0]+=Cosine(DegToRad(angles[0]))*Cosine(DegToRad(angles[1]))*100*multiplier;
					velocity[1]+=Cosine(DegToRad(angles[0]))*Sine(DegToRad(angles[1]))*100*multiplier;
					velocity[2]=(750.0+175.0*charge/70)*multiplier;
				}
			}

			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			decl String:sound[PLATFORM_MAX_PATH];
			if(FF2_RandomSound("sound_ability", sound, sizeof(sound), boss, slot))
			{
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
				EmitSoundToAll(sound, client, _, _, _, _, _, client, position);

				for(new target=1; target<=MaxClients; target++)
				{
					if(IsClientInGame(target) && target!=client)
					{
						EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
						EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
					}
				}
			}
		}
	}
}

Charge_Teleport(const String:ability_name[], boss, slot, status)
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	new Float:charge=FF2_GetBossCharge(boss, slot);
	switch(status)
	{
		case 1:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "Teleportation Cooldown", -RoundFloat(charge));
		}
		case 2:
		{
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
			FF2_ShowSyncHudText(client, jumpHUD, "%t", "Teleportation Charge", RoundFloat(charge));
		}
		case 3:
		{
			new Action:action;
			new bool:superJump=enableSuperDuperJump[boss];
			Call_StartForward(OnSuperJump);
			Call_PushCell(boss);
			Call_PushCellRef(superJump);
			Call_Finish(action);
			if(action==Plugin_Handled || action==Plugin_Stop)
			{
				return;
			}
			else if(action==Plugin_Changed)
			{
				enableSuperDuperJump[boss]=superJump;
			}

			if(enableSuperDuperJump[boss])
			{
				enableSuperDuperJump[boss]=false;
			}
			else if(charge<100)
			{
				CreateTimer(0.1, Timer_ResetCharge, boss*10000+slot);  //FIXME: Investigate.
				return;
			}

			new tries;
			new bool:otherTeamIsAlive;
			for(new target=1; target<=MaxClients; target++)
			{
				if(IsClientInGame(target) && IsPlayerAlive(target) && target!=client && !(FF2_GetFF2Flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
				{
					otherTeamIsAlive=true;
					break;
				}
			}

			new target;
			do
			{
				tries++;
				target=GetRandomInt(1, MaxClients);
				if(tries==100)
				{
					return;
				}
			}
			while(otherTeamIsAlive && (!IsValidEdict(target) || target==client || (FF2_GetFF2Flags(target) & FF2FLAG_ALLOWSPAWNINBOSSTEAM) || !IsPlayerAlive(target)));

			decl String:particle[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString2(boss, this_plugin_name, ability_name, "particle", particle, sizeof(particle));
			if(strlen(particle)>0)
			{
				CreateTimer(3.0, RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle)));
				CreateTimer(3.0, RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle, _, false)));
			}

			new Float:position[3];
			GetEntPropVector(target, Prop_Data, "m_vecOrigin", position);
			if(IsValidEdict(target))
			{
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", position);
				SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime() + (enableSuperDuperJump ? 4.0:2.0));
				if(GetEntProp(target, Prop_Send, "m_bDucked"))
				{
					new Float:temp[3]={24.0, 24.0, 62.0};  //Compiler won't accept directly putting it into SEPV -.-
					SetEntPropVector(client, Prop_Send, "m_vecMaxs", temp);
					SetEntProp(client, Prop_Send, "m_bDucked", 1);
					SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
					CreateTimer(0.2, Timer_StunBoss, boss, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					TF2_StunPlayer(client, (enableSuperDuperJump ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, target);
				}

				TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
				if(strlen(particle)>0)
				{
					CreateTimer(3.0, RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle)));
					CreateTimer(3.0, RemoveEntity, EntIndexToEntRef(AttachParticle(client, particle, _, false)));
				}
			}

			decl String:sound[PLATFORM_MAX_PATH];
			if(FF2_RandomSound("sound_ability", sound, sizeof(sound), boss, slot))
			{
				EmitSoundToAll(sound, boss, _, _, _, _, _, boss, position);
				EmitSoundToAll(sound, boss, _, _, _, _, _, boss, position);

				for(new enemy=1; enemy<=MaxClients; enemy++)
				{
					if(IsClientInGame(enemy) && enemy!=boss)
					{
						EmitSoundToClient(enemy, sound, boss, _, _, _, _, _, boss, position);
						EmitSoundToClient(enemy, sound, client, _, _, _, _, _, boss, position);
					}
				}
			}
		}
	}
}

public Action:Timer_ResetCharge(Handle:timer, any:boss)  //FIXME: What.
{
	new slot=boss%10000;
	boss/=1000;
	FF2_SetBossCharge(boss, slot, 0.0);
}

public Action:Timer_StunBoss(Handle:timer, any:boss)
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(!IsValidEdict(client))
	{
		return;
	}
	TF2_StunPlayer(client, (enableSuperDuperJump[boss] ? 4.0 : 2.0), 0.0, TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT, client);
}

Charge_WeighDown(boss, slot)  //TODO: Create a HUD for this
{
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if(client<=0 || !(GetClientButtons(client) & IN_DUCK))
	{
		return;
	}

	new Float:charge=FF2_GetBossCharge(boss, slot)+0.2;
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(charge>=4.0)
		{
			new Float:angles[3];
			GetClientEyeAngles(client, angles);
			if(angles[0]>60.0)
			{
				new Action:action;
				Call_StartForward(OnWeighdown);
				Call_PushCell(boss);
				Call_Finish(action);
				if(action==Plugin_Handled || action==Plugin_Stop)
				{
					return;
				}

				new Handle:data;
				new Float:velocity[3];
				if(gravityDatapack[client]==INVALID_HANDLE)
				{
					gravityDatapack[client]=CreateDataTimer(2.0, Timer_ResetGravity, data, TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(data, GetClientUserId(client));
					WritePackFloat(data, GetEntityGravity(client));
					ResetPack(data);
				}

				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
				velocity[2]=-1000.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
				SetEntityGravity(client, 6.0);

				FF2_SetBossCharge(boss, slot, 0.0);
			}
		}
		else
		{
			FF2_SetBossCharge(boss, slot, charge);
		}
	}
	else if(charge>0.3 || charge<0)
	{
		FF2_SetBossCharge(boss, slot, 0.0);
	}
}

public Action:Timer_ResetGravity(Handle:timer, Handle:data)
{
	new client=GetClientOfUserId(ReadPackCell(data));
	if(client && IsValidEdict(client) && IsClientInGame(client))
	{
		SetEntityGravity(client, ReadPackFloat(data));
	}
	gravityDatapack[client]=INVALID_HANDLE;
	return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new boss=FF2_GetBossIndex(attacker);
	if(boss!=-1 && FF2_HasAbility2(boss, this_plugin_name, "special_dissolve"))
	{
		CreateTimer(0.1, Timer_DissolveRagdoll, GetEventInt(event, "userid"));
	}
	
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || !attacker || !IsClientInGame(client) || !IsClientInGame(attacker))
	{
		return Plugin_Continue;
	}
	
	if(boss!=-1)
	{
		if(FF2_HasAbility2(boss, this_plugin_name, "special_dropprop"))
		{
			decl String:model[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString2(boss, this_plugin_name, "special_dropprop", "model", model, sizeof(model));
			if(model[0]!='\0')  //Because you never know when someone is careless and doesn't specify a model...
			{
				if(!IsModelPrecached(model))  //Make sure the boss author precached the model (similar to above)
				{
					new String:bossName[64];
					FF2_GetBossSpecial(boss, bossName, sizeof(bossName));
					if(!FileExists(model, true))
					{
						LogError("[FF2 Bosses] Model '%s' doesn't exist!  Please check %s's \"mod_precache\"", bossName, model);
						return Plugin_Continue;
					}

					LogError("[FF2 Bosses] Model '%s' isn't precached!  Please check %s's \"mod_precache\"", bossName, model);
					PrecacheModel(model);
				}

				if(FF2_GetAbilityArgument2(boss, this_plugin_name, "special_dropprop", "remove ragdoll", 0))
				{
					CreateTimer(0.01, Timer_RemoveRagdoll, GetEventInt(event, "userid"));
				}

				new prop=CreateEntityByName("prop_physics_override");
				if(IsValidEntity(prop))
				{
					SetEntityModel(prop, model);
					SetEntityMoveType(prop, MOVETYPE_VPHYSICS);
					SetEntProp(prop, Prop_Send, "m_CollisionGroup", 1);
					SetEntProp(prop, Prop_Send, "m_usSolidFlags", 16);
					DispatchSpawn(prop);

					new Float:position[3];
					GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
					position[2]+=20;
					TeleportEntity(prop, position, NULL_VECTOR, NULL_VECTOR);
					new Float:duration=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, "special_dropprop", "duration", 0.0);
					if(duration>0.5)
					{
						CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(prop));
					}
				}
			}
		}

		if(FF2_HasAbility2(boss, this_plugin_name, "special_cbs_multimelee"))
		{
			if(GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee))
			{
				TF2_RemoveWeaponSlot(attacker, TFWeaponSlot_Melee);
				new weapon;
				switch(GetRandomInt(0, 2))
				{
					case 0:
					{
						weapon=SpawnWeapon(attacker, "tf_weapon_club", 171, 101, 5, "68 ; 2 ; 2 ; 3.0");
					}
					case 1:
					{
						weapon=SpawnWeapon(attacker, "tf_weapon_club", 193, 101, 5, "68 ; 2 ; 2 ; 3.0");
					}
					case 2:
					{
						weapon=SpawnWeapon(attacker, "tf_weapon_club", 232, 101, 5, "68 ; 2 ; 2 ; 3.0");
					}
				}
				SetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon", weapon);
			}
		}
		
		if(FF2_HasAbility2(boss, this_plugin_name, OBJECTS))
		{
			decl String:classname[PLATFORM_MAX_PATH], String:model[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString2(boss, this_plugin_name, OBJECTS, "classname", classname, sizeof(classname));
			FF2_GetAbilityArgumentString2(boss, this_plugin_name, OBJECTS, "model", model, sizeof(model));
			new skin=FF2_GetAbilityArgument2(boss, this_plugin_name, OBJECTS, "skin");
			new count=FF2_GetAbilityArgument2(boss, this_plugin_name, OBJECTS, "count", 14);
			new Float:distance=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, OBJECTS, "distance", 30.0);
			SpawnManyObjects(classname, client, model, skin, count, distance);
			return Plugin_Continue;
		}
	}

	boss=FF2_GetBossIndex(client);
	if(boss!=-1 && FF2_HasAbility2(boss, this_plugin_name, OBJECTS_DEATH))
	{
		decl String:classname[PLATFORM_MAX_PATH], String:model[PLATFORM_MAX_PATH];
		FF2_GetAbilityArgumentString2(boss, this_plugin_name, OBJECTS_DEATH, "classname", classname, sizeof(classname));
		FF2_GetAbilityArgumentString2(boss, this_plugin_name, OBJECTS_DEATH, "model", model, sizeof(model));
		new skin=FF2_GetAbilityArgument2(boss, this_plugin_name, OBJECTS_DEATH, "skin");
		new count=FF2_GetAbilityArgument2(boss, this_plugin_name, OBJECTS_DEATH, "count", 14);
		new Float:distance=FF2_GetAbilityArgumentFloat2(boss, this_plugin_name, OBJECTS_DEATH, "distance", 30.0);
		SpawnManyObjects(classname, client, model, skin, count, distance);
		return Plugin_Continue;
	}
	if(boss!=-1 && FF2_HasAbility2(boss, this_plugin_name, "rage_cloneattack") && FF2_GetAbilityArgument2(boss, this_plugin_name, "rage_cloneattack", "die on boss death", 1) && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
	{
		for(new target=1; target<=MaxClients; target++)
		{
			if(CloneOwnerIndex[target]==boss && IsClientInGame(target) && TF2_GetClientTeam(target)==BossTeam)
			{
				CloneOwnerIndex[target]=-1;
				FF2_SetFF2Flags(target, FF2_GetFF2Flags(target) & ~FF2FLAG_CLASSTIMERDISABLED);
				TF2_ChangeClientTeam(target, (BossTeam==TFTeam_Blue) ? (TFTeam_Red) : (TFTeam_Blue));
			}
		}
	}

	if(CloneOwnerIndex[client]!=-1 && TF2_GetClientTeam(client)==BossTeam)  //Switch clones back to the other team after they die
	{
		CloneOwnerIndex[client]=-1;
		FF2_SetFF2Flags(client, FF2_GetFF2Flags(client) & ~FF2FLAG_CLASSTIMERDISABLED);
		TF2_ChangeClientTeam(client, BossTeam==TFTeam_Blue ? TFTeam_Red : TFTeam_Blue);
	}
	return Plugin_Continue;
}

public Action:Timer_RemoveRagdoll(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	new ragdoll;
	if(client>0 && (ragdoll=GetEntPropEnt(client, Prop_Send, "m_hRagdoll"))>MaxClients)
	{
		AcceptEntityInput(ragdoll, "Kill");
	}
}


public Action:Timer_DissolveRagdoll(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	new ragdoll=-1;
	if(client && IsClientInGame(client))
	{
		ragdoll=GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
	}

	if(ragdoll!=-1)
	{
		DissolveRagdoll(ragdoll);
	}
}

public Action:Timer_RemoveEntity(Handle:timer, any:entid)
{
	new entity=EntRefToEntIndex(entid);
	if(IsValidEdict(entity) && entity>MaxClients)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

DissolveRagdoll(ragdoll)
{
	new dissolver=CreateEntityByName("env_entity_dissolver");
	if(dissolver==-1)
	{
		return;
	}

	DispatchKeyValue(dissolver, "dissolvetype", "0");
	DispatchKeyValue(dissolver, "magnitude", "200");
	DispatchKeyValue(dissolver, "target", "!activator");

	AcceptEntityInput(dissolver, "Dissolve", ragdoll);
	AcceptEntityInput(dissolver, "Kill");
}

public Action:RemoveEntity(Handle:timer, any:entid)
{
	new entity=EntRefToEntIndex(entid);
	if(IsValidEdict(entity) && entity>MaxClients)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock AttachParticle(entity, String:particleType[], Float:offset=0.0, bool:attach=true)
{
	new particle=CreateEntityByName("info_particle_system");

	decl String:targetName[128];
	new Float:position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	position[2]+=offset;
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);

	Format(targetName, sizeof(targetName), "target%i", entity);
	DispatchKeyValue(entity, "targetname", targetName);

	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", targetName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(targetName);
	if(attach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", entity);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}

public Action:OnDeflect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new boss=FF2_GetBossIndex(GetClientOfUserId(GetEventInt(event, "userid")));
	if(boss!=-1)
	{
		if(UberRageCount[boss]>11)
		{
			UberRageCount[boss]-=10;
		}
	}
	return Plugin_Continue;
}

public Action:FF2_OnTriggerHurt(boss, triggerhurt, &Float:damage)
{
	enableSuperDuperJump[boss]=true;
	if(FF2_GetBossCharge(boss, 1)<0)
	{
		FF2_SetBossCharge(boss, 1, 0.0);
	}
	return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
	if(FF2_IsFF2Enabled() && IsValidEdict(entity) && StrContains(classname, "tf_projectile")>=0)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnProjectileSpawned);
	}
}

public OnProjectileSpawned(entity)
{
	new client=GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(client>0 && client<=MaxClients && IsClientInGame(client))
	{
		new boss=FF2_GetBossIndex(client);
		if(boss>=0 && FF2_HasAbility2(boss, this_plugin_name, PROJECTILE))
		{
			decl String:projectile[PLATFORM_MAX_PATH];
			FF2_GetAbilityArgumentString2(boss, this_plugin_name, PROJECTILE, "classname", projectile, sizeof(projectile));

			decl String:classname[PLATFORM_MAX_PATH];
			GetEntityClassname(entity, classname, sizeof(classname));
			if(StrEqual(classname, projectile, false))
			{
				decl String:model[PLATFORM_MAX_PATH];
				FF2_GetAbilityArgumentString2(boss, this_plugin_name, PROJECTILE, "model", model, sizeof(model));
				if(IsModelPrecached(model))
				{
					SetEntityModel(entity, model);
				}
				else
				{
					decl String:bossName[64];
					FF2_GetBossSpecial(boss, bossName, sizeof(bossName));
					LogError("[FF2 Bosses] Model %s (used by boss %s for ability %s) isn't precached!", model, bossName, PROJECTILE);
				}
			}
		}
	}
}

stock UpdateClientCheatValue(value)
{
	for(new client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
		{
			SendConVarValue(client, cvarCheats, value ? "1" : "0");
		}
	}
}

SpawnManyObjects(String:classname[], client, String:model[], skin=0, amount=14, Float:distance=30.0)
{
	if(!client || !IsClientInGame(client))
	{
		return;
	}

	new Float:position[3], Float:velocity[3];
	new Float:angle[]={90.0, 0.0, 0.0};
	GetClientAbsOrigin(client, position);
	position[2]+=distance;
	for(new i; i<amount; i++)
	{
		velocity[0]=GetRandomFloat(-400.0, 400.0);
		velocity[1]=GetRandomFloat(-400.0, 400.0);
		velocity[2]=GetRandomFloat(300.0, 500.0);
		position[0]+=GetRandomFloat(-5.0, 5.0);
		position[1]+=GetRandomFloat(-5.0, 5.0);

		new entity=CreateEntityByName(classname);
		if(!IsValidEntity(entity))
		{
			LogError("[FF2] Invalid entity while spawning objects for Easter Abilities-check your configs!");
			continue;
		}

		SetEntityModel(entity, model);
		DispatchKeyValue(entity, "OnPlayerTouch", "!self,Kill,,0,-1");
		SetEntProp(entity, Prop_Send, "m_nSkin", skin);
		SetEntProp(entity, Prop_Send, "m_nSolidType", 6);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 152);
		SetEntProp(entity, Prop_Send, "m_triggerBloat", 24);
		SetEntProp(entity, Prop_Send, "m_CollisionGroup", 1);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(entity, Prop_Send, "m_iTeamNum", 2);
		DispatchSpawn(entity);
		TeleportEntity(entity, position, angle, velocity);
		SetEntProp(entity, Prop_Data, "m_iHealth", 900);
		new offs=GetEntSendPropOffs(entity, "m_vecInitialVelocity", true);
		SetEntData(entity, offs-4, 1, _, true);
	}
}
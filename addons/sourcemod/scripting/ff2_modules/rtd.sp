#undef REQUIRE_PLUGIN
#tryinclude <rtd>
#tryinclude <rtd2>
#define REQUIRE_PLUGIN

ConVar cvarRTDDisabledPerks;

#if defined _rtd_included
#define DISABLED_PERKS "toxic,noclip,uber,ammo,instant,jump,tinyplayer"
#endif

void FindRTD()
{
	#if defined _rtd_included
	if(LibraryExists("TF2: Roll the Dice"))
	{
		cvarRTDDisabledPerks=FindConVar("sm_rtd_disabled");
		if(cvarRTDDisabledPerks)
		{
			cvarRTDDisabledPerks.SetString(DISABLED_PERKS);
		}
	}
	#endif
	
	#if defined _rtd2_included
	if(LibraryExists("RollTheDice2"))
	{
		RTD2_SetPerkById(1, -1);
		RTD2_SetPerkById(4, -1);
		RTD2_SetPerkById(31, -1);
		RTD2_SetPerkById(32, -1);
		RTD2_SetPerkById(34, -1);
		RTD2_SetPerkById(36, -1);
		RTD2_SetPerkById(38, -1);
		RTD2_SetPerkById(40, -1);
	}
	#endif
}

void OnRTDLoaded(const char[] name)
{
	#if defined _rtd2_included
	if(StrEqual(name, "RollTheDice2"))
	{
		RTD2_SetPerkById(1, -1);
		RTD2_SetPerkById(4, -1);
		RTD2_SetPerkById(31, -1);
		RTD2_SetPerkById(32, -1);
		RTD2_SetPerkById(34, -1);
		RTD2_SetPerkById(36, -1);
		RTD2_SetPerkById(38, -1);
		RTD2_SetPerkById(40, -1);
	}
	#endif
}

public Action RTD_CanRollDice(int client)
{
	if(IsBoss(client) && !cvarBossRTD.BoolValue)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action RTD2_CanRollDice(int client)
{
	if(IsBoss(client) && !cvarBossRTD.BoolValue)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
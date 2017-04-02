#undef REQUIRE_PLUGIN
#tryinclude<smac>
#define REQUIRE_PLUGIN

public OnSMACLoaded(const char[] name)
{
    if(!strcmp(name, "smac", false))
    {
        smac=true;
    }
}

public OnSMACRemoved(const char[] name)
{
    if(!strcmp(name, "smac", false))
    {
        smac=false;
    }
}

void SetSMACConVars()
{
    if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
    {
        ServerCommand("smac_addcvar sv_cheats replicated ban 0 0");
        ServerCommand("smac_addcvar host_timescale replicated ban 1.0 1.0");
    }
}

public Action:SMAC_OnCheatDetected(client, const String:module[], DetectionType:type, Handle:info)
{
    #if defined _smac_included
    if(type==Detection_CvarViolation)
    {
        new String:cvar[PLATFORM_MAX_PATH];
        KvGetString(info, "cvar", cvar, sizeof(cvar));
        if((StrEqual(cvar, "sv_cheats") || StrEqual(cvar, "host_timescale")) && !(FF2Flags[Boss[client]] & FF2FLAG_CHANGECVAR))
        {
            return Plugin_Stop;
        }
    }
    #endif
    return Plugin_Continue;
}
// developer commands

new bool:InfiniteRageActive[MAXPLAYERS+1]=false;

public Action:Command_SetRage(client, args)
{
    if(!GetConVarBool(cvarDevelopMode))
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Developer mode MUST be enabled to use this command!");
        return Plugin_Handled;
    }

    if(args!=2)
    {
        if(args!=1)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Usage: ff2_setrage or hale_setrage <target> <percent>");
        }
        else 
        {
            if(!IsValidClient(client))
            {
                ReplyToCommand(client, "[FF2 DEV] Command can only be used in-game!");
                return Plugin_Handled;
            }
            
            if(!IsBoss(client) || GetBossIndex(client)==-1 || !IsPlayerAlive(client) || CheckRoundState()!=FF2RoundState_RoundRunning)
            {
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} You must be a boss to give yourself RAGE!");
                return Plugin_Handled;
            }
            
            new String:ragePCT[80];
            GetCmdArg(1, ragePCT, sizeof(ragePCT));
            new Float:rageMeter=StringToFloat(ragePCT);
            
            BossCharge[Boss[client]][0]+=rageMeter;
            CReplyToCommand(client, "You now have %i percent RAGE (%i percent added)", RoundFloat(BossCharge[client][0]), RoundFloat(rageMeter));
            LogAction(client, client, "\"%L\" gave themselves %i RAGE", client, RoundFloat(rageMeter));
        }
        return Plugin_Handled;
    }
    
    new String:ragePCT[80];
    new String:targetName[PLATFORM_MAX_PATH];
    GetCmdArg(1, targetName, sizeof(targetName));
    GetCmdArg(2, ragePCT, sizeof(ragePCT));
    new Float:rageMeter=StringToFloat(ragePCT);

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;
    
    if((target_count=ProcessTargetString(targetName, client, target_list, MaxClients, 0, target_name, sizeof(target_name), tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    for(new target; target<target_count; target++)
    {
        if(IsClientSourceTV(target_list[target]) || IsClientReplay(target_list[target]))
        {
            continue;
        }
        
        if(!IsBoss(target_list[target]) || GetBossIndex(target_list[target])==-1 || !IsPlayerAlive(target_list[target]) || CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} %s must be a boss to add RAGE!", target_name);
            return Plugin_Handled;
        }

        BossCharge[Boss[target_list[target]]][0]+=rageMeter;
        LogAction(client, target_list[target], "\"%L\" added %d RAGE to \"%L\"", client, RoundFloat(rageMeter), target_list[target]);
        CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Added %d rage to %s", RoundFloat(rageMeter), target_name);
    }
    return Plugin_Handled;
}

public Action:Command_SetInfiniteRage(client, args)
{
    if(!GetConVarBool(cvarDevelopMode))
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Developer mode MUST be enabled to use this command!");
        return Plugin_Handled;
    }

    if(args!=1)
    {
        if(args>1)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Usage: ff2_setinfiniterage or hale_setinfiniterage <target>");
        }
        else 
        {
            if(!IsValidClient(client))
            {
                ReplyToCommand(client, "[FF2 DEV] Command can only be used in-game!");
                return Plugin_Handled;
            }
            
            if(!IsBoss(client) || !IsPlayerAlive(client) || GetBossIndex(client)==-1 || CheckRoundState()!=FF2RoundState_RoundRunning)
            {
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} You must be a boss to enable/disable infinite RAGE!");
                return Plugin_Handled;
            }
            if(!InfiniteRageActive[client])
            {
                InfiniteRageActive[client]=true;
                BossCharge[Boss[client]][0]=100.0;
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Infinite RAGE activated");
                LogAction(client, client, "\"%L\" activated infiite RAGE on themselves", client);
                CreateTimer(0.2, Timer_InfiniteRage, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
            }
            else
            {
                InfiniteRageActive[client]=false;
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Infinite RAGE deactivated");
                LogAction(client, client, "\"%L\" deactivated infiite RAGE on themselves", client);
            }
        }
        return Plugin_Handled;
    }

    new String:targetName[PLATFORM_MAX_PATH];
    GetCmdArg(1, targetName, sizeof(targetName));

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;
    
    if((target_count=ProcessTargetString(targetName, client, target_list, MaxClients, 0, target_name, sizeof(target_name), tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    for(new target; target<target_count; target++)
    {
        if(IsClientSourceTV(target_list[target]) || IsClientReplay(target_list[target]))
        {
            continue;
        }
        
        if(!IsBoss(target_list[target]) || GetBossIndex(target_list[target])==-1 || !IsPlayerAlive(target_list[target]) || CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} %s must be a boss to enable/disable infinite RAGE!", target_name);
            return Plugin_Handled;
        }

        if(!InfiniteRageActive[target_list[target]])
        {
            InfiniteRageActive[target_list[target]]=true;
            BossCharge[Boss[target_list[target]]][0]=100.0;
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Infinite RAGE activated for %s", target_name);
            LogAction(client, target_list[target], "\"%L\" activated infinite RAGE on \"%L\"", client, target_list[target]);
            CreateTimer(0.2, Timer_InfiniteRage, target_list[target], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        }
        else
        {
            InfiniteRageActive[target_list[target]]=false;    
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Infinite RAGE deactivated for %s", target_name);
            LogAction(client, target_list[target], "\"%L\" deactivated infinite RAGE on \"%L\"", client, target_list[target]);
        }
    }
    return Plugin_Handled;
}

public Action:Timer_InfiniteRage(Handle:timer, any:client)
{
    if(InfiniteRageActive[client] && CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        InfiniteRageActive[client]=false;
    }
    
    if(!IsBoss(client) || !IsPlayerAlive(client) || GetBossIndex(client)==-1 || !InfiniteRageActive[client] || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        return Plugin_Stop;
    }
    BossCharge[Boss[client]][0]=100.0;
    return Plugin_Continue;
}

public Action:Command_SetCharge(client, args)
{
    if(!GetConVarBool(cvarDevelopMode))
    {
        CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Developer mode MUST be enabled to use this command!");
        return Plugin_Handled;
    }

    if(args!=3)
    {
        if(args!=2)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Usage: ff2_setcharge or hale_setcharge <target> <slot> <percent>");
        }
        else 
        {
            if(!IsValidClient(client))
            {
                ReplyToCommand(client, "[FF2 DEV] Command can only be used in-game!");
                return Plugin_Handled;
            }
            
            if(!IsBoss(client) || !IsPlayerAlive(client) || CheckRoundState()!=FF2RoundState_RoundRunning)
            {
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} You must be a boss to give yourself RAGE!");
                return Plugin_Handled;
            }
            
            new String:ragePCT[80], String:slotCharge[10];
            GetCmdArg(1, slotCharge, sizeof(slotCharge));
            GetCmdArg(2, ragePCT, sizeof(ragePCT));
            new Float:rageMeter=StringToFloat(ragePCT);
            new abilitySlot=StringToInt(slotCharge);
            
            if(!abilitySlot || abilitySlot<=7)
            {
                BossCharge[Boss[client]][abilitySlot]+=rageMeter;
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Slot %i's charge: %i percent (added %i percent)!", abilitySlot, RoundFloat(BossCharge[Boss[client]][abilitySlot]), RoundFloat(rageMeter));
                LogAction(client, client, "\"%L\" gave themselves %i charge to slot %i", client, RoundFloat(rageMeter), abilitySlot);
            }
            else
            {
                CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Invalid slot!");            
            }
        }
        return Plugin_Handled;
    }
    
    new String:ragePCT[80], String:slotCharge[10];
    new String:targetName[PLATFORM_MAX_PATH];
    GetCmdArg(1, targetName, sizeof(targetName));
    GetCmdArg(2, slotCharge, sizeof(slotCharge));
    GetCmdArg(3, ragePCT, sizeof(ragePCT));
    new Float:rageMeter=StringToFloat(ragePCT);
    new abilitySlot=StringToInt(slotCharge);
            
    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;
    
    if((target_count=ProcessTargetString(targetName, client, target_list, MaxClients, 0, target_name, sizeof(target_name), tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    for(new target; target<target_count; target++)
    {
        if(IsClientSourceTV(target_list[target]) || IsClientReplay(target_list[target]))
        {
            continue;
        }
        
        if(!IsBoss(target_list[target]) || !IsPlayerAlive(target_list[target]) || CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} %s must be a boss to add RAGE!", target_name);
            return Plugin_Handled;
        }
        
        if(!abilitySlot || abilitySlot<=7)
        {
            BossCharge[Boss[target_list[target]]][abilitySlot]+=rageMeter;
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} %s's ability slot %i's charge: %i percent (added %i percent)!", target_name, abilitySlot, RoundFloat(BossCharge[Boss[target_list[target]]][abilitySlot]), RoundFloat(rageMeter));
            LogAction(client, target_list[target], "\"%L\" gave \"%L\" %i charge to slot %i", client, target_list[target], RoundFloat(rageMeter), abilitySlot);
        }
        else
        {
            CReplyToCommand(client, "{red}[{green}FF2 DEV{red}]{default} Invalid slot!");            
        }
    }
    return Plugin_Handled;
}
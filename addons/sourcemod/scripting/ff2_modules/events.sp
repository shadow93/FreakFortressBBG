// events

public Action:Event_Broadcast(Handle:event, const String:name[], bool:dontBroadcast)
{
    new String:strAudio[PLATFORM_MAX_PATH];
    GetEventString(event, "sound", strAudio, sizeof(strAudio));
    if(strncmp(strAudio, "Game.Your", 9) == 0 || strcmp(strAudio, "Game.Stalemate") == 0)
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action:Event_Destroy(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(Enabled)
    {
        new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
        if(!GetRandomInt(0, 2) && IsBoss(attacker))
        {
            new String:sound[PLATFORM_MAX_PATH];
            if(RandomSound("sound_kill_buildable", sound, sizeof(sound)) || FindSound("kill_buildable", sound, sizeof(sound)))
            {
                EmitSoundToAll(sound);
                EmitSoundToAll(sound);
            }
        }
    }
    return Plugin_Continue;
}

public Action Event_Uber(Event event, const char[] name, bool dontBroadcast)
{
    int healer=GetClientOfUserId(event.GetInt("userid"));
    if(!Enabled || !IsValidClient(healer))
        return Plugin_Continue;
    
    if(IsPlayerAlive(healer))
    {
        int medigun=GetPlayerWeaponSlot(healer, TFWeaponSlot_Secondary);
        if(IsValidEntity(medigun))
        {
            char classname[64];
            GetEdictClassname(medigun, classname, sizeof(classname));
            if(!StrContains(classname, "tf_weapon_medigun", false))
            {
                TF2_AddCondition(healer, TFCond_HalloweenCritCandy, 0.5, healer);
                int target=GetHealingTarget(healer);
                if(IsValidClient(target, true))
                {
                    TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, healer);
                    uberTarget[healer]=target;                
                }
                else
                {
                    uberTarget[healer]=-1;
                }
                CreateTimer(0.05, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    
    }
    return Plugin_Continue;
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(CheckRoundState()==FF2RoundState_RoundRunning)
    {
        CheckAlivePlayersAt=GetEngineTime()+0.1;
    }
}

public Action:OnRPS(Handle:event, const String:eventName[], bool:dontBroadcast)
{
    new winner = GetEventInt(event, "winner");
    new loser = GetEventInt(event, "loser");
    
    if(!IsValidClient(winner) || !IsValidClient(loser)) // Check for valid clients
    {
        return;
    }

    if(!IsBoss(winner) && IsBoss(loser) && GetBossIndex(loser)>=0) // Boss Loses on RPS? Kill current boss.
    {
        RPSWinner=winner;
        KillRPSLosingBossAt[loser]=GetEngineTime()+3.1;
        return;
    }
    
    if(!IsBoss(winner) && !IsBoss(loser) && GetClientQueuePoints(loser)>=GetConVarInt(cvarRPSQueuePoints) &&  GetConVarInt(cvarRPSQueuePoints)>0) // Teammate or Minion loses? Gamble for Queue Points
    {
        CPrintToChat(winner, "{olive}[FF2]{default} %t", "rps_won", GetConVarInt(cvarRPSQueuePoints), loser);
        SetClientQueuePoints(winner, GetClientQueuePoints(winner)+GetConVarInt(cvarRPSQueuePoints));

        CPrintToChat(loser, "{olive}[FF2]{default} %t", "rps_lost", GetConVarInt(cvarRPSQueuePoints), winner);
        SetClientQueuePoints(loser, GetClientQueuePoints(loser)-GetConVarInt(cvarRPSQueuePoints));
    }
}

public Action:Event_StartCapture(Handle:event, const String:eventName[], bool:dontBroadcast)
{
    if(useCPvalue)
    {
        capTeam=GetEventInt(event, "capteam");
        return;
    }

    if(!isCapping && GetEventInt(event, "capteam")>1)
    {    
        isCapping=true;
    }
}

public Action:Event_BreakCapture(Handle:event, const String:eventName[], bool:dontBroadcast)
{
    if(!GetEventFloat(event, "time_remaining") && isCapping)
    {
        capTeam=0;
        isCapping=false;
    }
}

public Action:Event_PlayerDeath(Handle:event, const String:eventName[], bool:dontBroadcast)
{
    if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        return Plugin_Continue;
    }
    
    if(!isCosmetic)
    {

        new client=GetClientOfUserId(GetEventInt(event, "userid")), attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
        new String:sound[PLATFORM_MAX_PATH];
        CheckAlivePlayersAt=GetEngineTime()+0.1;
        DoOverlay(client, "");
        
        if(GetClientTeam(client)==BossTeam && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
        {
            TF2_RemoveAllWeapons(client); // Prevent dropping a boss weapon
        }
        
        if(!IsBoss(client))
        {
            if(!attacker && DeadRunMode && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
            {    
                SetEventInt(event,"attacker",GetClientUserId(drboss));
            }
    
            if(!(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
            {
                airstab[client]=0;
                GoombaCount[client]=0;
                CreateTimer(1.0, Timer_Damage, GetClientUserId(client));
            }

            if(IsBoss(attacker))
            {
                new boss=GetBossIndex(attacker);
                if(firstBlood)  //TF_DEATHFLAG_FIRSTBLOOD is broken
                {
                    if(RandomSound("sound_first_blood", sound, sizeof(sound), boss) || FindSound("first_blood", sound, sizeof(sound), boss))
                    {
                        EmitSoundToAll(sound);
                        EmitSoundToAll(sound);
                    }
                    firstBlood=false;
                }

                if(GetRandomInt(0, 1) && RandomSound("sound_hit", sound, sizeof(sound), boss))
                {
                    EmitSoundToAll(sound);
                    EmitSoundToAll(sound);
                }
                else if(!GetRandomInt(0, 2))  //1/3 chance for "sound_kill_<class>"
                {
                    new String:classnames[][]={"", "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer"};
                    decl String:class[32], String:class2[32];
                    Format(class, sizeof(class), "sound_kill_%s", classnames[TF2_GetPlayerClass(client)]);
                    Format(class2, sizeof(class2), "kill_%s", classnames[TF2_GetPlayerClass(client)]);
                    if(RandomSound(class, sound, sizeof(sound), boss) || FindSound(class2, sound, sizeof(sound), boss))
                    {
                        EmitSoundToAll(sound);
                        EmitSoundToAll(sound);
                    }
                }

                GetGameTime()<=KSpreeTimer[boss] ? (KSpreeCount[boss]+=1) : (KSpreeCount[boss]=1);  //Breaks if you do ++ or remove the parentheses...
                if(KSpreeCount[boss]==3)
                {
                    if(RandomSound("sound_kspree", sound, sizeof(sound), boss) || FindSound("kspree", sound, sizeof(sound), boss))
                    {
                        EmitSoundToAll(sound);
                        EmitSoundToAll(sound);
                    }
                    KSpreeCount[boss]=0;
                }
                else
                {
                    KSpreeTimer[boss]=GetGameTime()+5.0;
                }
                
                if(!IsFakeClient(client))
                {
                    bossKills[attacker]++;
                }
            }
        }
        else
        {
            new boss=GetBossIndex(client);
            if(boss==-1 || (GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
            {
                return Plugin_Continue;
            }    

            if(RandomSound("sound_death", sound, sizeof(sound), boss) || FindSound("death", sound, sizeof(sound), boss))
            {
                EmitSoundToAll(sound);
                EmitSoundToAll(sound);
            }
            if(!IsFakeClient(attacker))
            {
                bossesSlain[attacker]++;
            }
            bossDeaths[client]++;
            BossHealth[boss]=0;
            UpdateHealthBar();

            Stabbed[boss]=0.0;
            Marketed[boss]=0.0;
        }

        if(TF2_GetPlayerClass(client)==TFClass_Engineer && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
        {
            new String:name[PLATFORM_MAX_PATH];
            FakeClientCommand(client, "destroy 2");
            for(new entity=MaxClients+1; entity<MaxEntities; entity++)
            {
                if(IsValidEdict(entity))
                {
                    GetEdictClassname(entity, name, sizeof(name));
                    if(!StrContains(name, "obj_sentrygun") && (GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client))
                    {
                        SetVariantInt(GetEntPropEnt(entity, Prop_Send, "m_iMaxHealth")+1);
                        AcceptEntityInput(entity, "RemoveHealth");

                        new Handle:eventRemoveObject=CreateEvent("object_removed", true);
                        SetEventInt(eventRemoveObject, "userid", GetClientUserId(client));
                        SetEventInt(eventRemoveObject, "index", entity);
                        FireEvent(eventRemoveObject);
                        AcceptEntityInput(entity, "kill");
                    }
                }
            }
        }
    }
    else
    {
        isCosmetic=false;
    }
    return Plugin_Continue;
}

public Action:Event_Deflect(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!Enabled || GetEventInt(event, "weaponid"))  //0 means that the client was airblasted, which is what we want
    {
        return Plugin_Continue;
    }

    new boss=GetBossIndex(GetClientOfUserId(GetEventInt(event, "ownerid")));
    if(boss!=-1 && BossCharge[boss][0]<100.0)
    {
        BossCharge[boss][0]+=7.0;  //TODO: Allow this to be customizable
        if(BossCharge[boss][0]>100.0)
        {
            BossCharge[boss][0]=100.0;
        }
    }
    return Plugin_Continue;
}

public Action:Event_DeployBanner(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(Enabled && GetEventInt(event, "buff_type")==2)
    {
        FF2Flags[GetClientOfUserId(GetEventInt(event, "buff_owner"))]|=FF2FLAG_ISBUFFED;
    }
    return Plugin_Continue;
}

public Action:Event_RocketJump(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(Enabled)
    {
        if(StrEqual(name, "rocket_jump", false))
        {
            FF2Flags[GetClientOfUserId(GetEventInt(event, "userid"))]|=FF2FLAG_ROCKET_JUMPING;
        }
        else
        {
            FF2Flags[GetClientOfUserId(GetEventInt(event, "userid"))]&=~FF2FLAG_ROCKET_JUMPING;
        }
    }
    return Plugin_Continue;
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        return Plugin_Continue;
    }

    new client=GetClientOfUserId(GetEventInt(event, "userid"));
    new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
    new boss=GetBossIndex(client);
    new damage=GetEventInt(event, "damageamount");
    
    if(boss==-1 || !Boss[boss] || !IsValidEdict(Boss[boss]) || client==attacker)
    {
        return Plugin_Continue;
    }

    if(GetEventBool(event, "minicrit") && GetEventBool(event, "allseecrit"))
    {
        SetEventBool(event, "allseecrit", false);
    }

    BossHealth[boss]-=damage;
    return Plugin_Continue;
}

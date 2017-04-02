// sdk hooks
public Action:OnTakeDamageAlive(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
    if(!Enabled || !IsValidEdict(attacker))
    {
        return Plugin_Continue;
    }

    if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
    {
        return Plugin_Continue;
    }

    if(!CheckRoundState() && IsBoss(client))
    {
        return Plugin_Handled;
    }
    
    if(IsBoss(client) && (attacker==client))
    {
        if(damagetype & DMG_BLAST)
        {
            return Plugin_Continue;
        }
        return Plugin_Handled;
    }
    
    float position[3];
    GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);
    
    if(IsValidClient(attacker) && TF2_GetClientTeam(attacker)==TFTeam:BossTeam && shield[client] && damage>0) // Absorbs damage from bosses AND minions
    {
        if(!(damagetype & DMG_CLUB) && shieldHP[client]>0.0 && RoundToFloor(damage)<GetClientHealth(client))
        {
            damage*=shDmgReduction[client]; // damage resistance on shield
            
            shieldHP[client]-=damage;        // take a small portion of shield health away    
            
            if(shDmgReduction[client]>=1.0)
            {
                shDmgReduction[client]=1.0;
            }
            else
            {
                shDmgReduction[client]+=0.02;
            }
                        
            new String:ric[PLATFORM_MAX_PATH];
            Format(ric, sizeof(ric), "weapons/fx/rics/ric%i.wav", GetRandomInt(1,5));
            EmitSoundToClient(client, ric, _, _, _, _, 0.7, _, _, position, _, false);
            EmitSoundToClient(attacker, ric, _, _, _, _, 0.7, _, _, position, _, false);
            return Plugin_Changed;
        }
        else
        {
            StripShield(client, attacker, position);
            return Plugin_Stop;                    
        }
    }
    
    if(IsBoss(attacker))
    {
        if(IsValidClient(client) && !IsBoss(client) && !TF2_IsPlayerInCondition(client, TFCond_Bonked))
        {
            if(damagecustom == TF_CUSTOM_BOOTS_STOMP)
            {
                damage = float(GetClientHealth(client));
                return Plugin_Changed;
            }        

            if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
            {
                ScaleVector(damageForce, 9.0);
                damage*=0.3;
                return Plugin_Changed;
            }

            if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
            {
                damage*=9;
                TF2_AddCondition(client, TFCond_Bonked, 0.1);  //In other words, no damage is actually taken
                return Plugin_Changed;
            }

            if(TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
            {
                damage*=0.25;
                return Plugin_Changed;

            }
            if(TF2_GetPlayerClass(client)==TFClass_Soldier && IsValidEdict((weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==226 && !(FF2Flags[client] & FF2FLAG_ISBUFFED))  //Battalion's Backup
            {
                SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
            }
        }
    }
    else
    {
        new boss=GetBossIndex(client);
        if(boss!=-1)
        {
            if(damagetype & DMG_FALL)
            {
                damage=1.0;
                return Plugin_Changed;
            }
            if(attacker<=MaxClients)
            {
                new bool:bChanged=false;
                #if defined _tf2attributes_included
                if(tf2attributes)
                {
                    if (!(damagetype & DMG_BLAST) && (GetEntityFlags(boss) & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))    //If Boss is ducking on the ground, it's harder to knock them back
                    {
                        damagetype |= DMG_PREVENT_PHYSICS_FORCE;
                        TF2Attrib_SetByName(boss, "damage force reduction", 0.0);
                        bChanged = true;
                    }
                    else
                    {
                        TF2Attrib_RemoveByName(boss, "damage force reduction");
                    }
                }
                else
                {
                    if ((GetEntityFlags(boss) & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))    
                    {
                        damagetype |= DMG_PREVENT_PHYSICS_FORCE;
                        bChanged = true;
                    }                        
                }
                #else
                // Does not protect against sentries or FaN, but does against miniguns and rockets
                if ((iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))    
                {
                    damagetype |= DMG_PREVENT_PHYSICS_FORCE;
                    bChanged = true;
                }
                #endif
            
                new index;
                decl String:classname[64];
                if(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients)
                {
                    GetEntityClassname(weapon, classname, sizeof(classname));
                    if(!StrContains(classname, "eyeball_boss"))  //Dang spell Monoculuses
                    {
                        index=-1;
                        Format(classname, sizeof(classname), "");
                    }
                    else
                    {
                        index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
                    }
                }
                else
                {
                    index=-1;
                    Format(classname, sizeof(classname), "");
                }
    
                //Sniper rifles aren't handled by the switch/case because of the amount of reskins there are
                if(!StrContains(classname, "tf_weapon_sniperrifle"))
                {
                    if(CheckRoundState()!=FF2RoundState_RoundEnd)
                    {
                        new Float:charge=(IsValidEntity(weapon) && weapon>MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
                        if(index==752)  //Hitman's Heatmaker
                        {
                            new Float:focus=10+(charge/10);
                            if(TF2_IsPlayerInCondition(attacker, TFCond_FocusBuff))
                            {
                                focus/=3;
                            }
                            new Float:rage=GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
                            SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage+focus>100) ? 100.0 : rage+focus);
                        }
                        else if(index!=230 && index!=402 && index!=526 && index!=30665)  //Sydney Sleeper, Bazaar Bargain, Machina, Shooting Star
                        {
                            new Float:time=(GlowTimer[boss]>10 ? 1.0 : 2.0);
                            time+=(GlowTimer[boss]>10 ? (GlowTimer[boss]>20 ? 1.0 : 2.0) : 4.0)*(charge/100.0);
                            EnableClientGlow(Boss[boss], time);
                            if(GlowTimer[boss]>30.0)
                            {
                                GlowTimer[boss]=30.0;
                            }
                        }

                        if(!(damagetype & DMG_CRIT) && !TF2_IsPlayerInCondition(attacker, TFCond_CritCola) && !TF2_IsPlayerInCondition(attacker, TFCond_Buffed))
                        {
                            if(index!=230 || BossCharge[boss][0]>90.0)  //Sydney Sleeper
                            {
                                damage*=3.0;
                            }
                            else
                            {
                                damage*=2.4;
                            }
                            return Plugin_Changed;
                        }
                    }
                }

                switch(index)
                {
                    case 61, 1006:  //Ambassador, Festive Ambassador
                    {
                        if(damagecustom==TF_CUSTOM_HEADSHOT)
                        {
                            damage=255.0;
                            return Plugin_Changed;
                        }
                    }
                    case 132, 266, 482, 1082:  //Eyelander, HHHH, Nessie's Nine Iron, Festive Eyelander
                    {
                        IncrementHeadCount(attacker);
                    }
                    case 214:  //Powerjack
                    {
                        new health=GetClientHealth(attacker);
                        new newhealth=health+50;
                        if(newhealth<=GetEntProp(attacker, Prop_Data, "m_iMaxHealth"))  //No overheal allowed
                        {
                            SetEntityHealth(attacker, newhealth);
                        }

                        if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
                        {
                            TF2_RemoveCondition(attacker, TFCond_OnFire);
                        }
                    }
                    case 310:  //Warrior's Spirit
                    {
                        new health=GetClientHealth(attacker);
                        new newhealth=health+50;
                        if(newhealth<=GetEntProp(attacker, Prop_Data, "m_iMaxHealth"))  //No overheal allowed
                        {
                            SetEntityHealth(attacker, newhealth);
                        }

                        if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
                        {
                            TF2_RemoveCondition(attacker, TFCond_OnFire);
                        }
                    }
                    case 317:  //Candycane
                    {
                        SpawnSmallHealthPackAt(client, TF2_GetClientTeam(attacker));
                    }
                    case 327:  //Claidheamh Mòr
                    {
                        new health=GetClientHealth(attacker);
                        new newhealth=health+25;
                        if(newhealth<=GetEntProp(attacker, Prop_Data, "m_iMaxHealth"))  //No overheal allowed
                        {
                            SetEntityHealth(attacker, newhealth);
                        }

                        if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
                        {
                            TF2_RemoveCondition(attacker, TFCond_OnFire);
                        }

                        new Float:charge=GetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter");
                        if(charge+25.0>=100.0)
                        {
                            SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", 100.0);
                        }
                        else
                        {
                            SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", charge+25.0);
                        }
                    }
                    case 355:  //Fan O' War
                    {
                        if(BossCharge[boss][0]>0.0)
                        {
                            BossCharge[boss][0]-=5.0;
                            if(BossCharge[boss][0]<0.0)
                            {
                                BossCharge[boss][0]=0.0;
                            }
                        }
                    }
                    case 357:  //Half-Zatoichi
                    {
                        SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
                        if(GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy")<1)
                        {
                            SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
                        }

                        new health=GetClientHealth(attacker);
                        new max=GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
                        new newhealth=health+50;
                        if(health<max+100)
                        {
                            if(newhealth>max+100)
                            {
                                newhealth=max+100;
                            }
                            SetEntityHealth(attacker, newhealth);
                        }

                        if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
                        {
                            TF2_RemoveCondition(attacker, TFCond_OnFire);
                        }
                    }
                    case 307, 416:   // Chdata's Market Gardener backstab + VoIDeD's Caber backstab
                    {
                        if (RemoveCond(attacker, TFCond_BlastJumping)) // New way to check explosive jumping status
                        {
                            if(index == 307 && GetEntProp(weapon, Prop_Send, "m_iDetonated") == 1) // If using ullapool caber, only trigger if bomb hasn't been detonated
                                return Plugin_Continue;
                        
                            damage=(Pow(float(BossHealthMax[boss]), 0.74074)+512.0-(Marketed[client]/128.0*float(BossHealthMax[boss])))/3.0;
                            damagetype |= DMG_CRIT;
                            
                            if (RemoveCond(attacker, TFCond_Parachute))   // If you parachuted to do this, remove your parachute.
                            {
                                damage *= 0.67;                       //  And nerf your damage
                            }

                            if(Marketed[client]<5)
                            {
                                Marketed[client]++;
                            }
                            
                            if(index==307)
                            {
                                SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
                                SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
                            }
                            
                            airstab[attacker]++;
                            
                            isCosmetic=true;
                            new Handle:hStreak = CreateEvent("player_death", true);
                            SetEventString(hStreak,"weapon", index==307 ? "ullapool_caber_explosion" : "market_gardener");
                            SetEventString(hStreak,"weapon_logclassname", index==307 ? "ullapool_caber_explosion" : "market_gardener");
                            SetEventInt(hStreak,"attacker",GetClientUserId(attacker));
                            SetEventInt(hStreak,"userid",GetClientUserId(client));
                            SetEventInt(hStreak, "death_flags", TF_DEATHFLAG_DEADRINGER);
                            SetEventInt(hStreak, "kill_streak_wep", airstab[attacker]);
                            FireEvent(hStreak);

                            new String:spcl[768];
                            GetBossSpecial(boss, spcl, sizeof(spcl), 0);
                            
                            CreateAttachedAnnotation(attacker, client, true, 5.0, "%t", index == 416 ? "Market Gardener" : "Ullapool Caber", spcl);  //You just market-gardened the boss!
                            CreateAttachedAnnotation(client, attacker, true, 5.0, "%t", index == 416 ? "Market Gardened" : "Ullapool Cabered", attacker);  //You just got market-gardened!

                            EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);
                            EmitSoundToClient(client, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);

                            return Plugin_Changed;
                        }
                    }
                    case 525, 595:  //Diamondback, Manmelter
                    {
                        if(GetEntProp(attacker, Prop_Send, "m_iRevengeCrits"))  //If a revenge crit was used, give a damage bonus
                        {
                            damage=255.0;
                            return Plugin_Changed;
                        }
                    }
                    case 528:  //Short Circuit
                    {
                        if(circuitStun)
                        {
                            if(!TF2_IsPlayerInCondition(client, TFCond_Dazed))
                            {
                                TF2_StunPlayer(client, circuitStun, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
                                SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+circuitStun+1.5);
                                SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+circuitStun+1.5);
                            }
                        }
                    }
                    case 593:  //Third Degree
                    {
                        new healers[MAXPLAYERS];
                        new healerCount;
                        for(new healer; healer<=MaxClients; healer++)
                        {
                            if(IsValidClient(healer) && IsPlayerAlive(healer) && (GetHealingTarget(healer, true)==attacker))
                            {
                                healers[healerCount]=healer;
                                healerCount++;
                            }
                        }

                        for(new healer; healer<healerCount; healer++)
                        {
                            if(IsValidClient(healers[healer]) && IsPlayerAlive(healers[healer]))
                            {
                                new medigun=GetPlayerWeaponSlot(healers[healer], TFWeaponSlot_Secondary);
                                if(IsValidEntity(medigun))
                                {
                                    decl String:medigunClassname[64];
                                    GetEdictClassname(medigun, medigunClassname, sizeof(medigunClassname));
                                    if(StrEqual(medigunClassname, "tf_weapon_medigun", false))
                                    {
                                        new Float:uber=GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+(0.1/healerCount);
                                        new Float:max=1.0;
                                        if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
                                        {
                                            max=1.5;
                                        }

                                        if(uber>max)
                                        {
                                            uber=max;
                                        }
                                        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", uber);
                                    }
                                }
                            }
                        }
                    }
                    case 594:  //Phlogistinator
                    {
                        if(!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
                        {
                            damage/=2.0;
                            return Plugin_Changed;
                        }
                    }
                    case 1099:  //Tide Turner
                    {
                        SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", 100.0);
                    }
                    case 1104:
                    {
                        static Float:airStrikeDamage;
                        airStrikeDamage+=damage;
                        if(airStrikeDamage>=200.0)
                        {
                            SetEntProp(attacker, Prop_Send, "m_iDecapitations", GetEntProp(attacker, Prop_Send, "m_iDecapitations")+1);
                            airStrikeDamage-=200.0;
                        }
                    }
                }

                static Float:kStreakCount;
                kStreakCount+=damage;
                if(kStreakCount>=GetConVarFloat(cvarDmg2KStreak))
                {
                    SetEntProp(attacker, Prop_Send, "m_nStreaks", GetEntProp(attacker, Prop_Send, "m_nStreaks")+1);
                    switch(GetEntProp(attacker, Prop_Send, "m_nStreaks"))
                    {
                        case 5,10,15,20,25,50,75,100,150,200,250,500,750,1000:
                        {
                            isCosmetic=true;
                            new Handle:hStreak = CreateEvent("player_death", true);
                            SetEventInt(hStreak,"attacker",GetClientUserId(attacker));
                            SetEventInt(hStreak,"userid",GetClientUserId(client));
                            SetEventInt(hStreak, "death_flags", TF_DEATHFLAG_DEADRINGER);
                            SetEventInt(hStreak, "kill_streak_wep", GetEntProp(attacker, Prop_Send, "m_nStreaks"));
                            SetEventInt(hStreak, "kill_streak_total", GetEntProp(attacker, Prop_Send, "m_nStreaks"));
                            FireEvent(hStreak);
                        }
                    }
                    kStreakCount-=GetConVarFloat(cvarDmg2KStreak);
                }

                if(damagecustom==TF_CUSTOM_BACKSTAB)
                {
                    damage=BossHealthMax[boss]*(LastBossIndex()+1)*BossLivesMax[boss]*(0.12-Stabbed[boss]/90);
                    damagetype|=DMG_CRIT;
                    damagecustom=0;

                    EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
                    EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
                    EmitSoundToClient(client, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
                    EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
                    SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
                    SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+2.0);
                    SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+2.0);

                    new viewmodel=GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
                    if(viewmodel>MaxClients && IsValidEntity(viewmodel) && TF2_GetPlayerClass(attacker)==TFClass_Spy)
                    {
                        new melee=GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
                        new animation=41;
                        switch(melee)
                        {
                            case 225, 356, 423, 461, 574, 649, 1071:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan
                            {
                                animation=15;
                            }
                            case 638:  //Sharp Dresser
                            {
                                animation=31;
                            }
                        }
                        SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
                    }

                    if(!(FF2Flags[attacker] & FF2FLAG_HUDDISABLED))
                    {
                        new String:spcl[768];
                        GetBossSpecial(boss, spcl, sizeof(spcl), 0);
                        CreateAttachedAnnotation(attacker, client, true, 5.0, "%t", "Backstab", spcl);
                    }

                    if(!(FF2Flags[client] & FF2FLAG_HUDDISABLED))
                    {
                        CreateAttachedAnnotation(client, attacker, true, 5.0, "%t", "Backstabbed", attacker);
                    }

                    if(index==225 || index==574)  //Your Eternal Reward, Wanga Prick
                    {
                        CreateTimer(0.3, Timer_DisguiseBackstab, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
                    }
                    else if(index==356)  //Conniver's Kunai
                    {
                        new health=GetClientHealth(attacker)+200;
                        if(health>500)
                        {
                            health=500;
                        }
                        SetEntityHealth(attacker, health);
                    }
                    else if(index==461)  //Big Earner
                    {
                        SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);  //Full cloak
                        TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 3.0);  //Speed boost
                    }

                    if(GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary)==525)  //Diamondback
                    {
                        SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", GetEntProp(attacker, Prop_Send, "m_iRevengeCrits")+2);
                    }

                    decl String:sound[PLATFORM_MAX_PATH];
                    if(RandomSound("sound_stabbed", sound, sizeof(sound), boss) || FindSound("stabbed", sound, sizeof(sound), boss))
                    {
                        EmitSoundToAllExcept(SoundException_BossVoice, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
                        EmitSoundToAllExcept(SoundException_BossVoice, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
                    }

                    if(Stabbed[boss]<3)
                    {
                        Stabbed[boss]++;
                    }
                    return Plugin_Changed;
                }
                else if(damagecustom==TF_CUSTOM_TELEFRAG)
                {
                    damagecustom=0;
                    if(!IsPlayerAlive(attacker))
                    {
                        damage=1.0;
                        return Plugin_Changed;
                    }
                    damage=(BossHealth[boss]>9001 ? 9001.0 : float(GetEntProp(Boss[boss], Prop_Send, "m_iHealth"))+90.0);

                    new teleowner=FindTeleOwner(attacker);
                    if(IsValidClient(teleowner) && teleowner!=attacker)
                    {
                        char spcl[768];
                        GetBossSpecial(boss, spcl, sizeof(spcl), 0);
                        CreateAttachedAnnotation(teleowner, attacker, true, 5.0, "%t", "Telefrag Assist", attacker, spcl);
                    }

                    if(!(FF2Flags[attacker] & FF2FLAG_HUDDISABLED))
                    {
                        char spcl[768];
                        GetBossSpecial(boss, spcl, sizeof(spcl), 0);
                        CreateAttachedAnnotation(attacker, client, true, 5.0, "%t", "Telefrag", spcl);
                    }

                    if(!(FF2Flags[client] & FF2FLAG_HUDDISABLED))
                    {
                        CreateAttachedAnnotation(client, attacker, true, 5.0, "%t", "Telefragged", attacker);
                    }
                    return Plugin_Changed;
                }
                else if(damagecustom==TF_CUSTOM_BOOTS_STOMP)
                {
                    damage*=5;
                    return Plugin_Changed;
                }
                
                if (bChanged)
                {
                    return Plugin_Changed;
                }
            }
            else
            {
                decl String:classname[64];
                if(GetEdictClassname(attacker, classname, sizeof(classname)) && StrEqual(classname, "trigger_hurt", false))
                {
                    static Float:damageToTele;
                    damageToTele+=damage;
                    if (bSpawnTeleOnTriggerHurt && IsBoss(client) && CheckRoundState()==FF2RoundState_RoundRunning && damageToTele>=GetConVarFloat(cvarDamageToTele))
                    {
                        // Teleport the boss back to one of the spawns.
                        // And during the first 30 seconds, they can only teleport to their own spawn.
                        TeleportToMultiMapSpawn(client, (MapBlackListed) ? (TFTeam_Unassigned) : (RoundTick<30) ? (TFTeam:BossTeam) : (TFTeam_Unassigned));
                        damageToTele-=GetConVarFloat(cvarDamageToTele);
                    }
                    
                    new Action:action;
                    Call_StartForward(OnTriggerHurt);
                    Call_PushCell(boss);
                    Call_PushCell(attacker);
                    new Float:damage2=damage;
                    Call_PushFloatRef(damage2);
                    Call_Finish(action);
                    if(action!=Plugin_Stop && action!=Plugin_Handled)
                    {
                        if(action==Plugin_Changed)
                        {
                            damage=damage2;
                        }

                        if(damage>1500.0)
                        {
                            damage=1500.0;
                        }

                        if(StrEqual(currentmap, "arena_arakawa_b3", false) && damage>1000.0)
                        {
                            damage=490.0;
                        }
                        BossHealth[boss]-=RoundFloat(damage);
                        BossCharge[boss][0]+=damage*100.0/BossRageDamage[boss];
                        if(BossHealth[boss]<=0)  //TODO: Wat
                        {
                            damage*=5;
                        }

                        if(BossCharge[boss][0]>100.0)
                        {
                            BossCharge[boss][0]=100.0;
                        }
                        return Plugin_Changed;
                    }
                    else
                    {
                        return action;
                    }
                }
            }

            if(BossCharge[boss][0]>100.0)
            {
                BossCharge[boss][0]=100.0;
            }
        }
        else
        {
            new index=(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
            if(index==307)  //Ullapool Caber
            {
                if(detonations[attacker]<allowedDetonations)
                {
                    detonations[attacker]++;
                    CreateAttachedAnnotation(attacker, client, true, 5.0, "%t", "Detonations Left", allowedDetonations-detonations[attacker]);
 
                    if(allowedDetonations-detonations[attacker])  //Don't reset their caber if they have 0 detonations left
                    {
                        SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
                        SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
                    }
                }
            }

            if(IsValidClient(client, false) && TF2_GetPlayerClass(client)==TFClass_Soldier)  //TODO: Wat
            {
                if(damagetype & DMG_FALL)
                {
                    new secondary=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
                    if(secondary<=0 || !IsValidEntity(secondary))
                    {
                        damage/=10.0;
                        return Plugin_Changed;
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}

public OnTakeDamageAlivePost(client, attacker, inflictor, Float:damageFloat, damagetype)
{
    if(Enabled && IsBoss(client))
    {
        new boss=GetBossIndex(client);
        new damage=RoundFloat(damageFloat);
        for(new lives=1; lives<BossLives[boss]; lives++)
        {
            if(BossHealth[boss]-damage<=BossHealthMax[boss]*lives)
            {
                SetEntityHealth(client, (BossHealth[boss]-damage)-BossHealthMax[boss]*(lives-1));  //Set the health early to avoid the boss dying from fire, etc.

                new Action:action, bossLives=BossLives[boss];  //Used for the forward
                Call_StartForward(OnLoseLife);
                Call_PushCell(boss);
                Call_PushCellRef(bossLives);
                Call_PushCell(BossLivesMax[boss]);
                Call_Finish(action);
                if(action==Plugin_Stop || action==Plugin_Handled)  //Don't allow any damage to be taken and also don't let the life-loss go through
                {
                    SetEntityHealth(client, BossHealth[boss]);
                    return;
                }
                else if(action==Plugin_Changed)
                {
                    if(bossLives>BossLivesMax[boss])  //If the new amount of lives is greater than the max, set the max to the new amount
                    {
                        BossLivesMax[boss]=bossLives;
                    }
                    BossLives[boss]=lives=bossLives;
                }

                decl String:ability[PLATFORM_MAX_PATH], String:abilityName[64], String:pluginName[64], String:stringLives[MaxAbilities][3];
                //FIXME: Create a new variable for the translation string later on
                if(FF2ClientDifficulty[client]<FF2Difficulty_Lunatic)
                {
                    // v1 abilities
                    for(new n=1; n<MaxAbilities; n++)
                    {
                        Format(ability, 10, "ability%i", n);
                        KvRewind(BossKV[characterIdx[boss]]);
                        if(KvJumpToKey(BossKV[characterIdx[boss]], ability))
                        {
                            if(KvGetNum(BossKV[characterIdx[boss]], "arg0", 0)!=-1)
                            {
                                continue;
                            }

                            KvGetString(BossKV[characterIdx[boss]], "life", ability, 10);
                            if(!ability[0])
                            {
                                KvGetString(BossKV[characterIdx[boss]], "plugin_name", pluginName, sizeof(pluginName));
                                KvGetString(BossKV[characterIdx[boss]], "name", abilityName, sizeof(abilityName));
                                UseAbility(boss, pluginName, abilityName, -1);
                            }
                            else
                            {
                                new count=ExplodeString(ability, " ", stringLives, MaxAbilities, 3);
                                for(new j; j<count; j++)
                                {
                                    if(StringToInt(stringLives[j])==BossLives[boss])
                                    {
                                        KvGetString(BossKV[characterIdx[boss]], "plugin_name", pluginName, sizeof(pluginName));
                                        KvGetString(BossKV[characterIdx[boss]], "name", abilityName, sizeof(abilityName));
                                        UseAbility(boss, pluginName, abilityName, -1);
                                        break;
                                    }
                                }
                            }
                        }
                    }
            
                    // v2 abilities
                    KvRewind(BossKV[characterIdx[boss]]);
                    if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities"))
                    {
                        while(KvGotoNextKey(BossKV[characterIdx[boss]]))
                        {
                            KvGetSectionName(BossKV[characterIdx[boss]], pluginName, sizeof(pluginName));
                            KvJumpToKey(BossKV[characterIdx[boss]], pluginName);
                            while(KvGotoNextKey(BossKV[characterIdx[boss]]))
                            {
                                KvGetSectionName(BossKV[characterIdx[boss]], abilityName, sizeof(abilityName));
                                KvJumpToKey(BossKV[characterIdx[boss]], abilityName);
                                if(KvGetNum(BossKV[characterIdx[boss]], "slot", 0)!=-1)
                                {
                                    continue;
                                }
                                KvGetString(BossKV[characterIdx[boss]], "life", ability, 10, "");
                                if(!ability[0])
                                {
                                    UseAbility2(boss, pluginName, abilityName, -1);
                                }
                                else
                                {
                                    new count=ExplodeString(ability, " ", stringLives, MaxAbilities, 3);
                                    for(new n; n<count; n++)
                                    {
                                        if(StringToInt(stringLives[n])==BossLives[boss])
                                        {
                                            UseAbility2(boss, pluginName, abilityName, -1);
                                            KvGoBack(BossKV[characterIdx[boss]]);
                                            break;
                                        }
                                    }
                                }
                                KvGoBack(BossKV[characterIdx[boss]]);
                            }
                            KvGoBack(BossKV[characterIdx[boss]]);
                        }
                    }
                }
                BossLives[boss]=lives;

                decl String:bossName[64];
                KvRewind(BossKV[characterIdx[boss]]);
                KvGetString(BossKV[characterIdx[boss]], "name", bossName, sizeof(bossName), "=Failed name=");

                strcopy(ability, sizeof(ability), BossLives[boss]==1 ? "Last Life" : "Lost Life");
                for(new target=1; target<=MaxClients; target++)
                {
                    if(IsValidClient(target) && !(FF2Flags[target] & FF2FLAG_HUDDISABLED))
                    {
                        CreateAttachedAnnotation(target, client, true, 5.0, "%t", ability, bossName, BossLives[boss]);
                    }
                }

                if(BossLives[boss]==1 && (RandomSound("sound_last_life", ability, sizeof(ability), boss) || FindSound("last_life", ability, sizeof(ability), boss)))
                {
                    EmitSoundToAll(ability);
                    EmitSoundToAll(ability);
                }
                else if(RandomSound("sound_nextlife", ability, sizeof(ability), boss) || FindSound("nextlife", ability, sizeof(ability), boss))
                {
                    EmitSoundToAll(ability);
                    EmitSoundToAll(ability);
                }

                UpdateHealthBar();
                break;
            }
        }
        
        if(attacker != client && !IsClientInvincible(client))
        {
            BossCharge[boss][0]+=damage*100.0/BossRageDamage[boss];
        }
        Damage[attacker]+=damage;

        new healers[MaxClients+1];
        new healerCount;
        for(new target; target<=MaxClients; target++)
        {
            if(IsValidClient(target) && IsPlayerAlive(target) && (GetHealingTarget(target, true)==attacker))
            {
                healers[healerCount]=target;
                healerCount++;
            }
        }

        for(new target; target<healerCount; target++)
        {
            if(IsValidClient(healers[target]) && IsPlayerAlive(healers[target]))
            {
                if(damage<10 || uberTarget[healers[target]]==attacker)
                {
                    Damage[healers[target]]+=damage;
                }
                else
                {
                    Damage[healers[target]]+=damage/(healerCount+1);
                }
            }
        }

        if(BossCharge[boss][0]>100.0)
        {
            BossCharge[boss][0]=100.0;
        }
        UpdateHealthBar();
    }
}

public Action:OnGetMaxHealth(client, &maxHealth)
{
    if(Enabled && IsBoss(client))
    {
        new boss=GetBossIndex(client);
        SetEntityHealth(client, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1));
        maxHealth=BossHealthMax[boss];
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

public void Client_PreThink(int client)
{
    if(!Enabled)
        return;
        
    if(!IsValidClient(client))
    {
        SDKUnhook(client, SDKHook_PreThink, Client_PreThink);
    }
        
    Timers_PreThink(client, GetEngineTime());
}

public OnEntityCreated(entity, const String:classname[])
{
    if(GetConVarBool(cvarHealthBar))
    {
        if(StrEqual(classname, HEALTHBAR_CLASS))
        {
            healthBar=entity;
        }

        if(!IsValidEntity(g_Monoculus) && StrEqual(classname, MONOCULUS))
        {
            g_Monoculus=entity;
        }
    }
    
    if(StrContains(classname, "item_healthkit")!=-1 || StrContains(classname, "item_ammopack")!=-1 || StrEqual(classname, "tf_ammo_pack"))
    {
        SDKHook(entity, SDKHook_Spawn, OnItemSpawned);
    }

}

public OnEntityDestroyed(entity)
{
    if(entity==g_Monoculus)
    {
        g_Monoculus=FindEntityByClassname(-1, MONOCULUS);
        if(g_Monoculus==entity)
        {
            g_Monoculus=FindEntityByClassname(entity, MONOCULUS);
        }
    }
}

public OnItemSpawned(entity)
{
    SDKHook(entity, SDKHook_StartTouch, OnPickup);
    SDKHook(entity, SDKHook_Touch, OnPickup);
}

public OnPreThinkPost(client)
{
    if(IsNearDispenser(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
    {
        new Float:cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
        if (cloak<0.0)
            cloak=0.0;
        SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
    }
}

public Action:OnPickup(entity, client)  //Thanks friagram!
{
    if(IsBoss(client))
    {
        new String:classname[32];
        GetEntityClassname(entity, classname, sizeof(classname));        
        if(!StrContains(classname, "item_healthkit") && !(FF2Flags[client] & FF2FLAG_ALLOW_HEALTH_PICKUPS))
        {
            return Plugin_Handled;
        }
        else if((!StrContains(classname, "item_ammopack") || StrEqual(classname, "tf_ammo_pack")) && !(FF2Flags[client] & FF2FLAG_ALLOW_AMMO_PICKUPS))
        {
            return Plugin_Handled;
        }
        return Plugin_Continue;
    }
    return Plugin_Continue;
}
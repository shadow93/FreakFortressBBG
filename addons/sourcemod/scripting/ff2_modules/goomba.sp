#undef REQUIRE_PLUGIN
#tryinclude <goomba>
#define REQUIRE_PLUGIN

#if defined _goomba_included
bool goomba=false;
#endif

public void FindGoomba()
{
    #if defined _goomba_included
    goomba=LibraryExists("goomba");
    #endif
}

public void OnGoombaLoaded(const char[] name)
{
    #if defined _goomba_included
    if(!strcmp(name, "goomba", false))
    {
        goomba=true;
    }
    #endif
}

public void OnGoombaRemoved(const char[] name)
{
    #if defined _goomba_included
    if(!strcmp(name, "goomba", false))
    {
        goomba=false;
    }
    #endif
}

public Action OnStomp(int attacker, int victim, float &damageMultiplier, float &damageBonus, float &JumpPower)
{
    if(!Enabled || !IsValidClient(attacker) || !IsValidClient(victim) || attacker==victim)
    {
        return Plugin_Continue;
    }
    
    if(TF2_GetClientTeam(attacker)==TFTeam:BossTeam) // Protect goombas from bosses AND minions
    {
        if(shield[victim])
        {
            float position[3];
            GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);

            StripShield(victim, attacker, position);
            return Plugin_Stop;
        }
    
        if(IsBoss(attacker))
        {
            int boss = GetBossIndex(attacker);
            char spcl[768];
            GetBossSpecial(boss, spcl, sizeof(spcl), 0);
        
            damageMultiplier=900.0;
            JumpPower=0.0;
        
            CreateAttachedAnnotation(attacker, victim, true, 5.0, "%t", "Boss Goomba Stomps", victim);
            CreateAttachedAnnotation(victim, attacker, true, 5.0, "%t","Goomba Stomped Player", spcl);

            UpdateHealthBar();
            return Plugin_Changed;
        }
    }
    
    if(IsBoss(victim))
    {
    
        int boss = GetBossIndex(victim);
        char spcl[768];
        GetBossSpecial(boss, spcl, sizeof(spcl), 0);
        
        GoombaCount[attacker]++;
        
        isCosmetic=true;
        Event hStreak = CreateEvent("player_death", true);
        hStreak.SetString("weapon", "mantreads");
        hStreak.SetString("weapon_logclassname", "mantreads");
        hStreak.SetInt("attacker",GetClientUserId(attacker));
        hStreak.SetInt("userid",GetClientUserId(victim));
        hStreak.SetInt("death_flags", TF_DEATHFLAG_DEADRINGER);
        hStreak.SetInt("kill_streak_wep", GoombaCount[attacker]);
        hStreak.Fire();

        damageMultiplier=GoombaDamage;
        JumpPower=reboundPower;
        
        CreateAttachedAnnotation(attacker, victim, true, 5.0, "%t", "Player Goomba Stomps", spcl, GoombaCount[attacker]);
        CreateAttachedAnnotation(victim, attacker, true, 5.0, "%t", "Goomba Stomped Boss", attacker, GoombaCount[attacker]);
        
        UpdateHealthBar();
        return Plugin_Changed;
    }
    return Plugin_Continue;
}
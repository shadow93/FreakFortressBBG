// Healthbar

void FindHealthBar()
{
    healthBar=FindEntityByClassname(-1, HEALTHBAR_CLASS);
    if(!IsValidEntity(healthBar))
    {
        healthBar=CreateEntityByName(HEALTHBAR_CLASS);
    }
}

public void HealthbarEnableChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(Enabled && GetConVarBool(cvarHealthBar) && IsValidEntity(healthBar))
    {
        UpdateHealthBar();
    }
    else if(!IsValidEntity(g_Monoculus) && IsValidEntity(healthBar))
    {
        SetEntProp(healthBar, Prop_Send, HEALTHBAR_PROPERTY, 0);
    }
}

void UpdateHealthBar()
{
    if(!Enabled || !GetConVarBool(cvarHealthBar) || IsValidEntity(g_Monoculus) || CheckRoundState()==FF2RoundState_Loading)
    {
        return;
    }
    
    if(!IsValidEntity(healthBar))
    {
        healthBar=CreateEntityByName(HEALTHBAR_CLASS);
    }

    int healthAmount, maxHealthAmount, bosses, healthPercent;
    for(int client; client<=MaxClients; client++)
    {
        if(IsValidClient(Boss[client], true))
        {
            bosses++;
            healthAmount+=BossHealth[client]-BossHealthMax[client]*(BossLives[client]-1);
            maxHealthAmount+=BossHealthMax[client];
        }
    }

    if(bosses)
    {
        healthPercent=RoundToCeil(float(healthAmount)/float(maxHealthAmount)*float(HEALTHBAR_MAX));
        if(healthPercent>HEALTHBAR_MAX)
        {
            healthPercent=HEALTHBAR_MAX;
        }
        else if(healthPercent<=0)
        {
            healthPercent=1;
        }
    }
    SetEntProp(healthBar, Prop_Send, HEALTHBAR_PROPERTY, healthPercent);
}
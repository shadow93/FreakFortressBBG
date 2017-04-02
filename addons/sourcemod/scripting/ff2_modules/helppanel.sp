// Help panel
public Action:HelpPanel3Cmd(client, args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }

    HelpPanel3(client);
    return Plugin_Handled;
}

public Action:HelpPanel3(client)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    new Handle:panel=CreatePanel();
    SetPanelTitle(panel, "Turn the Freak Fortress 2 class info...");
    DrawPanelItem(panel, "On");
    DrawPanelItem(panel, "Off");
    SendPanelToClient(panel, client, ClassinfoTogglePanelH, MENU_TIME_FOREVER);
    CloseHandle(panel);
    return Plugin_Handled;
}

public ClassinfoTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
    if(IsValidClient(param1))
    {
        if(action==MenuAction_Select)
        {

            if(param2==2)
                SetClientSetting(param1, FF2Cookie[Cookie_DisplayInfo], _, FF2Setting_Disabled, true);
            else
                SetClientSetting(param1, FF2Cookie[Cookie_DisplayInfo], _, FF2Setting_Enabled, true);
        }
    }
}

public Action:Command_HelpPanelClass(client, args)
{
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }

    HelpPanelClass(client);
    return Plugin_Handled;
}

public Action:HelpPanelClass(client)
{
    if(!Enabled)
    {
        return Plugin_Continue;
    }

    new boss=GetBossIndex(client);
    if(boss!=-1)
    {
        HelpPanelBoss(boss);
        return Plugin_Continue;
    }

    new String:text[512];
    new TFClassType:class=TF2_GetPlayerClass(client);
    SetGlobalTransTarget(client);
    switch(class)
    {
        case TFClass_Scout:
        {
            Format(text, sizeof(text), "%t", "help_scout");
        }
        case TFClass_Soldier:
        {
            Format(text, sizeof(text), "%t", "help_soldier");
        }
        case TFClass_Pyro:
        {
            Format(text, sizeof(text), "%t", "help_pyro");
        }
        case TFClass_DemoMan:
        {
            Format(text, sizeof(text), "%t", "help_demo");
        }
        case TFClass_Heavy:
        {
            Format(text, sizeof(text), "%t", "help_heavy");
        }
        case TFClass_Engineer:
        {
            Format(text, sizeof(text), "%t", "help_eggineer");
        }
        case TFClass_Medic:
        {
            Format(text, sizeof(text), "%t", "help_medic");
        }
        case TFClass_Sniper:
        {
            Format(text, sizeof(text), "%t", "help_sniper");
        }
        case TFClass_Spy:
        {
            Format(text, sizeof(text), "%t", "help_spie");
        }
        default:
        {
            Format(text, sizeof(text), "");
        }
    }

    if(class!=TFClass_Sniper)
    {
        Format(text, sizeof(text), "%t\n%s", "help_melee", text);
    }

    new Handle:panel=CreatePanel();
    SetPanelTitle(panel, text);
    DrawPanelItem(panel, "Exit");
    SendPanelToClient(panel, client, HintPanelH, 20);
    CloseHandle(panel);
    return Plugin_Continue;
}

HelpPanelBoss(boss)
{
    if(!IsValidClient(Boss[boss]))
    {
        return;
    }

    new String:text[512], String:language[20];
    GetLanguageInfo(GetClientLanguage(Boss[boss]), language, 8, text, 8);
    Format(language, sizeof(language), "description_%s", language);

    KvRewind(BossKV[characterIdx[boss]]);
    //KvSetEscapeSequences(BossKV[characterIdx[boss]], true);  //Not working
    KvGetString(BossKV[characterIdx[boss]], language, text, sizeof(text));
    if(!text[0])
    {
        KvGetString(BossKV[characterIdx[boss]], "description_en", text, sizeof(text));  //Default to English if their language isn't available
        if(!text[0])
        {
            return;
        }
    }
    ReplaceString(text, sizeof(text), "\\n", "\n");
    //KvSetEscapeSequences(BossKV[characterIdx[boss]], false);  //We don't want to interfere with the download paths

    new Handle:panel=CreatePanel();
    SetPanelTitle(panel, text);
    DrawPanelItem(panel, "Exit");
    SendPanelToClient(panel, Boss[boss], HintPanelH, 20);
    CloseHandle(panel);
}

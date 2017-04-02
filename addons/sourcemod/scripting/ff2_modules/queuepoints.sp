// queue points

public QueuePanelH(Handle:menu, MenuAction:action, client, selection)
{
    if(action==MenuAction_Select && selection==10)
    {
        TurnToZeroPanel(client, client);
    }
    return false;
}


public Action:QueuePanelCmd(client, args)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    new String:text[64];
    new items;
    new bool:added[MaxClients+1];

    new Handle:panel=CreatePanel();
    SetGlobalTransTarget(client);
    Format(text, sizeof(text), "%t", "thequeue");  //"Boss Queue"
    SetPanelTitle(panel, text);
    for(new boss; boss<=MaxClients; boss++)  //Add the current bosses to the top of the list
    {
        if(IsBoss(boss))
        {
            added[boss]=true;  //Don't want the bosses to show up again in the actual queue list
            Format(text, sizeof(text), "%N-%i", boss, GetClientQueuePoints(boss));
            DrawPanelItem(panel, text);
            items++;
        }
    }

    DrawPanelText(panel, "---");
    do
    {
        new target=GetClientWithMostQueuePoints(added);  //Get whoever has the highest queue points out of those who haven't been listed yet
        if(!IsValidClient(target))  //When there's no players left, fill up the rest of the list with blank lines
        {
            DrawPanelItem(panel, "");
            items++;
            continue;
        }

        Format(text, sizeof(text), "%N-%i", target, GetClientQueuePoints(target));
        if(client!=target)
        {
            DrawPanelItem(panel, text);
            items++;
        }
        else
        {
            DrawPanelText(panel, text);  //DrawPanelText() is white, which allows the client's points to stand out
        }
        added[target]=true;
    }
    while(items<9);

    Format(text, sizeof(text), "%t (%t)", "your_points", GetClientQueuePoints(client), "to0");  //"Your queue point(s) is {1} (set to 0)"
    DrawPanelItem(panel, text);

    SendPanelToClient(panel, client, QueuePanelH, MENU_TIME_FOREVER);
    CloseHandle(panel);
    return Plugin_Handled;
}

public Action:ResetQueuePointsCmd(client, args)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    if(client && !args)  //Normal players
    {
        TurnToZeroPanel(client, client);
        return Plugin_Handled;
    }

    if(!client)  //No confirmation for console
    {
        TurnToZeroPanelH(INVALID_HANDLE, MenuAction_Select, client, 1);
        return Plugin_Handled;
    }

    new AdminId:admin=GetUserAdmin(client);     //Normal players
    if((admin==INVALID_ADMIN_ID) || !GetAdminFlag(admin, Admin_Cheats))
    {
        TurnToZeroPanel(client, client);
        return Plugin_Handled;
    }

    if(args!=1)  //Admins
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_resetqueuepoints <target>");
        return Plugin_Handled;
    }

    new String:targetname[MAX_TARGET_LENGTH];
    GetCmdArg(1, targetname, MAX_TARGET_LENGTH);
    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[1], target_count;
    new bool:tn_is_ml;

    if((target_count=ProcessTargetString(targetname, client, target_list, 1, 0, target_name, MAX_TARGET_LENGTH, tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }
    TurnToZeroPanel(client, target_list[0]);
    return Plugin_Handled;
}

public TurnToZeroPanelH(Handle:menu, MenuAction:action, client, position)
{
    if(action==MenuAction_Select && position==1)
    {
        if(shortname[client]==client)
        {
            CPrintToChat(client,"{olive}[FF2]{default} %t", "to0_done");
        }
        else
        {
            CPrintToChat(client, "{olive}[FF2]{default} %t", "to0_done_admin", shortname[client]);
            CPrintToChat(shortname[client], "{olive}[FF2]{default} %t", "to0_done_by_admin", client);
        }
        SetClientQueuePoints(shortname[client], 0);
    }
}

public Action:TurnToZeroPanel(caller, client)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    new Handle:panel=CreatePanel();
    new String:text[512];
    SetGlobalTransTarget(caller);
    if(caller==client)
    {
        Format(text, 512, "%t", "to0_title");
    }
    else
    {
        Format(text, 512, "%t", "to0_title_admin", client);
    }

    PrintToChat(caller, text);
    SetPanelTitle(panel, text);
    Format(text, 512, "%t", "Yes");
    DrawPanelItem(panel, text);
    Format(text, 512, "%t", "No");
    DrawPanelItem(panel, text);
    shortname[caller]=client;
    SendPanelToClient(panel, caller, TurnToZeroPanelH, MENU_TIME_FOREVER);
    CloseHandle(panel);
    return Plugin_Handled;
}


GetClientQueuePoints(client)
{
    if(!IsValidClient(client) || !AreClientCookiesCached(client))
    {
        return 0;
    }

    if(IsFakeClient(client))
    {
        return botqueuepoints;
    }
    
    char value[64];
    GetClientCookie(client, FF2Cookie[Cookie_QueuePoints], value, sizeof(value));
    return StringToInt(value);
}

void SetClientQueuePoints(int client, int points)
{
    if(IsValidClient(client) && !IsFakeClient(client) && AreClientCookiesCached(client))
    {
        char value[64];
        IntToString(points, value, sizeof(value));
        SetClientCookie(client, FF2Cookie[Cookie_QueuePoints], value);
    }
}

public int SortQueueDesc(int[] x, int[] y, int[][] array, Handle data)
{
    if (x[1] > y[1]) 
        return -1;
    else if (x[1] < y[1]) 
        return 1;    
    return 0;
}

stock CalcQueuePoints()
{
    new damage;
    botqueuepoints+=5;
    new add_points[MAXPLAYERS+1];
    new add_points2[MAXPLAYERS+1];
    for(new client=1; client<=MaxClients; client++)
    {
        if(BossCookieSetting[client]==FF2Setting_Disabled) // Do not give queue points to those who have ff2 bosses disabled
            continue;
        if(IsValidClient(client))
        {
            damage=Damage[client];
            new Handle:event=CreateEvent("player_escort_score", true);
            SetEventInt(event, "player", client);

            new points;
            while(damage-600>0)
            {
                damage-=600;
                points++;
            }
            SetEventInt(event, "points", points);
            FireEvent(event);

            if(IsBoss(client) && GetBossIndex(client)==0)
            {
                if(IsFakeClient(client))
                {
                    botqueuepoints=0;
                }
                if(IsFakeClient(client))
                {
                    botqueuepoints=0;
                }
                else
                {
                    add_points[client]=-GetClientQueuePoints(client);
                    add_points2[client]=add_points[client];
                }
            }
            else if(!IsFakeClient(client) && (GetClientTeam(client)>_:TFTeam_Spectator))
            {
                if(damage>0 && !DeadRunMode)
                {
                    add_points[client]=10+points;
                    add_points2[client]=10+points;
                }
                if(DeadRunMode)
                {
                    add_points[client]=10;
                    add_points2[client]=10;                    
                }
            }
        }
    }

    new Action:action=Plugin_Continue;
    Call_StartForward(OnAddQueuePoints);
    Call_PushArrayEx(add_points2, MAXPLAYERS+1, SM_PARAM_COPYBACK);
    Call_Finish(action);
    switch(action)
    {
        case Plugin_Stop, Plugin_Handled:
        {
            return;
        }
        case Plugin_Changed:
        {
            for(new client=1; client<=MaxClients; client++)
            {
                if(IsValidClient(client))
                {
                    if(add_points2[client]>0)
                    {
                        CPrintToChat(client, "{olive}[FF2]{default} %t", "add_points", add_points2[client]);
                    }
                    SetClientQueuePoints(client, GetClientQueuePoints(client)+add_points2[client]);
                }
            }
        }
        default:
        {
            for(new client=1; client<=MaxClients; client++)
            {
                if(IsValidClient(client))
                {
                    if(add_points[client]>0)
                    {
                        CPrintToChat(client, "{olive}[FF2]{default} %t", "add_points", add_points[client]);
                    }
                    SetClientQueuePoints(client, GetClientQueuePoints(client)+add_points[client]);
                }
            }
        }
    }
}

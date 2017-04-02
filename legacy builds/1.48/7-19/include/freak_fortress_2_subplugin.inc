new String:this_plugin_name[80];

GetThisPluginName()
{
	decl String:pluginName[80];
	GetPluginFilename(INVALID_HANDLE, pluginName, 80);
	if(StrContains(pluginName, ".ff2", false)!=-1)
	{
		ReplaceString(pluginName, 80, ".ff2", "", false);
	}
	if(StrContains(pluginName, ".smx", false)!=-1)
	{
		ReplaceString(pluginName, 80, ".smx", "", false);
	}
	new forwardSlash=-1;
	new backwardSlash=-1;
	new finalPluginName=-1;
	for(;;)
	{
		forwardSlash=StrContains(pluginName[finalPluginName+1], "/");
		backwardSlash=StrContains(pluginName[finalPluginName+1], "\\");
		if((backwardSlash<forwardSlash && backwardSlash!=-1) || forwardSlash==-1)
		{
			if(backwardSlash==-1)
			{
				break;
			}
			finalPluginName=backwardSlash;
		}
		else if((forwardSlash<backwardSlash && forwardSlash!=-1) || backwardSlash==-1)
		{
			if(forwardSlash==-1)
			{
				break;
			}
			finalPluginName=forwardSlash;
		}
	}
	strcopy(this_plugin_name, sizeof(this_plugin_name), pluginName[finalPluginName+1]);
}

public OnPluginStart()
{
	OnPluginStart2();
	GetThisPluginName();
}

#if !defined FF2_V2
public Action:FF2_OnAbility(client, const String:plugin_name[], const String:ability_name[], status)
{
	if(plugin_name[0])
	{
		if(strcmp(this_plugin_name, plugin_name))
		{
			return;
		}
	}
	FF2_OnAbility2(client, plugin_name, ability_name, status);
}
#else
#if defined SHADOW93_FORK
public FF2_OnUseAbility(client, const String:plugin_name[], const String:ability_name[], slot, status)
#else
public FF2_OnAbility(client, const String:plugin_name[], const String:ability_name[], slot, status)
#endif
{
	if(plugin_name[0])
	{
		if(!StrEqual(this_plugin_name, plugin_name))
		{
			return;
		}
	}
	FF2_OnAbility2(client, plugin_name, ability_name, slot, status);
}
#endif

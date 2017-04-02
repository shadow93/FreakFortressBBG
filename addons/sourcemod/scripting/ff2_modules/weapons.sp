Handle kvWeaponMods=null;

public bool CacheWeapons()
{
    char config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, WeaponCFG);
    
    if(!FileExists(config))
    {
        LogToFile(eLog, "[FF2] Freak Fortress 2 disabled-can not find '%s'!", WeaponCFG);
        return false;
    }
    
    kvWeaponMods = CreateKeyValues("Weapons");
    if(!FileToKeyValues(kvWeaponMods, config))
    {
        LogToFile(eLog, "[FF2] Freak Fortress 2 disabled-'%s' is improperly formatted!", WeaponCFG);
        return false;
    }
	
    return true;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname,int iItemDefinitionIndex, Handle &item)
{
    if(!Enabled || !IsValidClient(client))
    {
        return Plugin_Continue;
    }
    
    bool SwordCanCountHeads=false;
    switch(iItemDefinitionIndex)
    {
        // Reverting some Valve weapon changes:
        case 132, 266, 482, 1082:
        {
            SwordCanCountHeads=true;
            return Plugin_Continue;
        }
        case 405, 608:  //Ali Baba's Wee Booties, Bootlegger
        {
            Handle itemOverride=PrepareItemHandle(item, _, _, !SwordCanCountHeads ? "259 ; 1" : "26 ; 25 ; 246 ; 2 ; 259 ; 1 ; 2034 ; 1.25", !SwordCanCountHeads ? false : true);
                //259: Deal 3x fall damage
                //If Headtaker, Nine Iron or Eyelander is equipped, nerf move speed bonus
            if(itemOverride!=null)
            {
                item=itemOverride;
                return Plugin_Changed;
            }        
        }
        case 444:  //Mantreads
        {
            #if defined _tf2attributes_included
            if(tf2attributes)
            {
                TF2Attrib_SetByDefIndex(client, 58, 1.5);
            }
            #endif
        }
    }

    if(kvWeaponMods == null)
    {
        LogToFile(eLog,"[FF2] Critical Error! Unable to configure weapons from '%s!", WeaponCFG);
    }
    else
    {    
        char weapon[64], wepIndexStr[768], wepIndexSkipStr[768], attributes[768];
        for(int i=1; ; i++)
        {
            KvRewind(kvWeaponMods);
            Format(weapon, 10, "weapon%i", i);
            if(KvJumpToKey(kvWeaponMods, weapon))
            {
                int isOverride=KvGetNum(kvWeaponMods, "mode");
                KvGetString(kvWeaponMods, "classname", weapon, sizeof(weapon));
                KvGetString(kvWeaponMods, "index", wepIndexStr, sizeof(wepIndexStr));
                KvGetString(kvWeaponMods, "skip", wepIndexSkipStr, sizeof(wepIndexSkipStr));
                KvGetString(kvWeaponMods, "attributes", attributes, sizeof(attributes));
                if(isOverride)
                {
                    if(IsOverrideByClassName(wepIndexStr, classname, weapon))
                    {
                        LogToFile(eLog,"[FF2] Found override by classname (%s)", classname);
                        
                        if(wepIndexSkipStr[0])
                        {
                            int wepIndex;
                            char wepIndexes[768][256];
                            int weaponIdxcount = ExplodeString(wepIndexSkipStr, " ; ", wepIndexes, sizeof(wepIndexes), 32);
                            for (int wepIdx = 0; wepIdx<=weaponIdxcount ; wepIdx++)
                            {
                                if(strlen(wepIndexes[wepIdx])>0)
                                {
                                    wepIndex = StringToInt(wepIndexes[wepIdx]);
                                    if(iItemDefinitionIndex == wepIndex)
                                    {
                                        return Plugin_Continue;
                                    }
                                }
                            }
                        }
                        
                        switch(isOverride)
                        {
                            case 3: return Plugin_Stop;
                            case 2,1:
                            {
                                Handle itemOverride=PrepareItemHandle(item, _, _, attributes, isOverride==1 ? false : true);
                                if(itemOverride!=null)
                                {
                                    item=itemOverride;
                                    return Plugin_Changed;
                                }
                            }
                        }
                    }
                    else
                    {                        
                        int wepIndex;
                        char wepIndexes[768][256];
                        int weaponIdxcount = ExplodeString(wepIndexStr, " ; ", wepIndexes, sizeof(wepIndexes), 32);
                        for (int wepIdx = 0; wepIdx<=weaponIdxcount ; wepIdx++)
                        {
                            if(strlen(wepIndexes[wepIdx])>0)
                            {
                                wepIndex = StringToInt(wepIndexes[wepIdx]);
                                if(iItemDefinitionIndex == wepIndex)
                                {
                                    LogToFile(eLog,"[FF2] Found override by item index (%s)", iItemDefinitionIndex);
                                    switch(isOverride)
                                    {
                                        case 3: return Plugin_Stop;                   
                                        case 2,1:
                                        {
                                            Handle itemOverride=PrepareItemHandle(item, _, _, attributes, isOverride==1 ? false : true);
                                            if(itemOverride!=null)
                                            {
                                                item=itemOverride;
                                                return Plugin_Changed;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }    
            }
            else
            {
                break;
            }
        }
        KvGoBack(kvWeaponMods);
    }
    return Plugin_Continue;
}

stock bool IsOverrideByClassName(const char[] index, const char[] classname, const char[] weapon)
{
    if(StrEqual(index, "-2", false) && !StrContains(classname, weapon, false)) return true;
    if(StrEqual(index, "-1", false) && StrEqual(classname, weapon, false)) return true;
    return false;
}

stock Handle PrepareItemHandle(Handle item, char[] name="", int index=-1, const char[] att="", bool dontPreserve=false)
{
    static Handle weapon;
    int addattribs;

    char weaponAttribsArray[32][32];
    int attribCount=ExplodeString(att, ";", weaponAttribsArray, 32, 32);

    if(attribCount % 2)
    {
        --attribCount;
    }

    int flags=OVERRIDE_ATTRIBUTES;
    if(!dontPreserve)
    {
        flags|=PRESERVE_ATTRIBUTES;
    }

    if(weapon==INVALID_HANDLE)
    {
        weapon=TF2Items_CreateItem(flags);
    }
    else
    {
        TF2Items_SetFlags(weapon, flags);
    }
    //Handle weapon=TF2Items_CreateItem(flags);  //INVALID_HANDLE;  Going to uncomment this since this is what Randomizer does

    if(item!=null)
    {
        addattribs=TF2Items_GetNumAttributes(item);
        if(addattribs>0)
        {
            for(int i; i<2*addattribs; i+=2)
            {
                bool dontAdd=false;
                int attribIndex=TF2Items_GetAttributeId(item, i);
                for(int z; z<attribCount+i; z+=2)
                {
                    if(StringToInt(weaponAttribsArray[z])==attribIndex)
                    {
                        dontAdd=true;
                        break;
                    }
                }

                if(!dontAdd)
                {
                    IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
                    FloatToString(FF2x10 ? TF2Items_GetAttributeValue(item, i)*10 : TF2Items_GetAttributeValue(item, i), weaponAttribsArray[i+1+attribCount], 32);
                }
            }
            attribCount+=2*addattribs;
        }

        if(weapon!=item)  //FlaminSarge: Item might be equal to weapon, so closing item's handle would also close weapon's
        {
            CloseHandle(item);  //probably returns false but whatever (rswallen-apparently not)
        }
    }

    if(name[0]!='\0')
    {
        flags|=OVERRIDE_CLASSNAME;
        TF2Items_SetClassname(weapon, name);
    }

    if(index!=-1)
    {
        flags|=OVERRIDE_ITEM_DEF;
        TF2Items_SetItemIndex(weapon, index);
    }

    if(attribCount>0)
    {
        TF2Items_SetNumAttributes(weapon, attribCount/2);
        int i2;
        for(int i; i<attribCount && i2<16; i+=2)
        {
            int attrib=StringToInt(weaponAttribsArray[i]);
            if(!attrib)
            {
                LogError("Bad weapon attribute passed: %s ; %s", weaponAttribsArray[i], weaponAttribsArray[i+1]);
                CloseHandle(weapon);
                return INVALID_HANDLE;
            }

            TF2Items_SetAttribute(weapon, i2, StringToInt(weaponAttribsArray[i]), FF2x10 ? StringToFloat(weaponAttribsArray[i+1])*10.0 : StringToFloat(weaponAttribsArray[i+1]));
            i2++;
        }
    }
    else
    {
        TF2Items_SetNumAttributes(weapon, 0);
    }
    TF2Items_SetFlags(weapon, flags);
    return weapon;
}
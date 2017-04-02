// parser
enum Operators
{
    Operator_None=-1,
    Operator_Add,
    Operator_Subtract,
    Operator_Multiply,
    Operator_Divide,
    Operator_Exponent,
};


stock Operate(Handle:sumArray, &bracket, Float:value, Handle:_operator)
{
    new Float:sum=GetArrayCell(sumArray, bracket);
    switch(GetArrayCell(_operator, bracket))
    {        case Operator_Add:
        {
            SetArrayCell(sumArray, bracket, sum+value);
        }
        case Operator_Subtract:
        {
            SetArrayCell(sumArray, bracket, sum-value);
        }
        case Operator_Multiply:
        {
            SetArrayCell(sumArray, bracket, sum*value);
        }
        case Operator_Divide:
        {
            if(!value)
            {
                LogToFile(bLog, "[FF2 Bosses] Detected a divide by 0!");
                bracket=0;
                return;
            }
            SetArrayCell(sumArray, bracket, sum/value);
        }
        case Operator_Exponent:
        {
            SetArrayCell(sumArray, bracket, Pow(sum, value));
        }
        default:
        {
            SetArrayCell(sumArray, bracket, value);  //This means we're dealing with a constant
        }
    }
    SetArrayCell(_operator, bracket, Operator_None);
}

stock OperateString(Handle:sumArray, &bracket, String:value[], size, Handle:_operator)
{
    if(!StrEqual(value, ""))  //Make sure 'value' isn't blank
    {
        Operate(sumArray, bracket, StringToFloat(value), _operator);
        strcopy(value, size, "");
    }
}

stock ParseHealthFormula(client)
{
    new String:defFormula[1024];
    GetConVarString(cvarDefaultHealthFormula, defFormula, sizeof(defFormula));
    
    decl String:formula[1024], String:bossName[64];
    KvRewind(BossKV[characterIdx[client]]);
    KvGetString(BossKV[characterIdx[client]], "name", bossName, sizeof(bossName), "=Failed name=");
    KvGetString(BossKV[characterIdx[client]], "health_formula", formula, sizeof(formula));
    
    if(!formula[0])
    {
        formula=defFormula;
    }
    
    ReplaceString(formula, sizeof(formula), " ", "");  //Get rid of spaces    
    
    new size=1;
    new matchingBrackets;
    for(new i; i<=strlen(formula); i++)  //Resize the arrays once so we don't have to worry about it later on
    {
        if(formula[i]=='(')
        {
            if(!matchingBrackets)
            {
                size++;
            }
            else
            {
                matchingBrackets--;
            }
        }
        else if(formula[i]==')')
        {
            matchingBrackets++;
        }
    }

    new Handle:sumArray=CreateArray(_, size), Handle:_operator=CreateArray(_, size);
    new bracket;  //Each bracket denotes a separate sum (within parentheses).  At the end, they're all added together to achieve the actual sum
    SetArrayCell(sumArray, 0, 0.0);  //TODO:  See if these can be placed naturally in the loop
    SetArrayCell(_operator, bracket, Operator_None);

    new String:character[2], String:value[16];  //We don't decl value because we directly append characters to it and there's no point in decl'ing character
    for(new i; i<=strlen(formula); i++)
    {
        character[0]=formula[i];  //Find out what the next char in the formula is
        switch(character[0])
        {
            case ' ', '\t':  //Ignore whitespace
            {
                continue;
            }
            case '(':
            {
                bracket++;  //We've just entered a new parentheses so increment the bracket value
                SetArrayCell(sumArray, bracket, 0.0);
                SetArrayCell(_operator, bracket, Operator_None);
            }
            case ')':
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
                if(GetArrayCell(_operator, bracket)!=Operator_None)  //Something like (5*)
                {
                    LogToFile(bLog, "[FF2 Bosses] %s's %s formula has an invalid operator at character %i", bossName, formula, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return formula=defFormula;
                }

                if(--bracket<0)  //Something like (5))
                {
                    LogToFile(bLog, "[FF2 Bosses] %s's %s formula has an unbalanced parentheses at character %i", bossName, formula, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return formula=defFormula;
                }

                Operate(sumArray, bracket, GetArrayCell(sumArray, bracket+1), _operator);
            }
            case '\0':  //End of formula
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
            }
            case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.':
            {
                StrCat(value, sizeof(value), character);  //Constant?  Just add it to the current value
            }
            case 'n', 'x':  //n and x denote player variables
            {
                Operate(sumArray, bracket, float(playing), _operator);
            }
            case '+', '-', '*', '/', '^':
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
                switch(character[0])
                {
                    case '+':
                    {
                        SetArrayCell(_operator, bracket, Operator_Add);
                    }
                    case '-':
                    {
                        SetArrayCell(_operator, bracket, Operator_Subtract);
                    }
                    case '*':
                    {
                        SetArrayCell(_operator, bracket, Operator_Multiply);
                    }
                    case '/':
                    {
                        SetArrayCell(_operator, bracket, Operator_Divide);
                    }
                    case '^':
                    {
                        SetArrayCell(_operator, bracket, Operator_Exponent);
                    }
                }
            }
        }
    }
    
    new result=RoundFloat(GetArrayCell(sumArray, 0));
    CloseHandle(sumArray);
    CloseHandle(_operator);
    if(result<=0)
    {
        LogToFile(eLog,"[FF2] %s has an invalid %s formula, using default!", bossName, formula);
        return formula=defFormula;
    }

    if(FF2x10)
    {
        result*=10;
    }
    
    if(bMedieval)
    {
        RoundFloat(result/=GetConVarFloat(cvarMedievalDivider));
    }
    
    return result;
}


stock ParseFormula(boss, const String:key[], defaultValue)
{
    decl String:formula[1024], String:bossName[64];
    KvRewind(BossKV[characterIdx[boss]]);
    KvGetString(BossKV[characterIdx[boss]], "name", bossName, sizeof(bossName), "=Failed name=");
    KvGetString(BossKV[characterIdx[boss]], key, formula, sizeof(formula) );
    if(!formula[0])
    {
        return defaultValue;
    }

    new size=1;
    new matchingBrackets;
    for(new i; i<=strlen(formula); i++)  //Resize the arrays once so we don't have to worry about it later on
    {
        if(formula[i]=='(')
        {
            if(!matchingBrackets)
            {
                size++;
            }
            else
            {
                matchingBrackets--;
            }
        }
        else if(formula[i]==')')
        {
            matchingBrackets++;
        }
    }

    new Handle:sumArray=CreateArray(_, size), Handle:_operator=CreateArray(_, size);
    new bracket;  //Each bracket denotes a separate sum (within parentheses).  At the end, they're all added together to achieve the actual sum
    new bool:escapeCharacter;
    SetArrayCell(sumArray, 0, 0.0);  //TODO:  See if these can be placed naturally in the loop
    SetArrayCell(_operator, bracket, Operator_None);

    new String:currentSpecial[2], String:value[16], String:variable[16];  //We don't decl these because we directly append characters to them and there's no point in decl'ing currentCharacter
    for(new i; i<=strlen(formula); i++)
    {
        currentSpecial[0]=formula[i];  //Find out what the next char in the formula is
        switch(currentSpecial[0])
        {
            case ' ', '\t':  //Ignore whitespace
            {
                continue;
            }
            case '(':
            {
                bracket++;  //We've just entered a new parentheses so increment the bracket value
                SetArrayCell(sumArray, bracket, 0.0);
                SetArrayCell(_operator, bracket, Operator_None);
            }
            case ')':
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
                if(GetArrayCell(_operator, bracket)!=Operator_None)  //Something like (5*)
                {
                    LogError("[FF2 Bosses] %s's %s formula has an invalid operator at character %i", bossName, key, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return defaultValue;
                }

                if(--bracket<0)  //Something like (5))
                {
                    LogError("[FF2 Bosses] %s's %s formula has an unbalanced parentheses at character %i", bossName, key, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return defaultValue;
                }

                Operate(sumArray, bracket, GetArrayCell(sumArray, bracket+1), _operator);
            }
            case '\0':  //End of formula
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
            }
            case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.':
            {
                StrCat(value, sizeof(value), currentSpecial);  //Constant?  Just add it to the current value
            }
            /*case 'n', 'x':  //n and x denote player variables
            {
                Operate(sumArray, bracket, float(playing), _operator);
            }*/
            case '{':
            {
                escapeCharacter=true;
            }
            case '}':
            {
                if(!escapeCharacter)
                {
                    LogError("[FF2 Bosses] %s's %s formula has an invalid escape character at character %i", bossName, key, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return defaultValue;
                }
                escapeCharacter=false;

                if(StrEqual(value, "players", false))
                {
                    Operate(sumArray, bracket, float(playing), _operator);
                }
                else if(StrEqual(value, "health", false))
                {
                    Operate(sumArray, bracket, float(BossHealth[boss]), _operator);
                }
                else if(StrEqual(value, "lives", false))
                {
                    Operate(sumArray, bracket, float(BossLives[boss]), _operator);
                }
                else if(StrEqual(value, "speed", false) || StrEqual(key, "maxspeed"))
                {
                    Operate(sumArray, bracket, BossSpeed[boss], _operator);
                }
                else
                {
                    new Action:action, Float:variableValue;
                    Call_StartForward(OnParseUnknownVariable);
                    Call_PushString(variable);
                    Call_PushFloatRef(variableValue);
                    Call_Finish();

                    if(action==Plugin_Changed)
                    {
                        Operate(sumArray, bracket, variableValue, _operator);
                    }
                    else
                    {
                        LogError("[FF2 Bosses] %s's %s formula has an unknown variable %s", bossName, key, variable);
                        CloseHandle(sumArray);
                        CloseHandle(_operator);
                        return defaultValue;
                    }
                }
            }
            case '+', '-', '*', '/', '^':
            {
                OperateString(sumArray, bracket, value, sizeof(value), _operator);
                switch(currentSpecial[0])
                {
                    case '+':
                    {
                        SetArrayCell(_operator, bracket, Operator_Add);
                    }
                    case '-':
                    {
                        SetArrayCell(_operator, bracket, Operator_Subtract);
                    }
                    case '*':
                    {
                        SetArrayCell(_operator, bracket, Operator_Multiply);
                    }
                    case '/':
                    {
                        SetArrayCell(_operator, bracket, Operator_Divide);
                    }
                    case '^':
                    {
                        SetArrayCell(_operator, bracket, Operator_Exponent);
                    }
                }
            }
            default:
            {
                if(escapeCharacter)  //Absorb all the characters into 'variable' if we hit an escape character
                {
                    StrCat(variable, sizeof(variable), currentSpecial);
                }
                else
                {
                    LogError("[FF2 Bosses] %s's %s formula has an invalid character at character %i", bossName, key, i+1);
                    CloseHandle(sumArray);
                    CloseHandle(_operator);
                    return defaultValue;
                }
            }
        }
    }

    new result=RoundFloat(GetArrayCell(sumArray, 0));
    CloseHandle(sumArray);
    CloseHandle(_operator);
    if(result<=0)
    {
        LogError("[FF2] %s has an invalid %s formula, using default!", bossName, key);
        return defaultValue;
    }
    
    if(FF2x10 && (StrEqual(key, "health", false) || StrEqual(key, "rage_damage", false) || StrEqual(key, "ragedamage", false)))
    {
        result*=10;
    }
    
    if(StrEqual(key, "health", false) && bMedieval)
    {
        RoundFloat(result/=GetConVarFloat(cvarMedievalDivider));
    }
    
    return result;
}

stock float GetCompensationCount()
{
    if(TotalCompanions>0 && Companions<TotalCompanions) // Compensate for the lack of companions
    {
        if(!Companions && TotalCompanions==1)
        {
            return 2.0;
        }
        return float(TotalCompanions)/float(Companions);
    }
    return 1.0;
}
#define MAXLEN_CONFIG_VALUE 128

methodmap WeaponConfig < StringMap
{
	public WeaponConfig()
	{
		return view_as<WeaponConfig>(new StringMap());
	}
	public bool GetWeaponAttributes(int iItemIndex, char[] sAttrib, int iMaxLength)
	{
		int iLookupItemIndex = iItemIndex;
		for (;;)
		{
			char sItemIndex[MAXLEN_CONFIG_VALUE], sValue[MAXLEN_CONFIG_VALUE];
			IntToString(iLookupItemIndex, sItemIndex, sizeof(sItemIndex));
			if (this.GetString(sItemIndex, sValue, sizeof(sValue)))
			{
				TrimString(sValue);
				if (strncmp(sValue, "disabled", 8) == 0 || strncmp(sValue, "restricted", 10) == 0)
					return false;
				else if (strncmp(sValue, "prefab:", 7) == 0)
				{
					ReplaceString(sValue, sizeof(sValue), "prefab:", "");
					TrimString(sValue);
					int iNewItemIndex = StringToInt(sValue);
					if (iNewItemIndex > 0)
					{
						iLookupItemIndex = iNewItemIndex;
						continue;
					}
					return false;
				}
				strcopy(sAttrib, iMaxLength, sValue);
				return true;
			}
			return true;
		}
		//The compiler will bitch that the function should return a value, but this part is unreachable...
	}
	public Handle PrepareItemHandle(char[] classname, int index, int level, int quality)
	{
		char sAttrib[255];
		if (!this.GetWeaponAttributes(index, sAttrib, sizeof(sAttrib)))
			return PrepareItemHandle(classname, index, level, quality, sAttrib);
		return PrepareItemHandle(classname, index, level, quality, "");
	}
}

WeaponConfig configWeapon = null;

methodmap Config < StringMap
{
	public Config()
	{
		return view_as<Config>(new StringMap());
	}
	public void LoadSection(KeyValues kv, const char[] sectionName)
	{
		if(kv.JumpToKey(sectionName, false))
		{
			if(kv.GotoFirstSubKey(false))
			{
				char bufferName[MAXLEN_CONFIG_VALUE];
				char bufferValue[MAXLEN_CONFIG_VALUE];
				do
				{
					kv.GetSectionName(bufferName, sizeof(bufferName));
					kv.GetString(NULL_STRING, bufferValue, sizeof(bufferValue), "");
					if (strcmp(bufferValue, "") != 0)
						this.SetString(bufferName, bufferValue);
				}
				while(kv.GotoNextKey(false));
				kv.GoBack();
			}
			kv.GoBack();
		}
	}
	public void GetValueCvar(ConVar cvar, char sValue[MAXLEN_CONFIG_VALUE])
	{
		char cvarName[MAXLEN_CONFIG_VALUE];
		cvar.GetName(cvarName, sizeof(cvarName));
		if (!this.GetString(cvarName, sValue, sizeof(sValue)))
			cvar.GetString(sValue, sizeof(sValue));
	}
	public int LookupInt(ConVar cvar)
	{
		char sValue[MAXLEN_CONFIG_VALUE];
		this.GetValueCvar(cvar, sValue);
		return StringToInt(sValue);
	}
	public float LookupFloat(ConVar cvar)
	{
		char sValue[MAXLEN_CONFIG_VALUE];
		this.GetValueCvar(cvar, sValue);
		return StringToFloat(sValue);
	}
	public bool LookupBool(ConVar cvar)
	{
		char sValue[MAXLEN_CONFIG_VALUE];
		this.GetValueCvar(cvar, sValue);
		return (!!StringToInt(sValue));
	}
	public void LookupString(ConVar cvar, char sValue[MAXLEN_CONFIG_VALUE])
	{
		this.GetValueCvar(cvar, sValue);
	}
	public void Refresh()
	{
		this.Clear();
		configWeapon.Clear();
		
		char configPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, configPath, sizeof(configPath), "configs/vsh/vsh.cfg");
		if(!FileExists(configPath))
		{
			LogMessage("Failed to load vsh config file (file missing): %s!", configPath);
			return;
		}

		KeyValues kv = new KeyValues("Config");
		kv.SetEscapeSequences(true);

		if(!kv.ImportFromFile(configPath))
		{
			LogMessage("Failed to parse vsh config file: %s!", configPath);
			delete kv;
			return;
		}
		
		this.LoadSection(kv, "cvars");
		Config tempConfig = view_as<Config>(configWeapon);
		tempConfig.LoadSection(kv, "weapons");

		delete kv;
	}
}
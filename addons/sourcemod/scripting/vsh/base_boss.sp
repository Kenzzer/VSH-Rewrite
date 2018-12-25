static char g_sClientBossType[TF_MAXPLAYERS+1][64];
static char g_sClientRageMusic[TF_MAXPLAYERS+1][255];

static int g_iClientBossMaxHealth[TF_MAXPLAYERS+1];
static int g_iClientMaxRageDamage[TF_MAXPLAYERS+1];
static int g_iClientRageDamage[TF_MAXPLAYERS+1];

static float g_flClientBossBackStabDamage[TF_MAXPLAYERS+1];
static float g_flClientBossFallDamageCap[TF_MAXPLAYERS+1];
static float g_flClientBossEnvDamageCap[TF_MAXPLAYERS+1];
static float g_flClientBossMaxSpeed[TF_MAXPLAYERS+1];
static float g_flClientBossSpeedMult[TF_MAXPLAYERS+1];
static float g_flClientBossGlowTime[TF_MAXPLAYERS+1];
static float g_flClientBossRageMusicVolume[TF_MAXPLAYERS+1];
static float g_flClientBossRageLastTime[TF_MAXPLAYERS+1];

static bool g_bClientBossActive[TF_MAXPLAYERS+1];
static bool g_bClientBossIsMinion[TF_MAXPLAYERS+1];

static IAbility g_iClientBossAbility[TF_MAXPLAYERS+1][MAX_BOSS_ABILITY];

static Handle g_hClientBossModelTimer[TF_MAXPLAYERS+1];
static Handle g_hClientBossRageMusicFadeTime[TF_MAXPLAYERS+1];
static Handle g_hBossRageHud;

methodmap CBaseBoss
{
	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property float flSpeed
	{
		public get()
		{
			return g_flClientBossMaxSpeed[this.Index];
		}
		public set(float val)
		{
			g_flClientBossMaxSpeed[this.Index] = val;
		}
	}
	
	property float flFallDamageCap
	{
		public get()
		{
			return g_flClientBossFallDamageCap[this.Index];
		}
		public set(float val)
		{
			g_flClientBossFallDamageCap[this.Index] = val;
		}
	}
	
	property float flBackStabDamage
	{
		public get()
		{
			return g_flClientBossBackStabDamage[this.Index];
		}
		public set(float val)
		{
			g_flClientBossBackStabDamage[this.Index] = val;
		}
	}
	
	property float flEnvDamageCap
	{
		public get()
		{
			return g_flClientBossEnvDamageCap[this.Index];
		}
		public set(float val)
		{
			g_flClientBossEnvDamageCap[this.Index] = val;
		}
	}
	
	property float flSpeedMult
	{
		public get()
		{
			return g_flClientBossSpeedMult[this.Index];
		}
		public set(float val)
		{
			g_flClientBossSpeedMult[this.Index] = val;
		}
	}

	property float flGlowTime
	{
		public get()
		{
			return g_flClientBossGlowTime[this.Index];
		}
		public set(float val)
		{
			float time = GetGameTime()+val;
			if (time > g_flClientBossGlowTime[this.Index] || val == -1.0)
				g_flClientBossGlowTime[this.Index] = time;
		}
	}
	
	property float flRageLastTime
	{
		public get()
		{
			return g_flClientBossRageLastTime[this.Index];
		}
	}
	
	property int iMaxHealth
	{
		public get()
		{
			return g_iClientBossMaxHealth[this.Index];
		}
		public set(int val)
		{
			g_iClientBossMaxHealth[this.Index] = val;
		}
	}
	
	property int iHealth
	{
		public get()
		{
			return GetEntProp(this.Index, Prop_Send, "m_iHealth");
		}
		public set(int val)
		{
			SetEntProp(this.Index, Prop_Send, "m_iHealth", val);
		}
	}
	
	property int iMaxRageDamage
	{
		public get()
		{
			return g_iClientMaxRageDamage[this.Index];
		}
		public set(int val)
		{
			g_iClientMaxRageDamage[this.Index] = val;
		}
	}
	
	property int iRageDamage
	{
		public get()
		{
			return g_iClientRageDamage[this.Index];
		}
		public set(int val)
		{
			g_iClientRageDamage[this.Index] = val;
			if (g_iClientRageDamage[this.Index] > this.iMaxRageDamage*2) g_iClientRageDamage[this.Index] = this.iMaxRageDamage*2;
			if (g_iClientRageDamage[this.Index] < 0) g_iClientRageDamage[this.Index] = 0;
		}
	}
	
	property bool IsMinion
	{
		public get()
		{
			return g_bClientBossIsMinion[this.Index];
		}
		public set(bool val)
		{
			g_bClientBossIsMinion[this.Index] = val;
		}
	}
	
	public void SetType(char[] type)
	{
		strcopy(g_sClientBossType[this.Index], sizeof(g_sClientBossType[]), type);
	}
	
	public bool FindFunction(char[] sName)
	{
		char sFunc[1000];
		Format(sFunc, sizeof(sFunc), "%s.%s", g_sClientBossType[this.Index], sName);
		Function func;
		if ((func = GetFunctionByName(INVALID_HANDLE, sFunc)) != INVALID_FUNCTION)
		{
			Call_StartFunction(INVALID_HANDLE, func);
			Call_PushCell(this);
			return true;
		}
		return false;
	}
	
	public int GetBaseHealth()
	{
		int iBaseHealth = 100;
		if (this.FindFunction("GetBaseHealth"))
			Call_Finish(iBaseHealth);
		return iBaseHealth;
	}
	
	public int GetHealthPerPlayer()
	{
		int iAdditionalHealth = 800;
		if (this.FindFunction("GetHealthPerPlayer"))
			Call_Finish(iAdditionalHealth);
		return iAdditionalHealth;
	}
	
	public void RecalculateMaxHealth()
	{
		int iTeam = GetClientTeam(this.Index);
		int iEnemy = 0;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				int iTargetTeam = GetClientTeam(i);
				if (iTargetTeam > 0 && iTargetTeam != iTeam)
					iEnemy++;
			}
		}
		
		int iCalculatedHealth = this.GetBaseHealth() + this.GetHealthPerPlayer()*iEnemy;
		if (VSH_SpecialRound(SPECIALROUND_DOUBLETROUBLE))
			iCalculatedHealth /= 3;
		else if (VSH_SpecialRound(SPECIALROUND_CLASHOFBOSSES))
			iCalculatedHealth /= 2;
		
		this.iHealth = iCalculatedHealth;
		this.iMaxHealth = iCalculatedHealth;
	}
	
	public CBaseBoss(int client, char[] type)
	{
		CBaseBoss boss = view_as<CBaseBoss>(client);
		boss.flSpeed = 370.0;
		boss.flSpeedMult = 0.07;
		boss.flFallDamageCap = 100.0;
		boss.iRageDamage = 0;
		boss.flBackStabDamage = 800.0;
		boss.flEnvDamageCap = 400.0;
		boss.flGlowTime = -1.0;
		boss.IsMinion = false;
		
		strcopy(g_sClientBossType[client], sizeof(g_sClientBossType[]), type);
		
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
			g_iClientBossAbility[client][i] = INVALID_ABILITY;
		
		if (boss.FindFunction(type))
			Call_Finish();
		
		if (g_hBossRageHud == null)
			g_hBossRageHud = CreateHudSynchronizer();
		
		if (g_hClientBossModelTimer[client] != null)
			delete g_hClientBossModelTimer[client];
		
		g_hClientBossModelTimer[client] = CreateTimer(0.5, Timer_ApplyBossModel, boss, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		
		g_bClientBossActive[client] = true;
		g_sClientRageMusic[client] = "";
		g_hClientBossRageMusicFadeTime[client] = null;
		g_flClientBossRageMusicVolume[client] = 1.0;
		g_flClientBossRageLastTime[client] = 0.0;
		return boss;
	}
	
	public IAbility RegisterAbility(char[] type)
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] == INVALID_ABILITY)
			{
				g_iClientBossAbility[this.Index][i] = IAbility(this.Index, i, type);
				return g_iClientBossAbility[this.Index][i];
			}
		}
		return INVALID_ABILITY;
	}
	
	public IAbility FindAbility(char[] type)
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
			{
				char sType[64];
				g_iClientBossAbility[this.Index][i].GetType(sType, sizeof(sType));
				if (strcmp(sType, type) == 0)
					return g_iClientBossAbility[this.Index][i];
			}
		}
		return INVALID_ABILITY;
	}
	
	public void UnRegisterAbility(char[] type)
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
			{
				char sType[64];
				g_iClientBossAbility[this.Index][i].GetType(sType, sizeof(sType));
				if (strcmp(sType, type) == 0)
					g_iClientBossAbility[this.Index][i] = INVALID_ABILITY;
			}
		}
	}
	
	public bool IsValid()
	{
		int client = this.Index;
		return (0 < client <= MaxClients && IsClientInGame(client) && g_bClientBossActive[client]);
	}
	
	public void Think()
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].Think();
		}
		
		if (this.FindFunction("Think"))
			Call_Finish();
		
		if (this.flGlowTime != -1.0 && this.flGlowTime >= GetGameTime())
		{
			SetEntProp(this.Index, Prop_Send, "m_bGlowEnabled", true);
		}
		else
		{
			this.flGlowTime = -1.0;
			SetEntProp(this.Index, Prop_Send, "m_bGlowEnabled", false);
		}

		float flMaxSpeed = this.flSpeed + (this.flSpeed-(this.flSpeed*((1.0-(float(this.iHealth)/float(this.iMaxHealth))*this.flSpeedMult))));
		SetEntPropFloat(this.Index, Prop_Data, "m_flMaxspeed", flMaxSpeed);
		
		if (this.iMaxRageDamage != -1)
		{
			int iColor[2];
			if (this.iRageDamage < (this.iMaxRageDamage/2))
			{
				iColor[0] = RoundToNearest(255.0*(float(this.iRageDamage)/(float(this.iMaxRageDamage)/2.0)));
				iColor[1] = 255;
			}
			else if (this.iRageDamage <= this.iMaxRageDamage)
			{
				iColor[1] = RoundToNearest(255.0*(1.0-(float(this.iRageDamage-(this.iMaxRageDamage/2))/(float(this.iMaxRageDamage)/2.0))));
				iColor[0] = 255-RoundToNearest(((255.0-float(iColor[1]))/55.0)*20.0);
			}
			else
			{
				iColor[1] = 162+RoundToNearest(93.0*(float(this.iRageDamage)/(float(this.iMaxRageDamage)*2.0)));
				iColor[0] = 0;
			}
			
			SetHudTextParams(-1.0, 0.83, 0.15, iColor[0], iColor[1], 0, 255);
			ShowSyncHudText(this.Index, g_hBossRageHud, "Rage: %0.0f%%%s", (float(this.iRageDamage)/float(this.iMaxRageDamage))*100.0, (this.iRageDamage >= this.iMaxRageDamage) ? " (Rage is ready! Press E to use your Rage!)" : "");
		}
	}
	
	public TFClassType GetClass()
	{
		TFClassType class = TFClass_Unknown;
		if (this.FindFunction("GetClass"))
			Call_Finish(class);
		return class;
	}
	
	public int SpawnWeapon()
	{
		int iWep = -1;
		if (this.FindFunction("SpawnWeapon"))
			Call_Finish(iWep);
		return iWep;
	}
	
	public void GetModel(char[] sModel, int length)
	{
		Format(sModel, length, "");
		if (this.FindFunction("GetModel"))
		{
			Call_PushStringEx(sModel, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void Spawn()
	{
		//Update our class
		int iPlayer = this.Index;
		TF2_SetPlayerClass(iPlayer, this.GetClass());
		
		char sModel[255];
		this.GetModel(sModel, sizeof(sModel));
		SetVariantString(sModel);
		AcceptEntityInput(iPlayer, "SetCustomModel");
		SetEntProp(iPlayer, Prop_Send, "m_bUseClassAnimations", 1);
		
		int iEntity = MaxClients+1;
		while ((iEntity = FindEntityByClassname(iEntity, "tf_wearable*")) > MaxClients)
		{
			if (GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == iPlayer || GetEntPropEnt(iEntity, Prop_Send, "moveparent") == iPlayer)
				AcceptEntityInput(iEntity, "Kill");
		}
		iEntity = MaxClients+1;
		while((iEntity = FindEntityByClassname(iEntity, "tf_powerup_bottle")) > MaxClients)
		{
			if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == iPlayer || GetEntPropEnt(iEntity, Prop_Send, "moveparent") == iPlayer)
				AcceptEntityInput(iEntity, "Kill");
		}
		
		for (int iSlot = WeaponSlot_Primary; iSlot <= WeaponSlot_InvisWatch; iSlot++)
			TF2_RemoveItemInSlot(iPlayer, iSlot);
		
		int iWep = this.SpawnWeapon();
		if (iWep > MaxClients)
		{
			SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
			EquipPlayerWeapon(iPlayer, iWep);
		}
	
		this.RecalculateMaxHealth();
		this.iHealth = this.iMaxHealth;
		
		if (this.FindFunction("Spawn"))
			Call_Finish();
	}
	
	public void GetPainSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetPainSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetRoundStartMusic(char [] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetRoundStartMusic"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetRoundStartSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetWinSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetLoseSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetRageSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetAbilitySound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_PushString(sType);
			Call_Finish();
		}
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetClassKillSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_PushCell(playerClass);
			Call_Finish();
		}
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetLastManSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		Format(sSound, length, "");
		if (this.FindFunction("GetBackstabSound"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_Finish();
		}
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		Format(sSound, length, "");
		time = -1.0;
		delay = -1.0;
		
		if (this.FindFunction("GetMusicInfo"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_PushFloatRef(time);
			Call_PushFloatRef(delay);
			Call_Finish();
		}
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		Format(sSound, length, "");
		time = 0.0;
		if (this.FindFunction("GetRageMusicInfo"))
		{
			Call_PushStringEx(sSound, length, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCell(length);
			Call_PushFloatRef(time);
			Call_Finish();
		}
	}
	
	public void GetEyeHeigth(float vecEyeHeight[3])
	{
		TFClassType class = TF2_GetPlayerClass(this.Index);
		//vecEyeHeight = g_TFClassViewVectors[view_as<int>(class)];
		
		if (this.FindFunction("GetEyeHeigth"))
		{
			Call_PushArrayEx(vecEyeHeight, sizeof(vecEyeHeight), SM_PARAM_COPYBACK);
			Call_Finish();
		}
	}
	
	public void OnPlayerKilled(int iVictim, Event eventInfo)
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].OnPlayerKilled(iVictim,eventInfo);
		}
		
		if (this.FindFunction("OnPlayerKilled"))
		{
			Call_PushCell(iVictim);
			Call_PushCell(eventInfo);
			Call_Finish();
		}
	}
	
	public void OnDeath(Event eventInfo)
	{
		if (this.FindFunction("OnDeath"))
		{
			Call_PushCell(eventInfo);
			Call_Finish();
		}
	}
	
	public Action OnTaunt(int iArgs)
	{
		Action action = Plugin_Continue;
		if (this.FindFunction("OnTaunt"))
		{
			Call_PushCell(iArgs);
			Call_Finish(action);
		}
		return action;
	}
	
	public void OnRage(bool bSuperRageEx)
	{
		g_flClientBossRageLastTime[this.Index] = GetGameTime();
		
		int iNumRageRemove = RoundToFloor(float(this.iRageDamage)/float(this.iMaxRageDamage));
		bool bSuperRage = (iNumRageRemove == 2);
		
		if (this.FindFunction("OnRage"))
		{
			Call_PushCell(bSuperRage);
			Call_Finish();
		}
		
		char sSound[255];
		float flDuration = 0.0;
		this.GetRageMusicInfo(sSound, sizeof(sSound), flDuration);
		if (flDuration > 0.0 && strcmp(sSound, "") != 0)
		{
			StopSound(this.Index, SNDCHAN_AUTO, sSound);
			
			g_flClientBossRageMusicVolume[this.Index] = 1.0;
			g_hClientBossRageMusicFadeTime[this.Index] = CreateTimer((bSuperRage) ? flDuration : (flDuration/2.0), Timer_BossRageMusicFade, this);
			strcopy(g_sClientRageMusic[this.Index], sizeof(g_sClientRageMusic[]), sSound);
			RequestFrame(Frame_BossRageMusic, this);
		}
		
		
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].OnRage(bSuperRage);
		}
		
		this.iRageDamage -= this.iMaxRageDamage*iNumRageRemove;
		

		this.GetRageSound(sSound, sizeof(sSound));
		if (strcmp(sSound, "") != 0)
			EmitSoundToAll(sSound, this.Index, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
	}
	
	public void OnButtonPress(int button)
	{
		if (this.FindFunction("OnButtonPress"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
		
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].OnButtonPress(button);
		}
	}
	
	public Action OnButton(int button)
	{
		Action action = Plugin_Continue;
		if (this.FindFunction("OnButton"))
		{
			Call_PushCell(button);
			Call_Finish(action);
		}
		
		Action abilityaction = Plugin_Continue;
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
			{
				abilityaction = g_iClientBossAbility[this.Index][i].OnButton(button);
				if (abilityaction != Plugin_Continue)
				{
					if (action == Plugin_Changed)
						action = abilityaction;
					else if (action == Plugin_Handled && abilityaction == Plugin_Stop)
						action = Plugin_Stop;
				}
			}
		}
		return action;
	}
	
	public void OnButtonHold(int button)
	{
		if (this.FindFunction("OnButtonHold"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
		
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].OnButtonHold(button);
		}
	}
	
	public void OnButtonRelease(int button)
	{
		if (this.FindFunction("OnButtonRelease"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
		
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].OnButtonRelease(button);
		}
	}
	
	public bool IsCosmeticBlocked(int iItemDefinitionIndex)
	{
		bool bAction = true;
		if (this.FindFunction("IsCosmeticBlocked"))
		{
			Call_PushCell(iItemDefinitionIndex);
			Call_Finish(bAction);
		}
		return bAction;
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		Action action = Plugin_Continue;
		if (this.FindFunction("OnSoundPlayed"))
		{
			Call_PushArrayEx(clients, MAXPLAYERS, SM_PARAM_COPYBACK);
			Call_PushCellRef(numClients);
			Call_PushStringEx(sample, PLATFORM_MAX_PATH, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCellRef(channel);
			Call_PushFloatRef(volume);
			Call_PushCellRef(level);
			Call_PushCellRef(pitch);
			Call_PushCellRef(flags);
			Call_PushStringEx(soundEntry, PLATFORM_MAX_PATH, SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_PushCellRef(seed);
			Call_Finish(action);
		}
		
		if (strcmp(sample, "player/pl_impact_airblast4.wav") == 0)
		{
			this.iRageDamage += config.LookupInt(g_cvBossAirblastRageDamage);
		}
		return action;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		char sSound[255];
		
		Action action = Plugin_Continue;
		if (this.FindFunction("OnTakeDamage"))
		{
			Call_PushCellRef(attacker);
			Call_PushCellRef(inflictor);
			Call_PushFloatRef(damage);
			Call_PushCellRef(damagetype);
			Call_PushCellRef(weapon);
			Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
			Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
			Call_PushCell(damagecustom);
			Call_Finish(action);
		}
		
		this.GetPainSound(sSound, sizeof(sSound));
		if (strcmp(sSound, "") != 0)
			EmitSoundToAll(sSound, this.Index, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		
		if (damagetype & DMG_FALL)
		{
			if ((attacker <= 0 || attacker > MaxClients) && inflictor == 0)
			{
				int iBossHealth = GetEntProp(this.Index, Prop_Send, "m_iHealth");
				damage = (iBossHealth >= 1000) ? this.flFallDamageCap : 0.0;
				action = Plugin_Changed;
			}
		}
		
		if (0 < attacker && attacker <= MaxClients && !this.IsMinion)
		{
			int iBossFlags = GetEntityFlags(this.Index);
			if (iBossFlags & (FL_ONGROUND|FL_DUCKING))
			{
				damagetype |= DMG_PREVENT_PHYSICS_FORCE;
				action = Plugin_Changed;
			}
			
			if(inflictor > MaxClients)
			{
				char strInflictor[32];
				GetEdictClassname(inflictor, strInflictor, sizeof(strInflictor));
				if(strcmp(strInflictor, "tf_projectile_sentryrocket") == 0 || strcmp(strInflictor, "obj_sentrygun") == 0)
				{
					damagetype |= DMG_PREVENT_PHYSICS_FORCE;
					action = Plugin_Changed;
				}
			}
			
			if (damagecustom == TF_CUSTOM_BACKSTAB && !TF2_IsUbercharged(this.Index))
			{
				damage = (0.10*float(SDK_GetMaxHealth(this.Index)))/(Pow(1.07,float(TF2_GetTeamAlivePlayers(GetClientTeam(attacker)))))/2.5;
				damagetype |= DMG_PREVENT_PHYSICS_FORCE;
				
				ScaleVector(damageForce, 0.03);
				for (int i=0; i<3; i++)
				{
					if(damageForce[i] > 300.0)
						damageForce[i] = 300.0;
					else if(damageForce[i] < -300.0)
						damageForce[i] = -300.0;
				}
				TeleportEntity(this.Index, NULL_VECTOR, NULL_VECTOR, damageForce);
				
				EmitSoundToClient(this.Index, BOSS_BACKSTAB_SOUND);
				EmitSoundToClient(attacker, BOSS_BACKSTAB_SOUND);
				
				float flBackStabCooldown = GetGameTime() + 2.0;
				SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", flBackStabCooldown);
				SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", flBackStabCooldown);
				SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", flBackStabCooldown);
				
				SDK_SendWeaponAnim(weapon, 0x648);
				
				PrintCenterText(attacker, "You backstabbed him!");
				PrintCenterText(this.Index, "You were just backstabbed!");
				
				this.GetBackstabSound(sSound, sizeof(sSound));
				if (strcmp(sSound, "") != 0)
					EmitSoundToAll(sSound, this.Index, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
				action = Plugin_Changed;
			}
			else if (damagecustom == TF_CUSTOM_TELEFRAG)
			{
				//Reward half of telefrag damage to the player telefragging the boss and the other half to the teleporter owner
				float flHalfTelefragDamage = config.LookupFloat(g_cvBossTelefragDamage)/2.0;
				damage = flHalfTelefragDamage;
				PrintCenterText(attacker, "TELEFRAG! You are a pro.");
				PrintCenterText(this.Index, "TELEFRAG! Be careful around quantum tunneling devices!");
				
				//Try to retrieve the entity under the player, and hopefully this is the teleporter
				int iGroundEntity = GetEntPropEnt(attacker, Prop_Send, "m_hGroundEntity");
				if (iGroundEntity > MaxClients)
				{
					char strGroundEntity[32];
					GetEdictClassname(iGroundEntity, strGroundEntity, sizeof(strGroundEntity));
					if (strcmp(strGroundEntity, "obj_teleporter") == 0)
					{
						int iBuilder = GetEntPropEnt(iGroundEntity, Prop_Send, "m_hBuilder");
						if (0 < iBuilder <= MaxClients && IsClientInGame(iBuilder))
						{
							SDKHooks_TakeDamage(this.Index, 0, iBuilder, flHalfTelefragDamage);
						}
					}
				}
				
				action = Plugin_Changed;
			}
			else if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
			{
				damage *= 5.0;
				action = Plugin_Changed;
			}
		}
		else if (MaxClients < attacker)
		{
			char strAttacker[32];
			GetEdictClassname(attacker, strAttacker, sizeof(strAttacker));
			if (strcmp(strAttacker, "trigger_hurt") == 0)
			{
				float flEnvDamage = damage;
				if ((damagetype & DMG_ACID)) flEnvDamage *= 3.0;
				
				if (flEnvDamage > this.flEnvDamageCap)
				{
					int iBossSpawn = MaxClients+1;
					int iTeam = GetClientTeam(this.Index);
					while((iBossSpawn = FindEntityByClassname(iBossSpawn, "info_player_teamspawn")) > MaxClients)
					{
						if (GetEntProp(iBossSpawn, Prop_Send, "m_iTeamNum") == iTeam)
						{
							float vecPos[3];
							GetEntPropVector(iBossSpawn, Prop_Data, "m_vecAbsOrigin", vecPos);
							float vecNoVel[3];
							TeleportEntity(this.Index, vecPos, NULL_VECTOR, vecNoVel);
							damage = (damagetype & DMG_ACID) ? this.flEnvDamageCap/3.0 : this.flEnvDamageCap;
							TF2_StunPlayer(this.Index, 2.0, 1.0, 257, 0);
							action = Plugin_Changed;
						}
					}
				}
			}
		}
		
		if (VSH_SpecialRound(SPECIALROUND_CLASHOFBOSSES))
		{
			damage *= 4.0;
			action = Plugin_Changed;
		}
		return action;
	}
	
	public void Precache()
	{
		if (this.FindFunction("Precache"))
			Call_Finish();
	}
	
	public void Destroy()
	{
		for (int i = 0; i < MAX_BOSS_ABILITY; i++)
		{
			if (g_iClientBossAbility[this.Index][i] != INVALID_ABILITY)
				g_iClientBossAbility[this.Index][i].Destroy();
		}
		
		if (this.FindFunction("Destroy"))
			Call_Finish();
		
		SetVariantString("");
		AcceptEntityInput(this.Index, "SetCustomModel");
		TF2_RegeneratePlayer(this.Index);
		
		g_bClientBossActive[this.Index] = false;
		TF2_AddCondition(this.Index, TFCond_SpeedBuffAlly, 0.01);
		
		if (strcmp(g_sClientRageMusic[this.Index], "") != 0)
			StopSound(this.Index, SNDCHAN_AUTO, g_sClientRageMusic[this.Index]);
		g_hClientBossRageMusicFadeTime[this.Index] = null;
		
		if (g_hClientBossModelTimer[this.Index] != null)
		{
			delete g_hClientBossModelTimer[this.Index];
			g_hClientBossModelTimer[this.Index] = null;
		}
	}
}

void Frame_BossRageMusic(CBaseBoss boss)
{
	if (!boss.IsValid())
		return;
	if (strcmp(g_sClientRageMusic[boss.Index], "") == 0)
		return;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			EmitSoundToClient(i, g_sClientRageMusic[boss.Index], boss.Index, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER, SND_CHANGEVOL, g_flClientBossRageMusicVolume[boss.Index]);
	if (g_flClientBossRageMusicVolume[boss.Index] == 0.0)
		return;
	RequestFrame(Frame_BossRageMusic, boss);
}

public Action Timer_ApplyBossModel(Handle hTimer, CBaseBoss boss)
{
	if (!boss.IsValid())
	{
		g_hClientBossModelTimer[boss.Index] = null;
		return Plugin_Stop;
	}
	
	if (g_hClientBossModelTimer[boss.Index] != hTimer)
	{
		g_hClientBossModelTimer[boss.Index] = null;
		return Plugin_Stop;
	}
	
	//Prevents plugins like model manager to override our model
	char sModel[255];
	boss.GetModel(sModel, sizeof(sModel));
	SetVariantString(sModel);
	AcceptEntityInput(boss.Index, "SetCustomModel");
	SetEntProp(boss.Index, Prop_Send, "m_bUseClassAnimations", true);
	return Plugin_Continue;
}

public Action Timer_BossRageMusicFade(Handle hTimer, CBaseBoss boss)
{
	if (!boss.IsValid())
		return;
	if (hTimer != g_hClientBossRageMusicFadeTime[boss.Index])
		return;
	if (strcmp(g_sClientRageMusic[boss.Index], "") == 0)
		return;
	
	g_flClientBossRageMusicVolume[boss.Index] -= 0.07;
	if (g_flClientBossRageMusicVolume[boss.Index] < 0.0)
		g_flClientBossRageMusicVolume[boss.Index] = 0.0;
	else
		g_hClientBossRageMusicFadeTime[boss.Index] = CreateTimer(0.01, Timer_BossRageMusicFade, boss);
}

const CBaseBoss INVALID_BOSS = view_as<CBaseBoss>(-1);

stock int CreateWeapon(int client, char[] sName, int index, int level, int qual, char[] att)
{
	Handle hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == INVALID_HANDLE)
		return -1;
	
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	TF2Items_SetClassname(hWeapon, sName);
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 1)
	{
		int iTotalCount = count/2;
		TF2Items_SetNumAttributes(hWeapon, iTotalCount);
		
		int i2 = 0;
		for (int i = 0; i < count; i += 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);

	int entity = TF2Items_GiveNamedItem(client, hWeapon);
	delete hWeapon;
	
	// Set Benoist as the maker of every boss weapon (if possible)
	TF2Attrib_SetByDefIndex(entity, 228, view_as<float>(76561198059675572));
	Address AttribAddress = TF2Attrib_GetByDefIndex(entity, 228);
	if (AttribAddress > view_as<Address>(3000))
		StoreToAddress(AttribAddress+view_as<Address>(8), 76561198059675572, NumberType_Int32);
	
	return entity;
}

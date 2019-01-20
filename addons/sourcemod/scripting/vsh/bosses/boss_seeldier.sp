#define SEELDIER_MODEL						"models/player/kirillian/boss/seeldier_fix.mdl"
#define SEELDIER_SEE_SND					"vsh_rewrite/seeldier/see.wav"
#define SEE_BOSSES_INTRO_SND				"vsh_rewrite/seeman/intro.wav"

methodmap CSeeldier < CBaseBoss
{
	public CSeeldier(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.iMaxRageDamage = 2000;
		
		int iActiveBoss = GetClientOfUserId(g_iUserActiveBoss);
		if (0 < iActiveBoss <= MaxClients && IsClientInGame(iActiveBoss) && iActiveBoss == boss.Index)
		{
			ArrayList aValidBosses = new ArrayList();
			
			// We are the main boss summon our companion
			int iBossTeam = GetClientTeam(iActiveBoss);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i))
				{
					int iTeam = GetClientTeam(i);
					if (iTeam > 1 && !Client_HasFlag(i, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM) && g_clientBoss[i] == INVALID_BOSS)
					{
						aValidBosses.Push(i);
					}
				}
			}
			
			int iValidCompanion = -1;
			if (aValidBosses.Length > 1) iValidCompanion = aValidBosses.Get(GetRandomInt(0, aValidBosses.Length-1));
			delete aValidBosses;
			
			if (iValidCompanion != -1)
			{
				// Allow them to join the boss team
				Client_AddFlag(iValidCompanion, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
				// Move them to the boss team
				TF2_ForceTeamJoin(iValidCompanion, iBossTeam);
				TF2_RespawnPlayer(iValidCompanion);
				// Transform them into a boss
				g_clientBoss[iValidCompanion] = CBaseBoss(iValidCompanion, "CSeeMan");
				TF2_RespawnPlayer(iValidCompanion);
			}
		}
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iTotalMinions = 3;
		if (bSuperRage) iTotalMinions *= 2;
		
		int iBossTeam = GetClientTeam(this.Index);
		float vecBossPos[3], vecBossAng[3];
		GetClientAbsOrigin(this.Index, vecBossPos);
		GetClientAbsAngles(this.Index, vecBossAng);
		vecBossAng[0] = 0.0;
		vecBossAng[2] = 0.0;
		
		ArrayList aValidMinions = new ArrayList();
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) > 1 && !IsPlayerAlive(i) && !Client_HasFlag(i, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM) && g_clientBoss[i] == INVALID_BOSS)
				{
					aValidMinions.Push(i);
				}
			}
		}
		
		SortADTArray(aValidMinions, Sort_Random, Sort_Integer);
		int iLength = aValidMinions.Length;
		if (iLength < iTotalMinions)
			iTotalMinions = iLength;
		else
			iLength = iTotalMinions;
		
		for (int i = 0; i < iLength; i++)
		{
			int iClient = aValidMinions.Get(i);
			// Allow them to join the boss team
			Client_AddFlag(iClient, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
			// Move them to the boss team
			TF2_ForceTeamJoin(iClient, iBossTeam);
			// Transform them into a boss
			g_clientBoss[iClient] = CBaseBoss(iClient, "CSeeldierMinion");
			TF2_RespawnPlayer(iClient);
			
			float vecVel[3];
			vecVel[0] = GetRandomFloat(-200.0, 200.0);
			vecVel[1] = GetRandomFloat(-200.0, 200.0);
			vecVel[2] = GetRandomFloat(-200.0, 200.0);
			
			TeleportEntity(iClient, vecBossPos, vecBossAng, vecVel);
		}
		
		delete aValidMinions;
	}
	
	public int GetBaseHealth()
	{
		return 750;
	}
	
	public int GetHealthPerPlayer()
	{
		return 450;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Soldier;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 1.9 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_shovel", 196, 100, TFQual_Collectors, attribs);
		SetEntityRenderMode(iWep, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iWep, _, _, _, 0);
		return iWep;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		EmitSoundToAll(SEELDIER_SEE_SND, this.Index, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		return Plugin_Continue;
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Seeldier");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, SEELDIER_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEE_BOSSES_INTRO_SND);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrepareSound(SEE_BOSSES_INTRO_SND);
		PrecacheModel(SEELDIER_MODEL);
		PrepareSound(SEELDIER_SEE_SND);
		
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.mdl");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.sw.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.vvd");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.dx80.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.dx90.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeldier_fix.phy");
	}
}

methodmap CSeeldierMinion < CBaseBoss
{
	public CSeeldierMinion(CBaseBoss boss)
	{
		boss.iMaxRageDamage = -1;
		boss.IsMinion = true;
	}
	
	public int GetBaseHealth()
	{
		return 420;
	}
	
	public int GetHealthPerPlayer()
	{
		return 0;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Soldier;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "2 ; 1.5 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_shovel", 196, 100, TFQual_Collectors, attribs);
		SetEntProp(iWep, Prop_Send, "m_iWorldModelIndex", -1);
		return iWep;
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, SEELDIER_MODEL);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, SEELDIER_SEE_SND);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void Spawn()
	{
		SetEntPropFloat(this.Index, Prop_Send, "m_flModelScale", 0.5);
	}
	
	public void Destroy()
	{
		SetEntPropFloat(this.Index, Prop_Send, "m_flModelScale", 1.0);
	}
}
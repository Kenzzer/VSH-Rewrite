#define SEEMAN_MODEL						"models/player/kirillian/boss/seeman_fix.mdl"
#define SEEMAN_RAGE_SND						"vsh_rewrite/seeman/rage.wav"
#define SEEMAN_SEE_SND						"vsh_rewrite/seeman/see.wav"
#define SEE_BOSSES_INTRO_SND				"vsh_rewrite/seeman/intro.wav"

methodmap CSeeMan < CBaseBoss
{
	public CSeeMan(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		CBomb bomb = view_as<CBomb>(boss.RegisterAbility("CBomb"));
		bomb.flBombSpawnInterval = 0.1;
		bomb.flBombSpawnDuration = 3.0;
		bomb.flBombSpawnRadius = 500.0;
		bomb.flBombRadius = 200.0;
		bomb.flBombDamage = 75.0;
		boss.iMaxRageDamage = 2000;
		
		CRageAddCond rageCond = view_as<CRageAddCond>(boss.RegisterAbility("CRageAddCond"));
		rageCond.flRageCondDuration = 3.0;
		rageCond.AddCond(TFCond_UberchargedCanteen);
		
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
				g_clientBoss[iValidCompanion] = CBaseBoss(iValidCompanion, "CSeeldier");
			}
		}
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
		return TFClass_DemoMan;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		char sWeaponClassName[32];
		if (weapon >= 0) GetEdictClassname(inflictor, sWeaponClassName, sizeof(sWeaponClassName));
		
		if (this.Index == attacker && strcmp(sWeaponClassName, "tf_generic_bomb") == 0) return Plugin_Handled; // Don't let the bombs from the bomb ability damages us!
		// Commented, too many SEEEEEEEEEEEEEEEEEE
		//EmitSoundToAll(SEEMAN_SEE_SND, this.Index, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		return Plugin_Continue;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 1.9 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_bottle", 191, 100, TFQual_Collectors, attribs);
		SetEntityRenderMode(iWep, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iWep, _, _, _, 0);
		return iWep;
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Seeman");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, SEEMAN_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEE_BOSSES_INTRO_SND);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, SEEMAN_SEE_SND);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		strcopy(sSound, length, SEEMAN_RAGE_SND);
		time = 6.0;
	}
	
	public void Precache()
	{
		CBomb.Precache();
		
		PrepareSound(SEEMAN_SEE_SND);
		PrepareSound(SEEMAN_RAGE_SND);
		PrepareSound(SEE_BOSSES_INTRO_SND);
		PrecacheModel(SEEMAN_MODEL);
		
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.mdl");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.sw.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.vvd");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.dx80.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.dx90.vtx");
		AddFileToDownloadsTable("models/player/kirillian/boss/seeman_fix.phy");
	}
}
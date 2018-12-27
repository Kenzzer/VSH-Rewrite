static char g_strBossSpawn[][] =
{
	"vo/spy_cloakedspy01.mp3",
	"vo/spy_cheers04.mp3",
	"vo/spy_cheers01.mp3",
	"vo/spy_mvm_resurrect03.mp3",
	"vo/spy_mvm_resurrect07.mp3"
};

static char g_strBossWin[][] = {
	"vo/spy_goodjob01.mp3",
	"vo/spy_paulingkilltaunt02.mp3",
	"vo/spy_paulingkilltaunt01.mp3",
	"vo/spy_positivevocalization01.mp3"
};

static char g_strBossJump[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3"
};

static char g_strBossRage[][] =
{
	"vo/spy_meleedare01.mp3",
	"vo/spy_meleedare02.mp3",
	"vo/spy_stabtaunt01.mp3",
	"vo/spy_stabtaunt02.mp3",
	"vo/spy_laughevil01.mp3",
	"vo/spy_laughevil02.mp3"
};

static char g_strBossBackStab[][] =
{
	"vo/spy_sf12_falling01.mp3",
	"vo/spy_sf12_scared01.mp3",
	"vo/spy_sf12_badmagic06.mp3",
	"vo/spy_sf12_badmagic07.mp3"
};

static char g_strBossLose[][] =
{
	"vo/spy_jeers06.mp3",
	"vo/spy_jeers04.mp3",
	"vo/spy_sf12_badmagic05.mp3"
};

static char g_strBossKillDemoman[][] = 
{
	"vo/spy_dominationdemoman01.mp3",
	"vo/spy_dominationdemoman02.mp3",
	"vo/spy_dominationdemoman03.mp3",
	"vo/spy_dominationdemoman04.mp3",
	"vo/spy_dominationdemoman05.mp3",
	"vo/spy_dominationdemoman06.mp3",
	"vo/spy_dominationdemoman07.mp3"
};

static char g_strBossKillEngie[][] = 
{
	"vo/spy_dominationengineer01.mp3",
	"vo/spy_dominationengineer02.mp3",
	"vo/spy_dominationengineer03.mp3",
	"vo/spy_dominationengineer04.mp3",
	"vo/spy_dominationengineer05.mp3",
	"vo/spy_dominationengineer06.mp3"
};

static char g_strBossKillHeavy[][] = 
{
	"vo/spy_dominationheavy01.mp3",
	"vo/spy_dominationheavy02.mp3",
	"vo/spy_dominationheavy03.mp3",
	"vo/spy_dominationheavy04.mp3",
	"vo/spy_dominationheavy05.mp3",
	"vo/spy_dominationheavy06.mp3",
	"vo/spy_dominationheavy07.mp3",
	"vo/spy_dominationheavy08.mp3"
};

static char g_strBossKillMedic[][] = 
{
	"vo/spy_dominationmedic01.mp3",
	"vo/spy_dominationmedic02.mp3",
	"vo/spy_dominationmedic03.mp3",
	"vo/spy_dominationmedic04.mp3",
	"vo/spy_dominationmedic05.mp3",
	"vo/spy_dominationmedic06.mp3"
};

static char g_strBossKillPyro[][] = 
{
	"vo/spy_dominationpyro01.mp3",
	"vo/spy_dominationpyro02.mp3",
	"vo/spy_dominationpyro03.mp3",
	"vo/spy_dominationpyro04.mp3",
	"vo/spy_dominationpyro05.mp3"
};

static char g_strBossKillScout[][] = 
{
	"vo/spy_dominationscout01.mp3",
	"vo/spy_dominationscout02.mp3",
	"vo/spy_dominationscout03.mp3",
	"vo/spy_dominationscout04.mp3",
	"vo/spy_dominationscout05.mp3",
	"vo/spy_dominationscout06.mp3",
	"vo/spy_dominationscout07.mp3",
	"vo/spy_dominationscout08.mp3"
};

static char g_strBossKillSniper[][] = 
{
	"vo/spy_dominationsniper01.mp3",
	"vo/spy_dominationsniper02.mp3",
	"vo/spy_dominationsniper03.mp3",
	"vo/spy_dominationsniper04.mp3",
	"vo/spy_dominationsniper05.mp3",
	"vo/spy_dominationsniper06.mp3",
	"vo/spy_dominationsniper07.mp3"
};

static char g_strBossKillSoldier[][] = 
{
	"vo/spy_dominationsoldier01.mp3",
	"vo/spy_dominationsoldier02.mp3",
	"vo/spy_dominationsoldier03.mp3",
	"vo/spy_dominationsoldier04.mp3",
	"vo/spy_dominationsoldier05.mp3"
};

static char g_strBossKillSpy[][] = 
{
	"vo/spy_dominationspy01.mp3",
	"vo/spy_dominationspy02.mp3",
	"vo/spy_dominationspy03.mp3",
	"vo/spy_dominationspy04.mp3",
	"vo/spy_dominationspy05.mp3"
};

static char g_strBossLast[][] = 
{
	"vo/taunts/spy_highfive10.mp3",
	"vo/taunts/spy_highfive13.mp3"
};

#define GENTLE_INTRO						"vsh_rewrite/gentlespy/intro.mp3"
#define GENTLE_THEME						"vsh_rewrite/gentlespy/theme.mp3"
#define GENTLE_MODEL						"models/freak_fortress_2/gentlespy/the_gentlespy_v1.mdl"

methodmap CGentleSpy < CBaseBoss
{
	public CGentleSpy(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.iMaxRageDamage = 2000;
	}
	
	public int GetBaseHealth()
	{
		return 850;
	}
	
	public int GetHealthPerPlayer()
	{
		return 650;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Spy;
	}
	
	public int SpawnWeapon()
	{
		return CreateWeapon(this.Index, "tf_weapon_knife", 4, 100, TFQual_Unusual, "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65 ; 159 ; 1.0");
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Gentle Spy");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, GENTLE_MODEL);
	}
	
	public void GetRoundStartMusic(char[] sSound, int length)
	{
		strcopy(sSound, length, GENTLE_INTRO);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossSpawn[GetRandomInt(0,sizeof(g_strBossSpawn)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossLose[GetRandomInt(0,sizeof(g_strBossLose)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossWin[GetRandomInt(0,sizeof(g_strBossWin)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossRage[GetRandomInt(0,sizeof(g_strBossRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strBossJump[GetRandomInt(0,sizeof(g_strBossJump)-1)]);
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossLast[GetRandomInt(0,sizeof(g_strBossLast)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strBossBackStab[GetRandomInt(0,sizeof(g_strBossBackStab)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		switch (playerClass)
		{
			case TFClass_Scout:
				strcopy(sSound, length, g_strBossKillScout[GetRandomInt(0,sizeof(g_strBossKillScout)-1)]);
			case TFClass_Sniper:
				strcopy(sSound, length, g_strBossKillSniper[GetRandomInt(0,sizeof(g_strBossKillSniper)-1)]);
			case TFClass_DemoMan:
				strcopy(sSound, length, g_strBossKillDemoman[GetRandomInt(0,sizeof(g_strBossKillDemoman)-1)]);
			case TFClass_Pyro:
				strcopy(sSound, length, g_strBossKillPyro[GetRandomInt(0,sizeof(g_strBossKillPyro)-1)]);
			case TFClass_Heavy:
				strcopy(sSound, length, g_strBossKillHeavy[GetRandomInt(0,sizeof(g_strBossKillHeavy)-1)]);
			case TFClass_Soldier:
				strcopy(sSound, length, g_strBossKillSoldier[GetRandomInt(0,sizeof(g_strBossKillSoldier)-1)]);
			case TFClass_Medic:
				strcopy(sSound, length, g_strBossKillMedic[GetRandomInt(0,sizeof(g_strBossKillMedic)-1)]);
			case TFClass_Spy:
				strcopy(sSound, length, g_strBossKillSpy[GetRandomInt(0,sizeof(g_strBossKillSpy)-1)]);
			case TFClass_Engineer:
				strcopy(sSound, length, g_strBossKillEngie[GetRandomInt(0,sizeof(g_strBossKillEngie)-1)]);
		}
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		strcopy(sSound, length, GENTLE_THEME);
		time = 140.0;
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iWep = GetPlayerWeaponSlot(this.Index, WeaponSlot_Primary);
		if (iWep <= MaxClients)
		{
			iWep = CreateWeapon(this.Index, "tf_weapon_revolver", 61, 100, TFQual_Unusual, "2 ; 20.0 ; 37 ; 0.0");
			if (iWep > MaxClients)
			{
				SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
				EquipPlayerWeapon(this.Index, iWep);
				
				SetEntProp(iWep, Prop_Send, "m_iClip1", 0);
				SetEntProp(this.Index, Prop_Send, "m_iAmmo", 0, _, GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType"));
			}
		}
		
		SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
		
		int iBossTeam = GetClientTeam(this.Index);
		int iEnemyTeam = (iBossTeam == TFTeam_Red) ? TFTeam_Blue : TFTeam_Red;
		int iBullets = RoundToCeil(VSH_GetTeamCount(iEnemyTeam, true, false, false) / 4.0);
		if (bSuperRage) iBullets *= 2;
		
		SetEntProp(iWep, Prop_Send, "m_iClip1", GetEntProp(iWep, Prop_Send, "m_iClip1")+iBullets);
	}
	
	public void Precache()
	{
		for (int i = 0; i <= sizeof(g_strBossWin)-1; i++) PrecacheSound(g_strBossWin[i]);
		for (int i = 0; i <= sizeof(g_strBossBackStab)-1; i++) PrecacheSound(g_strBossBackStab[i]);
		for (int i = 0; i <= sizeof(g_strBossLose)-1; i++) PrecacheSound(g_strBossLose[i]);
		for (int i = 0; i <= sizeof(g_strBossRage)-1; i++) PrecacheSound(g_strBossRage[i]);
		for (int i = 0; i <= sizeof(g_strBossSpawn)-1; i++) PrecacheSound(g_strBossSpawn[i]);
		for (int i = 0; i <= sizeof(g_strBossKillDemoman)-1; i++) PrecacheSound(g_strBossKillDemoman[i]);
		for (int i = 0; i <= sizeof(g_strBossKillEngie)-1; i++) PrecacheSound(g_strBossKillEngie[i]);
		for (int i = 0; i <= sizeof(g_strBossKillHeavy)-1; i++) PrecacheSound(g_strBossKillHeavy[i]);
		for (int i = 0; i <= sizeof(g_strBossKillMedic)-1; i++) PrecacheSound(g_strBossKillMedic[i]);
		for (int i = 0; i <= sizeof(g_strBossKillPyro)-1; i++) PrecacheSound(g_strBossKillPyro[i]);
		for (int i = 0; i <= sizeof(g_strBossKillScout)-1; i++) PrecacheSound(g_strBossKillScout[i]);
		for (int i = 0; i <= sizeof(g_strBossKillSniper)-1; i++) PrecacheSound(g_strBossKillSniper[i]);
		for (int i = 0; i <= sizeof(g_strBossKillSoldier)-1; i++) PrecacheSound(g_strBossKillSoldier[i]);
		for (int i = 0; i <= sizeof(g_strBossKillSpy)-1; i++) PrecacheSound(g_strBossKillSpy[i]);
		for (int i = 0; i <= sizeof(g_strBossJump)-1; i++) PrecacheSound(g_strBossJump[i]);
		
		PrepareSound(GENTLE_INTRO);
		PrecacheSound(GENTLE_THEME);
		PrecacheModel(GENTLE_MODEL);
		
		AddFileToDownloadsTable("materials/freak_fortress_2/gentlespy_tex/stylish_spy_blue.vmt");
		AddFileToDownloadsTable("materials/freak_fortress_2/gentlespy_tex/stylish_spy_blue.vtf");
		AddFileToDownloadsTable("materials/freak_fortress_2/gentlespy_tex/stylish_spy_blue_invun.vmt");
		AddFileToDownloadsTable("materials/freak_fortress_2/gentlespy_tex/stylish_spy_blue_invun.vtf");
		AddFileToDownloadsTable("materials/freak_fortress_2/gentlespy_tex/stylish_spy_normal.vtf");
		
		
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.mdl");
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.phy");
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.sw.vtx");
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.vvd");
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.dx80.vtx");
		AddFileToDownloadsTable("models/freak_fortress_2/gentlespy/the_gentlespy_v1.dx90.vtx");
	}
	
	public void Destroy()
	{
	}
}
static char g_strCBSSpawn[][] =
{
	"vo/sniper_specialweapon08.mp3"
};

static char g_strCBSWin[][] = {
	"vo/sniper_revenge01.mp3",
	"vo/sniper_revenge02.mp3",
	"vo/sniper_revenge03.mp3",
	"vo/sniper_revenge04.mp3",
	"vo/sniper_revenge05.mp3",
	"vo/sniper_revenge06.mp3",
	"vo/sniper_revenge07.mp3",
	"vo/sniper_revenge08.mp3",
	"vo/sniper_revenge09.mp3",
	"vo/sniper_revenge10.mp3",
	"vo/sniper_revenge11.mp3",
	"vo/sniper_revenge12.mp3",
	"vo/sniper_revenge13.mp3",
	"vo/sniper_revenge14.mp3",
	"vo/sniper_revenge15.mp3",
	"vo/sniper_revenge16.mp3",
	"vo/sniper_revenge17.mp3",
	"vo/sniper_revenge18.mp3",
	"vo/sniper_revenge19.mp3",
	"vo/sniper_revenge20.mp3",
	"vo/sniper_revenge21.mp3",
	"vo/sniper_revenge22.mp3",
	"vo/sniper_revenge23.mp3",
	"vo/sniper_revenge24.mp3",
	"vo/sniper_revenge25.mp3",
	"vo/sniper_autocappedcontrolpoint02.mp3"
};

static char g_strCBSJump[][] = {
	"vo/taunts/sniper_taunts01.mp3",
	"vo/taunts/sniper_taunts23.mp3"
};

static char s_strCBSRage[][] =
{
	"vo/sniper_battlecry03.mp3",
	"vo/taunts/sniper_taunts02.mp3",
	"vo/taunts/sniper_taunts03.mp3",
	"vo/taunts/sniper_taunts04.mp3",
	"vo/taunts/sniper_taunts05.mp3",
	"vo/taunts/sniper_taunts08.mp3",
	"vo/taunts/sniper_taunts09.mp3",
	"vo/taunts/sniper_taunts10.mp3",
	"vo/taunts/sniper_taunts11.mp3",
	"vo/taunts/sniper_taunts12.mp3",
	"vo/taunts/sniper_taunts13.mp3",
	"vo/taunts/sniper_taunts14.mp3",
	"vo/taunts/sniper_taunts15.mp3",
	"vo/taunts/sniper_taunts16.mp3"
};

static char g_strCBSBackStab[][] =
{
	"vo/sniper_autodejectedtie01.mp3",
	"vo/sniper_autodejectedtie02.mp3",
	"vo/sniper_autodejectedtie03.mp3"
};

static char g_strCBSLost[][] =
{
	"vo/sniper_autodejectedtie01.mp3",
	"vo/sniper_autodejectedtie02.mp3",
	"vo/sniper_autodejectedtie03.mp3"
};

static char g_strCBSKill[][] = 
{
	"vo/sniper_domination01.mp3",
	"vo/sniper_domination02.mp3",
	"vo/sniper_domination03.mp3",
	"vo/sniper_domination04.mp3",
	"vo/sniper_domination05.mp3",
	"vo/sniper_domination06.mp3",
	"vo/sniper_domination07.mp3",
	"vo/sniper_domination08.mp3",
	"vo/sniper_domination09.mp3",
	"vo/sniper_domination10.mp3",
	"vo/sniper_domination11.mp3",
	"vo/sniper_domination12.mp3",
	"vo/sniper_domination13.mp3",
	"vo/sniper_domination14.mp3",
	"vo/sniper_domination15.mp3",
	"vo/sniper_domination16.mp3",
	"vo/sniper_domination17.mp3",
	"vo/sniper_domination18.mp3",
	"vo/sniper_domination19.mp3",
	"vo/sniper_domination20.mp3",
	"vo/sniper_domination21.mp3",
	"vo/sniper_domination22.mp3",
	"vo/sniper_domination23.mp3",
	"vo/sniper_domination24.mp3",
	"vo/sniper_domination25.mp3"
};

static int g_iCBSClubsIndexes[] =
{
	3,
	171,
	232,
	401
};

#define CBS_THEME						"vsh_rewrite/cbs/theme.mp3"
#define CBS_MODEL						"models/player/saxton_hale/cbs_v4.mdl"

methodmap CCBS < CBaseBoss
{
	public CCBS(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.iMaxRageDamage = 1900;
	}
	
	public int GetBaseHealth()
	{
		return 850;
	}
	
	public int GetHealthPerPlayer()
	{
		return 575;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Sniper;
	}
	
	public int SpawnWeapon()
	{
		return CreateWeapon(this.Index, "tf_weapon_club", g_iCBSClubsIndexes[GetRandomInt(0, sizeof(g_iCBSClubsIndexes)-1)], 100, TFQual_Unusual, "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.6");
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Christian Brutal Sniper");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, CBS_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strCBSSpawn[GetRandomInt(0,sizeof(g_strCBSSpawn)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strCBSLost[GetRandomInt(0,sizeof(g_strCBSLost)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strCBSWin[GetRandomInt(0,sizeof(g_strCBSWin)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, s_strCBSRage[GetRandomInt(0,sizeof(s_strCBSRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strCBSJump[GetRandomInt(0,sizeof(g_strCBSJump)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strCBSBackStab[GetRandomInt(0,sizeof(g_strCBSBackStab)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, g_strCBSKill[GetRandomInt(0,sizeof(g_strCBSKill)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		strcopy(sSound, length, CBS_THEME);
		time = 132.0;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		return Plugin_Continue;
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iWep = GetPlayerWeaponSlot(this.Index, WeaponSlot_Primary);
		if (iWep <= MaxClients)
		{
			iWep = CreateWeapon(this.Index, "tf_weapon_compound_bow", 1005, 100, TFQual_Unusual, "2 ; 2.1 ; 6 ; 0.5 ; 37 ; 0.0 ; 280 ; 19 ; 551 ; 1");
			if (iWep > MaxClients)
			{
				SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
				EquipPlayerWeapon(this.Index, iWep);
				
				SetEntProp(this.Index, Prop_Send, "m_iAmmo", 0, _, GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType"));
				SetEntProp(iWep, Prop_Send, "m_iClip1", 0);
			}
		}
		
		int iBossTeam = GetClientTeam(this.Index);
		int iEnemyTeam = (iBossTeam == TFTeam_Red) ? TFTeam_Blue : TFTeam_Red;
		
		int iArrows = VSH_GetTeamCount(iEnemyTeam, true, false, false);
		if (iArrows > 9) iArrows = 9;
		if (bSuperRage) iArrows *= 2;
		
		SetEntProp(this.Index, Prop_Send, "m_iAmmo", iArrows, _, GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType"));
		SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
	}
	
	public void OnPlayerKilled(int iVictim, Event eventInfo)
	{
		bool bMeleeActive = (GetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon") == GetPlayerWeaponSlot(this.Index, WeaponSlot_Melee));
		TF2_RemoveItemInSlot(this.Index, WeaponSlot_Melee);
		
		int iWep = this.SpawnWeapon();
		if (iWep > MaxClients)
		{
			SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
			EquipPlayerWeapon(this.Index, iWep);
			
			if (bMeleeActive)
			{
				SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
			}
		}
	}
	
	public void Precache()
	{
		for (int i = 0; i <= sizeof(g_strCBSWin)-1; i++) PrecacheSound(g_strCBSWin[i]);
		for (int i = 0; i <= sizeof(g_strCBSBackStab)-1; i++) PrecacheSound(g_strCBSBackStab[i]);
		for (int i = 0; i <= sizeof(g_strCBSLost)-1; i++) PrecacheSound(g_strCBSLost[i]);
		for (int i = 0; i <= sizeof(s_strCBSRage)-1; i++) PrecacheSound(s_strCBSRage[i]);
		for (int i = 0; i <= sizeof(g_strCBSSpawn)-1; i++) PrecacheSound(g_strCBSSpawn[i]);
		for (int i = 0; i <= sizeof(g_strCBSKill)-1; i++) PrecacheSound(g_strCBSKill[i]);
		for (int i = 0; i <= sizeof(g_strCBSJump)-1; i++) PrecacheSound(g_strCBSJump[i]);
		
		PrepareSound(CBS_THEME);
		PrecacheModel(CBS_MODEL);
		
		AddFileToDownloadsTable("materials/models/player/saxton_hale/eye.vmt");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/eye.vtf");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_lens.vtf");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_lens.vmt");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_red.vtf");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_red.vmt");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head_red.vmt");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/sniper_head.vtf");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_l.vmt");
		AddFileToDownloadsTable("materials/models/player/saxton_hale/eyeball_r.vmt");
		
		
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.phy");
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/cbs_v4.dx90.vtx");
	}
	
	public void Destroy()
	{
	}
}
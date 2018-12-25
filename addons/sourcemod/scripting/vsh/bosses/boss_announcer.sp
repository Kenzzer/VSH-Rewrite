static char g_strAdminSpawn[][] = {
	"vo/announcer_dec_missionbegins60s01.mp3",
	"vo/announcer_dec_missionbegins60s02.mp3",
	"vo/announcer_dec_missionbegins60s05.mp3"
};

static char g_strAdminWin[][] = {
	"vo/announcer_dec_success01.mp3",
	"vo/announcer_dec_success02.mp3"
};

static char g_strAdminLastMan[][] = {
	"vo/announcer_am_lastmanalive01.mp3",
	"vo/announcer_am_lastmanalive02.mp3",
	"vo/announcer_am_lastmanalive03.mp3",
	"vo/announcer_am_lastmanalive04.mp3"
};

static char g_strAdminSummon[][] = {
	"vo/announcer_dec_kill07.mp3",
	"vo/announcer_dec_kill08.mp3",
	"vo/announcer_dec_kill09.mp3",
	"vo/announcer_dec_kill11.mp3",
	"vo/announcer_dec_kill12.mp3"
};

static char g_strAdminRage[][] =
{
	"vo/announcer_dec_failure01.mp3",
	"vo/announcer_dec_failure02.mp3"
};

static char g_strAdminBackStab[][] =
{
	"vo/announcer_dec_missionbegins60s04.mp3"
};

static char g_strAdminLost[][] =
{
	"vo/announcer_dec_missionbegins60s04.mp3"
};

#define ADMIN_THEME						"vsh_rewrite/administrator/theme.mp3"
#define ADMIN_INTRO						"vsh_rewrite/administrator/intro.mp3"
#define ADMIN_MODEL						"models/player/kirsfixes/administrator_mod_fix.mdl"

methodmap CAnnouncer < CBaseBoss
{
	public CAnnouncer(CBaseBoss boss)
	{
		boss.RegisterAbility("CRessurect");
		boss.iMaxRageDamage = 2200;
	}
	
	public int GetBaseHealth()
	{
		return 900;
	}
	
	public int GetHealthPerPlayer()
	{
		return 590;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Spy;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		return CreateWeapon(this.Index, "tf_weapon_knife", 4, 100, TFQual_Collectors, attribs);
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, ADMIN_MODEL);
	}
	
	public void GetRoundStartMusic(char [] sSound, int length)
	{
		strcopy(sSound, length, ADMIN_INTRO);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminSpawn[GetRandomInt(0,sizeof(g_strAdminSpawn)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminLost[GetRandomInt(0,sizeof(g_strAdminLost)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminWin[GetRandomInt(0,sizeof(g_strAdminWin)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminRage[GetRandomInt(0,sizeof(g_strAdminRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CRessurect") == 0)
			strcopy(sSound, length, g_strAdminSummon[GetRandomInt(0,sizeof(g_strAdminSummon)-1)]);
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminLastMan[GetRandomInt(0,sizeof(g_strAdminLastMan)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strAdminBackStab[GetRandomInt(0,sizeof(g_strAdminBackStab)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		strcopy(sSound, length, ADMIN_THEME);
		time = 67.0;
		delay = 8.0;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		return Plugin_Continue;
	}
	
	public void OnRage(bool bSuperRage)
	{
		TF2_RemoveItemInSlot(this.Index, WeaponSlot_Primary);
		
		int iWep = CreateWeapon(this.Index, "tf_weapon_revolver", 61, 100, TFQual_Unusual, "2 ; 20.0 ; 37 ; 0.0");
		if (iWep > MaxClients)
		{
			SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
			EquipPlayerWeapon(this.Index, iWep);
			
			SetEntProp(this.Index, Prop_Send, "m_iAmmo", 0, _, GetEntProp(iWep, Prop_Send, "m_iPrimaryAmmoType"));
			SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
			
			int iBossTeam = GetClientTeam(this.Index);
			int iEnemyTeam = (iBossTeam == TFTeam_Red) ? TFTeam_Blue : TFTeam_Red;
			SetEntProp(iWep, Prop_Send, "m_iClip1", RoundToCeil(VSH_GetTeamCount(iEnemyTeam, true, false, false) / 4.0));
		}
	}
	
	public void Precache()
	{
		for (int i = 0; i <= sizeof(g_strAdminWin)-1; i++) PrecacheSound(g_strAdminWin[i]);
		for (int i = 0; i <= sizeof(g_strAdminBackStab)-1; i++) PrecacheSound(g_strAdminBackStab[i]);
		for (int i = 0; i <= sizeof(g_strAdminLost)-1; i++) PrecacheSound(g_strAdminLost[i]);
		for (int i = 0; i <= sizeof(g_strAdminLastMan)-1; i++) PrecacheSound(g_strAdminLastMan[i]);
		for (int i = 0; i <= sizeof(g_strAdminRage)-1; i++) PrecacheSound(g_strAdminRage[i]);
		for (int i = 0; i <= sizeof(g_strAdminSpawn)-1; i++) PrecacheSound(g_strAdminSpawn[i]);
		for (int i = 0; i <= sizeof(g_strAdminSummon)-1; i++) PrecacheSound(g_strAdminSummon[i]);
		
		PrepareSound(ADMIN_THEME);
		PrepareSound(ADMIN_INTRO);
		
		PrecacheModel(ADMIN_MODEL);
		
		AddFileToDownloadsTable("materials/models/player/announcer/announcer_head_purple.vmt");
		AddFileToDownloadsTable("materials/models/player/announcer/announcer_head_purple.vtf");
		AddFileToDownloadsTable("materials/models/player/announcer/announcer_purple.vtf");
		AddFileToDownloadsTable("materials/models/player/announcer/announcer_purple.vmt");
		AddFileToDownloadsTable("materials/models/player/announcer/announcer_normal.vtf");
		AddFileToDownloadsTable("materials/models/player/announcer/eyeball_l.vmt");
		AddFileToDownloadsTable("materials/models/player/announcer/eyeball_r.vmt");
		
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.mdl");
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.phy");
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.sw.vtx");
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.vvd");
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.dx80.vtx");
		AddFileToDownloadsTable("models/player/kirsfixes/administrator_mod_fix.dx90.vtx");
	}
	
	public void Destroy()
	{
	}
}
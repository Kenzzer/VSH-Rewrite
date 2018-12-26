#define HHH_MODEL 	"models/bots/headless_hatman.mdl"
#define HHH_RAGE	"vo/halloween_boss/knight_alert.mp3"
#define HHH_THEME	"ui/holiday/gamestartup_halloween.mp3"

static char g_strHHHRoundStart[][] =
{
	"vo/halloween_boss/knight_spawn.mp3"
};

static char g_strHHHKill[][] =
{
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack04.mp3",
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};

static char g_strHHHLost[][] =
{
	"vo/halloween_boss/knight_death01.mp3",
	"vo/halloween_boss/knight_death02.mp3"
};

static char g_strHHHJump[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};

static char g_strHHHBackStabbed[][] = {
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3"
};

static int g_iHHH_Axe;

methodmap CHHH < CBaseBoss
{
	public CHHH(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.RegisterAbility("CScareRage");
		boss.iMaxRageDamage = 2000;
	}
	
	public int GetBaseHealth()
	{
		return 1000;
	}
	
	public int GetHealthPerPlayer()
	{
		return 800;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_DemoMan;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_sword", 266, 100, TFQual_Unusual, attribs);
		SetEntProp(iWep, Prop_Send, "m_nModelIndexOverrides", g_iHHH_Axe);
		return iWep;
	}
	
	public void Spawn()
	{
		float vecMins[3], vecMaxs[3];
		
		GetEntPropVector(this.Index, Prop_Send, "m_vecMaxs", vecMaxs);
		GetEntPropVector(this.Index, Prop_Send, "m_vecMins", vecMins);
		
		ScaleVector(vecMins, 2.0);
		ScaleVector(vecMaxs, 2.0);
		
		SetEntPropVector(this.Index, Prop_Send, "m_vecMinsPreScaled", vecMins);
		SetEntPropVector(this.Index, Prop_Send, "m_vecMaxsPreScaled", vecMaxs);
		SetEntPropVector(this.Index, Prop_Send, "m_vecMaxs", vecMaxs);
		SetEntPropVector(this.Index, Prop_Send, "m_vecMins", vecMins);
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Headless Horseless Horseman");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, HHH_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHHHRoundStart[GetRandomInt(0,sizeof(g_strHHHRoundStart)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHHHRoundStart[GetRandomInt(0,sizeof(g_strHHHRoundStart)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHHHLost[GetRandomInt(0,sizeof(g_strHHHLost)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, HHH_RAGE);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strHHHJump[GetRandomInt(0,sizeof(g_strHHHJump)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, g_strHHHKill[GetRandomInt(0,sizeof(g_strHHHKill)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHHHBackStabbed[GetRandomInt(0,sizeof(g_strHHHBackStabbed)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0 && strncmp(sample, "vo/halloween_boss/", 18) != 0)// Block voicelines but allow HHH lines
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		strcopy(sSound, length, HHH_THEME);
		time = 80.0;
	}
	
	public void Precache()
	{
		PrecacheModel(HHH_MODEL);
		PrecacheSound(HHH_RAGE);
		PrecacheSound(HHH_THEME);
		
		for (int i = 0; i <= sizeof(g_strHHHBackStabbed)-1; i++) PrecacheSound(g_strHHHBackStabbed[i]);
		for (int i = 0; i <= sizeof(g_strHHHJump)-1; i++) PrecacheSound(g_strHHHJump[i]);
		for (int i = 0; i <= sizeof(g_strHHHKill)-1; i++) PrecacheSound(g_strHHHKill[i]);
		for (int i = 0; i <= sizeof(g_strHHHLost)-1; i++) PrecacheSound(g_strHHHLost[i]);
		for (int i = 0; i <= sizeof(g_strHHHRoundStart)-1; i++) PrecacheSound(g_strHHHRoundStart[i]);
		
		g_iHHH_Axe = PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
	}
}
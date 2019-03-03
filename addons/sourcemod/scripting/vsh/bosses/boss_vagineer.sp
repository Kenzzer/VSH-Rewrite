#define VAGINEER_MODEL		"models/player/saxton_hale/vagineer_v150.mdl"
#define VAGINEER_KILL_SOUND "vsh_rewrite/vagineer/vagineer_kill.mp3"

static char g_strVagineerRageMusic[][] = {
	"vsh_rewrite/vagineer/vagineer_rage_music_1.mp3",
	"vsh_rewrite/vagineer/vagineer_rage_music_2.mp3",
	"vsh_rewrite/vagineer/vagineer_rage_music_3.mp3"
};

static char g_strVagineerRoundStart[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_intro_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_intro_2.mp3"
};

static char g_strVagineerLose[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_fail_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_fail_2.mp3"
};

static char g_strVagineerRage[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_rage_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_3.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_4.mp3"
};

static char g_strVagineerJump[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_jump_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_jump_2.mp3"
};

static char g_strVagineerKill[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_taunt_1.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_3.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_4.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_5.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_taunt_6.mp3"
};

static char g_strVagineerLastMan[][] = {
	"vsh_rewrite/vagineer/vagineer_lastman.mp3"
};

static char g_strVagineerBackStabbed[][] = {
	"vsh_rewrite/vagineer/vagineer_responce_rage_2.mp3",
	"vsh_rewrite/vagineer/vagineer_responce_rage_3.mp3"
};


methodmap CVagineer < CBaseBoss
{
	public CVagineer(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		CReverseGame reverse = view_as<CReverseGame>(boss.RegisterAbility("CReverseGame"));
		reverse.flReverseDuration = 10.0;
		boss.iMaxRageDamage = 2300;
		
		CLightRage light = view_as<CLightRage>(boss.RegisterAbility("CLightRage"));
		light.flLigthRageDuration = 10.0;
		light.flLightRageRadius = 800.0;
		light.iRageLightBrigthness = 5;
		
		int iColor[4] = {0, 255, 0, 255};
		light.SetColor(iColor);
	}
	
	public int GetBaseHealth()
	{
		return 750;
	}
	
	public int GetHealthPerPlayer()
	{
		return 500;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Engineer;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 2.80 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65 ; 150 ; 1.0 ; 436 ; 1.0");
		return CreateWeapon(this.Index, "tf_weapon_wrench", 169, 100, TFQual_Collectors, attribs);
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Vagineer");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, VAGINEER_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strVagineerRoundStart[GetRandomInt(0,sizeof(g_strVagineerRoundStart)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strVagineerLose[GetRandomInt(0,sizeof(g_strVagineerLose)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strVagineerRage[GetRandomInt(0,sizeof(g_strVagineerRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strVagineerJump[GetRandomInt(0,sizeof(g_strVagineerJump)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		strcopy(sSound, length, g_strVagineerKill[GetRandomInt(0,sizeof(g_strVagineerKill)-1)]);
	}
	
	public void OnPlayerKilled(int iVictim, Event eventInfo)
	{
		EmitSoundToAll(VAGINEER_KILL_SOUND);
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strVagineerLastMan[GetRandomInt(0,sizeof(g_strVagineerLastMan)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strVagineerBackStabbed[GetRandomInt(0,sizeof(g_strVagineerBackStabbed)-1)]);
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		strcopy(sSound, length, g_strVagineerRageMusic[GetRandomInt(0,sizeof(g_strVagineerRageMusic)-1)]);
		time = 19.0;
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)//Block voicelines
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrepareSound(VAGINEER_KILL_SOUND);
		for (int i = 0; i <= sizeof(g_strVagineerRageMusic)-1; i++) PrepareSound(g_strVagineerRageMusic[i]);
		for (int i = 0; i <= sizeof(g_strVagineerRoundStart)-1; i++) PrepareSound(g_strVagineerRoundStart[i]);
		for (int i = 0; i <= sizeof(g_strVagineerLose)-1; i++) PrepareSound(g_strVagineerLose[i]);
		for (int i = 0; i <= sizeof(g_strVagineerRage)-1; i++) PrepareSound(g_strVagineerRage[i]);
		for (int i = 0; i <= sizeof(g_strVagineerJump)-1; i++) PrepareSound(g_strVagineerJump[i]);
		for (int i = 0; i <= sizeof(g_strVagineerKill)-1; i++) PrepareSound(g_strVagineerKill[i]);
		for (int i = 0; i <= sizeof(g_strVagineerLastMan)-1; i++) PrepareSound(g_strVagineerLastMan[i]);
		for (int i = 0; i <= sizeof(g_strVagineerBackStabbed)-1; i++) PrepareSound(g_strVagineerBackStabbed[i]);
		
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.phy");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/vagineer_v150.dx90.vtx");
	}
}
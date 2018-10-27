#define HALE_MODEL "models/player/saxton_hale_jungle_inferno/saxton_hale.mdl"

static char g_strHaleRoundStart[][] = {
	"saxton_hale/saxton_hale_responce_start1.mp3",
	"saxton_hale/saxton_hale_responce_start2.mp3",
	"saxton_hale/saxton_hale_responce_start3.mp3",
	"saxton_hale/saxton_hale_responce_start4.mp3",
	"saxton_hale/saxton_hale_responce_start5.mp3"
};

static char g_strHaleWin[][] = {
	"saxton_hale/saxton_hale_responce_win1.mp3",
	"saxton_hale/saxton_hale_responce_win2.mp3"
};

static char g_strHaleLose[][] = {
	"saxton_hale/saxton_hale_responce_fail1.mp3",
	"saxton_hale/saxton_hale_responce_fail2.mp3",
	"saxton_hale/saxton_hale_responce_fail3.mp3"
};

static char g_strHaleRage[][] = {
	"saxton_hale/saxton_hale_responce_rage1.mp3",
	"saxton_hale/saxton_hale_responce_rage2.mp3",
	"saxton_hale/saxton_hale_responce_rage3.mp3",
	"saxton_hale/saxton_hale_responce_rage4.mp3"
};

static char g_strHaleJump[][] = {
	"saxton_hale/saxton_hale_responce_jump1.mp3",
	"saxton_hale/saxton_hale_responce_jump2.mp3",
	"saxton_hale/saxton_hale_132_jump_1.mp3",
	"saxton_hale/saxton_hale_132_jump_2.mp3"
};

static char g_strHaleKillScout[][] = {
	"saxton_hale/saxton_hale_132_kill_scout.mp3"
};

static char g_strHaleKillSniper[][] = {
	"saxton_hale/saxton_hale_responce_kill_sniper1.mp3",
	"saxton_hale/saxton_hale_responce_kill_sniper2.mp3"
};

static char g_strHaleKillDemoMan[][] = {
	"saxton_hale/saxton_hale_132_kill_demo.mp3"
};

static char g_strHaleKillMedic[][] = {
	"saxton_hale/saxton_hale_responce_kill_medic.mp3"
};

static char g_strHaleKillHeavy[][] = {
	"saxton_hale/saxton_hale_132_kill_heavy.mp3"
};

static char g_strHaleKillPyro[][] = {
	"saxton_hale/saxton_hale_132_kill_w_and_m1.mp3"
};

static char g_strHaleKillSpy[][] = {
	"saxton_hale/saxton_hale_responce_kill_spy1.mp3",
	"saxton_hale/saxton_hale_responce_kill_spy2.mp3",
	"saxton_hale/saxton_hale_132_kill_spie.mp3"
};

static char g_strHaleKillEngie[][] = {
	"saxton_hale/saxton_hale_132_kill_engie_1.mp3",
	"saxton_hale/saxton_hale_132_kill_engie_2.mp3",
	"saxton_hale/saxton_hale_responce_kill_eggineer1.mp3",
	"saxton_hale/saxton_hale_responce_kill_eggineer1.mp3"
};

static char g_strHaleLastMan[][] = {
	"saxton_hale/saxton_hale_responce_2.mp3",
	"saxton_hale/saxton_hale_132_last.mp3",
	"saxton_hale/saxton_hale_responce_lastman1.mp3",
	"saxton_hale/saxton_hale_responce_lastman2.mp3",
	"saxton_hale/saxton_hale_responce_lastman3.mp3",
	"saxton_hale/saxton_hale_responce_lastman4.mp3",
	"saxton_hale/saxton_hale_responce_lastman5.mp3"
};

static char g_strHaleBackStabbed[][] = {
	"saxton_hale/saxton_hale_132_stub_1.mp3",
	"saxton_hale/saxton_hale_132_stub_2.mp3",
	"saxton_hale/saxton_hale_132_stub_3.mp3",
	"saxton_hale/saxton_hale_132_stub_4.mp3"
};

methodmap CSaxtonHale < CBaseBoss
{
	public CSaxtonHale(CBaseBoss boss)
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
		return TFClass_Soldier;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65 ; 214 ; %d", GetRandomInt(9999, 99999));
		return CreateWeapon(this.Index, "tf_weapon_fists", 195, 100, TFQual_Strange, attribs);
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, HALE_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleRoundStart[GetRandomInt(0,sizeof(g_strHaleRoundStart)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleWin[GetRandomInt(0,sizeof(g_strHaleWin)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleLose[GetRandomInt(0,sizeof(g_strHaleLose)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleRage[GetRandomInt(0,sizeof(g_strHaleRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strHaleJump[GetRandomInt(0,sizeof(g_strHaleJump)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		switch (playerClass)
		{
			case TFClass_Scout:
				strcopy(sSound, length, g_strHaleKillScout[GetRandomInt(0,sizeof(g_strHaleKillScout)-1)]);
			case TFClass_Sniper:
				strcopy(sSound, length, g_strHaleKillSniper[GetRandomInt(0,sizeof(g_strHaleKillSniper)-1)]);
			case TFClass_DemoMan:
				strcopy(sSound, length, g_strHaleKillDemoMan[GetRandomInt(0,sizeof(g_strHaleKillDemoMan)-1)]);
			case TFClass_Heavy:
				strcopy(sSound, length, g_strHaleKillHeavy[GetRandomInt(0,sizeof(g_strHaleKillHeavy)-1)]);
			case TFClass_Medic:
				strcopy(sSound, length, g_strHaleKillMedic[GetRandomInt(0,sizeof(g_strHaleKillMedic)-1)]);
			case TFClass_Spy:
				strcopy(sSound, length, g_strHaleKillSpy[GetRandomInt(0,sizeof(g_strHaleKillSpy)-1)]);
			case TFClass_Engineer:
				strcopy(sSound, length, g_strHaleKillEngie[GetRandomInt(0,sizeof(g_strHaleKillEngie)-1)]);
		}
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleLastMan[GetRandomInt(0,sizeof(g_strHaleLastMan)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strHaleBackStabbed[GetRandomInt(0,sizeof(g_strHaleBackStabbed)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)//Block voicelines
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrecacheModel(HALE_MODEL);
		for (int i = 0; i <= sizeof(g_strHaleRoundStart)-1; i++) PrepareSound(g_strHaleRoundStart[i]);
		for (int i = 0; i <= sizeof(g_strHaleWin)-1; i++) PrepareSound(g_strHaleWin[i]);
		for (int i = 0; i <= sizeof(g_strHaleLose)-1; i++) PrepareSound(g_strHaleLose[i]);
		for (int i = 0; i <= sizeof(g_strHaleRage)-1; i++) PrepareSound(g_strHaleRage[i]);
		for (int i = 0; i <= sizeof(g_strHaleJump)-1; i++) PrepareSound(g_strHaleJump[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillScout)-1; i++) PrepareSound(g_strHaleKillScout[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillSniper)-1; i++) PrepareSound(g_strHaleKillSniper[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillDemoMan)-1; i++) PrepareSound(g_strHaleKillDemoMan[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillHeavy)-1; i++) PrepareSound(g_strHaleKillHeavy[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillMedic)-1; i++) PrepareSound(g_strHaleKillMedic[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillPyro)-1; i++) PrepareSound(g_strHaleKillPyro[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillSpy)-1; i++) PrepareSound(g_strHaleKillSpy[i]);
		for (int i = 0; i <= sizeof(g_strHaleKillEngie)-1; i++) PrepareSound(g_strHaleKillEngie[i]);
		for (int i = 0; i <= sizeof(g_strHaleLastMan)-1; i++) PrepareSound(g_strHaleLastMan[i]);
		for (int i = 0; i <= sizeof(g_strHaleBackStabbed)-1; i++) PrepareSound(g_strHaleBackStabbed[i]);
		
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/tongue_saxxy.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_hat_saxxy.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_hat_saxxy.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_hat_color.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_hat_color.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body_saxxy.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body_saxxy.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body_normal.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body_exp.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body_alt.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_body.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_belt_high_normal.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_belt_high.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_belt_high.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/saxton_belt.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head_exponent.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head_normal.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head_saxxy.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/saxton_head_saxxy.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/tongue.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/hwm/tongue.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eye.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eyeball_r.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eyeball_l.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eyeball_saxxy.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eye-extra.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/eye-saxxy.vtf");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/inv.vmt");
		AddFileToDownloadsTable("materials/models/player/hwm_saxton_hale/shades/null.vtf");
		
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.phy");
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale_jungle_inferno/saxton_hale.dx90.vtx");
	}
}
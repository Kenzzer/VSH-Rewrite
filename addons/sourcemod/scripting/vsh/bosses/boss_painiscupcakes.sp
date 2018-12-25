#define PAINIS_RAGE_MUSIC "vsh_rewrite/painis/rage.mp3"

static char g_strPainisRoundStart[][] = {
	"vsh_rewrite/painis/intro.mp3"
};

static char g_strPainisWin[][] = {
	"vo/soldier_laughevil01.mp3",
	"vo/soldier_laughevil02.mp3",
	"vo/soldier_laughevil03.mp3"
};

static char g_strPainisLose[][] = {
	"vo/soldier_autodejectedtie03.mp3"
};

static char g_strPainisRage[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3",
	"vo/soldier_paincrticialdeath04.mp3"
};

static char g_strPainisJump[][] = {
	"vo/soldier_laughshort01.mp3",
	"vo/soldier_laughshort02.mp3",
	"vo/soldier_laughshort03.mp3",
	"vo/soldier_laughshort04.mp3"
};

static char g_strPainisKillScout[][] = {
	"vo/soldier_dominationscout11.mp3"
};

static char g_strPainisKillSniper[][] = {
	"vo/soldier_dominationsniper12.mp3"
};

static char g_strPainisKillDemoMan[][] = {
	"vo/soldier_dominationdemoman02.mp3"
};

static char g_strPainisKillMedic[][] = {
	"vo/soldier_dominationmedic07.mp3"
};

static char g_strPainisKillSpy[][] = {
	"vo/soldier_dominationspy01.mp3"
};

static char g_strPainisKillEngie[][] = {
	"vo/soldier_dominationengineer04.mp3"
};

static char g_strPainisLastMan[][] = {
	"vo/soldier_pickaxetaunt01.mp3",
	"vo/soldier_pickaxetaunt02.mp3",
	"vo/soldier_pickaxetaunt03.mp3",
	"vo/soldier_pickaxetaunt04.mp3",
	"vo/soldier_pickaxetaunt05.mp3"
};

static char g_strPainisBackStabbed[][] = {
	"vo/soldier_weapon_taunts05.mp3",
	"vo/soldier_weapon_taunts04.mp3",
	"vo/soldier_weapon_taunts01.mp3"
};

static char g_strPainisFootsteps[][] = {
	"weapons/shotgun_cock_back.wav",
	"weapons/shotgun_cock_forward.wav"
};

methodmap CPainisCupcake < CBaseBoss
{
	public CPainisCupcake(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		
		CBodyEat bodyeat = view_as<CBodyEat>(boss.RegisterAbility("CBodyEat"));
		bodyeat.iMaxHeal = 500;
		bodyeat.flMaxEatDistance = 100.0;
		bodyeat.flEatRageRadius = 450.0;
		bodyeat.flEatRageDuration = 10.0;
		bodyeat.HUD_Y = 0.92;
		
		CLightRage light = view_as<CLightRage>(boss.RegisterAbility("CLightRage"));
		light.flLigthRageDuration = 10.0;
		light.flLightRageRadius = 450.0;
		light.iRageLightBrigthness = 10;
		
		CRageAddCond rageCond = view_as<CRageAddCond>(boss.RegisterAbility("CRageAddCond"));
		rageCond.flRageCondDuration = 10.0;
		rageCond.AddCond(TFCond_UberchargedCanteen);
		rageCond.AddCond(TFCond_SpeedBuffAlly);
		
		boss.iMaxRageDamage = 2000;
	}
	
	public int GetBaseHealth()
	{
		return 1000;
	}
	
	public int GetHealthPerPlayer()
	{
		return 650;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Soldier;
	}
	
	public void OnRage(bool bSuperRage)
	{
		IAbility ability = this.FindAbility("CLightRage");
		if (ability != INVALID_ABILITY)
		{
			CLightRage light = view_as<CLightRage>(ability);
			int iColor[4];
			if (GetClientTeam(this.Index) == TFTeam_Red)
			{
				iColor[0] = 255;
				iColor[1] = 0;
				iColor[2] = 0;
			}
			else
			{
				iColor[0] = 0;
				iColor[1] = 0;
				iColor[2] = 255;
			}
			
			iColor[3] = 255;
			light.SetColor(iColor);
		}
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_shovel", 196, 100, TFQual_Strange, attribs);
		SetEntProp(iWep, Prop_Send, "m_iWorldModelIndex", -1);
		return iWep;
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisRoundStart[GetRandomInt(0,sizeof(g_strPainisRoundStart)-1)]);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisWin[GetRandomInt(0,sizeof(g_strPainisWin)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisLose[GetRandomInt(0,sizeof(g_strPainisLose)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisRage[GetRandomInt(0,sizeof(g_strPainisRage)-1)]);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strPainisJump[GetRandomInt(0,sizeof(g_strPainisJump)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
		switch (playerClass)
		{
			case TFClass_Scout:
				strcopy(sSound, length, g_strPainisKillScout[GetRandomInt(0,sizeof(g_strPainisKillScout)-1)]);
			case TFClass_Sniper:
				strcopy(sSound, length, g_strPainisKillSniper[GetRandomInt(0,sizeof(g_strPainisKillSniper)-1)]);
			case TFClass_DemoMan:
				strcopy(sSound, length, g_strPainisKillDemoMan[GetRandomInt(0,sizeof(g_strPainisKillDemoMan)-1)]);
			case TFClass_Medic:
				strcopy(sSound, length, g_strPainisKillMedic[GetRandomInt(0,sizeof(g_strPainisKillMedic)-1)]);
			case TFClass_Spy:
				strcopy(sSound, length, g_strPainisKillSpy[GetRandomInt(0,sizeof(g_strPainisKillSpy)-1)]);
			case TFClass_Engineer:
				strcopy(sSound, length, g_strPainisKillEngie[GetRandomInt(0,sizeof(g_strPainisKillEngie)-1)]);
		}
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisLastMan[GetRandomInt(0,sizeof(g_strPainisLastMan)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strPainisBackStabbed[GetRandomInt(0,sizeof(g_strPainisBackStabbed)-1)]);
	}
	
	public void GetRageMusicInfo(char[] sSound, int length, float &time)
	{
		strcopy(sSound, length, PAINIS_RAGE_MUSIC);
		time = 22.0;
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if(StrContains(sample, "player/footsteps/", false) != -1)
		{
			EmitSoundToAll(g_strPainisFootsteps[GetRandomInt(0, sizeof(g_strPainisFootsteps)-1)], this.Index, _, _, _, 0.13, GetRandomInt(95, 100));
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrepareSound(PAINIS_RAGE_MUSIC);
		for (int i = 0; i <= sizeof(g_strPainisRoundStart)-1; i++) PrepareSound(g_strPainisRoundStart[i]);
		for (int i = 0; i <= sizeof(g_strPainisWin)-1; i++) PrepareSound(g_strPainisWin[i]);
		for (int i = 0; i <= sizeof(g_strPainisLose)-1; i++) PrepareSound(g_strPainisLose[i]);
		for (int i = 0; i <= sizeof(g_strPainisRage)-1; i++) PrepareSound(g_strPainisRage[i]);
		for (int i = 0; i <= sizeof(g_strPainisJump)-1; i++) PrepareSound(g_strPainisJump[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillScout)-1; i++) PrepareSound(g_strPainisKillScout[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillSniper)-1; i++) PrepareSound(g_strPainisKillSniper[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillDemoMan)-1; i++) PrepareSound(g_strPainisKillDemoMan[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillMedic)-1; i++) PrepareSound(g_strPainisKillMedic[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillSpy)-1; i++) PrepareSound(g_strPainisKillSpy[i]);
		for (int i = 0; i <= sizeof(g_strPainisKillEngie)-1; i++) PrepareSound(g_strPainisKillEngie[i]);
		for (int i = 0; i <= sizeof(g_strPainisLastMan)-1; i++) PrepareSound(g_strPainisLastMan[i]);
		for (int i = 0; i <= sizeof(g_strPainisBackStabbed)-1; i++) PrepareSound(g_strPainisBackStabbed[i]);
		for (int i = 0; i <= sizeof(g_strPainisFootsteps)-1; i++) PrepareSound(g_strPainisFootsteps[i]);
	}
}
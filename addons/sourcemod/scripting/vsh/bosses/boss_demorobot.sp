static char g_strSoundRobotFootsteps[][] =
{
	"mvm/player/footsteps/robostep_01.wav",
	"mvm/player/footsteps/robostep_02.wav",
	"mvm/player/footsteps/robostep_03.wav",
	"mvm/player/footsteps/robostep_04.wav",
	"mvm/player/footsteps/robostep_05.wav",
	"mvm/player/footsteps/robostep_06.wav",
	"mvm/player/footsteps/robostep_07.wav",
	"mvm/player/footsteps/robostep_08.wav",
	"mvm/player/footsteps/robostep_09.wav",
	"mvm/player/footsteps/robostep_10.wav",
	"mvm/player/footsteps/robostep_11.wav",
	"mvm/player/footsteps/robostep_12.wav",
	"mvm/player/footsteps/robostep_13.wav",
	"mvm/player/footsteps/robostep_14.wav",
	"mvm/player/footsteps/robostep_15.wav",
	"mvm/player/footsteps/robostep_16.wav",
	"mvm/player/footsteps/robostep_17.wav",
	"mvm/player/footsteps/robostep_18.wav"
};

static char g_strSoundGiantFootsteps[][] =
{
	"^mvm/giant_common/giant_common_step_01.wav",
	"^mvm/giant_common/giant_common_step_02.wav",
	"^mvm/giant_common/giant_common_step_03.wav",
	"^mvm/giant_common/giant_common_step_04.wav",
	"^mvm/giant_common/giant_common_step_05.wav",
	"^mvm/giant_common/giant_common_step_06.wav",
	"^mvm/giant_common/giant_common_step_07.wav",
	"^mvm/giant_common/giant_common_step_08.wav"
};

static char g_strDemoRobotSpawn[][] = {
	"vo/mvm/mght/demoman_mvm_m_eyelandertaunt01.mp3",
	"vo/mvm/mght/demoman_mvm_m_eyelandertaunt02.mp3",
	"vo/mvm/mght/demoman_mvm_m_dominationdemoman01.mp3",
	"vo/mvm/mght/demoman_mvm_m_specialcompleted08.mp3",
	"vo/mvm/mght/demoman_mvm_m_laughevil03.mp3"
};

static char g_strDemoRobotWin[][] = {
	"vo/mvm/mght/demoman_mvm_m_laughevil01.mp3",
	"vo/mvm/mght/demoman_mvm_m_laughevil02.mp3",
	"vo/mvm/mght/demoman_mvm_m_laughevil03.mp3",
	"vo/mvm/mght/demoman_mvm_m_laughevil04.mp3",
	"vo/mvm/mght/demoman_mvm_m_laughevil05.mp3"
};

static char g_strDemoRobotLastMan[][] = {
	"vo/mvm/mght/demoman_mvm_m_cheers03.mp3",
	"vo/mvm/mght/demoman_mvm_m_cheers05.mp3",
	"vo/mvm/mght/demoman_mvm_m_cheers06.mp3"
};

static char g_strDemoRobotJump[][] = {
	"vo/mvm/mght/demoman_mvm_m_battlecry01.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry02.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry03.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry04.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry05.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry06.mp3",
	"vo/mvm/mght/demoman_mvm_m_battlecry07.mp3"
};

static char g_strDemoRobotBackStab[][] = {
	"vo/mvm/mght/demoman_mvm_m_autodejectedtie01.mp3",
	"vo/mvm/mght/demoman_mvm_m_autodejectedtie02.mp3"
};

#define DEMO_ROBOT_TURN_INTO_GIANT  			"mvm/giant_heavy/giant_heavy_entrance.wav"
#define DEMO_ROBOT_THEME						"vsh_rewrite/glitched/theme.mp3"
#define DEMO_ROBOT_DEATH						"mvm/sentrybuster/mvm_sentrybuster_explode.wav"
#define DEMO_ROBOT_MODEL						"models/bots/demo/bot_demo.mdl"
#define DEMO_ROBOT_MODEL_GIANT					"models/bots/demo_boss/bot_demo_boss.mdl"
#define DEMO_ROBOT_GRENADE_LAUNCHER_SHOOT		"mvm/giant_demoman/giant_demoman_grenade_shoot.wav"

static int g_iParticleBotImpactHeavy;
static int g_iParticleBotImpactLight;
static float g_flGrenadeLauncherRemoveTime[MAXPLAYERS+1];

methodmap CDemoRobot < CBaseBoss
{
	public CDemoRobot(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.iMaxRageDamage = 2200;
		g_flGrenadeLauncherRemoveTime[boss.Index] = 0.0;
		
		//SendProxy_Unhook(boss.Index, "m_flModelScale", Hook_GiantScale);
		//SendProxy_Hook(boss.Index, "m_flModelScale", Prop_Float, Hook_GiantScale);
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
		return TFClass_DemoMan;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 1.75 ; 2 ; 2.80 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65 ; 436 ; 1.0 ; 218 ; 1.0");
		return CreateWeapon(this.Index, "tf_weapon_sword", 132, 100, TFQual_Collectors, attribs);
	}
	
	public void GetModel(char[] sModel, int length)
	{
		if(GetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss"))
			strcopy(sModel, length, DEMO_ROBOT_MODEL_GIANT);
		else
			strcopy(sModel, length, DEMO_ROBOT_MODEL);
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strDemoRobotSpawn[GetRandomInt(0,sizeof(g_strDemoRobotSpawn)-1)]);
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
		strcopy(sSound, length, DEMO_ROBOT_DEATH);
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strDemoRobotWin[GetRandomInt(0,sizeof(g_strDemoRobotWin)-1)]);
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
		strcopy(sSound, length, DEMO_ROBOT_TURN_INTO_GIANT);
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
		if (strcmp(sType, "CBraveJump") == 0)
			strcopy(sSound, length, g_strDemoRobotJump[GetRandomInt(0,sizeof(g_strDemoRobotJump)-1)]);
	}
	
	public void GetClassKillSound(char[] sSound, int length, TFClassType playerClass)
	{
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strDemoRobotLastMan[GetRandomInt(0,sizeof(g_strDemoRobotLastMan)-1)]);
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
		strcopy(sSound, length, g_strDemoRobotBackStab[GetRandomInt(0,sizeof(g_strDemoRobotBackStab)-1)]);
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
		{
			char file[PLATFORM_MAX_PATH];
			strcopy(file, PLATFORM_MAX_PATH, sample);
			ReplaceString(file, sizeof(file), "vo/", "vo/mvm/norm/", false);
			Format(file, sizeof(file), "sound/%s", file);
			
			if (FileExists(file, true))
			{
				ReplaceString(sample, sizeof(sample), "vo/", "vo/mvm/norm/", false);
				return Plugin_Changed;
			}
			return Plugin_Continue;
		}
		if(StrContains(sample, "player/footsteps/", false) != -1 && !GetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss"))
		{
			EmitSoundToAll(g_strSoundRobotFootsteps[GetRandomInt(0, sizeof(g_strSoundRobotFootsteps)-1)], this.Index, _, _, _, 0.13, GetRandomInt(95, 100));
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
		strcopy(sSound, length, DEMO_ROBOT_THEME);
		time = 140.0;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		if (GetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss"))
		{
			damage *= 0.90;
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	
	public void OnRage(bool bSuperRage)
	{
		TF2_RemoveItemInSlot(this.Index, WeaponSlot_Primary);
		
		int iWep = CreateWeapon(this.Index, "tf_weapon_grenadelauncher", 206, 100, TFQual_Unusual, "318 ; 0.6 ; 6 ; 0.3 ; 440 ; 3.0 ; 76 ; 10.0 ; 15 ; 1.0 ; 112 ; 100.0 ; 330 ; 4.0");
		if (iWep > MaxClients)
		{
			SetEntProp(iWep, Prop_Send, "m_bValidatedAttachedEntity", true);
			SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", true);
			EquipPlayerWeapon(this.Index, iWep);
			SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
		}
		
		g_flGrenadeLauncherRemoveTime[this.Index] = GetGameTime()+10.0;
	}
	
	public void Think()
	{
		if (g_flGrenadeLauncherRemoveTime[this.Index] != 0.0 && g_flGrenadeLauncherRemoveTime[this.Index] <= GetGameTime())
		{
			TF2_RemoveItemInSlot(this.Index, WeaponSlot_Primary);
			SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", false);
			g_flGrenadeLauncherRemoveTime[this.Index] = 0.0;
			
			int iWep = GetPlayerWeaponSlot(this.Index, WeaponSlot_Melee);
			if (iWep > MaxClients)
				SetEntPropEnt(this.Index, Prop_Send, "m_hActiveWeapon", iWep);
		}
	}
	
	public void GetEyeHeigth(float vecEyeHeight[3])
	{
		if (GetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss"))
			ScaleVector(vecEyeHeight, 1.75);
	}
	
	public void Precache()
	{
		for (int i = 0; i <= sizeof(g_strSoundRobotFootsteps)-1; i++) PrecacheSound(g_strSoundRobotFootsteps[i]);
		for (int i = 0; i <= sizeof(g_strSoundGiantFootsteps)-1; i++) PrecacheSound(g_strSoundGiantFootsteps[i]);
		for (int i = 0; i <= sizeof(g_strDemoRobotWin)-1; i++) PrecacheSound(g_strDemoRobotWin[i]);
		for (int i = 0; i <= sizeof(g_strDemoRobotSpawn)-1; i++) PrecacheSound(g_strDemoRobotSpawn[i]);
		for (int i = 0; i <= sizeof(g_strDemoRobotBackStab)-1; i++) PrecacheSound(g_strDemoRobotBackStab[i]);
		for (int i = 0; i <= sizeof(g_strDemoRobotLastMan)-1; i++) PrecacheSound(g_strDemoRobotLastMan[i]);
		
		PrecacheSound(DEMO_ROBOT_TURN_INTO_GIANT);
		PrecacheSound(DEMO_ROBOT_DEATH);
		PrecacheSound(DEMO_ROBOT_GRENADE_LAUNCHER_SHOOT);
		PrepareSound(DEMO_ROBOT_THEME);
		
		PrecacheModel(DEMO_ROBOT_MODEL);
		PrecacheModel(DEMO_ROBOT_MODEL_GIANT);
	}
	
	public void Destroy()
	{
		SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", false);
		//SendProxy_Unhook(this.Index, "m_flModelScale", Hook_GiantScale);
	}
}

public Action Hook_GiantScale(int entity, const char[] PropName, float &flValue, int element)
{
	if (GetEntProp(entity, Prop_Send, "m_bIsMiniBoss"))
	{
		flValue = 1.75;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
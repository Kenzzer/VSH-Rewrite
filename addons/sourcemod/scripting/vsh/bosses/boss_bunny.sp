#define BUNNY_MODEL						"models/player/saxton_hale/easter_demo.mdl"

methodmap CBunny < CBaseBoss
{
	public CBunny(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.RegisterAbility("CEasterEgg");
		boss.iMaxRageDamage = 2200;
	}
	
	public int GetBaseHealth()
	{
		return 900;
	}
	
	public int GetHealthPerPlayer()
	{
		return 600;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_DemoMan;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 1.9 ; 252 ; 0.5 ; 259 ; 1.0 ; 329 ; 0.65");
		int iWep = CreateWeapon(this.Index, "tf_weapon_bottle", 5, 100, TFQual_Collectors, attribs);
		return iWep;
	}
	
	public void GetName(char[] sName, int length)
	{
		strcopy(sName, length, "Easter Bunny");
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, BUNNY_MODEL);
	}
	
	public void GetRoundStartMusic(char[] sSound, int length)
	{
	}
	
	public void GetRoundStartSound(char[] sSound, int length)
	{
	}
	
	public void GetLoseSound(char[] sSound, int length)
	{
	}
	
	public void GetWinSound(char[] sSound, int length)
	{
	}
	
	public void GetRageSound(char[] sSound, int length)
	{
	}
	
	public void GetAbilitySound(char[] sSound, int length, char[] sType)
	{
	}
	
	public void GetLastManSound(char[] sSound, int length)
	{
	}
	
	public void GetBackstabSound(char[] sSound, int length)
	{
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		return Plugin_Continue;
	}
	
	public void GetMusicInfo(char[] sSound, int length, float &time, float &delay)
	{
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		if (inflictor > MaxClients)
		{
			char strInflictor[32];
			GetEdictClassname(inflictor, strInflictor, sizeof(strInflictor));
			if(strcmp(strInflictor, "tf_projectile_pipe") == 0 && attacker == this.Index)
			{
				damage = 0.0;
				return Plugin_Changed;
			}
		}
		return Plugin_Continue;
	}
	
	public void OnRage(bool bSuperRage)
	{
	}
	
	public void Precache()
	{
		PrecacheModel(BUNNY_MODEL);
		PrecacheModel(EGG_MODEL);
		
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit.vtf");
		AddFileToDownloadsTable("materials/models/player/easter_demo/eyeball_r.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_rabbit_normal.vtf");
		AddFileToDownloadsTable("materials/models/player/easter_demo/demoman_head_red.vmt");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vtf");
		AddFileToDownloadsTable("materials/models/player/easter_demo/easter_body.vmt");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg_gold.vmt");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vtf");
		AddFileToDownloadsTable("materials/models/props_easteregg/c_easteregg.vmt");
		
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.phy");
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/w_easteregg.dx90.vtx");
		
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.mdl");
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.phy");
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.sw.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.vvd");
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.dx80.vtx");
		AddFileToDownloadsTable("models/player/saxton_hale/easter_demo.dx90.vtx");
	}
	
	public void Destroy()
	{
	}
}
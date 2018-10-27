methodmap CSentryGun < CBaseBoss
{
	public CSentryGun(CBaseBoss boss)
	{
		boss.iMaxRageDamage = -1;
	}
	
	public int GetBaseHealth()
	{
		return 2000;
	}
	
	public int GetHealthPerPlayer()
	{
		return 0;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_Scout;
	}
	
	public int SpawnWeapon()
	{
		return -1;
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, "models/buildables/sentry3.mdl");
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void Precache()
	{
		PrecacheModel("models/buildables/sentry3.mdl");
	}
}
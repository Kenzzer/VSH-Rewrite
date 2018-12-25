void Natives_Init()
{
	CreateNative("VSHBoss.iMaxHealth.get", Native_VSHBossiMaxHealth);
	CreateNative("VSHBoss.iHealth.get", Native_VSHBossiHealth);
	CreateNative("VSHBoss.IsMinion.get", Native_VSHIsMinion);
	CreateNative("VSHBoss.IsValid.get", Native_VSHIsValid);
}

public int Native_VSHBossiMaxHealth(Handle plugin, int numParams)
{
	return g_clientBoss[GetNativeCell(1)].iMaxHealth;
}

public int Native_VSHBossiHealth(Handle plugin, int numParams)
{
	return g_clientBoss[GetNativeCell(1)].iHealth;
}

public int Native_VSHIsMinion(Handle plugin, int numParams)
{
	return g_clientBoss[GetNativeCell(1)].IsMinion;
}

public int Native_VSHIsValid(Handle plugin, int numParams)
{
	return g_clientBoss[GetNativeCell(1)].IsValid();
}

void Preferences_Save(int iClient)
{
	char s[64];
	Format(s, sizeof(s), "%d ; %d", g_iPlayerPreferences[iClient][PlayerPreference_PickAsBoss], 
		g_iPlayerPreferences[iClient][PlayerPreference_RevivalSelect]);
		
	SetClientCookie(iClient, g_hPlayerPreferences, s);
}

void Preferences_Get(int iClient)
{
	// Load our saved settings.
	char sCookie[64];
	GetClientCookie(iClient, g_hPlayerPreferences, sCookie, sizeof(sCookie));
	
	g_iPlayerPreferences[iClient][PlayerPreference_PickAsBoss] = true;
	g_iPlayerPreferences[iClient][PlayerPreference_RevivalSelect] = true;
	
	if (sCookie[0])
	{
		char s2[12][32];
		int count = ExplodeString(sCookie, " ; ", s2, 12, 32);
		
		if (count > 0)
			g_iPlayerPreferences[iClient][PlayerPreference_PickAsBoss] = view_as<bool>(StringToInt(s2[0]));
		if (count > 1)
			g_iPlayerPreferences[iClient][PlayerPreference_RevivalSelect] = view_as<bool>(StringToInt(s2[1]));
	}
}
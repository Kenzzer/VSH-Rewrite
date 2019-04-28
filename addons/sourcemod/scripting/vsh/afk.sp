// AFK Data
static int g_iPlayerAfkLastButtons[TF_MAXPLAYERS+1];
static float g_vecPlayerAfkEyeAngles[TF_MAXPLAYERS+1][3];
static float g_flPlayerLastAfkTime[TF_MAXPLAYERS+1];
static float g_flAfkLookupTime = 0.0;
static float g_flAfkMaxTime = 0.0;

void AFK_CleanUp()
{
	g_flAfkLookupTime = 0.0;
	g_flAfkMaxTime = 0.0;
}

void AFK_BeginTrack(float flTrackTime, float flAFKMaxTime)
{
	float flGameTime = GetGameTime();
	
	g_flAfkLookupTime = flGameTime+flTrackTime;
	g_flAfkMaxTime = flAFKMaxTime;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		g_flPlayerLastAfkTime[i] = 0.0;
		g_iPlayerAfkLastButtons[i] = 0;
		if (IsClientInGame(i))
		{
			g_flPlayerLastAfkTime[i] = flGameTime;
			g_iPlayerAfkLastButtons[i] = GetClientButtons(i);
		}
	}
}

void AFK_Think()
{
	float flGameTime = GetGameTime();
	if (flGameTime > g_flAfkLookupTime) return;
	
	bool bAFK = false;
	int iTrigger = FindEntityByClassname(-1, "trigger_hurt");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) > 1)
		{
			float flDiff = 0.0, vecAng[3];
			GetClientEyeAngles(i, vecAng);
			for (int j = 0; j < 3; j++) // compute new angles
				flDiff += FloatAbs(vecAng[j] - g_vecPlayerAfkEyeAngles[i][j]);
			
			int iCurrentButtons = GetClientButtons(i);
			if (flDiff > 0.1 || g_iPlayerAfkLastButtons[i] != iCurrentButtons || g_flPlayerLastAfkTime[i] == 0.0) // Enough to prove they're not AFK
				g_flPlayerLastAfkTime[i] = flGameTime;
			
			// Update data for next frame
			g_vecPlayerAfkEyeAngles[i] = vecAng;
			g_iPlayerAfkLastButtons[i] = iCurrentButtons;
			
			if (g_flPlayerLastAfkTime[i] < (flGameTime-g_flAfkMaxTime+5.0))
				PrintCenterText(i, "You are currently AFK. Please Move! %0.0f sec left", g_flAfkMaxTime-(flGameTime-g_flPlayerLastAfkTime[i]));
			
			if (g_flPlayerLastAfkTime[i] < flGameTime-g_flAfkMaxTime)
			{
				PrintToChatAll("%s %sSlayed and moved to spectator team %s%N%s for being AFK...", VSH_TAG, VSH_TEXT_COLOR, g_strTeamColors[GetClientTeam(i)], i, VSH_TEXT_COLOR);
				
				// They've been afk for too long
				SDKHooks_TakeDamage(i, iTrigger, iTrigger, 9999999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
				bAFK = true;
				ChangeClientTeam(i, TFTeam_Spectator);
				SetEntProp(i, Prop_Send, "m_lifeState", LifeState_Dead);
			}
		}
	}
	
	if (bAFK)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) > 1 && IsPlayerAlive(i))
			{
				// Recompute the health for bosses
				if (g_clientBoss[i].IsValid())
				{
					float flRatio = float(g_clientBoss[i].iHealth)/float(g_clientBoss[i].iMaxHealth);
					g_clientBoss[i].RecalculateMaxHealth();
					
					g_clientBoss[i].iHealth = RoundToCeil(float(g_clientBoss[i].iMaxHealth)*flRatio);
				}
			}
		}
	}
}
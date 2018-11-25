static Handle g_hQueueCookies;
static int g_iClientQueuePoints[MAXPLAYERS+1];

void Queue_Init()
{
	g_hQueueCookies = RegClientCookie("vsh_players_queue_points", "Amount of VSH Queue points player has", CookieAccess_Protected);
}

void Queue_OnClientConnect(int iClient)
{
	char sPoints[12];
	GetClientCookie(iClient, g_hQueueCookies, sPoints, sizeof(sPoints));
	g_iClientQueuePoints[iClient] = StringToInt(sPoints);
	if (g_iClientQueuePoints[iClient] < 0) g_iClientQueuePoints[iClient] = 0;
}

void Queue_OnClientDisconnect(int iClient)
{
	char sPoints[12];
	IntToString(g_iClientQueuePoints[iClient], sPoints, sizeof(sPoints));
	SetClientCookie(iClient, g_hQueueCookies, sPoints);
}

int Queue_GetTopPlayer()
{
	int iMaxPoint = -9999999, iTopPlayer = -1;
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient))
		{
			if (g_iClientQueuePoints[iClient] > iMaxPoint && g_iPlayerPreferences[iClient][PlayerPreference_PickAsBoss])
			{
				iTopPlayer = iClient;
				iMaxPoint = g_iClientQueuePoints[iClient];
			}
		}
	}
	return iTopPlayer;
}

void Queue_AddPlayerPoints(int iClient, int iPoints)
{
	if (!g_iPlayerPreferences[iClient][PlayerPreference_PickAsBoss])
	{
		PrintToChat(iClient, "%s %s No points awarded as you do not wish to play as boss.", VSH_TAG, VSH_TEXT_COLOR);
		return;
	}
	
	g_iClientQueuePoints[iClient] += iPoints;
	PrintToChat(iClient, "%s %s You have been awarded %d queue points! (Total: %i)", VSH_TAG, VSH_TEXT_COLOR, iPoints, g_iClientQueuePoints[iClient]);
}

void Queue_ResetPlayer(int iClient)
{
	g_iClientQueuePoints[iClient] = 0;
}

int Queue_PlayerGetPoints(int iClient)
{
	return g_iClientQueuePoints[iClient];
}
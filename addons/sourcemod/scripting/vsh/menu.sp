Handle g_hMenuMain;
Handle g_hMenuCredits;
Handle g_hMenuCredits2;
Handle g_hMenuCredits3;
Handle g_hMenuSettings;
Handle g_hMenuHelp;

Handle g_hBossSelect;
Handle g_hRevivalSelect;

void Menus_Setup()
{
	char buffer[512];
	
	// Create menus.
	// To-do add translations support.
	g_hMenuMain = CreateMenu(Menu_Main);
	SetMenuTitle(g_hMenuMain, "[VSH REWRITE] - %s\n \n",PLUGIN_VERSION);
	Format(buffer, sizeof(buffer), "Help Menu (!vshhelp)");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "Queue List (!vshnext)");
	AddMenuItem(g_hMenuMain, "0", buffer);
	Format(buffer, sizeof(buffer), "Settings (!vshsettings)");
	AddMenuItem(g_hMenuMain, "0", buffer);
	strcopy(buffer, sizeof(buffer), "Credits (!vshcredits)");
	AddMenuItem(g_hMenuMain, "0", buffer);
	
	
	g_hMenuHelp = CreateMenu(MenuPanel_HandlerNothing);
	SetMenuExitBackButton(g_hMenuHelp, true);
	
	g_hMenuCredits = CreateMenu(Menu_Credits);
	
	Format(buffer, sizeof(buffer), "Credits\n \n");
	StrCat(buffer, sizeof(buffer), "Coder: Benoist3012\n");
	StrCat(buffer, sizeof(buffer), "\n \n");
	StrCat(buffer, sizeof(buffer), "Eggman - The creator of the first VSH\n");
	StrCat(buffer, sizeof(buffer), "Alex Turtle & Chillax - Great test subjects!\n");
	StrCat(buffer, sizeof(buffer), "RedSun - Host community!\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---\n");
	StrCat(buffer, sizeof(buffer), "---[UNCLAIMED CREDIT SLOT]---");
	
	SetMenuTitle(g_hMenuCredits, buffer);
	AddMenuItem(g_hMenuCredits, "0", "Next");
	AddMenuItem(g_hMenuCredits, "1", "Back");
	
	g_hMenuCredits2 = CreateMenu(Menu_Credits2);
	
	Format(buffer, sizeof(buffer), "Weapons Rebalance Credits\n \n");
	StrCat(buffer, sizeof(buffer), " \n \n");
	StrCat(buffer, sizeof(buffer), "Sadim\n");
	StrCat(buffer, sizeof(buffer), "Palon\n");
	StrCat(buffer, sizeof(buffer), "NotPaddy\n");
	StrCat(buffer, sizeof(buffer), "DaveFlare\n");
	StrCat(buffer, sizeof(buffer), "PestoVerde\n");
	StrCat(buffer, sizeof(buffer), "Spark\n");
	StrCat(buffer, sizeof(buffer), "Blotz\n");
	StrCat(buffer, sizeof(buffer), "Robotnik\n");
	StrCat(buffer, sizeof(buffer), "FrostyScales\n");
	StrCat(buffer, sizeof(buffer), "Bone\n \n");
	
	SetMenuTitle(g_hMenuCredits2, buffer);
	AddMenuItem(g_hMenuCredits2, "0", "Next");
	AddMenuItem(g_hMenuCredits2, "1", "Back");
	
	g_hMenuCredits3 = CreateMenu(Menu_Credits3);
	
	Format(buffer, sizeof(buffer), "Alpha-Test Credits\n \n");
	StrCat(buffer, sizeof(buffer), "And to all the peeps who alpha-tested this thing!\n \n");
	StrCat(buffer, sizeof(buffer), "Bone\n");
	StrCat(buffer, sizeof(buffer), "NotPaddy\n");
	StrCat(buffer, sizeof(buffer), "Blotz\n");
	StrCat(buffer, sizeof(buffer), "GeeNoVoid\n");
	StrCat(buffer, sizeof(buffer), "Quentquent\n");
	StrCat(buffer, sizeof(buffer), "Harumaki\n");
	StrCat(buffer, sizeof(buffer), "42\n");
	StrCat(buffer, sizeof(buffer), "Robotnik\n");
	StrCat(buffer, sizeof(buffer), "FrostyScales\n");
	StrCat(buffer, sizeof(buffer), "Darthmule\n \n");
	
	SetMenuTitle(g_hMenuCredits3, buffer);
	AddMenuItem(g_hMenuCredits3, "0", "Back");
	
	g_hMenuSettings = CreateMenu(Menu_Settings);
	SetMenuTitle(g_hMenuSettings, "Settings \n \n");
	Format(buffer, sizeof(buffer), "Toggle Boss Selection");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	strcopy(buffer, sizeof(buffer), "Revival Preference");
	AddMenuItem(g_hMenuSettings, "0", buffer);
	
	g_hBossSelect = CreateMenu(Menu_Toggle);
	SetMenuTitle(g_hBossSelect, "Toggle boss selection \n \n");
	Format(buffer, sizeof(buffer), "Disable");
	AddMenuItem(g_hBossSelect, "0", buffer);
	strcopy(buffer, sizeof(buffer), "Enable");
	AddMenuItem(g_hBossSelect, "0", buffer);
	
	g_hRevivalSelect = CreateMenu(Menu_Toggle);
	SetMenuTitle(g_hRevivalSelect, "Toggle boss selection \n \n");
	Format(buffer, sizeof(buffer), "Disable");
	AddMenuItem(g_hRevivalSelect, "0", buffer);
	strcopy(buffer, sizeof(buffer), "Enable");
	AddMenuItem(g_hRevivalSelect, "0", buffer);
}

public int Menu_Main(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelp, param1, 30);
			case 1: Panel_DisplayQueue(param1);
			case 3: DisplayMenu(g_hMenuSettings, param1, MENU_TIME_FOREVER);
			case 4: DisplayMenu(g_hMenuCredits, param1, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_Settings(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hBossSelect, param1, 30);
			case 1: DisplayMenu(g_hRevivalSelect, param1, 30);
		}
	}
}

public int Menu_Toggle(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		bool bValue = (param2 == 1);
		if (g_hBossSelect == menu)
			g_iPlayerPreferences[param1][PlayerPreference_PickAsBoss] = bValue;
		if (g_hRevivalSelect == menu)
			g_iPlayerPreferences[param1][PlayerPreference_RevivalSelect] = bValue;
	}
}

public int Menu_Credits(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits2, param1, MENU_TIME_FOREVER);
			case 1: DisplayMenu(g_hMenuMain, param1, 30);
		}
	}
}

public int Menu_Credits2(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits3, param1, MENU_TIME_FOREVER);
			case 1: DisplayMenu(g_hMenuCredits, param1, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_Credits3(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits2, param1, MENU_TIME_FOREVER);
		}
	}
}

void Panel_DisplayQueue(int iClient)
{
	Handle hPanel = CreatePanel();
	char strTitle[100];
	Format(strTitle, sizeof(strTitle), "VSH Queue list:");
	SetPanelTitle(hPanel, strTitle);
	
	ArrayList queueList = new ArrayList();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) > 1)
			queueList.Push(i);
	}
	
	int i = 0;
	int iLength = queueList.Length;
	char sRank[100];
	while (i < 8)
	{
		if (iLength > 0)
		{
			int iMaxQueuePts = -1;
			int index = -1;
			for (int ii = 0; ii < iLength; ii++)
			{
				int iPlayer = queueList.Get(ii);
				int iQueuePts = Queue_PlayerGetPoints(iPlayer);
				if (iQueuePts > iMaxQueuePts)
				{
					iMaxQueuePts = iQueuePts;
					index = ii;
				}
			}
			
			if (index != -1)
			{
				int iPlayer = queueList.Get(index);
				Format(sRank, sizeof(sRank), "%i) - %N (%i)", i, iPlayer, Queue_PlayerGetPoints(iPlayer));
				DrawPanelText(hPanel, sRank);
				queueList.Erase(index);
			}
		}
		else
		{
			while (i < 8)
			{
				Format(sRank, sizeof(sRank), "%i) - ", i);
				DrawPanelText(hPanel, sRank);
				i++;
			}
		}	
		iLength = queueList.Length;
		i++;
	}
	Format(sRank, sizeof(sRank), "Your queue points: %i", Queue_PlayerGetPoints(iClient));
	DrawPanelText(hPanel, sRank);
	DrawPanelItem(hPanel, "Dismiss");
	SendPanelToClient(hPanel, iClient, MenuPanel_HandlerNothing, 20);
	delete hPanel;
}

public int MenuPanel_HandlerNothing(Handle hPanel, MenuAction action, int client, int menu_item)
{
	return;
}
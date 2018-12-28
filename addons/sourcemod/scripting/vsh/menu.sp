Handle g_hMenuMain;
Handle g_hMenuCredits;
Handle g_hMenuCredits2;
Handle g_hMenuCredits3;
Handle g_hMenuSettings;
Handle g_hMenuHelp;
Handle g_hMenuClassHelp;

Handle g_hBossSelect;
Handle g_hBossArrow;
Handle g_hRevivalSelect;

void Menus_Init()
{
	char buffer[512];
	
	// Create menus.
	// To-do add translations support.
	g_hMenuMain = CreateMenu(Menu_Main);
	SetMenuTitle(g_hMenuMain, "[VSH REWRITE] - %s\n \n",PLUGIN_VERSION);
	AddMenuItem(g_hMenuMain, "0", "Help Menu (!vshhelp)");
	AddMenuItem(g_hMenuMain, "0", "Queue List (!vshnext)");
	AddMenuItem(g_hMenuMain, "0", "Settings (!vshsettings)");
	AddMenuItem(g_hMenuMain, "0", "Credits (!vshcredits)");
	
	g_hMenuHelp = CreateMenu(Menu_Help);
	SetMenuTitle(g_hMenuHelp, "Help \n \n");
	AddMenuItem(g_hMenuHelp, "0", "Class Information");
	
	g_hMenuClassHelp = CreateMenu(Menu_ClassHelp);
	Format(buffer, sizeof(buffer), "Class Information\n \n");
	SetMenuTitle(g_hMenuClassHelp, buffer);
	
	AddMenuItem(g_hMenuClassHelp, "0", "Scout");
	AddMenuItem(g_hMenuClassHelp, "0", "Sniper");
	AddMenuItem(g_hMenuClassHelp, "0", "Soldier");
	AddMenuItem(g_hMenuClassHelp, "0", "Demoman");
	AddMenuItem(g_hMenuClassHelp, "0", "Medic");
	AddMenuItem(g_hMenuClassHelp, "0", "Heavy");
	AddMenuItem(g_hMenuClassHelp, "0", "Pyro");
	AddMenuItem(g_hMenuClassHelp, "0", "Spy");
	AddMenuItem(g_hMenuClassHelp, "0", "Engineer");
	
	g_hMenuCredits = CreateMenu(Menu_Credits);
	
	Format(buffer, sizeof(buffer), "Credits\n \n");
	StrCat(buffer, sizeof(buffer), "Coder: Benoist3012\n");
	StrCat(buffer, sizeof(buffer), "\n \n");
	StrCat(buffer, sizeof(buffer), "Eggman - The creator of the first VSH\n");
	StrCat(buffer, sizeof(buffer), "Alex Turtle & Chillax - Great test subjects!\n");
	StrCat(buffer, sizeof(buffer), "Dispenzor's Fun Servers - Host community!\n");
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
	StrCat(buffer, sizeof(buffer), "Sasch\n \n");
	
	SetMenuTitle(g_hMenuCredits3, buffer);
	AddMenuItem(g_hMenuCredits3, "0", "Back");
	
	g_hMenuSettings = CreateMenu(Menu_Settings);
	SetMenuTitle(g_hMenuSettings, "Settings \n \n");
	AddMenuItem(g_hMenuSettings, "0", "Boss Selection");
	AddMenuItem(g_hMenuSettings, "0", "Boss Arrow");
	AddMenuItem(g_hMenuSettings, "0", "Revival Preference");
	
	g_hBossSelect = CreateMenu(Menu_Toggle);
	SetMenuTitle(g_hBossSelect, "Toggle boss selection \n \n");
	AddMenuItem(g_hBossSelect, "0", "Disable");
	AddMenuItem(g_hBossSelect, "0", "Enable");
	
	g_hRevivalSelect = CreateMenu(Menu_Toggle);
	SetMenuTitle(g_hRevivalSelect, "Toggle being revived as a zombie \n \n");
	AddMenuItem(g_hRevivalSelect, "0", "Disable");
	AddMenuItem(g_hRevivalSelect, "0", "Enable");
	
	g_hBossArrow = CreateMenu(Menu_Toggle);
	SetMenuTitle(g_hBossArrow, "Toggle Boss Arrow \n \n");
	AddMenuItem(g_hBossArrow, "0", "Disable");
	AddMenuItem(g_hBossArrow, "0", "Enable");
}

public int Menu_Main(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuHelp, param1, MENU_TIME_FOREVER);
			case 1: Panel_DisplayQueue(param1);
			case 2: DisplayMenu(g_hMenuSettings, param1, MENU_TIME_FOREVER);
			case 3: DisplayMenu(g_hMenuCredits, param1, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_Settings(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hBossSelect, param1, MENU_TIME_FOREVER);
			case 2: DisplayMenu(g_hRevivalSelect, param1, MENU_TIME_FOREVER);
			case 1: DisplayMenu(g_hBossArrow, param1, MENU_TIME_FOREVER);
			default: DisplayMenu(g_hMenuMain, param1, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_Toggle(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		bool bValue = (param2 == 1);
		if (g_hBossSelect == menu)
		{
			g_iPlayerPreferences[param1][PlayerPreference_PickAsBoss] = bValue;
		}
		else if (g_hRevivalSelect == menu)
		{
			g_iPlayerPreferences[param1][PlayerPreference_RevivalSelect] = bValue;
		}
		else if (g_hBossArrow == menu)
		{
			g_iPlayerPreferences[param1][PlayerPreference_DisplayBossArrow] = bValue;
		}
		
		DisplayMenu(g_hMenuSettings, param1, MENU_TIME_FOREVER);
	}
}

public int Menu_Credits(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: DisplayMenu(g_hMenuCredits2, param1, MENU_TIME_FOREVER);
			case 1: DisplayMenu(g_hMenuMain, param1, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_Credits2(Handle menu, MenuAction action, int param1, int param2)
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

public int Menu_Credits3(Handle menu, MenuAction action, int param1, int param2)
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

public int Menu_Help(Handle hMenu, MenuAction action, int client, int menu_item)
{
	if (action == MenuAction_Select)
	{
		switch (menu_item)
		{
			case 0: DisplayMenu(g_hMenuClassHelp, client, MENU_TIME_FOREVER);
			default: DisplayMenu(g_hMenuMain, client, MENU_TIME_FOREVER);
		}
	}
}

public int Menu_ClassHelp(Handle hMenu, MenuAction action, int client, int menu_item)
{
	if (action == MenuAction_Select)
	{
		switch (menu_item)
		{
			case 9: DisplayMenu(g_hMenuHelp, client, MENU_TIME_FOREVER);
			default: Menu_DisplayClassTips(client, view_as<TFClassType>(menu_item+1));
		}
	}
}

static ArrayList g_aReadArray[TF_MAXPLAYERS+1];
static int g_iPage[TF_MAXPLAYERS+1];

void Menu_DisplayClassTips(int iClient, TFClassType class)
{
	ArrayList aTips = classConfig.GetClassTips(class);
	if (aTips == null)
	{
		DisplayMenu(g_hMenuMain, iClient, MENU_TIME_FOREVER);
		return;
	}
	
	g_iPage[iClient] = 0;
	g_aReadArray[iClient] = aTips;
	Menu_ClassTipDisplay(iClient);
}

public int Menu_ClassTips(Handle hMenu, MenuAction action, int client, int menu_item)
{
	if (action == MenuAction_Select)
	{
		switch (menu_item)
		{
			case 0: g_iPage[client]--;
			case 1: g_iPage[client]++;
		}
		Menu_ClassTipDisplay(client);
	}
	if (action == MenuAction_End)
		delete hMenu;
}

void Menu_ClassTipDisplay(int iClient)
{
	int iLength = g_aReadArray[iClient].Length;
	if (g_iPage[iClient] >= iLength || g_iPage[iClient] < 0)
	{
		DisplayMenu(g_hMenuClassHelp, iClient, MENU_TIME_FOREVER);
		return;
	}
	
	char sClassTips[2048];
	g_aReadArray[iClient].GetString(g_iPage[iClient], sClassTips, sizeof(sClassTips));
	
	Handle hClassTips = CreateMenu(Menu_ClassTips);
	SetMenuTitle(hClassTips, sClassTips);
	SetMenuExitButton(hClassTips, false);
	AddMenuItem(hClassTips, "0", "Back");
	
	if (g_iPage[iClient] < iLength-1)
		AddMenuItem(hClassTips, "0", "Next");
	DisplayMenu(hClassTips, iClient, MENU_TIME_FOREVER);
}

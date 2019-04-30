#define SR_CYCLELENGTH	10.0
#define SR_MUSIC		"vsh_rewrite/specialround.mp3"
#define SR_SOUND_SELECT "vsh_rewrite/specialroundselect.mp3"

#define MODEL_FLAG		"models/flag/briefcase.mdl"

#define FILE_SPECIALROUNDS "configs/vsh/specialrounds.cfg"

static float 	 g_flSpecialRoundCycleEndTime;
static Handle	 g_hSpecialRoundTimer = null;
static ArrayList g_aSpecialRoundCycleNames = null;
static KeyValues g_kvSpecialRoundsConfig = null;
static int 		 g_iSpecialRoundCycleNum = 0;
static int		 g_iSpecialRoundType = 0;
static int		 g_iYetiModelIndex;
static bool		 g_bStarted = false;

void SpecialRounds_Refresh()
{
	if (g_aSpecialRoundCycleNames == null)
		g_aSpecialRoundCycleNames = new ArrayList(128);
	
	g_aSpecialRoundCycleNames.Clear();

	if (g_kvSpecialRoundsConfig != null)
		delete g_kvSpecialRoundsConfig;
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), FILE_SPECIALROUNDS);
	KeyValues kv = new KeyValues("root");
	if (!FileToKeyValues(kv, buffer))
	{
		delete kv;
		LogError("Failed to load special rounds! File %s not found!", FILE_SPECIALROUNDS);
	}
	else
	{
		g_kvSpecialRoundsConfig = kv;
		LogMessage("Loaded special rounds file!");
		
		// Load names for the cycle.
		char sBuffer[128];
		for (int iSpecialRound = 1; iSpecialRound < SPECIALROUND_MAXROUNDS; iSpecialRound++)
		{
			SpecialRound_GetDescriptionHud(iSpecialRound, sBuffer, sizeof(sBuffer));
			g_aSpecialRoundCycleNames.PushString(sBuffer);
		}
		
		kv.Rewind();
		if (kv.JumpToKey("jokes"))
		{
			if (kv.GotoFirstSubKey(false))
			{
				do
				{
					kv.GetString(NULL_STRING, sBuffer, sizeof(sBuffer));
					if (strlen(sBuffer) > 0)
						g_aSpecialRoundCycleNames.PushString(sBuffer);
				}
				while (kv.GotoNextKey(false));
			}
		}
		
		SortADTArray(g_aSpecialRoundCycleNames, Sort_Random, Sort_String);
	}
}

void SpecialRounds_OnMapStart()
{
	g_iYetiModelIndex = PrecacheModel("models/player/items/taunts/yeti/yeti.mdl");
	PrecacheModel("models/buildables/sentry3.mdl");
	PrecacheSound(SR_MUSIC);
	PrecacheSound(SR_SOUND_SELECT);
	PrecacheModel(MODEL_FLAG);
	
	CSentryBuster buster;
	buster.Precache();
}

stock void SpecialRound_GetDescriptionHud(int iSpecialRound, char[] buffer, int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_kvSpecialRoundsConfig == null) return;
	
	g_kvSpecialRoundsConfig.Rewind();
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!g_kvSpecialRoundsConfig.JumpToKey(sSpecialRound)) return;
	
	g_kvSpecialRoundsConfig.GetString("display_text_hud", buffer, bufferlen);
}

stock void SpecialRound_GetDescriptionChat(int iSpecialRound, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_kvSpecialRoundsConfig == null) return;
	
	g_kvSpecialRoundsConfig.Rewind();
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!g_kvSpecialRoundsConfig.JumpToKey(sSpecialRound)) return;
	
	g_kvSpecialRoundsConfig.GetString("display_text_chat", buffer, bufferlen);
}

stock void SpecialRound_GetIconHud(int iSpecialRound, char[] buffer,int bufferlen)
{
	strcopy(buffer, bufferlen, "");

	if (g_kvSpecialRoundsConfig == null) return;
	
	g_kvSpecialRoundsConfig.Rewind();
	char sSpecialRound[32];
	IntToString(iSpecialRound, sSpecialRound, sizeof(sSpecialRound));
	
	if (!g_kvSpecialRoundsConfig.JumpToKey(sSpecialRound)) return;
	
	g_kvSpecialRoundsConfig.GetString("display_icon_hud", buffer, bufferlen);
}

public Action Timer_SpecialRoundCycle(Handle hTimer)
{
	if (hTimer != g_hSpecialRoundTimer) return Plugin_Stop;
	
	if (GetGameTime() >= g_flSpecialRoundCycleEndTime)
	{
		SpecialRound_CycleFinish();
		return Plugin_Stop;
	}
	
	char sBuffer[128];
	g_aSpecialRoundCycleNames.GetString(g_iSpecialRoundCycleNum, sBuffer, sizeof(sBuffer));
	SpecialRound_GameText(sBuffer);
	
	g_iSpecialRoundCycleNum++;
	if (g_iSpecialRoundCycleNum >= g_aSpecialRoundCycleNames.Length)
	{
		g_iSpecialRoundCycleNum = 0;
	}
	
	return Plugin_Continue;
}

void SpecialRound_CycleStart()
{
	//if (!g_bSpecialRound) return;
	if (g_bStarted) return;
	
	g_bStarted = true;
	EmitSoundToAll(SR_MUSIC, _, SNDCHAN_AUTO);
	g_iSpecialRoundType = 0;
	g_flSpecialRoundCycleEndTime = GetGameTime() + SR_CYCLELENGTH;
	g_hSpecialRoundTimer = CreateTimer(0.12, Timer_SpecialRoundCycle, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

ArrayList SpecialRound_GetList()
{
	ArrayList list = new ArrayList();
	
	//Enabled special rounds, or rounds with specific conditions must be put there!
	list.Push(SPECIALROUND_YETISVSHALE);
	
	int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
	if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss))
	{
		int iBossTeam = GetClientTeam(iMainBoss);
		int iOpositeTeam = (iBossTeam == TFTeam_Red) ? TFTeam_Blue : TFTeam_Red;
		int numPlayers = GetTeamClientCount(iOpositeTeam);
		if (numPlayers > 2)
			list.Push(SPECIALROUND_DOUBLEBOSSES);
		if (numPlayers > 10)
		{
			list.Push(SPECIALROUND_CLASHOFBOSSES);
			list.Push(SPECIALROUND_SENTRYBUSTERS);
		}
	}
	
	return list;
}

void SpecialRound_CycleFinish()
{
	ArrayList list = SpecialRound_GetList();
	g_iSpecialRoundType = list.Get(GetRandomInt(0,list.Length-1));
	delete list;
	
	char sDescHud[64];
	SpecialRound_GetDescriptionHud(g_iSpecialRoundType, sDescHud, sizeof(sDescHud));
	
	char sIconHud[64];
	SpecialRound_GetIconHud(g_iSpecialRoundType, sIconHud, sizeof(sIconHud));
	
	char sDescChat[64];
	SpecialRound_GetDescriptionChat(g_iSpecialRoundType, sDescChat, sizeof(sDescChat));
	
	SpecialRound_GameText(sDescHud, sIconHud);
	PrintToChatAll("%s %sSPECIAL ROUND: %s", VSH_TAG, VSH_TEXT_COLOR, sDescChat);
	
	SpecialRound_Activate(g_iSpecialRoundType);
}

void SpecialRound_Activate(int iSpecialRound)
{
	EmitSoundToAll(SR_SOUND_SELECT, _, SNDCHAN_AUTO);
	switch (iSpecialRound)
	{
		case SPECIALROUND_YETISVSHALE:
		{
			int iActiveBoss = GetClientOfUserId(g_iUserActiveBoss);
			float vecPos[3], vecAng[3];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (i != iActiveBoss && IsClientInGame(i) && GetClientTeam(i) > 1)
				{
					GetClientAbsAngles(i, vecAng);
					GetClientAbsOrigin(i, vecPos);
					TF2_RespawnPlayer(i);
					TeleportEntity(i, vecPos, vecAng, NULL_VECTOR);
				}
			}
		}
		case SPECIALROUND_DOUBLEBOSSES:
		{
			ArrayList pickList = new ArrayList();
			int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
			if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss))
			{
				int iBossTeam = GetClientTeam(iMainBoss);
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						int iClientTeam = GetClientTeam(i);
						if (iClientTeam > 1 && iClientTeam != iBossTeam)
							pickList.Push(i);
					}
				}
				int iLength = pickList.Length;
				if (iLength > 2)
				{
					int iPickedPlayer = pickList.Get(GetRandomInt(0,iLength-1));
					Client_AddFlag(iPickedPlayer, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
					
					if (g_clientBoss[iPickedPlayer].IsValid)
						g_clientBoss[iPickedPlayer].Destroy();
					g_clientBoss[iPickedPlayer] = CBaseBoss(iPickedPlayer, g_strBossesType[GetRandomInt(0, sizeof(g_strBossesType)-1)]);
					
					TF2_ForceTeamJoin(iPickedPlayer, iBossTeam);
				}
			}
			delete pickList;
		}
		case SPECIALROUND_CLASHOFBOSSES:
		{
			//By removing the active boss, we disable some of our security check (mostly team switch) and disable healthbar
			g_iUserActiveBoss = -1;
			
			int iSwapTeam = TFTeam_Red;
			ArrayList list = new ArrayList();
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) > 1)
					list.Push(i);
			}
			
			int iLength = list.Length;
			if (iLength > 1)
			{
				SortADTArray(list, Sort_Random, Sort_String);
				for (int i = 0; i < iLength; i++)
				{
					int iPlayer = list.Get(i);
					
					TF2_ForceTeamJoin(iPlayer, iSwapTeam);
					
					if (iSwapTeam == TFTeam_Red)
						iSwapTeam = TFTeam_Blue;
					else
						iSwapTeam = TFTeam_Red;
				}
				mp_teams_unbalance_limit.IntValue = 1;
			}
			
			delete list;
		}
		case SPECIALROUND_SENTRYBUSTERS:
		{
			int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
			if (iMainBoss > 0 && IsClientInGame(iMainBoss))
			{
				TF2_ForceTeamJoin(iMainBoss, TFTeam_Red);
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) > 1 && i != iMainBoss)
				{
					//Just for safety
					Client_AddFlag(i, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
					TF2_ForceTeamJoin(i, TFTeam_Blue);
					Client_RemoveFlag(i, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
				}
			}
		}
	}
}

public void SpecialRound_OnRoundArenaStart()
{
	switch (g_iSpecialRoundType)
	{
		case SPECIALROUND_CLASHOFBOSSES:
		{
			for (int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (IsClientInGame(iClient) && GetClientTeam(iClient) > 1)
				{
					g_clientBoss[iClient] = CBaseBoss(iClient, g_strBossesType[GetRandomInt(0, sizeof(g_strBossesType)-1)]);
					g_clientBoss[iClient].Spawn();
					g_clientBoss[iClient].flGlowTime = 99999999.0;
				}
			}
			mp_teams_unbalance_limit.IntValue = 0;
		}
		case SPECIALROUND_SENTRYBUSTERS:
		{
			int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
			g_iUserActiveBoss = -1;
			if (iMainBoss > 0 && IsClientInGame(iMainBoss))
			{
				if (GetClientTeam(iMainBoss) != TFTeam_Red)
					TF2_ForceTeamJoin(iMainBoss, TFTeam_Red);
			}
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && i != iMainBoss)
				{
					int iTeam = GetClientTeam(i);
					if (iTeam > 1)
					{
						if (iTeam != TFTeam_Blue)
						{
							TF2_ForceTeamJoin(i, TFTeam_Blue);
						}
						g_clientBoss[i] = CBaseBoss(i, "CSentryBuster");
					}
				}
			}
		}
	}
}

public void SpecialRound_OnRoundEnd(int iWinningTeam)
{
	SpecialRound_Reset();
	switch (g_iSpecialRoundType)
	{
		case SPECIALROUND_CLASHOFBOSSES:
		{
			for (int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (IsClientInGame(iClient))
				{
					SetEntProp(iClient, Prop_Send, "m_bGlowEnabled", false);
				}
			}
		}
		case SPECIALROUND_SENTRYBUSTERS:
		{
			for (int iClient = 1; iClient <= MaxClients; iClient++)
			{
				if (IsClientInGame(iClient))
				{
					if (GetClientTeam(iClient) == TFTeam_Red && IsPlayerAlive(iClient))
					{
						TF2_RegeneratePlayer(iClient);
						break;
					}
				}
			}
		}
	}
}

bool SpecialRound_PickBoss(int iClient)
{
	switch (g_iSpecialRoundType)
	{
		case SPECIALROUND_YETISVSHALE:
		{
			g_clientBoss[iClient] = CBaseBoss(iClient, "CSaxtonHale");
			return true;
		}
		case SPECIALROUND_SENTRYBUSTERS:
		{
			g_clientBoss[iClient] = CBaseBoss(iClient, "CSentryGun");
			g_clientBoss[iClient].flGlowTime = 99999999.0;
			return true;
		}
	}
	return false;
}

void SpecialRound_Reset()
{
	g_iSpecialRoundType = 0;
	g_flSpecialRoundCycleEndTime = 0.0;
	g_hSpecialRoundTimer = null;
	g_bStarted = false;
}

bool VSH_SpecialRound(int iSpecialRound)
{
	return (g_iSpecialRoundType == iSpecialRound);
}

static int g_iRefYetiModelWearable[TF_MAXPLAYERS+1];

public Action Timer_SpecialRoundYetiModel(Handle hTimer, int userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0 || !IsClientInGame(iClient)) return Plugin_Stop;
	
	if (g_hClientSpecialRoundTimer[iClient] != hTimer) return Plugin_Stop;
	
	if (!VSH_SpecialRound(SPECIALROUND_YETISVSHALE)) return Plugin_Stop;
	
	if (g_clientBoss[iClient].IsValid) return Plugin_Stop;
	
	if (IsPlayerAlive(iClient))
	{
		// Always keep their base model invisible
		SetEntityRenderMode(iClient, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iClient, _, _, _, 0);
		
		int iModel = EntRefToEntIndex(g_iRefYetiModelWearable[iClient]);
		if (iModel < MaxClients)
		{
			int iWearable = TF2_CreateAndEquipFakeModel(iClient);
			g_iRefYetiModelWearable[iClient] = EntIndexToEntRef(iWearable);
			SetEntProp(iWearable, Prop_Send, "m_bValidatedAttachedEntity", true); 
			SetEntProp(iWearable, Prop_Send, "m_nModelIndexOverrides", g_iYetiModelIndex);
			SetEntProp(iWearable, Prop_Send, "m_bValidatedAttachedEntity", true);
		}
	}
	
	return Plugin_Continue;
}

stock void SpecialRound_GameText(const char[] strMessage, const char strIcon[]="")
{
	int iEntity = CreateEntityByName("game_text_tf");
	DispatchKeyValue(iEntity,"message", strMessage);
	DispatchKeyValue(iEntity,"display_to_team", "0");
	DispatchKeyValue(iEntity,"icon", strIcon);
	DispatchKeyValue(iEntity,"targetname", "game_text1");
	DispatchKeyValue(iEntity,"background", "0");
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "Display", iEntity, iEntity);
	CreateTimer(0.3, Timer_EntityCleanup, EntIndexToEntRef(iEntity));
}

stock int CreateLink(int iClient)
{
	int iLink = CreateEntityByName("tf_taunt_prop");
	DispatchKeyValue(iLink, "targetname", "DispenserLink");
	DispatchSpawn(iLink); 
	
	SetEntityModel(iLink, MODEL_FLAG);
	
	SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
	
	SetVariantString("!activator"); 
	AcceptEntityInput(iLink, "SetParent", iClient); 
	
	SetVariantString("flag");
	AcceptEntityInput(iLink, "SetParentAttachment", iClient);
	
	return iLink;
}

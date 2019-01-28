#define DEATH_RINGS_DEF_RADIUS 		4000.0
#define DEATH_RINGS_DEPLOY_SOUND_1		"ambient/halloween/thunder_06.wav"
#define DEATH_RINGS_DEPLOY_SOUND_2		"misc/ks_tier_04_death.wav"
#define DEATH_RINGS_SHRINKING_SOUND	"vsh_rewrite/last30sec.mp3"

static char g_strDeathRingsHitSound[][] =
{
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav"
};

static Handle g_hTimerDeathRings = null;
static int g_iPlayerHealth[TF_MAXPLAYERS+1];

void DeathRings_Precache()
{
	PrecacheSound(DEATH_RINGS_DEPLOY_SOUND_1);
	PrecacheSound(DEATH_RINGS_DEPLOY_SOUND_2);
	PrepareSound(DEATH_RINGS_SHRINKING_SOUND);
	
	for (int i = 0; i < sizeof(g_strDeathRingsHitSound); i++) PrepareSound(g_strDeathRingsHitSound[i]);
}

void DeathRings_Setup(int iTime)
{
	if (g_hTimerDeathRings)
		delete g_hTimerDeathRings;
	
	g_hTimerDeathRings = CreateTimer(float(iTime)-6.0, Timer_DeployDeathRings);
	
	// Initiate our timer with our time
	int iTimer = CreateEntityByName("team_round_timer");
	DispatchKeyValue(iTimer, "show_in_hud", "1");
	DispatchSpawn(iTimer);
	
	SetVariantInt(iTime+24);
	AcceptEntityInput(iTimer, "SetTime");
	AcceptEntityInput(iTimer, "Resume");
	AcceptEntityInput(iTimer, "Enable");
	SetEntProp(iTimer, Prop_Send, "m_bAutoCountdown", false);
	CreateTimer(float(iTime+24), Timer_EntityCleanup, EntIndexToEntRef(iTimer));
	
	Event event = CreateEvent("teamplay_update_timer");
	event.Fire();
}

void DeathRings_Cleanup()
{
	g_hTimerDeathRings = null;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			TF2Attrib_RemoveByDefIndex(i, ATTRIB_REDUCED_HEALING);
			TF2Attrib_RemoveByDefIndex(i, ATTRIB_HEALTH_FROM_PACKS);
		}
	}
}

public Action Timer_DeployDeathRings(Handle hTimer)
{
	if (hTimer != g_hTimerDeathRings)
		return;
	
	g_hTimerDeathRings = null;
	
	VSH_StopBossMusic();
	EmitSoundToAll(DEATH_RINGS_SHRINKING_SOUND);
	EmitSoundToAll(DEATH_RINGS_DEPLOY_SOUND_1);
	EmitSoundToAll(DEATH_RINGS_DEPLOY_SOUND_2);
	
	float vecPos[3], vecCircleCenter[3];
	int iCp = FindEntityByClassname(-1, "team_control_point");
	if (iCp > MaxClients)
		GetEntPropVector(iCp, Prop_Send, "m_vecOrigin", vecPos);
	
	//Cancel medic healing
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			TF2Attrib_SetByDefIndex(i, ATTRIB_REDUCED_HEALING, 0.0);
			TF2Attrib_SetByDefIndex(i, ATTRIB_HEALTH_FROM_PACKS, 0.0);
		}
	}
	
	vecCircleCenter = vecPos;
	vecCircleCenter[2] -= 1500;
	
	int iColor[4] = {0, 255, 0, 255};
	for (int i = 1; i <= 30; i++)
	{
		vecCircleCenter[2] += 100;
		TE_SetupBeamRingPoint(vecCircleCenter, 0.0, DEATH_RINGS_DEF_RADIUS, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 4.0, 4.0, 1.0, iColor, 0, 0);
		TE_SendToAll();
	}
	
	g_hTimerDeathRings = CreateTimer(4.0, Timer_RingsBeginShrink);
}

public Action Timer_RingsBeginShrink(Handle hTimer)
{
	if (hTimer != g_hTimerDeathRings)
		return;
	
	float vecPos[3], vecCircleCenter[3];
	int iCp = FindEntityByClassname(-1, "team_control_point");
	if (iCp > MaxClients)
		GetEntPropVector(iCp, Prop_Send, "m_vecOrigin", vecPos);
	
	vecCircleCenter = vecPos;
	vecCircleCenter[2] -= 1500;
	
	int iColor[4] = {0, 255, 0, 255};
	for (int i = 1; i <= 30; i++)
	{
		vecCircleCenter[2] += 100;
		TE_SetupBeamRingPoint(vecCircleCenter, DEATH_RINGS_DEF_RADIUS, 0.0, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 30.0, 4.0, 1.0, iColor, 0, 0);
		TE_SendToAll();
	}
	
	// Save everyone's health prior the ring event
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			g_iPlayerHealth[i] = GetEntProp(i, Prop_Send, "m_iHealth");
			int iMaxHealth = SDK_GetMaxHealth(i);
			if (g_iPlayerHealth[i] > iMaxHealth)
				g_iPlayerHealth[i] = iMaxHealth;
		}
	}
	
	g_hTimerDeathRings = CreateTimer(0.1, Timer_DamageTick, GetGameTime());
}

public Action Timer_DamageTick(Handle hTimer, float flBeginTime)
{
	if (g_hTimerDeathRings != hTimer)
		return;
	
	float flDeathRadius, vecDeathPos[3], vecTargetPos[3];
	flDeathRadius = DEATH_RINGS_DEF_RADIUS*((26.0-(GetGameTime()-flBeginTime))/26.0);
	
	int iCp = FindEntityByClassname(-1, "team_control_point");
	if (iCp > MaxClients)
		GetEntPropVector(iCp, Prop_Send, "m_vecOrigin", vecDeathPos);
	
	int iTrigger = FindEntityByClassname(-1, "trigger_hurt");
	
	int iRecipients[TF_MAXPLAYERS+1], iTotal = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			GetClientAbsOrigin(i, vecTargetPos);
			vecTargetPos[2] = vecDeathPos[2];
			
			int iCurrentHealth = GetEntProp(i, Prop_Send, "m_iHealth");
			if (iCurrentHealth < g_iPlayerHealth[i])
				g_iPlayerHealth[i] = iCurrentHealth; // Health can only go down not up!
			
			if (GetVectorDistance(vecTargetPos, vecDeathPos, false) >= flDeathRadius/2)
			{
				if (IsPlayerAlive(i))
				{
					EmitSoundToClient(i, g_strDeathRingsHitSound[GetRandomInt(0, sizeof(g_strDeathRingsHitSound)-1)]);
					float vecNoForce[3] = {0.0, 0.0, 0.0};
					int iDamage = RoundToNearest(0.02*float(SDK_GetMaxHealth(i)));
					if (iDamage <= 2) iDamage = 2;
					
					g_iPlayerHealth[i] -= iDamage;
					if (g_iPlayerHealth[i] <= 0)
						SDKHooks_TakeDamage(i, iTrigger, iTrigger, 99999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE, 0, vecNoForce, vecNoForce);
				}
				iRecipients[iTotal++] = i;
			}
			
			SetEntProp(i, Prop_Send, "m_iHealth", g_iPlayerHealth[i]);
		}
	}
	
	static UserMsg uFadeID = INVALID_MESSAGE_ID;
	if (uFadeID == INVALID_MESSAGE_ID)
		uFadeID = GetUserMessageId("Fade");
	
	Handle hMsg = StartMessageEx(uFadeID, iRecipients, iTotal);
	BfWriteShort(hMsg, 255);
	BfWriteShort(hMsg, 255);
	BfWriteShort(hMsg, (0x0002));
	BfWriteByte(hMsg, 111);
	BfWriteByte(hMsg, GetRandomInt(200,255));
	BfWriteByte(hMsg, 134);
	BfWriteByte(hMsg, 128);
	EndMessage();
	
	g_hTimerDeathRings = CreateTimer(0.1, Timer_DamageTick, flBeginTime);
}
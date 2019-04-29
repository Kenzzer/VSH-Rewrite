#define BODY_CLASSNAME	"prop_ragdoll"
#define BODY_EAT		"vo/sandwicheat09.mp3"

static int g_iMaxHeal[TF_MAXPLAYERS+1];
static float g_flMaxEatDistance[TF_MAXPLAYERS+1];
static float g_flEatRageDuration[TF_MAXPLAYERS+1];
static float g_flEatRageRadius[TF_MAXPLAYERS+1];
static float g_flBodyEatHUD_Xpos[TF_MAXPLAYERS+1];
static float g_flBodyEatHUD_Ypos[TF_MAXPLAYERS+1];
static Handle g_hBossBodyEatHud;

methodmap CBodyEat < IAbility
{
	property int iMaxHeal
	{
		public set(int iVal)
		{
			g_iMaxHeal[this.Client] = iVal;
		}
		public get()
		{
			return g_iMaxHeal[this.Client];
		}
	}
	
	property float flMaxEatDistance
	{
		public set(float flVal)
		{
			g_flMaxEatDistance[this.Client] = flVal;
		}
		public get()
		{
			return g_flMaxEatDistance[this.Client];
		}
	}
	
	property float flEatRageDuration
	{
		public set(float flVal)
		{
			g_flEatRageDuration[this.Client] = flVal;
		}
		public get()
		{
			return g_flEatRageDuration[this.Client];
		}
	}
	
	property float flEatRageRadius
	{
		public set(float flVal)
		{
			g_flEatRageRadius[this.Client] = flVal;
		}
		public get()
		{
			return g_flEatRageRadius[this.Client];
		}
	}
	
	property float HUD_X
	{
		public get()
		{
			return g_flBodyEatHUD_Xpos[this.Client];
		}
		public set(float val)
		{
			g_flBodyEatHUD_Xpos[this.Client] = val;
		}
	}
	
	property float HUD_Y
	{
		public get()
		{
			return g_flBodyEatHUD_Ypos[this.Client];
		}
		public set(float val)
		{
			g_flBodyEatHUD_Ypos[this.Client] = val;
		}
	}
	
	public CBodyEat(IAbility ability)
	{
		PrecacheSound(BODY_EAT);
		
		CBodyEat bodyeat = view_as<CBodyEat>(ability);
		bodyeat.iMaxHeal = 500;
		bodyeat.flMaxEatDistance = 100.0;
		bodyeat.flEatRageRadius = 450.0;
		bodyeat.flEatRageDuration = 10.0;
		bodyeat.HUD_X = -1.0;
		bodyeat.HUD_Y = 0.88;
		
		if (g_hBossBodyEatHud == null)
			g_hBossBodyEatHud = CreateHudSynchronizer();
	}

	public void OnPlayerKilled(int iVictim, Event eventInfo)
	{
		if (g_bBlockRagdoll) return;
		
		g_bBlockRagdoll = true;
		bool bFake = view_as<bool>(eventInfo.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER);
		
		//Any players killed by a boss with this ability will see their client side ragdoll removed and replaced with this server side ragdoll
		//Collect their damage and convert
		int iHeal = (!Client_HasFlag(iVictim, VSH_ZOMBIE)) ? g_iPlayerDamage[iVictim]/2 : 50;
		
		if (iHeal > this.iMaxHeal) iHeal = this.iMaxHeal;
		int iColor[4];
		iColor[0] = 255;
		iColor[1] = 255;
		iColor[2] = 0;
		iColor[3] = 255;
		
		//Determine outline color
		float flHeal = float(iHeal);
		float flMaxHeal = float(this.iMaxHeal);
		if (flHeal <= flMaxHeal/2.0)
		{
			float flVal = flHeal/(flMaxHeal/2.0);
			iColor[1] = RoundToNearest(float(iColor[1])*flVal);
		}
		else
		{
			float flVal = 1.0-((flHeal-(flMaxHeal/2.0))/(flMaxHeal/2.0));
			iColor[0] = RoundToNearest(float(iColor[0])*flVal);
		}
		
		int iRagdoll = CreateEntityByName(BODY_CLASSNAME);
		SetEntProp(iRagdoll, Prop_Data, "m_iMaxHealth", (bFake) ? 0 : iHeal);
		SetEntProp(iRagdoll, Prop_Data, "m_iHealth", (bFake) ? 0 : iHeal);
		
		char sModel[255];
		GetEntPropString(iVictim, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		DispatchKeyValue(iRagdoll, "model", sModel);
		
		float vecPos[3];
		GetClientEyePosition(iVictim, vecPos);
		DispatchSpawn(iRagdoll);
		TeleportEntity(iRagdoll, vecPos, NULL_VECTOR, NULL_VECTOR);
		
		Network_CreateEntityGlow(iRagdoll, sModel, iColor, BodyGlow_Transmit);
		SetEntProp(iRagdoll, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);
		DHookEntity(g_hHookShouldTransmit, true, iRagdoll);
		
		CreateTimer(30.0, Timer_EntityCleanup, EntIndexToEntRef(iRagdoll));
		
		//SendProxy_Hook(iRagdoll, "m_CollisionGroup", Prop_Int, Body_FakeCollisionGroup);
		//SDKHook(iRagdoll, SDKHook_ShouldCollide, Body_ShouldCollide);
	}
	
	public void EatBody(int iEnt)
	{
		if (0 < GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") <= MaxClients) return;
		
		float lastRageTime = this.flLastRageTime;
		float eatDuration = this.flEatRageDuration;
		if (this.bSuperRage)
			eatDuration *= 2.0;
		if (lastRageTime == 0.0 || (GetGameTime()-lastRageTime) > eatDuration)
		{
			TF2_StunPlayer(this.Client, 2.0, 1.0, 35);
			EmitSoundToAll(BODY_EAT, this.Client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
		}
		
		int iDissolve = CreateEntityByName("env_entity_dissolver");
		if (iDissolve > 0)
		{
			char sName[32];
			Format(sName, sizeof(sName), "Ref_%d_Ent_%d", EntIndexToEntRef(iEnt), iEnt);

			DispatchKeyValue(iEnt, "targetname", sName);
			DispatchKeyValue(iDissolve, "target", sName);
			DispatchKeyValue(iDissolve, "dissolvetype", "2");
			DispatchKeyValue(iDissolve, "magnitude", "15.0");
			AcceptEntityInput(iDissolve, "Dissolve");
			AcceptEntityInput(iDissolve, "Kill");
			
			Client_AddHealth(this.Client, GetEntProp(iEnt, Prop_Data, "m_iHealth"), 0);
			
			SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", this.Client);
		}
	}
	
	public void OnButtonPress(int button)
	{
		if (button != IN_RELOAD) return;
		
		float vecPos[3], vecAng[3], vecEndPos[3];
		GetClientEyePosition(this.Client, vecPos);
		GetClientEyeAngles(this.Client, vecAng);
	
		Handle hTrace = TR_TraceRayFilterEx(vecPos, vecAng, MASK_VISIBLE, RayType_Infinite, TraceRay_DontHitPlayers);
		int iEnt = TR_GetEntityIndex(hTrace);
		TR_GetEndPosition(vecEndPos, hTrace);
		delete hTrace;
		
		if (GetVectorDistance(vecEndPos, vecPos) > this.flMaxEatDistance) return;
		
		char sClassName[32];
		if (iEnt > 0) GetEdictClassname(iEnt, sClassName, sizeof(sClassName));
		
		if (strcmp(sClassName, BODY_CLASSNAME) == 0)
			this.EatBody(iEnt);
	}
	
	public void Think()
	{
		float lastRageTime = this.flLastRageTime;
		float eatDuration = this.flEatRageDuration;
		if (this.bSuperRage)
			eatDuration *= 2.0;
		if (lastRageTime != 0.0 && ((GetGameTime()-lastRageTime) <= eatDuration))
		{
			float vecPos[3], vecBodyPos[3];
			GetClientEyePosition(this.Client, vecPos);
			
			int iEnt = MaxClients+1;
			while((iEnt = FindEntityByClassname(iEnt, "prop_ragdoll")) > MaxClients)
			{
				GetEntPropVector(iEnt, Prop_Send, "m_ragPos", vecBodyPos);
				if (GetVectorDistance(vecPos, vecBodyPos) > this.flEatRageRadius) continue;
				this.EatBody(iEnt);
			}
		}
		
		SetHudTextParams(this.HUD_X, this.HUD_Y, 0.15, 255, 255, 255, 255);
		ShowSyncHudText(this.Client, g_hBossBodyEatHud, "Aim at dead bodies and press reload to heal up!");
	}
}

public Action Body_FakeCollisionGroup(int entity, const char[] PropName, int &iValue, int element)
{
	iValue = COLLISION_GROUP_DEBRIS_TRIGGER;
	return Plugin_Changed;
}

public bool Body_ShouldCollide(int entity, int collisiongroup, int contentsmask, bool originalResult)
{
	if ((contentsmask & MASK_PLAYERSOLID))
		return false;
	return originalResult;
}

public Action BodyGlow_Transmit(int iGlow, int iClient)
{
	if (!Network_ClientHasSeenEntity(iClient, iGlow)) return Plugin_Continue;
	if (g_clientBoss[iClient].IsValid && g_clientBoss[iClient].FindAbility("CBodyEat") != INVALID_ABILITY) return Plugin_Continue;
	
	return Plugin_Handled;
}
#define SENTRY_BUSTER_DETONATE_TIME	2.0
#define SENTRY_BUSTER_EXPLOSION_RADIUS 300.0
#define SENTRY_BUSTER_EXPLOSION_DAMAGE 1200.0
#define SENTRY_BUSTER_MODEL_SCALE	   1.75

#define SENTRY_BUSTER_LOOP_SOUND	"mvm/sentrybuster/mvm_sentrybuster_loop.wav"
#define SENTRY_BUSTER_SPIN_SOUND	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
#define SNETRY_BUSTER_MODEL			"models/bots/demo/bot_sentry_buster.mdl"

static float g_flBusterTauntTime[TF_MAXPLAYERS+1];
static float g_flBusterLastTakeDmg[TF_MAXPLAYERS+1];

static char g_strSoundBusterFootsteps[][] = {
	"^mvm/sentrybuster/mvm_sentrybuster_step_01.wav",
	"^mvm/sentrybuster/mvm_sentrybuster_step_02.wav",
	"^mvm/sentrybuster/mvm_sentrybuster_step_03.wav",
	"^mvm/sentrybuster/mvm_sentrybuster_step_04.wav"
};

methodmap CSentryBuster < CBaseBoss
{
	public CSentryBuster(CBaseBoss boss)
	{
		boss.RegisterAbility("CBraveJump");
		boss.iMaxRageDamage = -1;
		g_flBusterTauntTime[boss.Index] = 0.0;
		
		//SendProxy_Unhook(boss.Index, "m_flModelScale", Hook_SentryBusterScale);
		//SendProxy_Hook(boss.Index, "m_flModelScale", Prop_Float, Hook_SentryBusterScale);
	}
	
	public int GetBaseHealth()
	{
		return 240;
	}
	
	public int GetHealthPerPlayer()
	{
		return 0;
	}
	
	public TFClassType GetClass()
	{
		return TFClass_DemoMan;
	}
	
	public int SpawnWeapon()
	{
		char attribs[128];
		Format(attribs, sizeof(attribs), "330 ; 7.0 ; 252 ; 0.5 ; 329 ; 0.7 ; 402 ; 1.0");
		return CreateWeapon(this.Index, "tf_weapon_stickbomb", 307, 100, TFQual_Collectors, attribs);
	}
	
	public void GetModel(char[] sModel, int length)
	{
		strcopy(sModel, length, SNETRY_BUSTER_MODEL);
	}
	
	public bool CanBeDestroyed(int entity, int team, float checkPos[3], float checkRadius)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == team) return false;

		float pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

		if(GetVectorDistance(pos, checkPos) > checkRadius) return false;

		return true;
	}
	
	public void Explode(float heightOffset, const char[] explosionParticle)
	{
		//Taken from STT
		float pos[3];
		GetClientAbsOrigin(this.Index, pos);
		pos[2] += heightOffset;

		// Spawn an explosion to hurt nearby entities
		int iExplosion = CreateEntityByName("env_explosion");
		if (iExplosion > MaxClients)
		{
			char strMagnitude[15];
			FloatToString(SENTRY_BUSTER_EXPLOSION_DAMAGE, strMagnitude, sizeof(strMagnitude));

			char strRadius[15];
			FloatToString(SENTRY_BUSTER_EXPLOSION_RADIUS, strRadius, sizeof(strRadius));

			DispatchKeyValue(iExplosion, "iMagnitude", strMagnitude);
			DispatchKeyValue(iExplosion, "iRadiusOverride", strRadius);
			
			DispatchSpawn(iExplosion);
			
			SetEntPropEnt(iExplosion, Prop_Data, "m_hOwnerEntity", this.Index);
			
			TeleportEntity(iExplosion, pos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(iExplosion, "Explode");
			
			CreateTimer(5.0, Timer_EntityCleanup, EntIndexToEntRef(iExplosion));
		}

		// env_explosion ain't perfect. Dispensers can be used to block explosions.
		// Collect entities of interest.
		ArrayList list = new ArrayList();
		int team = GetClientTeam(this.Index);
		int entity = MaxClients+1;
		while ((entity = FindEntityByClassname(entity, "obj_sentrygun")) > MaxClients)
		{
			if (this.CanBeDestroyed(entity, team, pos, SENTRY_BUSTER_EXPLOSION_RADIUS)) list.Push(entity);
		}
		entity = MaxClients+1;
		while ((entity = FindEntityByClassname(entity, "obj_dispenser")) > MaxClients)
		{
			if (this.CanBeDestroyed(entity, team, pos, SENTRY_BUSTER_EXPLOSION_RADIUS)) list.Push(entity);
		}
		entity = MaxClients+1;
		while ((entity = FindEntityByClassname(entity, "obj_teleporter")) > MaxClients)
		{
			if (this.CanBeDestroyed(entity, team, pos, SENTRY_BUSTER_EXPLOSION_RADIUS)) list.Push(entity);
		}
		for (int i=1; i<=MaxClients; i++)
		{
			if(i != this.Index && IsClientInGame(i) && IsPlayerAlive(i) && this.CanBeDestroyed(i, team, pos, SENTRY_BUSTER_EXPLOSION_RADIUS)) list.Push(i);
		}
		
		int size = list.Length;
		for (int i=0; i<size; i++)
		{
			entity = list.Get(i);
			
			// See if the buster is within line of sight before hurting the entity.
			float targetPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", targetPos);

			float targetMaxs[3];
			GetEntPropVector(entity, Prop_Send, "m_vecMaxs", targetMaxs);

			targetPos[2] += targetMaxs[2] / 2.0;

			TR_TraceRayFilter(pos, targetPos, MASK_SHOT, RayType_EndPoint, TraceEntityFilter_BusterExplosion, team);
			if (!TR_DidHit())
			{
				float damage = SENTRY_BUSTER_EXPLOSION_DAMAGE;
				SDKHooks_TakeDamage(entity, iExplosion, this.Index, damage, DMG_BLAST);
			}
		}

		delete list;

		// Spawn the explosion particle effects
		int iEntity = CreateEntityByName("info_particle_system");
		if (iEntity > MaxClients)
		{
			TeleportEntity(iEntity, pos, NULL_VECTOR, NULL_VECTOR);
			
			DispatchKeyValue(iEntity, "effect_name", explosionParticle);
			
			DispatchSpawn(iEntity);
			ActivateEntity(iEntity);
			AcceptEntityInput(iEntity, "Start");
			
			CreateTimer(5.0, Timer_EntityCleanup, EntIndexToEntRef(iEntity));
		}

		iEntity = CreateEntityByName("info_particle_system");
		if (iEntity > MaxClients)
		{
			TeleportEntity(iEntity, pos, NULL_VECTOR, NULL_VECTOR);
			
			DispatchKeyValue(iEntity, "effect_name", "fluidSmokeExpl_ring_mvm");
			
			DispatchSpawn(iEntity);
			ActivateEntity(iEntity);
			AcceptEntityInput(iEntity, "Start");
			
			CreateTimer(5.0, Timer_EntityCleanup, EntIndexToEntRef(iEntity));
		}

		// Generate an earth quake effect on player's screens
		UTIL_ScreenShake(pos, 25.0, 5.0, 5.0, 1000.0, 0, true);

		// Make sure the sentry buster expires.
		g_bBlockRagdoll = true; // Set a flag to remove this player's ragdoll (since tf_gibsforced is probably 0).
		// Make sure the sentry buster dies..
		ForcePlayerSuicide(this.Index);
		FakeClientCommand(this.Index, "explode");
		if (IsPlayerAlive(this.Index))
		{
			SDKHooks_TakeDamage(this.Index, 0, this.Index, 99999999.0);
			SDKHooks_TakeDamage(this.Index, 0, this.Index, 99999999.0);
		}
	}
	
	public void Spawn()
	{
		EmitSoundToAll(SENTRY_BUSTER_LOOP_SOUND, this.Index, SNDCHAN_AUTO, _, _, 1.0);
		SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", true);
		TF2_AddCondition(this.Index, TFCond_PreventDeath, -1.0);
		g_flBusterLastTakeDmg[this.Index] = 0.0;
	}
	
	public Action OnTaunt(int iArgs)
	{
		//Taken from STT
		char strArgs[5];
		GetCmdArgString(strArgs, sizeof(strArgs));
		int iIndexTaunt = StringToInt(strArgs);
		if(iIndexTaunt >= 1 && iIndexTaunt <= 9)
		{
			FakeClientCommand(this.Index, "taunt");
			return Plugin_Stop;
		}

		this.flSpeed = 0.0;
		EmitSoundToAll(SENTRY_BUSTER_SPIN_SOUND, this.Index);

		//SDK_PlaySpecificSequence(this.Index, "sentry_buster_preExplode");
		this.UnRegisterAbility("CBraveJump");
		g_flBusterTauntTime[this.Index] = GetGameTime();
		return Plugin_Continue;
	}
	
	public void OnDeath(Event eventInfo)
	{
		StopSound(this.Index, SNDCHAN_AUTO, SENTRY_BUSTER_LOOP_SOUND);
		SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", false);
		//SendProxy_Unhook(this.Index, "m_flModelScale", Hook_SentryBusterScale);
		g_bBlockRagdoll = true;
		eventInfo.BroadcastDisabled = true;
	}
	
	public Action OnSoundPlayed(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
	{
		if (strncmp(sample, "vo/", 3) == 0)
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public Action OnTakeDamage(int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
	{
		//Taken from STT
		if(g_flBusterTauntTime[this.Index] == 0.0)
		{
			if(this.iHealth == 1)
			{
				// Condition 70 will catch the sentry buster from being killed, letting us self-destruct
				// Try to make the player taunt but be prepared if they are not taunting
				FakeClientCommand(this.Index, "taunt");
				
				if(g_flBusterTauntTime[this.Index] == 0.0) // taunt command didn't go through
				{
					this.flSpeed = 0.0;
					g_flBusterTauntTime[this.Index] = GetGameTime();
					EmitSoundToAll(SENTRY_BUSTER_SPIN_SOUND, this.Index);
				}
				damage = 0.0;
				return Plugin_Changed;
			}
			else
			{
				// Player's health hasn't reached 1 yet so make sure the prevent death condition stays applied
				TF2_AddCondition(this.Index, TFCond_PreventDeath, -1.0);
			}
		}
		else if(g_flBusterTauntTime[this.Index] != 0.0)
		{
			// Buster is armed so we should block all further damage
			damage = 0.0;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	
	public void OnButtonHold(int button)
	{
		if (button == IN_ATTACK)
		{
			int iMelee = GetPlayerWeaponSlot(this.Index, WeaponSlot_Melee);
			if (iMelee > MaxClients)
				SetEntPropFloat(iMelee, Prop_Send, "m_flNextPrimaryAttack", 99999999.0);
			
			if (g_flBusterTauntTime[this.Index] == 0.0)
				FakeClientCommand(this.Index, "taunt");
		}
	}
	
	public void Think()
	{
		if (g_flBusterTauntTime[this.Index] != 0.0 && GetGameTime() - g_flBusterTauntTime[this.Index] > SENTRY_BUSTER_DETONATE_TIME)
		{
			// Buster is armed and enough time has passed, go BOOM!
			this.Explode(110.0,"explosionTrail_seeds_mvm");
			g_flBusterTauntTime[this.Index] = 0.0;
		}
		
		if (g_flBusterLastTakeDmg[this.Index] <= (GetGameTime()-0.5))
		{
			SDKHooks_TakeDamage(this.Index, 0, 0, 1.0);
			g_flBusterLastTakeDmg[this.Index] = GetGameTime();
		}
	}
	
	public void GetEyeHeigth(float vecEyeHeight[3])
	{
		ScaleVector(vecEyeHeight, SENTRY_BUSTER_MODEL_SCALE);
	}
	
	public void Precache()
	{
		PrecacheSound(SENTRY_BUSTER_LOOP_SOUND);
		PrecacheSound(SENTRY_BUSTER_SPIN_SOUND);
		PrecacheModel(SNETRY_BUSTER_MODEL);
		for (int i = 0; i <= sizeof(g_strSoundBusterFootsteps)-1; i++) PrecacheSound(g_strSoundBusterFootsteps[i]);
	}
	
	public void Destroy()
	{
		StopSound(this.Index, SNDCHAN_AUTO, SENTRY_BUSTER_LOOP_SOUND);
		StopSound(this.Index, SNDCHAN_AUTO, SENTRY_BUSTER_LOOP_SOUND);
		SetEntProp(this.Index, Prop_Send, "m_bIsMiniBoss", false);
		//SendProxy_Unhook(this.Index, "m_flModelScale", Hook_SentryBusterScale);
	}
}

public Action Hook_SentryBusterScale(int entity, const char[] PropName, float &flValue, int element)
{
	//Fakely change player scale but don't actually change world collision!
	flValue = SENTRY_BUSTER_MODEL_SCALE;
	return Plugin_Changed;
}

public bool TraceEntityFilter_BusterExplosion(int entity, int contentsMask, int team)
{
	// Hit the world.
	if(entity <= 0) return true;

	// Pass through all players.
	if(entity >= 1 && entity <= MaxClients) return false;

	// Pass through all buildings.
	if(entity > MaxClients)
	{
		char className[32];
		GetEdictClassname(entity, className, sizeof(className));
		//PrintToServer("Hit: %s", className);
		if(strncmp(className, "obj_", 4) == 0 || strcmp(className, "tf_ammo_pack") == 0)
		{
			return false;
		}
	}

	return true;
}
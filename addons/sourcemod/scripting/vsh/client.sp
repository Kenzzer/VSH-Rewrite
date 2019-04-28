
static float g_flClientZombieLastDamage[TF_MAXPLAYERS+1];
static float g_flClientScoutLastHypeDrain[TF_MAXPLAYERS+1];
static int g_iClientFlags[TF_MAXPLAYERS+1];

static Handle g_hClientSpecialModelTimer[TF_MAXPLAYERS+1] = {null, ...};

int g_iClassesZombieSoul[] = {
	0,		// TF_CLASS_UNDEFINED
	5617,		// TF_CLASS_SCOUT,
	5625,		// TF_CLASS_SNIPER,
	5618,		// TF_CLASS_SOLDIER,
	5620,		// TF_CLASS_DEMOMAN,
	5622,		// TF_CLASS_MEDIC,
	5619,		// TF_CLASS_HEAVYWEAPONS,
	5624,		// TF_CLASS_PYRO,
	5623,		// TF_CLASS_SPY,
	5621		// TF_CLASS_ENGINEER
};

//	==========================================================
//	CLIENT UTIL FUNCTIONS
//	==========================================================

void Client_TryClimb(int iClient)
{
	int iHealth = GetEntProp(iClient, Prop_Send, "m_iHealth");
	int iHealthClimb = config.LookupInt(g_cvClimbHealth);
	if (iHealth <= iHealthClimb) return;
	
	char sClassname[64];
	float vecClientEyePos[3], vecClientEyeAng[3];
	GetClientEyePosition(iClient, vecClientEyePos);
	GetClientEyeAngles(iClient, vecClientEyeAng);

	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRay_DontHitEntity, iClient);

	if (!TR_DidHit(INVALID_HANDLE)) return;

	int iEntity = TR_GetEntityIndex(INVALID_HANDLE);
	GetEdictClassname(iEntity, sClassname, sizeof(sClassname));

	if (strcmp(sClassname, "worldspawn") != 0 && strncmp(sClassname, "prop_", 5) != 0)
		return;
	
	float vecNormal[3];
	TR_GetPlaneNormal(INVALID_HANDLE, vecNormal);
	GetVectorAngles(vecNormal, vecNormal);

	if (vecNormal[0] >= 30.0 && vecNormal[0] <= 330.0) return;
	if (vecNormal[0] <= -30.0) return;

	float vecPos[3];
	TR_GetEndPosition(vecPos);
	float flDistance = GetVectorDistance(vecClientEyePos, vecPos);

	if (flDistance >= 100.0) return;

	float fVelocity[3];
	GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", fVelocity);
	fVelocity[2] = 600.0;
	TeleportEntity(iClient, NULL_VECTOR, NULL_VECTOR, fVelocity);

	SDKHooks_TakeDamage(iClient, 0, iClient, float(iHealthClimb));
}

void Client_AddFlag(int iClient, int flag)
{
	g_iClientFlags[iClient] |= flag;
}

void Client_RemoveFlag(int iClient, int flag)
{
	g_iClientFlags[iClient] &= ~flag;
}

void Client_ResetFlags(int iClient)
{
	g_iClientFlags[iClient] = 0;
}

bool Client_HasFlag(int iClient, int flag)
{
	return !!(g_iClientFlags[iClient] & flag);
}

void Client_AddHealth(int iClient, int iAdditionalHeal, int iMaxOverHeal=0)
{
	int iMaxHealth = SDK_GetMaxHealth(iClient);
	int iHealth = GetEntProp(iClient, Prop_Send, "m_iHealth");
	int iTrueMaxHealth = iMaxHealth+iMaxOverHeal;

	if (iHealth < iTrueMaxHealth)
	{
		iHealth += iAdditionalHeal;
		if (iHealth > iTrueMaxHealth) iHealth = iTrueMaxHealth;
		SetEntProp(iClient, Prop_Send, "m_iHealth", iHealth);
	}
}

//	==========================================================
//	CLIENT CONNECTIONS
//	==========================================================

void Client_PutInServer(int iClient)
{
	DHookEntity(g_hHookGetMaxHealth, false, iClient);
	DHookEntity(g_hHookShouldTransmit, true, iClient);
	SDKHook(iClient, SDKHook_PreThink, Client_OnThink);
	SDKHook(iClient, SDKHook_SetTransmit, Client_OnTransmit);
	SDKHook(iClient, SDKHook_OnTakeDamage, Client_OnTakeDamage);
	Network_ResetClient(iClient);
	
	g_hClientSpecialRoundTimer[iClient] = null;
	g_iClientFlags[iClient] = 0;
	g_flClientZombieLastDamage[iClient] = 0.0;
	g_flClientScoutLastHypeDrain[iClient] = 0.0;
}

void Client_Disconnect(int iClient)
{
	g_hClientSpecialRoundTimer[iClient] = null;
	g_iClientFlags[iClient] = 0;
}

//	==========================================================
//	CLIENT HOOKS
//	==========================================================

public MRESReturn Client_GetMaxHealth(int iClient, Handle hReturn)
{
	if (g_clientBoss[iClient].IsValid())
	{
		DHookSetReturn(hReturn, g_clientBoss[iClient].iMaxHealth);
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public Action Client_OnTransmit(int iClient, int iOther)
{
	if (iOther == iClient) // If it's us keep transmitting 
		return Plugin_Continue;
	if (TF2_IsInvisible(iClient)) // Don't allow the networking of invisible players
		return Plugin_Handled;
	return Plugin_Continue;
}

public void Client_OnThink(int iClient)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	if (g_clientBoss[iClient].IsValid())
		g_clientBoss[iClient].Think();
	else
	{
		TFClassType class = TF2_GetPlayerClass(iClient);
		int iTeam = GetClientTeam(iClient);
		
		if (Client_HasFlag(iClient, VSH_ZOMBIE))
		{
			// Since a recent tf2 update bleeding no long "works" well Sourcemod doesn't expose the new required parameter
			// However it's a good indicator to explain why zombies are taking damage
			if (!TF2_IsPlayerInCondition(iClient, TFCond_Bleeding))
				TF2_MakeBleed(iClient, iClient, 99999.0);
			
			if (g_flClientZombieLastDamage[iClient] == 0.0 || g_flClientZombieLastDamage[iClient] <= GetGameTime()-1.0)
			{
				// Zombies lose 4% of their max health every second
				float flDamage = float(RoundToCeil(SDK_GetMaxHealth(iClient)*0.04));
				// Clamp dmg to 1 at least
				if (flDamage < 1.0) flDamage = 1.0;
				
				int iTrigger = FindEntityByClassname(-1, "trigger_hurt");
				SDKHooks_TakeDamage(iClient, iTrigger, iTrigger, flDamage, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
				g_flClientZombieLastDamage[iClient] = GetGameTime();
			}
			
			// Zombies use their zombies skin
			int iSkin = iTeam + 2;
			if (class == TFClass_Spy)
				iSkin += 18; // Don't ask spy, the spy has his zombie skin there
			if (TF2_IsUbercharged(iClient))
				iSkin += 2;
			// Force the skin
			SetEntProp(iClient, Prop_Send, "m_nForcedSkin", iSkin);
		}
		
		if (class == TFClass_Spy)
		{
			// if the spy isn't disguised as one of their teammate don't display any buff
			int iDisguiseTeam = GetEntProp(iClient, Prop_Send, "m_nDisguiseTeam");
			if (TF2_IsPlayerInCondition(iClient, TFCond_Disguised) && iDisguiseTeam != iTeam)
				return;
		}
		
		if (TF2_IsPlayerInCondition(iClient, TFCond_CritCola) && config.LookupBool(g_cvCritColaMiniCritIsCrit))
			TF2_AddCondition(iClient, TFCond_CritOnDamage, 0.1); // Cola crit are minicrit
		
		int iPrimaryWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Primary);
		int iSecondaryWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Secondary);
		int iMeleeWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Melee);
		
		int iActiveWep = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		
		char weaponPrimaryClass[32], weaponSecondaryClass[32];
		if (iPrimaryWep >= 0) GetEdictClassname(iPrimaryWep, weaponPrimaryClass, sizeof(weaponPrimaryClass));
		if (iSecondaryWep >= 0) GetEdictClassname(iSecondaryWep, weaponSecondaryClass, sizeof(weaponSecondaryClass));
		//if (iMeleeWep >= 0) GetEdictClassname(iMeleeWep, weaponMeleeClass, sizeof(weaponMeleeClass));
	
		// Baby Face's Blaster
		if (iPrimaryWep > MaxClients && strcmp(weaponPrimaryClass, "tf_weapon_pep_brawler_master") == 0)
		{
			float flMaxHype = tf_scout_hype_pep_max.FloatValue; // max meter
			float flDrain = flMaxHype * 0.07; // 7% of max meter
			float flMinimumForDrain = flMaxHype * 0.2; // 20% of max meter
			float flHype = GetEntPropFloat(iClient, Prop_Send, "m_flHypeMeter"); // client's hype meter
			if (flHype >= flMinimumForDrain && (g_flClientScoutLastHypeDrain[iClient] == 0.0 || g_flClientScoutLastHypeDrain[iClient] <= GetGameTime()-1.0))
			{
				// Add automatic drain of the meter if higher than flMinimumForDrain
				SetEntPropFloat(iClient, Prop_Send, "m_flHypeMeter", (flHype - flDrain < flMinimumForDrain) ? flMinimumForDrain : (flHype - flDrain));
				TF2_AddCondition(iClient, TFCond_SpeedBuffAlly, 0.01); // Should be necessary
				g_flClientScoutLastHypeDrain[iClient] = GetGameTime();
			}
		}
		
		// Mediguns
		if (iSecondaryWep > MaxClients && strcmp(weaponSecondaryClass, "tf_weapon_medigun") == 0)
		{
			int iHealTarget = GetEntPropEnt(iSecondaryWep, Prop_Send, "m_hHealingTarget");
			// Apply Uber & Crit on heal on medic's patient except if they are a boss or a zombie
			if (0 < iHealTarget <= MaxClients && IsClientInGame(iHealTarget) && !g_clientBoss[iHealTarget].IsValid() && !Client_HasFlag(iHealTarget, VSH_ZOMBIE))
			{
				TFClassType healTargetClass = TF2_GetPlayerClass(iHealTarget);
				
				if (healTargetClass != TFClass_Scout && healTargetClass != TFClass_Medic && healTargetClass != TFClass_Spy)
				{
					TF2_AddCondition(iHealTarget, TFCond_UberchargedCanteen, 0.1);
					TF2_AddCondition(iHealTarget, TFCond_CritOnDamage, 0.1);
				}
				else if (healTargetClass == TFClass_Scout)
					TF2_AddCondition(iClient, TFCond_SpeedBuffAlly, 0.1);
			}
		}
		
		if (class == TFClass_Spy && iActiveWep == iPrimaryWep)
			TF2_AddCondition(iClient, TFCond_Buffed, 0.1);
		else if(class == TFClass_Medic && iActiveWep == iPrimaryWep)
			TF2_AddCondition(iClient, TFCond_CritOnDamage, 0.1);
		else if (iActiveWep == iMeleeWep && class != TFClass_Spy)
			TF2_AddCondition(iClient, TFCond_CritOnDamage, 0.1);
		else if (iActiveWep == iSecondaryWep && (class == TFClass_Engineer || class == TFClass_Scout || class == TFClass_Pyro))
			TF2_AddCondition(iClient, TFCond_Buffed, 0.1);
		
		/*if (class == TFClass_Engineer)
		{
			static int TELEPORTER_BODYGROUP_ARROW 	= (1 << 1);
			bool bTeleporterHealed = false;
			bool bSentryHealed = false;
			for (int i = 1; i<= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == iTeam)
				{
					char sWepClassName[32];
					int iMedigun = GetPlayerWeaponSlot(i, WeaponSlot_Secondary);
					if (iMedigun >= 0) GetEdictClassname(iMedigun, sWepClassName, sizeof(sWepClassName));
					
					if (strcmp(sWepClassName, "tf_weapon_medigun") != 0) continue;
					
					int iBuilding = GetEntPropEnt(iMedigun, Prop_Send, "m_hHealingTarget");
					if (iBuilding > MaxClients)
					{
						char sClassname[64];
						GetEdictClassname(iBuilding, sClassname, sizeof(sClassname));
						if (strncmp(sClassname, "obj_", 4) == 0 && GetEntPropEnt(iBuilding, Prop_Send, "m_hBuilder") == iClient)
						{
							if (!bTeleporterHealed && strcmp(sClassname, "obj_teleporter") == 0)
								bTeleporterHealed = true;
							if (!bSentryHealed && strcmp(sClassname, "obj_sentrygun") == 0)
								bSentryHealed = true;
							if (bTeleporterHealed && bSentryHealed)
								break;
						}
					}
				}
			}
			
			float flVal = 0.0;
			bool bHadBidirectionalTeleport = false;
			if (!bTeleporterHealed && TF2_FindAttribute(iClient,ATTRIB_BIDERECTIONAL, flVal) && flVal >= 1.0)
			{
				bHadBidirectionalTeleport = true;
				int tele = MaxClients+1;
				while((tele = FindEntityByClassname(tele, "obj_teleporter")) > MaxClients)
				{
					TFObjectMode mode = view_as<TFObjectMode>(GetEntProp(tele, Prop_Send, "m_iObjectMode"));
					if(mode == TFObjectMode_Exit && GetEntPropEnt(tele, Prop_Send, "m_hBuilder") == iClient)
					{
						int iBodyGroups = GetEntProp(tele, Prop_Send, "m_nBody");
						SetEntProp(tele, Prop_Send, "m_nBody", iBodyGroups &~ TELEPORTER_BODYGROUP_ARROW);
						break;
					}
				}
			}
			TF2Attrib_SetByDefIndex(iClient, ATTRIB_BIDERECTIONAL, (bTeleporterHealed) ? 1.0 : 0.0);
			if (bTeleporterHealed && !bHadBidirectionalTeleport)
			{
				int tele = MaxClients+1;
				while((tele = FindEntityByClassname(tele, "obj_teleporter")) > MaxClients)
				{
					TFObjectMode mode = view_as<TFObjectMode>(GetEntProp(tele, Prop_Send, "m_iObjectMode"));
					if(mode == TFObjectMode_Exit && GetEntPropEnt(tele, Prop_Send, "m_hBuilder") == iClient)
					{
						int iBodyGroups = GetEntProp(tele, Prop_Send, "m_nBody");
						SetEntProp(tele, Prop_Send, "m_nBody", iBodyGroups | TELEPORTER_BODYGROUP_ARROW);
						break;
					}
				}
			}
			TF2Attrib_SetByDefIndex(iClient, ATTRIB_SENTRYATTACKSPEED, (bSentryHealed) ? 0.5 : 1.0);
		}*/
		
		if (g_bRoundStarted)
		{
			int iTarget = iClient;
			if (!IsPlayerAlive(iClient))
			{
				int iOberserTarget = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
				if (iOberserTarget != iClient && 0 < iOberserTarget <= MaxClients && IsClientInGame(iOberserTarget) && !g_clientBoss[iOberserTarget].IsValid())
					iTarget = iOberserTarget;
			}
			
			SetHudTextParams(-1.0, 0.88, 0.15, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
			char sStart[64], sMessage[255];
			if (iTarget != iClient)
				Format(sStart, sizeof(sStart), "%N's ", iTarget);
			
			if (g_iPlayerAssistDamage[iTarget] <= 0)
				Format(sMessage, sizeof(sMessage), "%sDamage: %i", sStart, g_iPlayerDamage[iTarget]);
			else
				Format(sMessage, sizeof(sMessage), "%sDamage: %i Assist: %i", sStart, g_iPlayerDamage[iTarget], g_iPlayerAssistDamage[iTarget]);
			
			int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
			if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss) && IsPlayerAlive(iMainBoss))//Display health bar stats
				Format(sMessage, sizeof(sMessage), "%s\nBoss Health: %i/%i", sMessage, g_iHealthBarHealth, g_iHealthBarMaxHealth);
			
			ShowSyncHudText(iClient, g_hInfoHud, sMessage);
		}
	}
}

public Action Client_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action finalAction = Plugin_Continue;
	
	char weaponClass[32];
	if (weapon >= 0) GetEdictClassname(weapon, weaponClass, sizeof(weaponClass));

	// is valid victim
	if (0 < victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) > 1)
	{
		bool bIsVictimBoss = g_clientBoss[victim].IsValid();
		bool bVictimUbered = TF2_IsUbercharged(victim);
		if (bIsVictimBoss)
			finalAction = g_clientBoss[victim].OnTakeDamage(attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
		// is valid attacker
		if (0 < attacker <= MaxClients && IsClientInGame(attacker))
		{
			if (!g_clientBoss[attacker].IsValid()) // Regular players
			{
				if (bIsVictimBoss && !g_clientBoss[victim].IsMinion)
				{
					int iPrimaryWep = GetPlayerWeaponSlot(attacker, WeaponSlot_Primary);
					int iPrimaryItemIndex = (MaxClients < iPrimaryWep) ? GetEntProp(iPrimaryWep, Prop_Send, "m_iItemDefinitionIndex") : -1;

					int iSecondaryWep = GetPlayerWeaponSlot(attacker, WeaponSlot_Secondary);
					//int iSecondaryItemIndex = (MaxClients < iSecondaryWep) ? GetEntProp(iSecondaryWep, Prop_Send, "m_iItemDefinitionIndex") : -1;

					int iActiveWepIndex = (weapon > MaxClients && HasEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
					char sWeaponClass[64];
					if (weapon > MaxClients)
						GetEdictClassname(weapon, sWeaponClass, sizeof(sWeaponClass));

					if (damagecustom == TF_CUSTOM_BACKSTAB && !bVictimUbered)
					{
						// Boss backstab will award crits on the diamond back
						if (iPrimaryItemIndex == ITEM_DIAMONDBACK)
						{
							int iCrits = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
							SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", iCrits+config.LookupInt(g_cvDiamondbackCritReward));
						}
						
						if (iActiveWepIndex == ITEM_BIG_EARNER)
						{
							// Big earner refills the cloak and award a speed boost
							float flCloakMeter = GetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter");
							flCloakMeter += config.LookupFloat(g_cvBackstabBigEarnerCloak);
							if (flCloakMeter > 100.0) flCloakMeter = 100.0;
							SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", flCloakMeter);
							
							float flSpeedBoostDuration = config.LookupFloat(g_cvBackstabBigEarnerSpeedBoostDuration);
							if (flSpeedBoostDuration != 0.0)
								TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, flSpeedBoostDuration);
						}
						else if (iActiveWepIndex == ITEM_KUNAI)
						{
							// Kunai heal on backstab
							int iHeal = config.LookupInt(g_cvBackstabKunaiHeal);
							Client_AddHealth(attacker, iHeal, iHeal);
						}
						else if (iActiveWepIndex == ITEM_YOUR_ETERNAL_REWARD || iActiveWepIndex == ITEM_WANGA_PRICK)
						{
							// Eternal Reward & Wanga Prick won't do any damage until the 4th backstab
							// Upon 4th backstab the boss will receive damage and take a +25% damage vulnerability (effect doesn't stack up)
							g_iPlayerTotalBackstab[attacker][victim]++;
							
							int iTotalBackstab = g_iPlayerTotalBackstab[attacker][victim];
							if (1 <= iTotalBackstab <= 4)
							{
								SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()-0.1);
								char sBackStabSound[PLATFORM_MAX_PATH];
								Format(sBackStabSound, sizeof(sBackStabSound), "vsh_rewrite/stab0%i.mp3", iTotalBackstab);
								
								EmitSoundToAll(sBackStabSound);
								char sMessage[255];
								Format(sMessage, sizeof(sMessage), "%N vs %N\nTotal backstab: %i/4", attacker, victim, iTotalBackstab);
								if (iTotalBackstab == 4)
								{
									Format(sMessage, sizeof(sMessage), "%s\n 25% damage vulnerability", sMessage);
									TF2Attrib_SetByDefIndex(victim, ATTRIB_DAMAGE_VULNERABILITY, 1.25);
									TF2Attrib_ClearCache(victim);
								}
								else
									damage = 0.0;
								PrintHintTextToAll(sMessage);
								finalAction = Plugin_Changed;
							}
						}
					}
					else if (damagecustom == TF_CUSTOM_BOOTS_STOMP)
					{
						// We wanna cap the stomp dmg to a certain value
						damage = config.LookupFloat(g_cvBossPlayerStompDmg);
						finalAction = Plugin_Changed;
					}
					
					if (iSecondaryWep > MaxClients)
					{
						char sSecondaryWepClass[64];
						GetEdictClassname(iSecondaryWep, sSecondaryWepClass, sizeof(sSecondaryWepClass));
						
						if (weapon == iPrimaryWep && strcmp(sSecondaryWepClass, "tf_weapon_medigun") == 0)
						{
							float flCurrentUber = GetEntPropFloat(iSecondaryWep, Prop_Send, "m_flChargeLevel");
							bool bChargeReleased = view_as<bool>(GetEntProp(iSecondaryWep, Prop_Send, "m_bChargeRelease"));
							if (flCurrentUber < 1.0 && !bChargeReleased)
							{
								// Any hit on the boss with a syringue gun will award ubercharge
								if (strcmp(weaponClass, "tf_weapon_syringegun_medic") == 0)
									flCurrentUber += config.LookupFloat(g_cvSyringueUberReward);
								else // For now the medic only has 2 wep, crossbow or syringue gun
									flCurrentUber += config.LookupFloat(g_cvCrossBowUberReward);
									
								if (flCurrentUber >= 1.0)
								{
									flCurrentUber = 1.0;
									FakeClientCommand(attacker, "voicemenu 1 7");//Play fully charge line
								}
								SetEntPropFloat(iSecondaryWep, Prop_Send, "m_flChargeLevel", flCurrentUber);
							}
						}
					}
					
					if (strncmp(sWeaponClass, "tf_weapon_sniperrifle", 21) == 0)
					{
						float flSniperCharge = GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage");
						if (damagecustom == TF_CUSTOM_HEADSHOT)
						{
							// Decapitations are added by the game if the player dies, but since bosses can't die from just one headshot a fair balance is to add decapitations for every successful headshots
							if (iActiveWepIndex == ITEM_BAZARR)
								SetEntProp(attacker, Prop_Send, "m_iDecapitations", GetEntProp(attacker, Prop_Send, "m_iDecapitations") + config.LookupInt(g_cvBazaarDecapBonus));
							damage *= config.LookupFloat(g_cvSniperHeadshotDamageMult);
							finalAction = Plugin_Changed;
						}
						
						// Any damage dealt with the sniper riffle will add a glow on the boss
						float flGlowTime = config.LookupFloat(g_cvSniperGlowTime)*(flSniperCharge/100.0);
						g_clientBoss[victim].flGlowTime = flGlowTime;
						
						if (iActiveWepIndex == ITEM_HITMAN)
						{
							float flRageAdd = config.LookupFloat(g_cvHitmanFocusBonus)*(flSniperCharge/100.0);
							if (TF2_IsPlayerInCondition(attacker, TFCond_FocusBuff))
								flRageAdd /= 3.0;//If we are already in focus buff divide the bonus by 3
							float flRage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
							flRage += flRageAdd;
							if (flRage > 100.0) flRage = 100.0;
							SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", flRage);
						}
					}
					else if (strcmp(sWeaponClass, "tf_weapon_sword") == 0)
					{
						// Disable knockback
						damagetype |= DMG_PREVENT_PHYSICS_FORCE;
						// Update heads
						int iNewHeads = GetEntProp(attacker, Prop_Send, "m_iDecapitations")+1;
						SetEntProp(attacker, Prop_Send, "m_iDecapitations", iNewHeads);
						// Update player's health
						Client_AddHealth(attacker, 15, 15);
						// Recalculate player's speed
						TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.01);
						
						finalAction = Plugin_Changed;
					}
					else if (strcmp(sWeaponClass, "tf_weapon_katana") == 0)
					{
						// Allow them to switch to another weapon since they hit the boss
						SetEntProp(weapon, Prop_Send, "m_bIsBloody", true);
						if (GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy") < 1)
							SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
					}
					
					if ((damagetype & 0x80) && weapon > MaxClients)// Melee hit
					{
						if (g_iPlayerTotalBackstab[attacker][victim] >= 4)
						{
							CBaseBoss boss = g_clientBoss[victim];
							damage = float(boss.iMaxHealth/4);
							if (damagetype & DMG_ACID) damage /= 3.0;
							finalAction = Plugin_Changed;
						}
						
						//Turn attributes that require a kill into a "on hit" attribute.
						float flVal = 0.0;
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_HEALTH_PACK_ON_KILL, flVal) && flVal != 0.0)
						{
							for (int i = 0; i < 2; i++)
							{
								int iHealthPack = CreateEntityByName("item_healthkit_small");
								float vecPos[3];
								GetClientAbsOrigin(attacker, vecPos);
								vecPos[2] += 20.0;
								if (iHealthPack > MaxClients)
								{
									DispatchKeyValue(iHealthPack, "OnPlayerTouch", "!self,Kill,,0,-1");
									DispatchSpawn(iHealthPack);
									SetEntProp(iHealthPack, Prop_Send, "m_iTeamNum", GetClientTeam(attacker));
									SetEntityMoveType(iHealthPack, MOVETYPE_VPHYSICS);
									float vecVel[3];
									vecVel[0] = float(GetRandomInt(-10, 10)), vecVel[1] = float(GetRandomInt(-10, 10)), vecVel[2] = 50.0;
									TeleportEntity(iHealthPack, vecPos, NULL_VECTOR, vecVel);
								}
							}
						}
						
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_CRITBOOST_ON_KILL, flVal) && flVal > 0.0)
							TF2_AddCondition(attacker, TFCond_CritOnDamage, flVal);
						
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_HEAL_ON_KILL, flVal) && flVal > 0.0)
							Client_AddHealth(attacker, RoundToNearest(flVal), RoundToNearest(flVal));
						
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_MARK_FOR_DEATH, flVal) && flVal > 0.0)
							g_clientBoss[victim].iRageDamage -= config.LookupInt(g_cvMarkForDeathRageDamageDrain);
						
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_REGEN_HEALTH_ON_KILL, flVal) && flVal > 0.0)
							Client_AddHealth(attacker, RoundToCeil(float(SDK_GetMaxHealth(attacker))*config.LookupFloat(g_cvRegenHealthOnKillPercentage)), 0);
							
						if (TF2_WeaponFindAttribute(weapon, ATTRIB_CRIT_LAUGH, flVal) && flVal > 0.0)// Don't allow items using that attribute to crit on bosses
						{
							damagetype = 0x80;
							finalAction = Plugin_Changed;
						}
					}
					
					if (weapon > MaxClients && strncmp(sWeaponClass, "tf_we", 5) == 0 && TF2_WeaponCanHaveRevengeCrits(weapon))
					{
						// Any revenge crit do a lil more damage than regulars crit
						int iRevengeCrit = GetEntProp(attacker, Prop_Send, "m_iRevengeCrits");
						if (iRevengeCrit > 0)
						{
							damage *= config.LookupFloat(g_cvRevengeCritMult);
							finalAction = Plugin_Changed;
						}
					}
					
					switch (iActiveWepIndex)
					{
						case ITEM_THIRDDEGREE:
						{
							// Any hit with the third degree on the boss will give uber to any medic healing the attacker
							// First collect all the healers
							ArrayList aHealer = new ArrayList();
							for (int i = 1; i <= MaxClients; i++)
							{
								if (IsClientInGame(i) && IsPlayerAlive(i) && !g_clientBoss[i].IsValid())
								{
									int iMedigun = GetPlayerWeaponSlot(i, WeaponSlot_Secondary);
									if (iMedigun > MaxClients)
									{
										char sWepClassName[64];
										GetEdictClassname(iMedigun, sWepClassName, sizeof(sWepClassName));
										if (strcmp(sWepClassName, "tf_weapon_medigun") == 0)
										{
											bool bChargeReleased = view_as<bool>(GetEntProp(iMedigun, Prop_Send, "m_bChargeRelease"));
											if (bChargeReleased) continue;
											
											int iHealTarget = GetEntPropEnt(iMedigun, Prop_Send, "m_hHealingTarget");
											if (iHealTarget == attacker)
												aHealer.Push(i);
										}
									}
								}
							}
							// Divide the total amount of uber to award by the number of medic healing
							int iTotalHealer = aHealer.Length;
							float flUber = config.LookupFloat(g_cvThirdDegreeUberReward)/float(iTotalHealer);
							for (int i = 0; i < iTotalHealer; i++)
							{
								int iHealTarget = aHealer.Get(i);
								int iMedigun = GetPlayerWeaponSlot(iHealTarget, WeaponSlot_Secondary);
								float flNewUber = GetEntPropFloat(iMedigun, Prop_Send, "m_flChargeLevel")+flUber;
								if (flNewUber > 1.0) flNewUber = 1.0;
								SetEntPropFloat(iMedigun, Prop_Send, "m_flChargeLevel", flNewUber);
							}
							delete aHealer;
						}
						case ITEM_MARKET_GARDENER:
						{
							if (TF2_IsPlayerInCondition(attacker, TFCond_BlastJumping))
							{
								damage = ( ( 0.03*float(SDK_GetMaxHealth(victim)) ) / ( Pow(1.04,float(VSH_GetTeamCount(GetClientTeam(attacker), true, false, false))) ) )/3.0;
								if (damage < 200.0) damage = 200.0;
								
								damagetype |= DMG_CRIT;
								
								if (TF2_IsPlayerInCondition(attacker, TFCond_Parachute))
								{
									damage *= 0.67;
									TF2_RemoveCondition(victim, TFCond_Parachute);
								}

								PrintCenterText(attacker, "You market gardened him!");
								PrintCenterText(victim, "You were just market gardened!");

								EmitSoundToAll("player/doubledonk.wav", attacker);
								TF2_RemoveCondition(victim, TFCond_BlastJumping);
								finalAction = Plugin_Changed;
							}
						}
					}
				}
				
				if (Client_HasFlag(attacker, VSH_ZOMBIE) && victim != attacker)
				{
					int iHeal = RoundToNearest(damage);
					if (iHeal > 20) iHeal = 20;
					
					Client_AddHealth(attacker, iHeal, 0);
				}
			}
			else // Instead if the attacker is a boss
			{
				if (!bIsVictimBoss)
				{
					// Drain cloack meter
					if (TF2_IsPlayerInCondition(victim, TFCond_Cloaked))
					{
						damagetype &= ~DMG_CRIT;
						float flCloakMeter = GetEntPropFloat(victim, Prop_Send, "m_flCloakMeter");
						if (flCloakMeter <= 0.1)
							TF2_RemoveCondition(victim, TFCond_Cloaked);
						SetEntPropFloat(victim, Prop_Send, "m_flCloakMeter", GetEntPropFloat(victim, Prop_Send, "m_flCloakMeter") / 10.0);
						finalAction = Plugin_Changed;
					}
					// Never crit on feignted players
					if (GetEntProp(victim, Prop_Send, "m_bFeignDeathReady"))
					{
						damagetype &= ~DMG_CRIT;
						finalAction = Plugin_Changed;
					}

					// Damage resis is used steak
					if (TF2_IsPlayerInCondition(victim, TFCond_CritCola) && TF2_IsPlayerInCondition(victim, TFCond_RestrictToMelee))
					{
						damage *= config.LookupFloat(g_cvSteakBuffDamageResis);
						finalAction = Plugin_Changed;
					}

					// Knockback ubered players
					if (bVictimUbered)
					{
						float vecVel[3], vecBossPos[3], vecVictimPos[3];
						GetClientAbsOrigin(attacker, vecBossPos);
						GetClientAbsOrigin(victim, vecVictimPos);
						SubtractVectors(vecVictimPos, vecBossPos, vecVel);
						NormalizeVector(vecVel, vecVel);
						vecVel[2] += 1.5;
						ScaleVector(vecVel, 400.0);
						TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vecVel);
					}
					// Else, when not ubered, run code below
					else
					{
						// Don't do any dmg and destroy the demoman's shield if they have one
						int iWearable = SDK_GetEquippedWearable(victim, WeaponSlot_Secondary);
						if (iWearable > MaxClients)
						{
							char sWearableClass[32];
							GetEdictClassname(iWearable, sWearableClass, sizeof(sWearableClass));
							if (strcmp(sWearableClass, "tf_wearable_demoshield") == 0)
							{
								EmitSoundToAll(BOSS_BACKSTAB_SOUND, victim, _, SNDLEVEL_DISHWASHER);
								
								TF2_AddCondition(victim, TFCond_Bonked, 0.1);
								TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 1.0);
								damage = 1.0;
								
								TF2_RemoveItemInSlot(victim, WeaponSlot_Secondary);
								finalAction = Plugin_Changed;
							}
						}
					}
				}
			}
		}

		// zombie'd players (made for announcer summons, but it applies fine in general context here) take capped falling damage
		if (Client_HasFlag(victim, VSH_ZOMBIE) && damagetype & DMG_FALL && (attacker <= 0 || attacker > MaxClients) && inflictor == 0)
		{
			float flMaxDamage = config.LookupFloat(g_cvSummonedPlayerFallDamageCap);
			damage = (damage > flMaxDamage) ? flMaxDamage : damage;
			finalAction = Plugin_Changed;
		}
	}
	return finalAction;
}

public Action Client_VoiceCommand(int iClient, const char[] sCommand, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iArgs < 2) return Plugin_Handled;

	char sCmd1[8], sCmd2[8];

	GetCmdArg(1, sCmd1, sizeof(sCmd1));
	GetCmdArg(2, sCmd2, sizeof(sCmd2));

	if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(iClient))
	{
		if (g_clientBoss[iClient].IsValid() && g_clientBoss[iClient].iMaxRageDamage != -1 && (g_clientBoss[iClient].iRageDamage >= g_clientBoss[iClient].iMaxRageDamage) && !TF2_IsPlayerInCondition(iClient, TFCond_Dazed))
		{
			g_clientBoss[iClient].OnRage(false);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

bool g_inTauntListener = false;
public Action Client_TauntCommand(int iClient, const char[] sCommand, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (g_inTauntListener)
	{
		g_inTauntListener = false;
		return Plugin_Continue;
	}

	if (iClient >= 1 && iClient <= MaxClients && GetEntProp(iClient, Prop_Send, "m_hGroundEntity") != -1 && !TF2_IsPlayerInCondition(iClient, TFCond_Taunting))
	{
		if (g_clientBoss[iClient].IsValid())
			return g_clientBoss[iClient].OnTaunt(iArgs);
	}

	return Plugin_Continue;
}

public Action Client_JoinTeamCommand(int iClient, const char[] sCommand, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	
	if (strcmp(sCommand, "jointeam") == 0 && iArgs > 0)
	{
		char sTeam[64];
		GetCmdArg(1, sTeam, sizeof(sTeam));
		if (strcmp(sTeam, "spectate") == 0)
			return Plugin_Continue;
	}
	
	int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
	if (iMainBoss > 0 && iMainBoss <= MaxClients && IsClientInGame(iMainBoss))
	{
		if (iMainBoss == iClient) return Plugin_Handled; // Main boss cannot be allowed to switch team
		if (g_clientBoss[iClient].IsValid()) return Plugin_Handled; // Whoever that is, a minion, a companion ... if they use a boss object while a main boss is active they cannot switch team under any circumstances
		
		int iBossTeam = GetClientTeam(iMainBoss);
		if (iBossTeam > 1 && !Client_HasFlag(iMainBoss, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM))
		{
			int iSwapTeam = (iBossTeam == TFTeam_Blue) ? TFTeam_Red : TFTeam_Blue;
			ChangeClientTeam(iClient, iSwapTeam);
			ShowVGUIPanel(iClient, iSwapTeam == TFTeam_Blue ? "class_blue" : "class_red");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

//	==========================================================
//	CLIENT COMMANDS
//	==========================================================

Action Client_OnButton(int client, int button)
{
	if (g_clientBoss[client].IsValid())
		return g_clientBoss[client].OnButton(button);
	return Plugin_Continue;
}

void Client_OnButtonPress(int client, int button)
{
	if (g_clientBoss[client].IsValid())
	{
		g_clientBoss[client].OnButtonPress(button);
	}
	else
	{
		if (button == IN_ATTACK)
		{
			TFClassType class = TF2_GetPlayerClass(client);
			if (class == TFClass_Sniper)
			{
				int iActiveWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if (iActiveWep > MaxClients)
				{
					if (iActiveWep == GetPlayerWeaponSlot(client, WeaponSlot_Melee))
					{
						Client_TryClimb(client);
					}
				}
			}
		}
		else if (button == IN_RELOAD)
		{
			if (TF2_IsPlayerInCondition(client, TFCond_Dazed)) return;
			if (!config.LookupBool(g_cvMedigunPatientTeleport)) return;
			
			int iSecondaryWep = GetPlayerWeaponSlot(client, WeaponSlot_Secondary);
			char weaponSecondaryClass[32];
			if (iSecondaryWep >= 0) GetEdictClassname(iSecondaryWep, weaponSecondaryClass, sizeof(weaponSecondaryClass));
			
			// Teleport to patient if available
			if (strcmp(weaponSecondaryClass, "tf_weapon_medigun") == 0)
			{
				int iHealTarget = GetEntPropEnt(iSecondaryWep, Prop_Send, "m_hHealingTarget");
				if (0 < iHealTarget <= MaxClients)
				{
					float vecPos[3];
					GetClientAbsOrigin(iHealTarget, vecPos);
					TeleportEntity(client, vecPos, NULL_VECTOR, NULL_VECTOR);
					
					float flDuration = config.LookupFloat(g_cvPatientTeleportStunDuration);
					if (flDuration > 0.0)
						TF2_StunPlayer(client, flDuration, 1.0, TF_STUNFLAG_SLOWDOWN|TF_STUNFLAG_BONKSTUCK, 0);
				}
			}
		}
	}
}

void Client_OnButtonHold(int client, int button)
{
	if (g_clientBoss[client].IsValid())
		g_clientBoss[client].OnButtonHold(button);
}

void Client_OnButtonRelease(int client, int button)
{
	if (g_clientBoss[client].IsValid())
		g_clientBoss[client].OnButtonRelease(button);
}

//	==========================================================
//	CLIENT LOGIC
//	==========================================================

void Client_Spawn(int iClient)
{
	g_hClientSpecialRoundTimer[iClient] = null;
	g_hClientSpecialModelTimer[iClient] = null;
	
	if (!g_clientBoss[iClient].IsValid())
	{
		if (Client_HasFlag(iClient, VSH_ZOMBIE))
			g_hClientSpecialModelTimer[iClient] = CreateTimer(0.1, Timer_ApplyZombieModel, GetClientUserId(iClient), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		else if (VSH_SpecialRound(SPECIALROUND_YETISVSHALE))
			g_hClientSpecialRoundTimer[iClient] = CreateTimer(0.1, Timer_SpecialRoundYetiModel, GetClientUserId(iClient), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

void Client_ApplyEffects(int iClient)
{
	if (g_clientBoss[iClient].IsValid())
		return;
	
	// Weapon bonus
	int iPrimaryWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Primary);
	int iSecondaryWep = SDK_GetEquippedWearable(iClient, WeaponSlot_Secondary);
	
	char weaponPrimaryClass[32], weaponSecondaryClass[32];
	if (iPrimaryWep >= 0) GetEdictClassname(iPrimaryWep, weaponPrimaryClass, sizeof(weaponPrimaryClass));
	if (iSecondaryWep >= 0) GetEdictClassname(iSecondaryWep, weaponSecondaryClass, sizeof(weaponSecondaryClass));
	
	if (strcmp(weaponPrimaryClass, "tf_weapon_compound_bow") == 0 || strcmp(weaponSecondaryClass, "tf_wearable_demoshield") == 0)
		TF2_AddCondition(iClient, TFCond_CritOnDamage, -1.0);
	
	SetEntProp(iClient, Prop_Send, "m_bForcedSkin", false);
	
	if (Client_HasFlag(iClient, VSH_ZOMBIE))
	{
		Handle hItem = configWeapon.PrepareItemHandle("tf_wearable", g_iClassesZombieSoul[view_as<int>(TF2_GetPlayerClass(iClient))], 100, TFQual_Normal);
		int iZombie = TF2Items_GiveNamedItem(iClient, hItem);
		if (iZombie > MaxClients)
		{
			SetEntProp(iZombie, Prop_Send, "m_bValidatedAttachedEntity", true);
			SDK_EquipWearable(iClient, iZombie);
		}
		
		SetEntProp(iClient, Prop_Send, "m_bForcedSkin", true);
		delete hItem;
	}
}
	

//	==========================================================
//	CLIENT TIMERS
//	==========================================================

public Action Timer_ApplyZombieModel(Handle hTimer, int userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0 || !IsClientInGame(iClient))
		return Plugin_Stop;
	
	if (!Client_HasFlag(iClient, VSH_ZOMBIE))
		return Plugin_Stop;
	
	if (g_hClientSpecialModelTimer[iClient] != hTimer)
		return Plugin_Stop;
	
	SetVariantString("");
	AcceptEntityInput(iClient, "SetCustomModel");
	SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", true);
	
	return Plugin_Continue;
}
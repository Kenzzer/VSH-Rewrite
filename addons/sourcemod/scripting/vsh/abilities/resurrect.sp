static int g_iCharge[TF_MAXPLAYERS+1];
static int g_iMaxCharge[TF_MAXPLAYERS+1];
static int g_iChargeBuild[TF_MAXPLAYERS+1];
static int g_iMaxRevival[TF_MAXPLAYERS+1];
static int g_iHealthPerRevival[TF_MAXPLAYERS+1];
static float g_flResurrectHUD_Xpos[TF_MAXPLAYERS+1];
static float g_flResurrectHUD_Ypos[TF_MAXPLAYERS+1];
static float g_flCooldown[TF_MAXPLAYERS+1];
static float g_flCooldownWait[TF_MAXPLAYERS+1];
static bool g_bClientHoldingChargeButton[TF_MAXPLAYERS+1];
static Handle g_hResurrectHUD;

methodmap CResurrect < IAbility
{
	property int iMaxCharge
	{
		public get()
		{
			return g_iMaxCharge[this.Client];
		}
		public set(int val)
		{
			g_iMaxCharge[this.Client] = val;
		}
	}
	
	property int iCharge
	{
		public get()
		{
			return g_iCharge[this.Client];
		}
		public set(int val)
		{
			g_iCharge[this.Client] = val;
			if (g_iCharge[this.Client] > this.iMaxCharge) g_iCharge[this.Client] = this.iMaxCharge;
			if (g_iCharge[this.Client] < 0) g_iCharge[this.Client] = 0;
		}
	}
	
	property int iMaxRevival
	{
		public get()
		{
			return g_iMaxRevival[this.Client];
		}
		public set(int val)
		{
			g_iMaxRevival[this.Client] = val;
		}
	}
	
	property int iHealthPerRevival
	{
		public get()
		{
			return g_iHealthPerRevival[this.Client];
		}
		public set(int val)
		{
			g_iHealthPerRevival[this.Client] = val;
		}
	}
	
	property int iChargeBuild
	{
		public get()
		{
			return g_iChargeBuild[this.Client];
		}
		public set(int val)
		{
			g_iChargeBuild[this.Client] = val;
		}
	}
	
	property float HUD_X
	{
		public get()
		{
			return g_flResurrectHUD_Xpos[this.Client];
		}
		public set(float val)
		{
			g_flResurrectHUD_Xpos[this.Client] = val;
		}
	}
	
	property float HUD_Y
	{
		public get()
		{
			return g_flResurrectHUD_Ypos[this.Client];
		}
		public set(float val)
		{
			g_flResurrectHUD_Ypos[this.Client] = val;
		}
	}
	
	property float flCooldown
	{
		public get()
		{
			return g_flCooldown[this.Client];
		}
		public set(float val)
		{
			g_flCooldown[this.Client] = val;
		}
	}
	
	property float flCooldownWait
	{
		public get()
		{
			return g_flCooldownWait[this.Client];
		}
		public set(float val)
		{
			if (val != 0.0)
				val += GetGameTime();
			g_flCooldownWait[this.Client] = val;
		}
	}
	
	public CResurrect(IAbility ability)
	{
		g_iCharge[ability.Client] = 0;
		
		if (g_hResurrectHUD == null)
			g_hResurrectHUD = CreateHudSynchronizer();
		
		//Default values, these can be changed if needed
		CResurrect ressurectAbility = view_as<CResurrect>(ability);
		ressurectAbility.iMaxCharge = 200;
		ressurectAbility.iChargeBuild = 4;
		ressurectAbility.HUD_X = -1.0;
		ressurectAbility.HUD_Y = 0.88;
		ressurectAbility.flCooldown = 30.0;
		ressurectAbility.flCooldownWait = 30.0;
		ressurectAbility.iMaxRevival = 4;
		ressurectAbility.iHealthPerRevival = 500;
	}
	
	public void Think()
	{
		SetHudTextParams(this.HUD_X, this.HUD_Y, 0.15, 255, 255, 255, 255);
		if (this.iCharge > 0)
			ShowSyncHudText(this.Client, g_hResurrectHUD, "Resurrect charge: %0.2f%%. Look up and stand up to use resurrection.", (float(this.iCharge)/float(this.iMaxCharge))*100.0);
		else
			ShowSyncHudText(this.Client, g_hResurrectHUD, "Hold right click or crouch to resurrect players!");
		
		if (this.flCooldownWait != 0.0 && this.flCooldownWait > GetGameTime())
		{
			float flRemainingTime = this.flCooldownWait-GetGameTime();
			int iSec = RoundToNearest(flRemainingTime);
			ShowSyncHudText(this.Client, g_hResurrectHUD, "Resurrect cooldown %i second%s remaining!", iSec, (iSec > 1) ? "s" : "");
			return;
		}
		
		this.flCooldownWait = 0.0;
		
		if (g_bClientHoldingChargeButton[this.Client])
			this.iCharge += this.iChargeBuild;
		else
			this.iCharge -= this.iChargeBuild*2;
	}
	
	public Action OnButton(int button)
	{
		if (button == IN_ATTACK2)
			return Plugin_Handled;
		return Plugin_Continue;
	}
	
	public void OnButtonHold(int button)
	{
		if ((button == IN_DUCK) || (button == IN_ATTACK2))
			g_bClientHoldingChargeButton[this.Client] = true;
	}
	
	public void OnButtonRelease(int button)
	{
		if ((button == IN_DUCK) || (button == IN_ATTACK2))
		{
			g_bClientHoldingChargeButton[this.Client] = false;
			
			if (TF2_IsPlayerInCondition(this.Client, TFCond_Dazed)) // Can't ressurect if stunned
				return;
			
			if (this.flCooldownWait != 0.0 && this.flCooldownWait > GetGameTime()) return;
			if (this.iCharge != this.iMaxCharge) return;
			
			// Collect dead players
			int iTotalRevived = 0;
			ArrayList aDeadPlayers = new ArrayList();
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) > 1 && !IsPlayerAlive(i) && g_iPlayerPreferences[i][PlayerPreference_RevivalSelect])
				{
					if (g_clientBoss[i] != INVALID_BOSS && !g_clientBoss[i].IsMinion) continue; // Can't let dead boss ressurect
					
					aDeadPlayers.Push(i);
				}
			}
			
			// No dead players abort
			int iTotalPlayers = aDeadPlayers.Length;
			if (iTotalPlayers <= 0)
			{
				delete aDeadPlayers;
				return;
			}
			
			// Find the boss team
			int iBossTeam = GetClientTeam(this.Client);
			// Sort the array randomly so not the same players are ressurected
			SortADTArray(aDeadPlayers, Sort_Random, Sort_Integer);
			
			for (int i = 0; i < iTotalPlayers && iTotalRevived < this.iMaxRevival; i++)
			{
				int iPlayer = aDeadPlayers.Get(i);
				if (g_clientBoss[iPlayer] != INVALID_BOSS) // They were a minion, destroy their object
				{
					g_clientBoss[iPlayer].Destroy();
					g_clientBoss[iPlayer] = INVALID_BOSS;
				}
				
				// Allow them to join the boss team
				Client_AddFlag(iPlayer, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
				Client_AddFlag(iPlayer, VSH_ZOMBIE);
				// Move them to the boss team
				TF2_ForceTeamJoin(iPlayer, iBossTeam);
				TF2_RespawnPlayer(iPlayer);
				
				iTotalRevived++;
				
				// Drain the boss health per revival
				if (g_clientBoss[this.Client].iHealth > this.iHealthPerRevival)
					g_clientBoss[this.Client].iHealth -= this.iHealthPerRevival;
				else
					g_clientBoss[this.Client].iHealth = 1;
			}
			
			// Free the array
			delete aDeadPlayers;
			this.flCooldownWait = this.flCooldown*(iTotalRevived/this.iMaxRevival);
			
			// Play ability sound
			char sSound[PLATFORM_MAX_PATH];
			g_clientBoss[this.Client].GetAbilitySound(sSound, sizeof(sSound), "CResurrect");
			if (strcmp(sSound, "") != 0)
				EmitSoundToAll(sSound, this.Client, SNDCHAN_VOICE, SNDLEVEL_AIRCRAFT);
		}
	}
}
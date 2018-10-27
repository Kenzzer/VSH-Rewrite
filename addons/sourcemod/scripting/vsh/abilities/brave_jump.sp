static int g_iBraveJumpCharge[TF_MAXPLAYERS+1];
static int g_iBraveJumpMaxCharge[TF_MAXPLAYERS+1];
static int g_iBraveJumpChargeBuild[TF_MAXPLAYERS+1];
static float g_flBraveJumpMaxHeigth[TF_MAXPLAYERS+1];
static float g_flBraveJumpHUD_Xpos[TF_MAXPLAYERS+1];
static float g_flBraveJumpHUD_Ypos[TF_MAXPLAYERS+1];
static float g_flJumpCooldown[TF_MAXPLAYERS+1];
static float g_flJumpCooldownWait[TF_MAXPLAYERS+1];
static bool g_bClientHoldingChargeButton[TF_MAXPLAYERS+1];
static Handle g_hJumpHUD;

methodmap CBraveJump < IAbility
{
	property int iMaxJumpCharge
	{
		public get()
		{
			return g_iBraveJumpMaxCharge[this.Client];
		}
		public set(int val)
		{
			g_iBraveJumpMaxCharge[this.Client] = val;
		}
	}
	
	property int iJumpCharge
	{
		public get()
		{
			return g_iBraveJumpCharge[this.Client];
		}
		public set(int val)
		{
			g_iBraveJumpCharge[this.Client] = val;
			if (g_iBraveJumpCharge[this.Client] > this.iMaxJumpCharge) g_iBraveJumpCharge[this.Client] = this.iMaxJumpCharge;
			if (g_iBraveJumpCharge[this.Client] < 0) g_iBraveJumpCharge[this.Client] = 0;
		}
	}
	
	property int iJumpChargeBuild
	{
		public get()
		{
			return g_iBraveJumpChargeBuild[this.Client];
		}
		public set(int val)
		{
			g_iBraveJumpChargeBuild[this.Client] = val;
		}
	}
	
	property float HUD_X
	{
		public get()
		{
			return g_flBraveJumpHUD_Xpos[this.Client];
		}
		public set(float val)
		{
			g_flBraveJumpHUD_Xpos[this.Client] = val;
		}
	}
	
	property float HUD_Y
	{
		public get()
		{
			return g_flBraveJumpHUD_Ypos[this.Client];
		}
		public set(float val)
		{
			g_flBraveJumpHUD_Ypos[this.Client] = val;
		}
	}
	
	property float flCooldown
	{
		public get()
		{
			return g_flJumpCooldown[this.Client];
		}
		public set(float val)
		{
			g_flJumpCooldown[this.Client] = val;
		}
	}
	
	property float flMaxHeigth
	{
		public get()
		{
			return g_flBraveJumpMaxHeigth[this.Client];
		}
		public set(float val)
		{
			g_flBraveJumpMaxHeigth[this.Client] = val;
		}
	}
	
	public CBraveJump(IAbility ability)
	{
		g_iBraveJumpCharge[ability.Client] = 0;
		g_flJumpCooldownWait[ability.Client] = 0.0;
		
		if (g_hJumpHUD == null)
			g_hJumpHUD = CreateHudSynchronizer();
		
		//Default values, these can be changed if needed
		CBraveJump jumpAbility = view_as<CBraveJump>(ability);
		jumpAbility.iMaxJumpCharge = 200;
		jumpAbility.iJumpChargeBuild = 4;
		jumpAbility.flMaxHeigth = 1200.0;
		jumpAbility.HUD_X = -1.0;
		jumpAbility.HUD_Y = 0.88;
		jumpAbility.flCooldown = 5.0;
	}
	
	public void Think()
	{
		SetHudTextParams(this.HUD_X, this.HUD_Y, 0.15, 255, 255, 255, 255);
		if (this.iJumpCharge > 0)
			ShowSyncHudText(this.Client, g_hJumpHUD, "Jump charge: %0.2f%%. Look up and stand up to use super-jump.", (float(this.iJumpCharge)/float(this.iMaxJumpCharge))*100.0);
		else
			ShowSyncHudText(this.Client, g_hJumpHUD, "Hold left click or crouch to use your super-jump!");
		
		if (g_flJumpCooldownWait[this.Client] != 0.0 && g_flJumpCooldownWait[this.Client] > GetGameTime())
		{
			float flRemainingTime = g_flJumpCooldownWait[this.Client]-GetGameTime();
			int iSec = RoundToNearest(flRemainingTime);
			ShowSyncHudText(this.Client, g_hJumpHUD, "Super-jump cooldown %i second%s remaining!", iSec, (iSec > 1) ? "s" : "");
			return;
		}
		
		g_flJumpCooldownWait[this.Client] = 0.0;
		
		if (g_bClientHoldingChargeButton[this.Client])
			this.iJumpCharge += this.iJumpChargeBuild;
		else
			this.iJumpCharge -= this.iJumpChargeBuild*2;
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
			if (TF2_IsPlayerInCondition(this.Client, TFCond_Dazed))//Can't jump if stunned
				return;
			
			g_bClientHoldingChargeButton[this.Client] = false;
			if (g_flJumpCooldownWait[this.Client] != 0.0 && g_flJumpCooldownWait[this.Client] > GetGameTime()) return;
			
			float vecAng[3];
			GetClientEyeAngles(this.Client, vecAng);
			if ((vecAng[0] < -10.0) && (this.iJumpCharge > 1))
			{
				float vecVel[3];
				GetEntPropVector(this.Client, Prop_Data, "m_vecVelocity", vecVel);
				
				vecVel[2] = this.flMaxHeigth*((float(this.iJumpCharge)/float(this.iMaxJumpCharge)));
				vecVel[0] *= (1.0+Sine((float(this.iJumpCharge)/float(this.iMaxJumpCharge))*25.0 * FLOAT_PI / 50.0));
				vecVel[1] *= (1.0+Sine((float(this.iJumpCharge)/float(this.iMaxJumpCharge))*25.0 * FLOAT_PI / 50.0));
				SetEntProp(this.Client, Prop_Send, "m_bJumping", true);
				
				TeleportEntity(this.Client, NULL_VECTOR, NULL_VECTOR, vecVel);
				
				float flCooldownTime = (this.flCooldown*(float(this.iJumpCharge)/float(this.iMaxJumpCharge)));
				if (flCooldownTime < 2.5) flCooldownTime = 2.5;
				g_flJumpCooldownWait[this.Client] = GetGameTime()+flCooldownTime;
				
				this.iJumpCharge = 0;
				
				char sSound[PLATFORM_MAX_PATH];
				g_clientBoss[this.Client].GetAbilitySound(sSound, sizeof(sSound), "CBraveJump");
				if (strcmp(sSound, "") != 0)
					EmitSoundToAll(sSound, this.Client, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
			}
		}
	}
}
static float g_flScareRadius[TF_MAXPLAYERS+1];
static float g_flScareDuration[TF_MAXPLAYERS+1];

methodmap CScareRage < IAbility
{
	property float flRadius
	{
		public get()
		{
			return g_flScareRadius[this.Client];
		}
		public set(float val)
		{
			g_flScareRadius[this.Client] = val;
		}
	}
	
	property float flDuration
	{
		public get()
		{
			return g_flScareDuration[this.Client];
		}
		public set(float val)
		{
			g_flScareDuration[this.Client] = val;
		}
	}
	
	public CScareRage(IAbility ability)
	{
		//Default values, these can be changed if needed
		CScareRage scareAbility = view_as<CScareRage>(ability);
		scareAbility.flRadius = 800.0;
		scareAbility.flDuration = 5.0;
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iClient = this.Client;
		int bossTeam = GetClientTeam(iClient);
		float vecPos[3], vecTargetPos[3];
		GetClientAbsOrigin(iClient, vecPos);
		float flDuration = (bSuperRage) ? this.flDuration*2.0 : this.flDuration;
		
		for (int iVictim = 1; iVictim <= MaxClients; iVictim++)
		{
			if (IsClientInGame(iVictim) && IsPlayerAlive(iVictim) && GetClientTeam(iVictim) != bossTeam && !TF2_IsUbercharged(iVictim))
			{
				GetClientAbsOrigin(iVictim, vecTargetPos);
				if (GetVectorDistance(vecTargetPos, vecPos) <= this.flRadius)
					TF2_StunPlayer(iVictim, flDuration, 0.0, 192, 0);
			}
		}
		
		int iEntity = MaxClients+1;
		while ((iEntity = FindEntityByClassname(iEntity, "obj_sentrygun")) > MaxClients)
		{
			if (GetEntProp(iEntity, Prop_Send, "m_iTeamNum") != bossTeam)
			{
				GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vecTargetPos);
				if (GetVectorDistance(vecTargetPos, vecPos) <= this.flRadius)
				{
					SetEntProp(iEntity, Prop_Send, "m_bDisabled", true);
					CreateTimer(flDuration, Timer_ScareEnableSentry, EntIndexToEntRef(iEntity));
				}
			}
		}
	}
}

public Action Timer_ScareEnableSentry(Handle timer, int iRef)
{
	int iEntity = EntRefToEntIndex(iRef);
	if (iEntity > MaxClients)
		SetEntProp(iEntity, Prop_Send, "m_bDisabled", false);
}
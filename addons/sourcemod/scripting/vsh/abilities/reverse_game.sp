static float 	 g_flReverseDuration[TF_MAXPLAYERS+1];
static float	 g_flReverseRadius[TF_MAXPLAYERS+1];

methodmap CReverseGame < IAbility
{
	property float flReverseDuration
	{
		public set(float flVal)
		{
			g_flReverseDuration[this.Client] = flVal;
		}
		public get()
		{
			return g_flReverseDuration[this.Client];
		}
	}
	
	property float flRadius
	{
		public set(float flVal)
		{
			g_flReverseRadius[this.Client] = flVal;
		}
		public get()
		{
			return g_flReverseRadius[this.Client];
		}
	}
	
	public CReverseGame(IAbility ability)
	{
		CReverseGame reverse = view_as<CReverseGame>(ability);
		reverse.flReverseDuration = 7.0;
		reverse.flRadius = 800.0;
	}
	
	public void Think()
	{
		float lastRageTime = this.flLastRageTime;
		float duration = this.flReverseDuration;
		if (this.bSuperRage)
			duration *= 2.0;
		
		float flGameTime = GetGameTime();
		if (lastRageTime != 0.0 && ((flGameTime-lastRageTime) <= duration))
		{
			int iTeam = GetClientTeam(this.Client);
			
			float vecBossPos[3];
			GetEntPropVector(this.Client, Prop_Send, "m_vecOrigin", vecBossPos);
			
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != iTeam)
				{
					float vecTargetPos[3];
					GetEntPropVector(i, Prop_Send, "m_vecOrigin", vecTargetPos);
					if (GetVectorDistance(vecTargetPos, vecBossPos) < this.flRadius)
						g_flPlayerReverseControl[i] = flGameTime+0.1;
				}
			}
		}
	}
	public void OnRage(bool bSuperRage)
	{
		/*int iTeam = GetClientTeam(this.Client);
		int iEnemyTeam;
		if (iTeam == TFTeam_Red)
			iEnemyTeam = TFTeam_Blue;
		else
			iEnemyTeam = TFTeam_Red;
		
		int iSentry = MaxClients+1;
		while((iSentry = FindEntityByClassname(iSentry, "obj_sentrygun")) > MaxClients)
		{
			if (GetEntProp(iSentry, Prop_Send, "m_iTeamNum") == iEnemyTeam && !GetEntProp(iSentry, Prop_Send, "m_bCarried"))
			{
				SetEntProp(iSentry, Prop_Send, "m_iTeamNum", iTeam);
				
				int iOldBuilder = GetEntPropEnt(iSentry, Prop_Send, "m_hBuilder");
				if (iOldBuilder > MaxClients)
				{
					float vecPos[3];
					GetEntPropVector(iSentry, Prop_Send, "m_vecOrigin", vecPos);
					
					Event event = CreateEvent("show_annotation");
					event.SetFloat("worldPosX", vecPos[0]);
					event.SetFloat("worldPosY", vecPos[1]);
					event.SetFloat("worldPosZ", vecPos[2]+10.0);
					event.SetString("text", "Destroy your sentry!");
					event.SetFloat("lifetime", 5.0);
					event.FireToClient(iOldBuilder);
					event.SetInt("visibilityBitfield", (1 << iOldBuilder));
					delete event;
				}
				
				SetEntPropEnt(iSentry, Prop_Send, "m_hBuilder", this.Client);
				SetEntProp(iSentry, Prop_Send, "m_nSkin", iTeam-2);
			}
		}*/
	}
}
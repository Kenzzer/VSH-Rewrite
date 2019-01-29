static float 	 g_flReverseDuration[TF_MAXPLAYERS+1];

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
	
	public CReverseGame(IAbility ability)
	{
		CReverseGame reverse = view_as<CReverseGame>(ability);
		reverse.flReverseDuration = 7.0;
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iTeam = GetClientTeam(this.Client);
		int iEnemyTeam;
		if (iTeam == TFTeam_Red)
			iEnemyTeam = TFTeam_Blue;
		else
			iEnemyTeam = TFTeam_Red;
		
		float duration = this.flReverseDuration;
		if (bSuperRage)
			duration *= 2.0;
		g_flTeamInvertedMoveControlsTime[iEnemyTeam] = GetGameTime()+duration;
		
		int iSentry = MaxClients+1;
		while((iSentry = FindEntityByClassname(iSentry, "obj_sentrygun")) > MaxClients)
		{
			if (GetEntProp(iSentry, Prop_Send, "m_iTeamNum") == iEnemyTeam)
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
					delete event;
					//Probably no longer required
					//event.SetInt("visibilityBitfield", (1 << iOldBuilder));
				}
				
				SetEntPropEnt(iSentry, Prop_Send, "m_hBuilder", this.Client);
				SetEntProp(iSentry, Prop_Send, "m_nSkin", iTeam-2);
			}
		}
	}
}
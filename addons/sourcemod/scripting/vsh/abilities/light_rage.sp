
static float g_flLightRageDuration[TF_MAXPLAYERS+1];
static float g_flLightRageRadius[TF_MAXPLAYERS+1];
static int g_iRageLightColor[TF_MAXPLAYERS+1][4];
static int g_iRageLightBrigthness[TF_MAXPLAYERS+1];

methodmap CLightRage < IAbility
{
	property float flLigthRageDuration
	{
		public set(float flVal)
		{
			g_flLightRageDuration[this.Client] = flVal;
		}
		public get()
		{
			return g_flLightRageDuration[this.Client];
		}
	}
	
	property float flLightRageRadius
	{
		public set(float flVal)
		{
			g_flLightRageRadius[this.Client] = flVal;
		}
		public get()
		{
			return g_flLightRageRadius[this.Client];
		}
	}
	
	property int iRageLightBrigthness
	{
		public set(int iVal)
		{
			g_iRageLightBrigthness[this.Client] = iVal;
		}
		public get()
		{
			return g_iRageLightBrigthness[this.Client];
		}
	}
	
	public void SetColor(int iColor[4])
	{
		g_iRageLightColor[this.Client] = iColor;
	}
	
	public CLightRage(IAbility ability)
	{
		CLightRage lightRage = view_as<CLightRage>(ability);
		int lightColor[4];
		for (int i = 0; i < 4; i++) lightColor[i] = 255;
		lightRage.SetColor(lightColor);
		lightRage.flLigthRageDuration = 10.0;
		lightRage.flLightRageRadius = 450.0;
		lightRage.iRageLightBrigthness = 10;
	}
	
	public void OnRage(bool bSuperRage)
	{
		int ent = CreateEntityByName("light_dynamic");
		if (ent != -1)
		{
			int iColor[4];
			iColor = g_iRageLightColor[this.Client];
			
			float vecEyepos[3];
			GetClientEyePosition(this.Client, vecEyepos);
		
			TeleportEntity(ent, vecEyepos, view_as<float>({ 90.0, 0.0, 0.0 }), NULL_VECTOR);
			char sLigthColor[60];
			Format(sLigthColor, sizeof(sLigthColor), "%i %i %i", iColor[0], iColor[1], iColor[2]);
			DispatchKeyValue(ent, "rendercolor", sLigthColor);
			
			
			SetVariantFloat(this.flLightRageRadius);
			AcceptEntityInput(ent, "spotlight_radius");
			SetVariantFloat(this.flLightRageRadius);
			AcceptEntityInput(ent, "distance");
			SetVariantInt(this.iRageLightBrigthness);
			AcceptEntityInput(ent, "brightness");
			SetVariantInt(1);
			AcceptEntityInput(ent, "cone");
		
			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", this.Client);
			AcceptEntityInput(ent, "TurnOn");
			SetEntityRenderFx(ent, RENDERFX_SOLID_SLOW);
			SetEntityRenderColor(ent, iColor[0], iColor[1], iColor[2], iColor[3]);
			
			int iFlags = GetEdictFlags(ent);
			if (!(iFlags & FL_EDICT_ALWAYS))
			{
				iFlags |= FL_EDICT_ALWAYS;
				SetEdictFlags(ent, iFlags);
			}
			
			float flDuration = this.flLigthRageDuration;
			if (bSuperRage)
				flDuration *= 2.0;
			CreateTimer(flDuration, Timer_DestroyLight, EntIndexToEntRef(ent));
		}
	}
}

public Action Timer_DestroyLight(Handle hTimer, int iRef)
{
	int iLight = EntRefToEntIndex(iRef);
	if (iLight > MaxClients)
	{
		AcceptEntityInput(iLight, "TurnOff");
		RequestFrame(Frame_KillLigth, iRef);
	}
}

void Frame_KillLigth(int iRef)
{
	int iLight = EntRefToEntIndex(iRef);
	if (iLight > MaxClients)
		AcceptEntityInput(iLight, "Kill");
}
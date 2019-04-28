#define EGG_MODEL						"models/player/saxton_hale/w_easteregg.mdl"
static float g_flLastEggSpawnTime[TF_MAXPLAYERS+1];
static float g_flLastRageEggSpawnTime[TF_MAXPLAYERS+1];
static float g_flSpawnEggInterval[TF_MAXPLAYERS+1];
static float g_flDamage[TF_MAXPLAYERS+1];
static float g_flFuseTime[TF_MAXPLAYERS+1];
static float g_flRageDamage[TF_MAXPLAYERS+1];
static float g_flRageFuseTime[TF_MAXPLAYERS+1];
static float g_flRageSpawnRate[TF_MAXPLAYERS+1];
static float g_flDuration[TF_MAXPLAYERS+1];
static int g_iRageEggs[TF_MAXPLAYERS+1];

methodmap CEasterEgg < IAbility
{
	property int iRageEggs
	{
		public get()
		{
			return g_iRageEggs[this.Client];
		}
		public set(int val)
		{
			g_iRageEggs[this.Client] = val;
		}
	}
	
	property float flDuration
	{
		public get()
		{
			return g_flDuration[this.Client];
		}
		public set(float val)
		{
			g_flDuration[this.Client] = val;
		}
	}
	
	property float flRageSpawnRate
	{
		public get()
		{
			return g_flRageSpawnRate[this.Client];
		}
		public set(float val)
		{
			g_flRageSpawnRate[this.Client] = val;
		}
	}
	
	property float flRageDamage
	{
		public get()
		{
			return g_flRageDamage[this.Client];
		}
		public set(float val)
		{
			g_flRageDamage[this.Client] = val;
		}
	}
	
	property float flRageFuseTime
	{
		public get()
		{
			return g_flRageFuseTime[this.Client];
		}
		public set(float val)
		{
			g_flRageFuseTime[this.Client] = val;
		}
	}
	
	property float flDamage
	{
		public get()
		{
			return g_flDamage[this.Client];
		}
		public set(float val)
		{
			g_flDamage[this.Client] = val;
		}
	}
	
	property float flFuseTime
	{
		public get()
		{
			return g_flFuseTime[this.Client];
		}
		public set(float val)
		{
			g_flFuseTime[this.Client] = val;
		}
	}
	
	property float flSpawnInterval
	{
		public get()
		{
			return g_flSpawnEggInterval[this.Client];
		}
		public set(float val)
		{
			g_flSpawnEggInterval[this.Client] = val;
		}
	}
	
	public CEasterEgg(IAbility ability)
	{
		g_flLastEggSpawnTime[ability.Client] = 0.0;
		g_flLastRageEggSpawnTime[ability.Client] = 0.0;
		
		CEasterEgg egg = view_as<CEasterEgg>(ability);
		egg.flSpawnInterval = 1.5;
		egg.flFuseTime = 2.0;
		egg.flDamage = 70.0;
		egg.flRageFuseTime = 1.5;
		egg.flRageDamage = 70.0;
		egg.iRageEggs = 10;
		egg.flDuration = 10.0;
		egg.flRageSpawnRate = 0.7;
	}
	
	public int CreateEgg(float vecPos[3], float vecVel[3], float flDamage, float flFuseTime, int iSkin)
	{
		int iEggBomb = CreateEntityByName("tf_projectile_pipe");
		DispatchKeyValueVector(iEggBomb, "origin", vecPos);
		SetEntityModel(iEggBomb, EGG_MODEL);
		SetEntProp(iEggBomb, Prop_Send, "m_iTeamNum", GetClientTeam(this.Client));
		SetEntPropEnt(iEggBomb, Prop_Send, "m_hThrower", this.Client);
		SetEntPropEnt(iEggBomb, Prop_Send, "m_hOwnerEntity", this.Client);
		DispatchSpawn(iEggBomb);
		SDK_AddVelocity(iEggBomb, vecVel, NULL_VECTOR);
		SetEntityModel(iEggBomb, EGG_MODEL);
		SetEntPropFloat(iEggBomb, Prop_Data, "m_flDamage", flDamage);
		SetEntPropFloat(iEggBomb, Prop_Send, "m_flModelScale", 1.0);
		SetEntDataFloat(iEggBomb, g_iOffset_m_flFuseTime, flFuseTime);
		SetEntProp(iEggBomb, Prop_Send, "m_nSkin", iSkin);
	}
	
	public void Think()
	{
		if (IsPlayerAlive(this.Client))
		{
			float flGameTime = GetGameTime();
			
			float vecPos[3];
			GetClientAbsOrigin(this.Client, vecPos);
			vecPos[2] += 50.0;
			
			float lastRageTime = this.flLastRageTime;
			float spawnDuration = this.flDuration;
			if (this.bSuperRage)
				spawnDuration *= 2.0;
			if (lastRageTime != 0.0 && ((flGameTime-lastRageTime) <= spawnDuration))
			{
				if (g_flLastRageEggSpawnTime[this.Client] == 0.0 || g_flLastRageEggSpawnTime[this.Client] < flGameTime-this.flRageSpawnRate)
				{
					float flAng = 0.0, flPiDivider = float(this.iRageEggs), vecEggPos[3], vecEggVel[3];
					flPiDivider = flPiDivider/2.0;
					for (int i = 1; i <= this.iRageEggs; i++)
					{
						vecEggPos = vecPos;
						
						vecEggPos[0] += 20.0*Cosine(flAng);
						vecEggPos[1] += 20.0*Sine(flAng);
						
						SubtractVectors(vecEggPos, vecPos, vecEggVel);
						NormalizeVector(vecEggVel, vecEggVel);
						ScaleVector(vecEggVel, 200.0);
						vecEggVel[2] = 700.0;
						
						this.CreateEgg(vecEggPos, vecEggVel, this.flRageDamage, flGameTime+this.flRageFuseTime, 1);
						flAng += PI/flPiDivider;
					}
					
					g_flLastRageEggSpawnTime[this.Client] = flGameTime;
				}
			}
			
			
			if (g_flLastEggSpawnTime[this.Client] == 0.0 || g_flLastEggSpawnTime[this.Client] < flGameTime-this.flSpawnInterval)
			{
				this.CreateEgg(vecPos, NULL_VECTOR, this.flDamage, flGameTime+this.flFuseTime, 0);	
				g_flLastEggSpawnTime[this.Client] = flGameTime;
			}
		}
	}
}
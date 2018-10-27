#define BODY_CLASSNAME	"prop_ragdoll"
#define BODY_EAT		"vo/sandwicheat09.mp3"

#define BOMB_NUKE_PARTICLE	"dooms_nuke_collumn"
#define BOMB_PARTICLE		"ExplosionCore_MidAir"
#define BOMB_NUKE_SOUND 	"misc/doomsday_missile_explosion.wav"

static float g_flBombSpawnInterval[TF_MAXPLAYERS+1];
static float g_flBombSpawnDuration[TF_MAXPLAYERS+1];
static float g_flBombSpawnRadius[TF_MAXPLAYERS+1];
static float g_flBombRadius[TF_MAXPLAYERS+1];
static float g_flBombDamage[TF_MAXPLAYERS+1];
static float g_flBombEndTime[TF_MAXPLAYERS+1];
static float g_flLastExplosionTime[TF_MAXPLAYERS+1];

methodmap CBomb < IAbility
{
	property float flBombSpawnInterval
	{
		public set(float flVal)
		{
			g_flBombSpawnInterval[this.Client] = flVal;
		}
		public get()
		{
			return g_flBombSpawnInterval[this.Client];
		}
	}
	
	property float flBombSpawnDuration
	{
		public set (float flVal)
		{
			g_flBombSpawnDuration[this.Client] = flVal;
		}
		public get()
		{
			return g_flBombSpawnDuration[this.Client];
		}
	}
	
	property float flBombSpawnRadius
	{
		public set (float flVal)
		{
			g_flBombSpawnRadius[this.Client] = flVal;
		}
		public get()
		{
			return g_flBombSpawnRadius[this.Client];
		}
	}
	
	property float flBombRadius
	{
		public set (float flVal)
		{
			g_flBombRadius[this.Client] = flVal;
		}
		public get()
		{
			return g_flBombRadius[this.Client];
		}
	}
	
	property float flBombDamage
	{
		public set (float flVal)
		{
			g_flBombDamage[this.Client] = flVal;
		}
		public get()
		{
			return g_flBombDamage[this.Client];
		}
	}
	
	public CBomb(IAbility ability)
	{
		g_flBombSpawnInterval[ability.Client] = 0.1;
		g_flBombSpawnDuration[ability.Client] = 5.0;
		g_flBombSpawnRadius[ability.Client] = 500.0;
		g_flBombRadius[ability.Client] = 200.0;
		g_flBombDamage[ability.Client] = 150.0;
		g_flBombEndTime[ability.Client] = 0.0;
		g_flLastExplosionTime[ability.Client] = 0.0;
	}

	public void OnRage(bool bSuperRage)
	{
		float flDuration = this.flBombSpawnDuration;
		if (bSuperRage)
			flDuration *= 2.0;
		g_flBombEndTime[this.Client] = GetGameTime()+flDuration;
		FakeClientCommand(this.Client, "taunt");
		SetEntityMoveType(this.Client, MOVETYPE_NONE);
	}
	
	public void Think()
	{
		if (g_flBombEndTime[this.Client] == 0.0) return;
		
		float flGameTime = GetGameTime();
		if (flGameTime <= g_flBombEndTime[this.Client])
		{
			if (g_flLastExplosionTime[this.Client] != 0.0 && g_flLastExplosionTime[this.Client]+this.flBombSpawnInterval > flGameTime) return;
			
			g_flLastExplosionTime[this.Client] = flGameTime;
			
			float vecExplosionPos[3], vecExplosionOrigin[3];
			GetClientAbsOrigin(this.Client, vecExplosionOrigin);
			
			for (int i = 0; i < 2; i++)
			{
				vecExplosionPos = vecExplosionOrigin;
				vecExplosionPos[0] += GetRandomFloat(-this.flBombSpawnRadius, this.flBombSpawnRadius);
				vecExplosionPos[1] += GetRandomFloat(-this.flBombSpawnRadius, this.flBombSpawnRadius);
				vecExplosionPos[2] += GetRandomFloat(-this.flBombSpawnRadius, this.flBombSpawnRadius);
				
				char sSound[255];
				Format(sSound, sizeof(sSound), "weapons/airstrike_small_explosion_0%i.wav", GetRandomInt(1,3));
				TF2_Explode(this.Client, vecExplosionPos, this.flBombDamage, this.flBombRadius, BOMB_PARTICLE, sSound);
			}
		}
		else
		{
			if (this.bSuperRage)
			{
				float vecExplosionOrigin[3];
				GetClientAbsOrigin(this.Client, vecExplosionOrigin);
				TF2_Explode(this.Client, vecExplosionOrigin, 9999999.0, this.flBombRadius, BOMB_NUKE_PARTICLE, BOMB_NUKE_SOUND);
				EmitSoundToAll(BOMB_NUKE_SOUND);
			}
			g_flBombEndTime[this.Client] = 0.0;
			g_flLastExplosionTime[this.Client] = 0.0;
			TF2_RemoveCondition(this.Client, TFCond_Taunting);
			SetEntityMoveType(this.Client, MOVETYPE_WALK);
		}
	}
	
	public static void Precache()
	{
		PrecacheSound(BOMB_NUKE_SOUND);
		PrecacheParticleSystem(BOMB_NUKE_PARTICLE);
		PrecacheParticleSystem(BOMB_PARTICLE);
	}
}
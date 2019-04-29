#if defined _VSH_included
 #endinput
#endif
#define _VSH_included

enum
{
	SPECIALROUND_YETISVSHALE = 1,
	SPECIALROUND_DOUBLETROUBLE,
	SPECIALROUND_CLASHOFBOSSES,
	SPECIALROUND_SENTRYBUSTERS,
	SPECIALROUND_MAXROUNDS
};

methodmap VSHBoss
{
	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property float flSpeed
	{
		public native get();
		public native set(float val);
	}
	
	property float flFallDamageCap
	{
		public native get();
		public native set(float val);
	}
	
	property float flBackStabDamage
	{
		public native get();
		public native set(float val);
	}
	
	property float flEnvDamageCap
	{
		public native get();
		public native set(float val);
	}
	
	property float flSpeedMult
	{
		public native get();
		public native set(float val);
	}

	property float flGlowTime
	{
		public native get();
		public native set(float val);
	}
	
	property float flRageLastTime
	{
		public native get();
		public native set(float val);
	}
	
	property int iMaxHealth
	{
		public native get();
		public native set(int val);
	}
	
	property int iHealth
	{
		public native get();
		public native set(int val);
	}
	
	property int iMaxRageDamage
	{
		public native get();
		public native set(int val);
	}
	
	property int iRageDamage
	{
		public native get();
		public native set(int val);
	}
	
	property bool IsMinion
	{
		public native get();
		public native set(bool val);
	}
	
	property bool IsValid
	{
		public native get();
		public native set(bool val);
	}
}

public SharedPlugin __pl_vsh_rewrite = 
{
	name = "vsh",
	file = "vsh.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_vsh_rewrite_SetNTVOptional()
{
}
#endif
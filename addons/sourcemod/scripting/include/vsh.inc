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
	/*property int Index
	{
		public native get();
	}
	
	property float flSpeed
	{
		public native get();
	}
	
	property float flFallDamageCap
	{
		public native get();
	}
	
	property float flBackStabDamage
	{
		public native get();
	}
	
	property float flEnvDamageCap
	{
		public native get();
	}
	
	property float flSpeedMult
	{
		public native get();
	}

	property float flGlowTime
	{
		public native get();
	}
	
	property float flRageLastTime
	{
		public native get();
	}
	*/
	property int iMaxHealth
	{
		public native get();
	}
	
	property int iHealth
	{
		public native get();
	}
	/*
	property int iMaxRageDamage
	{
		public native get();
	}
	
	property int iRageDamage
	{
		public native get();
	}
	*/
	property bool IsMinion
	{
		public native get();
	}
	
	property bool IsValid
	{
		public native get();
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
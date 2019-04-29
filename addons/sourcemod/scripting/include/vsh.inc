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
	
	public native void GetType(char[] sBuffer, int iLen);
}

const VSHBoss INVALID_VSH_BOSS = view_as<VSHBoss>(-1);

public SharedPlugin __pl_vsh = 
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
public __pl_vsh_SetNTVOptional()
{
	MarkNativeAsOptional("VSHBoss.flSpeed.set");
	MarkNativeAsOptional("VSHBoss.flSpeed.get");
	MarkNativeAsOptional("VSHBoss.flFallDamageCap.set");
	MarkNativeAsOptional("VSHBoss.flFallDamageCap.get");
	MarkNativeAsOptional("VSHBoss.flBackStabDamage.set");
	MarkNativeAsOptional("VSHBoss.flBackStabDamage.get");
	MarkNativeAsOptional("VSHBoss.flEnvDamageCap.set");
	MarkNativeAsOptional("VSHBoss.flEnvDamageCap.get");
	MarkNativeAsOptional("VSHBoss.flSpeedMult.set");
	MarkNativeAsOptional("VSHBoss.flSpeedMult.get");
	MarkNativeAsOptional("VSHBoss.flGlowTime.set");
	MarkNativeAsOptional("VSHBoss.flGlowTime.get");
	MarkNativeAsOptional("VSHBoss.flRageLastTime.set");
	MarkNativeAsOptional("VSHBoss.flRageLastTime.get");
	MarkNativeAsOptional("VSHBoss.iMaxHealth.set");
	MarkNativeAsOptional("VSHBoss.iMaxHealth.get");
	MarkNativeAsOptional("VSHBoss.iHealth.set");
	MarkNativeAsOptional("VSHBoss.iHealth.get");
	MarkNativeAsOptional("VSHBoss.iMaxRageDamage.set");
	MarkNativeAsOptional("VSHBoss.iMaxRageDamage.get");
	MarkNativeAsOptional("VSHBoss.iRageDamage.set");
	MarkNativeAsOptional("VSHBoss.iRageDamage.get");
	MarkNativeAsOptional("VSHBoss.IsMinion.set");
	MarkNativeAsOptional("VSHBoss.IsMinion.get");
	MarkNativeAsOptional("VSHBoss.IsValid.set");
	MarkNativeAsOptional("VSHBoss.IsValid.get");
	MarkNativeAsOptional("VSHBoss.GetType");
}
#endif
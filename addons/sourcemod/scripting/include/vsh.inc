#if defined _VSH_included
 #endinput
#endif
#define _VSH_included

#define VSH_BOSS_TYPE_LEN	64

enum
{
	SPECIALROUND_YETISVSHALE = 1,
	SPECIALROUND_DOUBLEBOSSES,
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
	
	// Boss base speed
	property float flSpeed
	{
		public native get();
		public native set(float val);
	}
	
	// Maximum fall damage amount
	property float flFallDamageCap
	{
		public native get();
		public native set(float val);
	}
	
	// UNUSED: Minimum amount of damage the boss can receive from backstabs
	property float flBackStabDamage
	{
		public native get();
		public native set(float val);
	}
	
	// Maximum damage amount the boss can be afflicated by environmental (i.e trigger_hurt)
	property float flEnvDamageCap
	{
		public native get();
		public native set(float val);
	}
	
	// UNUSED: Boss Speed multiplier
	property float flSpeedMult
	{
		public native get();
		public native set(float val);
	}

	// Displays an outline on the boss as long the value is greater than GetGameTime()
	property float flGlowTime
	{
		public native get();
		public native set(float val);
	}
	
	// Last game time the boss used their rage, 0.0 if they never used their rage
	property float flRageLastTime
	{
		public native get();
		public native set(float val);
	}
	
	// Boss maximum health amount
	property int iMaxHealth
	{
		public native get();
		public native set(int val);
	}
	
	// Boss current health amount
	property int iHealth
	{
		public native get();
		public native set(int val);
	}
	
	// Maximum amount of damage for the rage meter
	property int iMaxRageDamage
	{
		public native get();
		public native set(int val);
	}
	
	// Current amount of damage stored in the rage meter  
	property int iRageDamage
	{
		public native get();
		public native set(int val);
	}
	
	// True if the boss is a minion
	property bool IsMinion
	{
		public native get();
		public native set(bool val);
	}
	
	// True if the boss is valid
	property bool IsValid
	{
		public native get();
		public native set(bool val);
	}
	
	/* Returns the methodmap name of this client's boss
	 *
	 * @param sType		Methodmap name of the boss you wish to create
	 * 
	 * @noreturn
	*/
	public native void GetType(char[] sBuffer, int iLen);
	
	/* Creates a new boss of the given type
	 *
	 * @param sType		Methodmap name of the boss you wish to create
	 * 
	 * @noreturn
	*/
	public native VSHBoss(int iClient, char sType[VSH_BOSS_TYPE_LEN]);
	
	/* Registers a new boss
	 *
	 * @param sType		Methodmap name of the boss you wish to register
	 * 
	 * @error Boss type already registered.
	 * @noreturn
	*/
	public static native void Register(char sType[VSH_BOSS_TYPE_LEN]);
	
	/* Untegisters a registered boss
	 *
	 * @param sType		Methodmap name of the boss you wish to unregister
	 * 
	 * @error Boss type not registered by the calling plugin
	 * @noreturn
	*/
	public static native void Unregister(char sType[VSH_BOSS_TYPE_LEN]);
}

const VSHBoss INVALID_VSH_BOSS = view_as<VSHBoss>(-1);

methodmap VSHAbility
{
	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property int Client
	{
		public native get();
	}
	
	property float flLastRageTime
	{
		public native get();
	}
	
	property bool bSuperRage
	{
		public native get();
	}
	
	public bool FindFunction(char[] sName) {}
	
	public char GetType(char[] sType, int iLength) {}
	
	public void Think() {}
	
	public void OnPlayerKilled(int iVictim, Event eventInfo) {}
	
	public void OnRage(bool bSuperRage) {}
	
	public Action OnButton(int button) {}
	
	public void OnButtonPress(int button) {}
	
	public void OnButtonHold(int button) {}
	
	public void OnButtonRelease(int button) {}
	
	public void Destroy() {}
}

const VSHAbility INVALID_VSH_ABILITY = view_as<VSHAbility>(-1);

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
	MarkNativeAsOptional("VSHBoss.VSHBoss");
}
#endif
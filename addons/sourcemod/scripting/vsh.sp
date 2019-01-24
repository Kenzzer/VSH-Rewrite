#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <dhooks>
#include <vsh>
//#include <benextension>
//#include <sendproxy>

#define PLUGIN_VERSION "0.0.4d"

#define MAX_BUTTONS 26

#define	TFTeam_Unassigned 		0
#define	TFTeam_Spectator 		1
#define TFTeam_Red 				2
#define TFTeam_Blue 			3

#define TF_MAXPLAYERS			32

#define VSH_SPECIALROUND_COIN	502

#define BOSS_TEAM		3
#define ATTACK_TEAM		2

#define ATTRIB_FASTER_FIRE_RATE		6
#define ATTRIB_UBER_RATE_BONUS		10
#define ATTRIB_CRITBOOST_ON_KILL	31
#define ATTRIB_REDUCED_HEALING		69
#define ATTRIB_HEALTH_FROM_PACKS	109
#define ATTRIB_SENTRYKILLED_REVENGE 136
#define ATTRIB_HEAL_ON_KILL			180
#define ATTRIB_HEALTH_PACK_ON_KILL  203
#define ATTRIB_MARK_FOR_DEATH		218
#define ATTRIB_BIDERECTIONAL		276
#define ATTRIB_SAPPER_KILLS_CRIT	296
#define ATTRIB_SENTRYATTACKSPEED	343
#define ATTRIB_CRIT_LAUGH			358
#define ATTRIB_EXTINGUISH_REVENGE	367
#define ATTRIB_DAMAGE_VULNERABILITY 412
#define ATTRIB_AUTO_FIRES_FULL_CLIP 413

#define ITEM_YOUR_ETERNAL_REWARD	225
#define ITEM_KUNAI			356
#define ITEM_BAZARR			402
#define ITEM_BIG_EARNER		461
#define ITEM_DIAMONDBACK	525
#define ITEM_WANGA_PRICK	574
#define ITEM_THIRDDEGREE	593
#define ITEM_HITMAN			752
#define ITEM_MARKET_GARDENER 416

#define BOSS_BACKSTAB_SOUND "player/spy_shield_break.wav"
#define CP_UNLOCK_SOUND		"vsh_rewrite/cp_unlocked.mp3"

#define FL_EDICT_CHANGED	(1<<0)	// Game DLL sets this when the entity state changes
									// Mutually exclusive with FL_EDICT_PARTIAL_CHANGE.

#define FL_EDICT_FREE		(1<<1)	// this edict if free for reuse
#define FL_EDICT_FULL		(1<<2)	// this is a full server entity

#define FL_EDICT_FULLCHECK	(0<<0)  // call ShouldTransmit() each time, this is a fake flag
#define FL_EDICT_ALWAYS		(1<<3)	// always transmit this entity
#define FL_EDICT_DONTSEND	(1<<4)	// don't transmit this entity
#define FL_EDICT_PVSCHECK	(1<<5)	// always transmit entity, but cull against PVS

#define EF_BONEMERGE			0x001 	// Performs bone merge on client side
#define	EF_BRIGHTLIGHT 			0x002	// DLIGHT centered at entity origin
#define	EF_DIMLIGHT 			0x004	// player flashlight
#define	EF_NOINTERP				0x008	// don't interpolate the next frame
#define	EF_NOSHADOW				0x010	// Don't cast no shadow
#define	EF_NODRAW				0x020	// don't draw entity
#define	EF_NORECEIVESHADOW		0x040	// Don't receive no shadow
#define	EF_BONEMERGE_FASTCULL	0x080	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
#define	EF_ITEM_BLINK			0x100	// blink an item so that the user notices it.
#define	EF_PARENT_ANIMATES		0x200	// always assume that the parent entity is animating
#define	EF_MAX_BITS = 10

#define VSH_TAG				"\x07E19300[\x07E17100VSH REWRITE\x07E19300]\x01"
#define VSH_TEXT_COLOR		"\x07E19F00"

#define VSH_ALLOWED_TO_SPAWN_BOSS_TEAM	(1 << 0)
#define VSH_ZOMBIE					(1 << 1)

#define BEAM_MATERIAL		"materials/sprites/laserbeam.vmt"
int BEAM_MODEL_INDEX		= -1;

enum
{
	WeaponSlot_Primary = 0,
	WeaponSlot_Secondary,
	WeaponSlot_Melee,
	WeaponSlot_PDABuild,
	WeaponSlot_PDADisguise = 3,
	WeaponSlot_PDADestroy,
	WeaponSlot_InvisWatch = 4,
	WeaponSlot_BuilderEngie,
	WeaponSlot_Unknown1,
	WeaponSlot_Head,
	WeaponSlot_Misc1,
	WeaponSlot_Action,
	WeaponSlot_Misc2
};

enum
{
	Shake_Start=0,
	Shake_Stop,
	Shake_Amplitude,
	Shake_Frequency,
};

enum
{
	TFQual_None = -1,
	TFQual_Normal = 0,
	TFQual_NoInspect = 0,
	TFQual_Rarity1,
	TFQual_Genuine = 1,
	TFQual_Rarity2,
	TFQual_Level = 2,
	TFQual_Vintage,
	TFQual_Rarity3,
	TFQual_Rarity4,
	TFQual_Unusual = 5,
	TFQual_Unique,
	TFQual_Community,
	TFQual_Developer,
	TFQual_Selfmade,
	TFQual_Customized,
	TFQual_Strange,
	TFQual_Completed,
	TFQual_Haunted,
	TFQual_Collectors
};

enum
{
	LifeState_Alive = 0,
	LifeState_Dead = 2
};

enum
{
	BUFF_BANNER = 1,
	BATTALION_BACKUP,
	CONCHEROR,
};

enum
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,			// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER, // Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,	// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,  // For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,			// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,		// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,			// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,	// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,		// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,	// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,	// Doors that the player shouldn't collide with
	COLLISION_GROUP_DISSOLVING,		// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,		// Nonsolid on client and server, pushaway in player code

	COLLISION_GROUP_NPC_ACTOR,		// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,	// USed for NPCs in scripts that should not collide with each other

	LAST_SHARED_COLLISION_GROUP
};

const float PI = 3.1415926535897932384626433832795;
static float g_flLastArrowDrawTime;

//ConVars
ConVar tf_arena_use_queue;
ConVar mp_teams_unbalance_limit;
ConVar tf_arena_first_blood;
ConVar tf_dropped_weapon_lifetime;
ConVar mp_forcecamera;
ConVar tf_scout_hype_pep_max;
ConVar tf_damage_disablespread;
ConVar tf_feign_death_activate_damage_scale;
ConVar tf_feign_death_damage_scale;
ConVar tf_stealth_damage_reduction;
ConVar tf_feign_death_duration;
ConVar tf_feign_death_speed_duration;
ConVar tf_arena_preround_time;
ConVar tf_forced_holiday;

ConVar g_cvDiamondbackCritReward;
ConVar g_cvSyringueUberReward;
ConVar g_cvCrossBowUberReward;
ConVar g_cvBossTelefragDamage;
ConVar g_cvBossAirblastRageDamage;
ConVar g_cvSniperHeadshotDamageMult;
ConVar g_cvBazaarDecapBonus;
ConVar g_cvSniperGlowTime;
ConVar g_cvHitmanFocusBonus;
ConVar g_cvExplosiveArrow;
ConVar g_cvArrowExplosionDmg;
ConVar g_cvThirdDegreeUberReward;
ConVar g_cvBattalionBackupMaxZombieScout;
ConVar g_cvConcherorBuffUber;
ConVar g_cvBuffBannerRocketsBonus;
ConVar g_cvBuffBannerRocketLauncherFasterFireRate;
ConVar g_cvBuffBannerBonusDuration;
ConVar g_cvBackstabBigEarnerCloak;
ConVar g_cvBackstabBigEarnerSpeedBoostDuration;
ConVar g_cvBackstabKunaiHeal;
ConVar g_cvRevengeCritMult;
ConVar g_cvSteakBuffDamageResis;
ConVar g_cvCritColaEndBuffSlowdown;
ConVar g_cvCritColaMiniCritIsCrit;
ConVar g_cvBossPlayerStompDmg;
ConVar g_cvClimbHealth;
ConVar g_cvMarkForDeathRageDamageDrain;
ConVar g_cvMedigunPatientTeleport;
ConVar g_cvPatientTeleportStunDuration;
ConVar g_cvSummonedPlayerFallDamageCap;

// Normal boss goes here
char g_strBossesType[][] = {
	"CSaxtonHale",
	"CPainisCupcake",
	"CVagineer",
	//"CDemoRobot",
	"CHHH",
	"CAnnouncer",
	"CCBS",
	"CGentleSpy"
};

// Duo and more goes here
char g_strMiscBossesType[][] = {
	"CSeeMan",
	"CSeeldier"
};

char g_sNextBossType[32];


bool g_bEnabled = true;
bool g_bRoundStarted = false;
bool g_bFreezeMovements = false;
bool g_bBlockRagdoll = false;
bool g_bSpecialRound = false;

//Main boss data
Handle g_hTimerPickBoss = null;
Handle g_hTimerBossMusic = null;
char g_sBossMusic[PLATFORM_MAX_PATH];
int g_iUserActiveBoss;

int g_iHealthBarMaxHealth;
int g_iHealthBarHealth;

//Player data
int g_iPlayerLastButtons[TF_MAXPLAYERS+1];
int g_iPlayerTotalBackstab[TF_MAXPLAYERS+1][TF_MAXPLAYERS+1];
int g_iPlayerDamage[TF_MAXPLAYERS+1];
int g_iPlayerAssistDamage[TF_MAXPLAYERS+1];
bool g_bPlayerTriggerSpecialRound[TF_MAXPLAYERS+1];
float g_flTeamInvertedMoveControlsTime[4];
enum PlayerPreferences
{
	bool:PlayerPreference_RevivalSelect,
	bool:PlayerPreference_PickAsBoss,
	bool:PlayerPreference_DisplayBossArrow
};
int g_iPlayerPreferences[TF_MAXPLAYERS+1][PlayerPreferences];
Handle g_hClientSpecialRoundTimer[TF_MAXPLAYERS+1] = {null, ...};

Handle g_hInfoHud = null;

//Game state data
int g_iTotalRoundPlayed;

Handle g_hTimerCPUnlockSound = null;

//SDK functions
Handle g_hHookGetMaxHealth = null;
Handle g_hHookShouldTransmit = null;
Handle g_hSDKGetMaxHealth = null;
Handle g_hSDKSendWeaponAnim = null;
Handle g_hSDKGetMaxClip = null;
Handle g_hSDKRemoveWearable = null;
Handle g_hSDKGetEquippedWearable = null;
Handle g_hSDKEquipWearable = null;

Handle g_hSDKWeaponScattergun = null;
Handle g_hSDKWeaponPistolScout = null;
Handle g_hSDKWeaponBat = null;
Handle g_hSDKWeaponSniperRifle = null;
Handle g_hSDKWeaponSMG = null;
Handle g_hSDKWeaponKukri = null;
Handle g_hSDKWeaponRocketLauncher = null;
Handle g_hSDKWeaponShotgunSoldier = null;
Handle g_hSDKWeaponShovel = null;
Handle g_hSDKWeaponGrenadeLauncher = null;
Handle g_hSDKWeaponStickyLauncher = null;
Handle g_hSDKWeaponBottle = null;
Handle g_hSDKWeaponMinigun = null;
Handle g_hSDKWeaponShotgunHeavy = null;
Handle g_hSDKWeaponFists = null;
Handle g_hSDKWeaponSyringeGun = null;
Handle g_hSDKWeaponMedigun = null;
Handle g_hSDKWeaponBonesaw = null;
Handle g_hSDKWeaponFlamethrower = null;
Handle g_hSDKWeaponShotgunPyro = null;
Handle g_hSDKWeaponFireaxe = null;
Handle g_hSDKWeaponRevolver = null;
Handle g_hSDKWeaponKnife = null;
Handle g_hSDKWeaponInvis = null;
Handle g_hSDKWeaponShotgunPrimary = null;
Handle g_hSDKWeaponPistol = null;
Handle g_hSDKWeaponWrench = null;

//Preferences
Handle g_hPlayerPreferences;

#include "vsh/network.sp"
#include "vsh/config.sp"
Config config;
#include "vsh/base_ability.sp"
#include "vsh/base_boss.sp"
CBaseBoss g_clientBoss[TF_MAXPLAYERS+1];
#include "vsh/client.sp"
#include "vsh/death_rings.sp"

#include "vsh/abilities/brave_jump.sp"
#include "vsh/abilities/scare_rage.sp"
#include "vsh/abilities/body_eat.sp"
#include "vsh/abilities/light_rage.sp"
#include "vsh/abilities/conditions_rage.sp"
#include "vsh/abilities/reverse_game.sp"
#include "vsh/abilities/bomb.sp"
#include "vsh/abilities/resurrect.sp"

#include "vsh/bosses/boss_hale.sp"
#include "vsh/bosses/boss_painiscupcakes.sp"
#include "vsh/bosses/boss_vagineer.sp"
#include "vsh/bosses/boss_sentrybuster.sp"
#include "vsh/bosses/boss_sentrygun.sp"
//#include "vsh/bosses/boss_demorobot.sp"
#include "vsh/bosses/boss_seeman.sp"
#include "vsh/bosses/boss_seeldier.sp"
#include "vsh/bosses/boss_hhh.sp"
#include "vsh/bosses/boss_announcer.sp"
#include "vsh/bosses/boss_cbs.sp"
#include "vsh/bosses/boss_gentlespy.sp"

#include "vsh/queue.sp"
#include "vsh/specialround.sp"
#include "vsh/menu.sp"
#include "vsh/preferences.sp"

#include "vsh/natives.sp"

public void OnPluginStart()
{
	g_hPlayerPreferences = RegClientCookie("vsh_preferences", "VSH Player preferences", CookieAccess_Protected);
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("arena_round_start", Event_RoundArenaStart);
	HookEvent("teamplay_round_win", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("post_inventory_application", Event_PlayerInventoryUpdate);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("deploy_buff_banner", Event_BuffBannerDeployed);
	HookEvent("player_chargedeployed", 	Event_UberDeployed);
	HookEvent("teamplay_broadcast_audio", Event_BroadcastAudio, EventHookMode_Pre);
	
	AddCommandListener(Client_VoiceCommand, "voicemenu");
	AddCommandListener(Client_TauntCommand, "taunt");
	AddCommandListener(Client_JoinTeamCommand, "jointeam");
	AddCommandListener(Client_JoinTeamCommand, "autoteam");
	
	RegConsoleCmd("sm_hale", Command_MainMenu);
	RegConsoleCmd("vsh", Command_MainMenu);
	RegConsoleCmd("sm_hale_next", Command_HaleNext);
	RegConsoleCmd("sm_halenext", Command_HaleNext);
	RegConsoleCmd("vshnext", Command_HaleNext);
	RegConsoleCmd("sm_hale_help", Command_Help);
	RegConsoleCmd("sm_halehelp", Command_Help);
	RegConsoleCmd("vshhelp", Command_Help);
	RegConsoleCmd("sm_halecredits", Command_Credits);
	RegConsoleCmd("vshcredits", Command_Credits);
	RegConsoleCmd("sm_halesettings", Command_Settings);
	RegConsoleCmd("vshsettings", Command_Settings);
	
	//RegConsoleCmd("vsh_get_cp_unlock_time", Command_GetCpUnlockTime);
	//RegConsoleCmd("vsh_set_cp_unlock_time", Command_SetCpUnlockTime);
	RegConsoleCmd("vsh_add_queue_points", Command_AddQueuePoints);
	RegConsoleCmd("vsh_special_round", Command_ForceSpecialRound);
	RegConsoleCmd("vsh_set_next_boss", Command_ForceNextBoss);
	
	RegAdminCmd("vsh_cmd_access", Command_MainMenu, ADMFLAG_ROOT);
	
	//Init our convars
	g_cvDiamondbackCritReward = CreateConVar("vsh_diamondback_backstab_crit_reward", "2", "How many crits shall be awarded upon successful boss backstab.", _, true, 0.0);
	g_cvSyringueUberReward = CreateConVar("vsh_syringue_uber_hit_reward", "0.05", "Uber charge given upon every successful syringue hit on a boss.", _, true, 0.0, true, 1.0);
	g_cvCrossBowUberReward = CreateConVar("vsh_crossbow_uber_hit_reward", "0.10", "Uber charge given upon every successful crossbow hit on a boss.", _, true, 0.0, true, 1.0);
	g_cvBossTelefragDamage = CreateConVar("vsh_telefrag_damage", "9001.0", "Override default telefrag damage dealt on a boss.", _, true, 0.0);
	g_cvBossAirblastRageDamage = CreateConVar("vsh_airblast_rage_damage", "100", "Rage damage given to the boss after being airblasted.", _, true, 0.0);
	g_cvSniperHeadshotDamageMult = CreateConVar("vsh_sniper_headshot_multiplier", "1.5", "Multiply sniper headshot damage by the given amount.", _, true, 0.0);
	g_cvBazaarDecapBonus = CreateConVar("vsh_bazaar_decap_bonus", "1", "Decapitation given upon successful boss headshot.", _, true, 0.0);
	g_cvSniperGlowTime = CreateConVar("vsh_sniper_shot_glow_time", "4.0", "Boss glow time duration for a fully charged sniper shot.", _, true, 0.0);
	g_cvHitmanFocusBonus = CreateConVar("vsh_hitman_focus_bonus", "12.0", "Max focus bonus given for every fully charged hitman shot on a boss.", _, true, 0.0);
	g_cvExplosiveArrow = CreateConVar("vsh_explosive_arrow", "1", "Toggle explosive arrow for attacking team.", _, true, 0.0, true, 1.0);
	g_cvArrowExplosionDmg = CreateConVar("vsh_arrow_explosion_damage", "45.0", "Arrow explosion damage.", _, true, 0.0);
	g_cvThirdDegreeUberReward = CreateConVar("vsh_third_degree_uber_bonus", "0.1", "Uber given to your healers upon every successful hit on the boss.", _, true, 0.0);
	g_cvBattalionBackupMaxZombieScout = CreateConVar("vsh_battalion_backup_max_zombie_scout", "5", "Max number of dead players to revive as zombie scouts.", _, true, 0.0);
	g_cvConcherorBuffUber = CreateConVar("vsh_concheror_buff_uber", "1", "Give the player ubercharge condition upon activating their concheror banner.", _, true, 0.0, true, 1.0);
	g_cvBuffBannerRocketsBonus = CreateConVar("vsh_buff_banner_rockets_bonus", "16", "Amount of rockets to add into the player's rocket launcher's clip upon buff banner activation.", _, true, 0.0);
	g_cvBuffBannerRocketLauncherFasterFireRate = CreateConVar("vsh_buff_banner_rocket_launcher_faster_fire_rate", "0.10", "", _, false, _, true, 1.0);
	g_cvBuffBannerBonusDuration = CreateConVar("vsh_buff_banner_bonus_duration", "5.0", "Buff banner bonus duration in second.", _, true, 0.0);
	g_cvBackstabBigEarnerCloak = CreateConVar("vsh_boss_backstab_big_earner_cloak", "100.0", "% cloak given upon boss backstab with the Big Earner.", _, true, 0.0);
	g_cvBackstabBigEarnerSpeedBoostDuration = CreateConVar("vsh_boss_backstab_big_earner_speed_boost_duration", "3.0", "Duration of speed boost given upon boss backstab with the Big Earner.");
	g_cvBackstabKunaiHeal = CreateConVar("vsh_boss_backstab_kunai_heal", "220", "Amount of health given upon boss backstab with the Kunai.");
	g_cvRevengeCritMult = CreateConVar("vsh_crit_revenge_damage_mult", "2.0", "If revenge crit is used, base damage will be multplied by this amount.", _, true, 0.0);
	g_cvSteakBuffDamageResis = CreateConVar("vsh_steak_buff_damage_resistance", "0.7", "Damage resistance from the Buffalo Steak.", _, true, 0.0);
	g_cvCritColaEndBuffSlowdown = CreateConVar("vsh_crit_cola_slowdown", "1", "Slow down player after using their crit cola.", _, true, 0.0, true, 1.0);
	g_cvCritColaMiniCritIsCrit = CreateConVar("vsh_crit_cola_is_crit", "1", "Defines if the crit cola should award crit instead of minicrit", _, true, 0.0, true, 1.0);
	g_cvBossPlayerStompDmg = CreateConVar("vsh_stomp_damage", "1024.0", "Damage applied if someone stomp the boss.", _, true, 0.0);
	g_cvClimbHealth = CreateConVar("vsh_climb_health", "15", "Amount of health drained when climbing.", _, true, 0.0);
	g_cvMarkForDeathRageDamageDrain = CreateConVar("vsh_mark_for_death_dmg_drain", "100", "Amount of rage damage to drain upon marking a boss for death.", _, true, 0.0);
	g_cvMedigunPatientTeleport = CreateConVar("vsh_medigun_patient_teleport", "1", "Defines if a healer can teleport to his patient using the reload key.", _, true, 0.0, true, 1.0);
	g_cvPatientTeleportStunDuration = CreateConVar("vsh_medigun_patient_teleport_stun_duration", "1.5", "How long the healer should be stunned for teleporting to his patient.", _, true, 0.0);
	g_cvSummonedPlayerFallDamageCap = CreateConVar("vsh_summoned_player_fall_damage_cap", "10.0", "Fall damage cap for player summoned in any form during the round.", _, true, 0.0);
	
	//Collect the convars
	tf_arena_use_queue = FindConVar("tf_arena_use_queue");
	mp_teams_unbalance_limit = FindConVar("mp_teams_unbalance_limit");
	tf_arena_first_blood = FindConVar("tf_arena_first_blood");
	tf_dropped_weapon_lifetime = FindConVar("tf_dropped_weapon_lifetime");
	mp_forcecamera = FindConVar("mp_forcecamera");
	tf_scout_hype_pep_max = FindConVar("tf_scout_hype_pep_max");
	tf_damage_disablespread = FindConVar("tf_damage_disablespread");
	tf_feign_death_activate_damage_scale = FindConVar("tf_feign_death_activate_damage_scale");
	tf_feign_death_damage_scale = FindConVar("tf_feign_death_damage_scale");
	tf_stealth_damage_reduction = FindConVar("tf_stealth_damage_reduction");
	tf_feign_death_duration = FindConVar("tf_feign_death_duration");
	tf_feign_death_speed_duration = FindConVar("tf_feign_death_speed_duration");
	tf_arena_preround_time = FindConVar("tf_arena_preround_time");
	tf_forced_holiday = FindConVar("tf_forced_holiday");
	
	AddNormalSoundHook(NormalSoundHook);
	
	SDK_Init();
	Queue_Init();
	Natives_Init();
	
	SpecialRounds_Refresh();
	
	config = new Config();
	configWeapon = new WeaponConfig();
	classConfig = new ClassConfig();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
			if (AreClientCookiesCached(i))
				OnClientCookiesCached(i);
		}
		g_clientBoss[i] = INVALID_BOSS;
	}
	
	g_hInfoHud = CreateHudSynchronizer();
	Menus_Init();
}

void SetupClassDefaultWeapons()
{
	// Scout
	if (g_hSDKWeaponScattergun != null) delete g_hSDKWeaponScattergun;
	if (g_hSDKWeaponPistolScout != null) delete g_hSDKWeaponPistolScout;
	if (g_hSDKWeaponBat != null) delete g_hSDKWeaponBat;
	
	g_hSDKWeaponScattergun = configWeapon.PrepareItemHandle("tf_weapon_scattergun", 13, 0, 0);
	g_hSDKWeaponPistolScout = configWeapon.PrepareItemHandle("tf_weapon_pistol", 23, 0, 0);
	g_hSDKWeaponBat = configWeapon.PrepareItemHandle("tf_weapon_bat", 0, 0, 0);
	
	// Sniper
	if (g_hSDKWeaponSniperRifle != null) delete g_hSDKWeaponSniperRifle;
	if (g_hSDKWeaponSMG != null) delete g_hSDKWeaponSMG;
	if (g_hSDKWeaponKukri != null) delete g_hSDKWeaponKukri;
	
	g_hSDKWeaponSniperRifle = configWeapon.PrepareItemHandle("tf_weapon_sniperrifle", 14, 0, 0);
	g_hSDKWeaponSMG = configWeapon.PrepareItemHandle("tf_weapon_smg", 16, 0, 0);
	g_hSDKWeaponKukri = configWeapon.PrepareItemHandle("tf_weapon_club", 3, 0, 0);
	
	// Soldier
	if (g_hSDKWeaponRocketLauncher != null) delete g_hSDKWeaponRocketLauncher;
	if (g_hSDKWeaponShotgunSoldier != null) delete g_hSDKWeaponShotgunSoldier;
	if (g_hSDKWeaponShovel != null) delete g_hSDKWeaponShovel;
	
	g_hSDKWeaponRocketLauncher = configWeapon.PrepareItemHandle("tf_weapon_rocketlauncher", 18, 0, 0);
	g_hSDKWeaponShotgunSoldier = configWeapon.PrepareItemHandle("tf_weapon_shotgun", 10, 0, 0);
	g_hSDKWeaponShovel = configWeapon.PrepareItemHandle("tf_weapon_shovel", 6, 0, 0);
	
	// Demoman
	if (g_hSDKWeaponGrenadeLauncher != null) delete g_hSDKWeaponGrenadeLauncher;
	if (g_hSDKWeaponStickyLauncher != null) delete g_hSDKWeaponStickyLauncher;
	if (g_hSDKWeaponBottle != null) delete g_hSDKWeaponBottle;
	
	g_hSDKWeaponGrenadeLauncher = configWeapon.PrepareItemHandle("tf_weapon_grenadelauncher", 19, 0, 0);
	g_hSDKWeaponStickyLauncher = configWeapon.PrepareItemHandle("tf_weapon_pipebomblauncher", 20, 0, 0);
	g_hSDKWeaponBottle = configWeapon.PrepareItemHandle("tf_weapon_bottle", 1, 0, 0);
	
	// Heavy
	if (g_hSDKWeaponMinigun != null) delete g_hSDKWeaponMinigun;
	if (g_hSDKWeaponShotgunHeavy != null) delete g_hSDKWeaponShotgunHeavy;
	if (g_hSDKWeaponFists != null) delete g_hSDKWeaponFists;
	
	g_hSDKWeaponMinigun = configWeapon.PrepareItemHandle("tf_weapon_minigun", 15, 0, 0);
	g_hSDKWeaponShotgunHeavy = configWeapon.PrepareItemHandle("tf_weapon_shotgun", 11, 0, 0);
	g_hSDKWeaponFists = configWeapon.PrepareItemHandle("tf_weapon_fists", 5, 0, 0);
	
	// Medic
	if (g_hSDKWeaponSyringeGun != null) delete g_hSDKWeaponSyringeGun;
	if (g_hSDKWeaponMedigun != null) delete g_hSDKWeaponMedigun;
	if (g_hSDKWeaponBonesaw != null) delete g_hSDKWeaponBonesaw;
	
	g_hSDKWeaponSyringeGun = configWeapon.PrepareItemHandle("tf_weapon_syringegun_medic", 17, 0, 0);
	g_hSDKWeaponMedigun = configWeapon.PrepareItemHandle("tf_weapon_medigun", 29, 0, 0);
	g_hSDKWeaponBonesaw = configWeapon.PrepareItemHandle("tf_weapon_bonesaw", 8, 0, 0);
	
	// Pyro
	if (g_hSDKWeaponFlamethrower != null) delete g_hSDKWeaponFlamethrower;
	if (g_hSDKWeaponShotgunPyro != null) delete g_hSDKWeaponShotgunPyro;
	if (g_hSDKWeaponFireaxe != null) delete g_hSDKWeaponFireaxe;
	
	g_hSDKWeaponFlamethrower = configWeapon.PrepareItemHandle("tf_weapon_flamethrower", 21, 0, 0);
	g_hSDKWeaponShotgunPyro = configWeapon.PrepareItemHandle("tf_weapon_shotgun", 12, 0, 0);
	g_hSDKWeaponFireaxe = configWeapon.PrepareItemHandle("tf_weapon_fireaxe", 2, 0, 0);
	
	// Spy
	if (g_hSDKWeaponRevolver != null) delete g_hSDKWeaponRevolver;
	if (g_hSDKWeaponKnife != null) delete g_hSDKWeaponKnife;
	if (g_hSDKWeaponInvis != null) delete g_hSDKWeaponInvis;
	
	g_hSDKWeaponRevolver = configWeapon.PrepareItemHandle("tf_weapon_revolver", 24, 0, 0);
	g_hSDKWeaponKnife = configWeapon.PrepareItemHandle("tf_weapon_knife", 4, 0, 0);
	g_hSDKWeaponInvis = configWeapon.PrepareItemHandle("tf_weapon_invis", 297, 0, 0);
	
	// Engineer
	if (g_hSDKWeaponShotgunPrimary != null) delete g_hSDKWeaponShotgunPrimary;
	if (g_hSDKWeaponPistol != null) delete g_hSDKWeaponPistol;
	if (g_hSDKWeaponWrench != null) delete g_hSDKWeaponWrench;
	
	g_hSDKWeaponShotgunPrimary = configWeapon.PrepareItemHandle("tf_weapon_shotgun", 9, 0, 0);
	g_hSDKWeaponPistol = configWeapon.PrepareItemHandle("tf_weapon_pistol", 22, 0, 0);
	g_hSDKWeaponWrench = configWeapon.PrepareItemHandle("tf_weapon_wrench", 7, 0, 0);
}

public void OnPluginEnd()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			OnClientDisconnect(i);
	}
	VSH_StopBossMusic();
	Plugin_Cvars(false);
}

void Plugin_Cvars(bool toggle)
{
	static bool bArenaUseQueue;
	static bool bArenaFirstBlood;
	static bool bForceCamera;
	
	static int iTeamsUnbalanceLimit;
	static int iDroppedWeaponLifetime;
	static int iDamageDisableSpread;
	static int iForcedHoliday;
	
	static float flScoutHypePepMax;
	static float flFeignDeathActiveDamageScale;
	static float flFeignDeathDamageScale;
	static float flStealthDamageReduction;
	static float flFeignDeathDuration;
	static float flFeignDeathSpeed;
	
	static bool toggled = false; // Used to avoid a overwrite of default value if toggled twice
	
	if (toggle && !toggled)
	{
		toggled = true;
		
		bArenaUseQueue = tf_arena_use_queue.BoolValue;
		tf_arena_use_queue.BoolValue = false;
		
		bArenaFirstBlood = tf_arena_first_blood.BoolValue;
		tf_arena_first_blood.BoolValue = false;
		
		bForceCamera = mp_forcecamera.BoolValue;
		mp_forcecamera.BoolValue = false;
		
		iTeamsUnbalanceLimit = mp_teams_unbalance_limit.IntValue;
		mp_teams_unbalance_limit.IntValue = 0;
		
		iDroppedWeaponLifetime = tf_dropped_weapon_lifetime.IntValue;
		tf_dropped_weapon_lifetime.IntValue = 0;
		
		iDamageDisableSpread = tf_damage_disablespread.IntValue;
		tf_damage_disablespread.IntValue = 1;
		
		iForcedHoliday = tf_forced_holiday.IntValue;
		tf_forced_holiday.IntValue = 2;
		
		flScoutHypePepMax = tf_scout_hype_pep_max.FloatValue;
		tf_scout_hype_pep_max.FloatValue = 100.0;
		
		flFeignDeathActiveDamageScale = tf_feign_death_activate_damage_scale.FloatValue;
		tf_feign_death_activate_damage_scale.FloatValue = 0.1;
		
		flFeignDeathDamageScale = tf_feign_death_damage_scale.FloatValue;
		tf_feign_death_damage_scale.FloatValue = 0.1;
		
		flStealthDamageReduction = tf_stealth_damage_reduction.FloatValue;
		tf_stealth_damage_reduction.FloatValue = 0.1;
		
		flFeignDeathDuration = tf_feign_death_duration.FloatValue;
		tf_feign_death_duration.FloatValue = 7.0;
		
		flFeignDeathSpeed = tf_feign_death_speed_duration.FloatValue;
		tf_feign_death_speed_duration.FloatValue = 0.0;
	}
	else if (toggled)
	{
		tf_arena_use_queue.BoolValue = bArenaUseQueue;
		tf_arena_first_blood.BoolValue = bArenaFirstBlood;
		mp_forcecamera.BoolValue = bForceCamera;
		

		mp_teams_unbalance_limit.IntValue = iTeamsUnbalanceLimit;
		tf_dropped_weapon_lifetime.IntValue = iDroppedWeaponLifetime;
		tf_damage_disablespread.IntValue = iDamageDisableSpread;
		tf_forced_holiday.IntValue = iForcedHoliday;
		

		tf_scout_hype_pep_max.FloatValue = flScoutHypePepMax;
		tf_feign_death_activate_damage_scale.FloatValue = flFeignDeathActiveDamageScale;
		tf_feign_death_damage_scale.FloatValue = flFeignDeathDamageScale;
		tf_stealth_damage_reduction.FloatValue = flStealthDamageReduction;
		tf_feign_death_duration.FloatValue = flFeignDeathDuration;
		tf_feign_death_speed_duration.FloatValue = flFeignDeathSpeed;
		
		toggled = false;
	}
}

void PluginStop(bool bError = false, const char[] sError = "")
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (g_clientBoss[iClient].IsValid())
			g_clientBoss[iClient].Destroy();
		g_clientBoss[iClient] = INVALID_BOSS;
	}
	if (bError)
	{
		PrintToChatAll("\x07FF0000 !!!!ERROR!!! UNEXPECTED CODE EXECUTION DISABLING GAMEMODE..... \n Please contact an admin ASAP!");
		Plugin_Cvars(false);
		SetFailState(sError);
	}
}

public void OnMapStart()
{
	//Check if the map is a VSH map
	char sMapName[64];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if ((StrContains(sMapName, "vsh_", false) != -1) || (StrContains(sMapName, "ff2_", false) != -1) || (StrContains(sMapName, "arena_", false) != -1))
	{
		if (FindEntityByClassname(-1, "tf_logic_arena") == -1)
		{
			g_bEnabled = false;
			return;
		}
		
		g_flLastArrowDrawTime = GetGameTime();
		
		config.Refresh();
		SetupClassDefaultWeapons();
		
		SpecialRounds_OnMapStart();
	
		//Precache every bosses
		for (int i = 0; i <= sizeof(g_strBossesType)-1; i++)
		{
			CBaseBoss boss = view_as<CBaseBoss>(0);
			boss.SetType(g_strBossesType[i]);
			boss.Precache();
		}
		
		// Precache duo/triple ect rotation
		for (int i = 0; i <= sizeof(g_strMiscBossesType)-1; i++)
		{
			CBaseBoss boss = view_as<CBaseBoss>(0);
			boss.SetType(g_strMiscBossesType[i]);
			boss.Precache();
		}
		
		for (int i = 1; i <= 3; i++)
		{
			char sBackStabSound[PLATFORM_MAX_PATH];
			Format(sBackStabSound, sizeof(sBackStabSound), "vsh_rewrite/stab0%i.mp3", i);
			PrepareSound(sBackStabSound);
		}
		
		PrecacheParticleSystem("ExplosionCore_MidAir");
		
		PrecacheSound(BOSS_BACKSTAB_SOUND);
		PrecacheSound("player/doubledonk.wav");
		PrepareSound(CP_UNLOCK_SOUND);
		DeathRings_Precache();
		
		BEAM_MODEL_INDEX = PrecacheModel(BEAM_MATERIAL);
		g_bEnabled = true;
	}
}

public void OnGameFrame()
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iHealthBar = FindEntityByClassname(-1, "monster_resource");
	
	int iActiveBoss = GetClientOfUserId(g_iUserActiveBoss);
	if (g_bRoundStarted && 0 < iActiveBoss <= MaxClients && IsClientInGame(iActiveBoss))
	{
		int iBossTeam = GetClientTeam(iActiveBoss);
		if (iBossTeam > 1)
		{
			static float flDefAng = 0.0;
			
			flDefAng = AngleNormalize(flDefAng);
			
			bool bAlive = IsPlayerAlive(iActiveBoss);
			bool bDrawArrow = (GetGameTime()-g_flLastArrowDrawTime > 0.05);
			
			// Collect recipitients for the arrow
			int iTotalCount = 0, iClients[TF_MAXPLAYERS+1];
			for (int i = 1; i <= MaxClients; i++)
				if (IsClientInGame(i) && g_iPlayerPreferences[i][PlayerPreference_DisplayBossArrow])
					iClients[iTotalCount++] = i;
			
			
			g_iHealthBarHealth = (bAlive) ? GetEntProp(iActiveBoss, Prop_Send, "m_iHealth") : 0;
			g_iHealthBarMaxHealth = SDK_GetMaxHealth(iActiveBoss);
			
			float vecPos[3], vecMaxs[3];
			int iColor[4] = {255, 0, 0, 255};
			if (iBossTeam == TFTeam_Blue)
			{
				iColor[0] = 0;
				iColor[2] = 255;
			}
			
			if (bAlive && bDrawArrow)
			{
				GetClientAbsOrigin(iActiveBoss, vecPos);
				GetEntPropVector(iActiveBoss, Prop_Send, "m_vecMaxs", vecMaxs);
				vecPos[2] += vecMaxs[2]+10.0;
				
				VSH_DisplayArrow(vecPos, flDefAng, iColor, false, iClients, iTotalCount);
			}
			
			if (bDrawArrow)
				g_flLastArrowDrawTime = GetGameTime();
			
			for (int iAlly = 1; iAlly <= MaxClients; iAlly++)
			{
				if (iAlly != iActiveBoss && IsClientInGame(iAlly) && GetClientTeam(iAlly) == iBossTeam && g_clientBoss[iAlly].IsValid() && !g_clientBoss[iAlly].IsMinion)
				{
					if (IsPlayerAlive(iAlly))
					{
						g_iHealthBarHealth += GetEntProp(iAlly, Prop_Send, "m_iHealth");
						
						if (bDrawArrow)
						{
							GetClientAbsOrigin(iAlly, vecPos);
							GetEntPropVector(iAlly, Prop_Send, "m_vecMaxs", vecMaxs);
							vecPos[2] += vecMaxs[2]+10.0;
							VSH_DisplayArrow(vecPos, flDefAng, iColor, false, iClients, iTotalCount);
						}
					}
					g_iHealthBarMaxHealth += SDK_GetMaxHealth(iActiveBoss);
				}
			}
			
			int healthBarValue = RoundToCeil(float(g_iHealthBarHealth) / float(g_iHealthBarMaxHealth) * 255.0);
			if(healthBarValue > 255) healthBarValue = 255;
			
			SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", healthBarValue);
			
			flDefAng += 0.02;
		}
	}
	else
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", 0);
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	if (0 < iEntity < 2049) Network_ResetEntity(iEntity);
	
	if (strcmp(sClassname, "tf_projectile_arrow") == 0 && config.LookupBool(g_cvExplosiveArrow))
	{
		SDKHook(iEntity, SDKHook_StartTouchPost, Arrow_OnTouch);
	}
	else if(g_bBlockRagdoll && strcmp(sClassname, "tf_ragdoll") == 0)
	{
		AcceptEntityInput(iEntity, "Kill");
		g_bBlockRagdoll = false;
	}
	else if(strncmp(sClassname, "item_healthkit_", 15) == 0 || strncmp(sClassname, "item_ammopack_", 14) == 0 || strcmp(sClassname, "func_regenerate") == 0 || strcmp(sClassname, "tf_ammo_pack") == 0)
	{
		SDKHook(iEntity, SDKHook_Touch, Boss_OnTouch);
	}
	else if (strcmp(sClassname, "trigger_capture_area") == 0)
	{
		SDKHook(iEntity, SDKHook_StartTouch, CaptureArea_OnTouch);
		SDKHook(iEntity, SDKHook_Touch, CaptureArea_OnTouch);
		SDKHook(iEntity, SDKHook_EndTouch, CaptureArea_OnTouch);
	}
}

public void OnEntityDestroyed(int iEntity)
{
	if (0 < iEntity < 2049)
	{
		Network_ResetEntity(iEntity);
	}
}

public Action Arrow_OnTouch(int iEntity, int iOther)
{
	int iClient = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	if (0 < iClient <= MaxClients && IsClientInGame(iClient) && !g_clientBoss[iClient].IsValid())
	{
		float vecPos[3];
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vecPos);
		char sSound[255];
		Format(sSound, sizeof(sSound), "weapons/airstrike_small_explosion_0%i.wav", GetRandomInt(1,3));
		TF2_Explode(iClient, vecPos, config.LookupFloat(g_cvArrowExplosionDmg), 120.0, "ExplosionCore_MidAir", sSound);
	}
	return Plugin_Continue;
}

void Frame_SoldierConcherorUberBuff(int iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient) || g_clientBoss[iClient].IsValid()) return;
	
	bool bRage = !!GetEntProp(iClient, Prop_Send, "m_bRageDraining");
	if (bRage)
	{
		TF2_AddCondition(iClient, TFCond_UberchargedCanteen, 0.1);
		TF2_AddCondition(iClient, TFCond_CritOnDamage, 0.1);
		RequestFrame(Frame_SoldierConcherorUberBuff, iUserID);
	}
}

void Frame_UberchargeAddCrit(int iRef)
{
	int iMedigun = EntRefToEntIndex(iRef);
	if (iMedigun > MaxClients)
	{
		bool bChargeReleased = !!GetEntProp(iMedigun, Prop_Send, "m_bChargeRelease");
		if (bChargeReleased)
		{
			RequestFrame(Frame_UberchargeAddCrit, iRef);
			int iHealTarget = GetEntPropEnt(iMedigun, Prop_Send, "m_hHealingTarget");
			if (0 < iHealTarget <= MaxClients && IsClientInGame(iHealTarget) && IsPlayerAlive(iHealTarget))
				TF2_AddCondition(iHealTarget, TFCond_CritOnDamage, 0.1);
		}
	}
}

void Frame_InitVshPreRoundTimer(int iTime)
{
	// Kill the timer created by the game
	int iGameTimer = -1;
	while ((iGameTimer = FindEntityByClassname(iGameTimer, "team_round_timer")) > MaxClients)
	{
		if (GetEntProp(iGameTimer, Prop_Send, "m_bShowInHUD"))
		{
			AcceptEntityInput(iGameTimer, "Kill");
			break;
		}
	}
	
	
	// Initiate our timer with our time
	int iTimer = CreateEntityByName("team_round_timer");
	DispatchKeyValue(iTimer, "show_in_hud", "1");
	DispatchSpawn(iTimer);
	
	SetVariantInt(iTime);
	AcceptEntityInput(iTimer, "SetTime");
	AcceptEntityInput(iTimer, "Resume");
	AcceptEntityInput(iTimer, "Enable");
	SetEntProp(iTimer, Prop_Send, "m_bAutoCountdown", false);
	
	GameRules_SetPropFloat("m_flStateTransitionTime", float(iTime)+GetGameTime());
	CreateTimer(float(iTime), Timer_EntityCleanup, EntIndexToEntRef(iTimer));
	
	Event event = CreateEvent("teamplay_update_timer");
	event.Fire();
}

public Action Event_RoundStart(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled || GameRules_GetProp("m_bInWaitingForPlayers")) return;
	
	// Play one round of arena
	if (g_iTotalRoundPlayed <= 0) return;
	
	// Arena has a very dumb logic, if all players from a team leave the round will end and then restart without reseting the game state...
	// Catch that issue and don't run our logic!
	bool bRed = false, bBlu = false;
	for (int iClient = 1; iClient <= MaxClients && (!bRed || !bBlu); iClient++)
	{
		if (IsClientInGame(iClient))
		{
			if (GetClientTeam(iClient) == TFTeam_Red)
				bRed = true;
			else if (GetClientTeam(iClient) == TFTeam_Blue)
				bBlu = true;
		}
	}
	// Both team must have at least one player!
	if (!bRed || !bBlu) return;
	
	g_hTimerPickBoss = null;
	g_hTimerBossMusic = null;
	g_hTimerCPUnlockSound = null;
	g_flTeamInvertedMoveControlsTime[TFTeam_Red] = 0.0;
	g_flTeamInvertedMoveControlsTime[TFTeam_Blue] = 0.0;
	g_bRoundStarted = false;
	g_bFreezeMovements = true;
	
	SpecialRound_Reset();
	
	bool bMusicPlayedLastRound = (strcmp(g_sBossMusic, "") == 0);
	// New round started
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		//Clean up any boss(es) that is/are still active
		if (g_clientBoss[iClient].IsValid())
			g_clientBoss[iClient].Destroy();
		
		Client_ResetFlags(iClient);
		
		g_clientBoss[iClient] = INVALID_BOSS;
		g_iPlayerDamage[iClient] = 0;
		g_iPlayerAssistDamage[iClient] = 0;
		
		for (int i = 1; i <= TF_MAXPLAYERS; i++)
			g_iPlayerTotalBackstab[iClient][i] = 0;
		
		if (!IsClientInGame(iClient)) continue;
			
		if (GetClientTeam(iClient) <= 1) continue;
		
		
		// Put every players in same team & pick the boss later
		TF2_ForceTeamJoin(iClient, ATTACK_TEAM);
		
		if (bMusicPlayedLastRound)
			StopSound(iClient, SNDCHAN_AUTO, g_sBossMusic);
	}
	
	g_sBossMusic = "";
	
	// Get top player and put them as our next boss
	int iPickedPlayer = Queue_GetTopPlayer();
	if (0 < iPickedPlayer <= MaxClients && IsClientInGame(iPickedPlayer))
	{
		// Reset their points
		Queue_ResetPlayer(iPickedPlayer);
		g_iUserActiveBoss = GetClientUserId(iPickedPlayer);
		TF2_ForceTeamJoin(iPickedPlayer, BOSS_TEAM);
		
		Queue_ResetPlayer(iPickedPlayer);
	}
	else
	{
		// We should never reach that part
		PluginStop(true, "[VSH] QUEUE SYSTEM FAILED TO PICK A PLAYER!!!!");
		return;
	}
	
	// Customize a bit the HUD & Lock the CP
	int iObjectiveRessource = TF2_GetObjectiveResource();
	if (iObjectiveRessource > MaxClients)
	{
		SetEntPropFloat(iObjectiveRessource, Prop_Send, "m_flCustomPositionX", 0.20);
		SetEntPropFloat(iObjectiveRessource, Prop_Send, "m_flCustomPositionY", -1.0);
	}

	//Create a trigger_hurt in case it does not exist
	if (FindEntityByClassname(-1, "trigger_hurt")) CreateEntityByName("trigger_hurt");
	
	GameRules_SetPropFloat("m_flCapturePointEnableTime", 31536000.0+GetGameTime());//3 years
	
	// Special round
	int iRoundTime = tf_arena_preround_time.IntValue;
	if (g_bSpecialRound || g_bPlayerTriggerSpecialRound[iPickedPlayer])
	{
		// Special round, let's add more setup time.
		iRoundTime += RoundToCeil(SR_CYCLELENGTH);
		SpecialRound_CycleStart();
		g_bSpecialRound = false;
		g_bPlayerTriggerSpecialRound[iPickedPlayer] = false;
	}
	float flPickBossTime = float(iRoundTime)-7.0;
	g_hTimerPickBoss = CreateTimer(flPickBossTime, Timer_PickBoss);
	
	RequestFrame(Frame_InitVshPreRoundTimer, iRoundTime);
}

public Action Event_RoundArenaStart(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled || GameRules_GetProp("m_bInWaitingForPlayers")) return;
	
	//Play one round of arena
	if (g_iTotalRoundPlayed <= 0) return;
	
	SpecialRound_OnRoundArenaStart();
	
	// Collect all bosses
	char sBossesAnnouncement[512];
	if (!VSH_SpecialRound(SPECIALROUND_CLASHOFBOSSES))
	{
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (!IsClientInGame(iClient)) continue;
			if (GetClientTeam(iClient) <= 1) continue;
			if (!g_clientBoss[iClient].IsValid()) continue;
			
			g_clientBoss[iClient].Spawn();
			g_clientBoss[iClient].iHealth = g_clientBoss[iClient].iMaxHealth;
			
			char sBossName[64];
			g_clientBoss[iClient].GetName(sBossName, sizeof(sBossName));
			Format(sBossesAnnouncement, sizeof(sBossesAnnouncement), "%s%N became: %s with %i HP\n", sBossesAnnouncement, iClient, sBossName, g_clientBoss[iClient].iMaxHealth);
		}
	}
	
	// New round started
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (!IsClientInGame(iClient)) continue;
		
		g_iPlayerDamage[iClient] = 0;
		g_iPlayerAssistDamage[iClient] = 0;
		
		if (GetClientTeam(iClient) <= 1) continue;
		
		PrintCenterText(iClient, sBossesAnnouncement);
		
		if (!g_clientBoss[iClient].IsValid())
		{
			Client_ApplyEffects(iClient);
		}
	}
	
	int iClient = GetClientOfUserId(g_iUserActiveBoss);
	if (0 < iClient <= MaxClients && IsClientInGame(iClient) && g_clientBoss[iClient].IsValid())
	{
		float flMusicTime, flInitDelay;
		g_clientBoss[iClient].GetMusicInfo(g_sBossMusic, sizeof(g_sBossMusic), flMusicTime, flInitDelay);
		g_hTimerBossMusic = CreateTimer(flInitDelay, Timer_MusicInitialDelay, g_clientBoss[iClient]);
		
		if (flInitDelay <= 0.0)
			TriggerTimer(g_hTimerBossMusic);
	}
	
	GameRules_SetPropFloat("m_flCapturePointEnableTime", 31536000.0+GetGameTime());
	DeathRings_Setup(240);
	
	g_bRoundStarted = true;
	g_bFreezeMovements = false;
}

public Action Event_RoundEnd(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	
	g_hTimerBossMusic = null;
	g_hTimerCPUnlockSound = null;
	g_bRoundStarted = false;
	
	DeathRings_Cleanup();
	
	int iWinningTeam = event.GetInt("team");
	SpecialRound_OnRoundEnd(iWinningTeam);
	
	g_iTotalRoundPlayed++;
	if (g_iTotalRoundPlayed <= 1)
	{
		if (g_iTotalRoundPlayed == 1)// Arena round ended disable arena logic!
			Plugin_Cvars(true);
		return;
	}
	
	int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
	if (iWinningTeam == BOSS_TEAM)
	{
		if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss))// Play our win line
		{
			if (g_clientBoss[iMainBoss].IsValid())
			{
				char sSound[255];
				g_clientBoss[iMainBoss].GetWinSound(sSound, sizeof(sSound));
				if (strcmp(sSound, "") != 0)
					BroadcastSoundToTeam(TFTeam_Spectator, sSound);
			}
		}
	}
	else
	{
		if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss))//Play our lose line
		{
			if (g_clientBoss[iMainBoss].IsValid())
			{
				char sSound[255];
				g_clientBoss[iMainBoss].GetLoseSound(sSound, sizeof(sSound));
				if (strcmp(sSound, "") != 0)
					BroadcastSoundToTeam(TFTeam_Spectator, sSound);
			}
		}
	}
	
	bool bMusicPlayedLastRound = (strcmp(g_sBossMusic, "") != 0);
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (IsClientInGame(iClient))
		{
			StopSound(iClient, SNDCHAN_AUTO, g_sBossMusic);
			if (GetClientTeam(iClient) > 1 && iClient != iMainBoss)
			{
				Queue_AddPlayerPoints(iClient, 10+(g_iPlayerDamage[iClient]/1000)+(g_iPlayerAssistDamage[iClient]/1000));
				if (bMusicPlayedLastRound)
					StopSound(iClient, SNDCHAN_AUTO, g_sBossMusic);
			}
		}
	}
	
	char sPlayerNames[3][70];
	sPlayerNames[0] = "----";
	sPlayerNames[1] = "----";
	sPlayerNames[2] = "----";
	
	ArrayList aPlayersList = new ArrayList();
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) > 1)
		{
			aPlayersList.Push(i);
		}
	}
	
	for (int iRank = 0; iRank < 3; iRank++)
	{
		int iBestPlayerIndex = -1;
		int iLength = aPlayersList.Length;
		int iBestDamage = 0;
		
		for (int i = 0; i < iLength; i++)
		{
			int iPlayer = aPlayersList.Get(i);
			int iPlayerDmg = g_iPlayerDamage[iPlayer];
			if (iPlayerDmg > iBestDamage)
			{
				iBestDamage = iPlayerDmg;
				iBestPlayerIndex = i;
			}
		}
		
		if (iBestPlayerIndex != -1)
		{
			char sBufferName[59];
			int iPlayer = aPlayersList.Get(iBestPlayerIndex);
			
			GetClientName(iPlayer, sBufferName, sizeof(sBufferName));
			Format(sPlayerNames[iRank], sizeof(sPlayerNames[]), "%s - %i", sBufferName, g_iPlayerDamage[iPlayer]);
			aPlayersList.Erase(iBestPlayerIndex);
		}
	}
	
	delete aPlayersList;
	
	SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			ShowSyncHudText(i, g_hInfoHud, "[VSH REWRITE] TOP PLAYERS\n1) %s \n2) %s \n3) %s \n\nYour damage: %i\nYour score: %i", sPlayerNames[0], sPlayerNames[1], sPlayerNames[2], g_iPlayerDamage[i], (g_iPlayerDamage[i]/1000)+(g_iPlayerAssistDamage[i]/1000));
}

public void Event_BroadcastAudio(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	char strSound[50];
	event.GetString("sound", strSound, sizeof(strSound));
	//PrintToChatAll("Sound played naturally: %s", strSound);
	
	if (strcmp(strSound, "Game.TeamWin3") == 0
	|| strcmp(strSound, "Game.YourTeamLost") == 0
	|| strcmp(strSound, "Game.YourTeamWon") == 0
	|| strcmp(strSound, "Announcer.AM_RoundStartRandom") == 0
	|| strcmp(strSound, "Game.Stalemate") == 0)
		SetEventBroadcast(event, true);
}

public Action Event_PlayerSpawn(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (iClient <= 0 || iClient > MaxClients) return;
	
	int iTeam = GetClientTeam(iClient);
	if (iTeam <= 1) return;
	
	StopSound(iClient, SNDCHAN_AUTO, SENTRY_BUSTER_LOOP_SOUND);
	Client_Spawn(iClient);
	
	// Player spawned, if they are a boss, call their spawn function
	if (g_clientBoss[iClient].IsValid())
		g_clientBoss[iClient].Spawn();
}

void Frame_VerifyTeam(int userid)
{
	int iClient = GetClientOfUserId(userid);
	if (iClient <= 0 || !IsClientInGame(iClient)) return;
	
	int iTeam = GetClientTeam(iClient);
	if (iTeam <= 1) return;
	
	if (g_bRoundStarted)
	{
		// Round has started, this is a late spawning.
		// Only zombies & minions are allowed to late spawn.
		if (!Client_HasFlag(iClient, VSH_ZOMBIE) && !(g_clientBoss[iClient] != INVALID_BOSS && g_clientBoss[iClient].IsMinion))
		{
			if (IsPlayerAlive(iClient))
			{
				int iTrigger = FindEntityByClassname(-1, "trigger_hurt");
				SDKHooks_TakeDamage(iClient, iTrigger, iTrigger, 9999999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
			}
			return; // not a zombie or minion stop right there
		}
	}
	
	int iActiveBoss = GetClientOfUserId(g_iUserActiveBoss);
	if (0 < iActiveBoss <= MaxClients && IsClientInGame(iActiveBoss) && iActiveBoss != iClient)
	{
		int iBossTeam = GetClientTeam(iActiveBoss);
		if (iBossTeam == iTeam && !Client_HasFlag(iClient, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM))// Don't allow normal players to spawn in boss team!
		{
			int iSwapTeam;
			if (iBossTeam == TFTeam_Red)
				iSwapTeam = TFTeam_Blue;
			else if (iBossTeam == TFTeam_Blue)
				iSwapTeam = TFTeam_Red;
			
			ChangeClientTeam(iClient, iSwapTeam);
			if (!g_bRoundStarted)
				TF2_RespawnPlayer(iClient);
			return;
		}
	}
}

public Action Event_PlayerDeath(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return Plugin_Continue;
	if (g_iTotalRoundPlayed <= 0) return Plugin_Continue;
	if (!g_bRoundStarted) return Plugin_Continue;

	int iVictim = GetClientOfUserId(event.GetInt("userid"));
	if (iVictim <= 0 || iVictim > MaxClients) return Plugin_Continue;
	
	int iVictimTeam = GetClientTeam(iVictim);
	if (iVictimTeam <= 1) return Plugin_Continue;
	
	TFClassType desiredClass = view_as<TFClassType>(GetEntProp(iVictim, Prop_Send, "m_iDesiredPlayerClass"));
	if (desiredClass != TFClass_Unknown)
		TF2_SetPlayerClass(iVictim, desiredClass);
	
	int iSentry = MaxClients+1;
	while((iSentry = FindEntityByClassname(iSentry, "obj_sentrygun")) > MaxClients)
	{
		if (GetEntPropEnt(iSentry, Prop_Send, "m_hBuilder") == iVictim)
		{
			SetVariantInt(999999);
			AcceptEntityInput(iSentry, "RemoveHealth");
		}
	}
	
	int iLastAlive = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && i != iVictim && GetClientTeam(i) == iVictimTeam)
			if (!g_clientBoss[i].IsValid() && !Client_HasFlag(i, VSH_ZOMBIE))
				iLastAlive++;
	}
	
	if (0 < iLastAlive <= 4)
	{
		if (ControlPoint_Unlock())
			PrintHintTextToAll("Only 4 players are alive, unlocking control point...");
	}	
	if (2 <= iLastAlive <= 3)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && i != iVictim && GetClientTeam(i) == iVictimTeam && !Client_HasFlag(i, VSH_ZOMBIE) && !g_clientBoss[i].IsValid())
				TF2_AddCondition(i, TFCond_Buffed, -1.0);
		}
	}
	else if (iLastAlive == 1)
	{
		//Find the last one alive and crit them
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && i != iVictim && GetClientTeam(i) == iVictimTeam && !Client_HasFlag(i, VSH_ZOMBIE) && !g_clientBoss[i].IsValid())
			{
				TF2_AddCondition(i, TFCond_CritOnDamage, -1.0);
				break;
			}
		}
	}
	else if (iLastAlive == 0)
	{
		if (!Client_HasFlag(iVictim, VSH_ZOMBIE))
		{
			int iTrigger = FindEntityByClassname(-1, "trigger_hurt");
			// Kill any zombies that are still alive
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && i != iVictim && GetClientTeam(i) == iVictimTeam && !g_clientBoss[i].IsValid())
					SDKHooks_TakeDamage(i, iTrigger, iTrigger, 99999999.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
			}
		}
	}
	
	if (g_clientBoss[iVictim].IsValid())
		g_clientBoss[iVictim].OnDeath(event);
	
	int iAttacker = GetClientOfUserId(event.GetInt("attacker"));
	if (0 < iAttacker <= MaxClients && GetClientTeam(iAttacker) > 1)
	{
		if (g_clientBoss[iAttacker].IsValid())
			g_clientBoss[iAttacker].OnPlayerKilled(iVictim, event);
		
		int iMainBoss = GetClientOfUserId(g_iUserActiveBoss);
		
		if (iLastAlive == 1)
		{
			if (0 < iMainBoss <= MaxClients && IsClientInGame(iMainBoss) && iAttacker == iMainBoss)// Last man standing, play the voice line
			{
				if (g_clientBoss[iMainBoss].IsValid())
				{
					char sSound[255];
					g_clientBoss[iMainBoss].GetLastManSound(sSound, sizeof(sSound));
					if (strcmp(sSound, "") != 0)
						EmitSoundToAll(sSound, iMainBoss, SNDCHAN_VOICE, SNDLEVEL_AIRCRAFT);
				}
			}
		}
		else if ((GetRandomInt(0, 1)) && !g_clientBoss[iVictim].IsValid() && iVictim != iAttacker && iLastAlive > 0 && g_clientBoss[iAttacker].IsValid())
		{
			char sSound[255];
			g_clientBoss[iAttacker].GetClassKillSound(sSound, sizeof(sSound), TF2_GetPlayerClass(iVictim));
			if (strcmp(sSound, "") != 0)
				EmitSoundToAll(sSound, iAttacker, SNDCHAN_VOICE, SNDLEVEL_AIRCRAFT);
		}
	}
	
	if (Client_HasFlag(iVictim, VSH_ZOMBIE))
		SetEntProp(iVictim, Prop_Send, "m_bForcedSkin", false);
	
	Client_RemoveFlag(iVictim, VSH_ZOMBIE);
	Client_RemoveFlag(iVictim, VSH_ALLOWED_TO_SPAWN_BOSS_TEAM);
	
	if (g_clientBoss[iVictim].IsValid())
	{
		// Destroy boss object so they cannot respawn
		// Which also allow other bosses to ressurect them as minions
		if (VSH_SpecialRound(SPECIALROUND_CLASHOFBOSSES) || g_clientBoss[iVictim].IsMinion)
		{
			g_clientBoss[iVictim].Destroy();
			g_clientBoss[iVictim] = INVALID_BOSS;
		}
	}
	
	return Plugin_Changed;
}

public Action Event_PlayerInventoryUpdate(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (iClient <= 0 || iClient > MaxClients || GetClientTeam(iClient) <= 1) return;
	
	if (!g_clientBoss[iClient].IsValid())
	{
		/*Balance or restrict specific weapons*/
		int iWeapon = -1;
		char sAttrib[255];
		Handle hItem;
		TFClassType class = TF2_GetPlayerClass(iClient);
		for (int iSlot = 0; iSlot <= 5; iSlot++)
		{
			iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
			
			if (IsValidEdict(iWeapon))
			{
				if (!configWeapon.GetWeaponAttributes(GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex"), sAttrib, sizeof(sAttrib)))
				{
					hItem = INVALID_HANDLE;
					TF2_RemoveItemInSlot(iClient, iSlot);
					
					switch (iSlot)
					{
						case WeaponSlot_Primary:
						{
							switch (class)
							{
								case TFClass_Scout: hItem = g_hSDKWeaponScattergun;
								case TFClass_Sniper: hItem = g_hSDKWeaponSniperRifle;
								case TFClass_Soldier: hItem = g_hSDKWeaponRocketLauncher;
								case TFClass_DemoMan: hItem = g_hSDKWeaponGrenadeLauncher;
								case TFClass_Heavy: hItem = g_hSDKWeaponMinigun;
								case TFClass_Medic: hItem = g_hSDKWeaponSyringeGun;
								case TFClass_Pyro: hItem = g_hSDKWeaponFlamethrower;
								case TFClass_Spy: hItem = g_hSDKWeaponRevolver;
								case TFClass_Engineer: hItem = g_hSDKWeaponShotgunPrimary;
							}
						}
						case WeaponSlot_Secondary:
						{
							switch (class)
							{
								case TFClass_Scout: hItem = g_hSDKWeaponPistolScout;
								case TFClass_Sniper: hItem = g_hSDKWeaponSMG;
								case TFClass_Soldier: hItem = g_hSDKWeaponShotgunSoldier;
								case TFClass_DemoMan: hItem = g_hSDKWeaponStickyLauncher;
								case TFClass_Heavy: hItem = g_hSDKWeaponShotgunHeavy;
								case TFClass_Medic: hItem = g_hSDKWeaponMedigun;
								case TFClass_Pyro: hItem = g_hSDKWeaponShotgunPyro;
								case TFClass_Engineer: hItem = g_hSDKWeaponPistol;
							}
						}
						case WeaponSlot_Melee:
						{
							switch (class)
							{
								case TFClass_Scout: hItem = g_hSDKWeaponBat;
								case TFClass_Sniper: hItem = g_hSDKWeaponKukri;
								case TFClass_Soldier: hItem = g_hSDKWeaponShovel;
								case TFClass_DemoMan: hItem = g_hSDKWeaponBottle;
								case TFClass_Heavy: hItem = g_hSDKWeaponFists;
								case TFClass_Medic: hItem = g_hSDKWeaponBonesaw;
								case TFClass_Pyro: hItem = g_hSDKWeaponFireaxe;
								case TFClass_Spy: hItem = g_hSDKWeaponKnife;
								case TFClass_Engineer: hItem = g_hSDKWeaponWrench;
							}
						}
						case WeaponSlot_InvisWatch:
						{
							switch (class)
							{
								case TFClass_Spy: hItem = g_hSDKWeaponInvis;
							}
						}
					}	
					if (hItem != INVALID_HANDLE)
					{
						int iNewWeapon = TF2Items_GiveNamedItem(iClient, hItem);
						if (IsValidEntity(iNewWeapon)) 
						{
							SetEntProp(iNewWeapon, Prop_Send, "m_bValidatedAttachedEntity", true);
							EquipPlayerWeapon(iClient, iNewWeapon);
						}
					}
				}
				else
				{
					// Balance the weapon
					char atts[32][32];
					int count = ExplodeString(sAttrib, " ; ", atts, 32, 32);
					if (count > 1)
					{
						for (int i = 0; i < count; i+= 2)
							TF2Attrib_SetByDefIndex(iWeapon, StringToInt(atts[i]), StringToFloat(atts[i+1]));
						TF2Attrib_ClearCache(iWeapon);
					}
				}
			}
		}
	}
	
	RequestFrame(Frame_VerifyTeam, GetClientUserId(iClient));
	if (!g_bRoundStarted) return;
	
	Client_ApplyEffects(iClient);
}

public Action Event_PlayerHurt(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (iClient <= 0 || iClient > MaxClients || GetClientTeam(iClient) <= 1) return;
	
	int iDamageAmount = event.GetInt("damageamount");
	
	if (g_clientBoss[iClient].IsValid())
	{
		int iAttacker = GetClientOfUserId(event.GetInt("attacker"));
		if (iAttacker != 0 && iAttacker != iClient)
			g_clientBoss[iClient].iRageDamage += iDamageAmount;
		if (0 < iAttacker <= MaxClients && IsClientInGame(iAttacker) && GetClientTeam(iAttacker) > 1 && !g_clientBoss[iAttacker].IsValid())
		{
			g_iPlayerDamage[iAttacker] += iDamageAmount;
			int iAttackTeam = GetClientTeam(iAttacker);
			
			ArrayList aSpiesAssist = new ArrayList();
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == iAttackTeam && i != iAttacker)
				{
					if (g_iPlayerTotalBackstab[i][iClient] >= 4)
						aSpiesAssist.Push(i);
					
					int iSecondaryWep = GetPlayerWeaponSlot(i, WeaponSlot_Secondary);
					char weaponSecondaryClass[32];
					if (iSecondaryWep >= 0) GetEdictClassname(iSecondaryWep, weaponSecondaryClass, sizeof(weaponSecondaryClass));
					
					//Award damage assit to healers
					if (strcmp(weaponSecondaryClass, "tf_weapon_medigun") == 0)
					{
						int iHealTarget = GetEntPropEnt(iSecondaryWep, Prop_Send, "m_hHealingTarget");
						if (iHealTarget == iAttacker)
							g_iPlayerAssistDamage[i] += iDamageAmount;
					}
				}
			}
			
			int iTotalSpies = aSpiesAssist.Length;
			if (iTotalSpies > 0)
			{
				int iDamageAssit = iDamageAmount/iTotalSpies;
				for (int i = 0; i < iTotalSpies; i++)
				{
					int iSpy = aSpiesAssist.Get(i);
					g_iPlayerAssistDamage[iSpy] += iDamageAssit;
				}
			}
			delete aSpiesAssist;
		}
	}
}

public Action Event_BuffBannerDeployed(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iClient = GetClientOfUserId(event.GetInt("buff_owner"));
	if (iClient <= 0 || iClient > MaxClients || GetClientTeam(iClient) <= 1 || g_clientBoss[iClient].IsValid()) return;
	
	int iBannerType = event.GetInt("buff_type");
	switch (iBannerType)
	{
		case BUFF_BANNER:
		{
			int iRocketLauncher = GetPlayerWeaponSlot(iClient, WeaponSlot_Primary);
			if (iRocketLauncher > MaxClients)
			{
				int iClip = SDK_GetMaxClip(iRocketLauncher);
				if(iClip > 0)
					SetEntProp(iRocketLauncher, Prop_Send, "m_iClip1", iClip+config.LookupInt(g_cvBuffBannerRocketsBonus));
				SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iRocketLauncher);
				
				float flVal = 0.0;
				//The beggar will amplify the effect, and that isn't our goal, detect the attrib and apply a nerf.
				bool bHasAutoFire = (TF2_WeaponFindAttribute(iRocketLauncher, ATTRIB_AUTO_FIRES_FULL_CLIP, flVal) && flVal > 0.0);
				
				TF2Attrib_SetByDefIndex(iRocketLauncher, ATTRIB_FASTER_FIRE_RATE, (bHasAutoFire) ? config.LookupFloat(g_cvBuffBannerRocketLauncherFasterFireRate)+0.4: config.LookupFloat(g_cvBuffBannerRocketLauncherFasterFireRate));
				TF2Attrib_ClearCache(iRocketLauncher);
				CreateTimer(config.LookupFloat(g_cvBuffBannerBonusDuration), Timer_ResetRocketLauncherBonus, EntIndexToEntRef(iRocketLauncher));
			}
		}
		case BATTALION_BACKUP:
		{
			int iPlayerTeam = GetClientTeam(iClient);
			
			int iMaxRevival = config.LookupInt(g_cvBattalionBackupMaxZombieScout);
			int iTotalRevived = 0;
			ArrayList aDeadPlayers = new ArrayList();
			for (int i = 1; i <= MaxClients && iTotalRevived < iMaxRevival; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) > 1 && !IsPlayerAlive(i) && g_iPlayerPreferences[i][PlayerPreference_RevivalSelect])
				{
					if (g_clientBoss[i] != INVALID_BOSS && !g_clientBoss[i].IsMinion) continue; // Can't let dead boss ressurect
					
					aDeadPlayers.Push(i);
					iTotalRevived++;
				}
			}
			
			int iTotalPlayers = aDeadPlayers.Length;
			bool bDucked = (GetEntProp(iClient, Prop_Send, "m_bDucking") || GetEntProp(iClient, Prop_Send, "m_bDucked"));
			float vecPos[3];
			GetClientAbsOrigin(iClient, vecPos);
			
			for (int i = 0; i < iTotalPlayers; i++)
			{
				int iPlayer = aDeadPlayers.Get(i);
				if (g_clientBoss[iPlayer] != INVALID_BOSS)
				{
					g_clientBoss[iPlayer].Destroy();
					g_clientBoss[iPlayer] = INVALID_BOSS;
				}
				
				ChangeClientTeam(iPlayer, iPlayerTeam);
				
				TFClassType desiredClass = TF2_GetPlayerClass(iPlayer);
				if (desiredClass == TFClass_Unknown) desiredClass = view_as<TFClassType>(GetRandomInt(view_as<int>(TFClass_Scout), view_as<int>(TFClass_Engineer)));
				SetEntProp(iPlayer, Prop_Send, "m_iDesiredPlayerClass", desiredClass); // set them their old class as desired class to avoid spam of scouts!
				
				Client_AddFlag(iPlayer, VSH_ZOMBIE);
				TF2_SetPlayerClass(iPlayer, TFClass_Scout);
				TF2_RespawnPlayer(iPlayer);
				
				for (int iSlot = WeaponSlot_Primary; iSlot <= WeaponSlot_InvisWatch; iSlot++)
					TF2_RemoveItemInSlot(iPlayer, iSlot);
				
				int iNewWeapon = TF2Items_GiveNamedItem(iPlayer, g_hSDKWeaponBat);
				SetEntProp(iNewWeapon, Prop_Send, "m_bValidatedAttachedEntity", true);
				EquipPlayerWeapon(iPlayer, iNewWeapon);
		
				if (!bDucked)
					TeleportEntity(iPlayer, vecPos, NULL_VECTOR, NULL_VECTOR);
			}
			
			delete aDeadPlayers;
			
			SetEntPropFloat(iClient, Prop_Send, "m_flRageMeter", 0.0); // Drain the rage
		}
		case CONCHEROR:
		{
			if (config.LookupBool(g_cvConcherorBuffUber))
				RequestFrame(Frame_SoldierConcherorUberBuff, GetClientUserId(iClient));
		}
	}
}

public Action Event_UberDeployed(Event event, const char[] sName, bool bDontBroadcast)
{
	if (!g_bEnabled) return;
	if (g_iTotalRoundPlayed <= 0) return;
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if (iClient <= 0 || iClient > MaxClients || GetClientTeam(iClient) <= 1 || g_clientBoss[iClient].IsValid()) return;
	
	int iSecondaryWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Secondary);
	if (iSecondaryWep > MaxClients)
		RequestFrame(Frame_UberchargeAddCrit, EntIndexToEntRef(iSecondaryWep));
}

public Action Timer_ControlPointUnlockSound(Handle hTimer)
{
	if (!g_bRoundStarted) return;
	if (g_hTimerCPUnlockSound != hTimer) return;
	EmitSoundToAll(CP_UNLOCK_SOUND);
	EmitSoundToAll(CP_UNLOCK_SOUND);
}

public Action Timer_PickBoss(Handle hTimer)
{
	if (g_hTimerPickBoss != hTimer) return;
	
	int iClient = GetClientOfUserId(g_iUserActiveBoss);
	if (0 < iClient <= MaxClients && IsClientInGame(iClient))
	{
		if (!SpecialRound_PickBoss(iClient))
		{
			if (strcmp(g_sNextBossType, "") != 0)
			{
				g_clientBoss[iClient] = CBaseBoss(iClient, g_sNextBossType);
				g_sNextBossType = "";
			}
			else if (GetRandomInt(0,100) <= 5)
			{
				g_clientBoss[iClient] = CBaseBoss(iClient, g_strMiscBossesType[GetRandomInt(0, sizeof(g_strMiscBossesType)-1)]);
			}
			else
			{
				g_clientBoss[iClient] = CBaseBoss(iClient, g_strBossesType[GetRandomInt(0, sizeof(g_strBossesType)-1)]);
			}
		}
		
		// Play boss intro sound
		char sSound[255];
		g_clientBoss[iClient].GetRoundStartSound(sSound, sizeof(sSound));
		
		if (strcmp(sSound, "") != 0)
			BroadcastSoundToTeam(TFTeam_Spectator, sSound);
		
		// Play boss intro music
		g_clientBoss[iClient].GetRoundStartMusic(sSound, sizeof(sSound));
		
		if (strcmp(sSound, "") != 0)
			BroadcastSoundToTeam(TFTeam_Spectator, sSound);
	}
	g_hTimerPickBoss = null;
}

public Action Timer_MusicInitialDelay(Handle hTimer, CBaseBoss boss)
{
	if (g_hTimerBossMusic != hTimer)
		return Plugin_Stop;
	
	if (!boss.IsValid())
	{
		g_hTimerBossMusic = null;
		return Plugin_Stop;
	}
	
	int iClient = boss.Index;
	if (iClient != GetClientOfUserId(g_iUserActiveBoss))
	{
		g_hTimerBossMusic = null;
		return Plugin_Stop;
	}
	
	float flMusicTime, flInitDelay;
	g_clientBoss[iClient].GetMusicInfo(g_sBossMusic, sizeof(g_sBossMusic), flMusicTime, flInitDelay);
	
	if (strcmp(g_sBossMusic, "") != 0)
		EmitSoundToAll(g_sBossMusic);
	
	if (flMusicTime > 0.0)
		g_hTimerBossMusic = CreateTimer(flMusicTime, Timer_Music, boss, TIMER_REPEAT);
	
	return Plugin_Continue;
}

public Action Timer_Music(Handle hTimer, CBaseBoss boss)
{
	if (g_hTimerBossMusic != hTimer)
		return Plugin_Stop;
	if (!boss.IsValid())
	{
		g_hTimerBossMusic = null;
		return Plugin_Stop;
	}
	
	int iClient = boss.Index;
	if (iClient != GetClientOfUserId(g_iUserActiveBoss))
	{
		g_hTimerBossMusic = null;
		return Plugin_Stop;
	}
	
	EmitSoundToAll(g_sBossMusic);
	return Plugin_Continue;
}

public Action Timer_ResetRocketLauncherBonus(Handle hTimer, int iRef)
{
	int iRocketLauncher = EntRefToEntIndex(iRef);
	if (iRocketLauncher > MaxClients)
	{
		int iMaxClip = SDK_GetMaxClip(iRocketLauncher);
		int iCurrentClip = GetEntProp(iRocketLauncher, Prop_Send, "m_iClip1");
		if (iCurrentClip > iMaxClip) iCurrentClip = iMaxClip;
		SetEntProp(iRocketLauncher, Prop_Send, "m_iClip1", iCurrentClip);
		TF2Attrib_RemoveByDefIndex(iRocketLauncher, ATTRIB_FASTER_FIRE_RATE);
	}
}

public Action Timer_EntityCleanup(Handle hTimer, int iRef)
{
	int iEntity = EntRefToEntIndex(iRef);
	if(iEntity > MaxClients)
		AcceptEntityInput(iEntity, "Kill");
	return Plugin_Handled;
}

public void OnClientPutInServer(int iClient)
{
	Client_PutInServer(iClient);
	
	g_clientBoss[iClient] = INVALID_BOSS;
	g_iPlayerDamage[iClient] = 0;
	g_iPlayerAssistDamage[iClient] = 0;
	g_bPlayerTriggerSpecialRound[iClient] = false;
	
	for (int i = 1; i <= TF_MAXPLAYERS; i++)
		g_iPlayerTotalBackstab[iClient][i] = 0;
}

public void OnClientCookiesCached(int iClient)
{
	Queue_OnClientConnect(iClient);
	Preferences_Get(iClient);
}

public void OnClientDisconnect(int iClient)
{
	if (g_clientBoss[iClient].IsValid())
		g_clientBoss[iClient].Destroy();
	
	if (GetClientOfUserId(g_iUserActiveBoss) == iClient)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) > 1)
			{
				if (g_clientBoss[i].IsValid())
				{
					g_iUserActiveBoss = GetClientUserId(i);
					break;
				}
			}
		}
	}
	
	g_clientBoss[iClient] = INVALID_BOSS;
	
	Queue_OnClientDisconnect(iClient);
	Client_Disconnect(iClient);
	Preferences_Save(iClient);
	
	for (int i = 1; i <= TF_MAXPLAYERS; i++)
		g_iPlayerTotalBackstab[iClient][i] = 0;
}

public Action Command_GetCpUnlockTime(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	if (VSH_IsMaker(iClient))
	{
		int iControlPoint = FindEntityByClassname(-1, "team_control_point");
		if (iControlPoint > MaxClients)
		{
			int iCPIndex = GetEntProp(iControlPoint, Prop_Data, "m_iPointIndex");
			int iObjective = TF2_GetObjectiveResource();
			if (iObjective > MaxClients)
			{
				float flUnlockTime = GetEntPropFloat(iObjective, Prop_Send, "m_flUnlockTimes", iCPIndex);
				ReplyToCommand(iClient, "%s %s Cp unlock time: %f", VSH_TAG, VSH_TEXT_COLOR, flUnlockTime);
			}
		}
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "%s %s You do not have permission to use this command.", VSH_TAG, VSH_TEXT_COLOR);
	return Plugin_Handled;
}

public Action Command_SetCpUnlockTime(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iArgs != 1 || iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	if (VSH_IsMaker(iClient))
	{
		int iControlPoint = FindEntityByClassname(-1, "team_control_point");
		if (iControlPoint > MaxClients)
		{
			int iCPIndex = GetEntProp(iControlPoint, Prop_Data, "m_iPointIndex");
			int iObjective = TF2_GetObjectiveResource();
			if (iObjective > MaxClients)
			{
				char sVal[10];
				GetCmdArg(1, sVal, sizeof(sVal));
				float flUnlockTime = StringToFloat(sVal);
				SetEntPropFloat(iObjective, Prop_Send, "m_flUnlockTimes", flUnlockTime+GetGameTime(), iCPIndex);
				ReplyToCommand(iClient, "%s %s Set cp unlock time to %f.", VSH_TAG, VSH_TEXT_COLOR, flUnlockTime);
				
				GameRules_SetPropFloat("m_flCapturePointEnableTime", flUnlockTime+GetGameTime());
			}
		}
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "%s %s You do not have permission to use this command.", VSH_TAG, VSH_TEXT_COLOR);
	return Plugin_Handled;
}

public Action Command_AddQueuePoints(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iArgs != 1 || iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	if (VSH_IsMaker(iClient))
	{
		char sVal[10];
		GetCmdArg(1, sVal, sizeof(sVal));
		Queue_AddPlayerPoints(iClient, StringToInt(sVal));
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "%s %s You do not have permission to use this command.", VSH_TAG, VSH_TEXT_COLOR);
	return Plugin_Handled;
}

public Action Command_ForceSpecialRound(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	
	if (VSH_IsMaker(iClient))
	{
		g_bSpecialRound = true;
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "%s %s You do not have permission to use this command.", VSH_TAG, VSH_TEXT_COLOR);
	return Plugin_Handled;
}

public Action Command_ForceNextBoss(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	
	if (VSH_IsMaker(iClient))
	{
		char sBossType[64];
		GetCmdArgString(sBossType, sizeof(sBossType));
		TrimString(sBossType);
		strcopy(g_sNextBossType, sizeof(g_sNextBossType), sBossType);
		return Plugin_Handled;
	}
	
	ReplyToCommand(iClient, "%s %s You do not have permission to use this command.", VSH_TAG, VSH_TEXT_COLOR);
	return Plugin_Handled;
}

public Action Command_MainMenu(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	DisplayMenu(g_hMenuMain, iClient, 30);
	return Plugin_Handled;
}

public Action Command_HaleNext(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	Panel_DisplayQueue(iClient);
	return Plugin_Handled;
}

public Action Command_Help(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	DisplayMenu(g_hMenuHelp, iClient, 30);
	return Plugin_Handled;
}

public Action Command_Credits(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	DisplayMenu(g_hMenuCredits, iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action Command_Settings(int iClient, int iArgs)
{
	if (!g_bEnabled) return Plugin_Handled;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Handled;
	
	DisplayMenu(g_hMenuSettings, iClient, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int iClient,int &buttons,int &impulse, float vel[3], float angles[3],int &weapon,int &subtype,int &cmdnum,int &tickcount,int &seed,int mouse[2])
{
	if (!g_bEnabled) return Plugin_Continue;
	if (g_iTotalRoundPlayed <= 0) return Plugin_Continue;
	if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return Plugin_Continue;
	
	Action finalAction = Plugin_Continue;
	
	int iTeam = GetClientTeam(iClient);
	if (iTeam > 1)
	{
		if (g_bFreezeMovements)
		{
			// Disallow moving during pre round phase
			vel = NULL_VECTOR;
			finalAction = Plugin_Changed;
		}
		
		if (g_flTeamInvertedMoveControlsTime[iTeam] != 0.0 && g_flTeamInvertedMoveControlsTime[iTeam] > GetGameTime())
		{
			/*bool bInAttack1 = !!((buttons & IN_ATTACK));
			bool bInAttack2 = !!((buttons & IN_ATTACK2));
			
			bool bInJump = !!((buttons & IN_JUMP));
			bool bInDuck = !!((buttons & IN_DUCK));
			
			bool bForward = !!((buttons & IN_FORWARD));
			bool bBack = !!((buttons & IN_BACK));
			
			bool bRight = !!((buttons & IN_RIGHT));
			bool bLeft = !!((buttons & IN_LEFT));
			
			bool bMoveRight = !!((buttons & IN_MOVERIGHT));
			bool bMoveLeft = !!((buttons & IN_MOVELEFT));
			
			if (bInAttack1)
			{
				buttons &= ~IN_ATTACK;
				buttons |= IN_ATTACK2;
			}
			if (bInAttack2)
			{
				buttons &= ~IN_ATTACK2;
				buttons |= IN_ATTACK;
			}
			
			if (bInJump)
			{
				buttons &= ~IN_JUMP;
				buttons |= IN_DUCK;
			}
			if (bInDuck)
			{
				buttons &= ~IN_DUCK;
				buttons |= IN_JUMP;
			}
			
			if (bForward)
			{
				buttons &= ~IN_FORWARD;
				buttons |= IN_BACK;
			}
			if (bBack)
			{
				buttons &= ~IN_BACK;
				buttons |= IN_FORWARD;
			}
			
			if (bRight)
			{
				buttons &= ~IN_RIGHT;
				buttons |= IN_LEFT;
			}
			if (bLeft)
			{
				buttons &= ~IN_LEFT;
				buttons |= IN_RIGHT;
			}
			
			if (bMoveRight)
			{
				buttons &= ~IN_MOVERIGHT;
				buttons |= IN_MOVELEFT;
			}
			if (bMoveLeft)
			{
				buttons &= ~IN_MOVELEFT;
				buttons |= IN_MOVERIGHT;
			}
			finalAction = Plugin_Changed;*/
			
			vel[0] = -vel[0];
			vel[1] = -vel[1];
			
			PrintCenterText(iClient, "Your controls are reversed!");
		}
	}
	
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		Action Actionbutton = Client_OnButton(iClient, button);
		if (Actionbutton != Plugin_Continue)
		{
			if (finalAction == Plugin_Changed)
				finalAction = Actionbutton;
			else if (finalAction == Plugin_Handled && Actionbutton == Plugin_Stop)
				finalAction = Plugin_Stop;
		}
		
		if ((buttons & button))
		{
			if (!(g_iPlayerLastButtons[iClient] & button))
				Client_OnButtonPress(iClient, button);
			else
				Client_OnButtonHold(iClient, button);
		}
		else if ((g_iPlayerLastButtons[iClient] & button))
		{
			Client_OnButtonRelease(iClient, button);
		}
	}
	
	g_iPlayerLastButtons[iClient] = buttons;
	return finalAction;
}

public Action Boss_OnTouch(int iEntity, int iToucher)
{
	//Don't allow bosses to pick up health kit or ammo pack
	if (iToucher >= 1 && iToucher <= MaxClients && IsClientInGame(iToucher) && IsPlayerAlive(iToucher) && g_clientBoss[iToucher].IsValid())
		return Plugin_Handled;
	return Plugin_Continue;
}

public Action CaptureArea_OnTouch(int iEntity, int iToucher)
{
	if (iToucher >= 1 && iToucher <= MaxClients && IsClientInGame(iToucher) && Client_HasFlag(iToucher, VSH_ZOMBIE))
		return Plugin_Handled; //Don't allow zombies to cap
	return Plugin_Continue;
}

public Action CWeaponMedigun_IsAllowedToHealTarget(int iMedigun, int iHealTarget, bool &bOriginalResult)
{
	int iOwner = GetEntPropEnt(iMedigun, Prop_Send, "m_hOwnerEntity");
	if (MaxClients >= iOwner > 0 && IsClientInGame(iOwner))
	{
		if (2048 > iHealTarget > MaxClients)
		{
			char classname[64];
			GetEdictClassname(iHealTarget, classname, sizeof(classname));
			if (strcmp(classname, "obj_sentrygun") == 0 || strcmp(classname, "obj_dispenser") == 0 || strcmp(classname, "obj_teleporter") == 0)
			{
				if (GetEntProp(iHealTarget, Prop_Send, "m_iTeamNum") == GetClientTeam(iOwner))
				{
					TF2Attrib_SetByDefIndex(iHealTarget, ATTRIB_UBER_RATE_BONUS, 0.001);
					TF2Attrib_ClearCache(iHealTarget);
					bOriginalResult = true;
					return Plugin_Changed;
				}
			}
		}
		TF2Attrib_SetByDefIndex(iHealTarget, ATTRIB_UBER_RATE_BONUS, 1.0);
		TF2Attrib_ClearCache(iHealTarget);
	}
	return Plugin_Continue;
}

public Action CTFPlayer_GetClassEyeHeight(int iClient, float vecSetPos[3])
{
	if (g_clientBoss[iClient].IsValid())
	{
		g_clientBoss[iClient].GetEyeHeigth(vecSetPos);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void TF2_OnConditionRemoved(int iClient, TFCond cond)
{
	if (cond == TFCond_CritCola && !g_clientBoss[iClient].IsValid())
	{
		int iSecondaryWep = GetPlayerWeaponSlot(iClient, WeaponSlot_Secondary);
		if (iSecondaryWep > MaxClients)
		{
			char sWeaponClass[64];
			GetEntityClassname(iSecondaryWep, sWeaponClass, sizeof(sWeaponClass));
			if (config.LookupBool(g_cvCritColaEndBuffSlowdown) && strcmp(sWeaponClass, "tf_weapon_lunchbox_drink") == 0)
				TF2_StunPlayer(iClient, 3.0, 0.5, TF_STUNFLAG_SLOWDOWN, 0);
		}
	}
}

public Action TF2_CalcIsAttackCritical(int iClient, int iWeapon, char[] sWepClassName, bool &bResult)
{
	if (!g_clientBoss[iClient].IsValid())
	{
		if (strncmp(sWepClassName, "tf_weapon_rocketlauncher", 24) == 0)
		{
			float eyePos[3], eyeAng[3];
			GetClientEyePosition(iClient, eyePos);
			GetClientEyeAngles(iClient, eyeAng);
			
			Handle hTrace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRay_DontHitEntity, iClient);
			int iCollisionEntity = TR_GetEntityIndex(hTrace);
			delete hTrace;
			
			if (0 < iCollisionEntity <= MaxClients && IsClientInGame(iCollisionEntity) && g_clientBoss[iCollisionEntity].IsValid())
			{
				bResult = true;
				return Plugin_Changed;
			}
		}
	}
	else
	{
		//Disable random crit for bosses
		bResult = false;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!g_bEnabled) return Plugin_Continue;

	if (g_clientBoss[client].IsValid() && strncmp(classname, "tf_wearable", 11) == 0)
		if (!g_clientBoss[client].IsCosmeticBlocked(iItemDefinitionIndex))
			return Plugin_Handled;
	return Plugin_Continue;
}

public Action NormalSoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (0 < entity <= MaxClients && IsClientInGame(entity))
	{
		if (g_clientBoss[entity].IsValid())
		{
			return g_clientBoss[entity].OnSoundPlayed(clients, numClients, sample, channel, volume, level, pitch, flags, soundEntry, seed);
		}
	}
	return Plugin_Continue;
}

bool ControlPoint_Unlock(float flUnlockTime = 6.0)
{
	if (!g_bRoundStarted) return false;
	
	float flCurrentUnlockTime = GameRules_GetPropFloat("m_flCapturePointEnableTime");
	if ((GetGameTime()+flUnlockTime)-flCurrentUnlockTime < 0.0)//The cap isn't being unlocked, or the new given time is shorter so we can initiate one
	{
		GameRules_SetPropFloat("m_flCapturePointEnableTime", GetGameTime()+6.0);
		g_hTimerCPUnlockSound = CreateTimer(6.0, Timer_ControlPointUnlockSound);
		return true;
	}
	return false;
}

void SDK_Init()
{
	Handle hGameData = LoadGameConfigFile("sdkhooks.games");
	if (hGameData == null) SetFailState("Could not find sdkhooks.games gamedata!");

	//This function is used to control player's max health
	int iOffset = GameConfGetOffset(hGameData, "GetMaxHealth");
	g_hHookGetMaxHealth = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, Client_GetMaxHealth);
	if (g_hHookGetMaxHealth == null) LogMessage("Failed to create hook: CTFPlayer::GetMaxHealth!");
	
	//This function is used to retreive player's max health
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "GetMaxHealth");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKGetMaxHealth = EndPrepSDKCall();
	if(g_hSDKGetMaxHealth == null)
	{
		LogMessage("Failed to create call: CTFPlayer::GetMaxHealth!");
	}
	
	delete hGameData;
	
	hGameData = LoadGameConfigFile("sm-tf2.games");
	if (hGameData == null) SetFailState("Could not find sm-tf2.games gamedata!");
	
	int iRemoveWearableOffset = GameConfGetOffset(hGameData, "RemoveWearable");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(iRemoveWearableOffset);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKRemoveWearable = EndPrepSDKCall();
	if(g_hSDKRemoveWearable == null)
	{
		LogMessage("Failed to create call: CBasePlayer::RemoveWearable!");
	}
	
	// This call allows us to equip a wearable
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(iRemoveWearableOffset-1);//In theory the virtual function for EquipWearable is rigth before RemoveWearable, 
													//if it's always true (valve don't put a new function between these two), then we can use SM auto update offset for RemoveWearable and find EquipWearable from it
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKEquipWearable = EndPrepSDKCall();
	if(g_hSDKEquipWearable == null)
	{
		LogMessage("Failed to create call: CBasePlayer::EquipWearable!");
	}

	delete hGameData;
	
	hGameData = LoadGameConfigFile("vsh");
	if (hGameData == null) SetFailState("Could not find vsh gamedata!");
	
	//This function is used to play the blocked knife animation
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CTFWeaponBase::SendWeaponAnim");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKSendWeaponAnim = EndPrepSDKCall();
	if(g_hSDKSendWeaponAnim == null)
	{
		LogMessage("Failed to create call: CTFWeaponBase::SendWeaponAnim!");
	}
	
	// This call gets the maximum clip 1 for a given weapon
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "CTFWeaponBase::GetMaxClip1");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKGetMaxClip = EndPrepSDKCall();
	if(g_hSDKGetMaxClip == null)
	{
		LogMessage("Failed to create call: CTFWeaponBase::GetMaxClip1!");
	}
	
	// This call gets wearable equipped in loadout slots
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTFPlayer::GetEquippedWearableForLoadoutSlot");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKGetEquippedWearable = EndPrepSDKCall();
	if(g_hSDKGetEquippedWearable == null)
	{
		LogMessage("Failed to create call: CTFPlayer::GetEquippedWearableForLoadoutSlot!");
	}
	
	iOffset = GameConfGetOffset(hGameData, "CBaseEntity::ShouldTransmit");
	g_hHookShouldTransmit = DHookCreate(iOffset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity, Hook_EntityShouldTransmit);
	if (g_hHookShouldTransmit == null)
		LogMessage("Failed to create hook: CBaseEntity::ShouldTransmit!");
	else
		DHookAddParam(g_hHookShouldTransmit, HookParamType_ObjectPtr);
	
	delete hGameData;
}

void SDK_SendWeaponAnim(int weapon, int anim)
{
	if (g_hSDKSendWeaponAnim != null)
		SDKCall(g_hSDKSendWeaponAnim, weapon, anim);
}


int SDK_GetMaxClip(int iWeapon)
{
	if(g_hSDKGetMaxClip != null)
		return SDKCall(g_hSDKGetMaxClip, iWeapon);
	return -1;
}

int SDK_GetMaxHealth(int iClient)
{
	if (g_hSDKGetMaxHealth != null)
		return SDKCall(g_hSDKGetMaxHealth, iClient);
	return 0;
}

void SDK_RemoveWearable(int client, int iWearable)
{
	if(g_hSDKRemoveWearable != null)
		SDKCall(g_hSDKRemoveWearable, client, iWearable);
}

int SDK_GetEquippedWearable(int client, int iSlot)
{
	if(g_hSDKGetEquippedWearable != null)
		return SDKCall(g_hSDKGetEquippedWearable, client, iSlot);
	return -1;
}

void SDK_EquipWearable(int client, int iWearable)
{
	if(g_hSDKEquipWearable != null)
		SDKCall(g_hSDKEquipWearable, client, iWearable);
}

public MRESReturn Hook_EntityShouldTransmit(int entity, Handle hReturn, Handle hParams)
{
	DHookSetReturn(hReturn, FL_EDICT_ALWAYS);
	return MRES_Supercede;
}

public bool TraceRay_DontHitEntity(int iEntity, int contentsMask, int data)
{
	if (iEntity == data) return false;
	
	return true;
}

public bool TraceRay_DontHitPlayers(int entity, int mask, any data)
{
	if (entity > 0 && entity <= MaxClients) return false;
	return true;
}

stock void TF2_ForceTeamJoin(int iClient, int iTeam)
{
	TFClassType class = TF2_GetPlayerClass(iClient);
	if (class == TFClass_Unknown)
	{
		// Player hasn't chosen a class. Choose one for him.
		TF2_SetPlayerClass(iClient, view_as<TFClassType>(GetRandomInt(1, 9)), true, true);
	}
	
	SetEntProp(iClient, Prop_Send, "m_lifeState", LifeState_Dead);
	ChangeClientTeam(iClient, iTeam);
	SetEntProp(iClient, Prop_Send, "m_lifeState", LifeState_Alive);
	
	TF2_RespawnPlayer(iClient);
}

stock int TF2_GetTeamAlivePlayers(int iTeam)
{
	int iAlive = 0;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) && IsPlayerAlive(i))
			iAlive++;
	return iAlive;
}

stock int TF2_GetObjectiveResource()
{
	static iRefObj = 0;
	
	if (iRefObj != 0)
	{
		int iObj = EntRefToEntIndex(iRefObj);
		if (iObj > MaxClients)
			return iObj;
		
		iRefObj = 0;
	}

	int iObj = FindEntityByClassname(MaxClients+1, "tf_objective_resource");
	if(iObj > MaxClients)
		iRefObj = EntIndexToEntRef(iObj);

	return iObj;
}

stock int TF2_CreateGlow(int iEnt, int iColor[4])
{
	char oldEntName[64];
	GetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "entity_glow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	SetEntPropString(iEnt, Prop_Data, "m_iName", oldEntName);
	
	SetVariantColor(iColor);
	AcceptEntityInput(ent, "SetGlowColor");
	
	SetVariantString("!activator");
	AcceptEntityInput(ent, "SetParent", iEnt);

	return ent;
}

stock bool TF2_FindAttribute(int iClient, int iAttrib, float &flVal)
{
	Address addAttrib = TF2Attrib_GetByDefIndex(iClient, iAttrib);
	if (addAttrib != Address_Null)
	{
		flVal = TF2Attrib_GetValue(addAttrib);
		return true;
	}
	return false;
}

stock bool TF2_WeaponFindAttribute(int iWeapon, int iAttrib, float &flVal)
{
	Address addAttrib = TF2Attrib_GetByDefIndex(iWeapon, iAttrib);
	if (addAttrib == Address_Null)
	{
		int iItemDefIndex = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
		int iAttributes[16];
		float flAttribValues[16];
		
		int iMaxAttrib = TF2Attrib_GetStaticAttribs(iItemDefIndex, iAttributes, flAttribValues);
		for (int i = 0; i < iMaxAttrib; i++)
		{
			if (iAttributes[i] == iAttrib)
			{
				flVal = flAttribValues[i];
				return true;
			}
		}
		return false;
	}
	flVal = TF2Attrib_GetValue(addAttrib);
	return true;
}

stock bool TF2_WeaponCanHaveRevengeCrits(int weapon)
{
	float flVal = 0.0;
	if (TF2_WeaponFindAttribute(weapon, ATTRIB_SAPPER_KILLS_CRIT, flVal) && flVal > 0.0)
		return true;
	flVal = 0.0;
	if (TF2_WeaponFindAttribute(weapon, ATTRIB_EXTINGUISH_REVENGE, flVal) && flVal > 0.0)
		return true;
	flVal = 0.0;
	if (TF2_WeaponFindAttribute(weapon, ATTRIB_SENTRYKILLED_REVENGE, flVal) && flVal > 0.0)
		return true;
	return false;
}

stock bool TF2_IsUbercharged(int client)
{
	return (TF2_IsPlayerInCondition(client, TFCond_Ubercharged) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargeFading) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedOnTakeDamage) ||
		TF2_IsPlayerInCondition(client, TFCond_UberchargedCanteen));
}

stock bool TF2_IsInvisible(int client)
{
	return ((TF2_IsPlayerInCondition(client, TFCond_Cloaked) ||
		TF2_IsPlayerInCondition(client, TFCond_DeadRingered) ||
		TF2_IsPlayerInCondition(client, TFCond_Stealthed))
		&& !TF2_IsPlayerInCondition(client, TFCond_StealthedUserBuffFade)
		&& !TF2_IsPlayerInCondition(client, TFCond_CloakFlicker));
}

stock void TF2_RemoveItemInSlot(int client, int slot)
{
	TF2_RemoveWeaponSlot(client, slot);
	
	int iWearable = SDK_GetEquippedWearable(client, slot);
	if (iWearable > MaxClients)
	{
		SDK_RemoveWearable(client, iWearable);
		AcceptEntityInput(iWearable, "Kill");
	}
}

stock Handle PrepareItemHandle(char[] classname,int index,int level,int quality, char[] att)
{
	Handle hItem = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION | PRESERVE_ATTRIBUTES);
	TF2Items_SetClassname(hItem, classname);
	TF2Items_SetItemIndex(hItem, index);
	TF2Items_SetLevel(hItem, level);
	TF2Items_SetQuality(hItem, quality);
	
	// Set attributes.
	char atts[32][32];
	int count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 1)
	{
		TF2Items_SetNumAttributes(hItem, count / 2);
		int i2 = 0;
		for (int i = 0; i < count; i+= 2)
		{
			TF2Items_SetAttribute(hItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hItem, 0);
	}
	
	return hItem;
}

stock void TF2_Explode(int iAttacker = -1, float flPos[3], float flDamage, float flRadius, const char[] strParticle, const char[] strSound)
{
	int iBomb = CreateEntityByName("tf_generic_bomb");
	DispatchKeyValueVector(iBomb, "origin", flPos);
	DispatchKeyValueFloat(iBomb, "damage", flDamage);
	DispatchKeyValueFloat(iBomb, "radius", flRadius);
	DispatchKeyValue(iBomb, "health", "1");
	DispatchKeyValue(iBomb, "explode_particle", strParticle);
	DispatchKeyValue(iBomb, "sound", strSound);
	DispatchSpawn(iBomb);

	if (iAttacker == -1)
		AcceptEntityInput(iBomb, "Detonate");
	else
		SDKHooks_TakeDamage(iBomb, 0, iAttacker, 9999.0);
}

stock int TF2_CreateAndEquipFakeModel(int iClient)
{
	Handle hWearable = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);

	if (hWearable == INVALID_HANDLE)
	return -1;

	TF2Items_SetClassname(hWearable, "tf_wearable");
	TF2Items_SetItemIndex(hWearable, 5023);
	TF2Items_SetLevel(hWearable, 50);
	TF2Items_SetQuality(hWearable, 6);
	
	int iWearable = TF2Items_GiveNamedItem(iClient, hWearable);
	delete hWearable;
	if (IsValidEdict(iWearable))
	{
		SetEntProp(iWearable, Prop_Send, "m_bValidatedAttachedEntity", true);
		SDK_EquipWearable(iClient, iWearable);
		return iWearable;
	}

	return -1;
}

stock int VSH_GetTeamCount(int iTeam, bool bAlive, bool bBoss, bool bMinion)
{
	int iTotalCount = 0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == iTeam)
		{
			if (bAlive && !IsPlayerAlive(i)) continue;
			if (bBoss && g_clientBoss[i] == INVALID_BOSS) continue;
			if (bMinion && (g_clientBoss[i] == INVALID_BOSS || !g_clientBoss[i].IsMinion)) continue;
			
			iTotalCount++;
		}
	}
	return iTotalCount;
}

stock int VSH_IsMaker(int iClient)
{
	char auth[32];
	GetClientAuthId(iClient, AuthId_Steam3, auth, sizeof(auth));
	return (strcmp(auth, "[U:1:99409844]") == 0 || strcmp(auth, "[U:1:81108435]") == 0 || CheckCommandAccess(iClient, "vsh_cmd_access", ADMFLAG_ROOT));
}

stock void VSH_DisplayArrow(float vecPos[3], float vecAng, int iColor[4], bool bSendToAll = true, int iRecipients[TF_MAXPLAYERS+1] = { 0, ... }, int iTotalCount = 0)
{
	float vecRight[3], vecRight2[3], vecLeft[3], vecLeft2[3];
	
	float flDist = 25.0;
	
	float flX = flDist*Cosine(vecAng);
	float flY = flDist*Sine(vecAng);
	
	float flX2 = flDist*Cosine(vecAng+PI);
	float flY2 = flDist*Sine(vecAng+PI);
	
	vecRight[0] = vecPos[0] + flX;
	vecRight[1] = vecPos[1] + flY;
	vecRight[2] = vecPos[2] + 30.0;
	
	vecLeft[0] = vecPos[0] + flX2;
	vecLeft[1] = vecPos[1] + flY2;
	vecLeft[2] = vecPos[2] + 30.0;
	
	vecRight2[0] = vecPos[0] + flX/2.0;
	vecRight2[1] = vecPos[1] + flY/2.0;
	vecRight2[2] = vecPos[2] + 70.0;
	
	vecLeft2[0] = vecPos[0] + flX2/2.0;
	vecLeft2[1] = vecPos[1] + flY2/2.0;
	vecLeft2[2] = vecPos[2] + 70.0;
	
	TE_SetupBeamPoints(vecPos, vecRight, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	TE_SetupBeamPoints(vecPos, vecLeft, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	
	float vecTemp[3];
	vecTemp = vecRight2;
	vecTemp[2] = vecRight[2];
	TE_SetupBeamPoints(vecRight, vecTemp, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	TE_SetupBeamPoints(vecTemp, vecRight2, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	
	vecTemp = vecLeft2;
	vecTemp[2] = vecLeft[2];
	TE_SetupBeamPoints(vecLeft, vecTemp, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	TE_SetupBeamPoints(vecTemp, vecLeft2, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
	
	TE_SetupBeamPoints(vecRight2, vecLeft2, BEAM_MODEL_INDEX, BEAM_MODEL_INDEX, 0, 30, 0.1, 1.0, 1.0, 1, 0.0, iColor, 30);
	if (bSendToAll)
		TE_SendToAll();
	else
		TE_Send(iRecipients, iTotalCount, 0.0);
}

stock void VSH_StopBossMusic()
{
	g_hTimerBossMusic = null;
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			StopSound(i, SNDCHAN_AUTO, g_sBossMusic);
}

stock void BroadcastSoundToTeam(int team, const char[] strSound)
{
	switch(team)
	{
		case TFTeam_Red, TFTeam_Blue: for(int i=1; i<=MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team) ClientCommand(i, "playgamesound %s", strSound);
		default: for(int i=1; i<=MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i)) ClientCommand(i, "playgamesound %s", strSound);
	}
}

stock void PrepareSound(const char[] sSoundPath)
{
	PrecacheSound(sSoundPath, true);
	char s[PLATFORM_MAX_PATH];
	Format(s, sizeof(s), "sound/%s", sSoundPath);
	AddFileToDownloadsTable(s);
}

stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;
	if (particleEffectNames == INVALID_STRING_TABLE) 
	{
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) 
		{
			return INVALID_STRING_INDEX;
		}
	}

	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX) 
	{
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) 
		{
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];
	int numStrings = GetStringTableNumStrings(tableidx);
	for (int i = 0; i < numStrings; i++)
	{
		ReadStringTable(tableidx, i, buf, sizeof(buf));
		if (StrEqual(buf, str)) 
		{
			return i;
		}
	}
	
	return INVALID_STRING_INDEX;
}

stock float AngleNormalize(float angle)
{
	while (angle > PI) angle -= PI;
	while (angle < -PI) angle += PI;
	return angle;
}

void UTIL_ScreenShake(float center[3], float amplitude, float frequency, float duration, float radius, int command, bool airShake)
{
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (!airShake && command == Shake_Start && !(GetEntityFlags(i) && FL_ONGROUND)) continue;

			float playerPos[3];
			GetClientAbsOrigin(i, playerPos);

			float localAmplitude = ComputeShakeAmplitude(center, playerPos, amplitude, radius);

			if (localAmplitude < 0.0) continue;

			if (localAmplitude > 0 || command == Shake_Stop)
			{
				Handle msg = StartMessageOne("Shake", i, USERMSG_RELIABLE);
				if(msg != null)
				{
					BfWriteByte(msg, command);
					BfWriteFloat(msg, localAmplitude);
					BfWriteFloat(msg, frequency);
					BfWriteFloat(msg, duration);

					EndMessage();
				}
			}
		}
	}
}

float ComputeShakeAmplitude(float center[3], float playerPos[3], float amplitude, float radius)
{
	if(radius <= 0.0) return amplitude;

	float localAmplitude = -1.0;
	float delta[3];
	SubtractVectors(center, playerPos, delta);
	float distance = GetVectorLength(delta);

	if(distance <= radius)
	{
		float perc = 1.0 - (distance / radius);
		localAmplitude = amplitude * perc;
	}

	return localAmplitude;
}
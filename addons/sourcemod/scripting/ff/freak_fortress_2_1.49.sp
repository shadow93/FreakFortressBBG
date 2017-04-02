 /*
---------------- CUSTOM FORK FOR BIG BANG GAMERS BY SHADoW NiNE TR3S -------------------
   ___                     _        ___               _                           ____  
  / __\ _ __   ___   __ _ | | __   / __\  ___   _ __ | |_  _ __   ___  ___  ___  |___ \ 
 / _\  | '__| / _ \ / _` || |/ /  / _\   / _ \ | '__|| __|| '__| / _ \/ __|/ __|   __) |
/ /    | |   |  __/| (_| ||   <  / /    | (_) || |   | |_ | |   |  __/\__ \\__ \  / __/ 
\/     |_|    \___| \__,_||_|\_\ \/      \___/ |_|    \__||_|    \___||___/|___/ |_____|

            By Rainbolt Dash (Eggman): programmer, modeler, mapper, painter.
            
                            Author of Demoman The Pirate:
                        http://www.randomfortress.ru/thepirate/
            
                        And one of two creators of Floral Defence:
                    http://www.polycount.com/forum/showthread.php?t=73688
                    
                            And author of VS Saxton Hale Mode

                                    Plugin Thread:
                    http://forums.alliedmods.net/showthread.php?t=182108

     Notoriously famous for creating plugins with terrible code and then abandoning them.
     
        Updated by Otokiru, Powerlord, and RavensBro, Wliu, Chris, Lawd, and Carge
        
                                        VSH End:
    FlaminSarge - He makes cool things. He improves on terrible things until they're good.
    
    Chdata - A Hale enthusiast and a coder. An Integrated Data Sentient Entity. 
             Notorious for spamming SHADoW's chat with frogs.
    
    nergal - Added some very nice features to the plugin and fixed important bugs.
----------------------------------------------------------------------------------------
*/

#pragma semicolon 1

#include <sourcemod>
#include <freak_fortress_2>
#include <freak_fortress_2_extras>
#include <adt_array>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <morecolors>
#include <tf2items>
#include <clientprefs>
#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#tryinclude <tf2attributes>
#tryinclude <updater>
#tryinclude <nativevotes>
#define REQUIRE_PLUGIN

#define FILECHECK_ENABLED
#define LOGERRORS_ENABLED
/*
    This fork uses a different versioning system
    as opposed to the public FF2 versioning system
*/
#define FORK_MAJOR_REVISION "1"
#define FORK_MINOR_REVISION "49"
#define FORK_SUB_REVISION    "BETA"

#if !defined FORK_SUB_REVISION
    #define PLUGIN_VERSION FORK_MAJOR_REVISION..."."...FORK_MINOR_REVISION
#else
    #define PLUGIN_VERSION FORK_MAJOR_REVISION..."."...FORK_MINOR_REVISION..." "...FORK_SUB_REVISION
#endif

/*
    And now, let's report its version as the latest public FF2 version
    for subplugins or plugins that uses the FF2_GetFF2Version native.
*/
#define MAJOR_REVISION "1"
#define MINOR_REVISION "10"
#define STABLE_REVISION "10"

#define MaxEntities 2048
#define MaxBosses 768
#define MaxAbilities 96

#define HEALTHBAR_CLASS "monster_resource"
#define HEALTHBAR_PROPERTY "m_iBossHealthPercentageByte"
#define HEALTHBAR_MAX 255
#define MONOCULUS "eyeball_boss"

#define INACTIVE 100000000.0

#define UPDATE_URL "http://www.shadow93.net/ff2/update.txt"

#define TF_MAX_PLAYERS          34             //  Sourcemod supports up to 64 players? Too bad TF2 doesn't. 33 player server +1 for 0 (console/world)

#define ConfigPath "configs/freak_fortress_2"
#define DataPath "data/freak_fortress_2"
#define CharsetCFG "characters.cfg"
#define DoorCFG "doors.cfg"
#define MapCFG "maps.cfg"
#define WeaponCFG "weapons.cfg"
#define SpawnTeleportCFG "spawn_teleport.cfg"
#define SpawnTeleportBlacklistCFG "spawn_teleport_blacklist.cfg"
#define FF2BossesLog "logs/freak_fortress_2/ff2_bosses.log"
#define FF2Log "logs/freak_fortress_2/freak_fortress_2.log"
#define ChangeLog "ff2_changelog.txt"
#define CPGameData "cp_pct"

bool IsNextBoss[MAXPLAYERS+1]=false;
bool minimalHUD[MAXPLAYERS+1]=false;
int showtip[MAXPLAYERS+1][4];
int oldTeam[MAX_EDICTS];

// Config file paths
char bLog[256], eLog[256];
float shDmgReduction[MAXPLAYERS+1];

#if defined _steamtools_included
bool steamtools=false;
#endif

#if defined _tf2attributes_included
bool tf2attributes=false;
#endif

bool makeScroll = false;

int capTeam;
Handle SDKGetCPPct; 
bool useCPvalue=false;

int currentBossTeam;

new RPSWinner;
new bool:blueBoss;
new bool:isCapping=false;
new bool:smac=false;
new MercTeam=2;
new BossTeam=3;
new playing;
new healthcheckused;
new LivingMinions;
new LivingMercs;
new LivingBosses;
new RoundCount;
new TeamRoundCounter;
new characterIdx[MAXPLAYERS+1];
new Incoming[MAXPLAYERS+1];

new Damage[MAXPLAYERS+1];
new curHelp[MAXPLAYERS+1];
new uberTarget[MAXPLAYERS+1];
new shield[MAXPLAYERS+1];
new detonations[MAXPLAYERS+1];
new GoombaCount[MAXPLAYERS+1];
new airstab[MAXPLAYERS+1];
new FF2Flags[MAXPLAYERS+1];

new Float:shieldHP[MAXPLAYERS+1];

new String:currentBGM[MAXPLAYERS+1][PLATFORM_MAX_PATH];
new bool:nomusic=false;

new Boss[MAXPLAYERS+1];
new BossHealthMax[MAXPLAYERS+1];
new BossHealth[MAXPLAYERS+1];
new BossHealthLast[MAXPLAYERS+1];
new BossLives[MAXPLAYERS+1];
new BossLivesMax[MAXPLAYERS+1];
new BossRageDamage[MAXPLAYERS+1];
new Float:BossCharge[MAXPLAYERS+1][8];
new Float:Stabbed[MAXPLAYERS+1];
new Float:Marketed[MAXPLAYERS+1];
new Float:KSpreeTimer[MAXPLAYERS+1];
new KSpreeCount[MAXPLAYERS+1];
new Float:GlowTimer[MAXPLAYERS+1];
new shortname[MAXPLAYERS+1];
char timeDisplay[13];
new bool:roundOvertime=false;
new bool:UnBonkSlowDown[MAXPLAYERS+1]=false;
new bool:emitRageSound[MAXPLAYERS+1];
new bool:MapBlackListed=false;
new bool:bSpawnTeleOnTriggerHurt = false;
new timeleft;

// Timer replacements
float CalcQueuePointsAt;
float CheckAlivePlayersAt;
float StartFF2RoundAt;
float ShowToolTipsAt;
float AnnounceAt;
float NineThousandAt;
float EnableCapAt;
float CheckDoorsAt;
float UpdateRoundTickAt;
float DrawGameTimerAt;
float DisplayMessageAt;
float StartBossAt;
float StartResponseAt;
float DisplayNextBossPanelAt;
float MoveAt;

// Boss & Client Timer Replacements;
float FF2BossTick;
float FF2ClientTick;

// Client-based timer replacements
float PlayBGMAt[MAXPLAYERS+1]=INACTIVE;
float PrepareMercAt[MAXPLAYERS+1]=INACTIVE;
float CheckMinHudAt[MAXPLAYERS+1]=INACTIVE;
float InspectPlayerInventoryAt[MAXPLAYERS+1]=INACTIVE;
float KillRPSLosingBossAt[MAXPLAYERS+1]=INACTIVE;

// music ID
new cursongId[MAXPLAYERS+1]=1;

// ConVars
ConVar cvarVersion;
ConVar cvarPointDelay;
ConVar cvarAnnounce;
ConVar cvarEnabled;
ConVar cvarAliveToEnable;
ConVar cvarPointType;
ConVar cvarCrits;
ConVar cvarFirstRound;  //DEPRECATED
ConVar cvarArenaRounds;
ConVar cvarCircuitStun;
ConVar cvarCountdownPlayers;
ConVar cvarCountdownTime;
ConVar cvarCountdownHealth;
ConVar cvarCountdownResult;
ConVar cvarCountdownOverTime;
ConVar cvarEnableEurekaEffect;
ConVar cvarForceBossTeam;
ConVar cvarHealthBar;
ConVar cvarLastPlayerGlow;
ConVar cvarBossTeleporter;
ConVar cvarBossSuicide;
ConVar cvarShieldCrits;
ConVar cvarCaberDetonations;
ConVar cvarDamageToTele;
ConVar cvarBossRTD;
ConVar cvarGoombaDamage;
ConVar cvarGoombaRebound;
ConVar cvarMedievalDivider;
ConVar cvarUpdater;
ConVar cvarDebug;
ConVar cvarDevelopMode;
ConVar cvarSpellBooks;
ConVar cvarRPSQueuePoints;
ConVar cvarSubtractRageOnJarate;
ConVar cvarDefaultMoveSpeed;
ConVar cvarDefaultRageDamage;
ConVar cvarDefaultRageDist;
ConVar cvarDmg2KStreak;
ConVar cvarDefaultHealthFormula;
ConVar cvarHardModifier;
ConVar cvarLunaticModifier;
ConVar cvarInsaneModifier;
ConVar cvarNextmap;

new Handle:FF2Cookies;

new Handle:FF2Cookie[10];
enum
{
    Cookie_DisplayInfo=0,
    Cookie_QueuePoints,
    Cookie_ToggleMusic,
    Cookie_ToggleVoice,
    Cookie_BossToggle,
    Cookie_CompanionToggle,
    Cookie_Difficulty,
    Cookie_SkillGroup
}

enum SoundException
{
    SoundException_BossMusic=0,
    SoundException_BossVoice
}

new Handle:jumpHUD;
new Handle:cloakHUD;
new Handle:rageHUD;
new Handle:livesHUD;
new Handle:timeleftHUD;
new Handle:infoHUD;

new bool:Enabled=true;
new bool:Enabled2=true;

bool FF2x10=false;
new PointDelay=6;
new Float:Announce=120.0;
new AliveToEnable=5;
new PointType;
new bool:BossCrits=true;
new arenaRounds;
new Float:circuitStun;
new countdownPlayers=1;
new countdownTime=120;
new countdownHealth=2000;
new bool:lastPlayerGlow=true;
new bool:bossTeleportation=true;
new shieldCrits;
new allowedDetonations;
new Float:GoombaDamage=0.05;
new Float:reboundPower=300.0;

new botqueuepoints;
new Float:HPTime;
new String:currentmap[99];
new bool:checkDoors=false;
new bool:bMedieval;
new bool:firstBlood;

new tf_spec_xray;
new Float:weapon_medigun_chargerelease_rate;
new tf_arena_use_queue;
new mp_teams_unbalance_limit;
new tf_arena_first_blood;
new mp_forcecamera;
new Float:tf_dropped_weapon_lifetime;
new Float:tf_feign_death_activate_damage_scale;
new Float:tf_feign_death_damage_scale;
new tf_feign_death_duration;

new bool:areSubPluginsEnabled;

new FF2CharSet;
new validCharsets[256];
new String:FF2CharSetString[42];
new bool:isCharSetSelected=false;
new bool:isCharsetOverride=false;
new healthBar=-1;
new g_Monoculus=-1;

static bool:executed=false;
static bool:executed2=false;
static bool:executed3=false;
static bool:executed4=false;

new changeGamemode;

new String: chkcurrentmap[PLATFORM_MAX_PATH];
new bool:DeadRunMode = false;
new bool:IsPreparing = false;
new RoundTick = 0;

new String: hName[512];
new Handle:sName;

new bool:IsBossSelected[MAXPLAYERS+1];

// Deathrun
new drboss;

// Dont trigger death events
new bool:isCosmetic=false;

// Enums

#define MAX_OPERATIONS 128

enum MapKind
{
    Maptype_VSH = 1,
    MapType_PropHunt,
    Maptype_Arena,
    Maptype_Deathrun,
    Maptype_Other,
}

enum WorldModelType
{
    ModelType_Normal=0,
    ModelType_PyroVision,
    ModelType_HalloweenVision,
    ModelType_RomeVision
}

enum FF2RoundState
{
    FF2RoundState_Loading=-1,
    FF2RoundState_Setup,
    FF2RoundState_RoundRunning,
    FF2RoundState_RoundEnd,
}

enum FF2Prefs
{
    FF2Setting_Unknown=-1,
    FF2Setting_None=0,
    FF2Setting_Enabled=1,
    FF2Setting_Disabled=2,
}

static bool:HasSwitched=false;
static bool:ReloadFF2=false;
static bool:ReloadWeapons=false;
static bool:ReloadConfigs=false;
new bool:LoadCharset=false;

new Specials;
new Handle:BossKV[MaxBosses];
new Handle:PreAbility;
//new Handle:PreAbility2;
new Handle:OnAbility;
new Handle:OnAbility2;
new Handle:OnMusic;
new Handle:OnTriggerHurt;
new Handle:OnSpecialSelected;
new Handle:OnAddQueuePoints;
new Handle:OnLoadCharacterSet;
new Handle:OnLoseLife;
new Handle:OnAlivePlayersChanged;
new Handle:OnParseUnknownVariable;

new cfgversion[MaxBosses];
new bool:bBlockVoice[MaxBosses];
#if defined FILECHECK_ENABLED
new bool:bSkipFileChecks[MaxBosses];
#endif
new Float:BossSpeed[MaxBosses];

new String:ChancesString[512];
new chances[MaxBosses];
new chancesIndex;

new Companions=0;
new TotalCompanions=0;

public Plugin:myinfo=
{
    name="Freak Fortress 2",
    author="Rainbolt Dash, FlaminSarge, Powerlord, the 50DKP team, SHADoW93",
    description="RUUUUNN!! COWAAAARRDSS!",
    version=PLUGIN_VERSION,
};

// Difficulty
new FF2Difficulty:FF2ClientDifficulty[MAXPLAYERS+1]=FF2Difficulty_Unknown;

// Boss Selection
new String:xIncoming[MAXPLAYERS+1][700];

new g_NextHale = -1;
new Handle:g_NextHaleTimer = INVALID_HANDLE;

new FF2Prefs:BossCookieSetting[MAXPLAYERS+1];
new FF2Prefs:CompanionCookieSetting[MAXPLAYERS+1];
new ClientPoint[MAXPLAYERS+1];
new ClientID[MAXPLAYERS+1];
new ClientQueue[MAXPLAYERS+1][2];
ConVar cvarFF2TogglePrefDelay;

stock MapKind:Maptype(String:map[])
{
    if(!StrContains(map,"dr_")) return Maptype_Deathrun;
    if(!StrContains(map,"deathrun_")) return Maptype_Deathrun;
    if(!StrContains(map,"deadrun_")) return Maptype_Deathrun;
    if(!StrContains(map,"vsh_dr_")) return Maptype_Deathrun;
    if(!StrContains(map,"vsh_")) return Maptype_VSH;
    if(!StrContains(map,"arena_")) return Maptype_Arena;
    if(!StrContains(map, "ph_")) return MapType_PropHunt;
    return Maptype_Other;
}

new bossWins[MAXPLAYERS+1];
new bossDefeats[MAXPLAYERS+1];
new bossKills[MAXPLAYERS+1];
new bossDeaths[MAXPLAYERS+1];

new bossesSlain[MAXPLAYERS+1];
new mvpCount[MAXPLAYERS+1];

Handle winCookie = null;
Handle lossCookie = null;
Handle killCookie = null;
Handle deathCookie = null; 
Handle bossslainCookie = null;
Handle mvpCookie = null;

// Modules
#include "ff2_modules/cookies.sp"
#include "ff2_modules/changelog.sp"
#include "ff2_modules/core.sp"
#include "ff2_modules/map.sp"
#include "ff2_modules/music.sp"
#include "ff2_modules/sounds.sp"
#include "ff2_modules/weapons.sp"
#include "ff2_modules/rtd.sp"
#include "ff2_modules/goomba.sp"
#include "ff2_modules/natives.sp"
#include "ff2_modules/healthbar.sp"
#include "ff2_modules/queuepoints.sp"
#include "ff2_modules/helppanel.sp"
#include "ff2_modules/parser.sp"
#include "ff2_modules/events.sp"
#include "ff2_modules/smac.sp"
#include "ff2_modules/tts.sp"
#include "ff2_modules/sdkhooks.sp"
#include "ff2_modules/developer.sp"
#include "ff2_modules/vsh.sp"

// Plugin Start
public OnPluginStart()
{
    LogMessage("===Freak Fortress 2 Initializing-v%s===", PLUGIN_VERSION);
    sName=FindConVar("hostname");
    
    // Logs for FF2 Bosses
    BuildPath(Path_SM, bLog, sizeof(bLog), FF2BossesLog);
    if(!FileExists(bLog))
    {
        OpenFile(bLog, "a+");
    }
     
    // Logs for FF2 in general
    BuildPath(Path_SM, eLog, sizeof(eLog), FF2Log);
    if(!FileExists(eLog))
    {
        OpenFile(eLog, "a+");    
    }
    
    FF2Cookies=RegClientCookie("ff2_cookies_mk2", "", CookieAccess_Protected);
    
    PrepareCookies(FF2Cookie);
    
    cvarVersion=CreateConVar("ff2_version", PLUGIN_VERSION, "Freak Fortress 2 Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_DONTRECORD);
    cvarPointType=CreateConVar("ff2_point_type", "0", "0-Use ff2_point_alive, 1-Use ff2_point_time", _, true, 0.0, true, 1.0);
    cvarPointDelay=CreateConVar("ff2_point_delay", "6", "Seconds to add to the point delay per player", _);
    cvarSpellBooks=CreateConVar("ff2_spells_enable", "1", "0-Disable spells from being dropped, 1-Enable spells", _, true, 0.0, true, 1.0);
    cvarAliveToEnable=CreateConVar("ff2_point_alive", "5", "The control point will only activate when there are this many people or less left alive", _);
    cvarAnnounce=CreateConVar("ff2_announce", "120", "Amount of seconds to wait until FF2 info is displayed again.  0 to disable", _, true, 0.0);
    cvarEnabled=CreateConVar("ff2_enabled", "1", "0-Disable FF2 (WHY?), 1-Enable FF2", FCVAR_DONTRECORD, true, 0.0, true, 1.0);
    cvarCrits=CreateConVar("ff2_crits", "1", "Can Boss get crits?", _, true, 0.0, true, 1.0);
    cvarFirstRound=CreateConVar("ff2_first_round", "-1", "This cvar is deprecated.  Please use 'ff2_arena_rounds' instead by setting this cvar to -1", _, true, -1.0, true, 1.0);  //DEPRECATED
    cvarArenaRounds=CreateConVar("ff2_arena_rounds", "1", "Number of rounds to make arena before switching to FF2 (helps for slow-loading players)", _, true, 0.0);
    cvarCircuitStun=CreateConVar("ff2_circuit_stun", "4", "Amount of seconds the Short Circuit and The Classic stuns the boss for.  0 to disable", _, true, 0.0);
    cvarCountdownPlayers=CreateConVar("ff2_countdown_players", "1", "Amount of players until the countdown timer starts (0 to disable)", _, true, 0.0);
    cvarCountdownTime=CreateConVar("ff2_countdown", "120", "Amount of seconds until the round ends in a stalemate", _);
    cvarCountdownHealth=CreateConVar("ff2_countdown_health", "2000", "Amount of health the Boss has remaining until the countdown stops", _, true, 0.0);
    cvarRPSQueuePoints=CreateConVar("ff2_rps_queue_points", "10", "Queue points awarded / removed upon RPS (0 to disable)", _, true, 0.0);
    cvarCountdownResult=CreateConVar("ff2_countdown_result", "0", "0-Kill players when the countdown ends, 1-End the round in a stalemate", _, true, 0.0, true, 1.0);
    cvarCountdownOverTime=CreateConVar("ff2_countdown_overtime", "1", "0-Proceed with 'ff2_countdown_result' as usual, 1-Delay 'ff2_countdown_result' action until control point is no longer being captured.", _, true, 0.0, true, 1.0);
    cvarEnableEurekaEffect=CreateConVar("ff2_enable_eureka", "0", "0-Disable the Eureka Effect, 1-Enable the Eureka Effect", _, true, 0.0, true, 1.0);
    cvarForceBossTeam=CreateConVar("ff2_force_team", "0", "0-Boss team depends on FF2 logic, 1-Boss is on a random team each round, 2-Boss is always on Red, 3-Boss is always on Blu", _, true, 0.0, true, 3.0);
    cvarHealthBar=CreateConVar("ff2_health_bar", "0", "0-Disable the health bar, 1-Show the health bar", _, true, 0.0, true, 1.0);
    cvarLastPlayerGlow=CreateConVar("ff2_last_player_glow", "1", "0-Don't outline the last player, 1-Outline the last player alive", _, true, 0.0, true, 1.0);
    cvarBossTeleporter=CreateConVar("ff2_boss_teleporter", "0", "-1 to disallow all bosses from using teleporters, 0 to use TF2 logic, 1 to allow all bosses", _, true, -1.0, true, 1.0);
    cvarBossSuicide=CreateConVar("ff2_boss_suicide", "0", "Allow the boss to suicide after the round starts?", _, true, 0.0, true, 1.0);
    cvarCaberDetonations=CreateConVar("ff2_caber_detonations", "5", "Amount of times somebody can detonate the Ullapool Caber", _);
    cvarShieldCrits=CreateConVar("ff2_shield_crits", "0", "0 to disable grenade launcher crits when equipping a shield, 1 for minicrits, 2 for crits", _, true, 0.0, true, 2.0);
    cvarBossRTD=CreateConVar("ff2_boss_rtd", "0", "Can the boss use rtd? 0 to disallow boss, 1 to allow boss (requires RTD)", _, true, 0.0, true, 1.0);
    cvarGoombaDamage=CreateConVar("ff2_goomba_damage", "0.05", "How much the Goomba damage should be multipled by when goomba stomping the boss (requires Goomba Stomp)", _, true, 0.01, true, 1.0);
    cvarMedievalDivider=CreateConVar("ff2_medieval_hp_divider", "3.6", "How much is health divided on medieval mode", _, true, 0.01, true, 1.0);
    cvarDamageToTele=CreateConVar("ff2_tts_damage", "400.0", "Minimum damage boss needs to take in order to be teleported to spawn", _, true, 0.01, true, 1.0);
    cvarGoombaRebound=CreateConVar("ff2_goomba_jump", "300.0", "How high players should rebound after goomba stomping the boss (requires Goomba Stomp)", _, true, 0.0);
    cvarSubtractRageOnJarate=CreateConVar("ff2_jarate_subtract_rage", "25.0", "How much rage should Jarate / Mad Milk subtract", _, true, 0.0);
    cvarUpdater=CreateConVar("ff2_updater", "0", "0-Disable Updater support, 1-Enable automatic updating (recommended, requires Updater)", _, true, 0.0, true, 1.0);
    cvarDebug=CreateConVar("ff2_debug", "0", "0-Disable FF2 debug output, 1-Enable debugging (not recommended)", _, true, 0.0, true, 1.0);
    cvarDmg2KStreak=CreateConVar("ff2_dmg_kstreak", "500", "Minimum damage to increase killstreak count", _, true, 0.0);
    // Config Defaults
    cvarDefaultHealthFormula=CreateConVar("ff2_default_health", "(((760.8+n)*(n-1))^1.0341)+2046", "Default health formula to use if none is specified on a boss cfg. v1 configs ONLY!", _);
    cvarDefaultRageDamage=CreateConVar("ff2_default_ragedamage", "3500", "Default rage damage to use if none is specified on a boss cfg. Applies to v1 and v2 configs!", _);
    cvarDefaultMoveSpeed=CreateConVar("ff2_default_movespeed", "340", "Default move speed to use if none is specified on a boss cfg. Applies to v1 and v2 configs!", _);
    cvarDefaultRageDist=CreateConVar("ff2_default_ragedist", "400.0", "Default rage distance to use if none is specified on a boss cfg. Applies to v1 and v2 configs!n", _, true, 0.01, true, 1.0);
    // Difficulty Modifiers
    cvarHardModifier=CreateConVar("ff2_difficulty_hard_hp_modifier", "0.5", "Health is modified by this percentage for the Hard Difficulty", _, true, 0.01, true, 1.0);
    cvarLunaticModifier=CreateConVar("ff2_difficulty_lunatic_hp_modifier", "0.35", "Health is modified by this percentage for the Lunatic Difficulty", _, true, 0.01, true, 1.0);
    cvarInsaneModifier=CreateConVar("ff2_difficulty_insane_hp_modifier", "0.25", "Health is modified by this percentage for the Insane Difficulty", _, true, 0.01, true, 1.0);
    // Boss Selection
    RegConsoleCmd("ff2_boss", Command_SetMyBoss, "Set my boss");
    RegConsoleCmd("ff2boss", Command_SetMyBoss, "Set my boss");
    RegConsoleCmd("hale_boss", Command_SetMyBoss, "Set my boss");
    RegConsoleCmd("haleboss", Command_SetMyBoss, "Set my boss");
    RegConsoleCmd("setboss", Command_SetMyBoss, "Set my boss");    
    RegConsoleCmd("setmyboss", Command_SetMyBoss, "Set my boss");
    
    // ff2 music
    RegConsoleCmd("ff2_skipsong", Command_SkipSong);
    RegConsoleCmd("ff2skipsong", Command_SkipSong);
    RegConsoleCmd("ff2_shufflesong", Command_ShuffleSong);
    RegConsoleCmd("ff2shufflesong", Command_ShuffleSong);
    RegConsoleCmd("ff2_tracklist", Command_Tracklist);
    RegConsoleCmd("ff2tracklist", Command_Tracklist);
    
    // Boss Toggle Stuff
    cvarFF2TogglePrefDelay = CreateConVar("ff2_boss_toggle_delay", "45.0", "Delay between joining the server and asking the player for their preference, if it is not set.");    
    AutoExecConfig(true, "plugin.ff2_boss_toggle");
    
    RegConsoleCmd("ff2toggle", BossMenu);
    RegConsoleCmd("ff2_toggle", BossMenu);
    RegConsoleCmd("haletoggle", BossMenu);
    RegConsoleCmd("hale_toggle", BossMenu);
    RegConsoleCmd("ff2companion", CompanionMenu);
    RegConsoleCmd("ff2_companion", CompanionMenu);
    RegConsoleCmd("halecompanion", CompanionMenu);
    RegConsoleCmd("hale_companion", CompanionMenu);
    RegConsoleCmd("ff2difficulty", DifficultyMenu);
    RegConsoleCmd("ff2_difficulty", DifficultyMenu);
    RegConsoleCmd("haledifficulty", DifficultyMenu);
    RegConsoleCmd("hale_difficulty", DifficultyMenu);
    for(new i=0;i<MAXPLAYERS;i++)
    {
        BossCookieSetting[i] = FF2Setting_Unknown;
        CompanionCookieSetting[i] = FF2Setting_Unknown;
        FF2ClientDifficulty[i] = FF2Difficulty_Unknown;
    }
    
    PrepareStatTrakCookie();

    //The following are used in various subplugins
    CreateConVar("ff2_oldjump", "0", "Use old Saxton Hale jump equations", _, true, 0.0, true, 1.0);
    CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", _, true, 0.0, true, 1.0);

    HookEvent("teamplay_round_start", Event_Setup, EventHookMode_Post);
    HookEvent("teamplay_round_win", Event_RoundWin, EventHookMode_Post);
    HookEvent("teamplay_broadcast_audio", Event_Broadcast, EventHookMode_Pre);
    HookEvent("rps_taunt_event", OnRPS, EventHookMode_Post);
    HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
    HookEvent("post_inventory_application", Event_PostInventoryApplication, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
    HookEvent("player_chargedeployed", Event_Uber, EventHookMode_Post);
    HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
    HookEvent("object_destroyed", Event_Destroy, EventHookMode_Pre);
    HookEvent("object_deflected", Event_Deflect, EventHookMode_Pre);
    HookEvent("deploy_buff_banner", Event_DeployBanner, EventHookMode_Post);
    HookEvent("rocket_jump", Event_RocketJump, EventHookMode_Post);
    HookEvent("rocket_jump_landed", Event_RocketJump, EventHookMode_Post);

    OnPluginStart_TeleportToMultiMapSpawn(); // Setup adt_array
    
    HookUserMessage(GetUserMessageId("PlayerJarated"), UserMessage_Jarate);  //Used to subtract rage when a boss is jarated (not through Sydney Sleeper)
    
    AddCommandListener(CMD_VoiceMenu, "voicemenu");  //Used to activate rages
    AddCommandListener(CMD_Taunt, "taunt"); //Used to activate rages
    AddCommandListener(CMD_Taunt, "+taunt"); //Used to activate rages
    AddCommandListener(CMD_Suicide, "explode");  //Used to stop boss from suiciding
    AddCommandListener(CMD_Suicide, "kill");  //Used to stop boss from suiciding
    AddCommandListener(CMD_JoinTeam, "jointeam");  //Used to make sure players join the right team
    AddCommandListener(CMD_JoinTeam, "autoteam");         //Used to make sure players don't kill themselves and change team
    AddCommandListener(CMD_ChangeClass, "joinclass");  //Used to make sure bosses don't change class
    
    HookConVarChange(FindConVar("tf_bot_quota"), HideCvarNotify);
    HookConVarChange(FindConVar("tf_bot_count"), HideCvarNotify);
    HookConVarChange(FindConVar("tf_arena_use_queue"), HideCvarNotify);
    HookConVarChange(FindConVar("tf_arena_first_blood"), HideCvarNotify);
    HookConVarChange(FindConVar("mp_friendlyfire"), HideCvarNotify);
    
    HookConVarChange(cvarEnabled, CvarChange);
    HookConVarChange(cvarPointDelay, CvarChange);
    HookConVarChange(cvarAnnounce, CvarChange);
    HookConVarChange(cvarPointType, CvarChange);
    HookConVarChange(cvarPointDelay, CvarChange);
    HookConVarChange(cvarAliveToEnable, CvarChange);
    HookConVarChange(cvarCrits, CvarChange);
    HookConVarChange(cvarCircuitStun, CvarChange);
    HookConVarChange(cvarHealthBar, HealthbarEnableChanged);
    HookConVarChange(cvarCountdownPlayers, CvarChange);
    HookConVarChange(cvarCountdownTime, CvarChange);
    HookConVarChange(cvarCountdownHealth, CvarChange);
    HookConVarChange(cvarLastPlayerGlow, CvarChange);
    HookConVarChange(cvarBossTeleporter, CvarChange);
    HookConVarChange(cvarShieldCrits, CvarChange);
    HookConVarChange(cvarCaberDetonations, CvarChange);
    HookConVarChange(cvarGoombaDamage, CvarChange);
    HookConVarChange(cvarGoombaRebound, CvarChange);
    HookConVarChange(cvarUpdater, CvarChange);
    HookConVarChange(cvarSpellBooks, CvarChange);
    HookConVarChange(cvarNextmap=FindConVar("sm_nextmap"), CvarChangeNextmap);
    
    RegConsoleCmd("ff2", FF2Panel);
    RegConsoleCmd("ff2_hp", Command_GetHPCmd);
    RegConsoleCmd("ff2hp", Command_GetHPCmd);
    RegConsoleCmd("ff2_next", QueuePanelCmd);
    RegConsoleCmd("ff2next", QueuePanelCmd);
    RegConsoleCmd("ff2_classinfo", Command_HelpPanelClass);
    RegConsoleCmd("ff2classinfo", Command_HelpPanelClass);
    RegConsoleCmd("ff2_new", NewPanelCmd);
    RegConsoleCmd("ff2new", NewPanelCmd);
    RegConsoleCmd("ff2music", MusicTogglePanelCmd);
    RegConsoleCmd("ff2_music", MusicTogglePanelCmd);
    RegConsoleCmd("ff2voice", VoiceTogglePanelCmd);
    RegConsoleCmd("ff2_voice", VoiceTogglePanelCmd);
    RegConsoleCmd("ff2_resetpoints", ResetQueuePointsCmd);
    RegConsoleCmd("ff2resetpoints", ResetQueuePointsCmd);

    RegConsoleCmd("hale", FF2Panel);
    RegConsoleCmd("hale_hp", Command_GetHPCmd);
    RegConsoleCmd("halehp", Command_GetHPCmd);
    RegConsoleCmd("hale_next", QueuePanelCmd);
    RegConsoleCmd("halenext", QueuePanelCmd);
    RegConsoleCmd("hale_classinfo", Command_HelpPanelClass);
    RegConsoleCmd("haleclassinfo", Command_HelpPanelClass);
    RegConsoleCmd("hale_new", NewPanelCmd);
    RegConsoleCmd("halenew", NewPanelCmd);
    RegConsoleCmd("halemusic", MusicTogglePanelCmd);
    RegConsoleCmd("hale_music", MusicTogglePanelCmd);
    RegConsoleCmd("halevoice", VoiceTogglePanelCmd);
    RegConsoleCmd("hale_voice", VoiceTogglePanelCmd);
    RegConsoleCmd("hale_resetpoints", ResetQueuePointsCmd);
    RegConsoleCmd("haleresetpoints", ResetQueuePointsCmd);

    RegConsoleCmd("nextmap", Command_Nextmap);
    RegConsoleCmd("say", Command_Say);
    RegConsoleCmd("say_team", Command_Say);

    ReloadFF2 = false;
    ReloadWeapons = false;
    ReloadConfigs = false;
    
    RegAdminCmd("ff2_loadcharset", Command_LoadCharset, ADMFLAG_CHEATS, "Usage: ff2_loadcharset <charset>.  Forces FF2 to switch to a given character set without changing maps");
    RegAdminCmd("ff2_reloadcharset", Command_ReloadCharset, ADMFLAG_CHEATS, "Usage:  ff2_reloadcharset.  Forces FF2 to reload the current character set");
    RegAdminCmd("ff2_reload", Command_ReloadFF2, ADMFLAG_ROOT, "Reloads FF2 safely and quietly");
    RegAdminCmd("ff2_reloadweapons", Command_ReloadFF2Weapons, ADMFLAG_RCON, "Reloads FF2 weapon configuration safely and quietly");
    RegAdminCmd("ff2_reloadconfigs", Command_ReloadFF2Configs, ADMFLAG_RCON, "Reloads ALL FF2 configs safely and quietly");

    RegAdminCmd("ff2_special", Command_SetNextBoss, ADMFLAG_CHEATS, "Usage:  ff2_special <boss>.  Forces next round to use that boss");
    RegAdminCmd("ff2_addpoints", Command_Points, ADMFLAG_CHEATS, "Usage:  ff2_addpoints <target> <points>.  Adds queue points to any player");
    RegAdminCmd("ff2_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable the control point if ff2_point_type is 0");
    RegAdminCmd("ff2_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable the control point if ff2_point_type is 0");
    RegAdminCmd("ff2_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music");
    RegAdminCmd("ff2_start_music", Command_StartMusic, ADMFLAG_CHEATS, "Starts Boss music");
    RegAdminCmd("ff2_resetqueuepoints", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
    RegAdminCmd("ff2_resetq", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
    RegAdminCmd("ff2_charset", Command_Charset, ADMFLAG_CHEATS, "Usage:  ff2_charset <charset>.  Forces FF2 to use a given character set for the next map");
    RegAdminCmd("ff2_votecharset", Command_VoteCharset, ADMFLAG_VOTE, "Forces FF2 charset vote");
    RegAdminCmd("ff2_reload_subplugins", Command_ReloadSubPlugins, ADMFLAG_RCON, "Reload FF2's subplugins.");
    
    RegAdminCmd("hale_select", Command_MakeNextBoss, ADMFLAG_CHEATS, "Usage:  hale_select <boss>.  Forces next round to use that boss");
    RegAdminCmd("ff2_select", Command_MakeNextBoss, ADMFLAG_CHEATS, "Usage:  hale_select <boss>.  Forces next round to use that boss");
    
    RegAdminCmd("hale_special", Command_SetNextBoss, ADMFLAG_CHEATS, "Usage:  hale_select <boss>.  Forces next round to use that boss");
    RegAdminCmd("hale_addpoints", Command_Points, ADMFLAG_CHEATS, "Usage:  hale_addpoints <target> <points>.  Adds queue points to any player");
    RegAdminCmd("hale_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable the control point if ff2_point_type is 0");
    RegAdminCmd("hale_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable the control point if ff2_point_type is 0");
    RegAdminCmd("hale_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music");
    RegAdminCmd("hale_resetqueuepoints", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
    RegAdminCmd("hale_resetq", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");

    AutoExecConfig(true, "FreakFortress2");

    jumpHUD=CreateHudSynchronizer();
    cloakHUD=CreateHudSynchronizer();
    rageHUD=CreateHudSynchronizer();
    livesHUD=CreateHudSynchronizer();
    timeleftHUD=CreateHudSynchronizer();
    infoHUD=CreateHudSynchronizer();

    new String:oldVersion[64];
    GetConVarString(cvarVersion, oldVersion, sizeof(oldVersion));
    if(strcmp(oldVersion, PLUGIN_VERSION, false))
    {
        LogToFile(eLog, "[FF2] Warning: Your config may be outdated. Back up tf/cfg/sourcemod/FreakFortress2.cfg and delete it, and this plugin will generate a new one that you can then modify to your original values.");
    }

    LoadTranslations("freak_fortress_2.phrases");
    LoadTranslations("freak_fortress_2_prefs.phrases");
    LoadTranslations("freak_fortress_2_help.phrases");
    LoadTranslations("freak_fortress_2_stats.phrases");
    LoadTranslations("common.phrases");

    ResetValueToZero();
    AddNormalSoundHook(SoundHook);

    AddMultiTargetFilter("@hale", BossTargetFilter, "all current Bosses", false);
    AddMultiTargetFilter("@!hale", BossTargetFilter, "all non-Boss players", false);
    AddMultiTargetFilter("@boss", BossTargetFilter, "all current Bosses", false);
    AddMultiTargetFilter("@!boss", BossTargetFilter, "all non-Boss players", false);
    
    FF2x10=LibraryExists("tf2x10");
    
    #if defined _steamtools_included
    steamtools=LibraryExists("SteamTools");
    #endif

    #if defined _tf2attributes_included
    tf2attributes=LibraryExists("tf2attributes");
    #endif
    
    for(new client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
            continue;
        FF2_AddHooks(client);
        if (IsPlayerAlive(client))
            TF2Attrib_RemoveByName(client, "damage force reduction");
    }
    
    // FF2 Developer Mode
    cvarDevelopMode=CreateConVar("ff2_developermode", "0", "0-Disable FF2 developer mode, 1-Enable developer mode (not recommended)", _, true, 0.0, true, 1.0);
    RegAdminCmd("hale_setrage", Command_SetRage, ADMFLAG_CHEATS, "Usage: hale_giverage <target> <percent>. Gives RAGE to a boss player");
    RegAdminCmd("ff2_setrage", Command_SetRage, ADMFLAG_CHEATS, "Usage: ff2_giverage <target> <percent>. Gives RAGE to a boss player");
    RegAdminCmd("hale_setinfiniterage", Command_SetInfiniteRage, ADMFLAG_CHEATS, "Usage: hale_infiniterage <target>. Gives infinite RAGE to a boss player");
    RegAdminCmd("ff2_setinfiniterage", Command_SetInfiniteRage, ADMFLAG_CHEATS, "Usage: ff2_infiniterage <target>. Gives infinite RAGE to a boss player");
    RegAdminCmd("hale_setcharge", Command_SetCharge, ADMFLAG_CHEATS, "Usage:  hale_setcharge <target> <slot> <percent>. Sets a boss's charge");
    RegAdminCmd("ff2_setcharge", Command_SetCharge, ADMFLAG_CHEATS, "Usage:  ff2_setcharge <target> <slot> <percent>. Sets a boss's charge");
    
    HookEvent("teamplay_point_startcapture", Event_StartCapture);
    new Handle:hCFG=LoadGameConfigFile(CPGameData);  
    if(hCFG == INVALID_HANDLE)
    {
        LogToFile(eLog, "Missing gamedata file %s.txt! Will not use CP capture percentage values!", CPGameData);
        CloseHandle(hCFG);
        useCPvalue=false;
        HookEvent("teamplay_capture_broken", Event_BreakCapture);
        return;
    }
    StartPrepSDKCall(SDKCall_Entity);  
    PrepSDKCall_SetFromConf(hCFG, SDKConf_Signature, "CTeamControlPoint::GetTeamCapPercentage");  
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); 
    PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain); 
    if((SDKGetCPPct = EndPrepSDKCall()) == INVALID_HANDLE)
    {
        LogToFile(eLog, "Failed to create SDKCall for CTeamControlPoint::GetTeamCapPercentage signature! Will not use CP capture percentage values!"); 
        CloseHandle(hCFG);
        useCPvalue=false;
        HookEvent("teamplay_capture_broken", Event_BreakCapture);
        return;
    }
    useCPvalue=true;
    CloseHandle(hCFG);  
}

static const char UnBonked[][] = {
    "vo/scout_sf12_badmagic04.mp3",
    "vo/scout_sf12_badmagic09.mp3",
    "vo/scout_sf13_magic_reac03.mp3",
    "vo/scout_invinciblenotready06.mp3"
};

static const char OTVoice[][] = {
    "vo/announcer_overtime.mp3",
    "vo/announcer_overtime2.mp3",
    "vo/announcer_overtime3.mp3",
    "vo/announcer_overtime4.mp3"
};

public FindCharacters()  //TODO: Investigate KvGotoFirstSubKey; KvGotoNextKey
{
    new String:config[PLATFORM_MAX_PATH], String:key[4], String:charset[42];
    Specials=0;
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, CharsetCFG);

    if(!FileExists(config))
    {
        BuildPath(Path_SM, config, sizeof(config), "%s/%s", ConfigPath, CharsetCFG);
        if(FileExists(config))
            LogToFile(eLog, "[FF2] Freak Fortress 2 disabled-please move '%s' from '%s' to '%s'!", CharsetCFG, ConfigPath, DataPath);
        else
            LogToFile(eLog, "[FF2] Freak Fortress 2 disabled-can not find '%s!", CharsetCFG);
        Enabled2=false;
        return;
    }

    new Handle:Kv=CreateKeyValues("");
    FileToKeyValues(Kv, config);
    new NumOfCharSet=FF2CharSet;

    new Action:action=Plugin_Continue;
    Call_StartForward(OnLoadCharacterSet);
    Call_PushCellRef(NumOfCharSet);
    strcopy(charset, sizeof(charset), FF2CharSetString);
    Call_PushStringEx(charset, sizeof(charset), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
    Call_Finish(action);
    if(action==Plugin_Changed)
    {
        new i=-1;
        if(strlen(charset))
        {
            KvRewind(Kv);
            for(i=0; ; i++)
            {
                KvGetSectionName(Kv, config, sizeof(config));
                if(!strcmp(config, charset, false))
                {
                    FF2CharSet=i;
                    strcopy(FF2CharSetString, PLATFORM_MAX_PATH, charset);
                    KvGotoFirstSubKey(Kv);
                    break;
                }

                if(!KvGotoNextKey(Kv))
                {
                    i=-1;
                    break;
                }
            }
        }

        if(i==-1)
        {
            FF2CharSet=NumOfCharSet;
            for(i=0; i<FF2CharSet; i++)
            {
                KvGotoNextKey(Kv);
            }
            KvGotoFirstSubKey(Kv);
            KvGetSectionName(Kv, FF2CharSetString, sizeof(FF2CharSetString));
        }
    }

    KvRewind(Kv);
    for(new i; i<FF2CharSet; i++)
    {
        KvGotoNextKey(Kv);
    }

    for(new i=1; i<MaxBosses; i++)
    {
        IntToString(i, key, sizeof(key));
        KvGetString(Kv, key, config, PLATFORM_MAX_PATH);
        if(!config[0])  //TODO: Make this more user-friendly (don't immediately break-they might have missed a number)
        {
            break;
        }
        LoadCharacter(config);
    }

    KvGetString(Kv, "chances", ChancesString, sizeof(ChancesString));
    CloseHandle(Kv);

    new String:stringChances[MaxBosses*2][8];
    if(ChancesString[0])
    {
        new amount=ExplodeString(ChancesString, ";", stringChances, MaxBosses*2, 8);
        if(amount % 2)
        {
            LogToFile(bLog, "[FF2 Bosses] Invalid chances string, disregarding chances");
            strcopy(ChancesString, sizeof(ChancesString), "");
            amount=0;
        }

        chances[0]=StringToInt(stringChances[0]);
        chances[1]=StringToInt(stringChances[1]);
        for(chancesIndex=2; chancesIndex<amount; chancesIndex++)
        {
            if(chancesIndex % 2)
            {
                if(StringToInt(stringChances[chancesIndex])<=0)
                {
                    LogToFile(bLog, "[FF2 Bosses] Character %i cannot have a zero or negative chance, disregarding chances", chancesIndex-1);
                    strcopy(ChancesString, sizeof(ChancesString), "");
                    break;
                }
                chances[chancesIndex]=StringToInt(stringChances[chancesIndex])+chances[chancesIndex-2];
            }
            else
            {
                chances[chancesIndex]=StringToInt(stringChances[chancesIndex]);
            }
        }
    }

    AddFileToDownloadsTable("sound/saxton_hale/9000.wav");
    for (new i = 0; i < sizeof(UnBonked); i++)
    {
        PrecacheSound(UnBonked[i], true);
    }
    for (new i = 0; i < sizeof(OTVoice); i++)
    {
        PrecacheSound(OTVoice[i], true);
    }
    PrecacheSound("saxton_hale/9000.wav", true);
    PrecacheSound("vo/announcer_am_capincite01.mp3", true);
    PrecacheSound("vo/announcer_am_capincite03.mp3", true);
    PrecacheSound("vo/announcer_am_capenabled01.mp3", true);
    PrecacheSound("vo/announcer_am_capenabled02.mp3", true);
    PrecacheSound("vo/announcer_am_capenabled03.mp3", true);
    PrecacheSound("vo/announcer_am_capenabled04.mp3", true);
    PrecacheSound("weapons/barret_arm_zap.wav", true);
    PrecacheSound("vo/announcer_ends_5min.mp3", true);
    PrecacheSound("vo/announcer_ends_2min.mp3", true);
    PrecacheSound("player/doubledonk.wav", true);
    isCharSetSelected=false;
    isCharsetOverride=false;
}

public bool:BossTargetFilter(const String:pattern[], Handle:clients)
{
    new bool:non=StrContains(pattern, "!", false)!=-1;
    for(new client=1; client<=MaxClients; client++)
    {
        if(IsValidClient(client) && FindValueInArray(clients, client)==-1)
        {
            if(Enabled && IsBoss(client))
            {
                if(!non)
                {
                    PushArrayCell(clients, client);
                }
            }
            else if(non)
            {
                PushArrayCell(clients, client);
            }
        }
    }
    return true;
}

public OnLibraryAdded(const String:name[])
{
    #if defined _steamtools_included
    if(!strcmp(name, "SteamTools", false))
    {
        steamtools=true;
    }
    #endif

    #if defined _tf2attributes_included
    if(!strcmp(name, "tf2attributes", false))
    {
        tf2attributes=true;
    }
    #endif

    #if defined _updater_included && !defined DEV_REVISION
    if(StrEqual(name, "updater") && GetConVarBool(cvarUpdater))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
    #endif
    
    if(StrEqual(name, "tf2x10"))
    {
        FF2x10=true;
    }
    
    OnRTDLoaded(name);
    OnGoombaLoaded(name);
    OnSMACLoaded(name);
}

public OnLibraryRemoved(const String:name[])
{
    #if defined _steamtools_included
    if(!strcmp(name, "SteamTools", false))
    {
        steamtools=false;
    }
    #endif

    #if defined _tf2attributes_included
    if(!strcmp(name, "tf2attributes", false))
    {
        tf2attributes=false;
    }
    #endif
    #if defined _updater_included
    if(StrEqual(name, "updater"))
    {
        Updater_RemovePlugin();
    }
    #endif

    if(StrEqual(name, "tf2x10"))
    {
        FF2x10=false;
    }
    
    OnGoombaRemoved(name);
    OnSMACRemoved(name);
}

public OnConfigsExecuted()
{   
    weapon_medigun_chargerelease_rate=GetConVarFloat(FindConVar("weapon_medigun_chargerelease_rate"));
    tf_spec_xray=GetConVarInt(FindConVar("tf_spec_xray"));
    tf_arena_use_queue=GetConVarInt(FindConVar("tf_arena_use_queue"));
    mp_teams_unbalance_limit=GetConVarInt(FindConVar("mp_teams_unbalance_limit"));
    tf_arena_first_blood=GetConVarInt(FindConVar("tf_arena_first_blood"));
    mp_forcecamera=GetConVarInt(FindConVar("mp_forcecamera"));
    tf_dropped_weapon_lifetime=GetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"));
    tf_feign_death_activate_damage_scale=GetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"));
    tf_feign_death_damage_scale=GetConVarFloat(FindConVar("tf_feign_death_damage_scale"));
    tf_feign_death_duration=GetConVarInt(FindConVar("tf_feign_death_duration"));
    
    GetConVarString(sName, hName, sizeof(hName));
    
    FindRTD();
    FindGoomba();
    
    if(IsFF2Map() && GetConVarBool(cvarEnabled))
    {
        EnableFF2();
    }
    else
    {
        DisableFF2();
    }

    #if defined _updater_included && !defined DEV_REVISION
    if(LibraryExists("updater") && GetConVarBool(cvarUpdater))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
    #endif
}

public OnMapStart()
{
    HPTime=0.0;
    RoundCount=0;
    TeamRoundCounter=0;
    
    for(new client; client<=MaxClients; client++)
    {
        KSpreeTimer[client]=0.0;
        FF2Flags[client]=0;
        Incoming[client]=-1;
        PlayBGMAt[client]=INACTIVE;
    }

    for(new specials; specials<MaxBosses; specials++)
    {
        if(BossKV[specials]!=INVALID_HANDLE)
        {
            CloseHandle(BossKV[specials]);
            BossKV[specials]=INVALID_HANDLE;
        }
    }
    
    GetCurrentMap(chkcurrentmap, PLATFORM_MAX_PATH);
    if (Maptype(chkcurrentmap) == Maptype_Deathrun)
        DeadRunMode = true;
    else
        DeadRunMode = false;
        
    if(GetConVarBool(cvarSpellBooks))
    {
        SetConVarInt(FindConVar("tf_spells_enabled"), (DeadRunMode == true ? 0 : 1));
        SetConVarInt(FindConVar("tf_player_spell_drop_on_death_rate"), (DeadRunMode == true ? 0 : 1));
    }
    SetConVarInt(FindConVar("tf_scout_air_dash_count"), (DeadRunMode == true ? 0 : 1));
    
    SaveOriginalEntityTeam("info_player_teamspawn");
    SaveOriginalEntityTeam("obj_sentrygun");
    SaveOriginalEntityTeam("obj_dispenser");
    SaveOriginalEntityTeam("obj_teleporter");
    SaveOriginalEntityTeam("filter_activator_tfteam");    
    
}

public OnMapEnd()
{
    if(Enabled || Enabled2)
    {
        StopMusic(_, true, nomusic);
        SetConVarFloat(FindConVar("weapon_medigun_chargerelease_rate"), weapon_medigun_chargerelease_rate);
        SetConVarInt(FindConVar("tf_spec_xray"), tf_spec_xray);
        SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
        SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
        SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
        SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
        SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), tf_dropped_weapon_lifetime);
        SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), tf_feign_death_activate_damage_scale);
        SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), tf_feign_death_damage_scale);
        SetConVarInt(FindConVar("tf_feign_death_duration"), tf_feign_death_duration);
        
        #if defined _steamtools_included
        if(steamtools)
        {
            Steam_SetGameDescription("Team Fortress");
        }
        #endif
        DisableSubPlugins();

        for(new client; client<=MaxClients; client++)
        {
            if(PlayBGMAt[client]!=INACTIVE)
            {
                PlayBGMAt[client]=INACTIVE;
            }
        }

        SetSMACConVars();
    }
}

public OnPluginEnd()
{
    OnMapEnd();
    SetConVarString(sName, hName);
    if (!ReloadFF2 && CheckRoundState() == FF2RoundState_RoundRunning)
    {
        ForceTeamWin(0);
        CPrintToChatAll("{olive}[FF2]{default} The plugin has been unexpectedly unloaded!");
    }
}

public ResetValueToZero()
{
    CheckDoorsAt=INACTIVE;
    CalcQueuePointsAt=INACTIVE;
    CheckAlivePlayersAt=INACTIVE;
    AnnounceAt=INACTIVE;
    NineThousandAt=INACTIVE;
    EnableCapAt=INACTIVE;
    StartFF2RoundAt=INACTIVE;
    ShowToolTipsAt=INACTIVE;
    DrawGameTimerAt=INACTIVE;
    DisplayMessageAt=INACTIVE;
    StartBossAt=INACTIVE;
    StartResponseAt=INACTIVE;
    DisplayNextBossPanelAt=INACTIVE;
    MoveAt=INACTIVE;
    FF2BossTick=INACTIVE;
    FF2ClientTick=INACTIVE;
    for(new client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
            continue;
        PlayBGMAt[client]=INACTIVE;
        CheckMinHudAt[client]=INACTIVE;
        PrepareMercAt[client]=INACTIVE;
        InspectPlayerInventoryAt[client]=INACTIVE;
        KillRPSLosingBossAt[client]=INACTIVE;
    }
}

public HideCvarNotify(Handle:convar, const String:oldValue[], const String:newValue[])
{
    new Handle:svtags = FindConVar("sv_tags");
    new sflags = GetConVarFlags(svtags);
    sflags &= ~FCVAR_NOTIFY;
    SetConVarFlags(svtags, sflags);

    new flags = GetConVarFlags(convar);
    flags &= ~FCVAR_NOTIFY;
    SetConVarFlags(convar, flags);
}

public CvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
    if(convar==cvarPointDelay)
    {
        PointDelay=StringToInt(newValue);
        if(PointDelay<0)
        {
            PointDelay*=-1;
        }
    }
    else if(convar==cvarSpellBooks && !DeadRunMode)
    {
        SetConVarInt(FindConVar("tf_spells_enabled"), (GetConVarBool(cvarSpellBooks) == true ? 1 : 0));
        SetConVarInt(FindConVar("tf_player_spell_drop_on_death_rate"), (GetConVarBool(cvarSpellBooks) == true ? 1 : 0));    
    }
    else if(convar==cvarAnnounce)
    {
        Announce=StringToFloat(newValue);
    }
    else if(convar==cvarPointType)
    {
        PointType=StringToInt(newValue);
    }
    else if(convar==cvarPointDelay)
    {
        PointDelay=StringToInt(newValue);
    }
    else if(convar==cvarAliveToEnable)
    {
        AliveToEnable=StringToInt(newValue);
    }
    else if(convar==cvarCrits)
    {
        BossCrits=bool:StringToInt(newValue);
    }
    else if(convar==cvarFirstRound)  //DEPRECATED
    {
        if(StringToInt(newValue)!=-1)
        {
            arenaRounds=StringToInt(newValue) ? 0 : 1;
        }
    }
    else if(convar==cvarArenaRounds)
    {
        arenaRounds=StringToInt(newValue);
    }
    else if(convar==cvarCircuitStun)
    {
        circuitStun=StringToFloat(newValue);
    }
    else if(convar==cvarCountdownPlayers)
    {
        countdownPlayers=StringToInt(newValue);
    }
    else if(convar==cvarCountdownTime)
    {
        countdownTime=StringToInt(newValue);
    }
    else if(convar==cvarCountdownHealth)
    {
        countdownHealth=StringToInt(newValue);
    }
    else if(convar==cvarLastPlayerGlow)
    {
        lastPlayerGlow=bool:StringToInt(newValue);
    }
    else if(convar==cvarBossTeleporter)
    {
        bossTeleportation=bool:StringToInt(newValue);
    }
    else if(convar==cvarShieldCrits)
    {
        shieldCrits=StringToInt(newValue);
    }
    else if(convar==cvarCaberDetonations)
    {
        allowedDetonations=StringToInt(newValue);
    }
    else if(convar==cvarGoombaDamage)
    {
        GoombaDamage=StringToFloat(newValue);
    }
    else if(convar==cvarGoombaRebound)
    {
        reboundPower=StringToFloat(newValue);
    }
    else if(convar==cvarUpdater)
    {
        #if defined _updater_included && !defined DEV_REVISION
        GetConVarInt(cvarUpdater) ? Updater_AddPlugin(UPDATE_URL) : Updater_RemovePlugin();
        #endif
    }
    else if(convar==cvarEnabled)
    {
        StringToInt(newValue) ? (changeGamemode=Enabled ? 0 : 1) : (changeGamemode=!Enabled ? 0 : 2);
    }
}

stock CountParticipants()
{
    playing=0;
    for(new client=1; client<=MaxClients; client++)
    {
        if(!IsValidClient(client))
            continue;
            
        Damage[client]=0;
        GoombaCount[client]=0;
        airstab[client]=0;
        uberTarget[client]=-1;
        emitRageSound[client]=true;
     
        if(GetClientTeam(client)>_:TFTeam_Spectator)
        {
            playing++;
        }
        
        QueryClientConVar(client, "cl_hud_minmode", ConVarQueryFinished:CvarCheck_MinimalHud, client);
        if(CheckMinHudAt[client]==INACTIVE)
        {
            CheckMinHudAt[client]=GetEngineTime()+0.1;
        }
    }
    
    return playing;
}

public CheckArena()
{
    if(PointType)
    {
        SetArenaCapEnableTime(float(45+PointDelay*(playing-1)));
    }
    else
    {
        SetArenaCapEnableTime(0.0);
        SetControlPoint(false);
    }
}

stock AssignTeam(client, TFTeam:team, desiredclass=1) // Move all this team switching stuff into a single stock
{
    if(!GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass")) // Initial living spectator check. A value of 0 means that no class is selected
    {
        SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TF2_GetPlayerClass(client)>=TFClass_Scout ? (_:TF2_GetPlayerClass(client)) : desiredclass); // So we assign one to prevent living spectators
    }

    SetEntProp(client, Prop_Send, "m_lifeState", 2);
    TF2_ChangeClientTeam(client, team);
    // SetEntProp(client, Prop_Send, "m_lifeState", 0); // Is this even needed? According to naydef, this is the other cause of living spectators. 
    TF2_RespawnPlayer(client);
    
    if(GetEntProp(client, Prop_Send, "m_iObserverMode") && IsPlayerAlive(client)) // If the initial checks fail, use brute-force.
    {
        TF2_SetPlayerClass(client, TF2_GetPlayerClass(client)>=TFClass_Scout ? (TF2_GetPlayerClass(client)) : (TFClassType:desiredclass), _, true);
        TF2_RespawnPlayer(client);
    }
}


public Action:ConfigTimer(Handle:timer, any:client)
{
    if(!IsValidClient(client))
        return Plugin_Stop;
        
    if(IsVoteInProgress())
    {
        CreateTimer(5.0, ConfigTimer, client, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Continue;
    }
        
    new Handle:menu = CreateMenu(MenuHandlerSetup);
    SetMenuTitle(menu, "%t", "FF2 Setup");
        
    new String:menuoption[128];
    if(BossCookieSetting[client]==FF2Setting_Unknown)
    {
        Format(menuoption,sizeof(menuoption),"%t","Configure Boss Toggle");
        AddMenuItem(menu, "FF2 Prefs Menu", menuoption);    
    }
    if(CompanionCookieSetting[client]==FF2Setting_Unknown)
    {
        Format(menuoption,sizeof(menuoption),"%t","Configure Companion Toggle");
        AddMenuItem(menu, "FF2 Prefs Menu", menuoption);
    }
    if(FF2ClientDifficulty[client]==FF2Difficulty_Unknown)
    {
        Format(menuoption,sizeof(menuoption),"%t","Configure Difficulty Setting");
        AddMenuItem(menu, "FF2 Prefs Menu", menuoption);    
    }
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, client, 20);
    return Plugin_Continue;
}

public MenuHandlerSetup(Handle:menu, MenuAction:action, param1, param2)
{
    if(action == MenuAction_Select)    
    {
        if(BossCookieSetting[param1]==FF2Setting_Unknown && param2==1)
        {
            BossMenu(param1, 0);
        }
        
        if(CompanionCookieSetting[param1]==FF2Setting_Unknown)
        {
            if((BossCookieSetting[param1]==FF2Setting_Unknown) && param2==2)
            {
                CompanionMenu(param1, 0);
            }
            else if((BossCookieSetting[param1]!=FF2Setting_Unknown) && param2==1)
            {
                CompanionMenu(param1, 0);        
            }
        }
        
        if(FF2ClientDifficulty[param1]==FF2Difficulty_Unknown)
        {
            if((BossCookieSetting[param1]==FF2Setting_Unknown && CompanionCookieSetting[param1]==FF2Setting_Unknown) && param2==3)
            {
                DifficultyMenu(param1, 0);
            }
            else if(((BossCookieSetting[param1]!=FF2Setting_Unknown && CompanionCookieSetting[param1]==FF2Setting_Unknown) || (BossCookieSetting[param1]==FF2Setting_Unknown && CompanionCookieSetting[param1]!=FF2Setting_Unknown)) && param2==2)
            {
                DifficultyMenu(param1, 0);
            }
            else if ((BossCookieSetting[param1]!=FF2Setting_Unknown && CompanionCookieSetting[param1]!=FF2Setting_Unknown) && param2==1)
            {
                DifficultyMenu(param1, 0);
            }
        }
        
    } 
    else if(action == MenuAction_End)
    {
       CloseHandle(menu);
    }
}

// Companion Menu
public Action:DifficultyMenu(client, args)
{
    if (IsValidClient(client))
    {    
        if(IsBoss(client) && CheckRoundState()!=FF2RoundState_RoundEnd)
        {
            CReplyToCommand(client, "{olive}[FF2]{default} %t", "ff2_changedifficulty_denied");
            return Plugin_Handled;
        }
    
        decl String:sEnabled[5];
        if(args)
        {
            new String:difficultyName[16];
            GetCmdArgString(difficultyName, sizeof(difficultyName));
        
            if(StrContains(difficultyName, "normal", false)!=-1)
            {
                FF2ClientDifficulty[client]=FF2Difficulty_Normal;
            }
            if(StrContains(difficultyName, "hard", false)!=-1)
            {
                FF2ClientDifficulty[client]=FF2Difficulty_Hard;
            }
            if(StrContains(difficultyName, "lunatic", false)!=-1)
            {
                FF2ClientDifficulty[client]=FF2Difficulty_Lunatic;
            }
            if(StrContains(difficultyName, "insane", false)!=-1)
            {
                FF2ClientDifficulty[client]=FF2Difficulty_Insane;
            }            
        
            IntToString(_:FF2ClientDifficulty[client], sEnabled, sizeof(sEnabled));
            SetClientCookie(client, FF2Cookie[Cookie_Difficulty], sEnabled);
            CReplyToCommand(client, "{olive}[FF2]{default} %t", "FF2 New Difficulty", RoundFloat(GetDifficultyModifier(FF2ClientDifficulty[client])*100));
            return Plugin_Handled;
        }
    
        GetClientCookie(client, FF2Cookie[Cookie_Difficulty], sEnabled, sizeof(sEnabled));
        FF2ClientDifficulty[client] = FF2Difficulty:StringToInt(sEnabled);    
        
        new Handle:menu = CreateMenu(MenuHandlerDifficulty);
        SetMenuTitle(menu, "%t\n%t", "FF2 Difficulty Settings Menu Title", (FF2ClientDifficulty[client]==FF2Difficulty_Unknown ? "ff2difficulty_undefined" : FF2ClientDifficulty[client]==FF2Difficulty_Normal ? "ff2difficulty_normal" : FF2ClientDifficulty[client]==FF2Difficulty_Hard ? "ff2difficulty_hard" : FF2ClientDifficulty[client]==FF2Difficulty_Lunatic ? "ff2difficulty_lunatic" : "ff2difficulty_insane"), RoundFloat(GetDifficultyModifier(FF2ClientDifficulty[client])*100));
        
        new String:menuoption[128];
        Format(menuoption,sizeof(menuoption),"%t","FF2 Normal Difficulty", RoundFloat(GetDifficultyModifier(FF2Difficulty_Normal)*100));
        AddMenuItem(menu, "FF2 Difficulty Menu", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","FF2 Hard Difficulty", RoundFloat(GetDifficultyModifier(FF2Difficulty_Hard)*100));
        AddMenuItem(menu, "FF2 Difficulty Menu", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","FF2 Lunatic Difficulty", RoundFloat(GetDifficultyModifier(FF2Difficulty_Lunatic)*100));
        AddMenuItem(menu, "FF2 Difficulty Menu", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","FF2 Insane Difficulty", RoundFloat(GetDifficultyModifier(FF2Difficulty_Insane)*100));
        AddMenuItem(menu, "FF2 Difficulty Menu", menuoption);    
        SetMenuExitButton(menu, true);
    
        DisplayMenu(menu, client, 20);
    }
    return Plugin_Handled;
}

public MenuHandlerDifficulty(Handle:menu, MenuAction:action, param1, param2)
{
    if(action == MenuAction_Select)    
    {
        decl String:sEnabled[5];
        new choice = param2 + 1;

        FF2ClientDifficulty[param1] = FF2Difficulty:choice;
        
        IntToString(choice, sEnabled, sizeof(sEnabled));
        SetClientCookie(param1, FF2Cookie[Cookie_Difficulty], sEnabled);
        CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 New Difficulty", RoundFloat(GetDifficultyModifier(FF2ClientDifficulty[param1])*100));
    } 
    else if(action == MenuAction_End)
    {
       CloseHandle(menu);
    }
}


public Action:BossMenuTimer(Handle:timer, any:clientpack)
{
    decl clientId;
    ResetPack(clientpack);
    clientId = ReadPackCell(clientpack);
    CloseHandle(clientpack);
    if (BossCookieSetting[clientId] == FF2Setting_Unknown)
    {
        BossMenu(clientId, 0);
    }
}

// Companion Menu
public Action CompanionMenu(int client, int args)
{
    if (IsValidClient(client))
    {   
        if(args)
        {
            char argstring[16];
            GetCmdArgString(argstring, sizeof(argstring));
        
            if(StrContains(argstring, "enable", false)!=-1 || StrContains(argstring, "on", false)!=-1)
            {
                SetClientSetting(client, FF2Cookie[Cookie_CompanionToggle], CompanionCookieSetting[client], FF2Setting_Enabled, true);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Companion Enabled");
            }
            if(StrContains(argstring, "disable", false)!=-1 || StrContains(argstring, "off", false)!=-1)
            {
                SetClientSetting(client, FF2Cookie[Cookie_CompanionToggle], CompanionCookieSetting[client], FF2Setting_Disabled, true);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Companion Disabled");
            }
            if(StrContains(argstring, "disablethismap", false)!=-1 || StrContains(argstring, "offthismap", false)!=-1)
            {
                SetClientSetting(client, _, CompanionCookieSetting[client], FF2Setting_Disabled, _);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Companion Disabled For Map");
            }
            return Plugin_Handled;
        }
        
        Menu cMenu = new Menu(MenuHandler_CompanionToggle);
        cMenu.SetTitle("%t\n%t", "FF2 Companion Toggle Menu Title", (CompanionCookieSetting[client]==FF2Setting_Disabled ? "ff2comp_disabled" : "ff2comp_enabled"));

        char menuoption[128];
        Format(menuoption,sizeof(menuoption),"%t","Enable Companion Selection");
        cMenu.AddItem("FF2 Companion Toggle Menu", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","Disable Companion Selection");
        cMenu.AddItem("FF2 Companion Toggle Menu", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","Disable Companion Selection For Map");
        cMenu.AddItem("FF2 Companion Toggle Menu", menuoption);    
        cMenu.ExitBackButton = true;
        cMenu.Display(client,MENU_TIME_FOREVER);    
    }
    return Plugin_Handled;
}

public int MenuHandler_CompanionToggle(Handle menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_Select)    
    {
        int choice = param2 + 1;
        SetClientSetting(param1, choice<3 ? FF2Cookie[Cookie_CompanionToggle] : null, CompanionCookieSetting[param1], FF2Prefs:choice, choice<3 ? true : false);
        
        if(1 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Enabled");
        }
        else if(2 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Disabled");
        }
        else if(3 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Disabled For Map");
        }
        
    } 
    else if(action == MenuAction_End)
    {
       delete menu;
    }
}

// Boss menu
public Action BossMenu(int client, int args)
{
    if (IsValidClient(client))
    {
        if(args)
        {
            char argstring[16];
            GetCmdArgString(argstring, sizeof(argstring));
        
            if(StrContains(argstring, "enable", false)!=-1 || StrContains(argstring, "on", false)!=-1)
            {
                SetClientSetting(client, FF2Cookie[Cookie_BossToggle], BossCookieSetting[client], FF2Setting_Enabled, true);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Enabled Notification");
            }
            if(StrContains(argstring, "disable", false)!=-1 || StrContains(argstring, "off", false)!=-1)
            {
                SetClientSetting(client, FF2Cookie[Cookie_BossToggle], BossCookieSetting[client], FF2Setting_Disabled, true);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
            }
            if(StrContains(argstring, "disablethismap", false)!=-1 || StrContains(argstring, "offthismap", false)!=-1)
            {
                SetClientSetting(client, _, BossCookieSetting[client], FF2Setting_Disabled, _);
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification For Map");
            }
            return Plugin_Handled;
        }
        
        Menu bMenu = new Menu(MenuHandler_BossToggle);
        bMenu.SetTitle("%t\n%t", "FF2 Toggle Menu Title", (BossCookieSetting[client]==FF2Setting_Disabled ? "ff2boss_disabled" : "ff2boss_enabled"));
        
        char menuoption[128];
        Format(menuoption,sizeof(menuoption),"%t","Enable Queue Points");
        bMenu.AddItem("Boss Toggle", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","Disable Queue Points");
        bMenu.AddItem("Boss Toggle", menuoption);
        Format(menuoption,sizeof(menuoption),"%t","Disable Queue Points For This Map");
        bMenu.AddItem("Boss Toggle", menuoption); 
        bMenu.ExitBackButton = true;
        bMenu.Display(client,MENU_TIME_FOREVER);        
    }
    return Plugin_Handled;
}

public int MenuHandler_BossToggle(Handle menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_Select)    
    {
        int choice = param2 + 1;
        SetClientSetting(param1, choice<3 ? FF2Cookie[Cookie_BossToggle] : null, BossCookieSetting[param1], FF2Prefs:choice, choice<3 ? true : false);
        
        if(1 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Enabled Notification");
        }
        else if(2 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
        }
        else if(3 == choice)
        {
            CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification For Map");
        }
    } 
    else if(action == MenuAction_End)
    {
       delete menu;
    }
}

public Action:Command_YouAreNext(client, args)
{
    if(!Enabled || !IsValidClient(client))
    {
        return Plugin_Handled;
    }
    
    if(IsVoteInProgress())
    {
        CreateTimer(5.0, Timer_RetryBossNotify, client);
        return Plugin_Handled;
    }
    
    if (client == 0)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return Plugin_Handled;
    }

    decl String:texts[256];
    new Handle:panel = CreatePanel();

    Format(texts, sizeof(texts), "%t\n%t", "to0_next", "to0_near");
    CRemoveTags(texts, sizeof(texts));

    ReplaceString(texts, sizeof(texts), "{olive}", "");
    ReplaceString(texts, sizeof(texts), "{default}", "");
    
    SetPanelTitle(panel, texts);
    
    Format(texts, sizeof(texts), "%t", "to0_to0_next");
    DrawPanelItem(panel, texts);
    
    SendPanelToClient(panel, client, SkipBossPanelH, 30);

    CloseHandle(panel);

    return Plugin_Handled;
}

public Action:Timer_RetryBossNotify(Handle:timer, any:client)
{
    Command_YouAreNext(client, 0);
}

public SkipBossPanelH(Handle:menu, MenuAction:action, param1, param2)
{
    switch(action)
    {
        case MenuAction_End: CloseHandle(menu);
        case MenuAction_Select:
        {
            Command_SetMyBoss(param1, 0);
        }
    }
    return;
}

public Action:Command_SetMyBoss(client, args)
{
    if (!client)
    {
        ReplyToCommand(client, "%t", "Command is in-game only");
        return Plugin_Handled;
    }
    
    if (!CheckCommandAccess(client, "ff2_boss", 0, true))
    {
        ReplyToCommand(client, "%t", "No Access");
        return Plugin_Handled;
    }

    if(args)
    {
        decl String:name[64], String:boss[64];
        GetCmdArgString(name, sizeof(name));

        for(new config; config<Specials; config++)
        {
            KvRewind(BossKV[config]);
            KvGetString(BossKV[config], "name", boss, sizeof(boss));
            if(KvGetNum(BossKV[config], "blocked",0)) continue;
            if(KvGetNum(BossKV[config], "hidden",0)) continue;            
            if(KvGetNum(BossKV[config], "donator", 0) && !CheckCommandAccess(client, "ff2_donator_bosses", 0, true)) continue;
            if(StrContains(boss, name, false)!=-1)
            {
                IsBossSelected[client]=true;
                strcopy(xIncoming[client], sizeof(xIncoming[]), boss);
                CReplyToCommand(client, "%t", "to0_boss_selected", boss);
                return Plugin_Handled;
            }

            KvGetString(BossKV[config], "filename", boss, sizeof(boss));
            if(StrContains(boss, name, false)!=-1)
            {
                IsBossSelected[client]=true;
                KvGetString(BossKV[config], "name", boss, sizeof(boss));
                strcopy(xIncoming[client], sizeof(xIncoming[]), boss);
                CReplyToCommand(client, "%t", "to0_boss_selected", boss);
                return Plugin_Handled;
            }
        }
        CReplyToCommand(client, "{olive}[FF2]{default} Boss could not be found!");
        return Plugin_Handled;
    }

    decl String:boss[64];
    new Handle:dMenu = CreateMenu(Command_SetMyBossH);

    SetMenuTitle(dMenu, "%t\n%t\n%t\n%t","ff2_boss_selection", xIncoming[client][0]=='\0' ? "None" : xIncoming[client], (BossCookieSetting[client]==FF2Setting_Disabled ? "ff2boss_disabled" : "ff2boss_enabled"), (CompanionCookieSetting[client]==FF2Setting_Disabled ? "ff2comp_disabled" : "ff2comp_enabled"), (FF2ClientDifficulty[client]==FF2Difficulty_Unknown ? "ff2difficulty_undefined" : FF2ClientDifficulty[client]==FF2Difficulty_Normal ? "ff2difficulty_normal" : FF2ClientDifficulty[client]==FF2Difficulty_Hard ? "ff2difficulty_hard" : FF2ClientDifficulty[client]==FF2Difficulty_Lunatic ? "ff2difficulty_lunatic" : "ff2difficulty_insane"), RoundFloat(GetDifficultyModifier(FF2ClientDifficulty[client])*100));
    
    Format(boss, sizeof(boss), "%t", "to0_random");
    AddMenuItem(dMenu, boss, boss);
    
    Format(boss, sizeof(boss), "%t", "thequeue");
    AddMenuItem(dMenu, boss, boss);
    
    Format(boss, sizeof(boss), "%t", "to0_resetpts");
    AddMenuItem(dMenu, boss, boss);
    
    Format(boss, sizeof(boss), "%t", BossCookieSetting[client] == FF2Setting_Disabled ? "to0_enablepts" : "to0_disablepts");
    AddMenuItem(dMenu, boss, boss);
    
    Format(boss, sizeof(boss), "%t", "to0_difficulty");
    AddMenuItem(dMenu, boss, boss);
    
    for(new config; config<Specials; config++)
    {    
        KvRewind(BossKV[config]);
        if(KvGetNum(BossKV[config], "blocked",0)) continue;
        if(KvGetNum(BossKV[config], "hidden",0)) continue;    
        if(KvGetNum(BossKV[config], "donator", 0) && !CheckCommandAccess(client, "ff2_donator_bosses", 0, true)) continue;
        KvGetString(BossKV[config], "name", boss, sizeof(boss));
        AddMenuItem(dMenu, boss, boss);
    }

    SetMenuExitButton(dMenu, true);
    DisplayMenu(dMenu, client, 20);
    return Plugin_Handled;
}

public Command_SetMyBossH(Handle:menu, MenuAction:action, param1, param2)
{
    switch(action)
    {
        case MenuAction_End:
        {
            CloseHandle(menu);
        }
        

        
        case MenuAction_Select:
        {
            switch(param2)
            {
                case 0: 
                {
                    IsBossSelected[param1]=true;
                    xIncoming[param1] = "";
                    CReplyToCommand(param1, "%t", "to0_comfirmrandom");
                    if((!IsBoss(param1) || IsBoss(param1) && CheckRoundState()==FF2RoundState_RoundEnd) && FF2ClientDifficulty[param1]==FF2Difficulty_Unknown)
                    {
                        DifficultyMenu(param1, 0);
                    }
                    return;
                }
                case 1: QueuePanelCmd(param1, 0);
                case 2: TurnToZeroPanel(param1, param1);
                case 3: BossMenu(param1, 0);
                case 4: DifficultyMenu(param1, 0);
                default:
                {
                    IsBossSelected[param1]=true;
                    GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
                    CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
                    if((!IsBoss(param1) || IsBoss(param1) && CheckRoundState()==FF2RoundState_RoundEnd) && FF2ClientDifficulty[param1]==FF2Difficulty_Unknown)
                    {
                        DifficultyMenu(param1, 0);
                    }
                }
            }
        }
    }
    return;
}

public Action:FF2_OnSpecialSelected(boss, &SpecialNum, String:SpecialName[], bool:preset)
{
    new client=GetClientOfUserId(GetBossUserId(boss));
    if(preset)
    {
        if(!boss && !StrEqual(xIncoming[client], ""))
        {
            CPrintToChat(client, "{olive}[FF2]{default} %t", "boss_selection_overridden");
        }
        return Plugin_Continue;
    }

    if(!boss && !StrEqual(xIncoming[client], ""))
    {
        strcopy(SpecialName, sizeof(xIncoming[]), xIncoming[client]);
        xIncoming[client] = "";
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

public Action:MakeModelTimer(Handle:timer, any:client)
{
    if(IsValidClient(Boss[client], true) && CheckRoundState()!=FF2RoundState_RoundEnd)
    {
        #if defined FILECHECK_ENABLED
        new String:model[PLATFORM_MAX_PATH], String:bossName[64];
        #else
        new String:model[PLATFORM_MAX_PATH];
        #endif
        KvRewind(BossKV[characterIdx[client]]);
        #if defined FILECHECK_ENABLED
        KvGetString(BossKV[characterIdx[client]], "filename", bossName, sizeof(bossName));
        #endif
        KvGetString(BossKV[characterIdx[client]], "model", model, sizeof(model));
        #if defined FILECHECK_ENABLED
        if(bSkipFileChecks[characterIdx[client]])
        {
            if(!FileExists(model))
                LogToFile(bLog, "[FF2 Bosses] Character '%s' will be skipping file checks for model '%s'", bossName, model);
            SetVariantString(model);
        }
        else
        {
            if(FileExists(model, true))
            {
                if(!IsModelPrecached(model))
                {
                    PrecacheModel(model);
                }
                SetVariantString(model);
            }
            else
            {
                SetVariantString("");
                LogToFile(bLog, "[FF2 Bosses] Character %s is missing file '%s'! Using default model!", bossName, model);
            }
        }
        AcceptEntityInput(Boss[client], "SetCustomModel");
        SetEntProp(Boss[client], Prop_Send, "m_bUseClassAnimations", 1);
        #else
        SetVariantString(model);
        AcceptEntityInput(Boss[client], "SetCustomModel");
        SetEntProp(Boss[client], Prop_Send, "m_bUseClassAnimations", 1);
        #endif
        return Plugin_Continue;
    }
    return Plugin_Stop;
}

EquipBoss(boss)
{
    new client=Boss[boss];
    DoOverlay(client, "");
    TF2_RemoveAllWeapons(client);
    if(cfgversion[characterIdx[boss]]>1)
    {
        Debug("Loading weapons for v2");
        decl String:classname[64], String:attributes[768];
        if(KvJumpToKey(BossKV[characterIdx[boss]], "weapons"))
        {
            while(KvGotoNextKey(BossKV[characterIdx[boss]]))
            {
                decl String:sectionName[32];
                KvGetSectionName(BossKV[characterIdx[boss]], sectionName, sizeof(sectionName));
                new index=StringToInt(sectionName);
                //NOTE: StringToInt returns 0 on failure which corresponds to tf_weapon_bat,
                //so there's no way to distinguish between an invalid string and 0.
                //Blocked on bug 6438: https://bugs.alliedmods.net/show_bug.cgi?id=6438
                if(index>=0)
                {
                    KvJumpToKey(BossKV[characterIdx[boss]], sectionName);
                    KvGetString(BossKV[characterIdx[boss]], "classname", classname, sizeof(classname));
                    if(classname[0]=='\0')
                    {
                        decl String:bossName[64];
                        KvGetString(BossKV[characterIdx[boss]], "name", bossName, sizeof(bossName), "=Failed Name=");
                        LogError("[FF2 Bosses] No classname specified for weapon %i (character %s)!", index, bossName);
                        KvGoBack(BossKV[characterIdx[boss]]);
                        continue;
                    }

                    KvGetString(BossKV[characterIdx[boss]], "attributes", attributes, sizeof(attributes));
                    if(attributes[0])
                    {
                        if(tf2attributes)
                        {
                            Format(attributes, sizeof(attributes), (!(FF2Flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? "214 ; %d ; 2 ; 3.1 ; %s" : "214 ; %d ; %s", bossKills[client], attributes);
                                //2: x3.1 damage
                        }
                        else
                        {
                            Format(attributes, sizeof(attributes), (!(FF2Flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? "214 ; %d ; 68 ; 2 ; 2 ; 3.1 ; %s" : "214 ; %d ; %s", bossKills[client], attributes);
                                //2: x3.1 damage
                                //68: +2 cap                    
                        }
                    }
                    else
                    {
                        if(tf2attributes)
                        {    
                            Format(attributes, sizeof(attributes), "2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1 ; 214 ; %d", bossKills[client]);
                                //2: x3.1 damage
                                //2025 + 2014: Team Shine Specialized Killstreak
                                //214: Kills
                        }
                        else
                        {
                            Format(attributes, sizeof(attributes), "68 ; 2 ; 2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1 ; 214 ; %d", bossKills[client]);
                                //2: x3.1 damage
                                //2025 + 2014: Team Shine Specialized Killstreak
                                //68: +2 cap  
                                //214: Kills
                        }
                    }

                    new weapon=SpawnWeapon(client, classname, index, KvGetNum(BossKV[characterIdx[boss]], "level", 101), KvGetNum(BossKV[characterIdx[boss]], "quality", 14), attributes, bool:KvGetNum(BossKV[characterIdx[boss]], "show", 0));
                    SetWeaponAmmo(client, weapon, KvGetNum(BossKV[characterIdx[boss]], "ammo", 0));
                    SetWeaponClip(client, weapon, KvGetNum(BossKV[characterIdx[boss]], "clip", 0));
                    if(StrEqual(classname, "tf_weapon_builder", false) && index!=735)  //PDA, normal sapper
                    {
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
                    }
                    else if(StrEqual(classname, "tf_weapon_sapper", false) || index==735)  //Sappers
                    {
                        SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
                        SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
                        SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
                    }

                    if(!KvGetNum(BossKV[characterIdx[boss]], "show", 0))
                    {
                        SetEntPropFloat(weapon, Prop_Send, "m_flModelScale", 0.001);
                        if(index==221 || index==572 || index==939 || index==999 || index==1013) // Workaround for jiggleboned weapons
                        {
                            SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", -1);
                            SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
                        }
                    }
                    else
                    {
                        new String:wModel[4][PLATFORM_MAX_PATH];
                        KvGetString(BossKV[characterIdx[boss]], "worldmodel", wModel[0], sizeof(wModel[]));
                        KvGetString(BossKV[characterIdx[boss]], "pyrovision", wModel[1], sizeof(wModel[]));
                        KvGetString(BossKV[characterIdx[boss]], "halloweenvision", wModel[2], sizeof(wModel[]));
                        KvGetString(BossKV[characterIdx[boss]], "romevision", wModel[3], sizeof(wModel[]));
                        for(new type=0;type<=3;type++)
                        {
                            if(wModel[type][0])
                            {
                                ConfigureWorldModelOverride(weapon, index, wModel[type], WorldModelType:type);
                            }
                        }
                    }

                    new rgba[4];
                    rgba[0]=KvGetNum(BossKV[characterIdx[boss]], "alpha", 255);
                    rgba[1]=KvGetNum(BossKV[characterIdx[boss]], "red", 255);
                    rgba[2]=KvGetNum(BossKV[characterIdx[boss]], "green", 255);
                    rgba[3]=KvGetNum(BossKV[characterIdx[boss]], "blue", 255);

                    SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
                    SetEntityRenderColor(weapon, rgba[1], rgba[2], rgba[3], rgba[0]);
                    
                    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);

                    KvGoBack(BossKV[characterIdx[boss]]);
                }
                else
                {
                    decl String:bossName[64];
                    KvGetString(BossKV[characterIdx[boss]], "name", bossName, sizeof(bossName), "=Failed Name=");
                    LogError("[FF2 Bosses] Invalid weapon index %s specified for character %s!", sectionName, bossName);
                }
            }
        }
        KvGoBack(BossKV[characterIdx[boss]]);
    }
    else
    {
        new String:weapon[64], String:attributes[768];
        for(new i=1; ; i++)
        {
            KvRewind(BossKV[characterIdx[boss]]);
            Format(weapon, 10, "weapon%i", i);
            if(KvJumpToKey(BossKV[characterIdx[boss]], weapon))
            {
                KvGetString(BossKV[characterIdx[boss]], "name", weapon, sizeof(weapon));
                KvGetString(BossKV[characterIdx[boss]], "attributes", attributes, sizeof(attributes));
                if(attributes[0])
                {
                    if(tf2attributes)
                    {
                        Format(attributes, sizeof(attributes), (!(FF2Flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? "214 ; %d ; 2 ; 3.1 ; %s" : "214 ; %d ; %s", bossKills[client], attributes);
                            //2: x3.1 damage
                    }
                    else
                    {
                        Format(attributes, sizeof(attributes), (!(FF2Flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? "214 ; %d ; 68 ; 2 ; 2 ; 3.1 ; %s" : "214 ; %d ; %s", bossKills[client], attributes);
                            //2: x3.1 damage
                            //68: +2 cap                    
                    }
                }
                else
                {
                    if(tf2attributes)
                    {    
                        Format(attributes, sizeof(attributes), "2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1 ; 214 ; %d", bossKills[client]);
                            //2: x3.1 damage
                            //2025 + 2014: Team Shine Specialized Killstreak
                            //214: Kills
                    }
                    else
                    {
                        Format(attributes, sizeof(attributes), "68 ; 2 ; 2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1 ; 214 ; %d", bossKills[client]);
                            //2: x3.1 damage
                            //2025 + 2014: Team Shine Specialized Killstreak
                            //68: +2 cap  
                            //214: Kills
                    }
                }
            
                new wepIdx=KvGetNum(BossKV[characterIdx[boss]], "index");
                new BossWeapon=SpawnWeapon(client, weapon, wepIdx, KvGetNum(BossKV[characterIdx[boss]], "level", 101), KvGetNum(BossKV[characterIdx[boss]], "quality", 14), attributes, bool:KvGetNum(BossKV[characterIdx[boss]], "show", 0));
                
                SetWeaponAmmo(client, BossWeapon, KvGetNum(BossKV[characterIdx[boss]], "ammo", 0));
                SetWeaponClip(client, BossWeapon, KvGetNum(BossKV[characterIdx[boss]], "clip", 0));
            
                if(!strcmp(weapon, "tf_weapon_builder") && wepIdx!=735)
                {
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
                }
                else if(!strcmp(weapon, "tf_weapon_sapper") || wepIdx==735)
                {
                    SetEntProp(BossWeapon, Prop_Send, "m_iObjectType", 3);
                    SetEntProp(BossWeapon, Prop_Data, "m_iSubType", 3);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
                    SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
                }
            
                if(!KvGetNum(BossKV[characterIdx[boss]], "show", 0))
                {
                    SetEntPropFloat(BossWeapon, Prop_Send, "m_flModelScale", 0.001);
                    if(wepIdx==221 || wepIdx==572 || wepIdx==939 || wepIdx==999 || wepIdx==1013) // Workaround for jiggleboned weapons
                    {
                        SetEntProp(BossWeapon, Prop_Send, "m_iWorldModelIndex", -1);
                        SetEntProp(BossWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
                    }
                }
                else
                {
                    new String:wModel[4][PLATFORM_MAX_PATH];
                    KvGetString(BossKV[characterIdx[boss]], "worldmodel", wModel[0], sizeof(wModel[]));
                    KvGetString(BossKV[characterIdx[boss]], "pyrovision", wModel[1], sizeof(wModel[]));
                    KvGetString(BossKV[characterIdx[boss]], "halloweenvision", wModel[2], sizeof(wModel[]));
                    KvGetString(BossKV[characterIdx[boss]], "romevision", wModel[3], sizeof(wModel[]));
                    for(new type=0;type<=3;type++)
                    {
                        if(wModel[type][0])
                        {
                            ConfigureWorldModelOverride(BossWeapon, wepIdx, wModel[type], WorldModelType:type);
                        }
                    }
                }
            
                new rgba[4];
                rgba[0]=KvGetNum(BossKV[characterIdx[boss]], "alpha", 255);
                rgba[1]=KvGetNum(BossKV[characterIdx[boss]], "red", 255);
                rgba[2]=KvGetNum(BossKV[characterIdx[boss]], "green", 255);
                rgba[3]=KvGetNum(BossKV[characterIdx[boss]], "blue", 255);

                SetEntityRenderMode(BossWeapon, RENDER_TRANSCOLOR);
                SetEntityRenderColor(BossWeapon, rgba[1], rgba[2], rgba[3], rgba[0]);

                
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", BossWeapon);
            }
            else
            {
                break;
            }
        }
        KvGoBack(BossKV[characterIdx[boss]]);
    }

    #if defined _tf2attributes_included
    if(!(FF2Flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT) && tf2attributes)
    {
        TF2Attrib_SetByDefIndex(client, 259, 1.0);  // Mantreads Stomp
        TF2Attrib_SetByDefIndex(client, 68, (TF2_GetPlayerClass(client) == TFClass_Scout ? 1.0 : 2.0));  // +1 x cap rate ? +2x cap rate?
        TF2Attrib_SetByDefIndex(client, 135, 0.0);
        TF2Attrib_SetByDefIndex(client, 181, 1.0);
    }
    #endif

    new TFClassType:class=TFClassType:KvGetNum(BossKV[characterIdx[boss]], "class", 1);
    if(TF2_GetPlayerClass(client)!=class)
    {
        TF2_SetPlayerClass(client, class, _, !GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass") ? true : false);
    }
}

stock bool ConfigureWorldModelOverride(int entity, int index, const char[] model, WorldModelType type, bool wearable=false)
{
    if(!FileExists(model, true))
        return false;
        
    int modelIndex=PrecacheModel(model);
    if(!type)
    {
        SetEntProp(entity, Prop_Send, "m_nModelIndex", modelIndex);
    }
    else
    {
        SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", modelIndex, _, _:type);
        SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", (!wearable ? GetEntProp(entity, Prop_Send, "m_iWorldModelIndex") : GetEntProp(entity, Prop_Send, "m_nModelIndex")), _, 0);    
    }
    return true;
}

stock int SetWeaponClip(int client, int slot, int clip)
{
    int weapon = GetPlayerWeaponSlot(client, slot);
    if (IsValidEntity(weapon))
    {
        SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
    }
}

stock int SetWeaponAmmo(int client, int slot, int ammo)
{
    int weapon = GetPlayerWeaponSlot(client, slot);
    if (IsValidEntity(weapon))
    {
        int iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
        int iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
        SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
    }
}

public Action:MakeBoss(Handle:timer, any:boss)
{
    new client=Boss[boss];
    if(!IsValidClient(client))
    {
        return Plugin_Continue;
    }

    if(!IsPlayerAlive(client))
    {
        if(!CheckRoundState())
        {
            TF2_RespawnPlayer(client);
        }
        else
        {
            return Plugin_Continue;
        }
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(GetClientTeam(client)!=BossTeam) // No Living Spectators Pls
    {
       AssignTeam(client, TFTeam:BossTeam, KvGetNum(BossKV[characterIdx[boss]], "class", 1));
    }
    
    if(!CheckRoundState()) // Only perform this before round starts
    {
        switch(cfgversion[characterIdx[boss]]) // calculate HP and compensate if companions are missing
        {
            case 0, 1: BossHealthMax[boss]=RoundFloat((ParseHealthFormula(boss)*GetDifficultyModifier(FF2ClientDifficulty[Boss[boss]]))*GetCompensationCount());
            default: BossHealthMax[boss]=RoundFloat((ParseFormula(boss, "health", RoundFloat(Pow((760.8+float(playing))*(float(playing)-1.0), 1.0341)+2046.0))*GetDifficultyModifier(FF2ClientDifficulty[Boss[boss]]))*GetCompensationCount());
        }
        BossLivesMax[boss]=BossLives[boss]=ParseFormula(boss, "lives", 1);
        BossHealth[boss]=BossHealthLast[boss]=BossHealthMax[boss]*BossLivesMax[boss];
        BossRageDamage[boss]=ParseFormula(boss, cfgversion[characterIdx[boss]]>1 ? "rage_damage" : "ragedamage", GetConVarInt(cvarDefaultRageDamage));
        BossSpeed[boss]=float(ParseFormula(boss, cfgversion[characterIdx[boss]]>1 ? "speed" : "maxspeed", GetConVarInt(cvarDefaultMoveSpeed)));
        for(new slot=1; slot<8; slot++)
        {
            BossCharge[boss][slot]=0.0;
        }
    }
    
    IsBossSelected[client]=false;
    SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
    TF2_RemovePlayerDisguise(client);
    TF2_SetPlayerClass(client, TFClassType:KvGetNum(BossKV[characterIdx[boss]], "class", 1), _, !GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass") ? true : false);
    SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);  //Temporary:  Used to prevent boss overheal

    switch(KvGetNum(BossKV[characterIdx[boss]], "pickups", 0))  //Check if the boss is allowed to pickup health/ammo
    {
        case 1:
        {
            FF2Flags[client]|=FF2FLAG_ALLOW_HEALTH_PICKUPS;
        }
        case 2:
        {
            FF2Flags[client]|=FF2FLAG_ALLOW_AMMO_PICKUPS;
        }
        case 3:
        {
            FF2Flags[client]|=FF2FLAG_ALLOW_HEALTH_PICKUPS|FF2FLAG_ALLOW_AMMO_PICKUPS;
        }
    }
    
    switch(KvGetNum(BossKV[characterIdx[boss]], "overrides", 0))
    {
        case 1: // Disable Speed Management
        {
            FF2Flags[client]|=FF2FLAG_DISABLE_SPEED_MANAGEMENT;
        }
        case 2: // Disable Weapon Management
        {
            FF2Flags[client]|=FF2FLAG_DISABLE_WEAPON_MANAGEMENT;
        }
    }
    

    if(!HasSwitched)
    {
        switch(KvGetNum(BossKV[characterIdx[boss]], "bossteam", 0))
        {
            case 1: // Always Random
            {            
                SwitchTeams((currentBossTeam==1) ? (_:TFTeam_Blue) : (_:TFTeam_Red) , (currentBossTeam==1) ? (_:TFTeam_Red) : (_:TFTeam_Blue), true);
            }
            case 2: // RED Boss
            {
                SwitchTeams(_:TFTeam_Red, _:TFTeam_Blue, true);
            }
            case 3: // BLU Boss
            {
                SwitchTeams(_:TFTeam_Blue, _:TFTeam_Red, true);
            }
            default: // Determined by "ff2_force_team" ConVar
            {
                SwitchTeams((blueBoss) ? (_:TFTeam_Blue) : (_:TFTeam_Red), (blueBoss) ? (_:TFTeam_Red) : (_:TFTeam_Blue), true);
            }
        }
        HasSwitched=true;    
    }
    
    CreateTimer(0.2, MakeModelTimer, boss);
    if(!IsVoteInProgress() && GetClientClassinfoCookie(client))
    {
        HelpPanelBoss(boss);
    }

    if(!IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }
    
    new entity=-1;
    while((entity=FindEntityByClassname2(entity, "tf_wear*"))!=-1)
    {
        if(IsBoss(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")))
        {
            switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
            {
                case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542, 577, 599, 673, 729, 791, 839, 1015, 5607:  //Action slot items
                {
                    //NOOP
                }
                default:
                {
                    TF2_RemoveWearable(client, entity);
                }
            }
        }
    }

    entity=-1;
    while((entity=FindEntityByClassname2(entity, "tf_powerup_bottle"))!=-1)
    {
        if(IsBoss(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")))
        {
            TF2_RemoveWearable(client, entity);
        }
    }

    EquipBoss(boss);
    KSpreeCount[boss]=0;
    BossCharge[boss][0]=0.0;
    if(DeadRunMode && IsPreparing)
    {
        drboss=boss;
        SetEntityMoveType(client, MOVETYPE_NONE);
    }
    return Plugin_Continue;
}

/*
    Returns the the TeamNum of an entity.
    Works for both clients and things like healthpacks.
    Returns -1 if the entity doesn't have the m_iTeamNum prop.

    GetEntityTeamNum() doesn't always return properly when tf_arena_use_queue is set to 0
*/

stock TFTeam GetEntityTeamNum(int iEnt)
{
    return view_as<TFTeam>(GetEntProp(iEnt, Prop_Send, "m_iTeamNum"));
}

stock SetEntityTeamNum(iEnt, iTeam)
{
    SetEntProp(iEnt, Prop_Send, "m_iTeamNum", iTeam);
}


stock RemovePlayerTarge(client)
{
    new entity=MaxClients+1;
    while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)
    {
        new index=GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
        if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
        {
            if(index==131 || index==406 || index==1099 || index==1144)  //Chargin' Targe, Splendid Screen, Tide Turner, Festive Chargin' Targe
            {
                TF2_RemoveWearable(client, entity);
            }
        }
    }
}

stock RemovePlayerBack(client, indices[], length)
{
    if(length<=0)
    {
        return;
    }

    new entity=MaxClients+1;
    while((entity=FindEntityByClassname2(entity, "tf_wearable"))!=-1)
    {
        new String:netclass[32];
        if(GetEntityNetClass(entity, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
        {
            new index=GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
            if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
            {
                for(new i; i<length; i++)
                {
                    if(index==indices[i])
                    {
                        TF2_RemoveWearable(client, entity);
                    }
                }
            }
        }
    }
}

stock FindPlayerBack(client, index)
{
    new entity=MaxClients+1;
    while((entity=FindEntityByClassname2(entity, "tf_wearable"))!=-1)
    {
        new String:netclass[32];
        if(GetEntityNetClass(entity, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable") && GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex")==index && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
        {
            return entity;
        }
    }
    return -1;
}


public Action:Timer_Uber(Handle:timer, any:medigunid)
{
    new medigun=EntRefToEntIndex(medigunid);
    if(medigun && IsValidEntity(medigun) && CheckRoundState()==FF2RoundState_RoundRunning)
    {
        new client=GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
        new Float:charge=GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
        if(IsValidClient(client, true) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")==medigun)
        {
            new target=GetHealingTarget(client);
            if(charge>0.05)
            {
                TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5);
                if(IsValidClient(target, true))
                {
                    TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
                    uberTarget[client]=target;
                }
                else
                {
                    uberTarget[client]=-1;
                }
            }
        }

        if(charge<=0.05)
        {
            CreateTimer(3.0, Timer_ResetUberCharge, EntIndexToEntRef(medigun));
            FF2Flags[client]&=~FF2FLAG_UBERREADY;
            return Plugin_Stop;
        }
    }
    else
    {
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public Action:Timer_ResetUberCharge(Handle:timer, any:medigunid)
{
    new medigun=EntRefToEntIndex(medigunid);
    if(IsValidEntity(medigun))
    {
        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+0.40);
    }
    return Plugin_Continue;
}

public Action:Command_GetHPCmd(client, args)
{
    if(!IsValidClient(client) || !Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        return Plugin_Continue;
    }

    Command_GetHP(client);
    return Plugin_Handled;
}

public Action:Command_GetHP(client)  //TODO: This can rarely show a very large negative number if you time it right
{
    if(IsBoss(client) || GetGameTime()>=HPTime)
    {
        new String:health[512];
        new String:lives[10], String:name[64];
        for(new target; target<=MaxClients; target++)
        {
            if(IsBoss(target))
            {
                new boss=Boss[target];
                KvRewind(BossKV[characterIdx[boss]]);
                KvGetString(BossKV[characterIdx[boss]], "name", name, sizeof(name), "=Failed name=");
                if(BossLives[boss]>1)
                {
                    Format(lives, sizeof(lives), "x%i", BossLives[boss]);
                }
                else
                {
                    strcopy(lives, sizeof(lives), "");
                }
                
                Format(health, sizeof(health), "%s\n%t", health, "ff2_hp", name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
    
                CPrintToChatAll("{olive}[FF2]{default} %t", "ff2_hp", name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
                BossHealthLast[boss]=BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1);
            }
        }

        for(new target; target<=MaxClients; target++)
        {
            if(IsValidClient(target) && !(FF2Flags[target] & FF2FLAG_HUDDISABLED))
            {
                if(!Companions)
                {
                    if(!minimalHUD[target])
                    {
                        ShowGameText(target, (DeadRunMode == true ? "ico_ghost" : (DrawGameTimerAt!=INACTIVE) ? ((timeleft>=10 && timeleft<30) ? "ico_notify_thirty_seconds" : (timeleft<10) ? "ico_notify_ten_seconds" : "ico_notify_sixty_seconds") : roundOvertime ? "ico_notify_flag_moving_alt" : "leaderboard_streak"), _, health);
                    }
                    else
                    {
                        PrintCenterText(target, health);
                    }
                }
                else
                {
                    PrintCenterText(target, health);            
                }
            }
        }

        if(GetGameTime()>=HPTime)
        {
            healthcheckused++;
            HPTime=GetGameTime()+(healthcheckused<3 ? 20.0 : 80.0);
        }
        return Plugin_Continue;
    }

    if(LivingMercs>1)
    {
        new String:waitTime[128];
        for(new target; target<=MaxClients; target++)
        {
            if(IsBoss(target))
            {
                Format(waitTime, sizeof(waitTime), "%s %i,", waitTime, BossHealthLast[Boss[target]]);
            }
        }
        CPrintToChat(client, "{olive}[FF2]{default} %t", "wait_hp", RoundFloat(HPTime-GetGameTime()), waitTime);
    }
    return Plugin_Continue;
}

public Action:Command_SetNextBoss(client, args)
{
    new String:name[64], String:boss[64];

    if(!args)
    {
        ReplyToCommand(client, "[FF2] Usage: /ff2_special <bossname>");
        return Plugin_Handled;
    }
    
    GetCmdArgString(name, sizeof(name));
    for(new config; config<Specials; config++)
    {
        KvRewind(BossKV[config]);
        KvGetString(BossKV[config], "name", boss, sizeof(boss));
        if(StrContains(boss, name, false)!=-1)
        {
            Incoming[0]=config;
            CReplyToCommand(client, "{olive}[FF2]{default} Set the next boss to %s", boss);
            return Plugin_Handled;
        }

        KvGetString(BossKV[config], "filename", boss, sizeof(boss));
        if(StrContains(boss, name, false)!=-1)
        {
            Incoming[0]=config;
            KvGetString(BossKV[config], "name", boss, sizeof(boss));
            CReplyToCommand(client, "{olive}[FF2]{default} Set the next boss to %s", boss);
            return Plugin_Handled;
        }
    }
    CReplyToCommand(client, "{olive}[FF2]{default} Boss could not be found!");
    return Plugin_Handled;
}

/*public Command_SetNextBossH(Handle:menu, MenuAction:action, param1, param2)
{
    switch(action)
    {
        case MenuAction_End:
        {
            CloseHandle(menu);
        }
        
        case MenuAction_Select:
        {
            
        }
    }
    return;
}*/

public Action:Command_MakeNextBoss(client, args)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    if(args!=1)
    {
        if(!args && IsValidClient(client))
        {
            for(new vplayer=1;vplayer<=MaxClients;vplayer++)
            {
                if(!IsValidClient(vplayer))
                    continue;
                if(IsNextBoss[vplayer])
                {
                    IsNextBoss[vplayer]=false;
                }
            }
            IsNextBoss[client]=true;
            LogMessage("\"%N\" is the next boss", client);
            CPrintToChatAll("{olive}[FF2]{default} %t", "ff2_next_boss", client);
            Command_YouAreNext(client, 0);
            return Plugin_Handled;
        }
        else
        {
            CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_setboss <target>");
            return Plugin_Handled;
        }
    }
    
    new String:targetName[PLATFORM_MAX_PATH];
    GetCmdArg(1, targetName, sizeof(targetName));

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;
    
    if((target_count=ProcessTargetString(targetName, client, target_list, MaxClients, 0, target_name, sizeof(target_name), tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    for(new target; target<target_count; target++)
    {
        if(IsClientSourceTV(target_list[target]) || IsClientReplay(target_list[target]))
        {
            continue;
        }
        
        for(new vplayer=1;vplayer<=MaxClients;vplayer++)
        {
            if(!IsValidClient(vplayer))
                continue;
            if(IsNextBoss[vplayer])
            {
                IsNextBoss[vplayer]=false;
            }
        }
        IsNextBoss[target_list[target]]=true;
        LogAction(client, target_list[target], "\"%L\" set \"%L\" as the next boss", client, target_list[target]);
        CPrintToChatAll("{olive}[FF2]{default} %s will become the boss next round!", target_name);
        Command_YouAreNext(target_list[target], 0);
    }
    return Plugin_Handled;
}

public Action:Command_Points(client, args)
{
    if(!Enabled2)
    {
        return Plugin_Continue;
    }

    if(args!=2)
    {
        if(args==1 && IsValidClient(client))
        {
            new String:queuePoints[80];
            GetCmdArg(1, queuePoints, sizeof(queuePoints));
            new points=StringToInt(queuePoints);
            
            SetClientQueuePoints(client, GetClientQueuePoints(client)+points);
            
            LogMessage("\"%N\" gave themselves %i queue points", client, points);
            CReplyToCommand(client, "{olive}[FF2]{default} You gave yourself %d queue points", points);
            return Plugin_Handled;
        }
        else
        {
            CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_addpoints <target> <points>");
            return Plugin_Handled;
        }
    }
    
    new String:queuePoints[80];
    new String:targetName[PLATFORM_MAX_PATH];
    GetCmdArg(1, targetName, sizeof(targetName));
    GetCmdArg(2, queuePoints, sizeof(queuePoints));
    new points=StringToInt(queuePoints);

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;

    
    
    if((target_count=ProcessTargetString(targetName, client, target_list, MaxClients, 0, target_name, sizeof(target_name), tn_is_ml))<=0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    for(new target; target<target_count; target++)
    {
        if(IsClientSourceTV(target_list[target]) || IsClientReplay(target_list[target]))
        {
            continue;
        }

        SetClientQueuePoints(target_list[target], GetClientQueuePoints(target_list[target])+points);
        LogAction(client, target_list[target], "\"%L\" added %d queue points to \"%L\"", client, points, target_list[target]);
        CReplyToCommand(client, "{olive}[FF2]{default} Added %d queue points to %s", points, target_name);
    }
    return Plugin_Handled;
}

public Action:Command_VoteCharset(client, args)
{
    isCharsetOverride=true;
    CReplyToCommand(client, "{olive}[FF2]{default} Starting charset vote!");
    LogMessage("\"%N\" initiated a charset vote!", client);
    CreateTimer(0.1, Timer_DisplayCharsetVote);
    return Plugin_Handled;
}


public Action:Command_Charset(client, args)
{
    if(!args)
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_charset <charset>");
        return Plugin_Handled;
    }

    new String:charset[32], String:rawText[16][16];
    GetCmdArgString(charset, sizeof(charset));
    new amount=ExplodeString(charset, " ", rawText, 16, 16);
    for(new i; i<amount; i++)
    {
        StripQuotes(rawText[i]);
    }
    ImplodeStrings(rawText, amount, " ", charset, sizeof(charset));

    new String:config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, CharsetCFG);


    new Handle:Kv=CreateKeyValues("");
    FileToKeyValues(Kv, config);
    for(new i; ; i++)
    {
        KvGetSectionName(Kv, config, sizeof(config));
        if(StrContains(config, charset, false)>=0)
        {
            CReplyToCommand(client, "{olive}[FF2]{default} Charset for nextmap is %s", config);
            isCharSetSelected=true;
            FF2CharSet=i;
            break;
        }

        if(!KvGotoNextKey(Kv))
        {
            CReplyToCommand(client, "{olive}[FF2]{default} Charset not found");
            break;
        }
    }
    CloseHandle(Kv);
    return Plugin_Handled;
}

public Action:Command_LoadCharset(client, args)
{
    if(!args)
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_loadcharset <charset>");
        return Plugin_Handled;
    }
    
    
    new String:charset[32], String:rawText[16][16];
    GetCmdArgString(charset, sizeof(charset));
    new amount=ExplodeString(charset, " ", rawText, 16, 16);
    for(new i; i<amount; i++)
    {
        StripQuotes(rawText[i]);
    }
    ImplodeStrings(rawText, amount, " ", charset, sizeof(charset));

    new String:config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, CharsetCFG);

    new Handle:Kv=CreateKeyValues("");
    FileToKeyValues(Kv, config);
    for(new i; ; i++)
    {
        KvGetSectionName(Kv, config, sizeof(config));
        if(StrContains(config, charset, false)>=0)
        {
            FF2CharSet=i;
            LoadCharset=true;
            if(CheckRoundState()==FF2RoundState_Setup || CheckRoundState()==FF2RoundState_RoundRunning)
            {
                CReplyToCommand(client, "{olive}[FF2]{default} The current character set is set to be switched to %s!", config);
                return Plugin_Handled;
            }
            
            CReplyToCommand(client, "{olive}[FF2]{default} Character set has been switched to %s", config);
            FindCharacters();
            strcopy(FF2CharSetString, 2, "");
            LoadCharset=false;
            break;
        }

        if(!KvGotoNextKey(Kv))
        {
            CReplyToCommand(client, "{olive}[FF2]{default} Charset not found");
            break;
        }
    }
    CloseHandle(Kv);
    return Plugin_Handled;
}

public Action Command_ReloadFF2(client, args)
{
    ReloadFF2 = true;
    switch (CheckRoundState())
    {
        case FF2RoundState_Loading, FF2RoundState_RoundEnd:
        {
            CReplyToCommand(client, "{olive}[FF2]{default} The plugin has been reloaded.");
            ServerCommand("sm plugins reload freak_fortress_2");
        }
        default:
        {
            CReplyToCommand(client, "{olive}[FF2]{default} The plugin is set to reload.");
        }
    }
    return Plugin_Handled;
}

public Action:Command_ReloadCharset(client, args)
{
    LoadCharset = true;
    if(CheckRoundState()==FF2RoundState_Setup || CheckRoundState()==FF2RoundState_RoundRunning)
    {
        CReplyToCommand(client, "{olive}[FF2]{default} Current character set is set to reload!");
        return Plugin_Handled;
    }
    CReplyToCommand(client, "{olive}[FF2]{default} Current character set has been reloaded!");
    FindCharacters();
    LoadCharset=false;
    return Plugin_Handled;
}

public Action:Command_ReloadFF2Weapons(client, args)
{
    ReloadWeapons = true;
    if(CheckRoundState()==FF2RoundState_Setup || CheckRoundState()==FF2RoundState_RoundRunning)
    {
        CReplyToCommand(client, "{olive}[FF2]{default} %s is set to reload!", WeaponCFG);
        return Plugin_Handled;
    }
    CReplyToCommand(client, "{olive}[FF2]{default} %s has been reloaded!", WeaponCFG);
    CacheWeapons();
    ReloadWeapons=false;
    return Plugin_Handled;
}

public Action:Command_ReloadFF2Configs(client, args)
{
    ReloadConfigs = true;
    if(CheckRoundState()==FF2RoundState_Setup || CheckRoundState()==FF2RoundState_RoundRunning)
    {
        CReplyToCommand(client, "{olive}[FF2]{default} All configs are set to be reloaded!");
        return Plugin_Handled;
    }
    CacheWeapons();
    CheckToChangeMapDoors();
    CheckToTeleportToSpawn();
    FindCharacters();
    ReloadConfigs = false;
    return Plugin_Handled;
}
public Action:Command_ReloadSubPlugins(client, args)
{
    if(Enabled)
    {
        switch(args)
        {
            case 0: // Reload ALL subplugins
            {
                DisableSubPlugins(true);
                EnableSubPlugins(true);
                decl String:path[PLATFORM_MAX_PATH], String:filename[PLATFORM_MAX_PATH];
                BuildPath(Path_SM, path, sizeof(path), "plugins/freak_fortress_2");
                decl FileType:filetype;
                new Handle:directory=OpenDirectory(path);
                while(ReadDirEntry(directory, filename, sizeof(filename), filetype))
                {
                    if(filetype==FileType_File && StrContains(filename, ".smx", false)!=-1)
                    {
                        ServerCommand("sm plugins unload freak_fortress_2/%s", filename);
                        ServerCommand("sm plugins load freak_fortress_2/%s", filename);
                    }
                }
                CReplyToCommand(client, "{olive}[FF2]{default} Reloaded subplugins!");
            }
            case 1: // Reload a specific subplugin
            {
                new count=0;
                new String:pluginName[PLATFORM_MAX_PATH];
                GetCmdArg(1, pluginName, sizeof(pluginName));
                BuildPath(Path_SM, pluginName, sizeof(pluginName), "plugins/freaks/%s.ff2", pluginName);
                if(FileExists(pluginName))
                {
                    ReplaceString(pluginName, sizeof(pluginName), "addons/sourcemod/plugins/freaks/", "freaks/", false);
                    ServerCommand("sm plugins unload %s", pluginName);
                    ServerCommand("sm plugins load %s", pluginName);
                    ReplaceString(pluginName, sizeof(pluginName), "freaks/", " ", false);
                    CReplyToCommand(client, "{olive}[FF2]{default} Reloaded subplugin %s!", pluginName);  
                }
                else
                {
                    count++;
                }
                
                BuildPath(Path_SM, pluginName, sizeof(pluginName), "plugins/freak_fortress_2/%s", pluginName);
                if(FileExists(pluginName))
                {
                    ReplaceString(pluginName, sizeof(pluginName), "addons/sourcemod/plugins/freak_fortress_2/", "freak_fortress_2/", false);
                    ServerCommand("sm plugins unload %s", pluginName);
                    ServerCommand("sm plugins load %s", pluginName);
                    ReplaceString(pluginName, sizeof(pluginName), "freak_fortress_2/", " ", false);
                    CReplyToCommand(client, "{olive}[FF2]{default} Reloaded subplugin %s!", pluginName);  
                }
                else
                {
                    count++;
                }
                
                if(count>=2)
                {

                    CReplyToCommand(client, "{olive}[FF2]{default} Subplugin %s does not exist!", pluginName);
                    return Plugin_Handled;
                }         
            }
            default:
            {
                ReplyToCommand(client, "[SM] Usage: ff2_reload_subplugins <plugin name> (omit <plugin name> to reload ALL subplugins)");    
            }
        }
    }
    return Plugin_Handled;
}

public Action:Command_Point_Disable(client, args)
{
    if(Enabled)
    {
        SetControlPoint(false);
    }
    return Plugin_Handled;
}

public Action:Command_Point_Enable(client, args)
{
    if(Enabled)
    {
        SetControlPoint(true);
    }
    return Plugin_Handled;
}

stock SetControlPoint(bool:enable)
{
    new controlPoint=MaxClients+1;
    while((controlPoint=FindEntityByClassname2(controlPoint, "team_control_point"))!=-1)
    {
        if(controlPoint>MaxClients && IsValidEdict(controlPoint))
        {
            AcceptEntityInput(controlPoint, (enable ? "ShowModel" : "HideModel"));
            SetVariantInt(enable ? 0 : 1);
            AcceptEntityInput(controlPoint, "SetLocked");
        }
    }
}

stock FindControlPoint()
{
    new controlPoint=MaxClients+1;
    while((controlPoint=FindEntityByClassname2(controlPoint, "team_control_point"))!=-1)
    {
        if(controlPoint>MaxClients && IsValidEdict(controlPoint))
        {
           return controlPoint;
        }
    }
    return -1;
}

stock SetArenaCapEnableTime(Float:time)
{
    new entity=-1;
    if((entity=FindEntityByClassname2(-1, "tf_logic_arena"))!=-1 && IsValidEdict(entity))
    {
        new String:timeString[32];
        FloatToString(time, timeString, sizeof(timeString));
        DispatchKeyValue(entity, "CapEnableDelay", timeString);
    }
}

public OnClientPostAdminCheck(client)
{
    FF2_AddHooks(client);
    
    if(nomusic)
    {
        strcopy(currentBGM[client], PLATFORM_MAX_PATH, "ff2_stop_music");
    }
    
    if(CheckRoundState()==FF2RoundState_RoundRunning)
    {
        PlayBGMAt[client]=GetEngineTime()+2.0;
    }
}

public FF2_AddHooks(client)
{
    strcopy(xIncoming[client], sizeof(xIncoming[]), "");
    SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
    SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
    SDKHook(client, SDKHook_PreThink, Client_PreThink);
    
    FF2Flags[client]=0;
    Damage[client]=0;
    uberTarget[client]=-1;
    QueryClientConVar(client, "cl_hud_minmode", ConVarQueryFinished:CvarCheck_MinimalHud, client);

    if(AreClientCookiesCached(client))
    {
        new String:buffer[24];
        GetClientCookie(client, FF2Cookies, buffer, sizeof(buffer));
        if(!buffer[0])
        {
            SetClientCookie(client, FF2Cookies, "0 1 1 1 3 3 3");
        }
    }
}

public OnClientDisconnect(client)
{
    if(Enabled)
    {
        if(IsNextBoss[client])
        {
            IsNextBoss[client]=false;
        }
    
        if (IsBoss(client) && !CheckRoundState())
        {
            new bool:omit[MaxClients+1];
            omit[client]=true;
                
            new boss=GetBossIndex(client);
            if(!boss)
            {
                SetClientQueuePoints(client, 0);
            }
            
            Boss[boss]=GetRandomValidClient(omit);
            omit[Boss[boss]]=true;

            if (IsValidClient(Boss[boss]))
            {    
                CreateTimer(0.1, MakeBoss, GetBossIndex(Boss[boss]));
                CPrintToChat(Boss[boss], "{olive}[FF2]{default} %t", "Replace Disconnected Boss 2");
                CPrintToChatAll("{olive}[FF2]{default} %t", "Replace Disconnected Boss", client, Boss[boss]);
                TF2_RespawnPlayer(Boss[boss]);
            }
        }
        
        if(IsValidClient(client) && CheckRoundState()==FF2RoundState_RoundRunning)
        {
            if (client == g_NextHale)
            {
                KillTimer(g_NextHaleTimer);
            }
        
            strcopy(xIncoming[client], sizeof(xIncoming[]), "");
            BossCookieSetting[client] = FF2Setting_Unknown;
            CompanionCookieSetting[client] = FF2Setting_Unknown;
            CheckAlivePlayersAt=GetEngineTime()+0.2;
        }
        
        PlayBGMAt[client]=INACTIVE;
        strcopy(currentBGM[client], PLATFORM_MAX_PATH, "");
        FF2Flags[client]=0;
        Damage[client]=0;
        uberTarget[client]=-1;
    }
}

public void CvarCheck_MinimalHud(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] value)
{
    if(!IsValidClient(client))
        return;
    minimalHUD[client]=view_as<bool>(StringToInt(value));
}

stock int GetAlivePlayerCount(int type)
{
    int count;
    for(int client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
            continue;
        if(type==1 && IsBoss(client))
        {
            count++;
        }
        else if(type==2 && GetClientTeam(client)==MercTeam)
        {
            count++;
        }
        else if(type==3 && !IsBoss(client) && (GetClientTeam(client)==BossTeam || (FF2_GetFF2flags(client) & FF2FLAG_ALLOWSPAWNINBOSSTEAM)))
        {
            count++;
        }
    }
    return count;
}

stock float GetDifficultyModifier(FF2Difficulty difficulty)
{
    switch(difficulty)
    {
        case FF2Difficulty_Normal, FF2Difficulty_Unknown: return 1.0;
        case FF2Difficulty_Hard: return GetConVarFloat(cvarHardModifier);
        case FF2Difficulty_Lunatic: return GetConVarFloat(cvarLunaticModifier);
        case FF2Difficulty_Insane: return GetConVarFloat(cvarInsaneModifier);
        default: return 1.0;
    }
    return 1.0;
}

stock int GetRandomClient()
{
    int clientIdx;
    for(int client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
            continue;
        if(IsBoss(client))
            continue;
            
        clientIdx=client;
    }
    return clientIdx;
}

stock FindSentry(client)
{
    int entity=-1;
    while((entity=FindEntityByClassname2(entity, "obj_sentrygun"))!=-1)
    {
        if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
        {
            return entity;
        }
    }
    return -1;
}

stock OnlyScoutsLeft()
{
    int scouts;
    for(int client; client<=MaxClients; client++)
    {
        if(IsValidClient(client, true) && GetClientTeam(client)==MercTeam)
        {
            if(TF2_GetPlayerClass(client)!=TFClass_Scout)
            {
                return 0;
            }
            else
            {
                scouts++;
            }
        }
    }
    return scouts;
}

stock GetIndexOfWeaponSlot(client, slot)
{
    int weapon=GetPlayerWeaponSlot(client, slot);
    return (weapon>MaxClients && IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
    if(!Enabled)
    {
        return;
    }
    
    if(IsBoss(client) && (condition==TFCond_Jarated || condition==TFCond_MarkedForDeath || (condition==TFCond_Dazed && TF2_IsPlayerInCondition(client, TFCond:42))))
    {
        TF2_RemoveCondition(client, condition);
    }
    
    if(condition==TFCond_BlastJumping)
    {
        FF2Flags[client]|=FF2FLAG_ROCKET_JUMPING;
    }
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
    if(!Enabled)
    {
        return;
    }
    
    if(TF2_GetPlayerClass(client)==TFClass_Scout)
    {
        switch(condition)
        {
            case TFCond_CritHype: TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
            case TFCond_Bonked:
            {
                if(IsBoss(client))
                {
                    return;
                }
            
                char UnBonk[PLATFORM_MAX_PATH];
                UnBonkSlowDown[client]=true;
                #if defined _tf2attributes_included
                if(tf2attributes)
                    TF2Attrib_SetByDefIndex(client, 54, 0.85);
                #endif
                TF2_AddCondition(client, TFCond_MarkedForDeath, 10.0);
                strcopy(UnBonk, PLATFORM_MAX_PATH, UnBonked[GetRandomInt(0, sizeof(UnBonked)-1)]);    
                EmitSoundToAll(UnBonk,client);
            }
            case TFCond_MarkedForDeath: 
            {
                if(UnBonkSlowDown[client])
                {
                    #if defined _tf2attributes_included
                    if(tf2attributes)
                        TF2Attrib_RemoveByDefIndex(client, 54);
                    #endif
                    UnBonkSlowDown[client]=false;
                }
            }    
        }
    }
    
    if(condition==TFCond_BlastJumping)
    {
        FF2Flags[client]&=~FF2FLAG_ROCKET_JUMPING;
    }
}

public void Frame_RegenPlayer(int client)
{
    if(IsPlayerAlive(client))
    {
        TF2_RegeneratePlayer(client);
    }
}

public void Frame_StopTaunt(int client)
{
    new boss=GetBossIndex(client);
    if(boss>=0 && BossCharge[boss][0]>=100.0 && FF2ClientDifficulty[client]<FF2Difficulty_Lunatic)
    {
        if(IsPlayerAlive(client) && GetEntProp(client, Prop_Send, "m_iTauntItemDefIndex") == -1)
        {
            if(!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
            {
                TF2_RemoveCondition(client,TFCond_Taunting);
                float up[3];
                up[2]=220.0;
                TeleportEntity(client,NULL_VECTOR, NULL_VECTOR,up);
            }
    
            else if(TF2_IsPlayerInCondition(client, TFCond_Taunting))
            {
                TF2_RemoveCondition(client,TFCond_Taunting);
            }
        
            UseRage(client);
        }
    }
}

public void Frame_BotRage(int client)
{
    if(IsValidClient(Boss[client]))
    {
        FakeClientCommandEx(Boss[client], GetRandomInt(0,1)==1 ? "voicemenu 0 0" : "taunt");
    }
}

public void Frame_RemoveHonorbound(int client)
{
    if(IsPlayerAlive(client))
    {
        int melee=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
        if(IsValidEntity(melee))
        {
            char katana[64];
            GetEdictClassname(melee, katana, sizeof(katana));
            if(GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex")==357 && !StrContains(katana, "tf_weapon_katana", false))
            {
                SetEntProp(melee, Prop_Send, "m_bIsBloody", 1);
                if(GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy")<1)
                {
                    SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
                }
            }
        }
    }        
}

public Action:UserMessage_Jarate(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
    new client=BfReadByte(bf);
    new victim=BfReadByte(bf);
    new boss=GetBossIndex(victim);
    if(boss!=-1)
    {
        new jarate=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
        if(jarate!=-1)
        {
            new index=GetEntProp(jarate, Prop_Send, "m_iItemDefinitionIndex");
            if((index==58 || index==1083 || index==1105) && GetEntProp(jarate, Prop_Send, "m_iEntityLevel")!=-122)  //-122 is the Jar of Ants which isn't really Jarate
            {
                BossCharge[boss][0]-=GetConVarFloat(cvarSubtractRageOnJarate);
                if(BossCharge[boss][0]<0.0)
                {
                    BossCharge[boss][0]=0.0;
                }
            }
        }
    }
    return Plugin_Continue;
}


public Action:CMD_Taunt(client, const String:command[], args)
{
    if(!Enabled || !IsPlayerAlive(client) || CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        return Plugin_Continue;
    }
    RequestFrame(Frame_StopTaunt, client);
    return Plugin_Continue;
}

public Action:CMD_VoiceMenu(client, const String:command[], args)
{
    if(!Enabled || !IsPlayerAlive(client) || CheckRoundState()!=FF2RoundState_RoundRunning || !IsBoss(client) || args!=2)
    {
        return Plugin_Continue;
    }

    new String:arg1[4], String:arg2[4];
    GetCmdArg(1, arg1, sizeof(arg1));
    GetCmdArg(2, arg2, sizeof(arg2));
    if(StringToInt(arg1) || StringToInt(arg2))  //We only want "voicemenu 0 0"-thanks friagram for pointing out edge cases
    {
        return Plugin_Continue;
    }

    new boss=GetBossIndex(client);
    if(boss>=0 && BossCharge[boss][0]>=100.0 && FF2ClientDifficulty[client]<FF2Difficulty_Lunatic)
    {
        UseRage(client);
        return Plugin_Stop;
    }
        
    return Plugin_Continue;
}

UseRage(client) // Activating our RAGE ability here
{
    new boss=GetBossIndex(client);
    if(boss==-1 || !Boss[boss] || !IsValidEdict(Boss[boss]))
    {
        return;
    }
    if(RoundFloat(BossCharge[boss][0])==100 && FF2ClientDifficulty[client]<FF2Difficulty_Lunatic)
    {
        
        // used by both
        char ability[10], lives[MaxAbilities][3], abilityName[64], pluginName[64];
        
        // load v1 abilities
        for(new i=1; i<MaxAbilities; i++)
        {
            Format(ability, sizeof(ability), "ability%i", i);
            KvRewind(BossKV[characterIdx[boss]]);
            if(KvJumpToKey(BossKV[characterIdx[boss]], ability))
            {
                if(KvGetNum(BossKV[characterIdx[boss]], "arg0", 0))
                {
                    continue;
                }
                KvGetString(BossKV[characterIdx[boss]], "life", ability, sizeof(ability));
                if(!ability[0])
                {
                    KvGetString(BossKV[characterIdx[boss]], "plugin_name", pluginName, sizeof(pluginName));
                    KvGetString(BossKV[characterIdx[boss]], "name", abilityName, sizeof(abilityName));
                    if(!UseAbility(boss, pluginName, abilityName, 0))
                    {
                        return;
                    }
                }
                else
                {
                    new count=ExplodeString(ability, " ", lives, MaxAbilities, 3);
                    for(new j; j<count; j++)
                    {
                        if(StringToInt(lives[j])==BossLives[boss])
                        {
                            KvGetString(BossKV[characterIdx[boss]], "plugin_name", pluginName, sizeof(pluginName));
                            KvGetString(BossKV[characterIdx[boss]], "name", abilityName, sizeof(abilityName));
                            if(!UseAbility(boss, pluginName, abilityName, 0))
                            {
                                return;
                            }
                            break;
                        }
                    }
                }
            }
        }
        
        // load v2 abilities
        KvRewind(BossKV[characterIdx[boss]]);
        if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities"))
        {
            while(KvGotoNextKey(BossKV[characterIdx[boss]]))
            {
                KvGetSectionName(BossKV[characterIdx[boss]], pluginName, sizeof(pluginName));
                KvJumpToKey(BossKV[characterIdx[boss]], pluginName);
                while(KvGotoNextKey(BossKV[characterIdx[boss]]))
                {
                    KvGetSectionName(BossKV[characterIdx[boss]], abilityName, sizeof(abilityName));
                    KvJumpToKey(BossKV[characterIdx[boss]], abilityName);
                    if(KvGetNum(BossKV[characterIdx[boss]], "slot", 0))
                    {
                        continue;
                    }

                    KvGetString(BossKV[characterIdx[boss]], "life", ability, sizeof(ability), "");
                    if(!ability[0])
                    {
                        UseAbility2(boss, pluginName, abilityName, 0);
                    }
                    else
                    {
                        new count=ExplodeString(ability, " ", lives, MaxAbilities, 3);
                        for(new n; n<count; n++)
                        {
                            if(StringToInt(lives[n])==BossLives[boss])
                            {
                                UseAbility(boss, pluginName, abilityName, 0);
                                KvGoBack(BossKV[characterIdx[boss]]);
                                break;
                            }
                        }
                    }
                    KvGoBack(BossKV[characterIdx[boss]]);
                }
                KvGoBack(BossKV[characterIdx[boss]]);
            }
        }

        float position[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);

        char sound[PLATFORM_MAX_PATH];

        if(RandomSound("sound_ability_serverwide", sound, sizeof(sound), boss) || FindSound("ability", sound, sizeof(sound), boss, true))
        {
            EmitSoundToAll(sound);
            EmitSoundToAll(sound);
        }
        
        if(RandomSoundAbility("sound_ability", sound, PLATFORM_MAX_PATH, boss))
        {
            FF2Flags[Boss[boss]]|=FF2FLAG_TALKING;
            EmitSoundToAll(sound, client, _, _, _, _, _, client, position);
            EmitSoundToAll(sound, client, _, _, _, _, _, client, position);

            for(new target=1; target<=MaxClients; target++)
            {
                if(IsClientInGame(target) && target!=Boss[boss])
                {
                    EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
                    EmitSoundToClient(target, sound, client, _, _, _, _, _, client, position);
                }
            }
            FF2Flags[Boss[boss]]&=~FF2FLAG_TALKING;
        }
        emitRageSound[boss]=true;
    }
}

public Action:CMD_Suicide(client, const String:command[], args)
{
    new bool:canBossSuicide=GetConVarBool(cvarBossSuicide);
    if(Enabled && IsBoss(client) && (canBossSuicide ? !CheckRoundState() : true) && CheckRoundState()!=FF2RoundState_RoundEnd)
    {
        CPrintToChat(client, "{olive}[FF2]{default} %t", canBossSuicide ? "Boss Suicide Pre-round" : "Boss Suicide Denied");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action:CMD_ChangeClass(client, const String:command[], args)
{
    if(Enabled && IsBoss(client) && IsPlayerAlive(client))
    {
        //Don't allow the boss to switch classes but instead set their *desired* class (for the next round)
        decl String:class[16];
        GetCmdArg(1, class, sizeof(class));
        SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", !TF2_GetClass(class) ? (TF2_GetPlayerClass(client)>=TFClass_Scout ? (_:TF2_GetPlayerClass(client)) : GetRandomInt(1,9)) : (_:TF2_GetClass(class)));
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

stock TFTeam:TF2_GetTeam(client, const String:team[])
{
    if(StrEqual(team, "red", false))
    {
        if(!IsBoss(client)) return (TFTeam:BossTeam==TFTeam_Blue ? TFTeam_Red : TFTeam_Blue);
        return (TFTeam:BossTeam==TFTeam_Blue ? TFTeam_Blue : TFTeam_Red);
    }
    if(StrEqual(team, "blue", false))
    {
        if(!IsBoss(client)) return (TFTeam:BossTeam==TFTeam_Red ? TFTeam_Blue : TFTeam_Red);
        return (TFTeam:BossTeam==TFTeam_Red ? TFTeam_Red : TFTeam_Blue);
    }
    if(StrEqual(team, "auto", false)) return TFTeam:(!IsBoss(client) ? MercTeam : BossTeam);
    if(StrEqual(team, "spectate", false)) return TFTeam:(!IsBoss(client) ? (GetConVarBool(FindConVar("mp_allowspectators")) ? (_:TFTeam_Spectator) : MercTeam) : BossTeam);
    return TFTeam:(IsBoss(client) ? BossTeam : MercTeam);
}

stock TFTeam:CheckTeam(client)
{
    if(!IsBoss(client)) return TFTeam:MercTeam;
    return TFTeam:BossTeam;
}

public Action:CMD_JoinTeam(client, const String:command[], args)
{
    if(!Enabled || !args || RoundCount<arenaRounds)
    {
        return Plugin_Continue;
    }

    new String:teamString[10];
    GetCmdArg(1, teamString, sizeof(teamString));
    TF2_ChangeClientTeam(client, TF2_GetTeam(client, teamString));

    if(CheckRoundState()!=FF2RoundState_RoundRunning && !IsBoss(client) || !IsPlayerAlive(client))  //No point in showing the VGUI if they can't change teams
    {
        switch(TF2_GetClientTeam(client))
        {
            case TFTeam_Red:
            {
                ShowVGUIPanel(client, "class_red");
            }
            case TFTeam_Blue:
            {
                ShowVGUIPanel(client, "class_blue");
            }
        }
    }
    return Plugin_Handled;
}


public EndBossRound()
{
    if(!GetConVarBool(cvarCountdownResult))
    {
        for(new client=1; client<=MaxClients; client++)  //Thx MasterOfTheXP
        {
            if(IsValidClient(client, true))
            {
                ForcePlayerSuicide(client);
            }
        }
    }
    else
    {
        ForceTeamWin(0);  //Stalemate
    }
    timeDisplay="88:88";
}

public Action:OverTimeAlert(Handle:timer)
{
    if(CheckRoundState()!=FF2RoundState_RoundRunning)
    {
        roundOvertime=false;
        return Plugin_Stop;
    }    
    
    decl String:HUDTextOT[768];
    if(useCPvalue && capTeam>1)
    {        
        new Float:captureValue;
        new cp = -1; 
        while ((cp = FindEntityByClassname(cp, "team_control_point")) != -1) 
        { 
            captureValue=SDKCall(SDKGetCPPct, cp, capTeam);
            SetHudTextParams(-1.0, 0.17, 1.1, capTeam==2 ? 191 : capTeam==3 ? 90 : 0, capTeam==2 ? 57 : capTeam==3 ? 140 : 0, capTeam==2 ? 28 : capTeam==3 ? 173 : 0, 255, makeScroll ? 2 : 0);
            Format(HUDTextOT, sizeof(HUDTextOT), "%t", "ff2_cpt_value", RoundFloat(captureValue*100));
            Format(timeDisplay, sizeof(timeDisplay), "%t", "overtime_percentage", RoundFloat(captureValue*100));
            for(new client; client<=MaxClients; client++)
            {
                if(IsValidClient(client) && ((FF2Flags[client] & FF2FLAG_HUDDISABLED) || Companions || LivingMercs>1))
                {
                    ShowSyncHudText(client, timeleftHUD, HUDTextOT);
                }
            }    
        }
        
        if(captureValue<=0.0)
        {
            EndBossRound();
            capTeam=0;
            roundOvertime=false;
            return Plugin_Stop;
        }
    }
    else
    {
        SetHudTextParams(-1.0, 0.17, 1.1, GetRandomInt(0,255), GetRandomInt(0,255), GetRandomInt(0,255), 255, makeScroll ? 2 : 0);
        Format(HUDTextOT, sizeof(HUDTextOT), "%t", "ff2_cpt_overtime");
        for(new client; client<=MaxClients; client++)
        {
            if(IsValidClient(client))
            {
                ShowSyncHudText(client, timeleftHUD, HUDTextOT);
            }
        }
        
        if(!isCapping)
        {
            EndBossRound();
            roundOvertime=false;
            return Plugin_Stop;
        }    
    }    

    switch(GetRandomInt(0,1))
    {
        case 0: 
        {
            new String:OTAlerting[PLATFORM_MAX_PATH];
            strcopy(OTAlerting, sizeof(OTAlerting), OTVoice[GetRandomInt(0, sizeof(OTVoice)-1)]);    
            EmitSoundToAll(OTAlerting);
        }
    }
    return Plugin_Continue;
}

stock GetPlayerMaxHealth(client)
{
    return GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client);
}

public Action:Timer_Damage(Handle:timer, any:userid)
{
    new client=GetClientOfUserId(userid);
    if(IsValidClient(client))
    {
        CPrintToChat(client, "{olive}[FF2] %t. %t{default}", "damage", Damage[client], "scores", RoundFloat(Damage[client]/600.0));
    }
    return Plugin_Continue;
}


// True if they weren't in the condition and were set to it.
stock bool:InsertCond(iClient, TFCond:iCond, Float:flDuration = TFCondDuration_Infinite)
{
    if (!TF2_IsPlayerInCondition(iClient, iCond))
    {
        TF2_AddCondition(iClient, iCond, flDuration);
        return true;
    }
    return false;
}

// True if the condition was removed.
stock bool:RemoveCond(iClient, TFCond:iCond)
{
    if (TF2_IsPlayerInCondition(iClient, iCond))
    {
        TF2_RemoveCondition(iClient, iCond);
        return true;
    }
    return false;
}

stock bool IsClientInvincible(int client)
{
    return (TF2_IsPlayerInCondition(client, TFCond_Ubercharged) || 
    TF2_IsPlayerInCondition(client, TFCond_UberchargeFading) || 
    TF2_IsPlayerInCondition(client, TFCond_UberchargedHidden) ||
    TF2_IsPlayerInCondition(client, TFCond_UberchargedCanteen) ||
    TF2_IsPlayerInCondition(client, TFCond_UberchargedOnTakeDamage) || 
    TF2_IsPlayerInCondition(client, TFCond_UberBulletResist) || 
    TF2_IsPlayerInCondition(client, TFCond_UberBlastResist) || 
    TF2_IsPlayerInCondition(client, TFCond_UberFireResist));
}

public Action:TF2_OnPlayerTeleport(client, teleporter, &bool:result)
{
    if(Enabled && IsBoss(client))
    {
        switch(bossTeleportation)
        {
            case -1:  //No bosses are allowed to use teleporters
            {
                result=false;
            }
            case 1:  //All bosses are allowed to use teleporters
            {
                result=true;
            }
        }
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

stock void StripShield(int client, int attacker, float position[3])
{
    TF2_RemoveWearable(client, shield[client]);
    EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
    EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
    TF2_AddCondition(client, TFCond_Bonked, 0.1);
    TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
    shieldHP[client]=0.0;
    shield[client]=0;    
}

stock GetClientCloakIndex(client)
{
    if(!IsValidClient(client))
    {
        return -1;
    }

    new weapon=GetPlayerWeaponSlot(client, 4);
    if(!IsValidEntity(weapon))
    {
        return -1;
    }

    new String:classname[64];
    GetEntityClassname(weapon, classname, sizeof(classname));
    if(strncmp(classname, "tf_weapon", 6, false))
    {
        return -1;
    }
    return GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
}

stock SpawnSmallHealthPackAt(client, TFTeam:team=TFTeam_Unassigned)
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    new healthpack=CreateEntityByName("item_healthkit_small"), Float:position[3];
    GetClientAbsOrigin(client, position);
    position[2]+=20.0;
    if(IsValidEntity(healthpack))
    {
        DispatchKeyValue(healthpack, "OnPlayerTouch", "!self,Kill,,0,-1");
        DispatchSpawn(healthpack);
        SetEntProp(healthpack, Prop_Send, "m_iTeamNum", _:team, 4);
        SetEntityMoveType(healthpack, MOVETYPE_VPHYSICS);
        new Float:velocity[3];//={float(GetRandomInt(-10, 10)), float(GetRandomInt(-10, 10)), 50.0};  //Q_Q
        velocity[0]=float(GetRandomInt(-10, 10)), velocity[1]=float(GetRandomInt(-10, 10)), velocity[2]=50.0;  //I did this because setting it on the creation of the vel variable was creating a compiler error for me.
        TeleportEntity(healthpack, position, NULL_VECTOR, velocity);
    }
}

stock IncrementHeadCount(client)
{
    if(!TF2_IsPlayerInCondition(client, TFCond_DemoBuff))
    {
        TF2_AddCondition(client, TFCond_DemoBuff, -1.0);
    }

    new decapitations=GetEntProp(client, Prop_Send, "m_iDecapitations");
    new health=GetClientHealth(client);
    SetEntProp(client, Prop_Send, "m_iDecapitations", decapitations+1);
    SetEntityHealth(client, health+15);
    TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}

stock FindTeleOwner(client)
{
    if(!IsValidClient(client, true))
    {
        return -1;
    }

    new teleporter=GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
    new String:classname[32];
    if(IsValidEntity(teleporter) && GetEdictClassname(teleporter, classname, sizeof(classname)) && !strcmp(classname, "obj_teleporter", false))
    {
        new owner=GetEntPropEnt(teleporter, Prop_Send, "m_hBuilder");
        if(IsValidClient(owner, false))
        {
            return owner;
        }
    }
    return -1;
}

stock TF2_IsPlayerCritBuffed(client)
{
    return (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) || TF2_IsPlayerInCondition(client, TFCond:34) || TF2_IsPlayerInCondition(client, TFCond:35) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph));
}

public Action:Timer_DisguiseBackstab(Handle:timer, any:userid)
{
    new client=GetClientOfUserId(userid);
    if(IsValidClient(client))
    {
        RandomlyDisguise(client);
    }
    return Plugin_Continue;
}

stock RandomlyDisguise(client)    //Original code was mecha's, but the original code is broken and this uses a better method now.
{
    if(IsValidClient(client, true))
    {
        new disguiseTarget=-1;
        new team=GetClientTeam(client);

        new Handle:disguiseArray=CreateArray();
        for(new clientcheck; clientcheck<=MaxClients; clientcheck++)
        {
            if(IsValidClient(clientcheck) && GetClientTeam(clientcheck)==team && clientcheck!=client)
            {
                PushArrayCell(disguiseArray, clientcheck);
            }
        }

        if(GetArraySize(disguiseArray)<=0)
        {
            disguiseTarget=client;
        }
        else
        {
            disguiseTarget=GetArrayCell(disguiseArray, GetRandomInt(0, GetArraySize(disguiseArray)-1));
            if(!IsValidClient(disguiseTarget))
            {
                disguiseTarget=client;
            }
        }

        new class=GetRandomInt(0, 4);
        new TFClassType:classArray[]={TFClass_Scout, TFClass_Pyro, TFClass_Medic, TFClass_Engineer, TFClass_Sniper};
        CloseHandle(disguiseArray);

        if(TF2_GetPlayerClass(client)==TFClass_Spy)
        {
            TF2_DisguisePlayer(client, TFTeam:team, classArray[class], disguiseTarget);
        }
        else
        {
            TF2_AddCondition(client, TFCond_Disguised, -1.0);
            SetEntProp(client, Prop_Send, "m_nDisguiseTeam", team);
            SetEntProp(client, Prop_Send, "m_nDisguiseClass", classArray[class]);
            SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", disguiseTarget);
            SetEntProp(client, Prop_Send, "m_iDisguiseHealth", 200);
        }
    }
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
    if(Enabled && IsBoss(client) && CheckRoundState()==FF2RoundState_RoundRunning && !TF2_IsPlayerCritBuffed(client) && !BossCrits)
    {
        result=false;
        return Plugin_Changed;
    }
    else if (Enabled && !IsBoss(client) && CheckRoundState()==FF2RoundState_RoundRunning && IsValidEntity(weapon))
    {
        if (!StrContains(weaponname, "tf_weapon_club"))
        {
            SickleClimbWalls(client, weapon);
        }
    }
    return Plugin_Continue;
}

public SickleClimbWalls(client, weapon)     //Credit to Mecha the Slag
{
    if (!IsValidClient(client) || (GetClientHealth(client)<=15) )return;

    new String:classname[64];
    new Float:vecClientEyePos[3];
    new Float:vecClientEyeAng[3];
    GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
    GetClientEyeAngles(client, vecClientEyeAng);       // Get the angle the player is looking

    //Check for colliding entities
    TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_VISIBLE_AND_NPCS|CONTENTS_WINDOW|CONTENTS_GRATE, RayType_Infinite, TraceRayDontHitSelf, client);

    if (!TR_DidHit(INVALID_HANDLE)) return;

    new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
    GetEdictClassname(TRIndex, classname, sizeof(classname));
    if (!StrEqual(classname, "worldspawn")) return;

    new Float:fNormal[3];
    TR_GetPlaneNormal(INVALID_HANDLE, fNormal);
    GetVectorAngles(fNormal, fNormal);

    if (fNormal[0] >= 30.0 && fNormal[0] <= 330.0) return;
    if (fNormal[0] <= -30.0) return;

    new Float:pos[3];
    TR_GetEndPosition(pos);
    new Float:distance = GetVectorDistance(vecClientEyePos, pos);

    if (distance >= 100.0) return;

    new Float:fVelocity[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

    fVelocity[2] = 600.0;

    TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
    TF2Attrib_SetByDefIndex(client, 236, 1.0);
    SDKHooks_TakeDamage(client, client, client, 15.0, DMG_CLUB, GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
    TF2Attrib_RemoveByDefIndex(client, 236);
    if (!IsBoss(client)) ClientCommand(client, "playgamesound \"%s\"", "player\\taunt_clip_spin.wav");
    
    RequestFrame(Timer_NoAttacking, EntIndexToEntRef(weapon));
}

stock SetNextAttack(weapon, Float:duration = 0.0)
{
    if (weapon <= MaxClients) return;
    if (!IsValidEntity(weapon)) return;
    new Float:next = GetGameTime() + duration;
    SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", next);
    SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", next);
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
    return (entity != data);
}

public Timer_NoAttacking(any:ref) // Action: Handle:timer, 
{
    new weapon = EntRefToEntIndex(ref);
    SetNextAttack(weapon, 1.56);
}

stock GetClientWithMostQueuePoints(bool:omit[])
{
    new winner, nexthale;
    for(new client=1;client<=MaxClients;client++)
    {
        if(nexthale)
            break;
        if(!IsValidClient(client) || TF2_GetClientTeam(client)<=TFTeam_Spectator)
            continue;
        if(IsNextBoss[client])
        {
            winner=client;
            IsNextBoss[client]=false;
            nexthale++;
        }
    }
    
    if(!nexthale)
    {
        for(new client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client))
            {
                if(BossCookieSetting[client]==FF2Setting_Disabled) // Skip if bosses are disabled for them
                    continue;
                if(GetClientQueuePoints(client)>=GetClientQueuePoints(winner) && !omit[client])
                {
                    if(TF2_GetClientTeam(client)>TFTeam_Spectator)
                    {
                        winner=client;
                    }
                }
            }
        }
    }
    return winner;
}

stock GetRandomValidClient(bool:omit[])
{
    new companion;
    for(new client=1; client<=MaxClients; client++)
    {
        if(IsValidClient(client) && !omit[client])
        {
            if(CompanionCookieSetting[client]==FF2Setting_Disabled) // Skip clients who have disabled being able to be selected as a companion
                continue;
        
            if(TF2_GetClientTeam(client)>TFTeam_Spectator)
            {
                companion=client;
            }
        }
    }
    
    if(!companion)
    {
        for(new client=1; client<MaxClients; client++)
        {
            if(IsValidClient(client) && !omit[client])
            {
                if(GetClientTeam(client)>_:TFTeam_Spectator) // Ignore the companion toggle pref if we can't find available clients
                {
                    companion=client;
                }
            }        
        }
    }
    return companion;
}

stock LastBossIndex()
{
    for(new client=1; client<=MaxClients; client++)
    {
        if(!Boss[client])
        {
            return client-1;
        }
    }
    return 0;
}

stock GetAbilityArgument(index,const String:plugin_name[],const String:ability_name[],arg,defvalue=0)
{
    if(index==-1 || characterIdx[index]==-1 || !BossKV[characterIdx[index]])
        return 0;
    KvRewind(BossKV[characterIdx[index]]);
    new String:s[10];
    for(new i=1; i<MaxAbilities; i++)
    {
        Format(s,10,"ability%i",i);
        if(KvJumpToKey(BossKV[characterIdx[index]],s))
        {
            new String:ability_name2[64];
            KvGetString(BossKV[characterIdx[index]], "name",ability_name2,64);
            if(strcmp(ability_name,ability_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            new String:plugin_name2[64];
            KvGetString(BossKV[characterIdx[index]], "plugin_name",plugin_name2,64);
            if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            Format(s,10,"arg%i",arg);
            return KvGetNum(BossKV[characterIdx[index]], s,defvalue);
        }
    }
    return 0;
}

stock GetAbilityArgument2(boss, const String:pluginName[], const String:abilityName[], const String:argument[], defaultValue=0)
{
    if(boss==-1 || characterIdx[boss]==-1 || !BossKV[characterIdx[boss]])  //Invalid boss
    {
        return 0;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities")
    && KvJumpToKey(BossKV[characterIdx[boss]], pluginName)
    && KvJumpToKey(BossKV[characterIdx[boss]], abilityName))
    {
        return KvGetNum(BossKV[characterIdx[boss]], argument, defaultValue);
    }

    return 0;
}

stock Float:GetAbilityArgumentFloat(index,const String:plugin_name[],const String:ability_name[],arg,Float:defvalue=0.0)
{
    if(index==-1 || characterIdx[index]==-1 || !BossKV[characterIdx[index]])
        return 0.0;
    KvRewind(BossKV[characterIdx[index]]);
    new String:s[10];
    for(new i=1; i<MaxAbilities; i++)
    {
        Format(s,10,"ability%i",i);
        if(KvJumpToKey(BossKV[characterIdx[index]],s))
        {
            new String:ability_name2[64];
            KvGetString(BossKV[characterIdx[index]], "name",ability_name2,64);
            if(strcmp(ability_name,ability_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            new String:plugin_name2[64];
            KvGetString(BossKV[characterIdx[index]], "plugin_name",plugin_name2,64);
            if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            Format(s,10,"arg%i",arg);
            new Float:see=KvGetFloat(BossKV[characterIdx[index]], s,defvalue);
            return see;
        }
    }
    return 0.0;
}

stock Float:GetAbilityArgumentFloat2(boss, const String:pluginName[], const String:abilityName[], const String:argument[], Float:defaultValue=0.0)
{
    if(boss==-1 || characterIdx[boss]==-1 || !BossKV[characterIdx[boss]])  //Invalid boss
    {
        return 0.0;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities")
    && KvJumpToKey(BossKV[characterIdx[boss]], pluginName)
    && KvJumpToKey(BossKV[characterIdx[boss]], abilityName))
    {
        return KvGetFloat(BossKV[characterIdx[boss]], argument, defaultValue);
    }

    return 0.0;
}

stock GetAbilityArgumentString(index,const String:plugin_name[],const String:ability_name[],arg,String:buffer[],buflen,const String:defvalue[]="")
{
    if(index==-1 || characterIdx[index]==-1 || !BossKV[characterIdx[index]])
    {
        strcopy(buffer,buflen,"");
        return;
    }
    KvRewind(BossKV[characterIdx[index]]);
    new String:s[10];
    for(new i=1; i<MaxAbilities; i++)
    {
        Format(s,10,"ability%i",i);
        if(KvJumpToKey(BossKV[characterIdx[index]],s))
        {
            new String:ability_name2[64];
            KvGetString(BossKV[characterIdx[index]], "name",ability_name2,64);
            if(strcmp(ability_name,ability_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            new String:plugin_name2[64];
            KvGetString(BossKV[characterIdx[index]], "plugin_name",plugin_name2,64);
            if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
            {
                KvGoBack(BossKV[characterIdx[index]]);
                continue;
            }
            Format(s,10,"arg%i",arg);
            KvGetString(BossKV[characterIdx[index]], s,buffer,buflen,defvalue);
        }
    }
}

stock GetAbilityArgumentString2(boss, const String:pluginName[], const String:abilityName[], const String:argument[], String:abilityString[], length, const String:defaultValue[]="")
{
    if(boss==-1 || characterIdx[boss]==-1 || !BossKV[characterIdx[boss]])  //Invalid boss
    {
        strcopy(abilityString, length, "");
        return;
    }

    KvRewind(BossKV[characterIdx[boss]]);
    if(KvJumpToKey(BossKV[characterIdx[boss]], "abilities")
    && KvJumpToKey(BossKV[characterIdx[boss]], pluginName)
    && KvJumpToKey(BossKV[characterIdx[boss]], abilityName))
    {
        KvGetString(BossKV[characterIdx[boss]], argument, abilityString, length, defaultValue);
    }
}

ForceTeamWin(team)
{
    new entity=FindEntityByClassname2(-1, "team_control_point_master");
    if(!IsValidEntity(entity))
    {
        entity=CreateEntityByName("team_control_point_master");
        DispatchSpawn(entity);
        AcceptEntityInput(entity, "Enable");
    }
    SetVariantInt(team);
    AcceptEntityInput(entity, "SetWinner");
}

public HintPanelH(Handle:menu, MenuAction:action, client, selection)
{
    if(IsValidClient(client) && (action==MenuAction_Select || (action==MenuAction_Cancel && selection==MenuCancel_Exit)))
    {
        FF2Flags[client]|=FF2FLAG_CLASSHELPED;
    }
    return;
}

stock bool:IsBoss(client)
{
    if(IsValidClient(client))
    {
        for(new boss; boss<=MaxClients; boss++)
        {
            if(Boss[boss]==client)
            {
                return true;
            }
        }
    }
    return false;
}

DoOverlay(client, const String:overlay[])
{
    new flags=GetCommandFlags("r_screenoverlay");
    SetCommandFlags("r_screenoverlay", flags & ~FCVAR_CHEAT);
    ClientCommand(client, "r_screenoverlay \"%s\"", overlay);
    SetCommandFlags("r_screenoverlay", flags);
}

stock GetHealingTarget(client, bool:checkgun=false)
{
    new medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
    if(!checkgun)
    {
        if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
        {
            return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
        }
        return -1;
    }

    if(IsValidEdict(medigun))
    {
        new String:classname[64];
        GetEdictClassname(medigun, classname, sizeof(classname));
        if(!strcmp(classname, "tf_weapon_medigun", false))
        {
            if(GetEntProp(medigun, Prop_Send, "m_bHealing"))
            {
                return GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
            }
        }
    }
    return -1;
}

public CvarChangeNextmap(Handle:convar, const String:oldValue[], const String:newValue[])
{
    CreateTimer(0.1, Timer_DisplayCharsetVote, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_DisplayCharsetVote(Handle:timer)
{
    if(isCharSetSelected && !isCharsetOverride)
    {
        return Plugin_Continue;
    }

    if(IsVoteInProgress())
    {
        CreateTimer(5.0, Timer_DisplayCharsetVote, _, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Continue;
    }

    new Handle:menu=CreateMenu(Handler_VoteCharset, MenuAction:MENU_ACTIONS_ALL);
    SetMenuTitle(menu, "%t", "select_charset");  //"Please vote for the character set for the next map."

    decl String:config[PLATFORM_MAX_PATH], String:charset[64];
    BuildPath(Path_SM, config, sizeof(config), "%s/%s", DataPath, CharsetCFG);

    new Handle:Kv=CreateKeyValues("");
    FileToKeyValues(Kv, config);
    AddMenuItem(menu, "Random", "Random");
    new total, charsets;
    do
    {
        total++;
        if(KvGetNum(Kv, "hidden", 0))  //Hidden charsets are hidden for a reason :P
        {
            continue;
        }
        charsets++;
        validCharsets[charsets]=total;

        KvGetSectionName(Kv, charset, sizeof(charset));
        AddMenuItem(menu, charset, charset);
    }
    while(KvGotoNextKey(Kv));
    CloseHandle(Kv);

    if(charsets>1)  //We have enough to call a vote
    {
        FF2CharSet=charsets;  //Temporary so that if the vote result is random we know how many valid charsets are in the validCharset array
        new Handle:voteDuration=FindConVar("sm_mapvote_voteduration");
        VoteMenuToAll(menu, voteDuration ? GetConVarInt(voteDuration) : 20);
    }
    return Plugin_Continue;
}

public Handler_VoteCharset(Handle:menu, MenuAction:action, param1, param2)
{
    if(action==MenuAction_VoteEnd)
    {
        FF2CharSet=param1 ? param1-1 : validCharsets[GetRandomInt(1, FF2CharSet)]-1;  //If param1 is 0 then we need to find a random charset

        decl String:nextmap[32];
        GetConVarString(cvarNextmap, nextmap, sizeof(nextmap));
        GetMenuItem(menu, param1, FF2CharSetString, sizeof(FF2CharSetString));
        CPrintToChatAll("{olive}[FF2]{default} %t", "Next Map Character Set", nextmap, FF2CharSetString);  //"The character set for {1} will be {2}."
        isCharSetSelected=true;
        if(isCharsetOverride)
        {
            isCharsetOverride=false;
        }
    }
    else if(action==MenuAction_End)
    {
        CloseHandle(menu);
    }
}

public Action:Command_Nextmap(client, args)
{
    if(FF2CharSetString[0])
    {
        decl String:nextmap[42];
        GetConVarString(cvarNextmap, nextmap, sizeof(nextmap));
        CPrintToChat(client, "{olive}[FF2]{default} %t", "Next Map Character Set", nextmap, FF2CharSetString);
    }
    return Plugin_Handled;
}

public Action:Command_Say(client, args)
{
    decl String:chat[128];
    if(GetCmdArgString(chat, sizeof(chat))<1 || !client)
    {
        return Plugin_Continue;
    }

    if(!strcmp(chat, "\"nextmap\"") && FF2CharSetString[0])
    {
        Command_Nextmap(client, 0);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
    while(startEnt>-1 && !IsValidEntity(startEnt))
    {
        startEnt--;
    }
    return FindEntityByClassname(startEnt, classname);
}

bool:UseAbility(boss, const String:plugin_name[], const String:ability_name[], slot, buttonMode=0)
{
    new bool:enabled=true;
    Call_StartForward(PreAbility);
    Call_PushCell(boss);
    Call_PushString(plugin_name);
    Call_PushString(ability_name);
    Call_PushCell(slot);
    Call_PushCellRef(enabled);
    Call_Finish();

    if(!enabled)
    {
        return false;
    }

    new Action:action=Plugin_Continue;
    Call_StartForward(OnAbility);
    Call_PushCell(boss);
    Call_PushString(plugin_name);
    Call_PushString(ability_name);
    if(slot==-1)
    {
        Call_PushCell(3);  //Status - we're assuming here a life-loss ability will always be in use if it gets called
        Call_Finish(action);
    }
    else if(!slot)
    {
        FF2Flags[Boss[boss]]&=~FF2FLAG_BOTRAGE;
        Call_PushCell(3);  //Status - we're assuming here a rage ability will always be in use if it gets called
        Call_Finish(action);
        BossCharge[boss][slot]=0.0;
    }
    else
    {
        SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
        new button;
        switch(buttonMode)
        {
            case 3:
            {
                button=IN_ATTACK3;
                showtip[Boss[boss]][3]=true;
            }
            case 2:
            {
                button=IN_RELOAD;
                showtip[Boss[boss]][2]=true;
            }
            default:
            {
                button=IN_DUCK|IN_ATTACK2;
                showtip[Boss[boss]][1]=true;
            }
        }

        if(GetClientButtons(Boss[boss]) & button)
        {
            if(!(FF2Flags[Boss[boss]] & FF2FLAG_USINGABILITY))
            {
                FF2Flags[Boss[boss]]|=FF2FLAG_USINGABILITY;
                switch(buttonMode)
                {
                    case 2:
                    {
                        SetInfoCookies(Boss[boss], 0, CheckInfoCookies(Boss[boss], 0)-1);
                    }
                    default:
                    {
                        SetInfoCookies(Boss[boss], 1, CheckInfoCookies(Boss[boss], 1)-1);
                    }
                }
            }

            if(BossCharge[boss][slot]>=0.0)
            {
                Call_PushCell(2);  //Status
                Call_Finish(action);
                new Float:charge=100.0*0.2/GetAbilityArgumentFloat(boss, plugin_name, ability_name, 1, 1.5);
                if(BossCharge[boss][slot]+charge<100.0)
                {
                    BossCharge[boss][slot]+=charge;
                }
                else
                {
                    BossCharge[boss][slot]=100.0;
                }
            }
            else
            {
                Call_PushCell(1);  //Status
                Call_Finish(action);
                BossCharge[boss][slot]+=0.2;
            }
        }
        else if(BossCharge[boss][slot]>0.3)
        {
            new Float:angles[3];
            GetClientEyeAngles(Boss[boss], angles);
            if(angles[0]<-45.0)
            {
                Call_PushCell(3);
                Call_Finish(action);
                new Handle:data;
                CreateDataTimer(0.1, Timer_UseBossCharge, data);
                WritePackCell(data, boss);
                WritePackCell(data, slot);
                WritePackFloat(data, -1.0*GetAbilityArgumentFloat(boss, plugin_name, ability_name, 2, 5.0));
                ResetPack(data);
            }
            else
            {
                Call_PushCell(0);  //Status
                Call_Finish(action);
                BossCharge[boss][slot]=0.0;
            }
        }
        else if(BossCharge[boss][slot]<0.0)
        {
            Call_PushCell(1);  //Status
            Call_Finish(action);
            BossCharge[boss][slot]+=0.2;
        }
        else
        {
            Call_PushCell(0);  //Status
            Call_Finish(action);
        }
    }
    return true;
}

UseAbility2(boss, const String:pluginName[], const String:abilityName[], slot, buttonMode=0)
{
    Call_StartForward(OnAbility2);
    Call_PushCell(boss);
    Call_PushString(pluginName);
    Call_PushString(abilityName);
    Call_PushCell(slot);
    if(slot==-1)
    {
        Call_PushCell(3);  //We're assuming here a life-loss ability will always be in use if it gets called
        Call_Finish();
    }
    else if(!slot)
    {
        FF2Flags[Boss[boss]]&=~FF2FLAG_BOTRAGE;
        Call_PushCell(3);  //We're assuming here a rage ability will always be in use if it gets called
        Call_Finish();
        BossCharge[boss][slot]=0.0;
    }
    else
    {
        SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);
        new button;
        switch(buttonMode)
        {
            case 3:
            {
                button=IN_ATTACK3;
            }
            case 2:
            {
                button=IN_RELOAD;
            }
            default:
            {
                button=IN_DUCK|IN_ATTACK2;
            }
        }

        if(GetClientButtons(Boss[boss]) & button)
        {
            if(!(FF2Flags[Boss[boss]] & FF2FLAG_USINGABILITY))
            {
                FF2Flags[Boss[boss]]|=FF2FLAG_USINGABILITY;
                switch(buttonMode)
                {
                    case 2:
                    {
                        SetInfoCookies(Boss[boss], 0, CheckInfoCookies(Boss[boss], 0)-1);
                    }
                    default:
                    {
                        SetInfoCookies(Boss[boss], 1, CheckInfoCookies(Boss[boss], 1)-1);
                    }
                }
            }

            if(BossCharge[boss][slot]>=0.0)
            {
                Call_PushCell(2);  //Ready
                Call_Finish();
                new Float:charge=100.0*0.2/GetAbilityArgumentFloat2(boss, pluginName, abilityName, "charge", 1.5);
                if(BossCharge[boss][slot]+charge<100.0)
                {
                    BossCharge[boss][slot]+=charge;
                }
                else
                {
                    BossCharge[boss][slot]=100.0;
                }
            }
            else
            {
                Call_PushCell(1);  //Recharging
                Call_Finish();
                BossCharge[boss][slot]+=0.2;
            }
        }
        else if(BossCharge[boss][slot]>0.3)
        {
            new Float:angles[3];
            GetClientEyeAngles(Boss[boss], angles);
            if(angles[0]<-45.0)
            {
                Call_PushCell(3);  //In use
                Call_Finish();
                new Handle:data;
                CreateDataTimer(0.1, Timer_UseBossCharge, data);
                WritePackCell(data, boss);
                WritePackCell(data, slot);
                WritePackFloat(data, -1.0*GetAbilityArgumentFloat2(boss, pluginName, abilityName, "cooldown", 5.0));
                ResetPack(data);
            }
            else
            {
                Call_PushCell(0);  //Not in use
                Call_Finish();
                BossCharge[boss][slot]=0.0;
            }
        }
        else if(BossCharge[boss][slot]<0.0)
        {
            Call_PushCell(1);  //Recharging
            Call_Finish();
            BossCharge[boss][slot]+=0.2;
        }
        else
        {
            Call_PushCell(0);  //Not in use
            Call_Finish();
        }
    }
}

stock bool:IsNearDispenser(client)
{
    new medics = 0, healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
    if (healers>0)
    {
        for (new i=1;i<=MaxClients;i++)
        {
            if (IsValidClient(i, true) && GetHealingTarget(i, true) == client)
            medics++;
        }
    }
    return healers > medics;
}

// GAMETICK

public void OnGameFrame() // Moving some stuff here and there
{
    if(!Enabled)
        return;

    FF2_Tick(GetEngineTime());
    FF2_RoundTick(GetEngineTime());
}

public FF2_RoundTick(Float:gameTime)
{
    if(gameTime >= FF2BossTick)
    {
        if(!Enabled)
        {
            FF2BossTick = INACTIVE;
            return;
        }
        
        bool validBoss=false;
        for(int client; client<=MaxClients; client++)
        {
            if(!IsValidClient(Boss[client], true) || !(FF2Flags[Boss[client]] & FF2FLAG_USEBOSSTIMER))
            {
                continue;
            }
            
            validBoss=true;

            int invalidWeps[MAXPLAYERS+1];
            for(int slot=0;slot<=5;slot++)
            {
                int weapon=GetPlayerWeaponSlot(Boss[client], slot);
                if(slot<3 && !IsValidEdict(weapon))
                {
                    invalidWeps[Boss[client]]++;
                }
                
                if(invalidWeps[Boss[client]]==3)
                {
                    TF2_RegeneratePlayer(Boss[client]);
                }
            }
            
            if(CheckRoundState()==FF2RoundState_RoundEnd)
            {
                TF2_AddCondition(Boss[client], TFCond_SpeedBuffAlly, 14.0);
                FF2BossTick = INACTIVE;
                return;
            }
        
            if(!(FF2Flags[Boss[client]] & FF2FLAG_DISABLE_SPEED_MANAGEMENT))
            {
                SetEntPropFloat(Boss[client], Prop_Data, "m_flMaxspeed", BossSpeed[characterIdx[client]]+0.7*(100-BossHealth[client]*100/BossLivesMax[client]/BossHealthMax[client]));
            }
        
            if(BossHealth[client]<=0 && IsPlayerAlive(Boss[client]))  //Wat.  TODO:  Investigate
            {
                BossHealth[client]=1;
            }

            if(BossLivesMax[client]>1)
            {
                SetHudTextParams(-1.0, 0.77, 0.15, 255, 255, 255, 255, makeScroll ? 2 : 0);
                FF2_ShowSyncHudText(Boss[client], livesHUD, "%t", "Boss Lives Left", BossLives[client], BossLivesMax[client]);
            }
        
            if(BossCharge[client][0]>100.0)
            {
                BossCharge[client][0]=100.0;
            }
            
            if(FF2ClientDifficulty[Boss[client]]<FF2Difficulty_Lunatic)
            {
                if(RoundFloat(BossCharge[client][0])==100.0)
                {
                    if(IsFakeClient(Boss[client]) && !(FF2Flags[Boss[client]] & FF2FLAG_BOTRAGE))
                    {
                        RequestFrame(Frame_BotRage, Boss[client]);
                        FF2Flags[Boss[client]]|=FF2FLAG_BOTRAGE;
                    }
                    else
                    {
                        SetHudTextParams(-1.0, 0.83, 0.15, 255, 64, 64, 255, makeScroll ? 2 : 0);
                        FF2_ShowSyncHudText(Boss[client], rageHUD, "%t", "do_rage");

                        new String:sound[PLATFORM_MAX_PATH];
                        if((RandomSound("sound_full_rage", sound, PLATFORM_MAX_PATH, client) || FindSound("full_rage", sound, sizeof(sound), client))&& emitRageSound[client])
                        {
                            new Float:position[3];
                            GetEntPropVector(Boss[client], Prop_Send, "m_vecOrigin", position);
    
                            FF2Flags[Boss[client]]|=FF2FLAG_TALKING;
                            EmitSoundToAll(sound, Boss[client], _, _, _, _, _, Boss[client], position);
                            EmitSoundToAll(sound, Boss[client], _, _, _, _, _, Boss[client], position);
    
                            for(new target=1; target<=MaxClients; target++)
                            {
                                if(IsClientInGame(target) && target!=Boss[client])
                                {
                                    EmitSoundToClient(target, sound, Boss[client], _, _, _, _, _, Boss[client], position);
                                    EmitSoundToClient(target, sound, Boss[client], _, _, _, _, _, Boss[client], position);
                                }
                            }
                            FF2Flags[Boss[client]]&=~FF2FLAG_TALKING;
                            emitRageSound[client]=false;
                        }
                    }
            
                }
                else
                {
                    SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, makeScroll ? 2 : 0);
                    FF2_ShowSyncHudText(Boss[client], rageHUD, "%t", "rage_meter", RoundFloat(BossCharge[client][0]));
                }
            }
            SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255, makeScroll ? 2 : 0);
            
            // varaiables used by both
            decl String:ability[10], String:lives[MaxAbilities][3], String:pluginName[64], String:abilityName[64];

            // load v1 abilities
            for(new i=1; ; i++)
            {
                Format(ability, 10, "ability%i", i);
                KvRewind(BossKV[characterIdx[client]]);
                if(KvJumpToKey(BossKV[characterIdx[client]], ability))
                {
                    KvGetString(BossKV[characterIdx[client]], "plugin_name", pluginName, 64);
                    new slot=KvGetNum(BossKV[characterIdx[client]], "arg0", 0);
                    new buttonmode=KvGetNum(BossKV[characterIdx[client]], "buttonmode", 0);
                    if(slot<1)
                    {
                        continue;
                    }
                    
                    KvGetString(BossKV[characterIdx[client]], "life", ability, 10, "");
                    if(!ability[0])
                    {
                        KvGetString(BossKV[characterIdx[client]], "name", abilityName, 64);
                        UseAbility(client, pluginName, abilityName, slot, buttonmode);
                    }
                    else
                    {
                        new count=ExplodeString(ability, " ", lives, MaxAbilities, 3);
                        for(new n; n<count; n++)
                        {
                            if(StringToInt(lives[n])==BossLives[client])
                            {
                                KvGetString(BossKV[characterIdx[client]], "name", abilityName, 64);
                                UseAbility(client, pluginName, abilityName, slot, buttonmode);
                                break;
                            }
                        }
                    }
                }
                else
                {
                    break;
                }
            }

            // load v2 abilities
            KvRewind(BossKV[characterIdx[client]]);
            if(KvJumpToKey(BossKV[characterIdx[client]], "abilities"))
            {
                while(KvGotoNextKey(BossKV[characterIdx[client]]))
                {
                    KvGetSectionName(BossKV[characterIdx[client]], pluginName, sizeof(pluginName));
                    KvJumpToKey(BossKV[characterIdx[client]], pluginName);
                    while(KvGotoNextKey(BossKV[characterIdx[client]]))
                    {
                        KvGetSectionName(BossKV[characterIdx[client]], abilityName, sizeof(abilityName));
                        KvJumpToKey(BossKV[characterIdx[client]], abilityName);
                        new slot=KvGetNum(BossKV[characterIdx[client]], "slot", 0);
                        new buttonmode=KvGetNum(BossKV[characterIdx[client]], "buttonmode", 0);
                        if(slot<1)
                        {
                            continue;
                        }

                        KvGetString(BossKV[characterIdx[client]], "life", ability, sizeof(ability), "");
                        if(!ability[0])
                        {
                            UseAbility2(client, pluginName, abilityName, slot, buttonmode);
                        }
                        else
                        {
                            new count=ExplodeString(ability, " ", lives, MaxAbilities, 3);
                            for(new n; n<count; n++)
                            {
                                if(StringToInt(lives[n])==BossLives[client])
                                {
                                    UseAbility2(client, pluginName, abilityName, slot, buttonmode);
                                    KvGoBack(BossKV[characterIdx[client]]);
                                    break;
                                }
                            }
                        }
                        KvGoBack(BossKV[characterIdx[client]]);
                    }
                    KvGoBack(BossKV[characterIdx[client]]);
                }
            }
            
            if(LivingMercs==1 && RoundTick>2)
            {
                new String:message[512];
                new String:name[64];
                for(new target; target<=MaxClients; target++)
                {
                    if(IsBoss(target))
                    {
                        new boss2=GetBossIndex(target);
                        KvRewind(BossKV[characterIdx[boss2]]);
                        KvGetString(BossKV[characterIdx[boss2]], "name", name, sizeof(name), "=Failed name=");
                        //Format(bossLives, sizeof(bossLives), ((BossLives[boss2]>1) ? ("x%i", BossLives[boss2]) : ("")));
                        decl String:bossLives[10];
                        if(BossLives[boss2]>1)
                        {
                            Format(bossLives, sizeof(bossLives), "x%i", BossLives[boss2]);
                        }
                        else
                        {
                            Format(bossLives, sizeof(bossLives), "");
                        }
                        
                        if(DrawGameTimerAt!=INACTIVE || roundOvertime)
                            Format(message, sizeof(message), "%s\n%t | %s", message, "ff2_hp", name, BossHealth[boss2]-BossHealthMax[boss2]*(BossLives[boss2]-1), BossHealthMax[boss2], bossLives, !timeDisplay[0] ? "88:88" : timeDisplay);
                        else
                            Format(message, sizeof(message), "%s\n%t", message, "ff2_hp", name, BossHealth[boss2]-BossHealthMax[boss2]*(BossLives[boss2]-1), BossHealthMax[boss2], bossLives);
                    }
                }
                for(new target; target<=MaxClients; target++)
                {
                    if(IsValidClient(target) && !(FF2Flags[target] & FF2FLAG_HUDDISABLED))
                    {
                        if(!Companions)
                        {
                            if(!minimalHUD[target])
                            {
                                ShowGameText(target, (DeadRunMode == true ? "ico_ghost" : (DrawGameTimerAt!=INACTIVE) ? ((timeleft>=10 && timeleft<30) ? "ico_notify_thirty_seconds" : (timeleft<10) ? "ico_notify_ten_seconds" : "ico_notify_sixty_seconds") : roundOvertime ? "ico_notify_flag_moving_alt" : "leaderboard_streak"), _, message);
                            }
                            else
                            {
                                PrintCenterText(target, message);
                            }
                        }
                        else
                        {
                            PrintCenterText(target, message);
                        }
                    }
                }
                
            }

            if(BossCharge[client][0]<100.0)
            {
                BossCharge[client][0]+=OnlyScoutsLeft()*0.2;
                if(BossCharge[client][0]>100.0)
                {
                    BossCharge[client][0]=100.0;
                }
            }

            HPTime-=0.2;
            if(HPTime<0)
            {
                HPTime=0.0;
            }

            for(new client2; client2<=MaxClients; client2++)
            {
                if(KSpreeTimer[client2]>0)
                {    
                    KSpreeTimer[client2]-=0.2;
                }
            }
        }

        if(!validBoss)
        {    
            FF2BossTick = INACTIVE;
            return;
        }
        
        FF2BossTick+=0.2;
    }
    
    if(gameTime >= FF2ClientTick)
    {
        if(!Enabled || CheckRoundState()==FF2RoundState_RoundEnd || CheckRoundState()==FF2RoundState_Loading)
        {
            FF2ClientTick = INACTIVE;
            return;
        }

        char classname[32];
        TFCond cond;
        for(int client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client) && !IsBoss(client) && !(FF2Flags[client] & FF2FLAG_CLASSTIMERDISABLED))
            {
                // Damage HUD
                SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, makeScroll ? 2 : 0);
                if(!IsPlayerAlive(client))
                {
                    int observer=GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
                    if(IsValidClient(observer) && observer!=client)
                    {
                        if(!IsBoss(observer))
                        {
                            FF2_ShowSyncHudText(client, rageHUD, "%t", "player_stats", Damage[client], bossesSlain[client], mvpCount[client], observer, Damage[observer], bossesSlain[observer], mvpCount[observer]);
                        }
                        else
                        {
                            FF2_ShowSyncHudText(client, rageHUD, "%t", "stats_hud_text", observer, bossWins[observer], bossDefeats[observer], bossKills[observer], bossDeaths[observer]);
                        }
                    }
                    else
                    {
                        FF2_ShowSyncHudText(client, rageHUD, "%t", "your_stats", Damage[client], bossesSlain[client], mvpCount[client]);
                    }
                    continue;
                }
                FF2_ShowSyncHudText(client, rageHUD, "%t", "your_stats", Damage[client], bossesSlain[client], mvpCount[client]);
                
                if(shield[client] && shieldHP[client]>0.0)
                {
                    SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, makeScroll ? 2 : 0);
                    FF2_ShowHudText(client, -1, "%t", "shield-hp", RoundToFloor(shieldHP[client]*0.1));
                }
                
                // Weapon Stuff
                TFClassType class=TF2_GetPlayerClass(client);
                int weapon=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
                if(weapon<=MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, classname, sizeof(classname)))
                {
                    strcopy(classname, sizeof(classname), "");
                }
                bool validwep=!StrContains(classname, "tf_weapon", false);
                        
                // Chdata's Deadringer Notifier
                if (TF2_GetPlayerClass(client) == TFClass_Spy && !IsBoss(client))
                {
                    if(GetClientCloakIndex(client) == 59)
                    {
                        int drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
                        char s[32];
                        
                        SetHudTextParams(-1.0, 0.83, 0.35, 90, drstatus==2 ? 64 : 255, drstatus==2 ? 64 : drstatus==1 ? 90 : 255, 255, makeScroll ? 2 : 0);        
                        Format(s, sizeof(s), TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? "Status: Deadringed" : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? "Status: Feign Death Ready" : "Status: Inactive");

                        if (!(GetClientButtons(client) & IN_SCORE))
                        {
                            FF2_ShowSyncHudText(client, cloakHUD, "%s", s);
                        }
                    }
                }

                int index=(validwep ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
                if(class==TFClass_Medic)
                {
                    if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
                    {
                        int medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
                        char mediclassname[64];
                        if(IsValidEdict(medigun) && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) && !StrContains(mediclassname, "tf_weapon_medigun", false))
                        {
                            int charge=RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
                            SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, makeScroll ? 2 : 0);
                            FF2_ShowSyncHudText(client, jumpHUD, "%t", "uber-charge", client, charge);
    
                            if(charge==100 && !(FF2Flags[client] & FF2FLAG_UBERREADY))
                            {
                                FakeClientCommandEx(client, "voicemenu 1 7");
                                FF2Flags[client]|=FF2FLAG_UBERREADY;
                            }
                        }
                    }
                    else if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
                    {
                        int healtarget=GetHealingTarget(client, true);
                        if(IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget)==TFClass_Scout)
                        {
                            TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.3);
                        }
                    }
                }

                else if(class==TFClass_Soldier)
                {
                    if((FF2Flags[client] & FF2FLAG_ISBUFFED) && !(GetEntProp(client, Prop_Send, "m_bRageDraining")))
                    {
                        FF2Flags[client]&=~FF2FLAG_ISBUFFED;
                    }
                }

                if(LivingMercs==1 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
                {
                    TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.3);
                    if(class==TFClass_Engineer && weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(classname, "tf_weapon_sentry_revenge", false))
                    {
                        SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
                    }
                    TF2_AddCondition(client, TFCond_Buffed, 0.3);
                    continue;
                }
                else if(LivingMercs==2 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
                {
                    TF2_AddCondition(client, TFCond_Buffed, 0.3);
                }
    
                if(bMedieval)
                {
                    continue;
                }

                cond=TFCond_HalloweenCritCandy;
                if(TF2_IsPlayerInCondition(client, TFCond_CritCola) && (class==TFClass_Scout || class==TFClass_Heavy))
                {
                    TF2_AddCondition(client, cond, 0.3);
                    continue;
                }

                int healer=-1;
                for(int healtarget=1; healtarget<=MaxClients; healtarget++)
                {
                    if(IsValidClient(healtarget, true) && GetHealingTarget(healtarget, true)==client)
                    {
                        healer=healtarget;
                        break;
                    }
                }
                
                bool addthecrit=false;
                if(validwep && weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) && strcmp(classname, "tf_weapon_knife", false))  //Every melee except knives
                {
                    if(index != 416 || index != 307)
                    {
                        addthecrit=true;
                    }
                }
                
                else if((!StrContains(classname, "tf_weapon_smg") && index!=751) ||
                        !StrContains(classname, "tf_weapon_compound_bow") ||
                        !StrContains(classname, "tf_weapon_crossbow") ||
                        !StrContains(classname, "tf_weapon_pistol") ||
                        index==1104 && TF2_IsPlayerInCondition(client, TFCond_BlastJumping) ||
                        !StrContains(classname, "tf_weapon_handgun_scout_secondary"    ))
                {
                    addthecrit=true;
                    if((class==TFClass_Scout|| index==1104 && TF2_IsPlayerInCondition(client, TFCond_Parachute)) && cond==TFCond_HalloweenCritCandy)
                    {
                        cond=TFCond_Buffed;
                    }
                }
    
                if(index==16 && IsValidEntity(FindPlayerBack(client, 642)))  //SMG, Cozy Camper
                {
                    addthecrit=false;
                }
                
                switch(class)
                {
                    case TFClass_Medic:
                    {
                        if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
                        {
                            int medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
                            if(IsValidEdict(medigun))
                            {                            
                                SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, makeScroll ? 2 : 0);
                                new charge=RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
                                FF2_ShowHudText(client, -1, "%t", "uber-charge", client, charge);
                                if(charge==100 && !(FF2Flags[client] & FF2FLAG_UBERREADY))
                                {
                                    FakeClientCommand(client, "voicemenu 1 7");  //"I am fully charged!"
                                    FF2Flags[client]|= FF2FLAG_UBERREADY;
                                }
                            }
                        }
                        else if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
                        {
                            int healtarget=GetHealingTarget(client, true);
                            if(IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget)==TFClass_Scout)
                            {
                                TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.3);
                            }
                        }
                    }
                    case TFClass_DemoMan:
                    {
                        if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && !IsValidEntity(GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary)) && shieldCrits)  //Demoshields
                        {
                            addthecrit=true;
                            if(shieldCrits==1)
                            {
                                cond=TFCond_Buffed;
                            }
                        }
                    }
                    case TFClass_Spy:
                    {
                        if(validwep && weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
                        {
                            if(!TF2_IsPlayerCritBuffed(client) && !TF2_IsPlayerInCondition(client, TFCond_Buffed) && !TF2_IsPlayerInCondition(client, TFCond_Cloaked) && !TF2_IsPlayerInCondition(client, TFCond_Disguised))
                            {
                                TF2_AddCondition(client, TFCond_CritCola, 0.3);
                            }
                        }
                    }
                    case TFClass_Engineer:
                    {
                        if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(classname, "tf_weapon_sentry_revenge", false))
                        {
                            int sentry=FindSentry(client);
                            if(IsValidEntity(sentry) && IsBoss(GetEntPropEnt(sentry, Prop_Send, "m_hEnemy")))
                            {
                                SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
                                TF2_AddCondition(client, TFCond_Kritzkrieged, 0.3);
                            }
                            else
                            {
                                if(GetEntProp(client, Prop_Send, "m_iRevengeCrits"))
                                {
                                    SetEntProp(client, Prop_Send, "m_iRevengeCrits", 0);
                                }
                                else if(TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(client, TFCond_Healing))
                                {
                                    TF2_RemoveCondition(client, TFCond_Kritzkrieged);
                                }
                            }
                        }
                    }
                }
                if(addthecrit)
                {
                    TF2_AddCondition(client, cond, 0.3);
                    if(healer!=-1 && cond!=TFCond_Buffed)
                    {
                        TF2_AddCondition(client, TFCond_Buffed, 0.3);
                    }
                }
            }
        }
        FF2ClientTick+=0.2;
    }
}

public void Timers_PreThink(int client, float gTime)
{
    if(DeadRunMode && CheckRoundState()==FF2RoundState_RoundRunning && IsPlayerAlive(client))
    {
        if(TF2_GetPlayerClass(client)==TFClass_Spy)
        {
            SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 1.0);
        }
        SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", (GetClientTeam(client) == BossTeam ? 400.0 : 300.0));
    }
    
    if(CheckRoundState()==FF2RoundState_Setup && IsPlayerAlive(client))
    {
        int melee=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
        if(IsValidEntity(melee) && melee==GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) && GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex")==357)
        {
            if(!GetEntProp(melee, Prop_Send, "m_bIsBloody"))
            {
                RequestFrame(Frame_RemoveHonorbound, client);
            }
        }
    }
    
    if(gTime>=CheckMinHudAt[client])
    {
        QueryClientConVar(client, "cl_hud_minmode", ConVarQueryFinished:CvarCheck_MinimalHud, client);
        CheckMinHudAt[client]+=1.0;
    }

    if(gTime>=KillRPSLosingBossAt[client])
    {
        if(IsPlayerAlive(client) && GetBossIndex(client)>=0)
        {
            if(IsValidClient(RPSWinner, true))
            {
                SDKHooks_TakeDamage(client, RPSWinner, RPSWinner, float(FF2_GetBossHealth(GetBossIndex(client))), DMG_GENERIC, -1);
            }
            else // Winner disconnects?
            {
                ForcePlayerSuicide(client);
            }
        }
        KillRPSLosingBossAt[client]=INACTIVE;
    }
    
    if(gTime>=PrepareMercAt[client])
    {
        if(!IsValidClient(client, true) || CheckRoundState()==FF2RoundState_RoundEnd || IsBoss(client) || (FF2Flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
        {
            PrepareMercAt[client]=INACTIVE;
            return;
        }

        if(!IsVoteInProgress() && GetClientClassinfoCookie(client) && !(FF2Flags[client] & FF2FLAG_CLASSHELPED))
        {
            HelpPanelClass(client);
        }

        SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);

        SetEntityHealth(client, GetPlayerMaxHealth(client)); //Temporary: Reset health to avoid an overhealh bug
        if(GetClientTeam(client)!=MercTeam)
        {
            #if defined _tf2attributes_included
            if(tf2attributes)
            {
                TF2Attrib_RemoveByDefIndex(client, 259);
                TF2Attrib_RemoveByDefIndex(client, 68);
                TF2Attrib_RemoveByDefIndex(client, 135);
                TF2Attrib_RemoveByDefIndex(client, 181);
            }
            #endif
        
            AssignTeam(client, TFTeam:MercTeam);
            
            if(DeadRunMode && IsPreparing)
            {
                SetEntityMoveType(client, MOVETYPE_NONE);
            }
        }
    
        #if defined _tf2attributes_included
        if(tf2attributes)
        {
            TF2Attrib_RemoveByDefIndex(client, 259);
            TF2Attrib_RemoveByDefIndex(client, 68);
            TF2Attrib_RemoveByDefIndex(client, 135);
            TF2Attrib_RemoveByDefIndex(client, 181);
        }
        #endif
    
        if(DeadRunMode && IsPreparing)
        {
            SetEntityMoveType(client, MOVETYPE_NONE);
        }
        
        InspectPlayerInventoryAt[client]=gTime+0.1;
        PrepareMercAt[client]=INACTIVE;
    }
    
    if(gTime>=InspectPlayerInventoryAt[client])
    {
        if(!IsValidClient(client, true) || CheckRoundState()==FF2RoundState_RoundEnd || IsBoss(client) || (FF2Flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
        {
            InspectPlayerInventoryAt[client]=INACTIVE;
            return;
        }

        SetEntityRenderColor(client, 255, 255, 255, 255);
        shield[client]=0;

        int civilianCheck[MAXPLAYERS+1];

        if(DeadRunMode && TF2_GetPlayerClass(client)==TFClass_Spy)
        {
            TF2_RemoveWeaponSlot(client, 4);
        }
    
        int weaponEntId, weaponIdx;
        for(int wepSlot=0; wepSlot<=5; wepSlot++)
        {
            weaponEntId=GetPlayerWeaponSlot(client, wepSlot);
            if(weaponEntId && IsValidEdict(weaponEntId))
            {
                weaponIdx=GetEntProp(weaponEntId, Prop_Send, "m_iItemDefinitionIndex");
                // Some internal weapon checks
                switch(weaponIdx)
                {
                    case 357:  //Half-Zatoichi
                    {
                        RequestFrame(Frame_RemoveHonorbound, client);
                    }
                    case 589:  //Eureka Effect
                    {
                        if(!GetConVarBool(cvarEnableEurekaEffect))
                        {    
                            TF2_RemoveWeaponSlot(client, wepSlot);
                            weaponEntId=SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "", true);
                        }
                    }
                }
            
                if(TF2_GetPlayerClass(client)==TFClass_Medic && wepSlot==1)
                {
                    SetEntPropFloat(weaponEntId, Prop_Send, "m_flChargeLevel", 0.40);
                    if(GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee)==142)  //Gunslinger (Randomizer, etc. compatability)
                    {
                        SetEntityRenderMode(weaponEntId, RENDER_TRANSCOLOR);
                        SetEntityRenderColor(weaponEntId, 255, 255, 255, 75);
                    }
                    SetEntPropFloat(weaponEntId, Prop_Send, "m_flChargeLevel", 0.40);
                }
            
                new playerBack=FindPlayerBack(client, 57);  //Razorback
                shield[client]=IsValidEntity(playerBack) ? playerBack : 0;

                if(IsValidEntity(FindPlayerBack(client, 642)))  //Cozy Camper
                {
                    weaponEntId=SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85", true);
                }

                #if defined _tf2attributes_included
                if(tf2attributes)
                {
                    if(IsValidEntity(FindPlayerBack(client, 444)))  //Mantreads
                    {
                        TF2Attrib_SetByDefIndex(client, 58, 1.5);  //+50% increased push force
                    }
                    else
                    {
                        TF2Attrib_RemoveByDefIndex(client, 58);
                    }
                }
                #endif

                int entity=-1;
                while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)  //Demoshields
                {
                    if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
                    {
                        shield[client]=entity;
                    }
                }
                
                if(IsValidEntity(shield[client]))
                {
                    shieldHP[client]=700.0;
                    shDmgReduction[client]=0.25;
                }
            }
            else 
            {
                if(wepSlot<3)
                {
                    civilianCheck[client]++;
                }    
            }
        }
    
        if(civilianCheck[client]==3)
        {
            civilianCheck[client]=0;
            CPrintToChat(client, "{olive}[FF2]{default} %t", "Civilian Check Failed");
            TF2_RespawnPlayer(client);
        }
        civilianCheck[client]=0;

        InspectPlayerInventoryAt[client]=INACTIVE;
    }
    
    if(gTime>=PlayBGMAt[client])
    {
        PrepareBGM(client);
    }
}

public FF2_Tick(Float:gameTime)
{
    if(gameTime >= UpdateRoundTickAt)
    {
        if(CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            RoundTick=0;
            UpdateRoundTickAt=INACTIVE;
            return;
        }
        
        if(RoundTick>=5 && makeScroll)
        {
            makeScroll=false;
        }
        
        RoundTick++;
        UpdateRoundTickAt+=1.0;
    }
    
    if(gameTime >= CalcQueuePointsAt)
    {
        CalcQueuePoints();
        CalcQueuePointsAt = INACTIVE;
    }

    if(gameTime >= CheckAlivePlayersAt)
    {    
        if(CheckRoundState()==FF2RoundState_RoundEnd)
        {    
            CheckAlivePlayersAt = INACTIVE;
            return;
        }
        
        LivingMercs=0;
        LivingBosses=0;
        LivingMinions=0;
        for(new client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client, true))
            {
                if(GetClientTeam(client)==MercTeam)
                {
                    LivingMercs++;
                }
                else if(IsBoss(client))
                {
                    LivingBosses++;
                }
                else if(!IsBoss(client) && GetClientTeam(client)==BossTeam || (FF2_GetFF2flags(client) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
                {
                    LivingMinions++;
                }
            }
        }

        Call_StartForward(OnAlivePlayersChanged);  //Let subplugins know that the number of alive players just changed
        Call_PushCell(LivingMercs);
        Call_PushCell(LivingBosses+LivingMinions);
        Call_Finish();

        if(!LivingMercs)
        {
            ForceTeamWin(BossTeam);
        }
        else if(LivingMercs==1 && LivingBosses && Boss[0] && !executed3)
        {
            char sound[PLATFORM_MAX_PATH];
            if(RandomSound("sound_lastman", sound, sizeof(sound)) || FindSound("lastman", sound, sizeof(sound)))
            {
                EmitSoundToAll(sound);
                EmitSoundToAll(sound);
            }
            
            if(lastPlayerGlow)
            {
                for(new client=1;client<=MaxClients;client++)
                {
                    if(!IsValidClient(client, true))
                        continue;
                
                    EnableClientGlow(client, float(timeleft));
                }
            }
            executed3=true;
        }
        else if(LivingMercs>1 && executed3 && lastPlayerGlow)
        {
            for(new client=1;client<=MaxClients;client++)
            {
                if(!IsValidClient(client, true))
                    continue;
            
                EnableClientGlow(client, 0.0);
            }
            executed3=false;
        }
        else if(!PointType && LivingMercs<=AliveToEnable && !executed)
        {
            char sound[64];
            if(GetRandomInt(0, 1))
            {
                Format(sound, sizeof(sound), "vo/announcer_am_capenabled0%i.mp3", GetRandomInt(1, 4));
            }
            else
            {
                Format(sound, sizeof(sound), "vo/announcer_am_capincite0%i.mp3", GetRandomInt(0, 1) ? 1 : 3);
            }
            EmitSoundToAll(sound);
            if(LivingMercs>1)
            {
                ShowGameText(0, "ico_notify_flag_moving_alt", _, "%t", "point_enable", AliveToEnable);
            }
            else
            {
                PrintHintTextToAll("%t", "point_enable", AliveToEnable);
            }
            SetControlPoint(true);
            executed=true;
        }

        if(!DeadRunMode && LivingMercs<=countdownPlayers && BossHealth[0]>countdownHealth && countdownTime>1 && !executed2)
        {
            if(FindEntityByClassname2(-1, "team_control_point")!=-1)
            {
                timeleft=countdownTime;
                DrawGameTimerAt = GetEngineTime()+1.0;
            }
            executed2=true;
        }
        CheckAlivePlayersAt = INACTIVE;
    }
    
    if(gameTime >= AnnounceAt)
    {    
        ShowAnnouncement(gameTime);
    }
    
    if(gameTime >= NineThousandAt)
    {
        EmitSoundToAll("saxton_hale/9000.wav", _, _, _, _, _, _, _, _, _, false);
        EmitSoundToAllExcept(SoundException_BossVoice, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, _, _, _, _, _, _, _, false);
        EmitSoundToAllExcept(SoundException_BossVoice, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, _, _, _, _, _, _, _, false);
        NineThousandAt = INACTIVE;
    }
    
    if(gameTime >= EnableCapAt)
    {
        if((Enabled || Enabled2) && CheckRoundState()==FF2RoundState_Loading)
        {
            SetControlPoint(true);
            if(checkDoors)
            {
                new ent=-1;
                while((ent=FindEntityByClassname2(ent, "func_door"))!=-1)
                {
                    AcceptEntityInput(ent, "Open");
                    AcceptEntityInput(ent, "Unlock");
                }
                CheckDoorsAt = GetEngineTime()+5.0;
            }
        }
        EnableCapAt = INACTIVE;
    }
    
    if(gameTime >= CheckDoorsAt)
    {
        if(!checkDoors)
        {
            CheckDoorsAt = INACTIVE;
            return;
        }

        if((!Enabled && CheckRoundState()!=FF2RoundState_Loading) || (Enabled && CheckRoundState()!=FF2RoundState_RoundRunning))
        {
            CheckDoorsAt = INACTIVE;
            return;
        }

        int entity=-1;
        while((entity=FindEntityByClassname2(entity, "func_door"))!=-1)
        {
            AcceptEntityInput(entity, "Open");
            AcceptEntityInput(entity, "Unlock");
        }
        CheckDoorsAt = INACTIVE;
    }
    
    if(gameTime >= StartFF2RoundAt)
    {
        DisplayNextBossPanelAt = GetEngineTime()+10.0;
        UpdateHealthBar();
        StartFF2RoundAt = INACTIVE;
    }
    
    if(gameTime >= DisplayNextBossPanelAt)
    {
        int clients;
        bool[] added = new bool[MaxClients+1];
        while(clients<3)  //TODO: Make this configurable?
        {
            int client=GetClientWithMostQueuePoints(added);
            if(!IsValidClient(client))  //No more players left on the server
            {
                break;
            }

            if(!IsBoss(client))
            {
                CPrintToChat(client, "{olive}[FF2]{default} %t", "to0_near");  //"You will become the Boss soon. Type {olive}/ff2next{default} to make sure."
            
                if (clients == 0)
                {
                    if(!IsBossSelected[client])
                    {
                        Command_YouAreNext(client, 0);
                    }
                }
                clients++;
            }
            added[client]=true;
        }
        DisplayNextBossPanelAt = INACTIVE;
    }
    if(gameTime >= ShowToolTipsAt)
    {
        if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            ShowToolTipsAt=INACTIVE;
            return;
        }

        for(int client=MaxClients;client;client--)
        {
            if(IsValidClient(client) && IsBoss(client))
            {
                if(showtip[client][1])
                {
                    PrintHintText(client, "%t", "Right Mouse Button Buttonmode");
                }
                else if(showtip[client][1] && showtip[client][2])
                {
                    PrintHintText(client, "%t\n%t", "Right Mouse Button Buttonmode", "Reload Buttonmode");
                }
                else if(showtip[client][1] && showtip[client][3])
                {
                    PrintHintText(client, "%t\n%t", "Right Mouse Button Buttonmode", "Special Buttonmode");
                }            
                else if(showtip[client][1] && showtip[client][2] && showtip[client][3])
                {
                    PrintHintText(client, "%t\n%t\%t", "Right Mouse Button Buttonmode", "Reload Buttonmode", "Special Buttonmode");
                }       
                else if(showtip[client][2])
                {
                    PrintHintText(client, "%t", "Reload Buttonmode");
                }            
                else if(showtip[client][2] && showtip[client][3])
                {
                    PrintHintText(client, "%t\n%t", "Reload Buttonmode", "Special Buttonmode");
                }              
                else if(showtip[client][3])
                {
                    PrintHintText(client, "%t", "Special Buttonmode");
                }
                for(int button=0;button<=3;button++)
                {
                    showtip[client][button]=false;
                }
            }
        }
        ShowToolTipsAt=INACTIVE;
    }
    
    if(gameTime >= DrawGameTimerAt)
    {
        if(BossHealth[0]<countdownHealth || CheckRoundState()!=FF2RoundState_RoundRunning || LivingMercs>countdownPlayers)
        {
            executed2=false;
            DrawGameTimerAt = INACTIVE;
            return;
        }

        new time=timeleft;
        timeleft--;
        if(time/60>9)
        {
            IntToString(time/60, timeDisplay, sizeof(timeDisplay));
        }    
        else
        {
            Format(timeDisplay, sizeof(timeDisplay), "0%i", time/60);
        }

        if(time%60>9)
        {
            Format(timeDisplay, sizeof(timeDisplay), "%s:%i", timeDisplay, time%60);
        }
        else
        {
            Format(timeDisplay, sizeof(timeDisplay), "%s:0%i", timeDisplay, time%60);
        }

        SetHudTextParams(-1.0, 0.17, 1.1, time<=(countdownTime*0.5) ? 255 : 0, time>(countdownTime*0.25) ? 255 : 0, 0, 255, time>=countdownTime ? 2 : 0);
        for(new client; client<=MaxClients; client++)
        {
            if(IsValidClient(client) && ((FF2Flags[client] & FF2FLAG_HUDDISABLED) || Companions || LivingMercs>1))
            {
                ShowSyncHudText(client, timeleftHUD, timeDisplay);
            }
        }

        switch(time)
        {
            case 300:
            {
                EmitSoundToAll("vo/announcer_ends_5min.mp3");
            }
            case 120:
            {
                EmitSoundToAll("vo/announcer_ends_2min.mp3");
            }
            case 60:
            {
                EmitSoundToAll("vo/announcer_ends_60sec.mp3");
            }
            case 30:
            {
                EmitSoundToAll("vo/announcer_ends_30sec.mp3");
            }
            case 10:
            {
                EmitSoundToAll("vo/announcer_ends_10sec.mp3");
            }
            case 1, 2, 3, 4, 5:
            {
                char sound[PLATFORM_MAX_PATH];
                Format(sound, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", time);
                EmitSoundToAll(sound);
            }
            case 0:
            {
                if(GetConVarBool(cvarCountdownOverTime) && (isCapping || useCPvalue))
                {
                    if(useCPvalue && capTeam>1)
                    {
                        int cp = -1; 
                        while ((cp = FindEntityByClassname(cp, "team_control_point")) != -1) 
                        { 
                            if(SDKCall(SDKGetCPPct, cp, capTeam)<=0.0)
                            {
                                EndBossRound();
                                DrawGameTimerAt = INACTIVE;
                                return;
                            }
                        }
                    }
                    roundOvertime=true;
                    CreateTimer(1.0, OverTimeAlert, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
                    DrawGameTimerAt = INACTIVE;
                    return;
                }
                
                EndBossRound();
                DrawGameTimerAt = INACTIVE;
                return;
            }
        }
        DrawGameTimerAt+=1.0;
    }
    
    if(gameTime >= DisplayMessageAt)
    {
        if(CheckRoundState())
        {
            DisplayMessageAt = INACTIVE;
            return;
        }

        if(checkDoors)
        {
            int entity=-1;
            while((entity=FindEntityByClassname2(entity, "func_door"))!=-1)
            {
                AcceptEntityInput(entity, "Open");
                AcceptEntityInput(entity, "Unlock");
            }

            CheckDoorsAt = gameTime+5.0;
        }
    
        SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255, makeScroll ? 2 : 0);
        char text[512];
        char textChat[512];
        char lives[4];
        char name[64];
        for(int client; client<=MaxClients; client++)
        {
            if(IsBoss(client))
            {
                int boss=Boss[client];
                KvRewind(BossKV[characterIdx[boss]]);
                KvGetString(BossKV[characterIdx[boss]], "name", name, sizeof(name), "=Failed name=");
                if(BossLives[boss]>1)
                {
                    Format(lives, 4, "x%i", BossLives[boss]);
                }    
                else
                {
                    strcopy(lives, 2, "");
                }
                
                char hUpdatedName[512];
                Format(hUpdatedName, sizeof(hUpdatedName), "%s | %s", hName, name);
                SetConVarString(sName, hUpdatedName);
                Format(text, sizeof(text), "%s\n%t", text, "ff2_start", Boss[boss], name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), lives);
                Format(textChat, sizeof(textChat), "{olive}[FF2]{default} %t!", "ff2_start", Boss[boss], name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), lives);
                ReplaceString(textChat, sizeof(textChat), "\n", "");  //Get rid of newlines
                CPrintToChatAll("%s", textChat);
                
                if(GetCompensationCount()>1.0)
                {
                    CPrintToChat(client,"{olive}[FF2]{default} %t", "ff2_compensation", RoundFloat(GetCompensationCount()*100.0));
                }
                if(GetDifficultyModifier(FF2ClientDifficulty[client])!=1.0)
                {
                    CPrintToChat(client,"{olive}[FF2]{default} %t", "ff2_difficulty_mod", RoundFloat(GetDifficultyModifier(FF2ClientDifficulty[client])*100.0));
                }
            }
        }

        for(int client; client<=MaxClients; client++)
        {
            if(IsValidClient(client))
            {
                PlayBGMAt[client]=GetEngineTime()+2.0;
                if(!Companions)
                {
                    if(!minimalHUD[client])
                    {
                        ShowGameText(client, (DeadRunMode == true ? "ico_ghost" : (DrawGameTimerAt!=INACTIVE) ? ((timeleft>=10 && timeleft<30) ? "ico_notify_thirty_seconds" : (timeleft<10) ? "ico_notify_ten_seconds" : "ico_notify_sixty_seconds") : roundOvertime ? "ico_notify_flag_moving_alt" : "leaderboard_streak"), _, text);
                    }
                    else
                    {
                        PrintCenterText(client, text);
                    }
                }
                else
                {
                    PrintCenterText(client, text);
                }
            }
        }
    
        if(DeadRunMode)
        {
            IsPreparing = false;
            for(int i = 1; i <= MaxClients; i++)
            {
                if(IsValidClient(i, true))
                {
                    SetEntityMoveType(i, MOVETYPE_WALK);
                }
            }
        }
        DisplayMessageAt = INACTIVE;
    }
 
    if(gameTime >= StartResponseAt)
    {
        char sound[PLATFORM_MAX_PATH];
        if(RandomSound("sound_begin", sound, PLATFORM_MAX_PATH) || FindSound("begin", sound, sizeof(sound)))
        {
            EmitSoundToAll(sound);
            EmitSoundToAll(sound);
        }
        SetClientQueuePoints(Boss[0], 0);
        StartResponseAt = INACTIVE;
    }
    
    if(gameTime >= MoveAt)
    {
        /*for(int client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client, true) && !IsBoss(client))
            {
                SetEntityMoveType(client, MOVETYPE_WALK);
            }
        }*/
        MoveAt = INACTIVE;
    }
    if(gameTime >= StartBossAt)
    {
        MoveAt=GetEngineTime()+0.1;
        UpdateRoundTickAt=GetEngineTime()+1.0;
    
        bool isBossAlive;
        for(new client; client<=MaxClients; client++)
        {
            if(IsValidClient(Boss[client], true))
            {
                isBossAlive=true;
            }
            
            if(isBossAlive && IsValidClient(client, true) && !IsBoss(client) && GetClientTeam(client)==BossTeam)
            {
                PrepareMercAt[client]=GetEngineTime()+0.1;
            }
        }

        if(!isBossAlive)
        {    
            StartBossAt = INACTIVE;
            return;
        }

        playing=0;
        for(int client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client, true) && !IsBoss(client))
            {
                playing++;
                PrepareMercAt[client]=GetEngineTime()+0.15;
            }
        }
        
        RoundTick = 0;
        FF2BossTick=gameTime+0.2;
        CheckAlivePlayersAt=gameTime+0.2;
        StartFF2RoundAt=gameTime+0.2;
        FF2ClientTick=gameTime+0.2;
        ShowToolTipsAt=gameTime+10.0;

        if(!PointType)
        {
            SetControlPoint(false);
        }
        StartBossAt = INACTIVE;
    }
}

// Game Events

public Action:Event_RoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
    makeScroll=true;
    capTeam=0;
    RoundCount++;
    TeamRoundCounter++;
    RoundTick=0;
    Companions=0;
    TotalCompanions=0;
    SetConVarString(sName, hName);
    if(HasSwitched)
    {
        HasSwitched=false;
    }
    
    SetConVarBool(FindConVar("mp_friendlyfire"), true);
    
    if(!Enabled)
    {
        return Plugin_Continue;
    }
    
    new winningTeam=GetEventInt(event, "team");
    new String:text[128], String:sound[PLATFORM_MAX_PATH];
    new bool:bossWin=false;
    executed=false;
    executed2=false;
    if((winningTeam==BossTeam))
    {
        bossWin=true;
        if(RandomSound("sound_win", sound, sizeof(sound)) || FindSound("win", sound, sizeof(sound)))
        {
            EmitSoundToAllExcept(SoundException_BossVoice, sound, _, _, _, _, _, _, Boss[0], _, _, false);
            EmitSoundToAllExcept(SoundException_BossVoice, sound, _, _, _, _, _, _, Boss[0], _, _, false);
        }
    }

    StopMusic(_, true, nomusic);

    DrawGameTimerAt=INACTIVE;
    
    new bool:isBossAlive, boss;
    for(new client; client<=MaxClients; client++)
    {
        if(IsValidClient(Boss[client]))
        {
            EnableClientGlow(Boss[client], 0.0, 0.0);
            SDKUnhook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);  //Temporary:  Used to prevent boss overheal
            if(IsPlayerAlive(Boss[client]))
            {
                isBossAlive=true;
            }

            for(new slot=1; slot<8; slot++)
            {
                BossCharge[client][slot]=0.0;
            }
        }
        else if(IsValidClient(client))
        {
            EnableClientGlow(client, 0.0, 0.0);
            shield[client]=0;
            detonations[client]=0;
        }
    }

    if(isBossAlive)
    {
        new String:bossName[64], String:lives[10];
        for(new target; target<=MaxClients; target++)
        {
            if(IsBoss(target))
            {
                boss=Boss[target];
                KvRewind(BossKV[characterIdx[boss]]);
                KvGetString(BossKV[characterIdx[boss]], "name", bossName, sizeof(bossName), "=Failed name=");
                if(BossLives[boss]>1)
                {
                    Format(lives, sizeof(lives), "x%i", BossLives[boss]);
                }
                else
                {
                    strcopy(lives, 2, "");
                }
                Format(text, PLATFORM_MAX_PATH, "%s\n%t", text, "ff2_alive", bossName, target, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
                
            }
        }
        
        new String:text2[256];
        strcopy(text2, sizeof(text2), text);
        ReplaceString(text2, sizeof(text2), "\n", "");
        CPrintToChatAll("{olive}[FF2]{default} %s", text2);
        
        if(!bossWin && (RandomSound("sound_fail", sound, PLATFORM_MAX_PATH, boss) || FindSound("fail", sound, sizeof(sound), boss)))
        {
            EmitSoundToAll(sound);
            EmitSoundToAll(sound);
        }
    }

    new top[3];
    Damage[0]=0;
    for(new client; client<=MaxClients; client++)
    {
        if(!IsValidClient(client) || Damage[client]<=0 || IsBoss(client))
        {
            continue;
        }

        if(Damage[client]>=Damage[top[0]])
        {
            top[2]=top[1];
            top[1]=top[0];
            top[0]=client;
            mvpCount[client]++;
        }
        else if(Damage[client]>=Damage[top[1]])
        {
            top[2]=top[1];
            top[1]=client;
            mvpCount[client]++;
        }
        else if(Damage[client]>=Damage[top[2]])
        {
            top[2]=client;
            mvpCount[client]++;
        }
    }

    if(Damage[top[0]]>9000)
    {
        NineThousandAt=GetEngineTime()+1.0;
    }

    new String:leaders[3][32];
    for(new i; i<=2; i++)
    {
        if(IsValidClient(top[i]))
        {
            GetClientName(top[i], leaders[i], 32);
        }
        else
        {
            Format(leaders[i], 32, "---");
            top[i]=0;
        }
    }

    SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
    PrintCenterTextAll("");
    for(new client; client<=MaxClients; client++)
    {
        if(IsValidClient(client))
        {
            // Reset gravity, color, alpha and move type
            if(GetEntityMoveType(client)!=MOVETYPE_WALK)
            {
                SetEntityMoveType(client, MOVETYPE_WALK);
            }

            if(GetEntityGravity(client)!=1.0)
            {
                SetEntityGravity(client, 1.0);
            }

            SetEntityRenderColor(client, 255, 255, 255, 255);

            // ETC
            SetGlobalTransTarget(client);
            //TODO:  Clear HUD text here
            if(IsBoss(client))
            {
                FF2_ShowSyncHudText(client, infoHUD, "%s\n%t\n1) %i-%s\n2) %i-%s\n3) %i-%s\n\n%t", text, "top_3", Damage[top[0]], leaders[0], Damage[top[1]], leaders[1], Damage[top[2]], leaders[2], (bossWin ? "boss_win" : "boss_lose"));
            }
            else
            {
                FF2_ShowSyncHudText(client, infoHUD, "%s\n%t\n1) %i-%s\n2) %i-%s\n3) %i-%s\n\n%t\n%t", text, "top_3", Damage[top[0]], leaders[0], Damage[top[1]], leaders[1], Damage[top[2]], leaders[2], "damage_fx", Damage[client], "scores", RoundFloat(Damage[client]/600.0));
            }
        }
    }
    timeDisplay="88:88";
    ShowBossStats(winningTeam);
    CalcQueuePointsAt=GetEngineTime()+3.0;
    UpdateHealthBar();
    
    if(ReloadFF2)
    {
        ServerCommand("sm plugins reload freak_fortress_2");
    }
    
    if(LoadCharset)
    {
        LoadCharset=false;
        FindCharacters();
        strcopy(FF2CharSetString, 2, "");        
    }
    
    if(ReloadWeapons)
    {
        CacheWeapons();
        ReloadWeapons=false;
    }
    
    if(ReloadConfigs)
    {
        CacheWeapons();
        CheckToChangeMapDoors();
        CheckToTeleportToSpawn();
        FindCharacters();
        ReloadConfigs=false;
    }
    
    return Plugin_Continue;
}

public Action:Event_Setup(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(executed4)
    {
        if(!CountParticipants())
        {
            return Plugin_Continue;
        }
        else if(CountParticipants()==1)
        {
            if(GetConVarInt(FindConVar("tf_bot_quota"))<2)
            {
                SetConVarInt(FindConVar("tf_bot_quota"), 2);
            }
            CPrintToChatAll("{olive}[FF2]{default} %t", "needmoreplayers");
        }
        else
        {
            executed4=false;
        }
    }

    makeScroll=true;
    teamplay_round_start_TeleportToMultiMapSpawn(); // Cache spawns
    SetConVarBool(FindConVar("mp_friendlyfire"), false);
    isCapping=false;
    if(changeGamemode==1)
    {
        EnableFF2();
    }
    else if(changeGamemode==2)
    {
        DisableFF2();
    }

    if(!GetConVarBool(cvarEnabled))
    {
        #if defined _steamtools_included
        if(steamtools)
        {
            Steam_SetGameDescription("Team Fortress");
        }
        #endif
        Enabled2=false;
    }

    Enabled=Enabled2;
    if(!Enabled)
    {
        return Plugin_Continue;
    }

    if(FileExists("bNextMapToFF2"))
    {
        DeleteFile("bNextMapToFF2");
    }

    currentBossTeam=GetRandomInt(1,2);
    switch(GetConVarInt(cvarForceBossTeam))
    {
        case 1:
        {
            blueBoss=bool:GetRandomInt(0, 1);
        }
        case 2:
        {
            blueBoss=false;
        }
        case 3:
        {
            blueBoss=true;
        }
        default:
        {
            if (Maptype(currentmap) == Maptype_VSH || Maptype(currentmap)== MapType_PropHunt || Maptype(currentmap) == Maptype_Deathrun) 
                blueBoss = true;
            else if (TeamRoundCounter >= 3 && GetRandomInt(0, 1))
            {
                blueBoss = (BossTeam != 3);
                TeamRoundCounter = 0;
            }
            else blueBoss = (BossTeam == 3);
        }
    }

    if(GetClientCount()<=1 || playing<=1)  //Not enough players D:
    {
        SetConVarString(sName, hName);
        Enabled=false;
        DisableSubPlugins();
        SetControlPoint(true);
        executed4=true;
        return Plugin_Continue;
    }
    else if(RoundCount<arenaRounds)  //We're still in arena mode
    {
        CPrintToChatAll("{olive}[FF2]{default} %t", "arena_round", arenaRounds-RoundCount);
        Enabled=false;
        DisableSubPlugins();
        SetArenaCapEnableTime(60.0);
        EnableCapAt=GetEngineTime()+71.0;
        new bool:toRed;
        new TFTeam:team;
        for(new client; client<=MaxClients; client++)
        {
            if(IsValidClient(client) && (team=TFTeam:GetClientTeam(client))>TFTeam_Spectator)
            {
                SetEntProp(client, Prop_Send, "m_lifeState", 2);
                if(toRed && team!=TFTeam_Red)
                {
                    ChangeClientTeam(client, _:TFTeam_Red);
                }
                else if(!toRed && team!=TFTeam_Blue)
                {
                    ChangeClientTeam(client, _:TFTeam_Blue);
                }
                SetEntProp(client, Prop_Send, "m_lifeState", 0);
                TF2_RespawnPlayer(client);
                toRed=!toRed;
            }
        }
        return Plugin_Continue;
    }

    for(new client; client<=MaxClients; client++)
    {
        Boss[client]=0;
        if(IsValidClient(client, true) && !(FF2Flags[client] & FF2FLAG_HASONGIVED))
        {
            TF2_RespawnPlayer(client);
        }
    }

    Enabled=true;
    EnableSubPlugins();
    CheckArena();

    if(!DeadRunMode) 
    {
        SearchForItemPacks();
    }
    
    new bool:omit[MaxClients+1];
    Boss[0]=GetClientWithMostQueuePoints(omit);
    omit[Boss[0]]=true;
    
    new bool:teamHasPlayers[TFTeam];
    for(new client=1; client<=MaxClients; client++)  //Find out if each team has at least one player on it
    {
        if(IsValidClient(client))
        {
            new TFTeam:team=TFTeam:GetClientTeam(client);
            if(team>TFTeam_Spectator)
            {
                teamHasPlayers[team]=true;
            }

            if(teamHasPlayers[TFTeam_Blue] && teamHasPlayers[TFTeam_Red])
            {
                break;
            }
        }
    }

    if(!teamHasPlayers[TFTeam_Blue] || !teamHasPlayers[TFTeam_Red])  //If there's an empty team make sure it gets populated
    {
        if(IsValidClient(Boss[0]) && GetClientTeam(Boss[0])!=BossTeam)
        {
            AssignTeam(Boss[0], TFTeam:BossTeam);
        }

        for(new client=1; client<=MaxClients; client++)
        {
            if(IsValidClient(client) && !IsBoss(client) && GetClientTeam(client)!=MercTeam)
            {
                PrepareMercAt[client]=GetEngineTime()+0.1;
            }
        }
        return Plugin_Continue;  //NOTE: This is needed because Event_Setup gets fired a second time once both teams have players
    }

    PickCharacter(0, 0);
    if((characterIdx[0]<0) || !BossKV[characterIdx[0]])
    {
        LogToFile(bLog,"[FF2 Bosses] Unable to find a boss!");
        return Plugin_Continue;
    }
    
    Companions=0;
    TotalCompanions=0;
    FindCompanion(0, playing, omit);  //Find companions for the boss!

    for(new boss; boss<=MaxClients; boss++)
    {
        if(Boss[boss])
        {
            CreateTimer(0.3, MakeBoss, boss, TIMER_FLAG_NO_MAPCHANGE);
        }
    }
    
    StartResponseAt = GetEngineTime()+3.5;
    StartBossAt = GetEngineTime()+9.1;
    DisplayMessageAt = GetEngineTime()+9.6;
    
    for(new entity=MaxClients+1; entity<MaxEntities; entity++)
    {
        if(!IsValidEdict(entity))
        {
            continue;
        }

        decl String:classname[64];
        GetEdictClassname(entity, classname, 64);
        if(!strcmp(classname, "func_regenerate"))
        {
            AcceptEntityInput(entity, "kill");
        }
        else if(!strcmp(classname, "func_respawnroomvisualizer"))
        {
            AcceptEntityInput(entity, "disable");
        }
    }
    
    for(new client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
        {
            continue;
        }
        
        if(DeadRunMode)
        {
            IsPreparing=true;
            SetEntityMoveType(client, MOVETYPE_NONE);
        }
    
        ClientQueue[client][0] = client;
        ClientQueue[client][1] = GetClientQueuePoints(client);
    }
    
    SortCustom2D(ClientQueue, sizeof(ClientQueue), SortQueueDesc);
    
    for(new client=1;client<=MaxClients;client++)
    {
        if(!IsValidClient(client))
        {
            continue;
        }

        ClientID[client] = ClientQueue[client][0];
        ClientPoint[client] = ClientQueue[client][1];
        
        if (BossCookieSetting[client] == FF2Setting_Enabled)
        {
            new index = -1;
            for(new i = 1; i < MAXPLAYERS+1; i++)
            {
                if (ClientID[i] == client)
                {
                    index = i;
                    break;
                }
            }    
            if (index > 0)
            {
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Queue Notification", index, ClientPoint[index]);
            }
            else
            {
                CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Enabled Notification");
               }
        }
        else if (BossCookieSetting[client] == FF2Setting_Disabled)
        {
               decl String:nick[64]; 
               GetClientName(client, nick, sizeof(nick));
               CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
        }
        
        if(BossCookieSetting[client]==FF2Setting_Unknown || !BossCookieSetting[client] || CompanionCookieSetting[client]==FF2Setting_Unknown || !CompanionCookieSetting[client] || FF2ClientDifficulty[client]==FF2Difficulty_Unknown || !FF2ClientDifficulty[client])
        {
            CreateTimer(GetConVarFloat(cvarFF2TogglePrefDelay), ConfigTimer, client, TIMER_FLAG_NO_MAPCHANGE);
        }
    }
    timeDisplay="88:88";
    healthcheckused=0;
    firstBlood=true;    
    return Plugin_Continue;    
}

public Action:Event_PostInventoryApplication(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(!Enabled)
    {
        return Plugin_Continue;
    }
    new client=GetClientOfUserId(GetEventInt(event, "userid"));
    if(!IsValidClient(client))  //I...what.  Apparently this is needed though?
    {
        return Plugin_Continue;
    }
    
    if(GetAlivePlayerCount(2)>1)
    {
        executed3=false;
    }
    
    airstab[client]=0;
    GoombaCount[client]=0;
    
    SetVariantString("");
    AcceptEntityInput(client, "SetCustomModel");
    
    if(IsBoss(client))
    {
        CreateTimer(0.1, MakeBoss, GetBossIndex(client));
    }
    
    if(!(FF2Flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
    {
        if(CheckRoundState()!=FF2RoundState_RoundRunning)
        {
            if(!(FF2Flags[client] & FF2FLAG_HASONGIVED))
            {
                FF2Flags[client]|=FF2FLAG_HASONGIVED;
                RemovePlayerBack(client, {57, 133, 405, 444, 608, 642}, 7);
                RemovePlayerTarge(client);
                TF2_RemoveAllWeapons(client);
                TF2_RegeneratePlayer(client);
                RequestFrame(Frame_RegenPlayer, client);
            }
            PrepareMercAt[client]=GetEngineTime()+0.2;
        }
        else
        {
            InspectPlayerInventoryAt[client]=GetEngineTime()+0.1;
        }
    }
    FF2Flags[client]&=~(FF2FLAG_DISABLE_SPEED_MANAGEMENT|FF2FLAG_DISABLE_WEAPON_MANAGEMENT|FF2FLAG_UBERREADY|FF2FLAG_ISBUFFED|FF2FLAG_TALKING|FF2FLAG_ALLOWSPAWNINBOSSTEAM|FF2FLAG_USINGABILITY|FF2FLAG_CLASSHELPED|FF2FLAG_CHANGECVAR|FF2FLAG_ALLOW_HEALTH_PICKUPS|FF2FLAG_ALLOW_AMMO_PICKUPS|FF2FLAG_ROCKET_JUMPING);
    FF2Flags[client]|=FF2FLAG_USEBOSSTIMER;
    return Plugin_Continue;
}

// VSH Feedback
#include <freak_fortress_2_vsh_feedback>
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

		Updated by Otokiru, Powerlord, and RavensBro, Wliu, Chris, Lawd, and Carge
----------------------------------------------------------------------------------------
*/

#pragma semicolon 1

#include <sourcemod>
#include <freak_fortress_2>
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
#tryinclude <smac>
#tryinclude <goomba>
#tryinclude <rtd>
#tryinclude <tf2attributes>
#tryinclude <updater>
#tryinclude <nativevotes>
#define REQUIRE_PLUGIN


#define FILECHECK_ENABLED
/*
	This fork uses a different versioning system
	as opposed to the public FF2 versioning system
*/
#define FORK_MAJOR_REVISION "1"
#define FORK_MINOR_REVISION "32"
//#define FORK_SUB_REVISION	"0"

#if !defined FORK_SUB_REVISION
	#define PLUGIN_VERSION FORK_MAJOR_REVISION..."."...FORK_MINOR_REVISION
#else
	#define PLUGIN_VERSION FORK_MAJOR_REVISION..."."...FORK_MINOR_REVISION..."."...FORK_SUB_REVISION
#endif
/*
	And now, let's report its version as the latest public FF2 version
	for subplugins or plugins that uses the FF2_GetFF2Version native.
*/
#define MAJOR_REVISION "1"
#define MINOR_REVISION "10"
#define STABLE_REVISION "6"

#define MAXENTITIES 2048
#define MAXSPECIALS 700
#define MAXRANDOMS 96

#define SOUNDEXCEPT_MUSIC 0
#define SOUNDEXCEPT_VOICE 1

#define HEALTHBAR_CLASS "monster_resource"
#define HEALTHBAR_PROPERTY "m_iBossHealthPercentageByte"
#define HEALTHBAR_MAX 255
#define MONOCULUS "eyeball_boss"
#define DISABLED_PERKS "toxic,noclip,uber,ammo,instant,jump,tinyplayer"

#define INACTIVE 100000000.0

#define UPDATE_URL "http://www.shadow93.info/bbg/ff2/update.txt"

#define TF_MAX_PLAYERS          34             //  Sourcemod supports up to 64 players? Too bad TF2 doesn't. 33 player server +1 for 0 (console/world)

static const char UnBonked[][] = {
	"vo/scout_sf12_badmagic04.mp3",
	"vo/scout_sf12_badmagic09.mp3",
	"vo/scout_sf13_magic_reac03.mp3",
	"vo/scout_invinciblenotready06.mp3"
};

#define AHH_PISS "vo/sniper_negativevocalization03.mp3"

#if defined _steamtools_included
new bool:steamtools=false;
#endif

#if defined _tf2attributes_included
new bool:tf2attributes=false;
#endif

#if defined _goomba_included
new bool:goomba=false;
#endif

new RPSWinner;
new bool:RPSLoser[MAXPLAYERS+1];
new bool:blueBoss;

new bool:smac=false;
new MercTeam=2;
new BossTeam=3;
new playing;
new healthcheckused;
new AliveMercPlayers;
new AliveBossPlayers;
new RoundCount;
new TeamRoundCounter;
new Special[MAXPLAYERS+1];
new Incoming[MAXPLAYERS+1];
new MusicIndex;

new Damage[MAXPLAYERS+1];
new curHelp[MAXPLAYERS+1];
new uberTarget[MAXPLAYERS+1];
new shield[MAXPLAYERS+1];
new detonations[MAXPLAYERS+1];
new GoombaCount[MAXPLAYERS+1];
new airstab[MAXPLAYERS+1];
new FF2flags[MAXPLAYERS+1];

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

new bool:HasCompanions = false;
new bool:UnBonkSlowDown[MAXPLAYERS+1]=false;
new bool:emitRageSound[MAXPLAYERS+1];
new bool:bSpawnTeleOnTriggerHurt = false;
new timeleft;

new Handle:cvarVersion;
new Handle:cvarPointDelay;
new Handle:cvarAnnounce;
new Handle:cvarEnabled;
new Handle:cvarAliveToEnable;
new Handle:cvarPointType;
new Handle:cvarCrits;
new Handle:cvarFirstRound;  //DEPRECATED
new Handle:cvarArenaRounds;
new Handle:cvarCircuitStun;
new Handle:cvarCountdownPlayers;
new Handle:cvarCountdownTime;
new Handle:cvarCountdownHealth;
new Handle:cvarCountdownResult;
new Handle:cvarEnableEurekaEffect;
new Handle:cvarForceBossTeam;
new Handle:cvarHealthBar;
new Handle:cvarLastPlayerGlow;
new Handle:cvarBossTeleporter;
new Handle:cvarBossSuicide;
new Handle:cvarShieldCrits;
new Handle:cvarCaberDetonations;
new Handle:cvarGoombaDamage;
new Handle:cvarGoombaRebound;
new Handle:cvarBossRTD;
new Handle:cvarUpdater;
new Handle:cvarDebug;
new Handle:cvarSpellBooks;
new Handle:cvarRPSQueuePoints;
new Handle:cvarSubtractRageOnJarate;

new Handle:FF2Cookies;

new Handle:jumpHUD;
new Handle:cloakHUD;
new Handle:rageHUD;
new Handle:livesHUD;
new Handle:timeleftHUD;
new Handle:abilitiesHUD;
new Handle:infoHUD;

new bool:Enabled=true;
new bool:Enabled2=true;

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
new bool:canBossRTD;
new Handle:MusicTimer;
new Handle:BossInfoTimer[MAXPLAYERS+1][2];

new botqueuepoints;
new Float:HPTime;
new String: currentmap[99];
new bool:checkDoors=false;
new bool:bMedieval;
new bool:firstBlood;

new bool:skewerCooldown[MAXPLAYERS+1];
new Float:skewerCooldownEndsIn[MAXPLAYERS+1];


new tf_arena_use_queue;
new mp_teams_unbalance_limit;
new tf_arena_first_blood;
new mp_forcecamera;
new Float:tf_dropped_weapon_lifetime;
new Float:tf_feign_death_activate_damage_scale;
new Float:tf_feign_death_damage_scale;
new tf_feign_death_duration;
new Float:tf_stealth_damage_reduction;

new Handle:cvarNextmap;
new bool:areSubPluginsEnabled;

new FF2CharSet;
new String:FF2CharSetString[42];
new bool:isCharSetSelected=false;
new bool:isCharsetOverride=false;
new healthBar=-1;
new g_Monoculus=-1;

static bool:executed=false;
static bool:executed2=false;

new changeGamemode;

new String: chkcurrentmap[PLATFORM_MAX_PATH];
new bool:DeadRunMode = false;
new bool:IsPreparing = false;
new RoundTick = 0;

new String: hName[512];
new Handle:sName;

new bool:IsBossSelected[MAXPLAYERS+1];
new bool:dmgTriple[MAXPLAYERS+1];

// Deathrun
new drboss;

// Dont trigger death events
new bool:isCosmetic=false;

// Admin overrides
new bool:AdminBossOverride;
 
// Timer replacements
new Float:CalcQueuePointsAt;
new Float:CheckAlivePlayersAt;
new Float:StartFF2RoundAt;
new Float:AnnounceAt;
new Float:NineThousandAt;
new Float:EnableCapAt;
new Float:CheckDoorsAt;
new Float:UpdateRoundTickAt;
new Float:DrawGameTimerAt;
new Float:DisplayMessageAt;
new Float:StartBossAt;
new Float:StartResponseAt;
new Float:DisplayNextBossPanelAt;
new Float:MoveAt;

// Boss & Client Timer Replacements;
new Float:FF2BossTick;
new Float:FF2ClientTick;


// Enums

#define MAX_OPERATIONS 128

enum MapKind
{
	Maptype_VSH = 1,
	Maptype_Arena,
	Maptype_Deathrun,
	Maptype_Other,
}

enum FF2RoundState
{
	FF2RoundState_Loading=-1,
	FF2RoundState_Setup,
	FF2RoundState_RoundRunning,
	FF2RoundState_RoundEnd,
}

enum Operators
{
	Operator_None=-1,
	Operator_Add,
	Operator_Subtract,
	Operator_Multiply,
	Operator_Divide,
	Operator_Exponent,
};

static bool:HasSwitched=false;
static bool:ReloadFF2=false;
new bool:LoadCharset=false;

static const String:ff2versiontitles[][]=
{
	"1.0",
	"1.01",
	"1.01",
	"1.02",
	"1.03",
	"1.04",
	"1.05",
	"1.05",
	"1.06",
	"1.06c",
	"1.06d",
	"1.06e",
	"1.06f",
	"1.06g",
	"1.06h",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 1",
	"1.07 beta 4",
	"1.07 beta 5",
	"1.07 beta 6",
	"1.07",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.0.8",
	"1.9.0",
	"1.9.0",
	"1.9.1",
	"1.9.2",
	"1.9.2",
	"1.9.3",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.0",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.1",
	"1.10.2",
	"1.10.3",
	"1.10.3",
	"1.10.3",
	"1.10.3",
	"1.11",
	"1.11",
	"1.12",
	"1.13",
	"1.13",
	"1.13",
	"1.13",
	"1.13",
	"1.13",
	"1.14",
	"1.15",
	"1.16",
	"1.17",
	"1.18",
	"1.19",
	"1.19",
	"1.20",
	"1.20",
	"1.21",
	"1.21",
	"1.21",
	"1.22",
	"1.22",
	"1.23",
	"1.23",
	"1.23",
	"1.24",
	"1.24",
	"1.25",
	"1.26",
	"1.27",
	"1.28",
	"1.29",
	"1.30",
	"1.30",
	"1.31", // Initial release & rollup 1-2
	"1.31", // Update Rollups 3-4
	"1.31",	// Update Rollups 5-6
	"1.31",	// Update Rollups 7-15
	"1.32",
	"1.32"
};

static const String:ff2versiondates[][]=
{
	"6 April 2012",		//1.0
	"14 April 2012",	//1.01
	"14 April 2012",	//1.01
	"17 April 2012",	//1.02
	"19 April 2012",	//1.03
	"21 April 2012",	//1.04
	"29 April 2012",	//1.05
	"29 April 2012",	//1.05
	"1 May 2012",		//1.06
	"22 June 2012",		//1.06c
	"3 July 2012",		//1.06d
	"24 Aug 2012",		//1.06e
	"5 Sep 2012",		//1.06f
	"5 Sep 2012",		//1.06g
	"6 Sep 2012",		//1.06h
	"8 Oct 2012",		//1.07 beta 1
	"8 Oct 2012",		//1.07 beta 1
	"8 Oct 2012",		//1.07 beta 1
	"8 Oct 2012",		//1.07 beta 1
	"8 Oct 2012",		//1.07 beta 1
	"11 Oct 2012",		//1.07 beta 4
	"18 Oct 2012",		//1.07 beta 5
	"9 Nov 2012",		//1.07 beta 6
	"14 Dec 2012",		//1.07
	"October 30, 2013",	//1.0.8
	"October 30, 2013",	//1.0.8
	"October 30, 2013",	//1.0.8
	"October 30, 2013",	//1.0.8
	"October 30, 2013",	//1.0.8
	"March 6, 2014",	//1.9.0
	"March 6, 2014",	//1.9.0
	"March 18, 2014",	//1.9.1
	"March 22, 2014",	//1.9.2
	"March 22, 2014",	//1.9.2
	"April 5, 2014",	//1.9.3
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"July 26, 2014",	//1.10.0
	"August 28, 2014",	//1.10.1
	"August 28, 2014",	//1.10.1
	"August 28, 2014",	//1.10.1
	"August 28, 2014",	//1.10.1
	"August 28, 2014",	//1.10.1
	"August 28, 2014",	//1.10.2
	"November 6, 2014",	//1.10.3
	"November 6, 2014",	//1.10.3
	"November 6, 2014",	//1.10.3
	"November 6, 2014",	//1.10.3
	"November 6, 2014",	//1.10.3
	"February 6, 2015",	//1.11
	"February 6, 2015",	//1.11
	"February 23, 2015",	//1.12 BBG
	"March 1, 2015",	//1.13 BBG
	"March 1, 2015",	//1.13 BBG
	"March 1, 2015",		//1.13 BBG
	"March 1, 2015",	//1.13 BBG
	"March 1, 2015",		//1.13 BBG
	"March 1, 2015",	//1.14 BBG
	"March 4, 2015",	//1.15 BBG
	"March 6, 2015", // 1.16 bbg
	"March 7, 2015", // 1.17 bbg
	"March 17, 2015", // 1.18 BBG
	"March 22, 2015",	// 1.19 BBG
	"March 22, 2015",	// 1.19 BBG
	"March 26, 2015",	//1.20 BBG
	"March 26, 2015",	//1.20 BBG
	"April 5, 2015",		//1.21
	"April 5, 2015",		//1.21
	"April 5, 2015",		//1.21
	"April 8, 2015",		//1.22
	"April 8, 2015",		//1.22
	"April 12, 2015",		//1.23
	"April 12, 2015",		//1.23
	"April 12, 2015",		//1.23
	"April 18, 2015",		//1.24
	"April 18, 2015",		//1.24
	"April 30, 2015",		//1.25
	"May 5, 2015",		//1.26
	"May 10, 2015",		//1.27
	"May 15, 2015",		//1.28
	"May 23, 2015",		//1.29
	"June 19, 2015",		//1.30
	"June 19, 2015",		//1.30
	"July 14, 2015",			//1.31
	"July 14, 2015",			//1.31
	"July 14, 2015",			//1.31
	"July 14, 2015",			//1.31
	"July 25, 2015",			//1.32
	"July 25, 2015"			//1.32
};

stock FindVersionData(Handle:panel, versionIndex)
{
	switch(versionIndex)
	{
		case 93: // 1.32
		{
			DrawPanelText(panel, "1) Replaced Sniper Rifle crits with triple damage (Wliu)");		
			DrawPanelText(panel, "2) Fixed Gun Mettle Medigun skins being replaced by a normal medigun (SHADoW)");		
			DrawPanelText(panel, "3) The Huntsman skewer taunt now has a cooldown between uses (SHADoW)");			
			DrawPanelText(panel, "4) Fixed boss anchor not working properly (SHADoW)");		
			DrawPanelText(panel, "5) Sandviches provide temporary damage protection while being consumed (SHADoW)");	
		}
		case 92: // 1.32
		{
			DrawPanelText(panel, "6) Air strike grants full crits while blast jumping, minicrits if parachuting (SHADoW)");					
			DrawPanelText(panel, "7) Fixed certain weapons not getting their stats overriden (SHADoW)");					
			DrawPanelText(panel, "8) Fixed stun scaling always returning solo-raging (SHADoW)");					
		}
		case 91: // 1.31
		{
			DrawPanelText(panel, "1) Reverted Gunslinger buffs (SHADoW)");		
			DrawPanelText(panel, "2) Reverted some Valve weapon buffs/nerfs and allowed Natascha to be used (SHADoW)");			
			DrawPanelText(panel, "3) Fixed 1st round bosses not getting all of their health (SHADoW)");			
			DrawPanelText(panel, "4) Stun rage duration is now scaled by players caught in radius, duration arg is max length (SHADoW)");
			DrawPanelText(panel, "5) Fixed first person weapon animation bugs (Chdata)");
		}
		case 90: // 1.31
		{
			DrawPanelText(panel, "6) Disabled dropping weapons during boss rounds (sarysa/Starblaster64)");
			DrawPanelText(panel, "7) Fixed a bug with teleport particles not working properly (Wliu from M76030)");
			DrawPanelText(panel, "8) Fixed a bug with teleport sounds not playing properly (Wliu from M76030)");
			DrawPanelText(panel, "9) Whitelisted new Gun Mettle cosmetic weapon skins (SHADoW)");
			DrawPanelText(panel, "10) Cloak and dagger is now an invis-watch reskin (SHADoW)");		}
		case 89: // 1.31
		{
			DrawPanelText(panel, "11) Updated Big Earner to provide a momentary speed boost upon backstab (Starblaster64)");
			DrawPanelText(panel, "12) Cloak and dagger is now an invis-watch reskin (SHADoW)");
			DrawPanelText(panel, "13) Fixed teleport to spawn firing before a round starts if a boss congas/kazotsky kicks to a harmful location (SHADoW)");
			DrawPanelText(panel, "14) Fixed Sydney Sleeper subtracting RAGE (Starblaster64)");
			DrawPanelText(panel, "15) Spies can no longer get cloak from dispensers while cloaked (Chdata)");
		}
		case 88: // 1.31
		{
			DrawPanelText(panel, "16) Fixed large amounts of damage insta-killing multi-life bosses (Wliu)");
			DrawPanelText(panel, "17) Dead Ringer will reduce incoming damage to 62 while cloaked. No speed boost on feign death.(Chdata)");
			DrawPanelText(panel, "18) All invis watch types will reduce other incoming damage by 90pct.(Starblaster64)");
			DrawPanelText(panel, "19) Diamondback revenge crits on stab reduced from 3 -> 2.(Chdata)");
		}
		case 87: // 1.30
		{
			DrawPanelText(panel, "1) Replaced many, many timers (SHADoW)");
			DrawPanelText(panel, "2) Added market gardener/caber/goomba/killstreak killfeed counters (SHADoW)");
			DrawPanelText(panel, "3) Short circuit stuns have 3 second delay between uses (SHADoW)");
			DrawPanelText(panel, "4) !ff2boss can now specify a boss's name to select a boss (SHADoW)");
			DrawPanelText(panel, "5) Hitting the boss with disciplinary action gives you 5 sec speed buff (Chdata from VSH)");
		}
		case 86: // 1.30
		{
			DrawPanelText(panel, "6) RPS is now all-or-nothing (SHADoW from BBG_Theory)");
			DrawPanelText(panel, "7) RPS will now add/subtract queue points if playing against a minion or teammate (SHADoW)");
			DrawPanelText(panel, "8) Fixed invalid client errors with 'easter_abilities' (Wliu)");
			DrawPanelText(panel, "9) Stun rage lasts 1/2 the duration if used for solo raging, and will print serverwide notifcation (SHADoW)");
			DrawPanelText(panel, "10) Added command !ff2_{load|reload}charset (REQUIRES CHEATS FLAG) (SHADoW)");
		}
		case 85: // 1.29
		{
			DrawPanelText(panel, "1) Companion selection is now random & no longer based on queue points (SHADoW)");
			DrawPanelText(panel, "2) Optimized FF2 to allow late load / reload (SHADoW)");
			DrawPanelText(panel, "3) Boss notification panel no longer interferes with any active votes (SHADoW)");
			DrawPanelText(panel, "4) Added 'FF2FLAG_DISABLE_SPEED_MANAGEMENT' flag to disable FF2's speed management (SHADoW)");
			DrawPanelText(panel, "5) Added 'FF2FLAG_DISABLE_WEAPON_MANAGEMENT' flag to disable FF2's default weapon attributes (SHADoW)");
		}
		case 84: // 1.28
		{
			DrawPanelText(panel, "1) Increased airblast cost from 20 to 25 for flamethrowers (except backburner)(SHADoW)");
			DrawPanelText(panel, "2) Allowed 'ff2_reload_subplugins' to reload a specific subplugin (SHADoW)");
			DrawPanelText(panel, "3) Fixed bosses with the {AMMO|HEALTH} pickups flag not being able to pick up ammo/health (SHADoW)");
			DrawPanelText(panel, "4) Integrated FF2 Toggle / Reset Points option into !ff2boss menu & added 'Random' option (SHADoW)");
			DrawPanelText(panel, "5) Added 'sound_ability_serverwide' for serverwide RAGE sound (SHADoW)");	
		}
		case 83: // 1.27
		{
			DrawPanelText(panel, "1) Goomba Stomp, Market Garden, Caber Stab & Backstab now show boss's name (SHADoW)");
			DrawPanelText(panel, "2) Added 'ff2_votecharset' to manually start a charset vote (SHADoW)");
			DrawPanelText(panel, "3) Auto-adjust environmental damage if extremely lethal to the boss (SHADoW)");
			DrawPanelText(panel, "4) Added config option to set ammo / clip to a boss weapon (SHADoW)");
			DrawPanelText(panel, "5) Added config option to enable / disable HP formula compatibility mode (SHADoW)");
		}
		case 82: // 1.26
		{
			DrawPanelText(panel, "1) 'ff2_addpoints' now targets player using the command if no target is specified (SHADoW)");
			DrawPanelText(panel, "2) Fixed teleport to spawn not firing sometimes (SHADoW)");
			DrawPanelText(panel, "3) Optimized team switching code (SHADoW)");
			DrawPanelText(panel, "4) Created cvar to enable/disable spellbooks on-the-fly (SHADoW)");
			DrawPanelText(panel, "5) Hopefully fixed taunt condition sometimes not being removed if activating RAGE via taunting (SHADoW)");
		}
		case 81: // 1.25
		{
			DrawPanelText(panel, "6) Block 'Medic!' voice line when activating RAGE via calling for medic (SHADoW)");
			DrawPanelText(panel, "7) Block healing while wallclimbing (SHADoW)");
			DrawPanelText(panel, "8) Fixed bosses not being able to to mark players for death (SHADoW)");
			DrawPanelText(panel, "9) Bosses can no longer taunt for crits (SHADoW)");
			DrawPanelText(panel, "10) Fixed companions losing queue points (SHADoW)");
		}
		case 80: // 1.24
		{
			DrawPanelText(panel, "1) Prevent RAGE from exceeding 100pct (SHADoW)");
			DrawPanelText(panel, "2) Jarate/Mad Milk & reskins now removes 25pct RAGE, up from 8pct (SHADoW)");
			DrawPanelText(panel, "3) Bonk! Atomic Punch: Marked for death & slowdown for 10 secs after effect wears off (SHADoW/Cpt.Haxray)");
			DrawPanelText(panel, "4) Gunslinger: +100pct Sentry Range / Building Health (SHADoW)");
			DrawPanelText(panel, "5) Gunboats: Now also deals 3x fall damage to player landed on (SHADoW)");
		}
		case 79: // 1.24
		{
			DrawPanelText(panel, "6) Blutsauger: +1 HP on-hit, no health regen, +1% uber per hit (SHADoW)");
			DrawPanelText(panel, "7) Pain train: +25% damage, +5 sec bleed on-hit, self-damage on-miss (SHADoW)");
			DrawPanelText(panel, "8) Sun-on-a-stick: ignite players on-hit, self-damage on-miss (SHADoW)");
			DrawPanelText(panel, "9) Bottle & Scottish Handshake: bleed on-hit if broken (SHADoW)");
			DrawPanelText(panel, "10) Ullapool 'airstabs' will no longer count towards detonation limit (SHADoW)");
		}
		case 78: // 1.23
		{
			DrawPanelText(panel, "1) Prevent non-existent files from attempting to download (SHADoW)");
			DrawPanelText(panel, "2) Updated 'mod_download' to download .phy files, if it exists (SHADoW)");	
			DrawPanelText(panel, "3) Tweaked teleport to spawn to only fire if damage is at least 450 (SHADoW)");			
			DrawPanelText(panel, "4) Added warning for non-existent files for easier boss config management (SHADoW)");
			DrawPanelText(panel, "5) Fixed 'FF2_PreAbility' causing server crashes (WildCard65)");						
		}
		case 77: // 1.23
		{
			DrawPanelText(panel, "6) Ali Baba's Wee Booties & The Bootlegger now deals 3x fall damage to the player landed on (SHADoW)");
			DrawPanelText(panel, "7) Fixed toolbox and sappers not having its netpprops attached if specified as a boss weapon (SHADoW)");	
			DrawPanelText(panel, "8) Update boss replacement to also replace companions if a companion disconnects (SHADoW)");	
			DrawPanelText(panel, "9) Fixed slot not being passed in UseAbility when slot>=1 (Wliu from WildCard65)");	
			DrawPanelText(panel, "10) Fixed status not being passed to FF2_OnAbility (Wliu)");
		}
		case 76: // 1.23
		{
			DrawPanelText(panel, "11) Allowed 'Special' key (+attack3) to be used as a 'buttonmode' for abilities (SHADoW)");
			DrawPanelText(panel, "12) Changed countdown timer text color from white to red (SHADoW)");	
		}
		case 75: // 1.22
		{
			DrawPanelText(panel, "1) Hopefully fixed living spectator bug (SHADoW)");			
			DrawPanelText(panel, "2) Boss disconnects? Surprise! Next person with most points takes over! (SHADoW)");	
			DrawPanelText(panel, "3) Fixed boss BGM's failing to stop correctly (SHADoW)");	
			DrawPanelText(panel, "4) Fixed sound_nextlife not playing (SHADoW)");	
			DrawPanelText(panel, "5) Fixed life loss notification not showing (SHADoW)");		
		}
		case 74: // 1.22
		{	
			DrawPanelText(panel, "6) Victim's name now shows when a boss goombas a player instead of 'you goomba stomped somebody' (SHADoW)");			
			DrawPanelText(panel, "7) Reduced blast radius on rocket launchers on Deathrun (SHADoW)");			
			DrawPanelText(panel, "8) Lowered jump height nerf to -50%, added self-damage of 100% on rocket launchers on Deathrun (SHADoW)");	
			DrawPanelText(panel, "9) Added Ullapool Caber 'airstabs' (only triggers if stickbomb hasn't been detonated yet - functions similar to market gardening)(SHADoW/VoiDeD)");	

		}
		case 73: // 1.21
		{
			DrawPanelText(panel, "1) Disabled spy cloaks on Deathrun (SHADoW)");	
			DrawPanelText(panel, "2) Allowed Amputator to be used on Deathrun, but strips their medigun (SHADoW)");			
			DrawPanelText(panel, "3) Bosses no longer get 200% damage bonus on Deathrun (SHADoW)");			
			DrawPanelText(panel, "4) Blast jump height once again nerfed to -70% on Deathrun(SHADoW)");			
			DrawPanelText(panel, "5) Disabled spellbooks on Deathrun (SHADoW)");			

		}
		case 72: // 1.21
		{
			DrawPanelText(panel, "6) !ff2_stop_music can now target specific clients (Wliu)");
			DrawPanelText(panel, "7) Fixed BGMs playing on maps that contain map music (SHADoW)");		
			DrawPanelText(panel, "8) Rebalanced market-gardener backstabs (Chdata from VSH 1.52)");		
			DrawPanelText(panel, "9) KGB retains GRU stats but no longer visually looks like GRU (Starblaster64)");		
			DrawPanelText(panel, "10) Players must now land on ground after market gardening the boss before attempting market gardening again (Chdata from VSH 1.52)");
		}
		case 71: // 1.21
		{
			DrawPanelText(panel, "11) Parachuting reduces market garden dmg by 33% and disables your parachute (Chdata from VSH 1.52)");		
			DrawPanelText(panel, "12) Maps without health/ammo now randomly spawn some in spawn (Chdata from VSH 1.52)");
			DrawPanelText(panel, "13) Boss is now teleported to a random spawn when touching a 'trigger_hurt' location (Chdata/sarysa)");		
			DrawPanelText(panel, "14) Fixed Dead ringer notifier not showing properly (SHADoW)");		
			DrawPanelText(panel, "15) Fixed life loss abilities triggering while round is inactive (SHADoW)");		
		}
		case 70:  //1.20
		{
			DrawPanelText(panel, "1) Updated the default health formula to match VSH's (Wliu)");
			DrawPanelText(panel, "2) Fixed charset voting again (Wliu from SHADoW)");
			DrawPanelText(panel, "3) Lowered required damage to increase killstreak count to 200 from 500 (SHADoW)");
			DrawPanelText(panel, "4) Fixed bravejump sounds not playing (Wliu from Maximilian_)");
			DrawPanelText(panel, "5) [Server] Fixed 'UTIL_SetModel not precached' crashes-see #6 for the underlying fix (SHADoW/Wliu)");
		}
		case 69:  //1.20
		{
			DrawPanelText(panel, "6) [Dev] FF2_GetBossIndex now makes sure the client index passed is valid (Wliu)");
			DrawPanelText(panel, "7) [Dev] Rewrote the health formula parser and fixed a few bugs along the way (WildCard65)");
			DrawPanelText(panel, "8) Improved next boss notification panel (SHADoW)");
		}
		case 68: // 1.19
		{
			DrawPanelText(panel, "1) Added next boss notification panel (SHADoW)");				
			DrawPanelText(panel, "2) Bosses can now anchor themselves by ducking for knockback protection (SHADoW)");	
			DrawPanelText(panel, "3) Player deaths on traps will be credited as boss kills on Deathrun (SHADoW)");	
			DrawPanelText(panel, "4) Every 500 damage now increases killstreak count (SHADoW)");	
			DrawPanelText(panel, "5) Integrated boss toggle & boss selection into FF2(SHADoW)");
		}
		case 67: // 1.19
		{
			DrawPanelText(panel, "6) Allowed B.A.S.E Jumper to be used on Deathrun (SHADoW)");				
			DrawPanelText(panel, "7) Lowered Deathrun push force nerf (SHADoW)");	
			DrawPanelText(panel, "8) B.A.S.E Jumper will make a client bleed as long as parachute is active on Deathrun (SHADoW)");	
			DrawPanelText(panel, "9) Rocket & Sticky Jumper will now function as a reskinned version of stock but with greater push force (SHADoW)");			
			DrawPanelText(panel, "10) Added Dead Ringer Notifier (Chdata from VSH)");			
		}
		case 66:  //1.18
		{	
			DrawPanelText(panel, "1) 'ff2_alive' now also shows boss player's name (Wliu)");				
			DrawPanelText(panel, "2) Fixed 'sound_fail' playing if a boss wins (SHADoW)");	
			DrawPanelText(panel, "3) Fixed Mantreads effect killing bosses on rare occasions (SHADoW)");
			DrawPanelText(panel, "4) Snipers can now climb walls with any melee weapon (Various from VSH)");	
		}	
		case 65:  //1.17
		{
			DrawPanelText(panel, "1) Fixed issues with slo-mo RAGES (Wliu)");	
			DrawPanelText(panel, "2) Moved most texts to in-game text panel (SHADoW)");				
		}		
		case 64:  //1.16
		{
			DrawPanelText(panel, "1) Fixed sounds overlapping each other (SHADoW)");	
			DrawPanelText(panel, "2) Fixed spectators becoming live players (SHADoW)");	
			DrawPanelText(panel, "3) Fixed client crashing when live spectators were slayed (SHADoW)");		
			DrawPanelText(panel, "4) Reverted team switching changes, which was the cause of these bugs (SHADoW)");	
			DrawPanelText(panel, "5) Fixed Sticky Launcher being given on Deathrun maps (SHADoW)");					
		}				
		case 63:  //1.15
		{
			DrawPanelText(panel, "1) Fixed Festive SMG not getting crigs (Wliu)");
			DrawPanelText(panel, "2) Updated FF2_{Get|Set}BossRageDamage (Wliu)");
			DrawPanelText(panel, "3) Fixed team switching not always respawning players properly (SHADoW)");
			DrawPanelText(panel, "4) Added 'bossteam' to allow specific bosses to use a specific team (SHADoW)");
			DrawPanelText(panel, "5) Whitelisted Blutsauger & Overdose to use Syringe Gun stats (SHADoW)");
		}
		case 62:  //1.14
		{
			DrawPanelText(panel, "1) Fixed Mantreads Stomp sometimes killing bosses if the damage is greater than their current HP (SHADoW)");
			DrawPanelText(panel, "2) Fixed team switching sometimes spawning a boss on RED team on blacklisted maps (SHADoW)");
			DrawPanelText(panel, "3) Improving team switching to cycle teams on non-blacklisted maps(SHADoW)");
		}
		case 61:  //1.13
		{
			DrawPanelText(panel, "1) Fixed players getting overheal after winning as a boss (Wliu/FlaminSarge)");
			DrawPanelText(panel, "2) Rebalanced the Baby Face's Blaster (SHADoW)");
			DrawPanelText(panel, "3) Fixed the Baby Face's Blaster being unusable when FF2 was disabled (Wliu from Curtgust)");
			DrawPanelText(panel, "4) Fixed the Darwin's Danger Shield getting replaced by the SMG (Wliu)");
			DrawPanelText(panel, "5) Added the Tide Turner and new festive weapons to the weapon whitelist (Wliu)");
		}
		case 60:  //1.13
		{
			DrawPanelText(panel, "6) Fixed Market Gardener backstabs (Wliu)");
			DrawPanelText(panel, "7) Improved class switching after you finish the round as a boss (Wliu)");
			DrawPanelText(panel, "8) Fixed the !ff2 command again (Wliu)");
			DrawPanelText(panel, "9) Fixed bosses not ducking when teleporting (CapnDev)");
			DrawPanelText(panel, "10) Prevented dead companion bosses from becoming clones (Wliu)");

		}
		case 59:  //1.13
		{
			DrawPanelText(panel, "11) [Server] Fixed 'ff2_alive' never being shown (Wliu from various from 1.10.4 commit)");
			DrawPanelText(panel, "12) [Server] Fixed invalid healthbar errors (Wliu from ClassicGuzzi from 1.10.4 commit)");
			DrawPanelText(panel, "13) [Server] Fixed OnTakeDamage errors from spell Monoculuses (Wliu from ClassicGuzzi)");
			DrawPanelText(panel, "14) [Server] Added 'ff2_arena_rounds' and deprecated 'ff2_first_round' (Wliu from Spyper)");
			DrawPanelText(panel, "15) [Server] Added 'ff2_base_jumper_stun' to disable the parachute on stun (Wliu from SHADoW)");

		}
		case 58:  //1.13
		{
			DrawPanelText(panel, "16) [Server] Prevented FF2 from loading if it gets loaded in the /plugins/freaks/ directory (Wliu)");
			DrawPanelText(panel, "17) [Dev] Fixed 'sound_fail' (Wliu from M76030 from 1.10.4 commit)");
			DrawPanelText(panel, "18) [Dev] Allowed companions to emit 'sound_nextlife' if they have it (Wliu from M76030");
			DrawPanelText(panel, "19) [Dev] Added 'sound_last_life' (Wliu from WildCard65 from 1.10.4 commit)");
			DrawPanelText(panel, "20) [Dev] Added FF2_OnAlivePlayersChanged and deprecated FF2_Get{Alive|Boss}Players (Wliu from SHADoW)");

		}
		case 57:  // 1.13
		{
			DrawPanelText(panel, "21) [Dev] Fixed AIOOB errors in FF2_GetBossUserId (Wliu)");
			DrawPanelText(panel, "22) [Dev] Improved FF2_OnSpecialSelected so that only part of a boss name is needed (Wliu )");
			DrawPanelText(panel, "23) [Dev] Added FF2_{Get|Set}BossRageDamage (Wliu from WildCard65)");
		}
		case 56: // 1.12
		{
			DrawPanelText(panel, "1) Improved compatibility with deathrun maps (SHADoW)");
			DrawPanelText(panel, "2) Deathrun maps will automatically load deathrun charset (SHADoW)");
			DrawPanelText(panel, "3) Countdown timer will not show on deathrun maps (SHADoW)");
			DrawPanelText(panel, "4) Client glow will not show on deathrun maps (SHADoW)");
			DrawPanelText(panel, "5) Restored ability to Mantreads stomp players as a boss (SHADoW)");
		}
		case 55: // 1.11
		{
			DrawPanelText(panel, "1) Overhauled queue points system: 10 pts + Pts scored. Minimum damage required is 1 for base points (SHADoW)");
			DrawPanelText(panel, "2) Basic HP formula increased from ((460+n)*n)^1.075 to ((760.8+n)*n)^1.04 for stock bosses (SHADoW)");
			DrawPanelText(panel, "3) Minions will now duck if a summoning boss is ducking when spawning minions (SHADoW)");
			DrawPanelText(panel, "4) Whitelisted the Scorch Shot to receive mega detonator stats (SHADoW)");
			DrawPanelText(panel, "5) Engineer Teleporters are now bi-directional (SHADoW)");
		}
		case 54: // 1.11
		{
			DrawPanelText(panel, "6) Bosses can now blast jump with their projectile weapons (SHADoW)");
			DrawPanelText(panel, "7) RAGE can now be activated by taunting or calling medic (SHADoW)");
			DrawPanelText(panel, "8) Companions should no longer lose their queue points (SHADoW)");
			DrawPanelText(panel, "9) Updated HHH & Headless Horseman's theme (SHADoW)");
		}
		case 53:  //1.10.3
		{
			DrawPanelText(panel, "1) Fixed bosses appearing to be overhealed (War3Evo/Wliu)");
			DrawPanelText(panel, "2) Rebalanced many weapons based on misc. feedback (Wliu/various)");
			DrawPanelText(panel, "3) Fixed not being able to use strange syringe guns or mediguns (Chris from Spyper)");
			DrawPanelText(panel, "4) Fixed the Bread Bite being replaced by the GRU (Wliu from Spyper)");
			DrawPanelText(panel, "5) Fixed Mantreads not giving extra rocket jump height (Chdata");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 52:  //1.10.3
		{
			DrawPanelText(panel, "6) Prevented bosses from picking up ammo/health by default (friagram)");
			DrawPanelText(panel, "7) Fixed a bug with respawning bosses (Wliu from Spyper)");
			DrawPanelText(panel, "8) Fixed an issue with displaying boss health in chat (Wliu)");
			DrawPanelText(panel, "9) Fixed an edge case where player crits would not be applied (Wliu from Spyper)");
			DrawPanelText(panel, "10) Fixed not being able to suicide as boss after round end (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 51:  //1.10.3
		{
			DrawPanelText(panel, "11) Updated Russian translations (wasder) and added German translations (CooliMC)");
			DrawPanelText(panel, "12) Fixed Dead Ringer deaths being too obvious (Wliu from AliceTaylor12)");
			DrawPanelText(panel, "13) Fixed many bosses not voicing their catch phrases (Wliu)");
			DrawPanelText(panel, "14) Updated Gentlespy, Easter Bunny, Demopan, and CBS (Wliu, configs need to be updated)");
			DrawPanelText(panel, "15) [Server] Added new cvar 'ff2_countdown_result' (Wliu from Shadow)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 50:  //1.10.3
		{
			DrawPanelText(panel, "16) [Server] Added new cvar 'ff2_caber_detonations' (Wliu)");
			DrawPanelText(panel, "17) [Server] Fixed a bug related to 'cvar_countdown_players' and the countdown timer (Wliu from Spyper)");
			DrawPanelText(panel, "18) [Server] Fixed 'Next Map Character Set' VFormat errors (Wliu from BBG_Theory)");
			DrawPanelText(panel, "19) [Server] Fixed errors when Monoculus was attacking (Wliu from ClassicGuzzi)");
			DrawPanelText(panel, "20) [Dev] Added 'sound_first_blood' (Wliu from Mr-Bro)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 49:  //1.10.3
		{
			DrawPanelText(panel, "21) [Dev] Added 'pickups' to set what the boss can pick up (Wliu)");
			DrawPanelText(panel, "22) [Dev] Added FF2FLAG_ALLOW_{HEALTH|AMMO}_PICKUPS (Powerlord)");
			DrawPanelText(panel, "23) [Dev] Added FF2_GetFF2Version (Wliu)");
			DrawPanelText(panel, "24) [Dev] Added FF2_ShowSync{Hud}Text wrappers (Wliu)");
			DrawPanelText(panel, "25) [Dev] Added FF2_SetAmmo and fixed setting clip (Wliu/friagram for fixing clip)");
			DrawPanelText(panel, "26) [Dev] Fixed weapons not being hidden when asked to (friagram)");
			DrawPanelText(panel, "27) [Dev] Fixed not being able to set constant health values for bosses (Wliu from braak0405)");
		}
		case 48:  //1.10.2
		{
			DrawPanelText(panel, "1) Fixed a critical bug that rendered most bosses as errors without sound (Wliu; thanks to slavko17 for reporting)");
			DrawPanelText(panel, "2) Reverted escape sequences change, which is what caused this bug");
		}
		case 47:  //1.10.1
		{
			DrawPanelText(panel, "1) Fixed a rare bug where rage could go over 100% (Wliu)");
			DrawPanelText(panel, "2) Updated to use Sourcemod 1.6.1 (Powerlord)");
			DrawPanelText(panel, "3) Fixed goomba stomp ignoring demoshields (Wliu)");
			DrawPanelText(panel, "4) Disabled boss from spectating (Wliu)");
			DrawPanelText(panel, "5) Fixed some possible overlapping HUD text (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 46:  //1.10.1
		{
			DrawPanelText(panel, "6) Fixed ff2_charset displaying incorrect colors (Wliu)");
			DrawPanelText(panel, "7) Boss info text now also displays in the chat area (Wliu)");
			DrawPanelText(panel, "--Partially synced with VSH 1.49 (all VSH changes listed courtesy of Chdata)--");
			DrawPanelText(panel, "8) VSH: Do not show HUD text if the scoreboard is open");
			DrawPanelText(panel, "9) VSH: Added market gardener 'backstab'");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 45:  //1.10.1
		{
			DrawPanelText(panel, "10) VSH: Removed Darwin's Danger Shield from the blacklist (Chdata) and gave it a +50 health bonus (Wliu)");
			DrawPanelText(panel, "11) VSH: Rebalanced Phlogistinator");
			DrawPanelText(panel, "12) VSH: Improved backstab code");
			DrawPanelText(panel, "13) VSH: Added ff2_shield_crits cvar to control whether or not demomen get crits when using shields");
			DrawPanelText(panel, "14) VSH: Reserve Shooter now deals crits to bosses in mid-air");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 44:  //1.10.1
		{
			DrawPanelText(panel, "15) [Server] Fixed conditions still being added when FF2 was disabled (Wliu)");
			DrawPanelText(panel, "16) [Server] Fixed a rare healthbar error (Wliu)");
			DrawPanelText(panel, "17) [Server] Added convar ff2_boss_suicide to control whether or not the boss can suicide after the round starts (Wliu)");
			DrawPanelText(panel, "18) [Server] Changed ff2_boss_teleporter's default value to 0 (Wliu)");
			DrawPanelText(panel, "19) [Server] Updated translations (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 43:  //1.10.1
		{
			DrawPanelText(panel, "20) [Dev] Added FF2_GetAlivePlayers and FF2_GetBossPlayers (Wliu/AliceTaylor)");
			DrawPanelText(panel, "21) [Dev] Fixed a bug in the main include file (Wliu)");
			DrawPanelText(panel, "22) [Dev] Enabled escape sequences in configs (Wliu)");
		}
		case 42:  //1.10.0
		{
			DrawPanelText(panel, "1) Rage is now activated by calling for medic (Wliu)");
			DrawPanelText(panel, "2) Balanced Goomba Stomp and RTD (WildCard65)");
			DrawPanelText(panel, "3) Fixed BGM not stopping if the boss suicides at the beginning of the round (Wliu)");
			DrawPanelText(panel, "4) Fixed Jarate, etc. not disappearing immediately on the boss (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 41:  //1.10.0
		{
			DrawPanelText(panel, "5) Fixed ability timers not resetting when the round was over (Wliu)");
			DrawPanelText(panel, "6) Fixed bosses losing momentum when raging in the air (Wliu)");
			DrawPanelText(panel, "7) Fixed bosses losing health if their companion left at round start (Wliu)");
			DrawPanelText(panel, "8) Fixed bosses sometimes teleporting to each other if they had a companion (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 40:  //1.10.0
		{
			DrawPanelText(panel, "9) Optimized the health calculation system (WildCard65)");
			DrawPanelText(panel, "10) Slightly tweaked default boss health formula to be more balanced (Eggman)");
			DrawPanelText(panel, "11) Fixed and optimized the leaderboard (Wliu)");
			DrawPanelText(panel, "12) Fixed medic minions receiving the medigun (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 39:  //1.10.0
		{
			DrawPanelText(panel, "13) Fixed Ninja Spy slow-mo bugs (Wliu/Powerlord)");
			DrawPanelText(panel, "14) Prevented players from changing to the incorrect team or class (Powerlord/Wliu)");
			DrawPanelText(panel, "15) Fixed bosses immediately dying after using the dead ringer (Wliu)");
			DrawPanelText(panel, "16) Fixed a rare bug where you could get notified about being the next boss multiple times (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 38:  //1.10.0
		{
			DrawPanelText(panel, "17) Fixed gravity not resetting correctly after a weighdown if using non-standard gravity (Wliu)");
			DrawPanelText(panel, "18) [Server] FF2 now properly disables itself when required (Wliu/Powerlord)");
			DrawPanelText(panel, "19) [Server] Added ammo, clip, and health arguments to rage_cloneattack (Wliu)");
			DrawPanelText(panel, "20) [Server] Changed how BossCrits works...again (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 37:  //1.10.0
		{
			DrawPanelText(panel, "21) [Server] Removed convar ff2_halloween (Wliu)");
			DrawPanelText(panel, "22) [Server] Moved convar ff2_oldjump to the main config file (Wliu)");
			DrawPanelText(panel, "23) [Server] Added convar ff2_countdown_players to control when the timer should appear (Wliu/BBG_Theory)");
			DrawPanelText(panel, "24) [Server] Added convar ff2_updater to control whether automatic updating should be turned on (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 36:  //1.10.0
		{
			DrawPanelText(panel, "25) [Server] Added convar ff2_goomba_jump to control how high players should rebound after goomba stomping the boss (WildCard65)");
			DrawPanelText(panel, "26) [Server] Fixed hale_point_enable/disable being registered twice (Wliu)");
			DrawPanelText(panel, "27) [Server] Fixed some convars not executing (Wliu)");
			DrawPanelText(panel, "28) [Server] Fixed the chances and charset systems (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 35:  //1.10.0
		{
			DrawPanelText(panel, "29) [Dev] Added more natives and one additional forward (Eggman)");
			DrawPanelText(panel, "30) [Dev] Added sound_full_rage which plays once the boss is able to rage (Wliu/Eggman)");
			DrawPanelText(panel, "31) [Dev] Fixed FF2FLAG_ISBUFFED (Wliu)");
			DrawPanelText(panel, "32) [Dev] FF2 now checks for sane values for \"lives\" and \"health_formula\" (Wliu)");
			DrawPanelText(panel, "Big thanks to GIANT_CRAB, WildCard65, and kniL for their devotion to this release!");
		}
		case 34:  //1.9.3
		{
			DrawPanelText(panel, "1) Fixed a bug in 1.9.2 where the changelog was off by one version (Wliu)");
			DrawPanelText(panel, "2) Fixed a bug in 1.9.2 where one dead player would not be cloned in rage_cloneattack (Wliu)");
			DrawPanelText(panel, "3) Fixed a bug in 1.9.2 where sentries would be permanently disabled after a rage (Wliu)");
			DrawPanelText(panel, "4) [Server] Removed ff2_halloween (Wliu)");
		}
		case 33:  //1.9.2
		{
			DrawPanelText(panel, "1) Fixed a bug in 1.9.1 that allowed the same player to be the boss over and over again (Wliu)");
			DrawPanelText(panel, "2) Fixed a bug where last player glow was being incorrectly removed on the boss (Wliu)");
			DrawPanelText(panel, "3) Fixed a bug where the boss would be assumed dead (Wliu)");
			DrawPanelText(panel, "4) Fixed having minions on the boss team interfering with certain rage calculations (Wliu)");
			DrawPanelText(panel, "See next page for more (press 1)");
		}
		case 32:  //1.9.2
		{
			DrawPanelText(panel, "5) Fixed a rare bug where the rage percentage could go above 100% (Wliu)");
			DrawPanelText(panel, "6) [Server] Fixed possible special_noanims errors (Wliu)");
			DrawPanelText(panel, "7) [Server] Added new arguments to rage_cloneattack-no updates necessary (friagram/Wliu)");
			DrawPanelText(panel, "8) [Server] Certain cvars that SMAC detects are now automatically disabled while FF2 is running (Wliu)");
			DrawPanelText(panel, "            Servers can now safely have smac_cvars enabled");
		}
		case 31:  //1.9.1
		{
			DrawPanelText(panel, "1) Fixed some minor leaderboard bugs and also improved the leaderboard text (Wliu)");
			DrawPanelText(panel, "2) Fixed a minor round end bug (Wliu)");
			DrawPanelText(panel, "3) [Server] Fixed improper unloading of subplugins (WildCard65)");
			DrawPanelText(panel, "4) [Server] Removed leftover console messages (Wliu)");
			DrawPanelText(panel, "5) [Server] Fixed sound not precached warnings (Wliu)");
		}
		case 30:  //1.9.0
		{
			DrawPanelText(panel, "1) Removed checkFirstHale (Wliu)");
			DrawPanelText(panel, "2) [Server] Fixed invalid healthbar entity bug (Wliu)");
			DrawPanelText(panel, "3) Changed default medic ubercharge percentage to 40% (Wliu)");
			DrawPanelText(panel, "4) Whitelisted festive variants of weapons (Wliu/BBG_Theory)");
			DrawPanelText(panel, "5) [Server] Added convars to control last player glow and timer health cutoff (Wliu");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 29:  //1.9.0
		{
			DrawPanelText(panel, "6) [Dev] Added new natives/stocks: Debug, FF2_SetClientGlow and FF2_GetClientGlow (Wliu)");
			DrawPanelText(panel, "7) Fixed a few minor !whatsnew bugs (BBG_Theory)");
			DrawPanelText(panel, "8) Fixed Easter Abilities (Wliu)");
			DrawPanelText(panel, "9) Minor grammar/spelling improvements (Wliu)");
			DrawPanelText(panel, "10) [Server] Minor subplugin load/unload fixes (Wliu)");
		}
		case 28:  //1.0.8
		{
			DrawPanelText(panel, "Wliu, Chris, Lawd, and Carge of 50DKP have taken over FF2 development");
			DrawPanelText(panel, "1) Prevented spy bosses from changing disguises (Powerlord)");
			DrawPanelText(panel, "2) Added Saxton Hale stab sounds (Powerlord/AeroAcrobat)");
			DrawPanelText(panel, "3) Made sure that the boss doesn't have any invalid weapons/items (Powerlord)");
			DrawPanelText(panel, "4) Tried fixing the visible weapon bug (Powerlord)");
			DrawPanelText(panel, "5) Whitelisted some more action slot items (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 27:  //1.0.8
		{
			DrawPanelText(panel, "6) Festive Huntsman has the same attributes as the Huntsman now (Powerlord)");
			DrawPanelText(panel, "7) Medigun now overheals 50% more (Powerlord)");
			DrawPanelText(panel, "8) Made medigun transparent if the medic's melee was the Gunslinger (Powerlord)");
			DrawPanelText(panel, "9) Slight tweaks to the view hp commands (Powerlord)");
			DrawPanelText(panel, "10) Whitelisted the Silver/Gold Botkiller Sniper Rifle Mk.II (Powerlord)");
			DrawPanelText(panel, "11) Slight tweaks to boss health calculation (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 26:  //1.0.8
		{
			DrawPanelText(panel, "12) Made sure that spies couldn't quick-backstab the boss (Powerlord)");
			DrawPanelText(panel, "13) Made sure the stab animations were correct (Powerlord)");
			DrawPanelText(panel, "14) Made sure that healthpacks spawned from the Candy Cane are not respawned once someone uses them (Powerlord)");
			DrawPanelText(panel, "15) Healthpacks from the Candy Cane are no longer despawned (Powerlord)");
			DrawPanelText(panel, "16) Slight tweaks to removing laughs (Powerlord)");
			DrawPanelText(panel, "17) [Dev] Added a clip argument to special_noanims.sp (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 25:  //1.0.8
		{
			DrawPanelText(panel, "18) [Dev] sound_bgm is now precached automagically (Powerlord)");
			DrawPanelText(panel, "19) Seeldier's minions can no longer cap (Wliu)");
			DrawPanelText(panel, "20) Fixed sometimes getting stuck when teleporting to a ducking player (Powerlord)");
			DrawPanelText(panel, "21) Multiple English translation improvements (Wliu/Powerlord)");
			DrawPanelText(panel, "22) Fixed Ninja Spy and other bosses that use the matrix ability getting stuck in walls/ceilings (Chris)");
			DrawPanelText(panel, "23) [Dev] Updated item attributes code per the TF2Items update (Powerlord)");
			DrawPanelText(panel, "See next page (press 1)");
		}
		case 24:  //1.0.8
		{
			DrawPanelText(panel, "24) Fixed duplicate sound downloads for Saxton Hale (Wliu)");
			DrawPanelText(panel, "25) [Server] FF2 now require morecolors, not colors (Powerlord)");
			DrawPanelText(panel, "26) [Server] Added a Halloween mode which will enable characters_halloween.cfg (Wliu)");
			DrawPanelText(panel, "27) Hopefully fixed multiple round-related issues (Wliu)");
			DrawPanelText(panel, "28) [Dev] Started to clean up/format the code (Wliu)");
			DrawPanelText(panel, "29) Changed versioning format to x.y.z and month day, year (Wliu)");
			DrawPanelText(panel, "HAPPY HALLOWEEN!");
		}
		case 23:  //1.07
		{
			DrawPanelText(panel, "1) [Players] Holiday Punch is now replaced by Fists");
			DrawPanelText(panel, "2) [Players] Bosses will have any disguises removed on round start");
			DrawPanelText(panel, "3) [Players] Bosses can no longer see all players health, as it wasn't working any more");
			DrawPanelText(panel, "4) [Server] ff2_addpoints no longer targets SourceTV or replay");
		}
		case 22:  //1.07 beta 6
		{
			DrawPanelText(panel, "1) [Dev] Fixed issue with sound hook not stopping sound when sound_block_vo was in use");
			DrawPanelText(panel, "2) [Dev] If ff2_charset was used, don't run the character set vote");
			DrawPanelText(panel, "3) [Dev] If a vote is already running, Character set vote will retry every 5 seconds or until map changes ");
		}
		case 21:  //1.07 beta 5
		{
			DrawPanelText(panel, "1) [Dev] Fixed issue with character sets not working.");
			DrawPanelText(panel, "2) [Dev] Improved IsValidClient replay check");
			DrawPanelText(panel, "3) [Dev] IsValidClient is now called when loading companion bosses");
			DrawPanelText(panel, "   This should prevent GetEntProp issues with m_iClass");
		}
		case 20:  //1.07 beta 4
		{
			DrawPanelText(panel, "1) [Players] Dead Ringers have no cloak defense buff. Normal cloaks do.");
			DrawPanelText(panel, "2) [Players] Fixed Sniper Rifle reskin behavior");
			DrawPanelText(panel, "3) [Players] Boss has small amount of stun resistance after rage");
			DrawPanelText(panel, "4) [Players] Various bugfixes and changes 1.7.0 beta 1");
		}
		case 19:  //1.07 beta
		{
			DrawPanelText(panel, "22) [Dev] Prevent boss rage from being activated if the boss is already taunting or is dead.");
			DrawPanelText(panel, "23) [Dev] Cache the result of the newer backstab detection");
			DrawPanelText(panel, "24) [Dev] Reworked Medic damage code slightly");
		}
		case 18:  //1.07 beta
		{
			DrawPanelText(panel, "16) [Server] The Boss queue now accepts negative points.");
			DrawPanelText(panel, "17) [Server] Bosses can be forced to a specific team using the new ff2_force_team cvar.");
			DrawPanelText(panel, "18) [Server] Eureka Effect can now be enabled using the new ff2_enable_eureka cvar");
			DrawPanelText(panel, "19) [Server] Bosses models and sounds are now precached the first time they are loaded.");
			DrawPanelText(panel, "20) [Dev] Fixed an issue where FF2 was trying to read cvars before config files were executed.");
			DrawPanelText(panel, "    This change should also make the game a little more multi-mod friendly.");
			DrawPanelText(panel, "21) [Dev] Fixed OnLoadCharacterSet not being fired. This should fix the deadrun plugin.");
			DrawPanelText(panel, "Continued on next page");
		}
		case 17:  //1.07 beta
		{
			DrawPanelText(panel, "10) [Players] Heatmaker gains Focus on hit (varies by charge)");
			DrawPanelText(panel, "11) [Players] Crusader's Crossbow damage has been adjusted to compensate for its speed increase.");
			DrawPanelText(panel, "12) [Players] Cozy Camper now gives you an SMG as well, but it has no crits and reduced damage.");
			DrawPanelText(panel, "13) [Players] Bosses get short defense buff after rage");
			DrawPanelText(panel, "14) [Server] Now attempts to integrate tf2items config");
			DrawPanelText(panel, "15) [Server] Changing the game description now requires Steam Tools");
			DrawPanelText(panel, "Continued on next page");
		}
		case 16:  //1.07 beta
		{
			DrawPanelText(panel, "6) [Players] Removed crits from sniper rifles, now do 2.9x damage");
			DrawPanelText(panel, "   Sydney Sleeper does 2.4x damage, 2.9x if boss's rage is >90pct");
			DrawPanelText(panel, "   Minicrit- less damage, more knockback");
			DrawPanelText(panel, "7) [Players] Baby Face's Blaster will fill boost normally, but will hit 100 and drain+minicrits.");
			DrawPanelText(panel, "8) [Players] Phlogistinator Pyros are invincible while activating the crit-boost taunt.");
			DrawPanelText(panel, "9) [Players] Can't Eureka+destroy dispenser to insta-teleport");
			DrawPanelText(panel, "Continued on next page");
		}
		case 15:  //1.07 beta
		{
			DrawPanelText(panel, "1) [Players] Reworked the crit code a bit. Should be more reliable.");
			DrawPanelText(panel, "2) [Players] Help panel should stop repeatedly popping up on round start.");
			DrawPanelText(panel, "3) [Players] Backstab disguising should be smoother/less obvious");
			DrawPanelText(panel, "4) [Players] Scaled sniper rifle glow time a bit better");
			DrawPanelText(panel, "5) [Players] Fixed Dead Ringer spy death icon");
			DrawPanelText(panel, "Continued on next page");
		}
		case 14:  //1.06h
		{
			DrawPanelText(panel, "1) [Players] Remove MvM powerup_bottle on Bosses. (RavensBro)");
		}
		case 13:  //1.06g
		{
			DrawPanelText(panel, "1) [Players] Fixed vote for charset. (RavensBro)");
		}
		case 12:  //1.06f
		{
			DrawPanelText(panel, "1) [Players] Changelog now divided into [Players] and [Dev] sections. (Otokiru)");
			DrawPanelText(panel, "2) [Players] Don't bother reading [Dev] changelogs because you'll have no idea what it's stated. (Otokiru)");
			DrawPanelText(panel, "3) [Players] Fixed civilian glitch. (Otokiru)");
			DrawPanelText(panel, "4) [Players] Fixed hale HP bar. (Valve) lol?");
			DrawPanelText(panel, "5) [Dev] Fixed \"GetEntProp\" reported: Entity XXX (XXX) is invalid on checkFirstHale(). (Otokiru)");
		}
		case 11:  //1.06e
		{

			DrawPanelText(panel, "1) [Players] Remove MvM water-bottle on hales. (Otokiru)");
			DrawPanelText(panel, "2) [Dev] Fixed \"GetEntProp\" reported: Property \"m_iClass\" not found (entity 0/worldspawn) error on checkFirstHale(). (Otokiru)");
			DrawPanelText(panel, "3) [Dev] Change how FF2 check for player weapons. Now also checks when spawned in the middle of the round. (Otokiru)");
			DrawPanelText(panel, "4) [Dev] Changed some FF2 warning messages color such as \"First-Hale Checker\" and \"Change class exploit\". (Otokiru)");
		}
		case 10:  //1.06d
		{
			DrawPanelText(panel, "1) Fix first boss having missing health or abilities. (Otokiru)");
			DrawPanelText(panel, "2) Health bar now goes away if the boss wins the round. (Powerlord)");
			DrawPanelText(panel, "3) Health bar cedes control to Monoculus if he is summoned. (Powerlord)");
			DrawPanelText(panel, "4) Health bar instantly updates if enabled or disabled via cvar mid-game. (Powerlord)");
		}
		case 9:  //1.06c
		{
			DrawPanelText(panel, "1) Remove weapons if a player tries to switch classes when they become boss to prevent an exploit. (Otokiru)");
			DrawPanelText(panel, "2) Reset hale's queue points to prevent the 'retry' exploit. (Otokiru)");
			DrawPanelText(panel, "3) Better detection of backstabs. (Powerlord)");
			DrawPanelText(panel, "4) Boss now has optional life meter on screen. (Powerlord)");
		}
		case 8:  //1.06
		{
			DrawPanelText(panel, "1) Fixed attributes key for weaponN block. Now 1 space needed for explode string.");
			DrawPanelText(panel, "2) Disabled vote for charset when there is only 1 not hidden chatset.");
			DrawPanelText(panel, "3) Fixed \"Invalid key value handle 0 (error 4)\" when when round starts.");
			DrawPanelText(panel, "4) Fixed ammo for special_noanims.ff2\\rage_new_weapon ability.");
			DrawPanelText(panel, "Coming soon: weapon balance will be moved into config file.");
		}
		case 7:  //1.05
		{
			DrawPanelText(panel, "1) Added \"hidden\" key for charsets.");
			DrawPanelText(panel, "2) Added \"sound_stabbed\" key for characters.");
			DrawPanelText(panel, "3) Mantread stomp deals 5x damage to Boss.");
			DrawPanelText(panel, "4) Minicrits will not play loud sound to all players");
			DrawPanelText(panel, "5-11) See next page...");
		}
		case 6:  //1.05
		{
			DrawPanelText(panel, "6) For mappers: Add info_target with name 'hale_no_music'");
			DrawPanelText(panel, "    to prevent Boss' music.");
			DrawPanelText(panel, "7) FF2 renames *.smx from plugins/freaks/ to *.ff2 by itself.");
			DrawPanelText(panel, "8) Third Degree hit adds uber to healers.");
			DrawPanelText(panel, "9) Fixed hard \"ghost_appearation\" in default_abilities.ff2.");
			DrawPanelText(panel, "10) FF2FLAG_HUDDISABLED flag blocks EVERYTHING of FF2's HUD.");
			DrawPanelText(panel, "11) Changed FF2_PreAbility native to fix bug about broken Boss' abilities.");
		}
		case 5:  //1.04
		{
			DrawPanelText(panel, "1) Seeldier's minions have protection (teleport) from pits for first 4 seconds after spawn.");
			DrawPanelText(panel, "2) Seeldier's minions correctly dies when owner-Seeldier dies.");
			DrawPanelText(panel, "3) Added multiplier for brave jump ability in char.configs (arg3, default is 1.0).");
			DrawPanelText(panel, "4) Added config key sound_fail. It calls when Boss fails, but still alive");
			DrawPanelText(panel, "4) Fixed potential exploits associated with feign death.");
			DrawPanelText(panel, "6) Added ff2_reload_subplugins command to reload FF2's subplugins.");
		}
		case 4:  //1.03
		{
			DrawPanelText(panel, "1) Finally fixed exploit about queue points.");
			DrawPanelText(panel, "2) Fixed non-regular bug with 'UTIL_SetModel: not precached'.");
			DrawPanelText(panel, "3) Fixed potential bug about reducing of Boss' health by healing.");
			DrawPanelText(panel, "4) Fixed Boss' stun when round begins.");
		}
		case 3:  //1.02
		{
			DrawPanelText(panel, "1) Added isNumOfSpecial parameter into FF2_GetSpecialKV and FF2_GetBossSpecial natives");
			DrawPanelText(panel, "2) Added FF2_PreAbility forward. Plz use it to prevent FF2_OnAbility only.");
			DrawPanelText(panel, "3) Added FF2_DoAbility native.");
			DrawPanelText(panel, "4) Fixed exploit about queue points...ow wait, it done in 1.01");
			DrawPanelText(panel, "5) ff2_1st_set_abilities.ff2 sets kac_enabled to 0.");
			DrawPanelText(panel, "6) FF2FLAG_HUDDISABLED flag disables Boss' HUD too.");
			DrawPanelText(panel, "7) Added FF2_GetQueuePoints and FF2_SetQueuePoints natives.");
		}
		case 2:  //1.01
		{
			DrawPanelText(panel, "1) Fixed \"classmix\" bug associated with Boss' class restoring.");
			DrawPanelText(panel, "3) Fixed other little bugs.");
			DrawPanelText(panel, "4) Fixed bug about instant kill of Seeldier's minions.");
			DrawPanelText(panel, "5) Now you can use name of Boss' file for \"companion\" Boss' keyvalue.");
			DrawPanelText(panel, "6) Fixed exploit when dead Boss can been respawned after his reconnect.");
			DrawPanelText(panel, "7-10) See next page...");
		}
		case 1:  //1.01
		{
			DrawPanelText(panel, "7) I've missed 2nd item.");
			DrawPanelText(panel, "8) Fixed \"Random\" charpack, there is no vote if only one charpack.");
			DrawPanelText(panel, "9) Fixed bug when boss' music have a chance to DON'T play.");
			DrawPanelText(panel, "10) Fixed bug associated with ff2_enabled in cfg/sourcemod/FreakFortress2.cfg and disabling of pugin.");
		}
		case 0:  //1.0
		{
			DrawPanelText(panel, "1) Boss's health divided by 3,6 in medieval mode");
			DrawPanelText(panel, "2) Restoring player's default class, after his round as Boss");
			DrawPanelText(panel, "===UPDATES OF VS SAXTON HALE MODE===");
			DrawPanelText(panel, "1) Added !ff2_resetqueuepoints command (also there is admin version)");
			DrawPanelText(panel, "2) Medic is credited 100% of damage done during ubercharge");
			DrawPanelText(panel, "3) If map changes mid-round, queue points not lost");
			DrawPanelText(panel, "4) Dead Ringer will not be able to activate for 2s after backstab");
			DrawPanelText(panel, "5) Added ff2_spec_force_boss cvar");
		}
		default:
		{
			DrawPanelText(panel, "-- Somehow you've managed to find a glitched version page!");
			DrawPanelText(panel, "-- Congratulations.  Now go and fight!");
		}
	}
}

static const maxVersion=sizeof(ff2versiontitles)-1;

new Specials;
new Handle:BossKV[MAXSPECIALS];
new Handle:PreAbility;
new Handle:OnAbility;
new Handle:OnMusic;
new Handle:OnTriggerHurt;
new Handle:OnSpecialSelected;
new Handle:OnAddQueuePoints;
new Handle:OnLoadCharacterSet;
new Handle:OnLoseLife;
new Handle:OnAlivePlayersChanged;

new bool:bBlockVoice[MAXSPECIALS];
new Float:BossSpeed[MAXSPECIALS];

new String:ChancesString[512];
new chances[MAXSPECIALS];
new chancesIndex;

public Plugin:myinfo=
{
	name="Freak Fortress 2",
	author="Rainbolt Dash, FlaminSarge, Powerlord, the 50DKP team, SHADoW93",
	description="RUUUUNN!! COWAAAARRDSS!",
	version=PLUGIN_VERSION,
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	decl String:plugin[PLATFORM_MAX_PATH];
	GetPluginFilename(myself, plugin, sizeof(plugin));
	if(!StrContains(plugin, "freaks/"))  //Prevent plugins/freaks/freak_fortress_2.ff2 from loading if it exists -.-
	{
		strcopy(error, err_max, "Quick, kill the frogs before they multiply!");
		return APLRes_Failure;
	}

	CreateNative("FF2_IsFF2Enabled", Native_IsEnabled);
	CreateNative("FF2_GetFF2Version", Native_FF2Version);
	CreateNative("FF2_GetBossUserId", Native_GetBoss);
	CreateNative("FF2_GetBossIndex", Native_GetIndex);
	CreateNative("FF2_GetBossTeam", Native_GetTeam);
	CreateNative("FF2_GetBossSpecial", Native_GetSpecial);
	CreateNative("FF2_GetBossHealth", Native_GetBossHealth);
	CreateNative("FF2_SetBossHealth", Native_SetBossHealth);
	CreateNative("FF2_GetBossMaxHealth", Native_GetBossMaxHealth);
	CreateNative("FF2_SetBossMaxHealth", Native_SetBossMaxHealth);
	CreateNative("FF2_GetBossLives", Native_GetBossLives);
	CreateNative("FF2_SetBossLives", Native_SetBossLives);
	CreateNative("FF2_GetBossMaxLives", Native_GetBossMaxLives);
	CreateNative("FF2_SetBossMaxLives", Native_SetBossMaxLives);
	CreateNative("FF2_GetBossCharge", Native_GetBossCharge);
	CreateNative("FF2_SetBossCharge", Native_SetBossCharge);
	CreateNative("FF2_GetBossRageDamage", Native_GetBossRageDamage);
	CreateNative("FF2_SetBossRageDamage", Native_SetBossRageDamage);
	CreateNative("FF2_GetClientDamage", Native_GetDamage);
	CreateNative("FF2_GetRoundState", Native_GetRoundState);
	CreateNative("FF2_GetSpecialKV", Native_GetSpecialKV);
	CreateNative("FF2_StartMusic", Native_StartMusic);
	CreateNative("FF2_StopMusic", Native_StopMusic);
	CreateNative("FF2_GetRageDist", Native_GetRageDist);
	CreateNative("FF2_HasAbility", Native_HasAbility);
	CreateNative("FF2_DoAbility", Native_DoAbility);
	CreateNative("FF2_GetAbilityArgument", Native_GetAbilityArgument);
	CreateNative("FF2_GetAbilityArgumentFloat", Native_GetAbilityArgumentFloat);
	CreateNative("FF2_GetAbilityArgumentString", Native_GetAbilityArgumentString);
	CreateNative("FF2_RandomSound", Native_RandomSound);
	CreateNative("FF2_GetFF2flags", Native_GetFF2flags);
	CreateNative("FF2_SetFF2flags", Native_SetFF2flags);
	CreateNative("FF2_GetQueuePoints", Native_GetQueuePoints);
	CreateNative("FF2_SetQueuePoints", Native_SetQueuePoints);
	CreateNative("FF2_GetClientGlow", Native_GetClientGlow);
	CreateNative("FF2_SetClientGlow", Native_SetClientGlow);
	CreateNative("FF2_GetAlivePlayers", Native_GetAlivePlayers);  //TODO: Deprecated, remove in 2.0.0
	CreateNative("FF2_GetBossPlayers", Native_GetBossPlayers);  //TODO: Deprecated, remove in 2.0.0
	CreateNative("FF2_Debug", Native_Debug);

	PreAbility=CreateGlobalForward("FF2_PreAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_CellByRef);  //Boss, plugin name, ability name, slot, enabled
	OnAbility=CreateGlobalForward("FF2_OnAbility", ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell);  //Boss, plugin name, ability name, status
	OnMusic=CreateGlobalForward("FF2_OnMusic", ET_Hook, Param_String, Param_FloatByRef);
	OnTriggerHurt=CreateGlobalForward("FF2_OnTriggerHurt", ET_Hook, Param_Cell, Param_Cell, Param_FloatByRef);
	OnSpecialSelected=CreateGlobalForward("FF2_OnSpecialSelected", ET_Hook, Param_Cell, Param_CellByRef, Param_String);  //Boss, character index, character name
	OnAddQueuePoints=CreateGlobalForward("FF2_OnAddQueuePoints", ET_Hook, Param_Array);
	OnLoadCharacterSet=CreateGlobalForward("FF2_OnLoadCharacterSet", ET_Hook, Param_CellByRef, Param_String);
	OnLoseLife=CreateGlobalForward("FF2_OnLoseLife", ET_Hook, Param_Cell, Param_CellByRef, Param_Cell);  //Boss, lives left, max lives
	OnAlivePlayersChanged=CreateGlobalForward("FF2_OnAlivePlayersChanged", ET_Hook, Param_Cell, Param_Cell);  //Players, bosses

	RegPluginLibrary("freak_fortress_2");

	AskPluginLoad_VSH();
	#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
	#endif

	#if defined _tf2attributes_included
	MarkNativeAsOptional("TF2Attrib_SetByDefIndex");
	MarkNativeAsOptional("TF2Attrib_RemoveByDefIndex");
	#endif
	return APLRes_Success;
}


// Boss Selection
new String:xIncoming[MAXPLAYERS+1][700];

new g_NextHale = -1;
new Handle:g_NextHaleTimer = INVALID_HANDLE;

// Boss Toggle
#define TOGGLE_UNDEF -1
#define TOGGLE_ON  1
#define TOGGLE_OFF 2

new Handle:BossCookie=INVALID_HANDLE;
new Handle:CompanionCookie=INVALID_HANDLE;

new ClientCookie[MAXPLAYERS+1];
new ClientCookie2[MAXPLAYERS+1];
new ClientPoint[MAXPLAYERS+1];
new ClientID[MAXPLAYERS+1];
new ClientQueue[MAXPLAYERS+1][2];
new Handle:cvarFF2TogglePrefDelay = INVALID_HANDLE;

stock MapKind:Maptype(String:map[])
{
	if(!StrContains(map,"dr_")) return Maptype_Deathrun;
	if(!StrContains(map,"deathrun_")) return Maptype_Deathrun;
	if(!StrContains(map,"deadrun_")) return Maptype_Deathrun;
	if(!StrContains(map,"vsh_dr_")) return Maptype_Deathrun;
	if(!StrContains(map,"vsh_")) return Maptype_VSH;
	if(!StrContains(map,"arena_")) return Maptype_Arena;
	return Maptype_Other;
}

// Plugin Start
public OnPluginStart()
{
	LogMessage("===Freak Fortress 2 Initializing-v%s===", PLUGIN_VERSION);
	sName=FindConVar("hostname");
	cvarVersion=CreateConVar("ff2_version", PLUGIN_VERSION, "Freak Fortress 2 Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);
	cvarPointType=CreateConVar("ff2_point_type", "0", "0-Use ff2_point_alive, 1-Use ff2_point_time", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarPointDelay=CreateConVar("ff2_point_delay", "6", "Seconds to add to the point delay per player", FCVAR_PLUGIN);
	cvarSpellBooks=CreateConVar("ff2_spells_enable", "1", "0-Disable spells from being dropped, 1-Enable spells", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarAliveToEnable=CreateConVar("ff2_point_alive", "5", "The control point will only activate when there are this many people or less left alive", FCVAR_PLUGIN);
	cvarAnnounce=CreateConVar("ff2_announce", "120", "Amount of seconds to wait until FF2 info is displayed again.  0 to disable", FCVAR_PLUGIN, true, 0.0);
	cvarEnabled=CreateConVar("ff2_enabled", "1", "0-Disable FF2 (WHY?), 1-Enable FF2", FCVAR_PLUGIN|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	cvarCrits=CreateConVar("ff2_crits", "1", "Can Boss get crits?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarFirstRound=CreateConVar("ff2_first_round", "-1", "This cvar is deprecated.  Please use 'ff2_arena_rounds' instead by setting this cvar to -1", FCVAR_PLUGIN, true, -1.0, true, 1.0);  //DEPRECATED
	cvarArenaRounds=CreateConVar("ff2_arena_rounds", "1", "Number of rounds to make arena before switching to FF2 (helps for slow-loading players)", FCVAR_PLUGIN, true, 0.0);
	cvarCircuitStun=CreateConVar("ff2_circuit_stun", "4", "Amount of seconds the Short Circuit and The Classic stuns the boss for.  0 to disable", FCVAR_PLUGIN, true, 0.0);
	cvarCountdownPlayers=CreateConVar("ff2_countdown_players", "1", "Amount of players until the countdown timer starts (0 to disable)", FCVAR_PLUGIN, true, 0.0);
	cvarCountdownTime=CreateConVar("ff2_countdown", "120", "Amount of seconds until the round ends in a stalemate", FCVAR_PLUGIN);
	cvarCountdownHealth=CreateConVar("ff2_countdown_health", "2000", "Amount of health the Boss has remaining until the countdown stops", FCVAR_PLUGIN, true, 0.0);
	cvarRPSQueuePoints=CreateConVar("ff2_rps_queue_points", "10", "Queue points awarded / removed upon RPS (0 to disable)", FCVAR_PLUGIN, true, 0.0);
	cvarCountdownResult=CreateConVar("ff2_countdown_result", "0", "0-Kill players when the countdown ends, 1-End the round in a stalemate", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarEnableEurekaEffect=CreateConVar("ff2_enable_eureka", "0", "0-Disable the Eureka Effect, 1-Enable the Eureka Effect", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarForceBossTeam=CreateConVar("ff2_force_team", "0", "0-Boss team depends on FF2 logic, 1-Boss is on a random team each round, 2-Boss is always on Red, 3-Boss is always on Blu", FCVAR_PLUGIN, true, 0.0, true, 3.0);
	cvarHealthBar=CreateConVar("ff2_health_bar", "0", "0-Disable the health bar, 1-Show the health bar", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarLastPlayerGlow=CreateConVar("ff2_last_player_glow", "1", "0-Don't outline the last player, 1-Outline the last player alive", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarBossTeleporter=CreateConVar("ff2_boss_teleporter", "0", "-1 to disallow all bosses from using teleporters, 0 to use TF2 logic, 1 to allow all bosses", FCVAR_PLUGIN, true, -1.0, true, 1.0);
	cvarBossSuicide=CreateConVar("ff2_boss_suicide", "0", "Allow the boss to suicide after the round starts?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarCaberDetonations=CreateConVar("ff2_caber_detonations", "5", "Amount of times somebody can detonate the Ullapool Caber", FCVAR_PLUGIN);
	cvarShieldCrits=CreateConVar("ff2_shield_crits", "0", "0 to disable grenade launcher crits when equipping a shield, 1 for minicrits, 2 for crits", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	cvarGoombaDamage=CreateConVar("ff2_goomba_damage", "0.05", "How much the Goomba damage should be multipled by when goomba stomping the boss (requires Goomba Stomp)", FCVAR_PLUGIN, true, 0.01, true, 1.0);
	cvarGoombaRebound=CreateConVar("ff2_goomba_jump", "300.0", "How high players should rebound after goomba stomping the boss (requires Goomba Stomp)", FCVAR_PLUGIN, true, 0.0);
	cvarSubtractRageOnJarate=CreateConVar("ff2_jarate_subtract_rage", "25.0", "How much rage should Jarate / Mad Milk subtract", FCVAR_PLUGIN, true, 0.0);
	cvarBossRTD=CreateConVar("ff2_boss_rtd", "0", "Can the boss use rtd? 0 to disallow boss, 1 to allow boss (requires RTD)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarUpdater=CreateConVar("ff2_updater", "0", "0-Disable Updater support, 1-Enable automatic updating (recommended, requires Updater)", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	cvarDebug=CreateConVar("ff2_debug", "0", "0-Disable FF2 debug output, 1-Enable debugging (not recommended)", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	// Boss Selection
	RegConsoleCmd("ff2_boss", Command_SetMyBoss, "Set my boss");
	RegConsoleCmd("ff2boss", Command_SetMyBoss, "Set my boss");
	RegConsoleCmd("hale_boss", Command_SetMyBoss, "Set my boss");
	RegConsoleCmd("haleboss", Command_SetMyBoss, "Set my boss");
	
	// Boss Toggle Stuff
	cvarFF2TogglePrefDelay = CreateConVar("ff2_boss_toggle_delay", "45.0", "Delay between joining the server and asking the player for their preference, if it is not set.");	
	AutoExecConfig(true, "plugin.ff2_boss_toggle");

	BossCookie = RegClientCookie("ff2_boss_toggle", "Players FF2 Boss Toggle", CookieAccess_Public);	
	CompanionCookie = RegClientCookie("ff2_companion_toggle", "Players FF2 Companion Boss Toggle", CookieAccess_Public);		
	
	RegConsoleCmd("ff2toggle", BossMenu);
	RegConsoleCmd("ff2companion", CompanionMenu);
	for(new i = 0; i < MAXPLAYERS; i++)
	{
		ClientCookie[i] = TOGGLE_UNDEF;
		ClientCookie2[i] = TOGGLE_UNDEF;
	}
	
	//The following are used in various subplugins
	CreateConVar("ff2_oldjump", "0", "Use old Saxton Hale jump equations", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	CreateConVar("ff2_base_jumper_stun", "0", "Whether or not the Base Jumper should be disabled when a player gets stunned", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	HookEvent("teamplay_round_start", Event_Setup, EventHookMode_Post);
	HookEvent("teamplay_round_win", Event_RoundWin, EventHookMode_Post);
	HookEvent("teamplay_broadcast_audio", Event_Broadcast, EventHookMode_Pre);

	HookEvent("rps_taunt_event", OnRPS);
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_chargedeployed", Event_Uber);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
	HookEvent("object_destroyed", Event_Destroy, EventHookMode_Pre);
	HookEvent("object_deflected", Event_Deflect, EventHookMode_Pre);
	HookEvent("deploy_buff_banner", Event_DeployBanner);
	HookEvent("rocket_jump", Event_RocketJump);
	HookEvent("rocket_jump_landed", Event_RocketJump);

	OnPluginStart_TeleportToMultiMapSpawn(); // Setup adt_array
	
	HookUserMessage(GetUserMessageId("PlayerJarated"), UserMessage_Jarate);  //Used to subtract rage when a boss is jarated (not through Sydney Sleeper)
	
	AddCommandListener(CMD_VoiceMenu, "voicemenu");  //Used to activate rages
	AddCommandListener(CMD_Taunt, "taunt"); 
	AddCommandListener(CMD_Taunt, "+taunt");
	AddCommandListener(CMD_Suicide, "explode");  //Used to stop boss from suiciding
	AddCommandListener(CMD_Suicide, "kill");  //Used to stop boss from suiciding
	AddCommandListener(CMD_JoinTeam, "jointeam");  //Used to make sure players join the right team
	AddCommandListener(CMD_ChangeClass, "joinclass");  //Used to make sure bosses don't change class
	
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
	HookConVarChange(cvarBossRTD, CvarChange);
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
	RegAdminCmd("ff2_loadcharset", Command_LoadCharset, ADMFLAG_CHEATS, "Usage: ff2_loadcharset <charset>.  Forces FF2 to switch to a given character set without changing maps");
	RegAdminCmd("ff2_reloadcharset", Command_ReloadCharset, ADMFLAG_CHEATS, "Usage:  ff2_reloadcharset.  Forces FF2 to reload the current character set");
	RegAdminCmd("ff2_reload", Command_ReloadFF2, ADMFLAG_ROOT, "Reloads FF2 safely and quietly");

	RegAdminCmd("ff2_special", Command_SetNextBoss, ADMFLAG_CHEATS, "Usage:  ff2_special <boss>.  Forces next round to use that boss");
	RegAdminCmd("ff2_addpoints", Command_Points, ADMFLAG_CHEATS, "Usage:  ff2_addpoints <target> <points>.  Adds queue points to any player");
	RegAdminCmd("ff2_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable the control point if ff2_point_type is 0");
	RegAdminCmd("ff2_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable the control point if ff2_point_type is 0");
	RegAdminCmd("ff2_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music");
	RegAdminCmd("ff2_resetqueuepoints", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
	RegAdminCmd("ff2_resetq", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
	RegAdminCmd("ff2_charset", Command_Charset, ADMFLAG_CHEATS, "Usage:  ff2_charset <charset>.  Forces FF2 to use a given character set for the next map");
	RegAdminCmd("ff2_votecharset", Command_VoteCharset, ADMFLAG_VOTE, "Forces FF2 charset vote");
	RegAdminCmd("ff2_reload_subplugins", Command_ReloadSubPlugins, ADMFLAG_RCON, "Reload FF2's subplugins.");
	
	RegAdminCmd("hale_select", Command_SetNextBoss, ADMFLAG_CHEATS, "Usage:  hale_select <boss>.  Forces next round to use that boss");
	RegAdminCmd("hale_special", Command_SetNextBoss, ADMFLAG_CHEATS, "Usage:  hale_select <boss>.  Forces next round to use that boss");
	RegAdminCmd("hale_addpoints", Command_Points, ADMFLAG_CHEATS, "Usage:  hale_addpoints <target> <points>.  Adds queue points to any player");
	RegAdminCmd("hale_point_enable", Command_Point_Enable, ADMFLAG_CHEATS, "Enable the control point if ff2_point_type is 0");
	RegAdminCmd("hale_point_disable", Command_Point_Disable, ADMFLAG_CHEATS, "Disable the control point if ff2_point_type is 0");
	RegAdminCmd("hale_stop_music", Command_StopMusic, ADMFLAG_CHEATS, "Stop any currently playing Boss music");
	RegAdminCmd("hale_resetqueuepoints", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");
	RegAdminCmd("hale_resetq", ResetQueuePointsCmd, ADMFLAG_CHEATS, "Reset a player's queue points");

	AutoExecConfig(true, "FreakFortress2");

	FF2Cookies=RegClientCookie("ff2_cookies_mk2", "", CookieAccess_Protected);

	jumpHUD=CreateHudSynchronizer();
	cloakHUD=CreateHudSynchronizer();
	rageHUD=CreateHudSynchronizer();
	livesHUD=CreateHudSynchronizer();
	abilitiesHUD=CreateHudSynchronizer();
	timeleftHUD=CreateHudSynchronizer();
	infoHUD=CreateHudSynchronizer();

	new String:oldVersion[64];
	GetConVarString(cvarVersion, oldVersion, sizeof(oldVersion));
	if(strcmp(oldVersion, PLUGIN_VERSION, false))
	{
		LogError("[FF2] Warning: Your config may be outdated. Back up tf/cfg/sourcemod/FreakFortress2.cfg and delete it, and this plugin will generate a new one that you can then modify to your original values.");
	}

	LoadTranslations("freak_fortress_2.phrases");
	LoadTranslations("common.phrases");

	AddNormalSoundHook(HookSound);
	
	ResetValueToZero();

	AddMultiTargetFilter("@hale", BossTargetFilter, "all current Bosses", false);
	AddMultiTargetFilter("@!hale", BossTargetFilter, "all non-Boss players", false);
	AddMultiTargetFilter("@boss", BossTargetFilter, "all current Bosses", false);
	AddMultiTargetFilter("@!boss", BossTargetFilter, "all non-Boss players", false);
	
	#if defined _steamtools_included
	steamtools=LibraryExists("SteamTools");
	#endif

	#if defined _goomba_included
	goomba=LibraryExists("goomba");
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

	#if defined _goomba_included
	if(!strcmp(name, "goomba", false))
	{
		goomba=true;
	}
	#endif

	if(!strcmp(name, "smac", false))
	{
		smac=true;
	}

	#if defined _updater_included && !defined DEV_REVISION
	if(StrEqual(name, "updater") && GetConVarBool(cvarUpdater))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
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

	#if defined _goomba_included
	if(!strcmp(name, "goomba", false))
	{
		goomba=false;
	}
	#endif

	if(!strcmp(name, "smac", false))
	{
		smac=false;
	}

	#if defined _updater_included
	if(StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
	#endif
}

public OnConfigsExecuted()
{
	tf_arena_use_queue=GetConVarInt(FindConVar("tf_arena_use_queue"));
	mp_teams_unbalance_limit=GetConVarInt(FindConVar("mp_teams_unbalance_limit"));
	tf_arena_first_blood=GetConVarInt(FindConVar("tf_arena_first_blood"));
	mp_forcecamera=GetConVarInt(FindConVar("mp_forcecamera"));
	tf_dropped_weapon_lifetime=GetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"));
	tf_feign_death_activate_damage_scale=GetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"));
	tf_feign_death_damage_scale=GetConVarFloat(FindConVar("tf_feign_death_damage_scale"));
	tf_feign_death_duration=GetConVarInt(FindConVar("tf_feign_death_duration"));
	tf_stealth_damage_reduction=GetConVarFloat(FindConVar("tf_stealth_damage_reduction"));
	
	GetConVarString(sName, hName, sizeof(hName));
	
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
	MusicTimer=INVALID_HANDLE;
	RoundCount=0;
	TeamRoundCounter=0;
	
	for(new client; client<=MaxClients; client++)
	{
		KSpreeTimer[client]=0.0;
		FF2flags[client]=0;
		Incoming[client]=-1;
	}

	for(new specials; specials<MAXSPECIALS; specials++)
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
}

public OnMapEnd()
{
	if(Enabled || Enabled2)
	{
		StopMusic();
		
		SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
		SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
		SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
		SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), tf_dropped_weapon_lifetime);
		SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), tf_feign_death_activate_damage_scale);
		SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), tf_feign_death_damage_scale);
		SetConVarInt(FindConVar("tf_feign_death_duration"), tf_feign_death_duration);
		SetConVarFloat(FindConVar("tf_stealth_damage_reduction"), tf_stealth_damage_reduction);
		
		#if defined _steamtools_included
		if(steamtools)
		{
			Steam_SetGameDescription("Team Fortress");
		}
		#endif
		DisableSubPlugins();

		if(MusicTimer!=INVALID_HANDLE)
		{
			KillTimer(MusicTimer);
			MusicTimer=INVALID_HANDLE;
		}
		
		ResetValueToZero();
		
		if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
		{
			ServerCommand("smac_addcvar sv_cheats replicated ban 0 0");
			ServerCommand("smac_addcvar host_timescale replicated ban 1.0 1.0");
		}
	}
}

public OnPluginEnd()
{
	OnMapEnd();
	if (!ReloadFF2 && CheckRoundState() == FF2RoundState_RoundRunning)
	{
		ServerCommand("mp_restartround 5");
		CPrintToChatAll("{olive}[FF2]{default} The plugin has been unexpectedly unloaded!");
	}
}

public EnableFF2()
{
	MusicTimer=INVALID_HANDLE;

	Enabled=true;
	Enabled2=true;

	//Cache cvars
	SetConVarString(FindConVar("ff2_version"), PLUGIN_VERSION);
	Announce=GetConVarFloat(cvarAnnounce);
	PointType=GetConVarInt(cvarPointType);
	PointDelay=GetConVarInt(cvarPointDelay);
	if(PointDelay<0)
	{
		PointDelay*=-1;
	}
	GoombaDamage=GetConVarFloat(cvarGoombaDamage);
	reboundPower=GetConVarFloat(cvarGoombaRebound);
	canBossRTD=GetConVarBool(cvarBossRTD);
	AliveToEnable=GetConVarInt(cvarAliveToEnable);
	BossCrits=GetConVarBool(cvarCrits);
	if(GetConVarInt(cvarFirstRound)!=-1)
	{
		arenaRounds=GetConVarInt(cvarFirstRound) ? 0 : 1;
	}
	else
	{
		arenaRounds=GetConVarInt(cvarArenaRounds);
	}
	circuitStun=GetConVarFloat(cvarCircuitStun);
	countdownHealth=GetConVarInt(cvarCountdownHealth);
	countdownPlayers=GetConVarInt(cvarCountdownPlayers);
	countdownTime=GetConVarInt(cvarCountdownTime);
	lastPlayerGlow=GetConVarBool(cvarLastPlayerGlow);
	bossTeleportation=GetConVarBool(cvarBossTeleporter);
	shieldCrits=GetConVarInt(cvarShieldCrits);
	allowedDetonations=GetConVarInt(cvarCaberDetonations);

	//Set some Valve cvars to what we want them to be
	SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
	SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
	SetConVarInt(FindConVar("mp_forcecamera"), 0);
	SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), 0.0);
	SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), 0.1);
	SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), 0.1);
	SetConVarInt(FindConVar("tf_feign_death_duration"), 7);
	SetConVarFloat(FindConVar("tf_stealth_damage_reduction"), 0.1);
		
	new Float:time=Announce;
	if(time>1.0)
	{
		AnnounceAt=GetEngineTime()+time;
	}

	CheckToChangeMapDoors();
	CheckToTeleportToSpawn();
	MapHasMusic(true);
	FindCharacters();
	strcopy(FF2CharSetString, 2, "");

	if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
	{
		ServerCommand("smac_removecvar sv_cheats");
		ServerCommand("smac_removecvar host_timescale");
	}

	bMedieval=FindEntityByClassname(-1, "tf_logic_medieval")!=-1 || bool:GetConVarInt(FindConVar("tf_medieval"));
	FindHealthBar();

	#if defined _steamtools_included
	if(steamtools)
	{
		new String:gameDesc[64];
		Format(gameDesc, sizeof(gameDesc), (DeadRunMode == true ? "FF2 Deathrun (%s)" : "Freak Fortress 2 (%s)"), PLUGIN_VERSION);			
		Steam_SetGameDescription(gameDesc);
	}
	#endif

	changeGamemode=0;
}

public DisableFF2()
{
	Enabled=false;
	Enabled2=false;

	DisableSubPlugins();

	MusicTimer=INVALID_HANDLE;

	ResetValueToZero();
	
	SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
	SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
	SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
	SetConVarFloat(FindConVar("tf_dropped_weapon_lifetime"), tf_dropped_weapon_lifetime);
	SetConVarFloat(FindConVar("tf_feign_death_activate_damage_scale"), tf_feign_death_activate_damage_scale);
	SetConVarFloat(FindConVar("tf_feign_death_damage_scale"), tf_feign_death_damage_scale);
	SetConVarInt(FindConVar("tf_feign_death_duration"), tf_feign_death_duration);
	SetConVarFloat(FindConVar("tf_stealth_damage_reduction"), tf_stealth_damage_reduction);
	SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
	SetConVarString(sName, hName);
	
	for(new client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			if(BossInfoTimer[client][1]!=INVALID_HANDLE)
			{
				KillTimer(BossInfoTimer[client][1]);
				BossInfoTimer[client][1]=INVALID_HANDLE;
			}
		}
	}

	if(MusicTimer!=INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer=INVALID_HANDLE;
	}

	if(smac && FindPluginByFile("smac_cvars.smx")!=INVALID_HANDLE)
	{
		ServerCommand("smac_addcvar sv_cheats replicated ban 0 0");
		ServerCommand("smac_addcvar host_timescale replicated ban 1.0 1.0");
	}

	#if defined _steamtools_included
	if(steamtools)
	{
		Steam_SetGameDescription("Team Fortress");
	}
	#endif

	changeGamemode=0;
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
	DrawGameTimerAt=INACTIVE;
	DisplayMessageAt=INACTIVE;
	StartBossAt=INACTIVE;
	StartResponseAt=INACTIVE;
	DisplayNextBossPanelAt=INACTIVE;
	MoveAt=INACTIVE;
	FF2BossTick=INACTIVE;
	FF2ClientTick=INACTIVE;
}

public FindCharacters()  //TODO: Investigate KvGotoFirstSubKey; KvGotoNextKey
{
	new String:config[PLATFORM_MAX_PATH], String:key[4], String:charset[42];
	Specials=0;
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/characters.cfg");

	if(!FileExists(config))
	{
		LogError("[FF2] Freak Fortress 2 disabled-can not find characters.cfg!");
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

	for(new i=1; i<MAXSPECIALS; i++)
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

	new String:stringChances[MAXSPECIALS*2][8];
	if(ChancesString[0])
	{
		new amount=ExplodeString(ChancesString, ";", stringChances, MAXSPECIALS*2, 8);
		if(amount % 2)
		{
			LogError("[FF2 Bosses] Invalid chances string, disregarding chances");
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
					LogError("[FF2 Bosses] Character %i cannot have a zero or negative chance, disregarding chances", chancesIndex-1);
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
	PrecacheSound(AHH_PISS);
	isCharSetSelected=false;
	isCharsetOverride=false;
}

EnableSubPlugins(bool:force=false)
{
	if(areSubPluginsEnabled && !force)
	{
		return;
	}

	areSubPluginsEnabled=true;
	new String:path[PLATFORM_MAX_PATH], String:filename[PLATFORM_MAX_PATH], String:filename_old[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/freaks");
	new FileType:filetype;
	new Handle:directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".smx", false)!=-1)
		{
			Format(filename_old, PLATFORM_MAX_PATH, "%s/%s", path, filename);
			ReplaceString(filename, PLATFORM_MAX_PATH, ".smx", ".ff2", false);
			Format(filename, PLATFORM_MAX_PATH, "%s/%s", path, filename);
			DeleteFile(filename);
			RenameFile(filename, filename_old);
		}
	}

	directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			ServerCommand("sm plugins load freaks/%s", filename);
		}
	}
}

DisableSubPlugins(bool:force=false)
{
	if(!areSubPluginsEnabled && !force)
	{
		return;
	}

	new String:path[PLATFORM_MAX_PATH], String:filename[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/freaks");
	new FileType:filetype;
	new Handle:directory=OpenDirectory(path);
	while(ReadDirEntry(directory, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype==FileType_File && StrContains(filename, ".ff2", false)!=-1)
		{
			InsertServerCommand("sm plugins unload freaks/%s", filename);  //ServerCommand will not work when switching maps
		}
	}
	ServerExecute();
	areSubPluginsEnabled=false;
}

public LoadCharacter(const String:character[])
{
	new String:extensions[][]={".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy"};
	new String:config[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/%s.cfg", character);
	if(!FileExists(config))
	{
		LogError("[FF2] Character %s does not exist!", character);
		return;
	}
	BossKV[Specials]=CreateKeyValues("character");
	FileToKeyValues(BossKV[Specials], config);

	new version=KvGetNum(BossKV[Specials], "version", 1);
	if(version!=1)
	{
		LogError("[FF2 Bosses] Character %s is only compatible with FF2 v%i!", character, version);
		return;
	}

	for(new i=1; ; i++)
	{
		Format(config, 10, "ability%i", i);
		if(KvJumpToKey(BossKV[Specials], config))
		{
			new String:plugin_name[64];
			KvGetString(BossKV[Specials], "plugin_name", plugin_name, 64);
			BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "plugins/freaks/%s.ff2", plugin_name);
			if(!FileExists(config))
			{
				LogError("[FF2 Bosses] Character %s needs plugin %s!", character, plugin_name);
				return;
			}
		}
		else
		{
			break;
		}
	}
	KvRewind(BossKV[Specials]);

	new String:key[PLATFORM_MAX_PATH], String:section[64];
	KvSetString(BossKV[Specials], "filename", character);
	KvGetString(BossKV[Specials], "name", config, PLATFORM_MAX_PATH);
	bBlockVoice[Specials]=bool:KvGetNum(BossKV[Specials], "sound_block_vo", 0);
	BossSpeed[Specials]=KvGetFloat(BossKV[Specials], "maxspeed", 340.0);
	KvGotoFirstSubKey(BossKV[Specials]);

	while(KvGotoNextKey(BossKV[Specials]))
	{
		KvGetSectionName(BossKV[Specials], section, sizeof(section));
		if(!strcmp(section, "download"))
		{
			for(new i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV[Specials], key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}
				#if defined FILECHECK_ENABLED
				if(FileExists(config, true))
					AddFileToDownloadsTable(config);
				else
					LogError("[FF2 Bosses] Character %s is missing file '%s'!", character, config);
				#else
				AddFileToDownloadsTable(config);
				#endif
			}
		}
		else if(!strcmp(section, "mod_download"))
		{
			for(new i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV[Specials], key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}

				for(new extension; extension<sizeof(extensions); extension++)
				{
					Format(key, PLATFORM_MAX_PATH, "%s%s", config, extensions[extension]);
					#if defined FILECHECK_ENABLED
					if(FileExists(key, true))
						AddFileToDownloadsTable(key);
					else
						LogError("[FF2 Bosses] Character %s is missing file '%s'!", character, key);
					#else
					AddFileToDownloadsTable(key);
					#endif
				}
			}
		}
		else if(!strcmp(section, "mat_download"))
		{
			for(new i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV[Specials], key, config, PLATFORM_MAX_PATH);
				if(!config[0])
				{
					break;
				}
				Format(key, PLATFORM_MAX_PATH, "%s.vtf", config);
				#if defined FILECHECK_ENABLED
				if(FileExists(key, true))
					AddFileToDownloadsTable(key);
				else
					LogError("[FF2 Bosses] Character %s is missing file '%s'!", character, key);
				#else
				AddFileToDownloadsTable(key);
				#endif
				Format(key, PLATFORM_MAX_PATH, "%s.vmt", config);
				#if defined FILECHECK_ENABLED
				if(FileExists(key, true))
					AddFileToDownloadsTable(key);
				else
					LogError("[FF2 Bosses] Character %s is missing file '%s'!", character, key);
				#else
				AddFileToDownloadsTable(key);
				#endif
			}
		}
	}
	Specials++;
}

public PrecacheCharacter(characterIndex)
{
	#if defined FILECHECK_ENABLED
	decl String:file[PLATFORM_MAX_PATH], String:filePath[PLATFORM_MAX_PATH], String:key[8], String:section[16];
	#else
	decl String:file[PLATFORM_MAX_PATH], String:key[8], String:section[16];	
	#endif
	KvRewind(BossKV[characterIndex]);
	KvGotoFirstSubKey(BossKV[characterIndex]);
	while(KvGotoNextKey(BossKV[characterIndex]))
	{
		KvGetSectionName(BossKV[characterIndex], section, sizeof(section));
		if(StrEqual(section, "sound_bgm"))
		{
			for(new i=1; ; i++)
			{
				Format(key, sizeof(key), "path%d", i);
				KvGetString(BossKV[characterIndex], key, file, sizeof(file));
				if(!file[0])
				{
					break;
				}
				#if defined FILECHECK_ENABLED
				Format(filePath, sizeof(filePath), "sound/%s", file);  //Sounds doesn't include the sound/ prefix, so add that
				if(FileExists(filePath, true))
				{
					PrecacheSound(file);
				}
				else
				{
					decl String:bossName[64];
					KvRewind(BossKV[characterIndex]);
					KvGetString(BossKV[characterIndex], "filename", bossName, sizeof(bossName));
					LogError("[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
				}
				#else
				PrecacheSound(file);
				#endif
			}
		}
		else if(StrEqual(section, "mod_precache") || !StrContains(section, "sound_") || StrEqual(section, "catch_phrase"))
		{
			for(new i=1; ; i++)
			{
				IntToString(i, key, sizeof(key));
				KvGetString(BossKV[characterIndex], key, file, sizeof(file));
				if(!file[0])
				{
					break;
				}

				if(StrEqual(section, "mod_precache"))
				{
					#if defined FILECHECK_ENABLED
					if(FileExists(file, true))
					{
						PrecacheModel(file);
					}
					else
					{
						decl String:bossName[64];
						KvRewind(BossKV[characterIndex]);
						KvGetString(BossKV[characterIndex], "filename", bossName, sizeof(bossName));
						LogError("[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
					}
					#else
					PrecacheModel(file);
					#endif
				}
				else
				{
					#if defined FILECHECK_ENABLED
					Format(filePath, sizeof(filePath), "sound/%s", file);  //Sounds doesn't include the sound/ prefix, so add that
					if(FileExists(filePath, true))
					{
						PrecacheSound(file);
					}
					else
					{
						decl String:bossName[64];
						KvRewind(BossKV[characterIndex]);
						KvGetString(BossKV[characterIndex], "filename", bossName, sizeof(bossName));
						LogError("[FF2 Bosses] Character %s is missing file '%s' in section '%s'!", bossName, filePath, section);
					}
					#else
					PrecacheSound(file);
					#endif
				}
			}
		}
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
	else if(convar==cvarBossRTD)
	{
		canBossRTD=bool:StringToInt(newValue);
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

#if defined _smac_included
public Action:SMAC_OnCheatDetected(client, const String:module[], DetectionType:type, Handle:info)
{
	if(type==Detection_CvarViolation)
	{
		new String:cvar[PLATFORM_MAX_PATH];
		KvGetString(info, "cvar", cvar, sizeof(cvar));
		if((StrEqual(cvar, "sv_cheats") || StrEqual(cvar, "host_timescale")) && !(FF2flags[Boss[client]] & FF2FLAG_CHANGECVAR))
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}
#endif

stock bool:IsFF2Map()
{
	new String:config[PLATFORM_MAX_PATH];
	GetCurrentMap(currentmap, sizeof(currentmap));
	if(FileExists("bNextMapToFF2"))
	{
		return true;
	}

	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/maps.cfg");
	if(!FileExists(config))
	{
		LogError("[FF2] Unable to find %s, disabling plugin.", config);
		return false;
	}

	new Handle:file=OpenFile(config, "r");
	if(file==INVALID_HANDLE)
	{
		LogError("[FF2] Error reading maps from %s, disabling plugin.", config);
		return false;
	}

	new tries;
	while(ReadFileLine(file, config, sizeof(config)) && tries<100)
	{
		tries++;
		if(tries==100)
		{
			LogError("[FF2] Breaking infinite loop when trying to check the map.");
			return false;
		}

		Format(config, strlen(config)-1, config);
		if(!strncmp(config, "//", 2, false))
		{
			continue;
		}

		if(!StrContains(currentmap, config, false) || !StrContains(config, "all", false))
		{
			CloseHandle(file);
			return true;
		}
	}
	CloseHandle(file);
	return false;
}

stock bool:MapHasMusic(bool:forceRecalc=false)  //SAAAAAARGE
{
	static bool:hasMusic;
	static bool:found;
	if(forceRecalc)
	{
		found=false;
		hasMusic=false;
	}

	if(!found)
	{
		new entity=-1;
		new String:name[64];
		while((entity=FindEntityByClassname2(entity, "info_target"))!=-1)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
			if(!strcmp(name, "hale_no_music", false) || !StrContains(chkcurrentmap, "vsh_megaman") || DeadRunMode)
			{
				hasMusic=true;
			}
		}
		found=true;
	}
	return hasMusic;
}

stock bool:CheckToChangeMapDoors()
{
	if(!Enabled || !Enabled2)
	{
		return;
	}

	new String:config[PLATFORM_MAX_PATH];
	checkDoors=false;
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/doors.cfg");
	if(!FileExists(config))
	{
		if(!strncmp(currentmap, "vsh_lolcano_pb1", 15, false))
		{
			checkDoors=true;
		}
		return;
	}

	new Handle:file=OpenFile(config, "r");
	if(file==INVALID_HANDLE)
	{
		if(!strncmp(currentmap, "vsh_lolcano_pb1", 15, false))
		{
			checkDoors=true;
		}
		return;
	}

	while(!IsEndOfFile(file) && ReadFileLine(file, config, sizeof(config)))
	{
		Format(config, strlen(config)-1, config);
		if(!strncmp(config, "//", 2, false))
		{
			continue;
		}

		if(StrContains(currentmap, config, false)!=-1 || !StrContains(config, "all", false))
		{
			CloseHandle(file);
			checkDoors=true;
			return;
		}
	}
	CloseHandle(file);
}

CheckToTeleportToSpawn()
{
    decl String:config[PLATFORM_MAX_PATH];
    GetCurrentMap(currentmap, sizeof(currentmap));
    bSpawnTeleOnTriggerHurt = false;

    BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/spawn_teleport.cfg");

    if (!FileExists(config))
    {
		LogError("[FF2] Unable to find %s, will not activate teleport to spawn.", config);
		return;
    }

    new Handle:fileh = OpenFile(config, "r");

    if (fileh == INVALID_HANDLE)
    {
        return;
    }

    while (!IsEndOfFile(fileh) && ReadFileLine(fileh, config, sizeof(config)))
    {
        Format(config, strlen(config) - 1, config);
        if (strncmp(config, "//", 2, false) == 0)
        {
            continue;
        }

        if (StrContains(currentmap, config, false) != -1 || StrContains(config, "all", false) == 0)
        {
			LogMessage("[FF2] enabling teleport to spawn for %s", currentmap);
			bSpawnTeleOnTriggerHurt = true;
			CloseHandle(fileh);
			return;
        }
    }

    CloseHandle(fileh);
}

public Action:Event_Setup(Handle:event, const String:name[], bool:dontBroadcast)
{
	teamplay_round_start_TeleportToMultiMapSpawn(); // Cache spawns
	SetConVarBool(FindConVar("mp_friendlyfire"), false);
	
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
			if (Maptype(currentmap) == Maptype_VSH || DeadRunMode) 
				blueBoss = true;
			else if (TeamRoundCounter >= 3 && GetRandomInt(0, 1))
			{
				blueBoss = (BossTeam != 3);
				TeamRoundCounter = 0;
			}
			else blueBoss = (BossTeam == 3);
		}
	}

	playing=0;
	for(new client=1; client<=MaxClients; client++)
	{
		Damage[client]=0;
		GoombaCount[client]=0;
		airstab[client]=0;
		uberTarget[client]=-1;
		emitRageSound[client]=true;
		if(IsValidClient(client) && GetClientTeam(client)>_:TFTeam_Spectator)
		{
			playing++;
		}
	}

	if(GetClientCount()<=1 || playing<=1)  //Not enough players D:
	{
		CPrintToChatAll("{olive}[FF2]{default} %t", "needmoreplayers");
		Enabled=false;
		DisableSubPlugins();
		SetControlPoint(true);
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
		if(IsValidClient(client) && IsPlayerAlive(client) && !(FF2flags[client] & FF2FLAG_HASONGIVED))
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
			AssignTeam(Boss[0], BossTeam);
		}

		for(new client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client) && !IsBoss(client) && GetClientTeam(client)!=MercTeam)
			{
				CreateTimer(0.1, MakeNotBoss, GetClientUserId(client));
			}
		}
		return Plugin_Continue;  //NOTE: This is needed because Event_Setup gets fired a second time once both teams have players
	}

	PickCharacter(0, 0);
	if((Special[0]<0) || !BossKV[Special[0]])
	{
		LogError("[FF2] I just don't know what went wrong");
		return Plugin_Continue;
	}

	KvRewind(BossKV[Special[0]]);
	BossRageDamage[0]=KvGetNum(BossKV[Special[0]], "ragedamage", 1900);
	if(BossRageDamage[0]<=0)
	{
		decl String:bossName[64];
		KvGetString(BossKV[Special[0]], "name", bossName, sizeof(bossName));
		PrintToServer("[FF2 Bosses] Warning: Boss %s's rage damage is 0 or below, setting to 1900", bossName);
		BossRageDamage[0]=1900;
	}


	BossLivesMax[0]=KvGetNum(BossKV[Special[0]], "lives", 1);
	if(BossLivesMax[0]<=0)
	{
		decl String:bossName[64];
		KvGetString(BossKV[Special[0]], "name", bossName, sizeof(bossName));
		PrintToServer("[FF2 Bosses] Warning: Boss %s has an invalid amount of lives, setting to 1", bossName);
		BossLivesMax[0]=1;
	}

	HasCompanions = false;
	FindCompanion(0, playing, omit);  //Find companions for the boss!

	for(new boss; boss<=MaxClients; boss++)
	{
		BossInfoTimer[boss][0]=INVALID_HANDLE;
		BossInfoTimer[boss][1]=INVALID_HANDLE;
		if(Boss[boss])
		{
			CreateTimer(0.3, MakeBoss, boss, TIMER_FLAG_NO_MAPCHANGE);
			BossInfoTimer[boss][0]=CreateTimer(30.2, BossInfoTimer_Begin, boss, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	StartResponseAt = GetEngineTime()+3.5;
	StartBossAt = GetEngineTime()+9.1;
	DisplayMessageAt = GetEngineTime()+9.6;

	for(new entity=MaxClients+1; entity<MAXENTITIES; entity++)
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
		
		if (ClientCookie[client] == TOGGLE_ON)
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
		else if (ClientCookie[client] == TOGGLE_OFF)
		{
			SetClientQueuePoints(client, -10);
   			decl String:nick[64]; 
   			GetClientName(client, nick, sizeof(nick));
			CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
		}
		else if (ClientCookie[client] == TOGGLE_UNDEF || !ClientCookie[client])
		{
			decl String:nick[64]; 
			GetClientName(client, nick, sizeof(nick));
			new Handle:clientPack = CreateDataPack();
			WritePackCell(clientPack, client);
			CreateTimer(GetConVarFloat(cvarFF2TogglePrefDelay), BossMenuTimer, clientPack);			
		}
	}
	
	healthcheckused=0;
	firstBlood=true;	
	return Plugin_Continue;	
}



public Action:BossInfoTimer_Begin(Handle:timer, any:client)
{
	BossInfoTimer[client][0]=INVALID_HANDLE;
	BossInfoTimer[client][1]=CreateTimer(0.2, BossInfoTimer_ShowInfo, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action:BossInfoTimer_ShowInfo(Handle:timer, any:client)
{
	if((FF2flags[Boss[client]] & FF2FLAG_USINGABILITY))
	{
		BossInfoTimer[client][1]=INVALID_HANDLE;
		return Plugin_Stop;
	}

	new bool:see;
	for(new n=1; ; n++)
	{
		new String:s[10];
		Format(s, 10, "ability%i", n);
		if(client==-1 || Special[client]==-1 || !BossKV[Special[client]])
		{
			return Plugin_Stop;
		}

		KvRewind(BossKV[Special[client]]);
		if(KvJumpToKey(BossKV[Special[client]], s))
		{
			new String:plugin_name[64];
			KvGetString(BossKV[Special[client]], "plugin_name", plugin_name, 64);
			if(KvGetNum(BossKV[Special[client]], "buttonmode", 0)==2)
			{
				see=true;
				break;
			}
		}
		else
		{
			break;
		}
	}
	new need_info_bout_reload=see && CheckInfoCookies(Boss[client], 0);
	new need_info_bout_rmb=CheckInfoCookies(Boss[client], 1);
	if(need_info_bout_reload)
	{
		SetHudTextParams(0.75, 0.7, 0.15, 255, 255, 255, 255);
		SetGlobalTransTarget(Boss[client]);
		if(need_info_bout_rmb)
		{
			FF2_ShowSyncHudText(Boss[client], abilitiesHUD, "%t\n%t", "Reload Buttonmode", "Right Mouse Button Buttonmode");
		}
		else
		{
			FF2_ShowSyncHudText(Boss[client], abilitiesHUD, "%t", "Reload Buttonmode");
		}
	}
	else if(need_info_bout_rmb)
	{
		SetHudTextParams(0.75, 0.7, 0.15, 255, 255, 255, 255);
		SetGlobalTransTarget(Boss[client]);
		FF2_ShowSyncHudText(Boss[client], abilitiesHUD, "%t", "Right Mouse Button Buttonmode");
	}
	else
	{
		BossInfoTimer[client][1]=INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
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

public Action:Event_Broadcast(Handle:event, const String:name[], bool:dontBroadcast)
{
	new String:strAudio[PLATFORM_MAX_PATH];
	GetEventString(event, "sound", strAudio, sizeof(strAudio));
	if(strncmp(strAudio, "Game.Your", 9) == 0 || strcmp(strAudio, "Game.Stalemate") == 0)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Event_RoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
	RoundCount++;
	TeamRoundCounter++;
	RoundTick=0;
	
	if(HasSwitched)
	{
		HasSwitched=false;
	}
	
	SetConVarBool(FindConVar("mp_friendlyfire"), true);
	
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
	
	if(!Enabled)
	{
		return Plugin_Continue;
	}

	new String:text[128], String:sound[PLATFORM_MAX_PATH];
	new bool:bossWin=false;
	executed=false;
	executed2=false;
	if((GetEventInt(event, "team")==BossTeam))
	{
		bossWin=true;
		if(RandomSound("sound_win", sound, sizeof(sound)))
		{
			EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[0], _, _, false);
			EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[0], _, _, false);
		}
	}

	StopMusic();

	if(MusicTimer!=INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer=INVALID_HANDLE;
	}

	DrawGameTimerAt = INACTIVE;
	
	new bool:isBossAlive, boss;
	for(new client; client<=MaxClients; client++)
	{
		if(IsValidClient(Boss[client]))
		{
			SetClientGlow(client, 0.0, 0.0);
			dmgTriple[client]=false;
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
			SetClientGlow(client, 0.0, 0.0);
			shield[client]=0;
			detonations[client]=0;
		}

		for(new timer; timer<=1; timer++)
		{
			if(BossInfoTimer[client][timer]!=INVALID_HANDLE)
			{
				KillTimer(BossInfoTimer[client][timer]);
				BossInfoTimer[client][timer]=INVALID_HANDLE;
			}
		}
	}

	if(isBossAlive)
	{
		new String:bossName[64], String:lives[4];
		for(new target; target<=MaxClients; target++)
		{
			if(IsBoss(target))
			{
				boss=Boss[target];
				KvRewind(BossKV[Special[boss]]);
				KvGetString(BossKV[Special[boss]], "name", bossName, sizeof(bossName), "=Failed name=");
				if(BossLives[boss]>1)
				{
					Format(lives, 4, "x%i", BossLives[boss]);
				}
				else
				{
					strcopy(lives, 2, "");
				}
				Format(text, PLATFORM_MAX_PATH, "%s\n%t", text, "ff2_alive", bossName, target, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
			}
		}
		if(!bossWin && (RandomSound("sound_fail", sound, PLATFORM_MAX_PATH, boss)))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}
	}

	new top[3];
	Damage[0]=0;
	for(new client; client<=MaxClients; client++)
	{
		if(Damage[client]<=0 || IsBoss(client))
		{
			continue;
		}

		if(Damage[client]>=Damage[top[0]])
		{
			top[2]=top[1];
			top[1]=top[0];
			top[0]=client;
		}
		else if(Damage[client]>=Damage[top[1]])
		{
			top[2]=top[1];
			top[1]=client;
		}
		else if(Damage[client]>=Damage[top[2]])
		{
			top[2]=client;
		}
	}

	if(Damage[top[0]]>9000)
	{
		NineThousandAt = GetEngineTime()+1.0;
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
			SetGlobalTransTarget(client);
			//TODO:  Clear HUD text here
			if(IsBoss(client))
			{
				FF2_ShowSyncHudText(client, infoHUD, "%s\n%t:\n1) %i-%s\n2) %i-%s\n3) %i-%s\n\n%t", text, "top_3", Damage[top[0]], leaders[0], Damage[top[1]], leaders[1], Damage[top[2]], leaders[2], (bossWin ? "boss_win" : "boss_lose"));
			}
			else
			{
				FF2_ShowSyncHudText(client, infoHUD, "%s\n%t:\n1) %i-%s\n2) %i-%s\n3) %i-%s\n\n%t\n%t", text, "top_3", Damage[top[0]], leaders[0], Damage[top[1]], leaders[1], Damage[top[2]], leaders[2], "damage_fx", Damage[client], "scores", RoundFloat(Damage[client]/600.0));
			}
		}
	}
	HasCompanions = false;
	
	CalcQueuePointsAt=GetEngineTime()+3.0;
	
	UpdateHealthBar();

	for(new client=0;client<=MaxClients;client++)
	{	if (client>0 && IsValidEntity(client) && IsClientConnected(client))
		{
			 if (ClientCookie[client] == TOGGLE_OFF)
			{
				FF2_SetQueuePoints(client,((FF2_GetQueuePoints(client))-FF2_GetQueuePoints(client))-10);
    				decl String:nick[64]; 
    				GetClientName(client, nick, sizeof(nick));
			}
		}
	}
	return Plugin_Continue;
}

stock AssignTeam(client, team)
{
	SetEntProp(client, Prop_Send, "m_lifeState", 2);
	ChangeClientTeam(client, team);
	SetEntProp(client, Prop_Send, "m_lifeState", 0);
	TF2_RespawnPlayer(client);
}


public Action:BossMenuTimer(Handle:timer, any:clientpack)
{
	decl clientId;
	ResetPack(clientpack);
	clientId = ReadPackCell(clientpack);
	CloseHandle(clientpack);
	if (ClientCookie[clientId] == TOGGLE_UNDEF)
	{
		BossMenu(clientId, 0);
	}
}

// Companion Menu
public Action:CompanionMenu(client, args)
{
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Companion Toggle Menu Title", ClientCookie2[client]);
	
		decl String:sEnabled[2];
		GetClientCookie(client, CompanionCookie, sEnabled, sizeof(sEnabled));
		ClientCookie2[client] = StringToInt(sEnabled);	
		
		new Handle:menu = CreateMenu(MenuHandlerCompanion);
		SetMenuTitle(menu, "%t", "FF2 Companion Toggle Menu Title", ClientCookie2[client]);
		
		new String:menuoption[128];
		Format(menuoption,sizeof(menuoption),"%t","Enable Companion Selection");
		AddMenuItem(menu, "FF2 Companion Toggle Menu", menuoption);
		Format(menuoption,sizeof(menuoption),"%t","Disable Companion Selection");
		AddMenuItem(menu, "FF2 Companion Toggle Menu", menuoption);
	
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, 20);
	}
	return Plugin_Handled;
}

public MenuHandlerCompanion(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)	
	{
		decl String:sEnabled[2];
		new choice = param2 + 1;

		ClientCookie2[param1] = choice;
		IntToString(choice, sEnabled, sizeof(sEnabled));

		SetClientCookie(param1, CompanionCookie, sEnabled);
		
		if(1 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Enabled");
		}
		else if(2 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Companion Disabled");
		}
	} 
	else if(action == MenuAction_End)
	{
	   CloseHandle(menu);
	}
}

// Boss menu
public Action:BossMenu(client, args)
{
	if (IsValidClient(client))
	{
		CPrintToChat(client, "{olive}[FF2]{default} %t", "FF2 Toggle Menu Title", ClientCookie[client]);
		decl String:sEnabled[2];
		GetClientCookie(client, BossCookie, sEnabled, sizeof(sEnabled));
		ClientCookie[client] = StringToInt(sEnabled);	
		
		new Handle:menu = CreateMenu(MenuHandlerBoss);
		SetMenuTitle(menu, "%t", "FF2 Toggle Menu Title", ClientCookie[client]);
		
		new String:menuoption[128];
		Format(menuoption,sizeof(menuoption),"%t","Enable Queue Points");
		AddMenuItem(menu, "Boss Toggle", menuoption);
		Format(menuoption,sizeof(menuoption),"%t","Disable Queue Points");
		AddMenuItem(menu, "Boss Toggle", menuoption);
	
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, 20);
	}
	return Plugin_Handled;
}

public MenuHandlerBoss(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)	
	{
		decl String:sEnabled[2];
		new choice = param2 + 1;

		ClientCookie[param1] = choice;
		IntToString(choice, sEnabled, sizeof(sEnabled));

		SetClientCookie(param1, BossCookie, sEnabled);
		
		if(1 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Enabled Notification");
		}
		else if(2 == choice)
		{
			CPrintToChat(param1, "{olive}[FF2]{default} %t", "FF2 Toggle Disabled Notification");
		}
	} 
	else if(action == MenuAction_End)
	{
	   CloseHandle(menu);
	}
}

public SortQueueDesc(x[], y[], array[][], Handle:data)
{
    if (x[1] > y[1]) 
        return -1;
    else if (x[1] < y[1]) 
        return 1;    
    return 0;
}


stock CalcQueuePoints()
{
	new damage;
	botqueuepoints+=5;
	new add_points[MAXPLAYERS+1];
	new add_points2[MAXPLAYERS+1];
	for(new client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			damage=Damage[client];
			new Handle:event=CreateEvent("player_escort_score", true);
			SetEventInt(event, "player", client);

			new points;
			while(damage-600>0)
			{
				damage-=600;
				points++;
			}
			SetEventInt(event, "points", points);
			FireEvent(event);

			if(IsBoss(client) && FF2_GetBossIndex(client)==0)
			{
				if(IsFakeClient(client))
				{
					botqueuepoints=0;
				}
				if(IsFakeClient(client))
				{
					botqueuepoints=0;
				}
				else
				{
					add_points[client]=-GetClientQueuePoints(client);
					add_points2[client]=add_points[client];
				}
			}
			else if(!IsFakeClient(client) && (GetClientTeam(client)>_:TFTeam_Spectator))
			{
				if(damage>0 && !DeadRunMode)
				{
					add_points[client]=10+points;
					add_points2[client]=10+points;
				}
				if(DeadRunMode)
				{
					add_points[client]=10;
					add_points2[client]=10;					
				}
			}
		}
	}

	new Action:action=Plugin_Continue;
	Call_StartForward(OnAddQueuePoints);
	Call_PushArrayEx(add_points2, MAXPLAYERS+1, SM_PARAM_COPYBACK);
	Call_Finish(action);
	switch(action)
	{
		case Plugin_Stop, Plugin_Handled:
		{
			return;
		}
		case Plugin_Changed:
		{
			for(new client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client))
				{
					if(add_points2[client]>0)
					{
						CPrintToChat(client, "{olive}[FF2]{default} %t", "add_points", add_points2[client]);
					}
					SetClientQueuePoints(client, GetClientQueuePoints(client)+add_points2[client]);
				}
			}
		}
		default:
		{
			for(new client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client))
				{
					if(add_points[client]>0)
					{
						CPrintToChat(client, "{olive}[FF2]{default} %t", "add_points", add_points[client]);
					}
					SetClientQueuePoints(client, GetClientQueuePoints(client)+add_points[client]);
				}
			}
		}
	}
}

public Action:Timer_MusicPlay(Handle:timer, any:client)
{
	if(CheckRoundState()!=FF2RoundState_RoundRunning)
	{
		return Plugin_Continue;
	}

	if(MusicTimer!=INVALID_HANDLE)
	{
		KillTimer(MusicTimer);
		MusicTimer=INVALID_HANDLE;
	}

	if(timer!=INVALID_HANDLE && MapHasMusic())
	{
		MusicIndex=-1;
		return Plugin_Continue;
	}
	KvRewind(BossKV[Special[0]]);
	if(KvJumpToKey(BossKV[Special[0]], "sound_bgm"))
	{
		decl String:music[PLATFORM_MAX_PATH];
		MusicIndex=0;
		do
		{
			MusicIndex++;
			Format(music, 10, "time%i", MusicIndex);
		}
		while(KvGetFloat(BossKV[Special[0]], music, 0.0)>1);

		MusicIndex=GetRandomInt(1, MusicIndex-1);
		Format(music, 10, "time%i", MusicIndex);
		new Float:time=KvGetFloat(BossKV[Special[0]], music);
		Format(music, 10, "path%i", MusicIndex);
		KvGetString(BossKV[Special[0]], music, music, PLATFORM_MAX_PATH);

		new Action:action=Plugin_Continue;
		Call_StartForward(OnMusic);
		decl String:sound2[PLATFORM_MAX_PATH];
		new Float:time2=time;
		strcopy(sound2, PLATFORM_MAX_PATH, music);
		Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
		Call_PushFloatRef(time2);
		Call_Finish(action);
		switch(action)
		{
			case Plugin_Stop, Plugin_Handled:
			{
				strcopy(music, sizeof(music), "");
				time=-1.0;
			}
			case Plugin_Changed:
			{
				strcopy(music, PLATFORM_MAX_PATH, sound2);
				time=time2;
			}
		}

		if(strlen(music[0])>5)
		{
			if(!client)
			{
				EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, music);
			}
			else if(CheckSoundException(client, SOUNDEXCEPT_MUSIC))
			{
				EmitSoundToClient(client, music);
			}

			new userid;
			if(!client)
			{
				userid=0;
			}
			else
			{
				userid=GetClientUserId(client);
			}

			if(time>1)
			{
				MusicTimer=CreateTimer(time, Timer_MusicTheme, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Continue;
}

public Action:Timer_MusicTheme(Handle:timer, any:userid)
{
	MusicTimer=INVALID_HANDLE;
	if(Enabled && CheckRoundState()==FF2RoundState_RoundRunning)
	{
		KvRewind(BossKV[Special[0]]);
		if(KvJumpToKey(BossKV[Special[0]], "sound_bgm"))
		{
			new client=GetClientOfUserId(userid);
			new String:music[PLATFORM_MAX_PATH];
			MusicIndex=0;
			do
			{
				MusicIndex++;
				Format(music, 10, "time%i", MusicIndex);
			}
			while(KvGetFloat(BossKV[Special[0]], music)>1);

			MusicIndex=GetRandomInt(1, MusicIndex-1);
			Format(music, 10, "time%i", MusicIndex);
			new Float:time=KvGetFloat(BossKV[Special[0]], music);
			Format(music, 10, "path%i", MusicIndex);
			KvGetString(BossKV[Special[0]], music, music, PLATFORM_MAX_PATH);

			new Action:action=Plugin_Continue;
			Call_StartForward(OnMusic);
			new String:sound2[PLATFORM_MAX_PATH];
			new Float:time2=time;
			strcopy(sound2, PLATFORM_MAX_PATH, music);
			Call_PushStringEx(sound2, PLATFORM_MAX_PATH, 0, SM_PARAM_COPYBACK);
			Call_PushFloatRef(time2);
			Call_Finish(action);
			switch(action)
			{
				case Plugin_Stop, Plugin_Handled:
				{
					strcopy(music, sizeof(music), "");
					time=-1.0;
				}
				case Plugin_Changed:
				{
					strcopy(music, PLATFORM_MAX_PATH, sound2);
					time=time2;
				}
			}

			if(strlen(music[0])>5)
			{
				if(!client)
				{
					EmitSoundToAllExcept(SOUNDEXCEPT_MUSIC, music, _, _, _, _, _, _, _, _, _, false);
				}
				else if(CheckSoundException(client, SOUNDEXCEPT_MUSIC))
				{
					EmitSoundToClient(client, music);
				}

				if(time>1)
				{
					MusicTimer=CreateTimer(time, Timer_MusicTheme, userid, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock EmitSoundToAllExcept(exceptiontype=SOUNDEXCEPT_MUSIC, const String:sample[], entity=SOUND_FROM_PLAYER, channel=SNDCHAN_AUTO, level=SNDLEVEL_NORMAL, flags=SND_NOFLAGS, Float:volume=SNDVOL_NORMAL, pitch=SNDPITCH_NORMAL, speakerentity=-1, const Float:origin[3]=NULL_VECTOR, const Float:dir[3]=NULL_VECTOR, bool:updatePos=true, Float:soundtime=0.0)
{
	new clients[MaxClients], total;
	for(new client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && IsClientInGame(client))
		{
			if(CheckSoundException(client, exceptiontype))
			{
				clients[total++]=client;
			}
		}
	}

	if(!total)
	{
		return;
	}

	EmitSound(clients, total, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

stock CheckInfoCookies(client,infonum)
{
	if(!IsValidClient(client)) return false;
	if(IsFakeClient(client)) return true;
	if(!AreClientCookiesCached(client)) return true;
	new String:s[24];
	new String:ff2cookies_values[8][5];
	GetClientCookie(client, FF2Cookies, s, 24);
	ExplodeString(s, " ", ff2cookies_values,8,5);
	new see=StringToInt(ff2cookies_values[4+infonum]);
	return (see>0 ? see : 0);
}

stock SetInfoCookies(client,infonum,value)
{
	if(!IsValidClient(client)) return ;
	if(IsFakeClient(client)) return ;
	if(!AreClientCookiesCached(client)) return ;
	new String:s[24];
	new String:ff2cookies_values[8][5];
	GetClientCookie(client, FF2Cookies, s, 24);
	ExplodeString(s, " ", ff2cookies_values,8,5);
	Format(s,24,"%s %s %s %s",ff2cookies_values[0],ff2cookies_values[1],ff2cookies_values[2],ff2cookies_values[3]);
	for(new i;i<infonum;i++)
		Format(s,24,"%s %s",s,ff2cookies_values[4+i]);
	Format(s,24,"%s %i",s,value);
	for(new i=infonum+1;i<4;i++)
		Format(s,24,"%s %s",s,ff2cookies_values[4+i]);
	SetClientCookie(client, FF2Cookies, s);
}


stock bool:CheckSoundException(client, excepttype)
{
	if(!IsValidClient(client)) return false;
	if(IsFakeClient(client)) return true;
	if(!AreClientCookiesCached(client)) return true;
	new String:s[24];
	new String:ff2cookies_values[8][5];
	GetClientCookie(client, FF2Cookies, s, 24);
	ExplodeString(s, " ", ff2cookies_values,8,5);
	if(excepttype==SOUNDEXCEPT_VOICE)
		return StringToInt(ff2cookies_values[2])==1;
	return StringToInt(ff2cookies_values[1])==1;
}

SetClientSoundOptions(client, excepttype, bool:on)
{
	if(!IsValidClient(client) || IsFakeClient(client) || !AreClientCookiesCached(client))
	{
		return;
	}

	new String:s[24];
	new String:ff2cookies_values[8][5];
	GetClientCookie(client, FF2Cookies, s, 24);
	ExplodeString(s, " ", ff2cookies_values, 8, 5);
	if(excepttype==SOUNDEXCEPT_VOICE)
	{
		if(on)
		{
			ff2cookies_values[2][0]='1';
		}
		else
		{
			ff2cookies_values[2][0]='0';
		}
	}
	else
	{
		if(on)
		{
			ff2cookies_values[1][0]='1';
		}
		else
		{
			ff2cookies_values[1][0]='0';
		}
	}
	Format(s, 24, "%s %s %s %s %s %s %s %s", ff2cookies_values[0], ff2cookies_values[1], ff2cookies_values[2], ff2cookies_values[3], ff2cookies_values[4], ff2cookies_values[5], ff2cookies_values[6], ff2cookies_values[7]);
	SetClientCookie(client, FF2Cookies, s);
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

	SetMenuTitle(dMenu, "%t","ff2_boss_selection", xIncoming[client]);
	
	Format(boss, sizeof(boss), "%t", "to0_random");
	AddMenuItem(dMenu, boss, boss);
	
	Format(boss, sizeof(boss), "%t", "thequeue");
	AddMenuItem(dMenu, boss, boss);
	
	Format(boss, sizeof(boss), "%t", "to0_resetpts");
	AddMenuItem(dMenu, boss, boss);
	
	Format(boss, sizeof(boss), "%t", ClientCookie[client] == TOGGLE_OFF ? "to0_enablepts" : "to0_disablepts");
	AddMenuItem(dMenu, boss, boss);
	
	for(new config; config<Specials; config++)
	{	
		KvRewind(BossKV[config]);
		if(KvGetNum(BossKV[config], "blocked",0)) continue;
		
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
					return;
				}
				case 1: QueuePanelCmd(param1, 0);
				case 2: TurnToZeroPanel(param1, param1);
				case 3: BossMenu(param1, 0);
				default:
				{
					IsBossSelected[param1]=true;
					GetMenuItem(menu, param2, xIncoming[param1], sizeof(xIncoming[]));
					CReplyToCommand(param1, "%t", "to0_boss_selected", xIncoming[param1]);
				}
			}
		}
	}
	return;
}

public Action:FF2_OnSpecialSelected(boss, &SpecialNum, String:SpecialName[])
{
	if(AdminBossOverride)
	{	
		AdminBossOverride=false;
		return Plugin_Continue;
	}
	new client=GetClientOfUserId(FF2_GetBossUserId(boss));
	if (!boss && !StrEqual(xIncoming[client], ""))
	{
		strcopy(SpecialName, sizeof(xIncoming[]), xIncoming[client]);
		xIncoming[client] = "";
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock ShowGameText(const String:strMessage[]) 
{
	new iEntity = CreateEntityByName("game_text_tf");
	DispatchKeyValue(iEntity,"message", strMessage);
	DispatchKeyValue(iEntity,"display_to_team", "0");
	DispatchKeyValue(iEntity,"icon", (DeadRunMode == true ? "ico_ghost" : "ico_notify_sixty_seconds"));
	DispatchKeyValue(iEntity,"targetname", "game_text1");
	DispatchKeyValue(iEntity,"background", "0");
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "Display", iEntity, iEntity);
	CreateTimer(2.5, KillGameText, iEntity);
}

public Action:KillGameText(Handle:hTimer, any:iEntity) 
{
    if ((iEntity > 0) && IsValidEntity(iEntity))
		AcceptEntityInput(iEntity, "kill"); 
    return Plugin_Stop;
}

public Action:MakeModelTimer(Handle:timer, any:client)
{
	if(IsValidClient(Boss[client]) && IsPlayerAlive(Boss[client]) && CheckRoundState()!=FF2RoundState_RoundEnd)
	{
		new String:model[PLATFORM_MAX_PATH];
		KvRewind(BossKV[Special[client]]);
		KvGetString(BossKV[Special[client]], "model", model, PLATFORM_MAX_PATH);
		SetVariantString(model);
		AcceptEntityInput(Boss[client], "SetCustomModel");
		SetEntProp(Boss[client], Prop_Send, "m_bUseClassAnimations", 1);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

EquipBoss(boss)
{
	new client=Boss[boss];
	DoOverlay(client, "");
	TF2_RemoveAllWeapons(client);
	new String:weapon[64], String:attributes[768];
	
	for(new i=1; ; i++)
	{
		KvRewind(BossKV[Special[boss]]);
		Format(weapon, 10, "weapon%i", i);
		if(KvJumpToKey(BossKV[Special[boss]], weapon))
		{
			KvGetString(BossKV[Special[boss]], "name", weapon, sizeof(weapon));
			KvGetString(BossKV[Special[boss]], "attributes", attributes, sizeof(attributes));
			if(attributes[0]!='\0')
			{
				if(tf2attributes)
				{
					Format(attributes, sizeof(attributes), (!(FF2flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? (DeadRunMode == true ? "2 ; 2.1 ; %s" : "2 ; 3.1 ; %s") : "%s", attributes);
						//2: x3.1 damage
				}
				else
				{
					Format(attributes, sizeof(attributes), (!(FF2flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT)) ? (DeadRunMode == true ? "68 ; 2 ; 2 ; 2.1 ; %s" : "68 ; 2 ; 2 ; 3.1 ; %s") : "%s", attributes);
						//2: x3.1 damage
						//68: +2 cap					
				}
			}
			else
			{
				if(tf2attributes)
				{
					attributes=(DeadRunMode == true ? "2 ; 2.1 ; 2025 ; 2 ; 2014; 1" : "2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1");
						//2: x3.1 damage
						//2025 + 2014: Team Shine Specialized Killstreak
			
				}
				else
				{
					attributes=(DeadRunMode == true ? "68 ; 2 ; 2 ; 2.1 ; 2025 ; 2 ; 2014; 1" : "68 ; 2 ; 2 ; 3.1 ; 2025 ; 2 ; 2014 ; 1");
						//2: x3.1 damage
						//2025 + 2014: Team Shine Specialized Killstreak
						//68: +2 cap					
				}
			}
			new BossWeapon=SpawnWeapon(client, weapon, KvGetNum(BossKV[Special[boss]], "index"), 101, 5, attributes);
			
			if(KvGetNum(BossKV[Special[boss]], "ammo") || KvGetNum(BossKV[Special[boss]], "clip"))
			{
				FF2_SetAmmo(BossWeapon, KvGetNum(BossKV[Special[boss]], "ammo"), KvGetNum(BossKV[Special[boss]], "clip"));
			}
			
			if(!strcmp(weapon, "tf_weapon_builder"))
			{
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 0);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 1);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 2);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 3);
				Debug("Attaching toolbox netprops to boss's toolbox");
			}
			
			if(!strcmp(weapon, "tf_weapon_sapper"))
			{
				SetEntProp(BossWeapon, Prop_Send, "m_iObjectType", 3);
				SetEntProp(BossWeapon, Prop_Data, "m_iSubType", 3);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
				SetEntProp(BossWeapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
				Debug("Attaching sapper netprops to boss's sapper");
			}
			
			if(!KvGetNum(BossKV[Special[boss]], "show", 0))
			{
				SetEntProp(BossWeapon, Prop_Send, "m_iWorldModelIndex", -1);
				SetEntProp(BossWeapon, Prop_Send, "m_nModelIndexOverrides", -1, _, 0);
				SetEntPropFloat(BossWeapon, Prop_Send, "m_flModelScale", 0.001);
			}
			
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", BossWeapon);
		}
		else
		{
			break;
		}
	}

	#if defined _tf2attributes_included
	if(!(FF2flags[client] & FF2FLAG_DISABLE_WEAPON_MANAGEMENT) && tf2attributes)
	{
		TF2Attrib_SetByDefIndex(client, 259, 1.0);  // Mantreads Stomp
		TF2Attrib_SetByDefIndex(client, 68, (TF2_GetPlayerClass(client) == TFClass_Scout ? 1.0 : 2.0));  // +1 x cap rate ? +2x cap rate?
		TF2Attrib_SetByDefIndex(client, 135, 0.0);
		TF2Attrib_SetByDefIndex(client, 181, 1.0);
	}
	#endif
	
	KvGoBack(BossKV[Special[boss]]);
	new TFClassType:class=TFClassType:KvGetNum(BossKV[Special[boss]], "class", 1);
	if(TF2_GetPlayerClass(client)!=class)
	{
		TF2_SetPlayerClass(client, class, _, false);
	}
}

stock bool:IsLivingSpectator(client)
{
	new SpecMode=GetEntProp(client, Prop_Send, "m_iObserverMode");
	
	if(SpecMode < 4 || SpecMode > 6)
	{
		Debug("Client %N is not a spectator", client);
		return false;
	}
	
	if(!IsPlayerAlive(client))
	{
		Debug("Client %N is not alive", client);
		return false;
	}
	Debug("Client %N is a living spectator", client);
	return true;
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

	if(GetClientTeam(client)!=BossTeam) // No Living Spectators Pls
	{
		AssignTeam(client, BossTeam);
	}
	
	IsBossSelected[client]=false;
	dmgTriple[client]=true;
	SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);
	KvRewind(BossKV[Special[boss]]);
	TF2_RemovePlayerDisguise(client);
	TF2_SetPlayerClass(client, TFClassType:KvGetNum(BossKV[Special[boss]], "class", 1), _, false);
	SDKHook(client, SDKHook_GetMaxHealth, OnGetMaxHealth);  //Temporary:  Used to prevent boss overheal

	switch(KvGetNum(BossKV[Special[boss]], "pickups", 0))  //Check if the boss is allowed to pickup health/ammo
	{
		case 1:
		{
			FF2flags[client]|=FF2FLAG_ALLOW_HEALTH_PICKUPS;
		}
		case 2:
		{
			FF2flags[client]|=FF2FLAG_ALLOW_AMMO_PICKUPS;
		}
		case 3:
		{
			FF2flags[client]|=FF2FLAG_ALLOW_HEALTH_PICKUPS|FF2FLAG_ALLOW_AMMO_PICKUPS;
		}
	}
	
	switch(KvGetNum(BossKV[Special[boss]], "overrides", 0))
	{
		case 1: // Disable Speed Management
		{
			FF2flags[client]|=FF2FLAG_DISABLE_SPEED_MANAGEMENT;
		}
		case 2: // Disable Weapon Management
		{
			FF2flags[client]|=FF2FLAG_DISABLE_WEAPON_MANAGEMENT;
		}
	}
	
	if(KvGetNum(BossKV[Special[boss]], "subversion")>=31)
	{
		dmgTriple[client]=false;
	}

	if(!HasSwitched)
	{
		switch(KvGetNum(BossKV[Special[boss]], "bossteam", 0))
		{
			case 1: // Always Random
			{			
				new currentBossTeam=GetRandomInt(1,2);
				FF2_SwitchTeams((currentBossTeam==1) ? (_:TFTeam_Blue) : (_:TFTeam_Red) , (currentBossTeam==1) ? (_:TFTeam_Red) : (_:TFTeam_Blue), true);
			}
			case 2: // RED Boss
			{
				FF2_SwitchTeams(_:TFTeam_Red, _:TFTeam_Blue, true);
			}
			case 3: // BLU Boss
			{
				FF2_SwitchTeams(_:TFTeam_Blue, _:TFTeam_Red, true);
			}
			default: // Determined by "ff2_force_team" ConVar
			{
				FF2_SwitchTeams((blueBoss) ? (_:TFTeam_Blue) : (_:TFTeam_Red), (blueBoss) ? (_:TFTeam_Red) : (_:TFTeam_Blue), true);
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
	while((entity=FindEntityByClassname2(entity, "tf_wearable"))!=-1)
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

	entity=-1;
	while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)
	{
		if(IsBoss(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")))
		{
			TF2_RemoveWearable(client, entity);
		}
	}

	entity=-1;
	while((entity=FindEntityByClassname2(entity, "tf_usableitem"))!=-1)
	{
		if(IsBoss(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")))
		{
			switch(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"))
			{
				case 438, 463, 167, 477, 493, 233, 234, 241, 280, 281, 282, 283, 284, 286, 288, 362, 364, 365, 536, 542:  //Action slot items
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

	EquipBoss(boss);
	KSpreeCount[boss]=0;
	BossCharge[boss][0]=0.0;
	if(DeadRunMode && IsPreparing)
	{
		drboss=boss;
		SetEntityMoveType(client, MOVETYPE_NONE);
	}

	if(IsLivingSpectator(client))
	{
		TF2_RespawnPlayer(client);
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

SearchForItemPacks()
{
	new bool:foundAmmo = false, bool:foundHealth = false;
	new ent = -1;
	decl Float:pos[3];
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);

        if (Enabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            new ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", 0, 4);
            foundAmmo = true;
        }
        
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);

        if (Enabled)
        {
            GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
            AcceptEntityInput(ent, "Kill");
            new ent2 = CreateEntityByName("item_ammopack_small");
            TeleportEntity(ent2, pos, NULL_VECTOR, NULL_VECTOR);
            DispatchSpawn(ent2);
            SetEntProp(ent2, Prop_Send, "m_iTeamNum", 0, 4);
        }
        
        foundAmmo = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "Item_ammopack_small")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundAmmo = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
	{
        SetEntProp(ent, Prop_Send, "m_iTeamNum", 0, 4);
        foundHealth = true;
	}
	if (!foundAmmo) SpawnRandomAmmo();
	if (!foundHealth) SpawnRandomHealth();
}

SpawnRandomAmmo()
{
    new iEnt = MaxClients + 1;
    decl Float:vPos[3];
    decl Float:vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
        {
            continue;
        }

        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

        new iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_ammopack_medium") : CreateEntityByName("item_ammopack_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
    }
}

SpawnRandomHealth()
{
    new iEnt = MaxClients + 1;
    decl Float:vPos[3];
    decl Float:vAng[3];
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        if (GetRandomInt(0, 4))
        {
            continue;
        }

        // Technically you'll never find a map without a spawn point.
        GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vPos);
        GetEntPropVector(iEnt, Prop_Send, "m_angRotation", vAng);

        new iEnt2 = !GetRandomInt(0, 3) ? CreateEntityByName("item_healthkit_medium") : CreateEntityByName("item_healthkit_small");
        TeleportEntity(iEnt2, vPos, vAng, NULL_VECTOR);
        DispatchSpawn(iEnt2);
        SetEntProp(iEnt2, Prop_Send, "m_iTeamNum", 0, 4);
    }
}

/*
    TeleportToMultiMapSpawn()

    [X][2]
       [0] = RED spawnpoint entref
       [1] = BLU spawnpoint entref
*/
static ArrayList s_hSpawnArray = null;

stock void OnPluginStart_TeleportToMultiMapSpawn()
{
    s_hSpawnArray = new ArrayList(2);
}

stock void teamplay_round_start_TeleportToMultiMapSpawn()
{
    s_hSpawnArray.Clear();
    int iInt = 0, iSkip[TF_MAX_PLAYERS] = {0,...}, iEnt = MaxClients + 1;
    while ((iEnt = FindEntityByClassname2(iEnt, "info_player_teamspawn")) != -1)
    {
        TFTeam iTeam = GetEntityTeamNum(iEnt);
        int iClient = GetClosestPlayerTo(iEnt, iTeam);
        if (iClient)
        {
            bool bSkip = false;
            for (int i = 0; i < TF_MAX_PLAYERS; i++)
            {
                if (iSkip[i] == iClient)
                {
                    bSkip = true;
                    break;
                }
            }
            if (bSkip)
                continue;
            iSkip[iInt++] = iClient;
            int iIndex = s_hSpawnArray.Push(EntIndexToEntRef(iEnt));
            s_hSpawnArray.Set(iIndex, iTeam, 1);       // Opposite team becomes an invalid ent
            //CPrintToChdata("spawn %i near %N added to team %i", iEnt, iClient, iTeam);
        }
    }
}

/*
    Teleports a client to spawn, but only if it's a spawn that someone spawned in at the start of the round.

    Useful for multi-stage maps like vsh_megaman
*/
stock int TeleportToMultiMapSpawn(int iClient, TFTeam iTeam = TFTeam_Unassigned)
{
    int iSpawn, iIndex;
    TFTeam iTeleTeam;
    if (iTeam <= TFTeam_Spectator)
        iSpawn = EntRefToEntIndex(GetRandBlockCellEx(s_hSpawnArray));
    else
    {
        do
            iTeleTeam = view_as<TFTeam>(GetRandBlockCell(s_hSpawnArray, iIndex, 1));
        while (iTeleTeam != iTeam);
        iSpawn = EntRefToEntIndex(GetArrayCell(s_hSpawnArray, iIndex, 0));
    }
    TeleMeToYou(iClient, iSpawn);
    return iSpawn;
}

/*
    Returns 0 if no client was found.
*/
stock int GetClosestPlayerTo(int iEnt, TFTeam iTeam = TFTeam_Unassigned)
{
    int iBest;
    float flDist, flTemp, vLoc[3], vPos[3];
    GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", vLoc);
    for(int iClient = 1; iClient <= MaxClients; iClient++)
    {
        if (IsClientInGame(iClient) && IsPlayerAlive(iClient))
        {
            if (iTeam > TFTeam_Unassigned && GetEntityTeamNum(iClient) != iTeam)
                continue;
            GetEntPropVector(iClient, Prop_Send, "m_vecOrigin", vPos);
            flTemp = GetVectorDistance(vLoc, vPos);
            if (!iBest || flTemp < flDist)
            {
                flDist = flTemp;
                iBest = iClient;
            }
        }
    }
    return iBest;
}

/*
    Teleports one entity to another.
    Doesn't necessarily have to be players.

    Returns true if a player teleported to a ducking player
*/
stock bool TeleMeToYou(int iMe, int iYou, bool bAngles = false)
{
    float vPos[3], vAng[3];
    vAng = NULL_VECTOR;
    GetEntPropVector(iYou, Prop_Send, "m_vecOrigin", vPos);
    if (bAngles)
        GetEntPropVector(iYou, Prop_Send, "m_angRotation", vAng);
    bool bDucked = false;
    if (IsValidClient(iMe) && IsValidClient(iYou) && GetEntProp(iYou, Prop_Send, "m_bDucked"))
    {
        float vCollisionVec[3];
        vCollisionVec[0] = 24.0;
        vCollisionVec[1] = 24.0;
        vCollisionVec[2] = 62.0;
        SetEntPropVector(iMe, Prop_Send, "m_vecMaxs", vCollisionVec);
        SetEntProp(iMe, Prop_Send, "m_bDucked", 1);
        SetEntityFlags(iMe, GetEntityFlags(iMe) | FL_DUCKING);
        bDucked = true;
    }
    TeleportEntity(iMe, vPos, vAng, NULL_VECTOR);
    return bDucked;
}

stock int GetRandBlockCell(ArrayList hArray, int &iSaveIndex, int iBlock = 0, bool bAsChar = false, int iDefault = 0)
{
    int iSize = hArray.Length;
    if (iSize > 0)
    {
        iSaveIndex = GetRandomInt(0, iSize - 1);
        return hArray.Get(iSaveIndex, iBlock, bAsChar);
    }
    iSaveIndex = -1;
    return iDefault;
}

// Get a random value while ignoring the save index.
stock int GetRandBlockCellEx(ArrayList hArray, int iBlock = 0, bool bAsChar = false, int iDefault = 0)
{
    int iIndex;
    return GetRandBlockCell(hArray, iIndex, iBlock, bAsChar, iDefault);
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname,int iItemDefinitionIndex, Handle &item)
{
	if(!Enabled || !IsValidClient(client))
	{
		return Plugin_Continue;
	}

	bool SwordCanCountHeads=false;
	switch(iItemDefinitionIndex)
	{
			
		case 17, 204, 412:  //Syringe Gun, Strange Syringe Gun, Overdose
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "17 ; 0.05 ; 144 ; 1");
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 25, 737:  //Build PDA
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "276 ; 1 ; 345 ; 2.5");
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 36: // Blutsauger
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "16 ; 1 ; 17 ; 0.01 ; 129 ; -2 ; 144 ; 1", true);
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}		
		}
		case 38, 457:  //Axtinguisher, Postal Pummeler
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "", true);
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 39, 351, 740 , 1081:  //Flaregun, Detonator, Scorch Shot, Festive Flaregun, 
		{
			Handle itemOverride;
			if(DeadRunMode)
				itemOverride=PrepareItemHandle(item, _, _, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0", true);
			else
				itemOverride=PrepareItemHandle(item, _, _, "25 ; 0.5 ; 58 ; 3.2 ; 144 ; 1.0 ; 207 ; 1.33", true);
					//25: -50% ammo
					//58: 220% self damage force
					//144: NOPE
					//207: +33% damage to self			
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 40, 1146:  //Backburner, Festive Backburner
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "165 ; 1.0");
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}		
		case 224:  //L'etranger
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "85 ; 0.5 ; 157 ; 1.0 ; 253 ; 1.0");
				//85: +50% time needed to regen cloak
				//157: +1 second needed to fully disguise
				//253: +1 second needed to fully cloak
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 43, 239, 1084, 1100:  //KGB, GRU, Festive GRU, Bread Bite
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "1 ; 0.5 ; 107 ; 1.5 ; 128 ; 1 ; 191 ; -7", true);
				//1: -50% damage
				//107: +50% move speed
				//128: Only when weapon is active
				//191: -7 health/second
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 237, 265: // Rocket & Sticky Jumper
		{
			if(!DeadRunMode)
			{
				Handle itemOverride=PrepareItemHandle(item, _, _, "58 ; 1.75 ; 265 ; 99999.0", true); 
				if(itemOverride!=null)
				{
					item=itemOverride;
					return Plugin_Changed;
				}
			}
		}
		case 56, 1005, 1092:  //Huntsman, Festive Huntsman, Fortified Compound
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.5 ; 76 ; 2");
				//2: +50% damage
				//76: +100% ammo
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 60: // Cloak and Dagger
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "253 ; -1 ; 728 ; 1 ; 83 ; 0.25 ; 85 ; 0.75", true);
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 154: // Pain Train
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.25 ; 149 ; 5.0 ; 204 ; 1", false);
				//2: +25% damage
				//149: On Hit: Bleed for 5 seconds
				//204: On Miss: Hit yourself. Idiot.
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 220:  //Shortstop
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "128 ; 0 ; 241 ; 1", true);
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 226:  //Battalion's Backup
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "140 ; 10.0");
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 231:  //Darwin's Danger Shield
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "26 ; 50");  //+50 health
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 331:  //Fists of Steel
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "177 ; 1.2 ; 205 ; 0.8 ; 206 ; 2.0", true);
				//177: +20% slower weapon switch
				//205: -80% damage from ranged while active
				//206: +100% damage from melee while active
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}	
		}
		case 349: // Sun-on-a-stick
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "204 ; 1 ; 208 ; 1", false);
				//204: On-miss; Hit yourself, idiot
				//208: Ignite player on-hit
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}		
		
		}
		case 415:  //Reserve Shooter
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "265 ; 99999.0 ; 178 ; 0.6 ; 179 ; 1 ; 2 ; 1.1 ; 3 ; 0.5", true);
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 444:  //Mantreads
		{
			#if defined _tf2attributes_included
			if(tf2attributes)
			{
				TF2Attrib_SetByDefIndex(client, 58, 1.5);
			}
			#endif
		}
		case 133: // Gunboats
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "259 ; 1", false);
				//259: Deal 3x fall damage
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}	
		}
		case 648:  //Wrap Assassin
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "279 ; 2.0");
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 656:  //Holiday Punch
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "178 ; 0", true);
				//178:  +100% faster weapon switch
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 772:  //Baby Face's Blaster 
		{ 
			if(!DeadRunMode)
			{
				Handle itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.25 ; 125 ; -25 ; 109 ; 0.5 ; 394 ; 0.85 ; 418 ; 1 ; 419 ; 1 ; 532 ; 0.5 ; 651 ; 0.5 ; 709 ; 1", true); 
					//2: +25% damage bonus 
					//125: -25 max health 
					//109: -50% health from packs on wearer 
					//394: 15% firing speed bonus hidden
					//418: Build hype for faster speed 
					//419: Hype resets on jump 
					//532: Hype decays 
					//651: Fire rate increases as health decreases
					//709: Weapon spread increases as health decreases
				if(itemOverride!=null) 
				{ 
					item=itemOverride; 
					return Plugin_Changed; 
				}
			}
		}
		case 1103:  //Back Scatter
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "179 ; 1");
				//179: Crit instead of mini-critting
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}
		case 41: // Natascha
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "1 ; 0.75 ; 32 ; 1.25 ; 76 ; 1.5 ; 86 ; 1.3 ; 206 ; 1.5", true);
				//1: -25% damage penalty
				//32: 25% chance to slow target
				//76: 50% more primary ammo
				//86: 30% slower spinup time
				//206: 50% more damage from melee sources
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}
		}		
		// Reverting some Valve weapon changes:
		case 132, 266, 482, 1082:
		{
			SwordCanCountHeads=true;
			return Plugin_Continue;
		}
		
		case 308: // Loch-n-load
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.25", false);
						//2: 25% damage bonus
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}			
		}
		case 405, 608:  //Ali Baba's Wee Booties, Bootlegger
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, !SwordCanCountHeads ? "259 ; 1" : "26 ; 25 ; 246 ; 2 ; 259 ; 1 ; 2034 ; 1.25", !SwordCanCountHeads ? false : true);
				//259: Deal 3x fall damage
				//If Headtaker, Nine Iron or Eyelander is equipped, nerf move speed bonus
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}		
		}
		case 460: // Enforcer
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "5 ; 1.20 ; 15 ; 1 ; 20 ; 1 ; 407 ; 1 ; 437 ; 1 ; 438 ; 1", true);
				//15: No Random Crits
				//5: 20% slower firing speed
				//20, 407, 437, 438: Crits vs disguised/burning/wet/stunned players
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}			
		}
		case 773: // Pocket Pistol
		{
			Handle itemOverride=PrepareItemHandle(item, _, _, "26 ; 15", false);
				//26: +15 HP
			if(itemOverride!=null)
			{
				item=itemOverride;
				return Plugin_Changed;
			}	
		}
	}
			
	if(!StrContains(classname, "tf_weapon_medigun") && (iItemDefinitionIndex!=35 || iItemDefinitionIndex!=411 || iItemDefinitionIndex!=998))  //Kritzkrieg, Quick Fix, Vaccinator
	{
		new Handle:itemOverride=PrepareItemHandle(item, _, _, "10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5");
			//10: +25% faster charge rate
			//178: +25% faster weapon switch
			//144: Quick-fix speed/jump effects
			//11: +50% overheal bonus
		if(itemOverride!=INVALID_HANDLE)
		{
			item=itemOverride;
			return Plugin_Changed;
		}
	}
		
	if(!StrContains(classname, "tf_weapon_crossbow"))
	{
		Handle itemOverride=PrepareItemHandle(item, _, _, "2 ; 1.2 ; 17 ; 0.15");
				//2: +20% damage
				//17: +15% uber on hit
		if(itemOverride!=null)
		{
			item=itemOverride;
			return Plugin_Changed;
		}		
	}

	if(!StrContains(classname, "tf_weapon_flamethrower") && (iItemDefinitionIndex != 40 || iItemDefinitionIndex != 1146 || iItemDefinitionIndex != 594))
	{
		Handle itemOverride=PrepareItemHandle(item, _, _, "170 ; 1.25", false); 
		if(itemOverride!=null)
		{
			item=itemOverride;
			return Plugin_Changed;
		}
	}
	
	if(TF2_GetPlayerClass(client)==TFClass_Soldier && (!StrContains(classname, "tf_weapon_rocketlauncher", false) || !StrContains(classname, "tf_weapon_shotgun", false)))
	{
		new Handle:itemOverride;
		if(iItemDefinitionIndex==127)  //Direct Hit
		{
			itemOverride=PrepareItemHandle(item, _, _, "265 ; 99999.0 ; 179 ; 1.0");
		}
		else
		{
			itemOverride=PrepareItemHandle(item, _, _, "265 ; 99999.0");
		}

		if(itemOverride!=INVALID_HANDLE)
		{
			item=itemOverride;
			return Plugin_Changed;
		}
	}
	
	if(((!StrContains(classname,"tf_weapon_rocketlauncher") || !StrContains(classname,"tf_weapon_particle_cannon") || !StrContains(classname,"tf_weapon_pipebomblauncher"))) && DeadRunMode)
	{
		switch(iItemDefinitionIndex)
		{
			case 237, 265: // Rocket & Sticky Jumper
			{
				Handle itemOverride=PrepareItemHandle(item, _, _, "59 ; 0.5 ; 100 ; 0.3 ; 103 ; 2.5 ; 207 ; 2", true); 
				if(itemOverride!=null)
				{
					item=itemOverride;
					return Plugin_Changed;
				}
			}
			default: // All others
			{
				Handle itemOverride=PrepareItemHandle(item, _, _, "59 ; 0.5 ; 100 ; 0.3 ; 103 ; 2.5 ; 207 ; 2", false); 
				if(itemOverride!=null)
				{
					item=itemOverride;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_NoHonorBound(Handle timer, any userid)
{
	int client=GetClientOfUserId(userid);
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		int melee=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index=((IsValidEntity(melee) && melee>MaxClients) ? GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") : -1);
		int weapon=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64];
		if(IsValidEdict(weapon))
		{
			GetEdictClassname(weapon, classname, sizeof(classname));
		}
		if(index==357 && weapon==melee && !strcmp(classname, "tf_weapon_katana", false))
		{
			SetEntProp(melee, Prop_Send, "m_bIsBloody", 1);
			if(GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy")<1)
			{
				SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
			}
		}
	}
}

stock Handle:PrepareItemHandle(Handle:item, String:name[]="", index=-1, const String:att[]="", bool:dontPreserve=false)
{
	static Handle:weapon;
	new addattribs;

	new String:weaponAttribsArray[32][32];
	new attribCount=ExplodeString(att, ";", weaponAttribsArray, 32, 32);

	if(attribCount % 2)
	{
		--attribCount;
	}

	new flags=OVERRIDE_ATTRIBUTES;
	if(!dontPreserve)
	{
		flags|=PRESERVE_ATTRIBUTES;
	}

	if(weapon==INVALID_HANDLE)
	{
		weapon=TF2Items_CreateItem(flags);
	}
	else
	{
		TF2Items_SetFlags(weapon, flags);
	}
	//new Handle:weapon=TF2Items_CreateItem(flags);  //INVALID_HANDLE;  Going to uncomment this since this is what Randomizer does

	if(item!=INVALID_HANDLE)
	{
		addattribs=TF2Items_GetNumAttributes(item);
		if(addattribs>0)
		{
			for(new i; i<2*addattribs; i+=2)
			{
				new bool:dontAdd=false;
				new attribIndex=TF2Items_GetAttributeId(item, i);
				for(new z; z<attribCount+i; z+=2)
				{
					if(StringToInt(weaponAttribsArray[z])==attribIndex)
					{
						dontAdd=true;
						break;
					}
				}

				if(!dontAdd)
				{
					IntToString(attribIndex, weaponAttribsArray[i+attribCount], 32);
					FloatToString(TF2Items_GetAttributeValue(item, i), weaponAttribsArray[i+1+attribCount], 32);
				}
			}
			attribCount+=2*addattribs;
		}

		if(weapon!=item)  //FlaminSarge: Item might be equal to weapon, so closing item's handle would also close weapon's
		{
			CloseHandle(item);  //probably returns false but whatever (rswallen-apparently not)
		}
	}

	if(name[0]!='\0')
	{
		flags|=OVERRIDE_CLASSNAME;
		TF2Items_SetClassname(weapon, name);
	}

	if(index!=-1)
	{
		flags|=OVERRIDE_ITEM_DEF;
		TF2Items_SetItemIndex(weapon, index);
	}

	if(attribCount>0)
	{
		TF2Items_SetNumAttributes(weapon, attribCount/2);
		new i2;
		for(new i; i<attribCount && i2<16; i+=2)
		{
			new attrib=StringToInt(weaponAttribsArray[i]);
			if(!attrib)
			{
				LogError("Bad weapon attribute passed: %s ; %s", weaponAttribsArray[i], weaponAttribsArray[i+1]);
				CloseHandle(weapon);
				return INVALID_HANDLE;
			}

			TF2Items_SetAttribute(weapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(weapon, 0);
	}
	TF2Items_SetFlags(weapon, flags);
	return weapon;
}

public Action:MakeNotBoss(Handle:timer, any:userid)
{
	Debug("MakeNotBoss Fired");
	new client=GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client) || CheckRoundState()==FF2RoundState_RoundEnd || IsBoss(client) || (FF2flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
	{
		return Plugin_Continue;
	}

	if(!IsVoteInProgress() && GetClientClassinfoCookie(client) && !(FF2flags[client] & FF2FLAG_CLASSHELPED))
	{
		HelpPanelClass(client);
	}

	SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0);

	SetEntProp(client, Prop_Send, "m_iHealth", GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client));  //Temporary: Reset health to avoid an overhealh bug
	SetEntProp(client, Prop_Data, "m_iHealth", GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client));
	if(GetClientTeam(client)!=MercTeam)
	{
		AssignTeam(client, MercTeam);
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
			SetEntityMoveType(client, MOVETYPE_NONE);
	}
	
	if(DeadRunMode && IsPreparing)
		SetEntityMoveType(client, MOVETYPE_NONE);

	CreateTimer(0.1, CheckItems, client);
	return Plugin_Continue;
}

public Action:CheckItems(Handle:timer, any:client)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client) || CheckRoundState()==FF2RoundState_RoundEnd || IsBoss(client) || (FF2flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
	{
		return Plugin_Continue;
	}

	SetEntityRenderColor(client, 255, 255, 255, 255);
	shield[client]=0;
	new weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	new index=-1;
	new civilianCheck[MAXPLAYERS+1];

	if(DeadRunMode && TF2_GetPlayerClass(client)==TFClass_Spy)
	{
		TF2_RemoveWeaponSlot(client, 4);
	}
	
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 15, 202, 298, 312, 424, 654, 793, 802, 811, 850, 882, 891, 900, 909, 958, 967: // All Miniguns
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
				}		
			}
			case 402:  //Bazaar Bargain
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_sniperrifle", 14, 1, 0, "");
			}
			case 448, 772: // Soda Popper, Baby Face's Blaster
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_scattergun", 13, 1, 0, "");	
				}
			}
		}
	}
	else
	{
		civilianCheck[client]++;
	}

	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 140, 1086: // Wranglers
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					SpawnWeapon(client, "tf_weapon_pistol", 22, 1, 0, "");
				}			
			
			}
			case 735, 736, 810, 831, 1080, 1102: // Sappers
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));					
				}
			}

		}

		if(TF2_GetPlayerClass(client)==TFClass_Medic && GetEntProp(weapon, Prop_Send, "m_iEntityQuality")!=10)  //10 means the weapon is customized, so we don't want to touch those
		{
			switch(index)
			{
				case 35, 411, 998:  //Kritzkrieg, Quick Fix, Vaccinator
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_medigun", 29, 5, 10, "10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5");
						//Switch to regular medigun
						//10: +25% faster charge rate
						//178: +25% faster weapon switch
						//144: Quick-fix speed/jump effects
						//11: +50% overheal bonus
				}
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.40);

			if(GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee)==142)  //Gunslinger (Randomizer, etc. compatability)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, 75);
			}
		}
	}
	else
	{
		civilianCheck[client]++;
	}
	
	new playerBack=FindPlayerBack(client, 57);  //Razorback
	shield[client]=playerBack!=-1 ? playerBack : 0;
	if(IsValidEntity(FindPlayerBack(client, 642)))  //Cozy Camper
	{
		weapon=SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85");
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

	new entity=-1;
	while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)  //Demoshields
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
		{
			shield[client]=entity;
		}
	}

	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 304: // Amputator
			{
				if(DeadRunMode && TF2_GetPlayerClass(client)==TFClass_Medic)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, TFWeaponSlot_Melee));
				}
			}
			case 307: // Ullapool Caber
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					weapon=SpawnWeapon(client, "tf_weapon_bottle", 1, 1, 0, "");
				}
			}
			case 325, 450, 452: // Atomizer, Boston Basher, Three-Rune Blade
			{
				if(DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					weapon=SpawnWeapon(client, "tf_weapon_bat", 0, 1, 0, "");
				}
			}
			case 357:  //Half-Zatoichi
			{
				CreateTimer(1.0, Timer_NoHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			case 589:  //Eureka Effect
			{
				if(!GetConVarBool(cvarEnableEurekaEffect) || DeadRunMode)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					weapon=SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	else
	{
		civilianCheck[client]++;
	}
	
	if(DeadRunMode)
	{
		weapon=GetPlayerWeaponSlot(client, 3);
		if(weapon && IsValidEdict(weapon))
		{
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 25, 737:
					TF2_RemoveWeaponSlot(client, 3);
			}
		}	

		weapon=GetPlayerWeaponSlot(client, 4);
		if(weapon && IsValidEdict(weapon))
		{
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 26:
					TF2_RemoveWeaponSlot(client, 4);
			}
		}	
	
		weapon=GetPlayerWeaponSlot(client, 5);
		if(weapon && IsValidEdict(weapon))
		{
			index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			switch(index)
			{
				case 28:
					TF2_RemoveWeaponSlot(client, 5);
			}
		}	
	
		else
		{
			civilianCheck[client]++;
		}
	}

	if(TF2_GetPlayerClass(client)==TFClass_Medic)
	{
		weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		new mediquality=(weapon>MaxClients && IsValidEdict(weapon) ? GetEntProp(weapon, Prop_Send, "m_iEntityQuality") : -1);
		if(mediquality!=10)
		{
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.40);
			
			if(GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee)==142)  //Gunslinger (Randomizer, etc. compatability)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, 75);
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.40);
		}
	}

	if(civilianCheck[client]==3)
	{
		civilianCheck[client]=0;
		CPrintToChat(client, "{olive}[FF2]{default} %t", "Civilian Check Failed");
		TF2_RespawnPlayer(client);
	}
	civilianCheck[client]=0;
	
	if(IsLivingSpectator(client))
	{
		TF2_RespawnPlayer(client);
	}

	return Plugin_Continue;
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

public Action:Event_Destroy(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(Enabled)
	{
		new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
		if(!GetRandomInt(0, 2) && IsBoss(attacker))
		{
			new String:sound[PLATFORM_MAX_PATH];
			if(RandomSound("sound_kill_buildable", sound, PLATFORM_MAX_PATH))
			{
				EmitSoundToAll(sound);
				EmitSoundToAll(sound);
			}
		}
	}
	return Plugin_Continue;
}

public Action:Event_Uber(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	if(Enabled && IsValidClient(client) && IsPlayerAlive(client))
	{
		new medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if(IsValidEntity(medigun))
		{
			new String:classname[64];
			GetEdictClassname(medigun, classname, sizeof(classname));
			if(!strcmp(classname, "tf_weapon_medigun"))
			{
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
				new target=GetHealingTarget(client);
				if(IsValidClient(target, false) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
					uberTarget[client]=target;
				}
				else
				{
					uberTarget[client]=-1;
				}
				SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.50);
				CreateTimer(0.4, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	return Plugin_Continue;
}

public Action:Timer_Uber(Handle:timer, any:medigunid)
{
	new medigun=EntRefToEntIndex(medigunid);
	if(medigun && IsValidEntity(medigun) && CheckRoundState()==FF2RoundState_RoundRunning)
	{
		new client=GetEntPropEnt(medigun, Prop_Send, "m_hOwnerEntity");
		new Float:charge=GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
		if(IsValidClient(client, false) && IsPlayerAlive(client) && GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")==medigun)
		{
			new target=GetHealingTarget(client);
			if(charge>0.05)
			{
				TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5);
				if(IsValidClient(target, false) && IsPlayerAlive(target))
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
			FF2flags[client]&=~FF2FLAG_UBERREADY;
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
		new String:lives[4], String:name[64];
		for(new target; target<=MaxClients; target++)
		{
			if(IsBoss(target))
			{
				new boss=Boss[target];
				KvRewind(BossKV[Special[boss]]);
				KvGetString(BossKV[Special[boss]], "name", name, sizeof(name), "=Failed name=");
				if(BossLives[boss]>1)
				{
					Format(lives, sizeof(lives), "x%i", BossLives[boss]);
				}
				else
				{
					strcopy(lives, 2, "");
				}
				
				if(!HasCompanions)
				{
					Format(health, sizeof(health), "%s\n%t\n", health, "ff2_hp", name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
					ShowGameText(health);
				}
				else
					Format(health, sizeof(health), "%s\n%t", health, "ff2_hp", name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
	
				CPrintToChatAll("{olive}[FF2]{default} %t", "ff2_hp", name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), BossHealthMax[boss], lives);
				BossHealthLast[boss]=BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1);
			}
		}

		for(new target; target<=MaxClients; target++)
		{
			if(IsValidClient(target) && !(FF2flags[target] & FF2FLAG_HUDDISABLED) && HasCompanions)
			{
				SetGlobalTransTarget(target);
				PrintCenterText(target, health);
			}
		}

		if(GetGameTime()>=HPTime)
		{
			healthcheckused++;
			HPTime=GetGameTime()+(healthcheckused<3 ? 20.0 : 80.0);
		}
		return Plugin_Continue;
	}

	if(AliveMercPlayers>1)
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

	if(args<1)
	{
		CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_special <boss>");
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
			AdminBossOverride=true;
			return Plugin_Handled;
		}

		KvGetString(BossKV[config], "filename", boss, sizeof(boss));
		if(StrContains(boss, name, false)!=-1)
		{
			Incoming[0]=config;
			KvGetString(BossKV[config], "name", boss, sizeof(boss));
			CReplyToCommand(client, "{olive}[FF2]{default} Set the next boss to %s", boss);
			AdminBossOverride=true;
			return Plugin_Handled;
		}
	}
	CReplyToCommand(client, "{olive}[FF2]{default} Boss could not be found!");
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

public Action:Command_StopMusic(client, args)
{
	if(Enabled2)
	{
		if(args)
		{
			decl String:pattern[MAX_TARGET_LENGTH];
			GetCmdArg(1, pattern, sizeof(pattern));
			new String:targetName[MAX_TARGET_LENGTH];
			new targets[MAXPLAYERS], matches;
			new bool:targetNounIsMultiLanguage;
			if((matches=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage))<=0)
			{
				ReplyToTargetError(client, matches);
				return Plugin_Handled;
			}

			if(matches>1)
			{
				for(new target; target<matches; target++)
				{
					StopMusic(targets[target]);
				}
			}
			else
			{
				StopMusic(targets[0]);
			}
			CReplyToCommand(client, "{olive}[FF2]{default} Stopped boss music for %s.", targetName);
		}
		else
		{
			StopMusic();
			CReplyToCommand(client, "{olive}[FF2]{default} Stopped boss music for all clients.");
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

StopMusic(target=0)
{
	if(!BossKV[Special[0]])
	{
		return;
	}

	KvRewind(BossKV[Special[0]]);
	if(KvJumpToKey(BossKV[Special[0]], "sound_bgm"))
	{
		decl String:music[PLATFORM_MAX_PATH];
		Format(music, sizeof(music), "path%i", MusicIndex);
		KvGetString(BossKV[Special[0]], music, music, sizeof(music));

		if(!target || target<0)  //Stop music for all clients
		{
			for(target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target))
				{
					StopSound(target, SNDCHAN_AUTO, music);
					StopSound(target, SNDCHAN_AUTO, music);
				}
			}
		}
		else
		{
			StopSound(target, SNDCHAN_AUTO, music);
			StopSound(target, SNDCHAN_AUTO, music);
		}
	}
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
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/characters.cfg");

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
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/characters.cfg");

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
				CReplyToCommand(client, "{olive}[FF2]{default} Reloaded subplugins!");
			}
			case 1: // Reload a specific subplugin
			{
				new String:pluginName[PLATFORM_MAX_PATH];
				GetCmdArg(1, pluginName, sizeof(pluginName));
				BuildPath(Path_SM, pluginName, PLATFORM_MAX_PATH, "plugins/freaks/%s.ff2", pluginName);
				if(!FileExists(pluginName))
				{
					CReplyToCommand(client, "{olive}[FF2]{default} Subplugin %s does not exist!", pluginName);
					return Plugin_Handled;
				}	
				ReplaceString(pluginName, sizeof(pluginName), "addons/sourcemod/plugins/freaks/", "freaks/", false);
				ServerCommand("sm plugins unload %s", pluginName);
				ServerCommand("sm plugins load %s", pluginName);
				ReplaceString(pluginName, sizeof(pluginName), "freaks/", " ", false);
				CReplyToCommand(client, "{olive}[FF2]{default} Reloaded subplugin %s!", pluginName);		
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
}

public FF2_AddHooks(client)
{
	strcopy(xIncoming[client], sizeof(xIncoming[]), "");
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
	
	FF2flags[client]=0;
	Damage[client]=0;
	uberTarget[client]=-1;

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

public OnClientCookiesCached(client)
{
	decl String:sEnabled[2];
	GetClientCookie(client, BossCookie, sEnabled, sizeof(sEnabled));

	new enabled = StringToInt(sEnabled);
	
	if( 1 > enabled || 2 < enabled)
	{
		ClientCookie[client] = TOGGLE_UNDEF;
		new Handle:clientPack = CreateDataPack();
		WritePackCell(clientPack, client);
		CreateTimer(GetConVarFloat(cvarFF2TogglePrefDelay), BossMenuTimer, clientPack);
	}
	else
	{
		ClientCookie[client] = enabled;
	}

	GetClientCookie(client, CompanionCookie, sEnabled, sizeof(sEnabled));
	
	enabled = StringToInt(sEnabled);
	
	if( 1 > enabled || 2 < enabled)
	{
		ClientCookie2[client] = TOGGLE_UNDEF;
		new Handle:clientPack = CreateDataPack();
		WritePackCell(clientPack, client);
	}
	else
	{
		ClientCookie2[client] = enabled;
	}
}

public OnClientDisconnect(client)
{
	if(Enabled)
	{
		if (IsBoss(client))
		{
			if (CheckRoundState() == FF2RoundState_RoundRunning)
			{
				ForceTeamWin(MercTeam);
			}
			if (!CheckRoundState())
			{
				new bool:omit[MaxClients+1];
				
				omit[client]=true;
				
				SetClientQueuePoints(client, 0);
				
				new boss=FF2_GetBossIndex(client);
				Boss[boss]=GetClientWithMostQueuePoints(omit);
				omit[Boss[boss]]=true;
				
				if(!boss)
				{
					SetClientQueuePoints(Boss[boss], 0);
				}
				
				if (IsValidClient(Boss[boss]))
				{	
					CreateTimer(0.1, MakeBoss, GetBossIndex(Boss[boss]));
					CPrintToChat(Boss[boss], "{olive}[FF2]{default} %t", "Replace Disconnected Boss 2");
					CPrintToChatAll("{olive}[FF2]{default} %t", "Replace Disconnected Boss", client, Boss[boss]);
				}
			}
		}
		
		if(IsClientInGame(client) && IsPlayerAlive(client) && CheckRoundState()==FF2RoundState_RoundRunning)
		{
			if (client == g_NextHale)
			{
				KillTimer(g_NextHaleTimer);
			}
		
			strcopy(xIncoming[client], sizeof(xIncoming[]), "");
			ClientCookie[client] = TOGGLE_UNDEF;
			ClientCookie2[client] = TOGGLE_UNDEF;
			CheckAlivePlayersAt=GetEngineTime()+0.1;
		}
	}
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
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
	
	airstab[client]=0;
	GoombaCount[client]=0;
	
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");

	if(IsBoss(client))
	{
		CreateTimer(0.1, MakeBoss, GetBossIndex(client));
	}
	
	if(!(FF2flags[client] & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
	{
		if(CheckRoundState()!=FF2RoundState_RoundRunning)
		{
			if(!(FF2flags[client] & FF2FLAG_HASONGIVED))
			{
				FF2flags[client]|=FF2FLAG_HASONGIVED;
				RemovePlayerBack(client, {57, 133, 405, 444, 608, 642}, 7);
				RemovePlayerTarge(client);
				TF2_RemoveAllWeapons(client);
				TF2_RegeneratePlayer(client);
				CreateTimer(0.1, Timer_RegenPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			CreateTimer(0.2, MakeNotBoss, GetClientUserId(client));
		}
		else
		{
			CreateTimer(0.1, CheckItems, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	if(CheckRoundState()==FF2RoundState_RoundRunning)
	{
		CheckAlivePlayersAt=GetEngineTime()+0.1;
	}

	FF2flags[client]&=~(FF2FLAG_DISABLE_SPEED_MANAGEMENT|FF2FLAG_DISABLE_WEAPON_MANAGEMENT|FF2FLAG_UBERREADY|FF2FLAG_ISBUFFED|FF2FLAG_TALKING|FF2FLAG_ALLOWSPAWNINBOSSTEAM|FF2FLAG_USINGABILITY|FF2FLAG_CLASSHELPED|FF2FLAG_CHANGECVAR|FF2FLAG_ALLOW_HEALTH_PICKUPS|FF2FLAG_ALLOW_AMMO_PICKUPS|FF2FLAG_ROCKET_JUMPING);
	FF2flags[client]|=FF2FLAG_USEBOSSTIMER;
	return Plugin_Continue;
}

public Action:Timer_RegenPlayer(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	if(IsValidClient(client) && IsPlayerAlive(client))
	{
		TF2_RegeneratePlayer(client);
	}
}

public OnGameFrame() // Moving some stuff here and there
{
	if(!Enabled)
		return;

	if(DeadRunMode && CheckRoundState()==FF2RoundState_RoundRunning)
	{
		Deathrun_Tick(GetEngineTime());
	}
	FF2_ClientTick(GetEngineTime());
	FF2_Tick(GetEngineTime());
	FF2_RoundTick(GetEngineTime());
}

public FF2_ClientTick(Float:gameTime)
{
	for(new client=1;client<=MaxClients;client++)
	{
		if(!IsValidClient(client))
			continue;
		if(gameTime>=skewerCooldownEndsIn[client])
		{
			skewerCooldown[client]=false;
			skewerCooldownEndsIn[client]=INACTIVE;
		}
	}
}

public Deathrun_Tick(Float:gameTime)
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			if(TF2_GetPlayerClass(client)==TFClass_Spy)
				SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 1.0);
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", (GetClientTeam(client) == BossTeam ? 400.0 : 300.0));
		}
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
		
		RoundTick++;
		UpdateRoundTickAt=GetEngineTime()+1.0;
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

		AliveMercPlayers=0;
		AliveBossPlayers=0;
		for(new client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(GetClientTeam(client)==MercTeam)
				{
					AliveMercPlayers++;
				}
				else if(IsBoss(client) || (FF2_GetFF2flags(client) & FF2FLAG_ALLOWSPAWNINBOSSTEAM))
				{
					AliveBossPlayers++;
				}
			}
		}

		Call_StartForward(OnAlivePlayersChanged);  //Let subplugins know that the number of alive players just changed
		Call_PushCell(AliveMercPlayers);
		Call_PushCell(AliveBossPlayers);
		Call_Finish();

		if(!AliveMercPlayers)
		{
			ForceTeamWin(BossTeam);
		}
		else if(AliveMercPlayers==1 && AliveBossPlayers && Boss[0])
		{
			new String:sound[PLATFORM_MAX_PATH];
			if(RandomSound("sound_lastman", sound, PLATFORM_MAX_PATH))
			{
				EmitSoundToAll(sound);
				EmitSoundToAll(sound);
			}
		}
		else if(!PointType && AliveMercPlayers<=AliveToEnable && !executed)
		{
			PrintHintTextToAll("%t", "point_enable", AliveToEnable);
			if(AliveMercPlayers<=AliveToEnable)
			{
				new String:sound[64];
				if(GetRandomInt(0, 1))
				{
					Format(sound, sizeof(sound), "vo/announcer_am_capenabled0%i.mp3", GetRandomInt(1, 4));
				}
				else
				{
					Format(sound, sizeof(sound), "vo/announcer_am_capincite0%i.mp3", GetRandomInt(0, 1) ? 1 : 3);
				}
				EmitSoundToAll(sound);
			}
			SetControlPoint(true);
			executed=true;
		}

		if(!DeadRunMode && AliveMercPlayers<=countdownPlayers && BossHealth[0]>countdownHealth && countdownTime>1 && !executed2)
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
		static announcecount=-1;
		announcecount++;
		if(Enabled2)
		{
			switch(announcecount)
			{
				case 1:
				{
					CPrintToChatAll("=== {blue}Big Bang Gamers{default} Freak Fortress 2 v%s (a fork of the official Freak Fortress 2 game mode) ===", PLUGIN_VERSION);
				}
				case 2:
				{
					CPrintToChatAll("{olive}[FF2]{default} %t", "type_ff2_to_open_menu");
				}
				case 3:
				{
					CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Updates", PLUGIN_VERSION, ff2versiondates[maxVersion]);
				}
				case 4:
				{
					CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Toggle Command");
				}
				case 5:
				{
					CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Companion Command");
				}
				case 6:
				{
					CPrintToChatAll("{olive}[FF2]{default} To select a boss, type {olive}/ff2boss{default} to open boss selection menu, or {olive}/ff2boss <boss name>{default} to select a boss.");
				}
				case 7:
				{
					CPrintToChatAll("=== Freak Fortress 2 v%s (based on {olive}VS Saxton Hale{default} mode by {olive}RainBolt Dash{default}, {olive}FlaminSarge{default}, and {blue}Chdata{default}) ===", PLUGIN_VERSION);
				}
				case 8:
				{
					announcecount=0;
					CPrintToChatAll("{olive}[FF2]{default} VS Saxton Hale/Freak Fortress 2 group: {olive}http://steamcommunity.com/groups/vssaxtonhale{default}");
				}
				default:
				{
					CPrintToChatAll("{olive}[FF2]{default} %t", "type_ff2_to_open_menu");
				}
			}
			AnnounceAt = Announce ? GetEngineTime()+Announce : INACTIVE;
		}
	}
	
	if(gameTime >= NineThousandAt)
	{
		EmitSoundToAll("saxton_hale/9000.wav", _, _, _, _, _, _, _, _, _, false);
		EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, _, _, _, _, _, _, _, false);
		EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, "saxton_hale/9000.wav", _, SNDCHAN_VOICE, _, _, _, _, _, _, _, false);
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

		new entity=-1;
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
		new clients;
		new bool:added[MaxClients+1];
		while(clients<3)  //TODO: Make this configurable?
		{
			new client=GetClientWithMostQueuePoints(added);
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
	
	if(gameTime >= DrawGameTimerAt)
	{
		if(BossHealth[0]<countdownHealth || CheckRoundState()!=FF2RoundState_RoundRunning || AliveMercPlayers>countdownPlayers)
		{
			executed2=false;
			DrawGameTimerAt = INACTIVE;
			return;
		}

		new time=timeleft;
		timeleft--;
		new String:timeDisplay[6];
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

		SetHudTextParams(-1.0, 0.17, 1.1, 255, 0, 0, 255);
		for(new client; client<=MaxClients; client++)
		{
			if(IsValidClient(client))
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
				new String:sound[PLATFORM_MAX_PATH];
				Format(sound, PLATFORM_MAX_PATH, "vo/announcer_ends_%isec.mp3", time);
				EmitSoundToAll(sound);
			}
			case 0:
			{
				if(!GetConVarBool(cvarCountdownResult))
				{
					for(new client=1; client<=MaxClients; client++)  //Thx MasterOfTheXP
					{
						if(IsClientInGame(client) && IsPlayerAlive(client))
						{
							ForcePlayerSuicide(client);
						}
					}
				}
				else
				{
					ForceTeamWin(0);  //Stalemate
				}
				DrawGameTimerAt = INACTIVE;
				return;
			}
		}
		DrawGameTimerAt = GetEngineTime()+1.0;
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
			new entity=-1;
			while((entity=FindEntityByClassname2(entity, "func_door"))!=-1)
			{
				AcceptEntityInput(entity, "Open");
				AcceptEntityInput(entity, "Unlock");
			}

			CheckDoorsAt = GetEngineTime()+5.0;
		}
	
		SetHudTextParams(-1.0, 0.2, 10.0, 255, 255, 255, 255);
		new String:text[512];
		new String:textChat[512];
		new String:lives[4];
		new String:name[64];
		for(new client; client<=MaxClients; client++)
		{
			if(IsBoss(client))
			{
				new boss=Boss[client];
				KvRewind(BossKV[Special[boss]]);
				KvGetString(BossKV[Special[boss]], "name", name, sizeof(name), "=Failed name=");
				if(BossLives[boss]>1)
				{
					Format(lives, 4, "x%i", BossLives[boss]);
				}	
				else
				{
					strcopy(lives, 2, "");
				}
				
				decl String:hUpdatedName[512];
				Format(hUpdatedName, sizeof(hUpdatedName), "%s | %s", hName, name);
				SetConVarString(sName, hUpdatedName);	
				
				if(!HasCompanions)
				{	
					Format(text, sizeof(text), "%s\n%t\n", text, "ff2_start", Boss[boss], name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), lives);
					ShowGameText(text);
				}
				else
					Format(text, sizeof(text), "%s\n%t", text, "ff2_start", Boss[boss], name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), lives);
				Format(textChat, sizeof(textChat), "{olive}[FF2]{default} %t!", "ff2_start", Boss[boss], name, BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1), lives);
				ReplaceString(textChat, sizeof(textChat), "\n", "");  //Get rid of newlines
				CPrintToChatAll("%s", textChat);
			}
		}

		for(new client; client<=MaxClients; client++)
		{
			if(IsValidClient(client) && HasCompanions)
			{
				SetGlobalTransTarget(client);
				PrintCenterText(client, text);
			}
		}
	
		if(DeadRunMode)
		{
			IsPreparing = false;
			for(new i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && IsPlayerAlive(i))
					SetEntityMoveType(i, MOVETYPE_WALK);
		}
		DisplayMessageAt = INACTIVE;
	}
	
	if(gameTime >= StartResponseAt)
	{
		new String:sound[PLATFORM_MAX_PATH];
		if(RandomSound("sound_begin", sound, PLATFORM_MAX_PATH))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}
		SetClientQueuePoints(Boss[0], 0);
		StartResponseAt = INACTIVE;
	}
	
	if(gameTime >= MoveAt)
	{
		for(new client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client) && IsPlayerAlive(client))
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
			}
		}
		MoveAt = INACTIVE;
	}
	if(gameTime >= StartBossAt)
	{
		MoveAt=GetEngineTime()+0.1;
		UpdateRoundTickAt=GetEngineTime()+1.0;
	
		new bool:isBossAlive;
		for(new client; client<=MaxClients; client++)
		{
			if(IsValidClient(Boss[client]) && IsPlayerAlive(Boss[client]))
			{
				isBossAlive=true;
				SetEntityMoveType(Boss[client], MOVETYPE_NONE);
			}
			
			if(isBossAlive && IsValidClient(client) && IsPlayerAlive(client) && !IsBoss(client) && GetClientTeam(client)==BossTeam)
			{
				CreateTimer(0.1, MakeNotBoss, client);
			}
		}

		if(!isBossAlive)
		{	
			StartBossAt = INACTIVE;
			return;
		}

		playing=0;
		for(new client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client) && !IsBoss(client) && IsPlayerAlive(client))
			{
				playing++;
				if(IsLivingSpectator(client))
				{
					TF2_RespawnPlayer(client);
				}
				CreateTimer(0.15, MakeNotBoss, GetClientUserId(client));  //TODO:  Is this needed?
			}
		}

		for(new boss; boss<=MaxClients; boss++)
		{
			if(Boss[boss] && IsValidEdict(Boss[boss]) && IsPlayerAlive(Boss[boss]))
			{
				BossHealthMax[boss]=ParseFormula(boss);
				BossLives[boss]=BossLivesMax[boss];
				BossHealth[boss]=BossHealthMax[boss]*BossLivesMax[boss];
				BossHealthLast[boss]=BossHealth[boss];
			}
		}
	
		RoundTick = 0;
		FF2BossTick=GetEngineTime()+0.2;
		CheckAlivePlayersAt=GetEngineTime()+0.2;
		StartFF2RoundAt=GetEngineTime()+0.2;
		FF2ClientTick=GetEngineTime()+0.2;
		CreateTimer(2.0, Timer_MusicPlay, 0, TIMER_FLAG_NO_MAPCHANGE);
 
		if(!PointType)
		{
			SetControlPoint(false);
		}
		StartBossAt = INACTIVE;
	}
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

		new bool:validBoss=false;
		for(new client; client<=MaxClients; client++)
		{
			if(!IsValidClient(Boss[client]) || !IsPlayerAlive(Boss[client]) || !(FF2flags[Boss[client]] & FF2FLAG_USEBOSSTIMER))
			{
				continue;
			}
			
			validBoss=true;

			if(CheckRoundState()==FF2RoundState_RoundEnd)
			{
				TF2_AddCondition(Boss[client], TFCond_SpeedBuffAlly, 14.0);
				FF2BossTick = INACTIVE;
				return;
			}
		
			if(!(FF2flags[Boss[client]] & FF2FLAG_DISABLE_SPEED_MANAGEMENT))
			{
				SetEntPropFloat(Boss[client], Prop_Data, "m_flMaxspeed", BossSpeed[Special[client]]+0.7*(100-BossHealth[client]*100/BossLivesMax[client]/BossHealthMax[client]));
			}
		
			if(BossHealth[client]<=0 && IsPlayerAlive(Boss[client]))  //Wat.  TODO:  Investigate
			{
				BossHealth[client]=1;
			}

			if(BossLivesMax[client]>1)
			{
				SetHudTextParams(-1.0, 0.77, 0.15, 255, 255, 255, 255);
				FF2_ShowSyncHudText(Boss[client], livesHUD, "%t", "Boss Lives Left", BossLives[client], BossLivesMax[client]);
			}
		
			if(BossCharge[client][0]>100.0)
			{
				BossCharge[client][0]=100.0;
			}

			if(RoundFloat(BossCharge[client][0])==100.0)
			{
				if(IsFakeClient(Boss[client]) && !(FF2flags[Boss[client]] & FF2FLAG_BOTRAGE))
				{
					CreateTimer(1.0, Timer_BotRage, client, TIMER_FLAG_NO_MAPCHANGE);
					FF2flags[Boss[client]]|=FF2FLAG_BOTRAGE;
				}
				else
				{
					SetHudTextParams(-1.0, 0.83, 0.15, 255, 64, 64, 255);
					FF2_ShowSyncHudText(Boss[client], rageHUD, "%t", "do_rage");

					new String:sound[PLATFORM_MAX_PATH];
					if(RandomSound("sound_full_rage", sound, PLATFORM_MAX_PATH, client) && emitRageSound[client])
					{
						new Float:position[3];
						GetEntPropVector(Boss[client], Prop_Send, "m_vecOrigin", position);

						FF2flags[Boss[client]]|=FF2FLAG_TALKING;
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
						FF2flags[Boss[client]]&=~FF2FLAG_TALKING;
						emitRageSound[client]=false;
					}
				}
			}
			else
			{
				SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255);
				FF2_ShowSyncHudText(Boss[client], rageHUD, "%t", "rage_meter", RoundFloat(BossCharge[client][0]));
			}
			SetHudTextParams(-1.0, 0.88, 0.15, 255, 255, 255, 255);

			SetClientGlow(client, -0.2);

			new String:lives[MAXRANDOMS][3];
			for(new i=1; ; i++)
			{
				new String:ability[10];
				Format(ability, 10, "ability%i", i);
				KvRewind(BossKV[Special[client]]);
				if(KvJumpToKey(BossKV[Special[client]], ability))
				{
					new String:plugin_name[64];
					KvGetString(BossKV[Special[client]], "plugin_name", plugin_name, 64);
					new slot=KvGetNum(BossKV[Special[client]], "arg0", 0);
					new buttonmode=KvGetNum(BossKV[Special[client]], "buttonmode", 0);
					if(slot<1)
					{
						continue;
					}

					KvGetString(BossKV[Special[client]], "life", ability, 10, "");
					if(!ability[0])
					{
						new String:ability_name[64];
						KvGetString(BossKV[Special[client]], "name", ability_name, 64);
						UseAbility(ability_name, plugin_name, client, slot, buttonmode);
					}
					else
					{
						new count=ExplodeString(ability, " ", lives, MAXRANDOMS, 3);
						for(new n; n<count; n++)
						{
							if(StringToInt(lives[n])==BossLives[client])
							{
								new String:ability_name[64];
								KvGetString(BossKV[Special[client]], "name", ability_name, 64);
								UseAbility(ability_name, plugin_name, client, slot, buttonmode);
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

			if(AliveMercPlayers==1)
			{
				new String:message[512];
				new String:name[64];
				for(new target; target<=MaxClients; target++)
				{
					if(IsBoss(target))
					{
						new boss2=GetBossIndex(target);
						KvRewind(BossKV[Special[boss2]]);
						KvGetString(BossKV[Special[boss2]], "name", name, sizeof(name), "=Failed name=");
						//Format(bossLives, sizeof(bossLives), ((BossLives[boss2]>1) ? ("x%i", BossLives[boss2]) : ("")));
						decl String:bossLives[4];
						if(BossLives[boss2]>1)
						{
							Format(bossLives, sizeof(bossLives), "x%i", BossLives[boss2]);
						}
						else
						{
							Format(bossLives, sizeof(bossLives), "");
						}
						Format(message, sizeof(message), !HasCompanions ? "%s\n%t \n":"%s\n%t", message, "ff2_hp", name, BossHealth[boss2]-BossHealthMax[boss2]*(BossLives[boss2]-1), BossHealthMax[boss2], bossLives);
					}
					
					if(!HasCompanions)
					{
						ShowGameText(message);
					}
				}
				for(new target; target<=MaxClients; target++)
				{
					if(IsValidClient(target) && !(FF2flags[target] & FF2FLAG_HUDDISABLED) && HasCompanions)
					{
						SetGlobalTransTarget(target);
						PrintCenterText(target, message);
					}
				}

				if(lastPlayerGlow)
				{
					SetClientGlow(client, 3600.0);
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
		
		FF2BossTick = GetEngineTime()+0.2;
	}
	
	if(gameTime >= FF2ClientTick)
	{
		if(!Enabled || CheckRoundState()==FF2RoundState_RoundEnd || CheckRoundState()==FF2RoundState_Loading)
		{
			FF2ClientTick = INACTIVE;
			return;
		}

		decl String:classname[32];
		new TFCond:cond;
		for(new client=1; client<=MaxClients; client++)
		{
			if(IsValidClient(client) && !IsBoss(client) && !(FF2flags[client] & FF2FLAG_CLASSTIMERDISABLED))
			{
				// Damage HUD
				SetHudTextParams(-1.0, 0.88, 0.35, 90, 255, 90, 255, 0, 0.35, 0.0, 0.1);
				if(!IsPlayerAlive(client))
				{
					new observer=GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
					if(IsValidClient(observer) && !IsBoss(observer) && observer!=client)
					{
						FF2_ShowSyncHudText(client, rageHUD, "Damage: %d-%N's Damage: %d", Damage[client], observer, Damage[observer]);
					}
					else
					{
						FF2_ShowSyncHudText(client, rageHUD, "Damage: %d", Damage[client]);
					}
					continue;
				}
				FF2_ShowSyncHudText(client, rageHUD, "Damage: %d", Damage[client]);
				
				// Weapon Stuff
				new TFClassType:class=TF2_GetPlayerClass(client);
				new weapon=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon<=MaxClients || !IsValidEntity(weapon) || !GetEdictClassname(weapon, classname, sizeof(classname)))
				{
					strcopy(classname, sizeof(classname), "");
				}
				new bool:validwep=!StrContains(classname, "tf_weapon", false);
						
				// Chdata's Deadringer Notifier
				if (TF2_GetPlayerClass(client) == TFClass_Spy && !IsBoss(client))
				{
					if(GetClientCloakIndex(client) == 59)
					{
						new drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
						new String:s[32];
						
						SetHudTextParams(-1.0, 0.83, 0.35, 90, drstatus==2 ? 64 : 255, drstatus==2 ? 64 : drstatus==1 ? 90 : 255, 255, 0, 0.0, 0.0, 0.0);		
						Format(s, sizeof(s), TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? "Status: Deadringed" : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? "Status: Feign Death Ready" : "Status: Inactive");

						if (!(GetClientButtons(client) & IN_SCORE))
						{
							FF2_ShowSyncHudText(client, cloakHUD, "%s", s);
						}
					}
				}
	
				new index=(validwep ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
				if(class==TFClass_Medic)
				{
					if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary))
					{
						new medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
						decl String:mediclassname[64];
						if(IsValidEdict(medigun) && GetEdictClassname(medigun, mediclassname, sizeof(mediclassname)) && !StrContains(mediclassname, "tf_weapon_medigun", false))
						{
							new charge=RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
							SetHudTextParams(-1.0, 0.83, 0.35, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
							FF2_ShowSyncHudText(client, jumpHUD, "%T: %i", "uber-charge", client, charge);
	
							if(charge==100 && !(FF2flags[client] & FF2FLAG_UBERREADY))
							{
								FakeClientCommandEx(client, "voicemenu 1 7");
								FF2flags[client]|=FF2FLAG_UBERREADY;
							}
						}
					}
					else if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
					{
						new healtarget=GetHealingTarget(client, true);
						if(IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget)==TFClass_Scout)
						{
							TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.3);
						}
					}
				}

				else if(class==TFClass_Soldier)
				{
					if((FF2flags[client] & FF2FLAG_ISBUFFED) && !(GetEntProp(client, Prop_Send, "m_bRageDraining")))
					{
						FF2flags[client]&=~FF2FLAG_ISBUFFED;
					}
				}

				if(AliveMercPlayers==1 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
				{
					TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.3);
					if(class==TFClass_Engineer && weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(classname, "tf_weapon_sentry_revenge", false))
					{
						SetEntProp(client, Prop_Send, "m_iRevengeCrits", 3);
					}
					TF2_AddCondition(client, TFCond_Buffed, 0.3);
	
					if(lastPlayerGlow)
					{
						SetClientGlow(client, 3600.0);
					}
					continue;
				}
				else if(AliveMercPlayers==2 && !TF2_IsPlayerInCondition(client, TFCond_Cloaked))
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

				new healer=-1;
				for(new healtarget=1; healtarget<=MaxClients; healtarget++)
				{
					if(IsValidClient(healtarget) && IsPlayerAlive(healtarget) && GetHealingTarget(healtarget, true)==client)
					{
						healer=healtarget;
						break;
					}
				}
				
				new bool:addthecrit=false;
				if(validwep && weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) && strcmp(classname, "tf_weapon_knife", false))  //Every melee except knives
				{
					addthecrit=true;
				}
				
				else if((!StrContains(classname, "tf_weapon_smg") && index!=751) ||
						!StrContains(classname, "tf_weapon_compound_bow") ||
						!StrContains(classname, "tf_weapon_crossbow") ||
						!StrContains(classname, "tf_weapon_pistol") ||
						index==1104 && TF2_IsPlayerInCondition(client, TFCond_BlastJumping) ||
						!StrContains(classname, "tf_weapon_handgun_scout_secondary"	))
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
							new medigun=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
							if(IsValidEdict(medigun))
							{
								SetHudTextParams(-1.0, 0.83, 0.15, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
								new charge=RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
								FF2_ShowHudText(client, -1, "%T: %i", "uber-charge", client, charge);
								if(charge==100 && !(FF2flags[client] & FF2FLAG_UBERREADY))
								{
									FakeClientCommand(client, "voicemenu 1 7");  //"I am fully charged!"
									FF2flags[client]|= FF2FLAG_UBERREADY;
								}
							}
						}
						else if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))
						{
							new healtarget=GetHealingTarget(client, true);
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
							if(!TF2_IsPlayerCritBuffed(client) && !TF2_IsPlayerInCondition(client, TFCond_Buffed) && !TF2_IsPlayerInCondition(client, TFCond_Cloaked) && !TF2_IsPlayerInCondition(client, TFCond_Disguised) && !GetEntProp(client, Prop_Send, "m_bFeignDeathReady"))
							{
								TF2_AddCondition(client, TFCond_CritCola, 0.3);
							}
						}
					}
					case TFClass_Engineer:
					{
						if(weapon==GetPlayerWeaponSlot(client, TFWeaponSlot_Primary) && StrEqual(classname, "tf_weapon_sentry_revenge", false))
						{
							new sentry=FindSentry(client);
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
		FF2ClientTick = GetEngineTime()+0.2;
	}
}

stock FindSentry(client)
{
	new entity=-1;
	while((entity=FindEntityByClassname2(entity, "obj_sentrygun"))!=-1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client)
		{
			return entity;
		}
	}
	return -1;
}


public Action:Timer_BotRage(Handle:timer, any:bot)
{
	if(IsValidClient(Boss[bot], false))
	{
		FakeClientCommandEx(Boss[bot], "voicemenu 0 0");
	}
}

stock OnlyScoutsLeft()
{
	new scouts;
	for(new client; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client)==MercTeam)
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
	new weapon=GetPlayerWeaponSlot(client, slot);
	return (weapon>MaxClients && IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
}

public TF2_OnConditionAdded(client, TFCond:condition)
{
	if(!Enabled)
	{
		return;
	}
	
	if(IsBoss(client) && (condition==TFCond_Jarated || condition==TFCond_MarkedForDeath || (condition==TFCond_Dazed && TF2_IsPlayerInCondition(client, TFCond:42))))
	{
		TF2_RemoveCondition(client, condition);
	}
	
	if(!IsBoss(client) && condition==TFCond_Taunting)
	{
		new weapon=GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEdict(weapon))
		{
		
			decl String:classname[64];
			GetEdictClassname(weapon, classname, 64);

			if(StrEqual(classname, "tf_weapon_compound_bow", false))
			{
				if(skewerCooldown[client] && GetEntProp(client, Prop_Send, "m_iTauntItemDefIndex") == -1)
				{
					TF2_RemoveCondition(client, TFCond_Taunting);
					return;
				}
				skewerCooldownEndsIn[client]=GetEngineTime()+10.0;
				skewerCooldown[client]=true;
				return;
			}
			if(StrEqual(classname, "tf_weapon_lunchbox", false))
			{
				TF2_AddCondition(client, TFCond_Bonked, 3.0);
				if(condition==TFCond:41)
				{
					RequestFrame(Frame_RemoveMeleeRestrict, client);
				}
			}
		}
	}
	
	
	if(TF2_GetPlayerClass(client)==TFClass_Spy && condition==TFCond_DeadRingered)
	{
		RequestFrame(Frame_RemoveFeignSpeedBuff, client);
	}

}

public TF2_OnConditionRemoved(client, TFCond:condition)
{
	if(Enabled && TF2_GetPlayerClass(client)==TFClass_Scout)
	{
		switch(condition)
		{
			case TFCond_CritHype: TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
			case TFCond_Bonked:
			{
				new String:UnBonk[PLATFORM_MAX_PATH];
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
}

public Frame_RemoveFeignSpeedBuff(client)
{
	if (IsClientInGame(client))
	{
		TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(client, "DispatchEffect");
	}
}

public Frame_RemoveMeleeRestrict(client)
{
	if (IsClientInGame(client))
	{
		TF2_RemoveCondition(client, TFCond:41);
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

	UseRage(client);
	return Plugin_Continue;
}

public Action:StopTaunt(Handle:timer,any:client)
{

	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(client,TFCond_Taunting);
		new Float:up[3];
		up[2]=220.0;
		TeleportEntity(client,NULL_VECTOR, NULL_VECTOR,up);
	}
	else if(TF2_IsPlayerInCondition(client, TFCond_Taunting))
	{
		TF2_RemoveCondition(client,TFCond_Taunting);
	}
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

	if(FF2_GetBossIndex(client)>=0 && FF2_GetBossCharge(FF2_GetBossIndex(client), 0)>=100.0)
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
	if(RoundFloat(BossCharge[boss][0])==100)
	{
	
		if(TF2_IsPlayerInCondition(client, TFCond_Taunting))
			CreateTimer(0.1, StopTaunt, client);
	
		char ability[10], lives[MAXRANDOMS][3];
		for(new i=1; i<MAXRANDOMS; i++)
		{
			Format(ability, sizeof(ability), "ability%i", i);
			KvRewind(BossKV[Special[boss]]);
			if(KvJumpToKey(BossKV[Special[boss]], ability))
			{
				if(KvGetNum(BossKV[Special[boss]], "arg0", 0))
				{
					continue;
				}

				KvGetString(BossKV[Special[boss]], "life", ability, sizeof(ability));
				if(!ability[0])
				{
					char abilityName[64], pluginName[64];
					KvGetString(BossKV[Special[boss]], "plugin_name", pluginName, sizeof(pluginName));
					KvGetString(BossKV[Special[boss]], "name", abilityName, sizeof(abilityName));
					UseAbility(abilityName, pluginName, boss, 0);
				}
				else
				{
					new count=ExplodeString(ability, " ", lives, MAXRANDOMS, 3);
					for(new j; j<count; j++)
					{
						if(StringToInt(lives[j])==BossLives[boss])
						{
							char abilityName[64], pluginName[64];
							KvGetString(BossKV[Special[boss]], "plugin_name", pluginName, sizeof(pluginName));
							KvGetString(BossKV[Special[boss]], "name", abilityName, sizeof(abilityName));
							UseAbility(abilityName, pluginName, boss, 0);
							break;
						}
					}
				}
			}
		}

		float position[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);

		char sound[PLATFORM_MAX_PATH];

		if(RandomSound("sound_ability_serverwide", sound, sizeof(sound), boss))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}
		
		if(RandomSoundAbility("sound_ability", sound, PLATFORM_MAX_PATH, boss))
		{
			FF2flags[Boss[boss]]|=FF2FLAG_TALKING;
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
			FF2flags[Boss[boss]]&=~FF2FLAG_TALKING;
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
		new String:class[16];
		GetCmdArg(1, class, sizeof(class));
		if(StrEqual(class, "scout", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Scout);
		}
		else if(StrEqual(class, "soldier", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Soldier);
		}
		else if(StrEqual(class, "pyro", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Pyro);
		}
		else if(StrEqual(class, "demoman", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_DemoMan);
		}
		else if(StrEqual(class, "heavyweapons", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Heavy);
		}
		else if(StrEqual(class, "medic", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Medic);
		}
		else if(StrEqual(class, "sniper", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Sniper);
		}
		else if(StrEqual(class, "spy", false))
		{
			SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", _:TFClass_Spy);
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:CMD_JoinTeam(client, const String:command[], args)
{
	if(!Enabled || !args || RoundCount<arenaRounds)
	{
		return Plugin_Continue;
	}

	new team=_:TFTeam_Unassigned, oldTeam=GetClientTeam(client), String:teamString[10];
	GetCmdArg(1, teamString, sizeof(teamString));

	if(StrEqual(teamString, "red", false))
	{
		team=_:TFTeam_Red;
	}
	else if(StrEqual(teamString, "blue", false))
	{
		team=_:TFTeam_Blue;
	}
	else if(StrEqual(teamString, "auto", false))
	{
		team=MercTeam;
	}
	else if(StrEqual(teamString, "spectate", false) && !IsBoss(client) && GetConVarBool(FindConVar("mp_allowspectators")))
	{
		team=_:TFTeam_Spectator;
	}

	if(team==BossTeam && !IsBoss(client))
	{
		team=MercTeam;
	}
	else if(team==MercTeam && IsBoss(client))
	{
		team=BossTeam;
	}

	if(team>_:TFTeam_Unassigned && team!=oldTeam)
	{
		ChangeClientTeam(client, team);
	}

	if(CheckRoundState()!=FF2RoundState_RoundRunning && !IsBoss(client) || !IsPlayerAlive(client))  //No point in showing the VGUI if they can't change teams
	{
		switch(team)
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

public Action:OnRPS(Handle:event, const String:eventName[], bool:dontBroadcast)
{
	new winner = GetEventInt(event, "winner");
	new loser = GetEventInt(event, "loser");
	
	if(!IsValidClient(winner) || !IsValidClient(loser)) // Check for valid clients
	{
		return;
	}

	if(!IsBoss(winner) && IsBoss(loser)) // Boss Loses on RPS? Kill current boss.
	{
		new boss=FF2_GetBossIndex(loser);
		RPSWinner=winner;
		RPSLoser[loser]=true;
		Damage[winner]+=FF2_GetBossHealth(boss);
		CreateTimer(3.1, DelayRPSDeath, loser);
		return;
	}
	
	if(!IsBoss(winner) && !IsBoss(loser) && GetClientQueuePoints(loser)>=GetConVarInt(cvarRPSQueuePoints) &&  GetConVarInt(cvarRPSQueuePoints)>0) // Teammate or Minion loses? Gamble for Queue Points
	{
		CPrintToChat(winner, "{olive}[FF2]{default} %t", "rps_won", GetConVarInt(cvarRPSQueuePoints), loser);
		SetClientQueuePoints(winner, GetClientQueuePoints(winner)+GetConVarInt(cvarRPSQueuePoints));

		CPrintToChat(loser, "{olive}[FF2]{default} %t", "rps_lost", GetConVarInt(cvarRPSQueuePoints), winner);
		SetClientQueuePoints(loser, GetClientQueuePoints(loser)-GetConVarInt(cvarRPSQueuePoints));
	}
}

public Action:DelayRPSDeath(Handle:timer, any:client)
{
	if(IsValidClient(client))
	{
		ForcePlayerSuicide(client);
	}
}

public Action:Event_PlayerDeath(Handle:event, const String:eventName[], bool:dontBroadcast)
{
	if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
	{
		return Plugin_Continue;
	}
	
	if(!isCosmetic)
	{
		new client=GetClientOfUserId(GetEventInt(event, "userid")), attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
		new String:sound[PLATFORM_MAX_PATH];
		CheckAlivePlayersAt=GetEngineTime()+0.1;
		DoOverlay(client, "");
		
		if(GetClientTeam(client)==BossTeam && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
		{
			TF2_RemoveAllWeapons(client); // Prevent dropping a boss weapon
		}
		
		if(IsBoss(client) && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
		{
			if(RPSLoser[client])
			{
				SetEventInt(event,"attacker",GetClientUserId(RPSWinner));
				RPSWinner=client;
				RPSLoser[client]=false;
			}
		}
		
		if(!IsBoss(client))
		{
			if(!attacker && DeadRunMode && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
			{	
				SetEventInt(event,"attacker",GetClientUserId(drboss));
			}
	
			if(!(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
			{
				airstab[client]=0;
				GoombaCount[client]=0;
				CreateTimer(1.0, Timer_Damage, GetClientUserId(client));
			}

			if(IsBoss(attacker))
			{
				new boss=GetBossIndex(attacker);
				if(firstBlood)  //TF_DEATHFLAG_FIRSTBLOOD is broken
				{
					if(RandomSound("sound_first_blood", sound, PLATFORM_MAX_PATH, boss))
					{
						EmitSoundToAll(sound);
						EmitSoundToAll(sound);
					}
					firstBlood=false;
				}

				if(RandomSound("sound_hit", sound, PLATFORM_MAX_PATH, boss))
				{
					EmitSoundToAll(sound);
					EmitSoundToAll(sound);
				}

				if(!GetRandomInt(0, 2))  //1/3 chance for "sound_kill_<class>"
				{
					new Handle:data;
					CreateDataTimer(0.1, PlaySoundKill, data);
					WritePackCell(data, GetClientUserId(client));
					WritePackCell(data, boss);
					ResetPack(data);
				}

				GetGameTime()<=KSpreeTimer[boss] ? (KSpreeCount[boss]+=1) : (KSpreeCount[boss]=1);  //Breaks if you do ++ or remove the parentheses...
				if(KSpreeCount[boss]==3)
				{
					if(RandomSound("sound_kspree", sound, PLATFORM_MAX_PATH, boss))
					{
						EmitSoundToAll(sound);
						EmitSoundToAll(sound);
					}
					KSpreeCount[boss]=0;
				}
				else
				{
					KSpreeTimer[boss]=GetGameTime()+5.0;
				}
			}
		}
		else
		{
			new boss=GetBossIndex(client);
			if(boss==-1 || (GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
			{
				return Plugin_Continue;
			}	

			if(RandomSound("sound_death", sound, PLATFORM_MAX_PATH, boss))
			{
				EmitSoundToAll(sound);
				EmitSoundToAll(sound);
			}
	
			BossHealth[boss]=0;
			UpdateHealthBar();

			Stabbed[boss]=0.0;
			Marketed[boss]=0.0;
		}

		if(TF2_GetPlayerClass(client)==TFClass_Engineer && !(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER))
		{
			new String:name[PLATFORM_MAX_PATH];
			FakeClientCommand(client, "destroy 2");
			for(new entity=MaxClients+1; entity<MAXENTITIES; entity++)
			{
				if(IsValidEdict(entity))
				{
					GetEdictClassname(entity, name, sizeof(name));
					if(!StrContains(name, "obj_sentrygun") && (GetEntPropEnt(entity, Prop_Send, "m_hBuilder")==client))
					{
						SetVariantInt(GetEntPropEnt(entity, Prop_Send, "m_iMaxHealth")+1);
						AcceptEntityInput(entity, "RemoveHealth");

						new Handle:eventRemoveObject=CreateEvent("object_removed", true);
						SetEventInt(eventRemoveObject, "userid", GetClientUserId(client));
						SetEventInt(eventRemoveObject, "index", entity);
						FireEvent(eventRemoveObject);
						AcceptEntityInput(entity, "kill");
					}
				}
			}
		}
	}
	else
	{
		isCosmetic=false;
	}
	return Plugin_Continue;
}

public Action:PlaySoundKill(Handle:timer, Handle:data)
{
	new client=GetClientOfUserId(ReadPackCell(data));
	if(client)
	{
		new String:classnames[][]={"", "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer"};
		new String:class[32], String:sound[PLATFORM_MAX_PATH];
		Format(class, sizeof(class), "sound_kill_%s", classnames[TF2_GetPlayerClass(client)]);
		if(RandomSound(class, sound, PLATFORM_MAX_PATH, ReadPackCell(data)))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}
	}
	return Plugin_Continue;
}

public Action:Timer_Damage(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	if(IsValidClient(client, false))
	{
		CPrintToChat(client, "{olive}[FF2] %t. %t{default}", "damage", Damage[client], "scores", RoundFloat(Damage[client]/600.0));
	}
	return Plugin_Continue;
}

public Action:Event_Deflect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!Enabled || GetEventInt(event, "weaponid"))  //0 means that the client was airblasted, which is what we want
	{
		return Plugin_Continue;
	}

	new boss=GetBossIndex(GetClientOfUserId(GetEventInt(event, "ownerid")));
	if(boss!=-1 && BossCharge[boss][0]<100.0)
	{
		BossCharge[boss][0]+=7.0;  //TODO: Allow this to be customizable
		if(BossCharge[boss][0]>100.0)
		{
			BossCharge[boss][0]=100.0;
		}
	}
	return Plugin_Continue;
}

public Action:Event_DeployBanner(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(Enabled && GetEventInt(event, "buff_type")==2)
	{
		FF2flags[GetClientOfUserId(GetEventInt(event, "buff_owner"))]|=FF2FLAG_ISBUFFED;
	}
	return Plugin_Continue;
}

public Action:Event_RocketJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(Enabled)
	{
		if(StrEqual(name, "rocket_jump", false))
		{
			FF2flags[GetClientOfUserId(GetEventInt(event, "userid"))]|=FF2FLAG_ROCKET_JUMPING;
		}
		else
		{
			FF2flags[GetClientOfUserId(GetEventInt(event, "userid"))]&=~FF2FLAG_ROCKET_JUMPING;
		}
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

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(!Enabled || CheckRoundState()!=FF2RoundState_RoundRunning)
	{
		return Plugin_Continue;
	}

	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker=GetClientOfUserId(GetEventInt(event, "attacker"));
	new boss=GetBossIndex(client);
	new damage=GetEventInt(event, "damageamount");
	new custom=GetEventInt(event, "custom");
	
	if(boss==-1 || !Boss[boss] || !IsValidEdict(Boss[boss]) || client==attacker)
	{
		return Plugin_Continue;
	}

	if(custom==TF_CUSTOM_TELEFRAG)
	{
		damage=(IsPlayerAlive(attacker) ? 9001 : 1);
	}
	else if(custom==TF_CUSTOM_BOOTS_STOMP)
	{
		damage*=5;
	}
	if(GetEventBool(event, "minicrit") && GetEventBool(event, "allseecrit"))
	{
		SetEventBool(event, "allseecrit", false);
	}

	if(custom==TF_CUSTOM_TELEFRAG || custom==TF_CUSTOM_BOOTS_STOMP)
	{
		SetEventInt(event, "damageamount", damage);
	}

	for(new lives=1; lives<BossLives[boss]; lives++)
	{
		if(BossHealth[boss]-damage<=BossHealthMax[boss]*lives)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", (BossHealth[boss]-damage)-BossHealthMax[boss]*(lives-1));  //Set the health early to avoid the boss dying from fire, etc.  //Set the health early to avoid the boss dying from fire, etc.

			new Action:action=Plugin_Continue, bossLives=BossLives[boss];  //Used for the forward
			Call_StartForward(OnLoseLife);
			Call_PushCell(boss);
			Call_PushCellRef(bossLives);
			Call_PushCell(BossLivesMax[boss]);
			Call_Finish(action);
			if(action==Plugin_Stop || action==Plugin_Handled)
			{
				return action;
			}
			else if(action==Plugin_Changed)
			{
				if(bossLives>BossLivesMax[boss])
				{
					BossLivesMax[boss]=bossLives;
				}
				BossLives[boss]=bossLives;
			}

			new String:ability[PLATFORM_MAX_PATH];
			for(new n=1; n<MAXRANDOMS; n++)
			{
				Format(ability, 10, "ability%i", n);
				KvRewind(BossKV[Special[boss]]);
				if(KvJumpToKey(BossKV[Special[boss]], ability))
				{
					if(KvGetNum(BossKV[Special[boss]], "arg0", 0)!=-1)
					{
						continue;
					}

					KvGetString(BossKV[Special[boss]], "life", ability, 10);
					if(!ability[0])
					{
						new String:abilityName[64], String:pluginName[64];
						KvGetString(BossKV[Special[boss]], "plugin_name", pluginName, sizeof(pluginName));
						KvGetString(BossKV[Special[boss]], "name", abilityName, sizeof(abilityName));
						UseAbility(abilityName, pluginName, boss, -1);
					}
					else
					{
						new String:stringLives[MAXRANDOMS][3];
						new count=ExplodeString(ability, " ", stringLives, MAXRANDOMS, 3);
						for(new j; j<count; j++)
						{
							if(StringToInt(stringLives[j])==BossLives[boss])
							{
								new String:abilityName[64], String:pluginName[64];
								KvGetString(BossKV[Special[boss]], "plugin_name", pluginName, sizeof(pluginName));
								KvGetString(BossKV[Special[boss]], "name", abilityName, sizeof(abilityName));
								UseAbility(abilityName, pluginName, boss, -1);
								break;
							}
						}
					}
				}
			}
			BossLives[boss]=lives;

			new String:bossName[64], String:nextlife[1024];
			KvRewind(BossKV[Special[boss]]);
			KvGetString(BossKV[Special[boss]], "name", bossName, sizeof(bossName), "=Failed name=");

			strcopy(ability, sizeof(ability), BossLives[boss]==1 ? "Last Life" : "Lost Life");
			for(new target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && !(FF2flags[target] & FF2FLAG_HUDDISABLED))
				{
					Format(nextlife, sizeof(nextlife), "%t", ability, bossName, BossLives[boss]);
					ShowGameText(nextlife);
				}
			}

			if(BossLives[boss]==1 && RandomSound("sound_last_life", ability, PLATFORM_MAX_PATH, boss))
			{
				EmitSoundToAll(ability);
				EmitSoundToAll(ability);
			}
			else if(RandomSound("sound_nextlife", ability, PLATFORM_MAX_PATH, boss))
			{
				EmitSoundToAll(ability);
				EmitSoundToAll(ability);
			}
			UpdateHealthBar();
			break;
		}
	}

	BossHealth[boss]-=damage;
	if(attacker != boss)
		BossCharge[boss][0]+=damage*100.0/BossRageDamage[boss];
	Damage[attacker]+=damage;

	new healers[MAXPLAYERS];
	new healerCount;
	for(new target; target<=MaxClients; target++)
	{
		if(IsValidClient(target) && IsPlayerAlive(target) && (GetHealingTarget(target, true)==attacker))
		{
			healers[healerCount]=target;
			healerCount++;
		}
	}

	for(new target; target<healerCount; target++)
	{
		if(IsValidClient(healers[target]) && IsPlayerAlive(healers[target]))
		{
			if(damage<10 || uberTarget[healers[target]]==attacker)
			{
				Damage[healers[target]]+=damage;
			}
			else
			{
				Damage[healers[target]]+=damage/(healerCount+1);
			}
		}
	}

	if(IsValidClient(attacker))
	{
		new weapon=GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary);
		if(IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==1104)  //Air Strike-moved from OTD
		{
			static airStrikeDamage;
			airStrikeDamage+=damage;
			if(airStrikeDamage>=200)
			{
				SetEntProp(attacker, Prop_Send, "m_iDecapitations", GetEntProp(attacker, Prop_Send, "m_iDecapitations")+1);
				airStrikeDamage-=200;
			}
		}
		
		if(!IsBoss(attacker) && IsValidEntity(weapon))
		{
			static kStreakCount;
			kStreakCount+=damage;
			if(kStreakCount>=200)
			{
				SetEntProp(attacker, Prop_Send, "m_nStreaks", GetEntProp(attacker, Prop_Send, "m_nStreaks")+1);
				switch(GetEntProp(attacker, Prop_Send, "m_nStreaks"))
				{
					case 5,10,15,20,25,50,75,100,150,200,250,500,750,1000:
					{
						isCosmetic=true;
						new Handle:hStreak = CreateEvent("player_death", true);
						SetEventBool(hStreak, "sourcemod", true);
						SetEventInt(hStreak,"attacker",GetClientUserId(attacker));
						SetEventInt(hStreak,"userid",GetClientUserId(client));
						SetEventInt(hStreak, "death_flags", TF_DEATHFLAG_DEADRINGER);
						SetEventInt(hStreak, "kill_streak_wep", GetEntProp(attacker, Prop_Send, "m_nStreaks"));
						SetEventInt(hStreak, "kill_streak_total", GetEntProp(attacker, Prop_Send, "m_nStreaks"));
						FireEvent(hStreak);
					}
				}
				kStreakCount-=200;
			}
		}
	}

	if(BossCharge[boss][0]>100.0)
	{
		BossCharge[boss][0]=100.0;
	}
	return Plugin_Continue;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if(!Enabled || !IsValidEdict(attacker))
	{
		return Plugin_Continue;
	}
	
	static bool:foundDmgCustom, bool:dmgCustomInOTD;
	if(!foundDmgCustom)
	{
		dmgCustomInOTD=(GetFeatureStatus(FeatureType_Capability, "SDKHook_DmgCustomInOTD")==FeatureStatus_Available);
		foundDmgCustom=true;
	}

	if((attacker<=0 || client==attacker) && IsBoss(client))
	{
		if(damagetype & DMG_FALL)
		{
			damage=1.0;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}

	if(TF2_IsPlayerInCondition(client, TFCond_Ubercharged))
	{
		return Plugin_Continue;
	}

	if(!CheckRoundState() && IsBoss(client))
	{
		damage*=0.0;
		return Plugin_Changed;
	}

	new Float:position[3];
	GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);
	if(IsBoss(attacker))
	{
		if(IsValidClient(client) && !IsBoss(client) && !TF2_IsPlayerInCondition(client, TFCond_Bonked))
		{
			if(damagecustom == TF_CUSTOM_BOOTS_STOMP)
			{
				damage = float(GetClientHealth(client));
				return Plugin_Changed;
			}		

			if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffed))
			{
				ScaleVector(damageForce, 9.0);
				damage*=0.3;
				return Plugin_Changed;
			}

			if(TF2_IsPlayerInCondition(client, TFCond_DefenseBuffMmmph))
			{
				damage*=9;
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				return Plugin_Changed;
			}

			if(TF2_IsPlayerInCondition(client, TFCond_CritMmmph))
			{
				damage*=0.25;
				return Plugin_Changed;
			}

			if(shield[client])
			{
				TF2_RemoveWearable(client, shield[client]);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
				TF2_AddCondition(client, TFCond_Bonked, 0.1);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
				shield[client]=0;
				return Plugin_Continue;
			}

			switch(TF2_GetPlayerClass(client))
			{
				case TFClass_Spy:
				{
					if((GetEntProp(client, Prop_Send, "m_bFeignDeathReady") && !TF2_IsPlayerInCondition(client, TFCond_Cloaked)))
					{
						if(damagetype & DMG_CRIT)
						{
							damagetype&=~DMG_CRIT;
						}
						damage=620.0;
						return Plugin_Changed;
					}
					else if(TF2_IsPlayerInCondition(client, TFCond_Cloaked))
					{
						if(damagetype & DMG_CRIT)
						{
							damagetype&=~DMG_CRIT;
						}

						if(TF2_IsPlayerInCondition(client, TFCond_DeadRingered))
						{
							damage=620.0;
						}
						else
						{
							damage=850.0;
						}
						return Plugin_Changed;
					}
				}
				case TFClass_Soldier:
				{
					if(IsValidEdict((weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary))) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==226 && !(FF2flags[client] & FF2FLAG_ISBUFFED))  //Battalion's Backup
					{
						SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0);
					}
				}
			}
			
			if(dmgTriple[attacker] && damage<=160.0)
			{
				damage*=3;
				return Plugin_Changed;
			}
		}
	}
	else
	{
		new boss=GetBossIndex(client);
		if(boss!=-1)
		{
			if(attacker<=MaxClients)
			{
				new bool:bIsTelefrag, bool:bIsBackstab;
				new bChanged = false;
				if (inflictor == attacker || inflictor == weapon)
				{
					#if defined _tf2attributes_included
					if(tf2attributes)
					{
						if (!(damagetype & DMG_BLAST) && (GetEntityFlags(boss) & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))	//If Boss is ducking on the ground, it's harder to knock them back
						{
							damagetype |= DMG_PREVENT_PHYSICS_FORCE;
							TF2Attrib_SetByName(boss, "damage force reduction", 0.0);
							bChanged = true;
						}
						else
						{
							TF2Attrib_RemoveByName(boss, "damage force reduction");
						}
					}
					else
					{
						if ((GetEntityFlags(boss) & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))	
						{
							damagetype |= DMG_PREVENT_PHYSICS_FORCE;
							bChanged = true;
						}						
					}
					#else
					// Does not protect against sentries or FaN, but does against miniguns and rockets
					if ((iFlags & (FL_ONGROUND|FL_DUCKING)) == (FL_ONGROUND|FL_DUCKING))	
					{
						damagetype |= DMG_PREVENT_PHYSICS_FORCE;
						bChanged = true;
					}
					#endif
					
					if (bChanged)
					{
						return Plugin_Changed;
					}
				}
				
				if(dmgCustomInOTD)
				{
					if(damagecustom==TF_CUSTOM_BACKSTAB)
					{
						bIsBackstab=true;
					}
					else if(damagecustom==TF_CUSTOM_TELEFRAG)
					{
						bIsTelefrag=true;
					}
				}
				else if(weapon!=4095 && IsValidEdict(weapon) && weapon==GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee) && damage>1000.0)
				{
					new String:classname[32];
					if(GetEdictClassname(weapon, classname, sizeof(classname)) && !strcmp(classname, "tf_weapon_knife", false))
					{
						bIsBackstab=true;
					}
				}
				else if(!IsValidEntity(weapon) && (damagetype & DMG_CRUSH)==DMG_CRUSH && damage==1000.0)
				{
					bIsTelefrag=true;
				}

				if(bIsTelefrag)
				{
					damagecustom=0;
					if(!IsPlayerAlive(attacker))
					{
						damage=1.0;
						return Plugin_Changed;
					}
					damage=(BossHealth[boss]>9001 ? 9001.0 : float(GetEntProp(Boss[boss], Prop_Send, "m_iHealth"))+90.0);

					new teleowner=FindTeleOwner(attacker);
					if(IsValidClient(teleowner) && teleowner!=attacker)
					{
						Damage[teleowner]+=9001*3/5;
						if(!(FF2flags[teleowner] & FF2FLAG_HUDDISABLED))
						{
							PrintHintText(teleowner, "%t", "Telefrag Assist");
						}
					}

					if(!(FF2flags[attacker] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(attacker, "%t", "Telefrag");
					}

					if(!(FF2flags[client] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(client, "%t", "Telefragged");
					}
					return Plugin_Changed;
				}

				new index;
				decl String:classname[64];
				if(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients)
				{
					GetEntityClassname(weapon, classname, sizeof(classname));
					if(!StrContains(classname, "eyeball_boss"))  //Dang spell Monoculi
					{
						index=-1;
						Format(classname, sizeof(classname), "");
					}
					else
					{
						index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
					}
				}
				else
				{
					index=-1;
				 	Format(classname, sizeof(classname), "");
				}

				switch(index)
				{
					case 61, 1006:  //Ambassador, Festive Ambassador
					{
						if(damagecustom==TF_CUSTOM_HEADSHOT)
						{
							damage=85.0;  //Final damage 255
						}
					}
					case 1, 191, 609: //Bottle, Scottish Handshake
					{
						if(GetEntProp(weapon, Prop_Send, "m_bBroken")==1)
						{
							TF2_MakeBleed(boss, attacker, 5.0);
						}
					}
					case 132, 266, 482, 1082:  //Eyelander, HHHH, Nessie's Nine Iron, Festive Eyelander
					{
						IncrementHeadCount(attacker);
					}
					case 214:  //Powerjack
					{
						new health=GetClientHealth(attacker);
						new max=GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						new newhealth=health+50;
						if(health<max+100)
						{
							if(newhealth>max+100)
							{
								newhealth=max+100;
							}
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}

						if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						{
							TF2_RemoveCondition(attacker, TFCond_OnFire);
						}
					}
					case 317:  //Candycane
					{
						SpawnSmallHealthPackAt(client, GetClientTeam(attacker));
					}
					case 355:  //Fan O' War
					{
						if(BossCharge[boss][0]>0.0)
						{
							BossCharge[boss][0]-=10.0;
							if(BossCharge[boss][0]<0.0)
							{
								BossCharge[boss][0]=0.0;
							}
						}
					}
					case 357:  //Half-Zatoichi
					{
						SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
						if(GetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy")<1)
						{
							SetEntProp(attacker, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
						}

						new health=GetClientHealth(attacker);
						new max=GetEntProp(attacker, Prop_Data, "m_iMaxHealth");
						new newhealth=health+50;
						if(health<max+100)
						{
							if(newhealth>max+100)
							{
								newhealth=max+100;
							}
							SetEntProp(attacker, Prop_Data, "m_iHealth", newhealth);
							SetEntProp(attacker, Prop_Send, "m_iHealth", newhealth);
						}
						if(TF2_IsPlayerInCondition(attacker, TFCond_OnFire))
						{
							TF2_RemoveCondition(attacker, TFCond_OnFire);
						}
					}
					case 307, 416:   // Chdata's Market Gardener backstab + VoIDeD's Caber backstab
                    {
                        if (RemoveCond(attacker, TFCond_BlastJumping)) // New way to check explosive jumping status
                        {
							if(index == 307 && GetEntProp(weapon, Prop_Send, "m_iDetonated") == 1) // If using ullapool caber, only trigger if bomb hasn't been detonated
								return Plugin_Continue;
						
							damage=(Pow(float(BossHealthMax[boss]), 0.74074)+512.0-(Marketed[client]/128.0*float(BossHealthMax[boss])))/3.0;
							damagetype |= DMG_CRIT;
							
							if (RemoveCond(attacker, TFCond_Parachute))   // If you parachuted to do this, remove your parachute.
							{
								damage *= 0.67;                       //  And nerf your damage
							}

							if(Marketed[client]<5)
							{
								Marketed[client]++;
							}
							
							if(index==307)
							{
								SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
								SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
							}
							
							airstab[attacker]++;
							
							isCosmetic=true;
							new Handle:hStreak = CreateEvent("player_death", true);
							SetEventBool(hStreak, "sourcemod", true);
							SetEventString(hStreak,"weapon", index==307 ? "ullapool_caber_explosion" : "market_gardener");
							SetEventString(hStreak,"weapon_logclassname", index==307 ? "ullapool_caber_explosion" : "market_gardener");
							SetEventInt(hStreak,"attacker",GetClientUserId(attacker));
							SetEventInt(hStreak,"userid",GetClientUserId(client));
							SetEventInt(hStreak, "death_flags", TF_DEATHFLAG_DEADRINGER);
							SetEventInt(hStreak, "kill_streak_wep", airstab[attacker]);
							FireEvent(hStreak);

							new String:spcl[768];
							FF2_GetBossSpecial(boss, spcl, sizeof(spcl));
							PrintHintText(attacker, "%t", (index == 416 ? "Market Gardener" : "Ullapool Caber"), spcl);  //You just market-gardened the boss!
							PrintHintText(client, "%t", (index == 416 ? "Market Gardened" : "Ullapool Cabered"));  //You just got market-gardened!

							EmitSoundToClient(attacker, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);
							EmitSoundToClient(client, "player/doubledonk.wav", _, _, _, _, 0.6, _, _, position, _, false);

							return Plugin_Changed;
                        }
                    }					
					case 447: // Disciplinary action
					{
						if(!TF2_IsPlayerInCondition(attacker, TFCond_SpeedBuffAlly))
						{
							TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 5.0);
						}
					}
					case 525, 595:  //Diamondback, Manmelter
					{
						if(GetEntProp(attacker, Prop_Send, "m_iRevengeCrits"))  //If a revenge crit was used, give a damage bonus
						{
							damage=85.0;  //255 final damage
						}
					}
					case 528:  //Short Circuit
					{
						if(circuitStun)
						{
							if(!TF2_IsPlayerInCondition(client, TFCond_Dazed))
							{
								TF2_StunPlayer(client, circuitStun, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
								SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+3.0);
								SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+3.0);
							}
						}
					}
					case 593:  //Third Degree
					{
						new healers[MAXPLAYERS];
						new healerCount;
						for(new healer; healer<=MaxClients; healer++)
						{
							if(IsValidClient(healer) && IsPlayerAlive(healer) && (GetHealingTarget(healer, true)==attacker))
							{
								healers[healerCount]=healer;
								healerCount++;
							}
						}

						for(new healer; healer<healerCount; healer++)
						{
							if(IsValidClient(healers[healer]) && IsPlayerAlive(healers[healer]))
							{
								new medigun=GetPlayerWeaponSlot(healers[healer], TFWeaponSlot_Secondary);
								if(IsValidEntity(medigun))
								{
									new String:medigun_classname[64];
									GetEdictClassname(medigun, medigun_classname, sizeof(medigun_classname));
									if(!strcmp(medigun_classname, "tf_weapon_medigun", false))
									{
										new Float:uber=GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")+(0.1/healerCount);
										new Float:max=1.0;
										if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
										{
											max=1.5;
										}

										if(uber>max)
										{
											uber=max;
										}
										SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", uber);
									}
								}
							}
						}
					}
					case 594:  //Phlogistinator
					{
						if(!TF2_IsPlayerInCondition(attacker, TFCond_CritMmmph))
						{
							damage/=2.0;
						}
					}
					case 1099:  //Tide Turner
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", 100.0);
					}
				}
				
				if(!StrContains(classname, "tf_weapon_sniperrifle"))
				{
					if(CheckRoundState()!=FF2RoundState_RoundEnd)
					{
						new Float:charge=(IsValidEntity(weapon) && weapon>MaxClients ? GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage") : 0.0);
						if(index==752)  //Hitman's Heatmaker
						{
							new Float:focus=10+(charge/10);
							if(TF2_IsPlayerInCondition(attacker, TFCond_FocusBuff))
							{
								focus/=3;
							}
							new Float:rage=GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
							SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", (rage+focus>100) ? 100.0 : rage+focus);
						}
						else if(index!=230 && index!=402 && index!=526)  //Sydney Sleeper, Bazaar Bargain, Machina
						{
							new Float:time=(GlowTimer[boss]>10 ? 1.0 : 2.0);
							time+=(GlowTimer[boss]>10 ? (GlowTimer[boss]>20 ? 1.0 : 2.0) : 4.0)*(charge/100.0);
							SetClientGlow(Boss[boss], time);
							if(GlowTimer[boss]>30.0)
							{
								GlowTimer[boss]=30.0;
							}
						}

						if(!(damagetype & DMG_CRIT))
						{
							if(TF2_IsPlayerInCondition(attacker, TFCond_CritCola) || TF2_IsPlayerInCondition(attacker, TFCond_Buffed))
							{
								damage*=2.2;
							}
							else
							{
								if(index!=230 || BossCharge[boss][0]>90.0)  //Sydney Sleeper
								{
									damage*=3.0;
								}
								else
								{
									damage*=2.4;
								}
							}
							return Plugin_Changed;
						}
					}
				}
				
				if(bIsBackstab)
				{
					damage=BossHealthMax[boss]*(LastBossIndex()+1)*BossLivesMax[boss]*(0.12-Stabbed[boss]/90)/3;
					damagetype|=DMG_CRIT;
					damagecustom=0;

					EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					EmitSoundToClient(client, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
					EmitSoundToClient(attacker, "player/crit_received3.wav", _, _, _, _, 0.7, _, _, _, _, false);
					SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+2.0);
					SetEntPropFloat(attacker, Prop_Send, "m_flStealthNextChangeTime", GetGameTime()+2.0);
					new viewmodel=GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
					if(viewmodel>MaxClients && IsValidEntity(viewmodel) && TF2_GetPlayerClass(attacker)==TFClass_Spy)
					{
						new melee=GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
						new animation=15;
						switch(melee)
						{
							case 727:  //Black Rose
							{
								animation=41;
							}
							case 4, 194, 665, 794, 803, 883, 892, 901, 910:  //Knife, Strange Knife, Festive Knife, Botkiller Knifes
							{
								animation=10;
							}
							case 638:  //Sharp Dresser
							{
								animation=31;
							}
						}
						SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
					}

					if(!(FF2flags[attacker] & FF2FLAG_HUDDISABLED))
					{
						new String:spcl[768];
						FF2_GetBossSpecial(boss, spcl, sizeof(spcl));
						PrintHintText(attacker, "%t", "Backstab", spcl);
					}

					if(!(FF2flags[client] & FF2FLAG_HUDDISABLED))
					{
						PrintHintText(client, "%t", "Backstabbed");
					}

					if(index==225 || index==574)  //Your Eternal Reward, Wanga Prick
					{
						CreateTimer(0.3, Timer_DisguiseBackstab, GetClientUserId(attacker));
					}
					else if(index==356)  //Conniver's Kunai
					{
						new health=GetClientHealth(attacker)+200;
						if(health>500)
						{
							health=500;
						}
						SetEntProp(attacker, Prop_Data, "m_iHealth", health);
						SetEntProp(attacker, Prop_Send, "m_iHealth", health);
					}
					else if(index==461)  //Big Earner
					{
						SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", 100.0);  //Full cloak
						if(!TF2_IsPlayerInCondition(attacker, TFCond_SpeedBuffAlly))
						{
							TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 3.0);
						}
					}

					if(GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Primary)==525)  //Diamondback
					{
						SetEntProp(attacker, Prop_Send, "m_iRevengeCrits", GetEntProp(attacker, Prop_Send, "m_iRevengeCrits")+2);
					}

					new String:sound[PLATFORM_MAX_PATH];
					if(RandomSound("sound_stabbed", sound, PLATFORM_MAX_PATH, boss))
					{
						EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
						EmitSoundToAllExcept(SOUNDEXCEPT_VOICE, sound, _, _, _, _, _, _, Boss[boss], _, _, false);
					}

					if(Stabbed[boss]<3)
					{
						Stabbed[boss]++;
					}
					return Plugin_Changed;
				}
			}
			else
			{
				new String:classname[64];
				if(GetEdictClassname(attacker, classname, sizeof(classname)) && !strcmp(classname, "trigger_hurt", false))
				{
					if (bSpawnTeleOnTriggerHurt && IsBoss(client) && CheckRoundState()==FF2RoundState_RoundRunning)
					{
						// Teleport the boss back to one of the spawns.
						// And during the first 30 seconds, they can only teleport to their own spawn.
						TeleportToMultiMapSpawn(client, (RoundTick<30) ? (TFTeam:BossTeam) : (TFTeam_Unassigned));
					}
					
					new Action:action=Plugin_Continue;
					Call_StartForward(OnTriggerHurt);
					Call_PushCell(boss);
					Call_PushCell(attacker);
					new Float:damage2=damage;
					Call_PushFloatRef(damage2);
					Call_Finish(action);
					if(action!=Plugin_Stop && action!=Plugin_Handled)
					{
						if(action==Plugin_Changed)
						{
							damage=damage2;
						}
						
						if(damage>=float(BossHealthMax[boss]) || damage>1000.0)
						{
							damage=float(BossHealthMax[boss]/20); // Divide damage by 20
						}
						
						if(!strcmp(currentmap, "arena_arakawa_b3", false) && damage>1000.0)
						{
							damage=490.0;
						}
						BossHealth[boss]-=RoundFloat(damage);
						BossCharge[boss][0]+=damage*100.0/BossRageDamage[boss];
						if(BossHealth[boss]<=0)  //Wat
						{
							damage*=5;
						}
						if(BossCharge[boss][0]>100.0)
						{
							BossCharge[boss][0]=100.0;
						}
						return Plugin_Changed;
					}
					else
					{
						return action;
					}
				}
			}
			if(BossCharge[boss][0]>100.0)
			{
				BossCharge[boss][0]=100.0;
			}
		}
		else
		{
			new index=(IsValidEntity(weapon) && weapon>MaxClients && attacker<=MaxClients ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1);
			if(index==307)  //Ullapool Caber
			{
				if(detonations[attacker]<allowedDetonations && !RemoveCond(attacker, TFCond_BlastJumping)) // Ignore if caber 'backstabbing'
				{
					detonations[attacker]++;
					PrintHintText(attacker, "%t", "Detonations Left", allowedDetonations-detonations[attacker]);
					if(allowedDetonations-detonations[attacker])  //Don't reset their caber if they have 0 detonations left
					{
						SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
						SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
					}
				}
			}

			if(IsValidClient(client, false) && TF2_GetPlayerClass(client)==TFClass_Soldier)  //TODO: LOOK AT THIS
			{
				if(damagetype & DMG_FALL)
				{
					new secondary=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
					if(secondary<=0 || !IsValidEntity(secondary))
					{
						damage/=10.0;
						return Plugin_Changed;
					}
				}
			}
		}
	}
	return Plugin_Continue;
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

public Action:OnStomp(attacker, victim, &Float:damageMultiplier, &Float:damageBonus, &Float:JumpPower)
{
	if(!Enabled || !IsValidClient(attacker) || !IsValidClient(victim) || attacker==victim)
	{
		return Plugin_Continue;
	}
	
	if(IsBoss(attacker))
	{
		new boss = FF2_GetBossIndex(attacker);
		new String:spcl[768];
		FF2_GetBossSpecial(boss, spcl, sizeof(spcl));
		
		if(shield[victim])
		{
			new Float:position[3];
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", position);

			TF2_RemoveWearable(victim, shield[victim]);
			EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
			EmitSoundToClient(victim, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
			EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
			EmitSoundToClient(attacker, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
			TF2_AddCondition(victim, TFCond_Bonked, 0.1);
			TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 1.0);
			shield[victim]=0;
			return Plugin_Handled;
		}
		damageMultiplier=900.0;
		JumpPower=0.0;
		PrintHintText(victim, "%t","Goomba Stomped Player", spcl);
		PrintHintText(attacker, "%t", "Boss Goomba Stomps", victim);
		return Plugin_Changed;
	}
	else if(IsBoss(victim))
	{
	
		new boss = FF2_GetBossIndex(victim);
		new String:spcl[768];
		FF2_GetBossSpecial(boss, spcl, sizeof(spcl));
		
		GoombaCount[attacker]++;
		
		isCosmetic=true;
		new Handle:hStreak = CreateEvent("player_death", true);
		SetEventBool(hStreak, "sourcemod", true);
		SetEventString(hStreak,"weapon", "mantreads");
		SetEventString(hStreak,"weapon_logclassname", "mantreads");
		SetEventInt(hStreak,"attacker",GetClientUserId(attacker));
		SetEventInt(hStreak,"userid",GetClientUserId(victim));
		SetEventInt(hStreak, "death_flags", TF_DEATHFLAG_DEADRINGER);
		SetEventInt(hStreak, "kill_streak_wep", GoombaCount[attacker]);
		FireEvent(hStreak);
		
		damageMultiplier=GoombaDamage;
		JumpPower=reboundPower;
		PrintHintText(victim, "%t", "Goomba Stomped Boss", GoombaCount[attacker], attacker);
		PrintHintText(attacker, "%t", "Player Goomba Stomps", spcl, GoombaCount[attacker]);
		UpdateHealthBar();
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:RTD_CanRollDice(client)
{
	if(Enabled && IsBoss(client) && !canBossRTD)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:OnGetMaxHealth(client, &maxHealth)
{
	if(Enabled && IsBoss(client))
	{
		new boss=GetBossIndex(client);
		SetEntProp(client, Prop_Data, "m_iHealth", BossHealth[boss]-BossHealthMax[boss]*(BossLives[boss]-1));
		maxHealth=BossHealthMax[boss];
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

stock GetClientCloakIndex(client)
{
	if(!IsValidClient(client, false))
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

stock SpawnSmallHealthPackAt(client, team=0)
{
	if(!IsValidClient(client, false) || !IsPlayerAlive(client))
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
		SetEntProp(healthpack, Prop_Send, "m_iTeamNum", team, 4);
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
	SetEntProp(client, Prop_Data, "m_iHealth", health+15);
	SetEntProp(client, Prop_Send, "m_iHealth", health+15);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
}

stock FindTeleOwner(client)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
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
	if(IsValidClient(client, false))
	{
		RandomlyDisguise(client);
	}
	return Plugin_Continue;
}

stock RandomlyDisguise(client)	//Original code was mecha's, but the original code is broken and this uses a better method now.
{
	if(IsValidClient(client) && IsPlayerAlive(client))
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

public SickleClimbWalls(client, weapon)	 //Credit to Mecha the Slag
{
	if (!IsValidClient(client) || (GetClientHealth(client)<=15) )return;

	new String:classname[64];
	new Float:vecClientEyePos[3];
	new Float:vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos);   // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng);	   // Get the angle the player is looking

	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, client);

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
	new winner;
	for(new client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && GetClientQueuePoints(client)>=GetClientQueuePoints(winner) && !omit[client])
		{
			if(GetClientTeam(client)>_:TFTeam_Spectator)
			{
				winner=client;
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
			if(ClientCookie2[client]==TOGGLE_OFF) // Skip clients who have disabled being able to be selected as a companion
				continue;
		
			if(GetClientTeam(client)>_:TFTeam_Spectator)
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

stock GetBossIndex(client)
{
	if(client>0 && client<=MaxClients)
	{
		for(new boss; boss<=MaxClients; boss++)
		{
			if(Boss[boss]==client)
			{
				return boss;
			}
		}
	}
	return -1;
}

stock Operate(Handle:sumArray, &bracket, Float:value, Handle:_operator)
{
	new Float:sum=GetArrayCell(sumArray, bracket);
	switch(GetArrayCell(_operator, bracket))
	{
		case Operator_Add:
		{
			SetArrayCell(sumArray, bracket, sum+value);
		}
		case Operator_Subtract:
		{
			SetArrayCell(sumArray, bracket, sum-value);
		}
		case Operator_Multiply:
		{
			SetArrayCell(sumArray, bracket, sum*value);
		}
		case Operator_Divide:
		{
			if(!value)
			{
				LogError("[FF2 Bosses] Detected a divide by 0!");
				bracket=0;
				return;
			}
			SetArrayCell(sumArray, bracket, sum/value);
		}
		case Operator_Exponent:
		{
			SetArrayCell(sumArray, bracket, Pow(sum, value));
		}
		default:
		{
			SetArrayCell(sumArray, bracket, value);  //This means we're dealing with a constant
		}
	}
	SetArrayCell(_operator, bracket, Operator_None);
}

stock OperateString(Handle:sumArray, &bracket, String:value[], size, Handle:_operator)
{
	if(!StrEqual(value, ""))  //Make sure 'value' isn't blank
	{
		Operate(sumArray, bracket, StringToFloat(value), _operator);
		strcopy(value, size, "");
	}
}

stock ParseFormula(client)
{

	decl String:formula[1024], String:bossName[64];
	KvRewind(BossKV[Special[client]]);
	KvGetString(BossKV[Special[client]], "name", bossName, sizeof(bossName), "=Failed name=");
	KvGetString(BossKV[Special[client]], "health_formula", formula, sizeof(formula));
	
	if(formula[0]!='\0')
	{
		if(KvGetNum(BossKV[Special[client]], "subversion")<30 && playing<5)
		{
			playing+=2;
		}
	}
	else
	{
		formula="(((760.8+n)*(n-1))^1.0341)+2046";
	}
	
	ReplaceString(formula, sizeof(formula), " ", "");  //Get rid of spaces	
	
	new size=1;
	new matchingBrackets;
	for(new i; i<=strlen(formula); i++)  //Resize the arrays once so we don't have to worry about it later on
	{
		if(formula[i]=='(')
		{
			if(!matchingBrackets)
			{
				size++;
			}
			else
			{
				matchingBrackets--;
			}
		}
		else if(formula[i]==')')
		{
			matchingBrackets++;
		}
	}

	new Handle:sumArray=CreateArray(_, size), Handle:_operator=CreateArray(_, size);
	new bracket;  //Each bracket denotes a separate sum (within parentheses).  At the end, they're all added together to achieve the actual sum
	SetArrayCell(sumArray, 0, 0.0);  //TODO:  See if these can be placed naturally in the loop
	SetArrayCell(_operator, bracket, Operator_None);

	new String:character[2], String:value[16];  //We don't decl value because we directly append characters to it and there's no point in decl'ing character
	for(new i; i<=strlen(formula); i++)
	{
		character[0]=formula[i];  //Find out what the next char in the formula is
		switch(character[0])
		{
			case ' ', '\t':  //Ignore whitespace
			{
				continue;
			}
			case '(':
			{
				bracket++;  //We've just entered a new parentheses so increment the bracket value
				SetArrayCell(sumArray, bracket, 0.0);
				SetArrayCell(_operator, bracket, Operator_None);
			}
			case ')':
			{
				OperateString(sumArray, bracket, value, sizeof(value), _operator);
				if(GetArrayCell(_operator, bracket)!=Operator_None)  //Something like (5*)
				{
					LogError("[FF2 Bosses] %s's %s formula has an invalid operator at character %i", bossName, formula, i+1);
					CloseHandle(sumArray);
					CloseHandle(_operator);
					return formula="(((760.8+n)*(n-1))^1.0341)+2046";
				}

				if(--bracket<0)  //Something like (5))
				{
					LogError("[FF2 Bosses] %s's %s formula has an unbalanced parentheses at character %i", bossName, formula, i+1);
					CloseHandle(sumArray);
					CloseHandle(_operator);
					return formula="(((760.8+n)*(n-1))^1.0341)+2046";
				}

				Operate(sumArray, bracket, GetArrayCell(sumArray, bracket+1), _operator);
			}
			case '\0':  //End of formula
			{
				OperateString(sumArray, bracket, value, sizeof(value), _operator);
			}
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.':
			{
				StrCat(value, sizeof(value), character);  //Constant?  Just add it to the current value
			}
			case 'n', 'x':  //n and x denote player variables
			{
				Operate(sumArray, bracket, float(playing), _operator);
			}
			case '+', '-', '*', '/', '^':
			{
				OperateString(sumArray, bracket, value, sizeof(value), _operator);
				switch(character[0])
				{
					case '+':
					{
						SetArrayCell(_operator, bracket, Operator_Add);
					}
					case '-':
					{
						SetArrayCell(_operator, bracket, Operator_Subtract);
					}
					case '*':
					{
						SetArrayCell(_operator, bracket, Operator_Multiply);
					}
					case '/':
					{
						SetArrayCell(_operator, bracket, Operator_Divide);
					}
					case '^':
					{
						SetArrayCell(_operator, bracket, Operator_Exponent);
					}
				}
			}
		}
	}
	
	new result=RoundFloat(GetArrayCell(sumArray, 0));
	CloseHandle(sumArray);
	CloseHandle(_operator);
	if(result<=0)
	{
		LogError("[FF2] %s has an invalid %s formula, using default!", bossName, formula);
		return formula="(((760.8+n)*(n-1))^1.0341)+2046";
	}

	if(bMedieval)
	{
		return RoundFloat(result/3.6);  //TODO: Make this configurable
	}
	return result;
}

stock GetAbilityArgument(index,const String:plugin_name[],const String:ability_name[],arg,defvalue=0)
{
	if(index==-1 || Special[index]==-1 || !BossKV[Special[index]])
		return 0;
	KvRewind(BossKV[Special[index]]);
	new String:s[10];
	for(new i=1; i<MAXRANDOMS; i++)
	{
		Format(s,10,"ability%i",i);
		if(KvJumpToKey(BossKV[Special[index]],s))
		{
			new String:ability_name2[64];
			KvGetString(BossKV[Special[index]], "name",ability_name2,64);
			if(strcmp(ability_name,ability_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			new String:plugin_name2[64];
			KvGetString(BossKV[Special[index]], "plugin_name",plugin_name2,64);
			if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			Format(s,10,"arg%i",arg);
			return KvGetNum(BossKV[Special[index]], s,defvalue);
		}
	}
	return 0;
}

stock Float:GetAbilityArgumentFloat(index,const String:plugin_name[],const String:ability_name[],arg,Float:defvalue=0.0)
{
	if(index==-1 || Special[index]==-1 || !BossKV[Special[index]])
		return 0.0;
	KvRewind(BossKV[Special[index]]);
	new String:s[10];
	for(new i=1; i<MAXRANDOMS; i++)
	{
		Format(s,10,"ability%i",i);
		if(KvJumpToKey(BossKV[Special[index]],s))
		{
			new String:ability_name2[64];
			KvGetString(BossKV[Special[index]], "name",ability_name2,64);
			if(strcmp(ability_name,ability_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			new String:plugin_name2[64];
			KvGetString(BossKV[Special[index]], "plugin_name",plugin_name2,64);
			if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			Format(s,10,"arg%i",arg);
			new Float:see=KvGetFloat(BossKV[Special[index]], s,defvalue);
			return see;
		}
	}
	return 0.0;
}

stock GetAbilityArgumentString(index,const String:plugin_name[],const String:ability_name[],arg,String:buffer[],buflen,const String:defvalue[]="")
{
	if(index==-1 || Special[index]==-1 || !BossKV[Special[index]])
	{
		strcopy(buffer,buflen,"");
		return;
	}
	KvRewind(BossKV[Special[index]]);
	new String:s[10];
	for(new i=1; i<MAXRANDOMS; i++)
	{
		Format(s,10,"ability%i",i);
		if(KvJumpToKey(BossKV[Special[index]],s))
		{
			new String:ability_name2[64];
			KvGetString(BossKV[Special[index]], "name",ability_name2,64);
			if(strcmp(ability_name,ability_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			new String:plugin_name2[64];
			KvGetString(BossKV[Special[index]], "plugin_name",plugin_name2,64);
			if(plugin_name[0] && plugin_name2[0] && strcmp(plugin_name,plugin_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			Format(s,10,"arg%i",arg);
			KvGetString(BossKV[Special[index]], s,buffer,buflen,defvalue);
		}
	}
}

stock bool:RandomSound(const String:sound[], String:file[], length, boss=0)
{
	if(boss<0 || Special[boss]<0 || !BossKV[Special[boss]])
	{
		return false;
	}

	KvRewind(BossKV[Special[boss]]);
	if(!KvJumpToKey(BossKV[Special[boss]], sound))
	{
		KvRewind(BossKV[Special[boss]]);
		return false;  //Requested sound not implemented for this boss
	}

	new String:key[4];
	new sounds;
	while(++sounds)  //Just keep looping until there's no keys left
	{
		IntToString(sounds, key, sizeof(key));
		KvGetString(BossKV[Special[boss]], key, file, length);
		if(!file[0])
		{
			sounds--;  //This sound wasn't valid, so don't include it
			break;  //Assume that there's no more sounds
		}
	}

	if(!sounds)
	{
		return false;  //Found sound, but no sounds inside of it
	}

	IntToString(GetRandomInt(1, sounds), key, sizeof(key));
	KvGetString(BossKV[Special[boss]], key, file, length);  //Populate file
	return true;
}

stock bool:RandomSoundAbility(const String:sound[], String:file[], length, boss=0, slot=0)
{
	if(boss==-1 || Special[boss]==-1 || !BossKV[Special[boss]])
	{
		return false;
	}

	KvRewind(BossKV[Special[boss]]);
	if(!KvJumpToKey(BossKV[Special[boss]], sound))
	{
		return false;  //Sound doesn't exist
	}

	new String:key[10];
	new sounds, matches, match[MAXRANDOMS];
	while(++sounds)
	{
		IntToString(sounds, key, 4);
		KvGetString(BossKV[Special[boss]], key, file, length);
		if(!file[0])
		{
			break;  //Assume that there's no more sounds
		}

		Format(key, sizeof(key), "slot%i", sounds);
		if(KvGetNum(BossKV[Special[boss]], key, 0)==slot)
		{
			match[matches]=sounds;  //Found a match: let's store it in the array
			matches++;
		}
	}

	if(!matches)
	{
		return false;  //Found sound, but no sounds inside of it
	}

	IntToString(match[GetRandomInt(0, matches-1)], key, 4);
	KvGetString(BossKV[Special[boss]], key, file, length);  //Populate file
	return true;
}

ForceTeamWin(team)
{
	new entity=FindEntityByClassname2(-1, "team_control_point_master");
	if(entity==-1)
	{
		entity=CreateEntityByName("team_control_point_master");
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(entity, "SetWinner");
}

public bool:PickCharacter(boss, companion)
{
	if(boss==companion)
	{
		Special[boss]=Incoming[boss];
		Incoming[boss]=-1;
		if(Special[boss]!=-1)  //We've already picked a boss through Command_SetNextBoss
		{
			new Action:action;
			Call_StartForward(OnSpecialSelected);
			Call_PushCell(boss);
			new characterIndex=Special[boss];
			Call_PushCellRef(characterIndex);
			decl String:newName[64];
			KvRewind(BossKV[Special[boss]]);
			KvGetString(BossKV[Special[boss]], "name", newName, sizeof(newName));
			Call_PushStringEx(newName, sizeof(newName), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
			Call_Finish(action);
			if(action==Plugin_Changed)
			{
				if(newName[0])
				{
					decl String:characterName[64];
					new foundExactMatch, foundPartialMatch;
					for(new character; BossKV[character] && character<MAXSPECIALS; character++)
					{
						KvRewind(BossKV[character]);
						KvGetString(BossKV[character], "name", characterName, sizeof(characterName));
						if(StrEqual(newName, characterName, false))
						{
							foundExactMatch=character;
							break;  //If we find an exact match there's no reason to keep looping
						}
						else if(StrContains(newName, characterName, false)!=-1)
						{
							foundPartialMatch=character;
						}

						//Do the same thing as above here, but look at the filename instead of the boss name
						KvGetString(BossKV[character], "filename", characterName, sizeof(characterName));
						if(StrEqual(newName, characterName, false))
						{
							foundExactMatch=character;
							break;  //If we find an exact match there's no reason to keep looping
						}
						else if(StrContains(newName, characterName, false)!=-1)
						{
							foundPartialMatch=character;
						}
					}

					if(foundExactMatch)
					{
						Special[boss]=foundExactMatch;
					}
					else if(foundPartialMatch)
					{
						Special[boss]=foundPartialMatch;
					}
					else
					{
						return false;
					}
					PrecacheCharacter(Special[boss]);
					return true;
				}
				Special[boss]=characterIndex;
				PrecacheCharacter(Special[boss]);
				return true;
			}
			PrecacheCharacter(Special[boss]);
			return true;
		}

		for(new tries; tries<100; tries++)
		{
			if(ChancesString[0])
			{
				new i=GetRandomInt(0, chances[chancesIndex-1]);
				while(chancesIndex>=2 && i<chances[chancesIndex-1])
				{
					Special[boss]=chances[chancesIndex-2]-1;
					chancesIndex-=2;
				}
			}
			else
			{
				Special[boss]=GetRandomInt(0, Specials-1);
			}

			KvRewind(BossKV[Special[boss]]);
			if(KvGetNum(BossKV[Special[boss]], "blocked"))
			{
				Special[boss]=0;
				continue;
			}
			break;
		}
	}
	else
	{
		decl String:bossName[64], String:companionName[64];
		KvRewind(BossKV[Special[boss]]);
		KvGetString(BossKV[Special[boss]], "companion", companionName, sizeof(companionName), "=Failed companion name=");

		new character;
		while(character<Specials)  //Loop through all the bosses to find the companion we're looking for
		{
			KvRewind(BossKV[character]);
			KvGetString(BossKV[character], "name", bossName, sizeof(bossName), "=Failed name=");
			if(StrEqual(bossName, companionName))
			{
				Special[companion]=character;
				break;
			}

			KvGetString(BossKV[character], "filename", bossName, sizeof(bossName), "=Failed name=");
			if(StrEqual(bossName, companionName))
			{
				Special[companion]=character;
				break;
			}
			character++;
		}

		if(character==Specials)  //Companion not found
		{
			return false;
		}
	}

	new Action:action;
	Call_StartForward(OnSpecialSelected);
	Call_PushCell(companion);
	new characterIndex=Special[companion];
	Call_PushCellRef(characterIndex);
	decl String:newName[64];
	KvRewind(BossKV[Special[companion]]);
	KvGetString(BossKV[Special[companion]], "name", newName, sizeof(newName));
	Call_PushStringEx(newName, sizeof(newName), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(action);
	if(action==Plugin_Changed)
	{
		if(newName[0])
		{
			decl String:characterName[64];
			new foundExactMatch, foundPartialMatch;
			for(new character; BossKV[character] && character<MAXSPECIALS; character++)
			{
				KvRewind(BossKV[character]);
				KvGetString(BossKV[character], "name", characterName, sizeof(characterName));
				if(StrEqual(newName, characterName, false))
				{
					foundExactMatch=character;
					break;  //If we find an exact match there's no reason to keep looping
				}
				else if(StrContains(newName, characterName, false)!=-1)
				{
					foundPartialMatch=character;
				}

				//Do the same thing as above here, but look at the filename instead of the boss name
				KvGetString(BossKV[character], "filename", characterName, sizeof(characterName));
				if(StrEqual(newName, characterName, false))
				{
					foundExactMatch=character;
					break;  //If we find an exact match there's no reason to keep looping
				}
				else if(StrContains(newName, characterName, false)!=-1)
				{
					foundPartialMatch=character;
				}
			}

			if(foundExactMatch)
			{
				Special[companion]=foundExactMatch;
			}
			else if(foundPartialMatch)
			{
				Special[companion]=foundPartialMatch;
			}
			else
			{
				return false;
			}
			PrecacheCharacter(Special[companion]);
			return true;
		}
		Special[companion]=characterIndex;
		PrecacheCharacter(Special[companion]);
		return true;
	}
	PrecacheCharacter(Special[boss]);
	return true;
}

FindCompanion(boss, players, bool:omit[])
{
	static playersNeeded=3;
	new String:companionName[64];
	KvRewind(BossKV[Special[boss]]);
	KvGetString(BossKV[Special[boss]], "companion", companionName, sizeof(companionName));
	if(playersNeeded<players && strlen(companionName))  //Only continue if we have enough players and if the boss has a companion
	{
		HasCompanions=true;
		new companion=GetRandomValidClient(omit);
		Boss[companion]=companion;  //Woo boss indexes!
		omit[companion]=true;
		
		if(PickCharacter(boss, companion))  //TODO: This is a bit misleading
		{
			BossRageDamage[companion]=KvGetNum(BossKV[Special[companion]], "ragedamage", 1900);
			if(BossRageDamage[companion]<=0)
			{
				new String:bossName[64];
				KvGetString(BossKV[Special[companion]], "name", bossName, sizeof(bossName));
				LogError("[FF2 Bosses] Warning: Boss %s's rage damage is below 0, setting to 1900", bossName);
				BossRageDamage[companion]=1900;
			}
			
			BossLivesMax[companion]=KvGetNum(BossKV[Special[companion]], "lives", 1);
			if(BossLivesMax[companion]<=0)
			{
				LogError("[FF2 Bosses] Warning: Boss %s has an invalid amount of lives, setting to 1", companionName);
				BossLivesMax[companion]=1;
			}

			playersNeeded++;
			FindCompanion(companion, players, omit);  //Make sure this companion doesn't have a companion of their own
		}
	}
	playersNeeded=3;  //Reset the amount of players needed back to 3 after we're done
}

stock SpawnWeapon(client, String:name[], index, level, qual, String:att[])
{
	new Handle:hWeapon=TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if(hWeapon==INVALID_HANDLE)
	{
		return -1;
	}

	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count=ExplodeString(att, ";", atts, 32, 32);

	if(count % 2)
	{
		--count;
	}

	if(count>0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2;
		for(new i; i<count; i+=2)
		{
			new attrib=StringToInt(atts[i]);
			if(!attrib)
			{
				LogError("Bad weapon attribute passed: %s ; %s", atts[i], atts[i+1]);
				CloseHandle(hWeapon);
				return -1;
			}

			TF2Items_SetAttribute(hWeapon, i2, attrib, StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hWeapon, 0);
	}

	new entity=TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}

public HintPanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(IsValidClient(client) && (action==MenuAction_Select || (action==MenuAction_Cancel && selection==MenuCancel_Exit)))
	{
		FF2flags[client]|=FF2FLAG_CLASSHELPED;
	}
	return;
}

public QueuePanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(action==MenuAction_Select && selection==10)
	{
		TurnToZeroPanel(client, client);
	}
	return false;
}


public Action:QueuePanelCmd(client, args)
{
	if(!Enabled2)
	{
		return Plugin_Continue;
	}

	new String:text[64];
	new items;
	new bool:added[MaxClients+1];

	new Handle:panel=CreatePanel();
	SetGlobalTransTarget(client);
	Format(text, sizeof(text), "%t", "thequeue");  //"Boss Queue"
	SetPanelTitle(panel, text);
	for(new boss; boss<=MaxClients; boss++)  //Add the current bosses to the top of the list
	{
		if(IsBoss(boss))
		{
			added[boss]=true;  //Don't want the bosses to show up again in the actual queue list
			Format(text, sizeof(text), "%N-%i", boss, GetClientQueuePoints(boss));
			DrawPanelItem(panel, text);
			items++;
		}
	}

	DrawPanelText(panel, "---");
	do
	{
		new target=GetClientWithMostQueuePoints(added);  //Get whoever has the highest queue points out of those who haven't been listed yet
		if(!IsValidClient(target))  //When there's no players left, fill up the rest of the list with blank lines
		{
			DrawPanelItem(panel, "");
			items++;
			continue;
		}

		Format(text, sizeof(text), "%N-%i", target, GetClientQueuePoints(target));
		if(client!=target)
		{
			DrawPanelItem(panel, text);
			items++;
		}
		else
		{
			DrawPanelText(panel, text);  //DrawPanelText() is white, which allows the client's points to stand out
		}
		added[target]=true;
	}
	while(items<9);

	Format(text, sizeof(text), "%t (%t)", "your_points", GetClientQueuePoints(client), "to0");  //"Your queue point(s) is {1} (set to 0)"
	DrawPanelItem(panel, text);

	SendPanelToClient(panel, client, QueuePanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Handled;
}

public Action:ResetQueuePointsCmd(client, args)
{
	if(!Enabled2)
	{
		return Plugin_Continue;
	}

	if(client && !args)  //Normal players
	{
		TurnToZeroPanel(client, client);
		return Plugin_Handled;
	}

	if(!client)  //No confirmation for console
	{
		TurnToZeroPanelH(INVALID_HANDLE, MenuAction_Select, client, 1);
		return Plugin_Handled;
	}

	new AdminId:admin=GetUserAdmin(client);	 //Normal players
	if((admin==INVALID_ADMIN_ID) || !GetAdminFlag(admin, Admin_Cheats))
	{
		TurnToZeroPanel(client, client);
		return Plugin_Handled;
	}

	if(args!=1)  //Admins
	{
		CReplyToCommand(client, "{olive}[FF2]{default} Usage: ff2_resetqueuepoints <target>");
		return Plugin_Handled;
	}

	new String:targetname[MAX_TARGET_LENGTH];
	GetCmdArg(1, targetname, MAX_TARGET_LENGTH);
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[1], target_count;
	new bool:tn_is_ml;

	if((target_count=ProcessTargetString(targetname, client, target_list, 1, 0, target_name, MAX_TARGET_LENGTH, tn_is_ml))<=0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	TurnToZeroPanel(client, target_list[0]);
	return Plugin_Handled;
}

public TurnToZeroPanelH(Handle:menu, MenuAction:action, client, position)
{
	if(action==MenuAction_Select && position==1)
	{
		if(shortname[client]==client)
		{
			CPrintToChat(client,"{olive}[FF2]{default} %t", "to0_done");
		}
		else
		{
			CPrintToChat(client, "{olive}[FF2]{default} %t", "to0_done_admin", shortname[client]);
			CPrintToChat(shortname[client], "{olive}[FF2]{default} %t", "to0_done_by_admin", client);
		}
		SetClientQueuePoints(shortname[client], 0);
	}
}

public Action:TurnToZeroPanel(caller, client)
{
	if(!Enabled2)
	{
		return Plugin_Continue;
	}

	new Handle:panel=CreatePanel();
	new String:text[512];
	SetGlobalTransTarget(caller);
	if(caller==client)
	{
		Format(text, 512, "%t", "to0_title");
	}
	else
	{
		Format(text, 512, "%t", "to0_title_admin", client);
	}

	PrintToChat(caller, text);
	SetPanelTitle(panel, text);
	Format(text, 512, "%t", "Yes");
	DrawPanelItem(panel, text);
	Format(text, 512, "%t", "No");
	DrawPanelItem(panel, text);
	shortname[caller]=client;
	SendPanelToClient(panel, caller, TurnToZeroPanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Handled;
}

bool:GetClientClassinfoCookie(client)
{
	if(!IsValidClient(client)) return false;
	if(IsFakeClient(client)) return false;
	if(!AreClientCookiesCached(client)) return true;
	new String:s[24];
	new String:ff2cookies_values[8][5];
	GetClientCookie(client, FF2Cookies, s,24);
	ExplodeString(s, " ", ff2cookies_values,8,5);
	return StringToInt(ff2cookies_values[3])==1;
}

GetClientQueuePoints(client)
{
	if(!IsValidClient(client) || !AreClientCookiesCached(client))
	{
		return 0;
	}

	if(IsFakeClient(client))
	{
		return botqueuepoints;
	}

	new String:cookies[24], String:values[8][5];
	GetClientCookie(client, FF2Cookies, cookies, 24);
	ExplodeString(cookies, " ", values, 8, 5);
	return StringToInt(values[0]);
}

SetClientQueuePoints(client, points)
{
	if(IsValidClient(client) && !IsFakeClient(client) && AreClientCookiesCached(client))
	{
		new String:cookies[24], String:values[8][5];
		GetClientCookie(client, FF2Cookies, cookies, sizeof(cookies));
		ExplodeString(cookies, " ", values, 8, 5);
		Format(cookies, sizeof(cookies), "%i %s %s %s %s %s %s %s", points, values[1], values[2], values[3], values[4], values[5], values[6], values[7]);
		SetClientCookie(client, FF2Cookies, cookies);
	}
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

public FF2PanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(action==MenuAction_Select)
	{
		switch(selection)
		{
			case 1:
			{
				Command_GetHP(client);
			}
			case 2:
			{
				HelpPanelClass(client);
			}
			case 3:
			{
				NewPanel(client, maxVersion);
			}
			case 4:
			{
				QueuePanelCmd(client, 0);
			}
			case 5:
			{
				MusicTogglePanel(client);
			}
			case 6:
			{
				VoiceTogglePanel(client);
			}
			case 7:
			{
				HelpPanel3(client);
			}
			default:
			{
				return;
			}
		}
	}
}

public Action:FF2Panel(client, args)  //._.
{
	if(Enabled2 && IsValidClient(client, false))
	{
		new Handle:panel=CreatePanel();
		new String:text[256];
		SetGlobalTransTarget(client);
		Format(text, sizeof(text), "%t", "menu_1");  //What's up?
		SetPanelTitle(panel, text);
		Format(text, sizeof(text), "%t", "menu_2");  //Investigate the boss's current health level (/ff2hp)
		DrawPanelItem(panel, text);
		//Format(text, sizeof(text), "%t", "menu_3");  //Help about FF2 (/ff2help).
		//DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_7");  //Changes to my class in FF2 (/ff2classinfo)
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_4");  //What's new? (/ff2new).
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_5");  //Queue points
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_8");  //Toggle music (/ff2music)
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_9");  //Toggle monologues (/ff2voice)
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_9a");  //Toggle info about changes of classes in FF2
		DrawPanelItem(panel, text);
		Format(text, sizeof(text), "%t", "menu_6");  //Exit
		DrawPanelItem(panel, text);
		SendPanelToClient(panel, client, FF2PanelH, MENU_TIME_FOREVER);
		CloseHandle(panel);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public NewPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if(action==MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if(curHelp[param1]<=0)
					NewPanel(param1, 0);
				else
					NewPanel(param1, --curHelp[param1]);
			}
			case 2:
			{
				if(curHelp[param1]>=maxVersion)
					NewPanel(param1, maxVersion);
				else
					NewPanel(param1, ++curHelp[param1]);
			}
			default: return;
		}
	}
}

public Action:NewPanelCmd(client, args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	NewPanel(client, maxVersion);
	return Plugin_Handled;
}

public Action:NewPanel(client, versionIndex)
{
	if(!Enabled2)
	{
		return Plugin_Continue;
	}

	curHelp[client]=versionIndex;
	new Handle:panel=CreatePanel();
	new String:whatsNew[90];

	SetGlobalTransTarget(client);
	Format(whatsNew, 90, "=%t=", "whatsnew", ff2versiontitles[versionIndex], ff2versiondates[versionIndex]);
	SetPanelTitle(panel, whatsNew);
	FindVersionData(panel, versionIndex);
	if(versionIndex>0)
	{
		Format(whatsNew, 90, "%t", "older");
	}
	else
	{
		Format(whatsNew, 90, "%t", "noolder");
	}

	DrawPanelItem(panel, whatsNew);
	if(versionIndex<maxVersion)
	{
		Format(whatsNew, 90, "%t", "newer");
	}
	else
	{
		Format(whatsNew, 90, "%t", "nonewer");
	}

	DrawPanelItem(panel, whatsNew);
	Format(whatsNew, 512, "%t", "menu_6");
	DrawPanelItem(panel, whatsNew);
	SendPanelToClient(panel, client, NewPanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Continue;
}

public Action:HelpPanel3Cmd(client, args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	HelpPanel3(client);
	return Plugin_Handled;
}

public Action:HelpPanel3(client)
{
	if(!Enabled2)
	{
		return Plugin_Continue;
	}

	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, "Turn the Freak Fortress 2 class info...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, ClassinfoTogglePanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Handled;
}


public ClassinfoTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if(IsValidClient(param1))
	{
		if(action==MenuAction_Select)
		{
			new String:s[24];
			new String:ff2cookies_values[8][5];
			GetClientCookie(param1, FF2Cookies, s, 24);
			ExplodeString(s, " ", ff2cookies_values,8,5);
			if(param2==2)
				Format(s,24,"%s %s %s 0 %s %s %s",ff2cookies_values[0],ff2cookies_values[1],ff2cookies_values[2],ff2cookies_values[4],ff2cookies_values[5],ff2cookies_values[6],ff2cookies_values[7]);
			else
				Format(s,24,"%s %s %s 1 %s %s %s",ff2cookies_values[0],ff2cookies_values[1],ff2cookies_values[2],ff2cookies_values[4],ff2cookies_values[5],ff2cookies_values[6],ff2cookies_values[7]);
			SetClientCookie(param1, FF2Cookies,s);
			CPrintToChat(param1,"{olive}[VSH]{default} %t","FF2 Class Info", param2==2 ? "off" : "on");
		}
	}
}

public Action:Command_HelpPanelClass(client, args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	HelpPanelClass(client);
	return Plugin_Handled;
}

public Action:HelpPanelClass(client)
{
	if(!Enabled)
	{
		return Plugin_Continue;
	}

	new boss=GetBossIndex(client);
	if(boss!=-1)
	{
		HelpPanelBoss(boss);
		return Plugin_Continue;
	}

	new String:text[512];
	new TFClassType:class=TF2_GetPlayerClass(client);
	SetGlobalTransTarget(client);
	switch(class)
	{
		case TFClass_Scout:
		{
			Format(text, sizeof(text), "%t", "help_scout");
		}
		case TFClass_Soldier:
		{
			Format(text, sizeof(text), "%t", "help_soldier");
		}
		case TFClass_Pyro:
		{
			Format(text, sizeof(text), "%t", "help_pyro");
		}
		case TFClass_DemoMan:
		{
			Format(text, sizeof(text), "%t", "help_demo");
		}
		case TFClass_Heavy:
		{
			Format(text, sizeof(text), "%t", "help_heavy");
		}
		case TFClass_Engineer:
		{
			Format(text, sizeof(text), "%t", "help_eggineer");
		}
		case TFClass_Medic:
		{
			Format(text, sizeof(text), "%t", "help_medic");
		}
		case TFClass_Sniper:
		{
			Format(text, sizeof(text), "%t", "help_sniper");
		}
		case TFClass_Spy:
		{
			Format(text, sizeof(text), "%t", "help_spie");
		}
		default:
		{
			Format(text, sizeof(text), "");
		}
	}

	if(class!=TFClass_Sniper)
	{
		Format(text, sizeof(text), "%t\n%s", "help_melee", text);
	}

	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, text);
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, HintPanelH, 20);
	CloseHandle(panel);
	return Plugin_Continue;
}

HelpPanelBoss(boss)
{
	if(!IsValidClient(Boss[boss]))
	{
		return;
	}

	new String:text[512], String:language[20];
	GetLanguageInfo(GetClientLanguage(Boss[boss]), language, 8, text, 8);
	Format(language, sizeof(language), "description_%s", language);

	KvRewind(BossKV[Special[boss]]);
	//KvSetEscapeSequences(BossKV[Special[boss]], true);  //Not working
	KvGetString(BossKV[Special[boss]], language, text, sizeof(text));
	if(!text[0])
	{
		KvGetString(BossKV[Special[boss]], "description_en", text, sizeof(text));  //Default to English if their language isn't available
		if(!text[0])
		{
			return;
		}
	}
	ReplaceString(text, sizeof(text), "\\n", "\n");
	//KvSetEscapeSequences(BossKV[Special[boss]], false);  //We don't want to interfere with the download paths

	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, text);
	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, Boss[boss], HintPanelH, 20);
	CloseHandle(panel);
}

public Action:MusicTogglePanelCmd(client, args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	MusicTogglePanel(client);
	return Plugin_Handled;
}

public Action:MusicTogglePanel(client)
{
	if(!Enabled || !IsValidClient(client))
	{
		return Plugin_Continue;
	}

	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, "Turn the Freak Fortress 2 music...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, MusicTogglePanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Continue;
}

public MusicTogglePanelH(Handle:menu, MenuAction:action, param1, param2)
{
	if(IsValidClient(param1))
	{
		if(action==MenuAction_Select)
		{
			if(param2==2)
			{
				SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, false);
				KvRewind(BossKV[Special[0]]);
				if(KvJumpToKey(BossKV[Special[0]],"sound_bgm"))
				{
					new String:s[PLATFORM_MAX_PATH];
					Format(s,10,"path%i",MusicIndex);
					KvGetString(BossKV[Special[0]], s,s, PLATFORM_MAX_PATH);
					StopSound(param1, SNDCHAN_AUTO, s);
					StopSound(param1, SNDCHAN_AUTO, s);
				}
			}
			else
				SetClientSoundOptions(param1, SOUNDEXCEPT_MUSIC, true);
			CPrintToChat(param1,"{olive}[FF2]{default} %t","ff2_music", param2==2 ? "off" : "on");
		}
	}
}

public Action:VoiceTogglePanelCmd(client, args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	VoiceTogglePanel(client);
	return Plugin_Handled;
}

public Action:VoiceTogglePanel(client)
{
	if(!Enabled || !IsValidClient(client))
	{
		return Plugin_Continue;
	}

	new Handle:panel=CreatePanel();
	SetPanelTitle(panel, "Turn the Freak Fortress 2 voices...");
	DrawPanelItem(panel, "On");
	DrawPanelItem(panel, "Off");
	SendPanelToClient(panel, client, VoiceTogglePanelH, MENU_TIME_FOREVER);
	CloseHandle(panel);
	return Plugin_Continue;
}

public VoiceTogglePanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(IsValidClient(client))
	{
		if(action==MenuAction_Select)
		{
			if(selection==2)
			{
				SetClientSoundOptions(client, SOUNDEXCEPT_VOICE, false);
			}
			else
			{
				SetClientSoundOptions(client, SOUNDEXCEPT_VOICE, true);
			}

			CPrintToChat(client, "{olive}[FF2]{default} %t", "ff2_voice", selection==2 ? "off" : "on");
			if(selection==2)
			{
				CPrintToChat(client, "%t", "ff2_voice2");
			}
		}
	}
}

//Ugly compatability layer since HookSound's arguments changed in 1.8
#if SOURCEMOD_V_MAJOR==1 && SOURCEMOD_V_MINOR<=7
public Action:HookSound(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &client, &channel, &Float:volume, &level, &pitch, &flags)
#else
public Action:HookSound(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &client, &channel, &Float:volume, &level, &pitch, &flags, String:soundEntry[PLATFORM_MAX_PATH], &seed)
#endif
{
	if(!Enabled || !IsValidClient(client) || channel<1)
	{
		return Plugin_Continue;
	}

	new boss=GetBossIndex(client);
	if(boss==-1)
	{
		return Plugin_Continue;
	}

	if(!StrContains(sound, "vo") && !(FF2flags[Boss[boss]] & FF2FLAG_TALKING))
	{
		decl String:newSound[PLATFORM_MAX_PATH];
		if(RandomSound("catch_phrase", newSound, PLATFORM_MAX_PATH, boss))
		{
			strcopy(sound, PLATFORM_MAX_PATH, newSound);	
			return Plugin_Changed;
		}

		if(bBlockVoice[Special[boss]])
		{
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
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

stock bool:IsValidClient(client, bool:replaycheck=true)
{
	if(client<=0 || client>MaxClients)
	{
		return false;
	}

	if(!IsClientInGame(client))
	{
		return false;
	}

	if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
	{
		return false;
	}

	if(replaycheck)
	{
		if(IsClientSourceTV(client) || IsClientReplay(client))
		{
			return false;
		}
	}
	return true;
}

// Old voting system

public NextmapPanelH(Handle:menu, MenuAction:action, client, selection)
{
	if(action==MenuAction_Select && selection==1)
	{
		new clients[1];
		clients[0]=client;
		if(!IsVoteInProgress())
		{
			VoteMenu(menu, clients, client, 1, MENU_TIME_FOREVER);
		}
	}
	else if(action==MenuAction_End)
	{
		CloseHandle(menu);
	}

	return;
}

public Handler_VoteCharset(Handle:menu, votes, clients, const clientInfo[][2], items, const itemInfo[][2])
{
	decl String:item[42], String:display[42], String:nextmap[42];
	GetMenuItem(menu, itemInfo[0][VOTEINFO_ITEM_INDEX], item, sizeof(item), _, display, sizeof(display));
	if(item[0]=='0')  //!StringToInt(item)
	{
		FF2CharSet=GetRandomInt(0, FF2CharSet);
	}
	else
	{
		FF2CharSet=item[0]-'0'-1;  //Wat
	}

	GetConVarString(cvarNextmap, nextmap, sizeof(nextmap));
	strcopy(FF2CharSetString, 42, item[StrContains(item, " ")+1]);
	CPrintToChatAll("{olive}[FF2]{default} %t", "Next Map Character Set", nextmap, FF2CharSetString);  //display
	isCharSetSelected=true;
}

public CvarChangeNextmap(Handle:convar, const String:oldValue[], const String:newValue[])
{
	CreateTimer(0.1, Timer_DisplayCharsetVote);
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

	new Handle:menu=CreateMenu(NextmapPanelH, MenuAction:MENU_ACTIONS_ALL);
	SetMenuTitle(menu, "%t", "select_charset");
	SetVoteResultCallback(menu, Handler_VoteCharset);

	decl String:config[PLATFORM_MAX_PATH], String:charset[64];
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/characters.cfg");

	new Handle:Kv=CreateKeyValues("");
	FileToKeyValues(Kv, config);
	AddMenuItem(menu, "0 Random", "Random");
	new i, charsets;
	do
	{
		i++;
		if(KvGetNum(Kv, "hidden", 0))
		{
			continue;
		}
		charsets++;

		KvGetSectionName(Kv, config, 64);
		Format(charset, sizeof(charset), "%i %s", i, config);
		AddMenuItem(menu, charset, config);
	}
	while(KvGotoNextKey(Kv));
	CloseHandle(Kv);

	if(charsets>1)  //We have enough to call a vote
	{
		new Handle:voteDuration=FindConVar("sm_mapvote_voteduration");
		VoteMenuToAll(menu, voteDuration ? GetConVarInt(voteDuration) : 20);
	}
	return Plugin_Continue;
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

// Attempted port to nativevotes
/*public CvarChangeNextmap(Handle:convar, const String:oldValue[], const String:newValue[])
{
	CPrintToChatAll("{olive}[FF2]{default} Starting charset vote!");
	CreateTimer(0.1, Timer_DisplayCharsetVote);
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

public Action:Timer_DisplayCharsetVote(Handle:timer)
{
	if(isCharSetSelected && !isCharsetOverride)
	{
		return Plugin_Continue;
	}

	if(IsVoteInProgress() || NativeVotes_IsVoteInProgress())
	{
		CreateTimer(5.0, Timer_DisplayCharsetVote, _, TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	new String:votetitle[768];
	new Handle:menu=NativeVotes_Create(NextmapPanelH, NativeVotesType_Custom_Mult, NATIVEVOTES_ACTIONS_DEFAULT | MenuAction_DisplayItem);
	Format(votetitle, sizeof(votetitle), "%t", "select_charset");
	NativeVotes_SetTitle(menu, votetitle);

	decl String:config[PLATFORM_MAX_PATH], String:charset[64];
	BuildPath(Path_SM, config, PLATFORM_MAX_PATH, "configs/freak_fortress_2/characters.cfg");

	new Handle:Kv=CreateKeyValues("");
	FileToKeyValues(Kv, config);
	new i, charsets;
	do
	{
		i++;
		if(KvGetNum(Kv, "hidden", 0))
		{
			continue;
		}
		charsets++;

		KvGetSectionName(Kv, config, 64);
		Format(charset, sizeof(charset), "%i %s", i, config);
		NativeVotes_AddItem(menu, charset, config);
	}
	while(KvGotoNextKey(Kv));
	CloseHandle(Kv);

	if(charsets>1)  //We have enough to call a vote
	{
		new Handle:voteDuration=FindConVar("sm_mapvote_voteduration");
		NativeVotes_DisplayToAll(menu, voteDuration ? GetConVarInt(voteDuration) : 20);
	}
	return Plugin_Continue;
}

public NextmapPanelH(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{
		case MenuAction_VoteEnd:
		{
			new votes, totalVotes;
			decl String:item[42], String:display[42], String:nextmap[42];

			GetMenuVoteInfo(param2, votes, totalVotes);
			GetMenuItem(menu, param1, item, sizeof(item), _, display, sizeof(display));
		
			FF2CharSet=item[0]-'0'-1;  //Wat

			GetConVarString(cvarNextmap, nextmap, sizeof(nextmap));
			strcopy(FF2CharSetString, 42, item[StrContains(item, " ")+1]);
			NativeVotes_DisplayPassCustom(menu, "%t", "Next Map Character Set", param1);
			CPrintToChatAll("{olive}[FF2]{default} %t", "Next Map Character Set", nextmap, FF2CharSetString);  //display
			isCharSetSelected=true;
		}
		
		case MenuAction_End:
		{
			NativeVotes_Close(menu);
		}
		
		case MenuAction_VoteCancel:
		{
			 NativeVotes_DisplayFail(menu, NativeVotesFail_Generic);
			 CPrintToChatAll("{olive}[FF2]{default} The current charset will be used for the next map!");
		}
	}
	return 0;
}*/


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

UseAbility(const String:ability_name[], const String:plugin_name[], boss, slot, buttonMode=0)
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
		return;
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
		FF2flags[Boss[boss]]&=~FF2FLAG_BOTRAGE;
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
			if(!(FF2flags[Boss[boss]] & FF2FLAG_USINGABILITY))
			{
				FF2flags[Boss[boss]]|=FF2FLAG_USINGABILITY;
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
}

stock SwitchEntityTeams(String:entityname[], bossteam, mercteam)
{
	new ent=-1;
	while((ent=FindEntityByClassname2(ent, entityname))!=-1)
	{
		SetEntityTeamNum(ent, _:GetEntityTeamNum(ent)==mercteam ? bossteam : mercteam);
	}
}

/*****************************************************************************
 * Fork-specific functions (can only be called via reflection for subplugins)*
 *****************************************************************************/
public FF2_GetBossMoveSpeed(boss)
{
	return _:BossSpeed[Special[boss]];
}

public FF2_SetBossMoveSpeed(boss, Float:speed)
{
	BossSpeed[Special[boss]]=speed;
}

public FF2_GetNonBossTeam()
{
	return MercTeam;
}

public FF2_SwitchTeams(bossteam, mercteam, bool:respawn)
{
	SetTeamScore(bossteam, GetTeamScore(bossteam));
	SetTeamScore(mercteam, GetTeamScore(mercteam));
	MercTeam=mercteam;
	BossTeam=bossteam;
	
	if(Maptype(chkcurrentmap)==Maptype_VSH)
	{
		if(bossteam==_:TFTeam_Red && mercteam==_:TFTeam_Blue)
		{
			SwitchEntityTeams("info_player_teamspawn", bossteam, mercteam);
			SwitchEntityTeams("obj_sentrygun", bossteam, mercteam);
			SwitchEntityTeams("obj_dispenser", bossteam, mercteam);
			SwitchEntityTeams("obj_teleporter", bossteam, mercteam);
			SwitchEntityTeams("filter_activator_tfteam", bossteam, mercteam);

			if(respawn)
			{
				for(new client=1;client<=MaxClients;client++)
				{
					if(!IsValidClient(client) || GetClientTeam(client)<=_:TFTeam_Spectator || TF2_GetPlayerClass(client)==TFClass_Unknown)
						continue;
					TF2_RespawnPlayer(client);
				}
			}
		}
	}
}



/**************
 * FF2 Natives*
 **************/
public Action:Timer_UseBossCharge(Handle:timer, Handle:data)
{
	BossCharge[ReadPackCell(data)][ReadPackCell(data)]=ReadPackFloat(data);
	return Plugin_Continue;
}

public Native_IsEnabled(Handle:plugin, numParams)
{
	return Enabled;
}

public Native_FF2Version(Handle:plugin, numParams)
{
	new version[3];  //Blame the compiler for this mess -.-
	version[0]=StringToInt(MAJOR_REVISION);
	version[1]=StringToInt(MINOR_REVISION);
	version[2]=StringToInt(STABLE_REVISION);
	SetNativeArray(1, version, sizeof(version));
	#if !defined DEV_REVISION
		return false;
	#else
		return true;
	#endif
}

public Native_GetBoss(Handle:plugin, numParams)
{
	new boss=GetNativeCell(1);
	if(boss>=0 && boss<=MaxClients && IsValidClient(Boss[boss]))
	{
		return GetClientUserId(Boss[boss]);
	}
	return -1;
}

public Native_GetIndex(Handle:plugin, numParams)
{
	return GetBossIndex(GetNativeCell(1));
}

public Native_GetTeam(Handle:plugin, numParams)
{
	return BossTeam;
}

public Native_GetSpecial(Handle:plugin, numParams)
{
	new index=GetNativeCell(1), dstrlen=GetNativeCell(3), see=GetNativeCell(4);
	new String:s[dstrlen];
	if(see)
	{
		if(index<0) return false;
		if(!BossKV[index]) return false;
		KvRewind(BossKV[index]);
		KvGetString(BossKV[index], "name", s, dstrlen);
		SetNativeString(2, s,dstrlen);
	}
	else
	{
		if(index<0) return false;
		if(Special[index]<0) return false;
		if(!BossKV[Special[index]]) return false;
		KvRewind(BossKV[Special[index]]);
		KvGetString(BossKV[Special[index]], "name", s, dstrlen);
		SetNativeString(2, s,dstrlen);
	}
	return true;
}

public Native_GetBossHealth(Handle:plugin, numParams)
{
	return BossHealth[GetNativeCell(1)];
}

public Native_SetBossHealth(Handle:plugin, numParams)
{
	BossHealth[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetBossMaxHealth(Handle:plugin, numParams)
{
	return BossHealthMax[GetNativeCell(1)];
}

public Native_SetBossMaxHealth(Handle:plugin, numParams)
{
	BossHealthMax[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetBossLives(Handle:plugin, numParams)
{
	return BossLives[GetNativeCell(1)];
}

public Native_SetBossLives(Handle:plugin, numParams)
{
	BossLives[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetBossMaxLives(Handle:plugin, numParams)
{
	return BossLivesMax[GetNativeCell(1)];
}

public Native_SetBossMaxLives(Handle:plugin, numParams)
{
	BossLivesMax[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetBossCharge(Handle:plugin, numParams)
{
	return _:BossCharge[GetNativeCell(1)][GetNativeCell(2)];
}

public Native_SetBossCharge(Handle:plugin, numParams)
{
	BossCharge[GetNativeCell(1)][GetNativeCell(2)]=Float:GetNativeCell(3);
}

public Native_GetBossRageDamage(Handle:plugin, numParams)
{
	return BossRageDamage[GetNativeCell(1)];
}

public Native_SetBossRageDamage(Handle:plugin, numParams)
{
	BossRageDamage[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetRoundState(Handle:plugin, numParams)
{
	if(CheckRoundState()<=FF2RoundState_Setup)
	{
		return _:FF2RoundState_Setup;
	}
	return _:CheckRoundState();
}

public Native_GetRageDist(Handle:plugin, numParams)
{
	new index=GetNativeCell(1);
	new String:plugin_name[64];
	GetNativeString(2,plugin_name,64);
	new String:ability_name[64];
	GetNativeString(3,ability_name,64);

	if(!BossKV[Special[index]]) return _:0.0;
	KvRewind(BossKV[Special[index]]);
	new Float:see;
	if(!ability_name[0])
	{
		return _:KvGetFloat(BossKV[Special[index]],"ragedist",400.0);
	}
	new String:s[10];
	for(new i=1; i<MAXRANDOMS; i++)
	{
		Format(s,10,"ability%i",i);
		if(KvJumpToKey(BossKV[Special[index]],s))
		{
			new String:ability_name2[64];
			KvGetString(BossKV[Special[index]], "name",ability_name2,64);
			if(strcmp(ability_name,ability_name2))
			{
				KvGoBack(BossKV[Special[index]]);
				continue;
			}
			if((see=KvGetFloat(BossKV[Special[index]],"dist",-1.0))<0)
			{
				KvRewind(BossKV[Special[index]]);
				see=KvGetFloat(BossKV[Special[index]],"ragedist",400.0);
			}
			return _:see;
		}
	}
	return _:0.0;
}

public Native_HasAbility(Handle:plugin, numParams)
{
	new String:pluginName[64], String:abilityName[64];

	new boss=GetNativeCell(1);
	GetNativeString(2, pluginName, sizeof(pluginName));
	GetNativeString(3, abilityName, sizeof(abilityName));
	if(boss==-1 || Special[boss]==-1 || !BossKV[Special[boss]])
	{
		return false;
	}

	KvRewind(BossKV[Special[boss]]);
	if(!BossKV[Special[boss]])
	{
		LogError("Failed KV: %i %i", boss, Special[boss]);
		return false;
	}

	new String:ability[12];
	for(new i=1; i<MAXRANDOMS; i++)
	{
		Format(ability, sizeof(ability), "ability%i", i);
		if(KvJumpToKey(BossKV[Special[boss]], ability))  //Does this ability number exist?
		{
			new String:abilityName2[64];
			KvGetString(BossKV[Special[boss]], "name", abilityName2, sizeof(abilityName2));
			if(StrEqual(abilityName, abilityName2))  //Make sure the ability names are equal
			{
				new String:pluginName2[64];
				KvGetString(BossKV[Special[boss]], "plugin_name", pluginName2, sizeof(pluginName2));
				if(!pluginName[0] || !pluginName2[0] || StrEqual(pluginName, pluginName2))  //Make sure the plugin names are equal
				{
					return true;
				}
			}
			KvGoBack(BossKV[Special[boss]]);
		}
	}
	return false;
}

public Native_DoAbility(Handle:plugin, numParams)
{
	new String:plugin_name[64];
	new String:ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	UseAbility(ability_name,plugin_name, GetNativeCell(1), GetNativeCell(4), GetNativeCell(5));
}

public Native_GetAbilityArgument(Handle:plugin, numParams)
{
	new String:plugin_name[64];
	new String:ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	return GetAbilityArgument(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5));
}

public Native_GetAbilityArgumentFloat(Handle:plugin, numParams)
{
	new String:plugin_name[64];
	new String:ability_name[64];
	GetNativeString(2,plugin_name,64);
	GetNativeString(3,ability_name,64);
	return _:GetAbilityArgumentFloat(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),GetNativeCell(5));
}

public Native_GetAbilityArgumentString(Handle:plugin, numParams)
{
	new String:plugin_name[64];
	GetNativeString(2,plugin_name,64);
	new String:ability_name[64];
	GetNativeString(3,ability_name,64);
	new dstrlen=GetNativeCell(6);
	new String:s[dstrlen+1];
	GetAbilityArgumentString(GetNativeCell(1),plugin_name,ability_name,GetNativeCell(4),s,dstrlen);
	SetNativeString(5,s,dstrlen);
}

public Native_GetDamage(Handle:plugin, numParams)
{
	new client=GetNativeCell(1);
	if(!IsValidClient(client))
	{
		return 0;
	}
	return Damage[client];
}

public Native_GetFF2flags(Handle:plugin, numParams)
{
	return FF2flags[GetNativeCell(1)];
}

public Native_SetFF2flags(Handle:plugin, numParams)
{
	FF2flags[GetNativeCell(1)]=GetNativeCell(2);
}

public Native_GetQueuePoints(Handle:plugin, numParams)
{
	return GetClientQueuePoints(GetNativeCell(1));
}

public Native_SetQueuePoints(Handle:plugin, numParams)
{
	SetClientQueuePoints(GetNativeCell(1), GetNativeCell(2));
}

public Native_GetSpecialKV(Handle:plugin, numParams)
{
	new index=GetNativeCell(1);
	new bool:isNumOfSpecial=bool:GetNativeCell(2);
	if(isNumOfSpecial)
	{
		if(index!=-1 && index<Specials)
		{
			if(BossKV[index]!=INVALID_HANDLE)
			{
				KvRewind(BossKV[index]);
			}
			return _:BossKV[index];
		}
	}
	else
	{
		if(index!=-1 && index<=MaxClients && Special[index]!=-1 && Special[index]<MAXSPECIALS)
		{
			if(BossKV[Special[index]]!=INVALID_HANDLE)
			{
				KvRewind(BossKV[Special[index]]);
			}
			return _:BossKV[Special[index]];
		}
	}
	return _:INVALID_HANDLE;
}

public Native_StartMusic(Handle:plugin, numParams)
{
	Timer_MusicPlay(INVALID_HANDLE, GetNativeCell(1));
}

public Native_StopMusic(Handle:plugin, numParams)
{
	StopMusic(GetNativeCell(1));
}

public Native_RandomSound(Handle:plugin, numParams)
{
	new length=GetNativeCell(3)+1;
	new boss=GetNativeCell(4);
	new slot=GetNativeCell(5);
	new String:sound[length];
	new kvLength;

	GetNativeStringLength(1, kvLength);
	kvLength++;

	new String:keyvalue[kvLength];
	GetNativeString(1, keyvalue, kvLength);

	new bool:soundExists;
	if(!strcmp(keyvalue, "sound_ability"))
	{
		soundExists=RandomSoundAbility(keyvalue, sound, length, boss, slot);
	}
	else
	{
		soundExists=RandomSound(keyvalue, sound, length, boss);
	}
	SetNativeString(2, sound, length);
	return soundExists;
}

public Native_GetClientGlow(Handle:plugin, numParams)
{
	new client=GetNativeCell(1);
	if(IsValidClient(client))
	{
		return _:GlowTimer[client];
	}
	else
	{
		return -1;
	}
}

public Native_SetClientGlow(Handle:plugin, numParams)
{
	SetClientGlow(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

public Native_GetAlivePlayers(Handle:plugin, numParams)
{
	return AliveMercPlayers;
}

public Native_GetBossPlayers(Handle:plugin, numParams)
{
	return AliveBossPlayers;
}

public Native_Debug(Handle:plugin, numParams)
{
	return GetConVarBool(cvarDebug);
}

public Native_IsVSHMap(Handle:plugin, numParams)
{
	return false;
}

public Action:VSH_OnIsSaxtonHaleModeEnabled(&result)
{
	if((!result || result==1) && Enabled)
	{
		result=2;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetSaxtonHaleTeam(&result)
{
	if(Enabled)
	{
		result=BossTeam;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetSaxtonHaleUserId(&result)
{
	if(Enabled && IsClientConnected(Boss[0]))
	{
		result=GetClientUserId(Boss[0]);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetSpecialRoundIndex(&result)
{
	if(Enabled)
	{
		result=Special[0];
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetSaxtonHaleHealth(&result)
{
	if(Enabled)
	{
		result=BossHealth[0];
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetSaxtonHaleHealthMax(&result)
{
	if(Enabled)
	{
		result=BossHealthMax[0];
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetClientDamage(client, &result)
{
	if(Enabled)
	{
		result=Damage[client];
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:VSH_OnGetRoundState(&result)
{
	if(Enabled)
	{
		result=_:CheckRoundState();
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public OnTakeDamagePost(client, attacker, inflictor, Float:damage, damagetype)
{
	if(Enabled && IsBoss(client))
	{
		UpdateHealthBar();
	}
}

public OnEntityCreated(entity, const String:classname[])
{

	if(GetConVarBool(cvarHealthBar))
	{
		if(StrEqual(classname, HEALTHBAR_CLASS))
		{
			healthBar=entity;
		}

		if(g_Monoculus==-1 && StrEqual(classname, MONOCULUS))
		{
			g_Monoculus=entity;
		}
	}
	
	if(Enabled && GetConVarFloat(FindConVar("tf_dropped_weapon_lifetime")) && !StrContains(classname, "tf_dropped_weapon"))
	{
		AcceptEntityInput(entity, "kill");
		return;
	}
	
	if(StrContains(classname, "item_healthkit")!=-1 || StrContains(classname, "item_ammopack")!=-1 || StrEqual(classname, "tf_ammo_pack"))
	{
		SDKHook(entity, SDKHook_Spawn, OnItemSpawned);
	}
}

public OnEntityDestroyed(entity)
{
	if(entity==g_Monoculus)
	{
		g_Monoculus=FindEntityByClassname(-1, MONOCULUS);
		if(g_Monoculus==entity)
		{
			g_Monoculus=FindEntityByClassname(entity, MONOCULUS);
		}
	}
}

public OnItemSpawned(entity)
{
	SDKHook(entity, SDKHook_StartTouch, OnPickup);
	SDKHook(entity, SDKHook_Touch, OnPickup);
}

public OnPreThinkPost(client)
{
	if(IsNearDispenser(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
	{
		new Float:cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - 0.5;
		if (cloak<0.0)
			cloak=0.0;
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
	}
}

stock bool:IsNearDispenser(client)
{
	new medics = 0, healers = GetEntProp(client, Prop_Send, "m_nNumHealers");
	if (healers>0)
	{
		for (new i=1;i<=MaxClients;i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetHealingTarget(i, true) == client)
			medics++;
		}
	}
	return healers > medics;
}

public Action:OnPickup(entity, client)  //Thanks friagram!
{
	if(IsBoss(client))
	{
		new String:classname[32];
		GetEntityClassname(entity, classname, sizeof(classname));		
		if(!StrContains(classname, "item_healthkit") && !(FF2flags[client] & FF2FLAG_ALLOW_HEALTH_PICKUPS))
		{
			return Plugin_Handled;
		}
		else if((!StrContains(classname, "item_ammopack") || StrEqual(classname, "tf_ammo_pack")) && !(FF2flags[client] & FF2FLAG_ALLOW_AMMO_PICKUPS))
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public FF2RoundState:CheckRoundState()
{
	switch(GameRules_GetRoundState())
	{
		case RoundState_Init, RoundState_Pregame:
		{
			return FF2RoundState_Loading;
		}
		case RoundState_StartGame, RoundState_Preround:
		{
			return FF2RoundState_Setup;
		}
		case RoundState_RoundRunning, RoundState_Stalemate:  //Oh Valve.
		{
			return FF2RoundState_RoundRunning;
		}
		default:
		{
			return FF2RoundState_RoundEnd;
		}
	}
	return FF2RoundState_Loading;  //Compiler bug-doesn't recognize 'default' as a valid catch-all
}

FindHealthBar()
{
	healthBar=FindEntityByClassname(-1, HEALTHBAR_CLASS);
	if(healthBar==-1)
	{
		healthBar=CreateEntityByName(HEALTHBAR_CLASS);
	}
}

public HealthbarEnableChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(Enabled && GetConVarBool(cvarHealthBar) && healthBar!=-1)
	{
		UpdateHealthBar();
	}
	else if(g_Monoculus==-1 && healthBar!=-1)
	{
		SetEntProp(healthBar, Prop_Send, HEALTHBAR_PROPERTY, 0);
	}
}

UpdateHealthBar()
{
	if(!Enabled || !GetConVarBool(cvarHealthBar) || g_Monoculus!=-1 || CheckRoundState()==FF2RoundState_Loading)
	{
		return;
	}

	new healthAmount, maxHealthAmount, bosses, healthPercent;
	for(new client; client<=MaxClients; client++)
	{
		if(IsValidClient(Boss[client]) && IsPlayerAlive(Boss[client]))
		{
			bosses++;
			healthAmount+=BossHealth[client]-BossHealthMax[client]*(BossLives[client]-1);
			maxHealthAmount+=BossHealthMax[client];
		}
	}

	if(bosses)
	{
		healthPercent=RoundToCeil(float(healthAmount)/float(maxHealthAmount)*float(HEALTHBAR_MAX));
		if(healthPercent>HEALTHBAR_MAX)
		{
			healthPercent=HEALTHBAR_MAX;
		}
		else if(healthPercent<=0)
		{
			healthPercent=1;
		}
	}
	SetEntProp(healthBar, Prop_Send, HEALTHBAR_PROPERTY, healthPercent);
}

SetClientGlow(client, Float:time1, Float:time2=-1.0)
{
	if(!IsValidClient(client) && !IsValidClient(Boss[client]))
	{
		return;
	}
	if(DeadRunMode)
	{
		return;
	}
	GlowTimer[client]+=time1;
	if(time2>=0)
	{
		GlowTimer[client]=time2;
	}

	if(GlowTimer[client]<=0.0)
	{
		GlowTimer[client]=0.0;
		SetEntProp((IsValidClient(Boss[client]) ? Boss[client] : client), Prop_Send, "m_bGlowEnabled", 0);
	}
	else
	{
		SetEntProp((IsValidClient(Boss[client]) ? Boss[client] : client), Prop_Send, "m_bGlowEnabled", 1);
	}
}

#include <freak_fortress_2_vsh_feedback>
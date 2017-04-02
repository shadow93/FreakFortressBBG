// changelog

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
    "1.31",    // Update Rollups 5-6
    "1.31",    // Update Rollups 7-15
    "1.32",
    "1.32",
    "1.33",
    "1.33",
    "1.33",
    "1.34",
    "1.34",
    "1.34",
    "1.35",
    "1.35",
    "1.36",
    "1.36",
    "1.36",
    "1.37",
    "1.38",
    "1.39",
    "1.40",
    "1.40",
    "1.40",
    "1.40",
    "1.41",
    "1.41",
    "1.42",
    "1.42",
    "1.43",
    "1.44",
    "1.45",
    "1.46",
    "1.47",
    "1.48",
    "1.48",
	"1.49"
};    

static const maxVersion=sizeof(ff2versiontitles)-1;

static const String:ff2versiondates[][]=
{
    "6 April 2012",        //1.0
    "14 April 2012",    //1.01
    "14 April 2012",    //1.01
    "17 April 2012",    //1.02
    "19 April 2012",    //1.03
    "21 April 2012",    //1.04
    "29 April 2012",    //1.05
    "29 April 2012",    //1.05
    "1 May 2012",        //1.06
    "22 June 2012",        //1.06c
    "3 July 2012",        //1.06d
    "24 Aug 2012",        //1.06e
    "5 Sep 2012",        //1.06f
    "5 Sep 2012",        //1.06g
    "6 Sep 2012",        //1.06h
    "8 Oct 2012",        //1.07 beta 1
    "8 Oct 2012",        //1.07 beta 1
    "8 Oct 2012",        //1.07 beta 1
    "8 Oct 2012",        //1.07 beta 1
    "8 Oct 2012",        //1.07 beta 1
    "11 Oct 2012",        //1.07 beta 4
    "18 Oct 2012",        //1.07 beta 5
    "9 Nov 2012",        //1.07 beta 6
    "14 Dec 2012",        //1.07
    "October 30, 2013",    //1.0.8
    "October 30, 2013",    //1.0.8
    "October 30, 2013",    //1.0.8
    "October 30, 2013",    //1.0.8
    "October 30, 2013",    //1.0.8
    "March 6, 2014",    //1.9.0
    "March 6, 2014",    //1.9.0
    "March 18, 2014",    //1.9.1
    "March 22, 2014",    //1.9.2
    "March 22, 2014",    //1.9.2
    "April 5, 2014",    //1.9.3
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "July 26, 2014",    //1.10.0
    "August 28, 2014",    //1.10.1
    "August 28, 2014",    //1.10.1
    "August 28, 2014",    //1.10.1
    "August 28, 2014",    //1.10.1
    "August 28, 2014",    //1.10.1
    "August 28, 2014",    //1.10.2
    "November 6, 2014",    //1.10.3
    "November 6, 2014",    //1.10.3
    "November 6, 2014",    //1.10.3
    "November 6, 2014",    //1.10.3
    "November 6, 2014",    //1.10.3
    "February 6, 2015",    //1.11
    "February 6, 2015",    //1.11
    "February 23, 2015",    //1.12 BBG
    "March 1, 2015",    //1.13 BBG
    "March 1, 2015",    //1.13 BBG
    "March 1, 2015",        //1.13 BBG
    "March 1, 2015",    //1.13 BBG
    "March 1, 2015",        //1.13 BBG
    "March 1, 2015",    //1.14 BBG
    "March 4, 2015",    //1.15 BBG
    "March 6, 2015", // 1.16 bbg
    "March 7, 2015", // 1.17 bbg
    "March 17, 2015", // 1.18 BBG
    "March 22, 2015",    // 1.19 BBG
    "March 22, 2015",    // 1.19 BBG
    "March 26, 2015",    //1.20 BBG
    "March 26, 2015",    //1.20 BBG
    "April 5, 2015",        //1.21
    "April 5, 2015",        //1.21
    "April 5, 2015",        //1.21
    "April 8, 2015",        //1.22
    "April 8, 2015",        //1.22
    "April 12, 2015",        //1.23
    "April 12, 2015",        //1.23
    "April 12, 2015",        //1.23
    "April 18, 2015",        //1.24
    "April 18, 2015",        //1.24
    "April 30, 2015",        //1.25
    "May 5, 2015",        //1.26
    "May 10, 2015",        //1.27
    "May 15, 2015",        //1.28
    "May 23, 2015",        //1.29
    "June 19, 2015",        //1.30
    "June 19, 2015",        //1.30
    "July 14, 2015",            //1.31
    "July 14, 2015",            //1.31
    "July 14, 2015",            //1.31
    "July 14, 2015",            //1.31
    "July 25, 2015",            //1.32
    "July 25, 2015",                //1.32
    "August 6, 2015",            //1.33
    "August 6, 2015",            //1.33
    "August 6, 2015",            //1.33
    "August 25, 2015",            //1.34
    "August 25, 2015",            //1.34
    "August 25, 2015",            //1.34
    "September 26, 2015",        //1.35
    "September 26, 2015",            //1.35
    "October 31, 2015",            //1.36
    "October 31, 2015",            //1.36
    "October 31, 2015",            //1.36
    "December 5, 2015",               // 1.37
    "December 29, 2015",                // 1.38
    "January 4, 2016",                // 1.39
    "February 3, 2016",                // 1.40
    "February 3, 2016",                // 1.40
    "February 3, 2016",                    // 1.40
    "February 3, 2016",                // v1.40
    "February 15, 2016",            // v1.41
    "February 15, 2016",            // v1.41
    "March 12, 2016",                // v1.42
    "March 12, 2016",                // v1.42
    "March 22, 2016",                // v1.43
    "April 8, 2016",                    // v1.44
    "April 14, 2016",                // v1.45
    "June 1, 2016",                // v1.46
    "June 8, 2016",                    // v1.47
    "August 18, 2016",                    // v1.48
    "August 18, 2016",                    // v1.48
    "August 27, 2016"                    // v1.49
};

stock FindVersionData(Handle:panel, versionIndex)
{
    switch(versionIndex)
    {
        case 123: // 1.49
        {
            DrawPanelText(panel, "1) [Source Code] Source code is now a modular design (SHADoW)");
        }
        case 122: // 1.48
        {
            DrawPanelText(panel, "1) [Gameplay] A single bot will spawn if human players connected are below 2 (SHADoW)");
            DrawPanelText(panel, "2) [Configs] Song time can now also be defined as MM:SS:MS (eg: 180.0 or 3:00:00) (SHADoW)");
            DrawPanelText(panel, "3) [Configs] Song time now displays on !ff2tracklist (SHADoW)");
            DrawPanelText(panel, "4) [Core] Added support for RTD 2! (SHADoW)");
            DrawPanelText(panel, "5) [Gameplay] Reduced shield health to 700 from 1000 (SHADoW)");
        }
        case 121: // 1.48
        {
            DrawPanelText(panel, "6) [Gameplay] Reduced damage resistance of shields from 50% to 25%(SHADoW)");
            DrawPanelText(panel, "7) [Configs] Added translations support for default UNKNOWN song/artist info (SHADoW)");
        }
        case 120: // 1.47
        {
            DrawPanelText(panel, "1) [Commands] Added 'ff2_start_music' and updated 'ff2_stop_music' (SHADoW/Wliu)");
            DrawPanelText(panel, "2) [Gameplay] Boss ability tooltips are now hint texts (SHADoW)");
            DrawPanelText(panel, "3) [Gameplay] If taunting to rage, perform your weapon taunt to use RAGE (SHADoW)");
        }
        case 119: // 1.46
        {
            DrawPanelText(panel, "1) [Configs] Added manual tagging of boss themes (SHADoW)");
            DrawPanelText(panel, "2) [Core] Rewrote FF2's clusterf**ked cookie system (SHADoW)");
            DrawPanelText(panel, "3) [Core] FF2 music volume can now be adjusted with TF2's music volume slider (Deathreus)");
            DrawPanelText(panel, "4) [Core] Hopefully fixed a critical issue with VSH map switching (SHADoW from Haxray)");        
            DrawPanelText(panel, "5) [Core] Fixed occasional empty win score (naydef)");
        }
        case 118: // 1.45
        {
            DrawPanelText(panel, "1) [Gameplay] Fixed a serious exploit related to weightdown and ubercharge rages (SHADoW)");     
        }
        case 117: // 1.44
        {
            DrawPanelText(panel, "1) [Gameplay] Removed damage resistance upon melee hit when using a shield (SHADoW)");
            DrawPanelText(panel, "2) [Gameplay] Fixed RAGE not being reset when round is over (SHADoW)");       
            DrawPanelText(panel, "3) [Gameplay] Fixed a serious exploit with 'rage_matrix_attack' (naydef)");    
            DrawPanelText(panel, "4) [Natives] Added FF2_{Get|Set}ClientDifficultyLevel (SHADoW)");
        }
        case 116: // 1.43
        {
            DrawPanelText(panel, "1) [Gameplay] Shields no longer break on a single melee hit (SHADoW)");
            DrawPanelText(panel, "2) [Gameplay] Shields absorb 50% non-melee damage, 25% melee damage (SHADoW)");
            DrawPanelText(panel, "3) [Gameplay] Shields slowly lose damage resistance as shield health lowers (SHADoW)");
            DrawPanelText(panel, "4) [Core] Fixed health not being shown properly before round starts (Wliu)");
        }
        case 115: // 1.42
        {
            DrawPanelText(panel, "1) [Core] Fixed rage damage being accidentally set x10 when not in x10 mode (SHADoW)");      
            DrawPanelText(panel, "2) [Gameplay] Updated cloak and dead ringer damage code (Wliu)");            
            DrawPanelText(panel, "3) [Gameplay] 'ff2_alive' now also prints in chat (Wliu)");    
            DrawPanelText(panel, "4) [Gameplay] Fixed shields not blocking lethal damage (SHADoW)");
            DrawPanelText(panel, "5) [Gameplay] Shields now protect against minion damage (SHADoW)");
        }
        case 114: // 1.42
        {
            DrawPanelText(panel, "6) [Gameplay] Shields now block a single lethal hit or melee hit, and has a health bar (SHADoW)");
            DrawPanelText(panel, "7) [Gameplay] Shields will block a single hit upon its HP being completely depleted (SHADoW)");
            DrawPanelText(panel, "8) [Gameplay] Shields offer 50% damage resistance until its HP is completely depleted (SHADoW)");
            DrawPanelText(panel, "9) [HUD] Fixed tooltips for activating charged abilities never displaying...again (SHADoW)");
        }
        case 113: // 1.41
        {
            DrawPanelText(panel, "1) [Core] Added support for TF2x10 (SHADoW)");              
            DrawPanelText(panel, "2) [Configs] Boss weapons can now use custom models: (SHADoW)");            
            DrawPanelText(panel, "    - 'worldmodel' is general world model");
            DrawPanelText(panel, "    - 'pyrovision' is pyrovision world model");
            DrawPanelText(panel, "    - 'halloweenvision' is halloween world model");        
            DrawPanelText(panel, "    - 'romevision' is romevision world model");            
        }
        case 112: // 1.41
        {
            DrawPanelText(panel, "3) [HUD] Some TF2-style notifications now use TF2-style tooltips (naydef/SHADoW)");
            DrawPanelText(panel, "4) [HUD] Fixed tooltips for activating charged abilities never showing (SHADoW)");
            DrawPanelText(panel, "5) [Core] OnTakeDamage -> OntakeDamageAlive (Wliu)");
            DrawPanelText(panel, "6) [Core] OnTakeDamagePost -> OntakeDamageAlivePost (Wliu)");
            DrawPanelText(panel, "7) [Core] Backported latest FF2 v2 BETA functions (SHADoW)");
        }
        case 111: // 1.40
        {
            DrawPanelText(panel, "1) [Configs] Weapon quality can now be set with 'quality' (SHADoW)");              
            DrawPanelText(panel, "2) [Configs] Weapon level can now be set with 'level' (SHADoW)");            
            DrawPanelText(panel, "3) [Configs] Default weapon quality is now 'Collectors', from 'Unusual' (SHADoW)");
            DrawPanelText(panel, "4) [Configs] Default weapon level is now 101, from 100 (SHADoW)");
            DrawPanelText(panel, "5) [Gameplay] Minor cosmetic changes to HUD effects (SHADoW)");
        }
        case 110: // 1.40
        {
            DrawPanelText(panel, "6) [Core] Damage tripling is no longer handled internally (SHADoW)");    
            DrawPanelText(panel, "7) [Gameplay] !ff2difficulty now lets you change boss difficulty (as boss) (SHADoW)");
            DrawPanelText(panel, "8) [Configs] 'rage_{stun|stunsg}' now allows the delay between activating to be set via 'arg2' (SHADoW)");
            DrawPanelText(panel, "9) [Core] Limited support for v2 configs and subplugins has been added (SHADoW)"); 
            DrawPanelText(panel, "10) [Server] Fixed server crashes related to 'game_text_tf' entities (naydef)");
        }
        case 109: // 1.40
        {
            DrawPanelText(panel, "11) [Natives] Fixed FF2_Get{Alive|Boss}Players returning the wrong values (SHADoW)");     
            DrawPanelText(panel, "12) [HUD] Hint texts now use TF2-style messages, unless only 1 alive player remains (SHADoW)");     
            DrawPanelText(panel, "13) [Natives] All natives now have a public analogue for using reflection (SHADoW from sarysa)"); 
            DrawPanelText(panel, "14) [Gameplay] Bots no longer count towards boss kills / bosses slain (SHADoW)");    
            DrawPanelText(panel, "15) [Gameplay] Now auto-detects if minimal hud is being used! (naydef)");
        }
        case 108: // 1.40
        {
            DrawPanelText(panel, "16) [Gameplay] Boss HP now compensated when their companion is missing. (SHADoW)");
            DrawPanelText(panel, "17) [Subplugins] 'default_abilities' now manages damage tripling (SHADoW)");
            DrawPanelText(panel, "18) [Abilities] Added 'special_notripledamage' to disable damage tripling for a boss (SHADoW)");
            DrawPanelText(panel, "19) [Core] Rewrote boss BGM code & fixed FF2_StartMusic (Wliu/SHADoW)");
            DrawPanelText(panel, "20) [Core] Fixed FF2_StopMusic not ending BGM if changed via FF2_OnMusic (SHADoW)");
        }
        case 107: // 1.39
        {
            DrawPanelText(panel, "1) [Gameplay] The StatTrak update is here! (SHADoW)");              
            DrawPanelText(panel, "2) [Preferences] Preferences no longer reset if plugin is reloaded/late loaded! (SHADoW)");
            DrawPanelText(panel, "3) [Gameplay] FF2 now automagically detects if a boss has no valid weapon, and re-equips them (SHADoW)");
            
        }
        case 106: // 1.38
        {
            DrawPanelText(panel, "1) [Gameplay] Boss weapons are no longer invisible, if show is set to 1 (naydef)");      
            DrawPanelText(panel, "2) [Gameplay] Fixed spy backstab animations being broken (Dalix)");        
        }
        case 105: // 1.37
        {
            DrawPanelText(panel, "1) [Gameplay] Spectators now see glow on players and bosses (SHADoW)");      
            DrawPanelText(panel, "2) [Gameplay] Prevent wallclimb from working on clip brushes (Starblaster64)");
            DrawPanelText(panel, "3) [Gameplay] Workaround for TF2-bug with Ubercharge implemented (Chdata/Starblaster64)");
            DrawPanelText(panel, "4) [Gameplay] Fixed boss RPS damage being broken...yet again (SHADoW)");
        }
        case 104: // 1.36
        {
            DrawPanelText(panel, "1) [ConVars] 'ff2_default_health' sets default v1 HP formula (SHADoW)");        
            DrawPanelText(panel, "2) [ConVars] 'ff2_default_ragedamage' sets default rage damage (SHADoW)");        
            DrawPanelText(panel, "3) [ConVars] 'ff2_default_movespeed' sets default boss speed (SHADoW)");        
            DrawPanelText(panel, "4) [ConVars] 'ff2_default_ragedist' sets default rage distance (SHADoW)");        
            DrawPanelText(panel, "5) [ConVars] 'ff2_medieval_hp_divider' sets boss health divider for medieval mode (SHADoW)");    
        }
        case 103: // 1.36
        {        
            DrawPanelText(panel, "6) [Gameplay] Fixed boss RPS damage being broken...again (SHADoW)");        
            DrawPanelText(panel, "7) [Gameplay] Removed Huntsman taunt cooldown and re-enabled dead ringer speed buff (SHADoW)");
            DrawPanelText(panel, "8) [Configs] Added forward compatibility with FF2 v2 configs (SHADoW)");                
            DrawPanelText(panel, "9) [Prefs] Added option to disable bosses / companions for 1 map duration (SHADoW)");     
            DrawPanelText(panel, "10) [Configs] Added '{red|green|blue|alpha}' as a boss weapon config option (SHADoW)");
        }
        case 102: // 1.36
        {
            DrawPanelText(panel, "11) [Gameplay] Queue points are no longer reset if queue points are disabled (SHADoW)");        
            DrawPanelText(panel, "12) [ConVars] 'ff2_dmg_kstreak' sets minimum damage to increase killstreak count (SHADoW)");        
            DrawPanelText(panel, "13) [Core] Minor code tweaks (SHADoW)");
        }
        case 101: // 1.35
        {
            DrawPanelText(panel, "1) [Commands] Added '{hale|ff2}_select' to make a player the next boss (SHADoW from Chdata)");        
            DrawPanelText(panel, "2) [Gameplay] Boss RPS now counts towards player's damage properly based on HP left (SHADoW)");        
            DrawPanelText(panel, "3) [Gameplay] Hopefully fixed glow not working correctly (SHADoW)");        
            DrawPanelText(panel, "4) [Server] Fixed unexpected reloads not ending the current active round (SHADoW)");        
            DrawPanelText(panel, "5) [Configs] Fixed charset voting (Wliu)");
        }
        case 100: // 1.35
        {
            DrawPanelText(panel, "6) [Dev] Added 'ff2_developermode' to enable FF2 developer commands (SHADoW93)");        
            DrawPanelText(panel, "7) [Dev Commands] Added '{ff2|hale}_set{rage|charge}' (SHADoW93 from Chdata)");        
            DrawPanelText(panel, "8) [Dev Commands] Added '{ff2|hale}_setinfiniterage' (SHADoW from Chdata)");        
            DrawPanelText(panel, "9) [Maps] Fixed map blacklist not working correctly sometimes (SHADoW)");                        
        }
        case 99: // 1.34
        {
            DrawPanelText(panel, "1) [Configs] Moved non-boss configs to 'data/freak_fortress_2' (SHADoW)");        
            DrawPanelText(panel, "2) [Weapons] Weapon configs are no longer hardcoded, and are now in 'weapons.cfg' (SHADoW)");        
            DrawPanelText(panel, "3) [Maps] Blacklisted maps specified on 'spawn_teleport_blacklist' will teleport the boss to the nearest CP (SHADoW)");        
            DrawPanelText(panel, "4) [Configs] Bosses can now be hidden from '!ff2boss' by setting 'hidden' to 1 on their config (SHADoW)");        
            DrawPanelText(panel, "5) [Maps] PropHunt & Deathrun maps are now treated as VSH maps (SHADoW)");
        }
        case 98: // 1.34
        {
            DrawPanelText(panel, "6) [Configs] Added 'override' sections to force files to download in those sections (SHADoW)");        
            DrawPanelText(panel, "7) Weapon checks should be a lot more smoother now (SHADoW)");        
            DrawPanelText(panel, "8) [Configs] 'sound_' and 'catch_phrase' sections will now be automatically added to downloads table (SHADoW)");        
            DrawPanelText(panel, "9) [Configs] Missing phy files will no longer be logged (SHADoW)");        
            DrawPanelText(panel, "10) [Server] Added 'ff2_reloadweapons' and 'ff2_reloadconfigs' commands (SHADoW)");
        }
        case 97: // 1.34
        {
            DrawPanelText(panel, "11) [Bosses] Fixed companion lives and rage damage not being set (Wliu)");        
            DrawPanelText(panel, "12) [Configs] Added 'skip_filechecks' option to bypass file checks (SHADoW)");        
            DrawPanelText(panel, "13) [Server] FF2-related logs are now logged in 'logs/freak_fortress_2' (SHADoW)");        
            DrawPanelText(panel, "14) [Players] Fixed disconnecting bosses ending rounds on multiboss rounds (SHADoW)");        
            DrawPanelText(panel, "15) [Dev] New include file - 'freak_fortress_2_extras.inc' (SHADoW)");
        }
        case 96: // 1.33
        {
            DrawPanelText(panel, "1) [Players] Fixed living spectator bugs...again - see #11 for details (SHADoW)");        
            DrawPanelText(panel, "2) [Dev] TF2_RegeneratePlayer can now be used to regenerate a boss's weapon loadout - see #11 for details (SHADoW)");
            DrawPanelText(panel, "3) Fixed 'companion' section being case-sensitive (SHADoW)");
            DrawPanelText(panel, "4) [Dev] Added 'preset' bool to FF2_OnSpecialSelected (Wliu)");
            DrawPanelText(panel, "5) [Players] Market Gardener & Ullapool Caber can only crit while blast jumping (SHADoW)");
        }
        case 95: // 1.33
        {
            DrawPanelText(panel, "6) [Players] Minions now have the same minicrit / crit boost restrictions (SHADoW)");
            DrawPanelText(panel, "7) Fixed the first boss option on !ff2boss list returning a random boss (Wliu/Lawd)");
            DrawPanelText(panel, "8) Countdown timer is now color-coded  (SHADoW)");
            DrawPanelText(panel, "9) [Configs] Fixed 'bossteam' option endlessly switching teams if setting is 1 (SHADoW)");
            DrawPanelText(panel, "10) [Players] Lowered huntsman skewer taunt cooldown from 10 seconds to 7 (SHADoW)");
        }    
        case 94: // 1.33
        {
            DrawPanelText(panel, "11) 'post_inventory_application' is now used to execute Make{Boss|NotBoss} (SHADoW)");
            DrawPanelText(panel, "12) Overtime mode activates if countdown timer expires while capping a point (SHADoW)");
            DrawPanelText(panel, "13) [Server] New cvar - 'ff2_countdown_overtime' - determines if #12 would fire (SHADoW)");
            DrawPanelText(panel, "14) Fixed and rebalanced blutsauger and scorch shot (SHADoW)");
            DrawPanelText(panel, "15) Fixed server name not updating when FF2 is inactive or when a round ends (SHADoW)");
        }
        case 93: // 1.32
        {
            DrawPanelText(panel, "1) [Players] Replaced Sniper Rifle crits with triple damage (Wliu)");        
            DrawPanelText(panel, "2) [Players] Fixed Gun Mettle Medigun skins being replaced by a normal medigun (SHADoW)");        
            DrawPanelText(panel, "3) [Players] The Huntsman skewer taunt now has a cooldown between uses (SHADoW)");            
            DrawPanelText(panel, "4) [Bosses] Fixed boss anchor not working properly (SHADoW)");        
            DrawPanelText(panel, "5) [Players] Sandviches provide temporary damage protection while being consumed (SHADoW)");    
        }
        case 92: // 1.32
        {
            DrawPanelText(panel, "6) [Players] Air strike grants full crits while blast jumping, minicrits if parachuting (SHADoW)");                    
            DrawPanelText(panel, "7) [Players] Fixed certain weapons not getting their stats overriden (SHADoW)");                    
            DrawPanelText(panel, "8) [Bosses] Fixed stun scaling always returning solo-raging (SHADoW)");                    
        }
        case 91: // 1.31
        {
            DrawPanelText(panel, "1) [Players] Reverted Gunslinger buffs (SHADoW)");        
            DrawPanelText(panel, "2) [Players] Reverted some Valve weapon buffs/nerfs and allowed Natascha to be used (SHADoW)");            
            DrawPanelText(panel, "3) [Bosses] Fixed 1st round bosses not getting all of their health (SHADoW)");            
            DrawPanelText(panel, "4) [Bosses] Stun rage duration is now scaled by players caught in radius, duration arg is max length (SHADoW)");
            DrawPanelText(panel, "5) [Bosses] Fixed first person weapon animation bugs (Chdata)");
        }
        case 90: // 1.31
        {
            DrawPanelText(panel, "6) [Players] Disabled dropping weapons during boss rounds (sarysa/Starblaster64)");
            DrawPanelText(panel, "7) [Bosses] Fixed a bug with teleport particles not working properly (Wliu from M76030)");
            DrawPanelText(panel, "8) [Bosses] Fixed a bug with teleport sounds not playing properly (Wliu from M76030)");
            DrawPanelText(panel, "9) [Players] Whitelisted new Gun Mettle cosmetic weapon skins (SHADoW)");
            DrawPanelText(panel, "10) [Players] Cloak and dagger is now an invis-watch reskin (SHADoW)");        }
        case 89: // 1.31
        {
            DrawPanelText(panel, "11) [Players] Updated Big Earner to provide a momentary speed boost upon backstab (Starblaster64)");
            DrawPanelText(panel, "12) [Players] Cloak and dagger is now an invis-watch reskin (SHADoW)");
            DrawPanelText(panel, "13) [Bosses] Fixed teleport to spawn firing before a round starts if a boss congas/kazotsky kicks to a harmful location (SHADoW)");
            DrawPanelText(panel, "14) [Players] Fixed Sydney Sleeper subtracting RAGE (Starblaster64)");
            DrawPanelText(panel, "15) [Players] Spies can no longer get cloak from dispensers while cloaked (Chdata)");
        }
        case 88: // 1.31
        {
            DrawPanelText(panel, "16) [Bosses] Fixed large amounts of damage insta-killing multi-life bosses (Wliu)");
            DrawPanelText(panel, "17) [Players] Dead Ringer will reduce incoming damage to 62 while cloaked. No speed boost on feign death.(Chdata)");
            DrawPanelText(panel, "18) [Players] All invis watch types will reduce other incoming damage by 90pct.(Starblaster64)");
            DrawPanelText(panel, "19) [Players] Diamondback revenge crits on stab reduced from 3 -> 2.(Chdata)");
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
            DrawPanelText(panel, "6) [Dev] Added new natives/stocks: Debug, FF2_EnableClientGlow and FF2_GetClientGlow (Wliu)");
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
    if(Enabled2 && IsValidClient(client))
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

void ShowAnnouncement(float gameTime)
{
    static announcecount=-1;
    announcecount++;
    if(Enabled2)
    {
        switch(announcecount)
        {
            case 1:
            {
                CPrintToChatAll("%t", "FF2 Fork Build", PLUGIN_VERSION);
            }
            case 2:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Updates", PLUGIN_VERSION, ff2versiondates[maxVersion]);
            }
            case 3:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Toggle Command");
            }
            case 4:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Companion Command");
            }
            case 5:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Difficulty Command");
            }
            case 6:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Boss Selection Command");
            }
            case 7:
            {
                CPrintToChatAll("%t", "FF2 Version Info", PLUGIN_VERSION);
            }
            case 8:
            {
                announcecount=0;
                CPrintToChatAll("{olive}[FF2]{default} %t", "FF2 Group");
            }
            default:
            {
                CPrintToChatAll("{olive}[FF2]{default} %t", "type_ff2_to_open_menu");
            }
        }
        AnnounceAt = Announce ? gameTime+Announce : INACTIVE;
    }
}
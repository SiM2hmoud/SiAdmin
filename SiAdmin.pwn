// ---------------------------------------------------------------------------------- //
//                                                                                    //
//                     SiAdmin System                                                 //   
//                            Version: 0.1.0                                          //
//                                    Developer: SiM2hmoud                            //
//                                                                                    //
// ---------------------------------------------------------------------------------- //

#define FILTERSCRIPT

// -----------------------------[ Includes: ]------------------------------ //

#include <a_samp> // Thanks to SA:MP Team.
#include <YSI\y_ini> // Thanks to Y_Less.
#include <zcmd> // Thanks to Zeex.
#include <sscanf2> // Thanks to Y_Less.

// -----------------------------[ Defines: ]------------------------------ //

#define D_Register 1
#define D_Login 2
#define D_Register2 3
#define D_Login2 4

// -----------------------------[ Colors: ]------------------------------ //

#define CRed 0xFF0000FF
#define CGrey 0xAFAFAFAA
#define CGreen 0x33AA33AA3AA
#define CYellow 0xFFFF00AA
#define COrange 0xFF9900AA
#define CLime 0x10F441AA
#define CLBlue 0x33CCFFAA

// -----------------------------[ Settings: ]------------------------------ //
// -- [ Max Levels: ] -- //

#define MAX_ADMIN_LEVEL 4

// -- [ Level Names: ] -- //

#define LVL1 "Moderator"
#define LVL2 "Junior Admin"
#define LVL3 "Senior Admin"
#define LVL4 "Management"

// -- [ General Settings } -- //

#define MAX_WARNS 3

// -----------------------------[ Forwards: ]------------------------------ //

forward LoadUser_data(playerid,name[],value[]);
forward BanPlayer(playerid);
forward KickPlayer(playerid);
forward CheckHealth(playerid);
forward CheckArmour(playerid);
forward CheckPing(playerid);

// -----------------------------[ Saving Location: ]------------------------------ //

#define PATH "/Accounts/%s.ini"

// -----------------------------[ Saving Data: ]------------------------------ //

enum pInfo
{
    pPass,
    pAdmin
}

// -----------------------------[ Variables: ]------------------------------ //

new PlayerInfo[MAX_PLAYERS][pInfo];
new Warns[MAX_PLAYERS];
new IsFreezed[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS];
new Jetpack[MAX_PLAYERS];

// -----------------------------[ Loading System: ]------------------------------ //

public LoadUser_data(playerid,name[],value[])
{
    INI_Int("Password:",PlayerInfo[playerid][pPass]);
    INI_Int("Admin:",PlayerInfo[playerid][pAdmin]);
    return 1;
}

// -----------------------------[ Filterscript: ]------------------------------ //

public OnFilterScriptInit()
{
    print("---------------------------------------------");
    print("-   SiAdmin v0.1.0 loaded successfully!     -");
    print("-        This Filtescript has been          -");
    print("-               Developed by                -");
    print("-                SiM2hmoud                  - ");
    print("---------------------------------------------");
    SetTimerEx("CheckHealth", 1000, 1,"i");
    SetTimerEx("CheckArmour", 1000, 1,"i");
    SetTimerEx("CheckPing", 1000, 1,"i");
}

public OnPlayerConnect(playerid)
{
    if(fexist(UserPath(playerid)))
    {
        INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
        ShowPlayerDialog(playerid, D_Login, DIALOG_STYLE_INPUT,"Login:","Type your password below to login.","Login","Quit");
    }
    else
    {
        ShowPlayerDialog(playerid, D_Register, DIALOG_STYLE_INPUT,"Create an Account:","Type your password below to create your account.","Register","Quit");
    }
    IsSpecing[playerid] = 0;
    Warns[playerid] = 0;
    IsFreezed[playerid] = 0;
    Jetpack[playerid] = 0;
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "[SERVER]: %s (%d) has joined the server!", pname, playerid);
    SendClientMessageToAll(CLime, string);
    print(string);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new INI:File = INI_Open(UserPath(playerid));
    INI_SetTag(File,"data");
    INI_WriteInt(File,"Admin:",PlayerInfo[playerid][pAdmin]);
    INI_Close(File);
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    format(string, sizeof(string), "[SERVER]: %s (%d) has left the server!", pname, playerid);
    print(string);
    SendClientMessageToAll(CGrey, string);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerHealth(playerid, 99);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    return 1;
}
public OnPlayerText(playerid, text[])
{
    new pname[MAX_PLAYER_NAME], string[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(PlayerInfo[playerid][pAdmin] == 0){ atext = "Player"; }
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    format(string, sizeof(string), "[%s] %s: %s", atext, pname, text);
    SendClientMessageToAll(-1, string);
	return 0;
}

public OnPlayerUpdate(playerid)
{
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)  // Anti-Jetpack hack.
    {
        if(Jetpack[playerid] == 1) return 1;
        else
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Jetpack hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
    if(Warns[playerid] >= MAX_WARNS) // Automaticly kicks player when he reaches MAX_WARNS.
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for having more than %d warns!", pname, MAX_WARNS);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
    if(GetPlayerWeapon(playerid) == 36 || 37 || 38)
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Weapons hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
    return 1;
}
public OnVehiclePaintjob(playerid, vehicleid, paintjobid) 
{
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(GetPlayerInterior(playerid) == 0) // Anti-Tunning hack.
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Tuning hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
}
public OnVehicleMod(playerid, vehicleid, componentid)
{
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(GetPlayerInterior(playerid) == 0) // Anti-Tunning hack.
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Tuning hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);

    }
    return 1;
}

public CheckHealth(playerid) // Anti-Health hack.
{
    new pname[MAX_PLAYER_NAME], string[128], Float:health;
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerHealth(playerid, health);
    if(health > 99) 
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Health hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
}
public CheckArmour(playerid) // Anti-Armour hack.
{
    new pname[MAX_PLAYER_NAME], string[128], Float:armour;
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerArmour(playerid, armour);
    if(armour > 99) 
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for using Armour hack!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
}
public CheckPing(playerid) // High ping checker.
{
    new pname[MAX_PLAYER_NAME], string[128];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(GetPlayerPing(playerid) > 300) 
    {
        format(string, sizeof(string), "[SERVER]: %s has been kicked from the server for having a high ping!", pname);
        SendClientMessageToAll(CRed, string);
        TogglePlayerControllable(playerid, false);
        SetTimer("KickPlayer", 200, false);
        print(string);
    }
}

// ------------------------------------- { Admin Commands: } -------------------------------------------------- //
// ------------------------------------- { RCON Admin: } -------------------------------------------------- //

CMD:acmds(playerid, params[]) 
{
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CLime, "[SERVER]: You need to be a high level admin to use this!");
    SendClientMessage(playerid, COrange, "-------------------{ Server Admin Commands: }------------------");
    SendClientMessage(playerid, CLime, "- Level 1: /goto, /get, /announce, /write, /asay, /apm, /checkhealth, /checkarmour, /spawn.");
    SendClientMessage(playerid, CLime, "- Level 2: /akill, /explode, /(un)freeze, /spec(off), /gotols, /sendtols.");
    SendClientMessage(playerid, CLime, "- Level 3: /warn, /kick, /ban, /sethealth, /setarmour, /setskin, /veh, /agivegun.");
    SendClientMessage(playerid, CLime, "- Level 4:  /skick, /sban, /setscore, /resetscore, /givecash.");
    SendClientMessage(playerid, COrange, "--------------------------------------------------------");
    return 1;
}
CMD:setadmin(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, string[128], string2[128], stringtoall[128], amount;
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "ud", targetid, amount)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /setadmin [ID] [Level].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!!");
    if(0 > amount > MAX_ADMIN_LEVEL) return SendClientMessage(playerid, CRed, "[SERVER]: Incorrect level.");
    if(PlayerInfo[targetid][pAdmin] == amount) return SendClientMessage(playerid, CRed, "[SERVER]: Player have that level already!");
    PlayerInfo[targetid][pAdmin] = amount;
    format(string, sizeof(string), "[SERVER]: You've set %s (%d)'s Admin level to %d!", tname, targetid, amount);
    format(string2, sizeof(string2), "[SERVER]: Server Owner %s (%d) set your Admin level to %d!", pname, playerid, amount);
    format(stringtoall, sizeof(stringtoall), "[SERVER]: Server Owner %s (%d) has set %s (%d)'s Admin level to %d!", pname, playerid, tname, targetid, amount);
    SendClientMessage(playerid, COrange, string);
    SendClientMessage(targetid, CLime, string2);
    SendClientMessageToAll(CLBlue, stringtoall);
    return 1;
}

// ------------------------------------- { Moderator: } -------------------------------------------------- //

CMD:goto(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, Float:x, Float:y, Float:z, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /goto [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: You can't go to yourself!");
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(playerid, x, y, z);
    format(string, sizeof(string), "[SERVER]: You've teleported to %s (%d)!", tname, targetid);
    format(string2, sizeof(string2), "[SERVER]: %s %s (%d) teleported to your location!", atext ,pname, playerid);
    return 1;
}
CMD:get(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, Float:x, Float:y, Float:z, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /get [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: You can't get yourself!");
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(targetid, x, y, z);
    format(string, sizeof(string), "[SERVER]: You've teleported to %s (%d) to your location!", tname, targetid);
    format(string2, sizeof(string2), "[SERVER]: %s %s (%d) teleported you to their location!", atext ,pname, playerid);
    return 1;
}
CMD:announce(playerid, params[]) 
{
    new string[128];
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "s", string)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /announce [Text].");
    GameTextForAll(string, 6000, 5);
    return 1;
}
CMD:write(playerid, params[]) 
{
    new string[128];
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "s", string)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /write [Text].");
    SendClientMessageToAll(CRed, string);
    return 1;
}
CMD:asay(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], string[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "s", string)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /asay [Text].");
    format(string, sizeof(string), "[%s] %s: %s", atext, pname, string);
    SendClientMessageToAll(CRed, string);
    return 1;
}
CMD:apm(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "us", targetid, string)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /apm [ID] [Text].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: You can't send A-PM to yourself!");
    format(string, sizeof(string), "[A-PM] %s %s (%d): %s", atext, pname, targetid, string);
    SendClientMessage(targetid, CRed, string);
    format(string2, sizeof(string2), "[SERVER]: You sent a privite Admin message to %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    return 1;
}
CMD:checkhealth(playerid, params[]) 
{
    new tname[MAX_PLAYER_NAME], targetid, string[128], Float:health;
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /checkhealth [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    GetPlayerHealth(targetid, health);
    format(string, sizeof(string), "[SERVER]: %s's health is %.1f.", tname, health);
    SendClientMessage(playerid, CLime, string);
    return 1;
}
CMD:checkarmour(playerid, params[]) 
{
    new tname[MAX_PLAYER_NAME], targetid, string[128], Float:armour;
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /checkarmour [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    GetPlayerHealth(targetid, armour);
    format(string, sizeof(string), "[SERVER]: %s's armour is %.1f.", tname, armour);
    SendClientMessage(playerid, CLime, string);
    return 1;
}
CMD:spawn(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], targetid, tname[MAX_PLAYER_NAME], string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 1){ atext = LVL1; }
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /spawn [ID]!");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    SpawnPlayer(targetid);
    format(string, sizeof(string), "[SERVER]: %s %s (%d) spawned you!", atext,pname, playerid);
    format(string2, sizeof(string2), "[SERVER]: You've spawned %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, COrange, string);
    return 1;
}


// ------------------------------------- { Junior Admin: } -------------------------------------------------- //

CMD:akill(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], targetid, tname[MAX_PLAYER_NAME], string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /akill [ID]!");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    SetPlayerHealth(targetid, 0.0);
    format(string, sizeof(string), "[SERVER]: %s %s (%d) killed you!", atext,pname, playerid);
    format(string2, sizeof(string2), "[SERVER]: You've killed %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string);
    return 1;
}
CMD:explode(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], targetid, tname[MAX_PLAYER_NAME], string[128], string2[128], Float:x, Float:y, Float:z, atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /explode [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    GetPlayerPos(targetid, x, y, z);
    CreateExplosion(x, y, z, 1, 5);
    format(string, sizeof(string), "[SERVER]: %s %s (%d) exploded you!", atext, pname, playerid);
    format(string2, sizeof(string2), "[SERVER]: You exploded %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string);
    return 1;
}
CMD:freeze(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], targetid, tname[MAX_PLAYER_NAME], string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /freeze [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(IsFreezed[targetid] == 1) return SendClientMessage(playerid, CRed, "[SERVER]: Player is already freezed!");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    TogglePlayerControllable(playerid, 0);
    IsFreezed[targetid] = 1;
    format(string, sizeof(string), "[SERVER]: %s %s (%d) freezed you!", atext ,pname, playerid);
    format(string2, sizeof(string2), "[SERVER]: You freezed %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string);
    return 1;
}
CMD:unfreeze(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], targetid, tname[MAX_PLAYER_NAME], string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /unfreeze [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(IsFreezed[targetid] == 0) return SendClientMessage(playerid, CRed, "[SERVER]: Player is already unfreezed!");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    IsFreezed[targetid] = 0;
    TogglePlayerControllable(playerid, 1);
    format(string, sizeof(string), "[SERVER]: %s %s (%d) unfreezed you!", atext ,pname, playerid);
    format(string2, sizeof(string2), "[SERVER]: You unfreezed %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string);
    return 1;
}
CMD:spec(playerid, params[]) 
{
    new string[128], targetid, tname[MAX_PLAYER_NAME];
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /spec [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: You're kidding right? you can't spectate yourself.");
    if(IsSpecing[playerid] == 1) return SendClientMessage(playerid, CRed, "[SERVER]: /specoff first.");
    IsSpecing[playerid] = 1;
    TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, targetid, SPECTATE_MODE_NORMAL);
    format(string, sizeof(string), "[SERVER]: You're now specing %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string);
    return 1;
}
CMD:specoff(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(IsSpecing[playerid] == 0) return SendClientMessage(playerid, CRed, "[SERVER]: You're not spectating anyone.");
    IsSpecing[playerid] = 0;
    TogglePlayerSpectating(playerid, 0);
    SendClientMessage(playerid, CLime, "[SERVER]: Done.");
    return 1;
}
CMD:gotols(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    else
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, 1529.6, -1691.2, 13.3);
        SendClientMessage(playerid, CLime, "[SERVER]: You have been teleported to Los Santos!");
    }
    return 1;
}
CMD:sendtols(playerid, params[])
{
    new targetid, atext[60], string[128], string2[128], pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 2){ atext = LVL2; }
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /senttols [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: You can't do that. Use /gotols.");
    SetPlayerInterior(targetid, 0);
    SetPlayerPos(targetid, 1529.6, -1691.2, 13.3);
    format(string, sizeof(string), "[SERVER]: You've sent %s (%d) to Los Santos!", tname, targetid);
    format(string2, sizeof(string2), "[SERVER]: %s %s (%d) sent you to Los Santos!", atext, pname, playerid);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}

// ------------------------------------- { Senior Admin: } -------------------------------------------------- //

CMD:veh(playerid, params[])
{
    new car,color,color2, Float:x, Float:y, Float:z, Float:a;
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You need to be a high level admin to use this!");
    {
        if(sscanf(params, "iii", car,color,color2)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /veh [Model] [C1] [C2]");
        if(car < 400 || car > 611) return SendClientMessage(playerid,CRed, "[SERVER]: Invalid vehicle ID specified (411 - 611).");
        if(color> 255 || color< 0) return SendClientMessage(playerid, CRed, "[SERVER]: Car color IDs: 0-255.");
        if(color2> 255 || color2< 0) return SendClientMessage(playerid, CRed, "[SERVER]: Car color IDs: 0-255.");
        if(IsPlayerInAnyVehicle(playerid)) return RemovePlayerFromVehicle(playerid);
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid,a);
        new carid = CreateVehicle(car, x, y, z, a, color, color2, -1);
        PutPlayerInVehicle(playerid,carid, 0);
        LinkVehicleToInterior(carid,GetPlayerInterior(playerid));
    }
    return 1;
}

CMD:warn(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, reason[64], string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /warn [ID] [Reason].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected!");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    Warns[playerid]++;
    format(string, sizeof(string), "[SERVER]: %s %s (%d) warned you for ' %s '!", atext ,pname, playerid, reason);
    format(string2, sizeof(string2), "[SERVER]: You've warned %s (%d) for ' %s '!", tname, targetid, reason);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string);
    return 1;
}

CMD:kick(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, reason[60], string[128], string2[128], string3[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /kick [ID] [Reason].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: Don't try to kick yourself okay?");
    format(string, sizeof(string), "[SERVER]: %s %s (%d) kicked %s (%d) for ' %s '!", atext, pname, playerid, tname, targetid, reason);
    format(string2, sizeof(string2), "[SERVER]: You have been kicked by %s for ' %s '!", pname, reason);
    format(string3, sizeof(string3), "[SERVER]: You've kicked %s for ' %s '!", tname, reason);
    SendClientMessageToAll(CRed, string);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string3);
    SetTimer("KickPlayer", 1000, false);
    return 1;
}
CMD:ban(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, reason[60], string[128], string2[128], string3[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "us", targetid, reason)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /ban [ID] [Reason].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: That's dangerous son. Don't ban yourself.");
    format(string, sizeof(string), "[SERVER]: %s %s (%d) banned %s (%d) for ' %s '!", atext, pname, playerid, tname, targetid, reason);
    format(string2, sizeof(string2), "[SERVER]: You have been banned by %s for ' %s '!", pname, reason);
    format(string3, sizeof(string3), "[SERVER]: You've banned %s for ' %s '!", tname, reason);
    SendClientMessageToAll(CRed, string);
    SendClientMessage(playerid, CLime, string2);
    SendClientMessage(targetid, CRed, string3);
    SetTimer("BanPlayer", 1000, false);
    return 1;
}
CMD:sethealth(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, health, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }

    if(sscanf(params, "ud", targetid, health)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /sethealth [ID] [Amount].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if( 0 > health > 99) return SendClientMessage(playerid, CRed, "[SERVER]: Incorrect amount.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    SetPlayerHealth(targetid, health);
    format(string, sizeof(string), "[SERVER]: You've set %s (%d)'s health to %d!", tname, targetid, health); 
    format(string2, sizeof(string2), "[SERVER]: %s %s set your health to %d!", atext, pname, health);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}
CMD:setarmour(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, armour, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }

    if(sscanf(params, "ud", targetid, armour)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /setarmour [ID] [Amount].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if( 0 > armour > 99) return SendClientMessage(playerid, CRed, "[SERVER]: Incorrect amount.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    SetPlayerArmour(targetid, armour);
    format(string, sizeof(string), "[SERVER]: You've set %s (%d)'s armour to %d!", tname, targetid, armour); 
    format(string2, sizeof(string2), "[SERVER]: %s %s set your armour to %d!", atext, pname, armour);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}
CMD:setskin(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, skinid, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    if(sscanf(params, "ud", targetid, skinid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /setskin [ID] [Skin ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if( 0 > skinid > 311) return SendClientMessage(playerid, CRed, "[SERVER]: Skin ID must be between 0 & 311.");
    SetPlayerSkin(targetid, skinid);
    format(string, sizeof(string), "[SERVER]: You've set %s (%d)'s skin to %d!", tname, targetid, skinid); 
    format(string2, sizeof(string2), "[SERVER]: %s %s set your skin to %d!", atext, pname, skinid);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}
CMD:agivegun(playerid, params[])
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, gun, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    
    {
        if(sscanf(params, "ud", targetid, gun))
        {
            SendClientMessage(playerid, CRed, "[SERVER]: Usage: /givegun [ID] [WeaponID].");
            SendClientMessage(playerid, COrange,"_______________________________________");
            SendClientMessage(playerid, CYellow, "1: Brass Knuckles 2: Golf Club 3: Nite Stick 4: Knife 5: Baseball Bat 6: Shovel 7: Pool Cue 8: Katana 9: Chainsaw");
            SendClientMessage(playerid, CYellow, "10: Purple Dildo 11: Small White Vibrator 12: Large White Vibrator 13: Silver Vibrator 14: Flowers 15: Cane 16: Frag Grenade");
            SendClientMessage(playerid, CYellow, "17: Tear Gas 18: Molotov Cocktail 21: Jetpack 22: 9mm 23: Silenced 9mm 24: Deagle 25: Shotgun");
            SendClientMessage(playerid, CYellow, "26: Sawnoff Shotgun 27: Combat Shotgun 28: Micro SMG (Mac 10) 29: SMG (MP5) 30: AK-47 31: M4 32: Tec9 33: Country Rifle");
            SendClientMessage(playerid, CYellow, "34: Sniper Rifle 35: Rocket Launcher 36: Satchel Charge");
            SendClientMessage(playerid, CYellow, "40: Detonator 41: Spraycan 42: Fire Extinguisher 43: Camera 44: Nightvision Goggles 45: Infared Goggles 46: Parachute");
            SendClientMessage(playerid, COrange,"_______________________________________");
            return 1;
        }
        if(gun < 1 || gun > 46) { SendClientMessage(playerid, CRed, "[SERVER]: Don't go below 1 or above 47."); return 1; }
        if(IsPlayerConnected(targetid))
        {
            if(targetid != INVALID_PLAYER_ID)
            {
                if(gun == 21)
                {
                    Jetpack[playerid] = 1;
                    SetPlayerSpecialAction(targetid, SPECIAL_ACTION_USEJETPACK);
                }
                if(gun ==  37)
                GivePlayerWeapon(targetid, gun, 999999);
                format(string, sizeof(string), "[SERVER]: You have given gun %d to %s (%d)!", gun, tname, targetid);
                SendClientMessage(playerid, CLime, string);
                format(string2, sizeof(string2), "[SERVER]: %s %s (%d) gave you a weapon: %d!", atext, pname, playerid, gun);
                SendClientMessage(targetid, COrange, string2);
            }
        }
    }
    return 1;
}

// ------------------------------------- { Management: } -------------------------------------------------- //

CMD:skick(playerid, params[]) 
{
    new tname[MAX_PLAYER_NAME], targetid, string[128];
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "us", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /skick [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: Don't try to kick yourself okay?");
    format(string, sizeof(string), "[SERVER]: You've silently kicked %s (%d)!", tname, targetid);
    SendClientMessage(playerid, CLime, string);
    SetTimer("KickPlayer", 1000, false);
    return 1;
}
CMD:sban(playerid, params[]) 
{
    new tname[MAX_PLAYER_NAME], targetid, string[128];
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(sscanf(params, "us", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /sban [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    if(PlayerInfo[targetid][pAdmin] > 1 && PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, CRed, "[SERVER]: You can't use that on another admin!");
    if(targetid == playerid) return SendClientMessage(playerid, CRed, "[SERVER]: Don't try to ban yourself okay?");
    format(string, sizeof(string), "[SERVER]: You've silently banned %s (%d)! ", tname, targetid);
    SendClientMessage(playerid, CLime, string);
    SetTimer("BanPlayer", 1000, false);
    return 1;
}
CMD:setscore(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, score, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    if(sscanf(params, "ud", targetid, score)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /setscore [ID] [Amount].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    SetPlayerScore(targetid, score);
    format(string, sizeof(string), "[SERVER]: You've set %s (%d)'s score to %d!", tname, targetid, score); 
    format(string2, sizeof(string2), "[SERVER]: %s %s set your score to %d!", atext, pname, score);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}
CMD:resetscore(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    if(sscanf(params, "ud", targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /setscore [ID].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    SetPlayerScore(targetid, 0);
    format(string, sizeof(string), "[SERVER]: You've reset %s (%d)'s score to 0!", tname, targetid); 
    format(string2, sizeof(string2), "[SERVER]: %s %s set your score to 0!", atext, pname);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}
CMD:givecash(playerid, params[]) 
{
    new pname[MAX_PLAYER_NAME], tname[MAX_PLAYER_NAME], targetid, cash, string[128], string2[128], atext[60];
    GetPlayerName(playerid, pname, sizeof(pname));
    GetPlayerName(targetid, tname, sizeof(tname));
    if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, CRed, "[SERVER]: You must be a high level admin to use this!");
    if(PlayerInfo[playerid][pAdmin] == 3){ atext = LVL3; }
    if(PlayerInfo[playerid][pAdmin] == 4){ atext = LVL4; }
    if(sscanf(params, "ud", targetid, cash)) return SendClientMessage(playerid, CRed, "[SERVER]: Usage: /givecash [ID] [Amount].");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, CRed, "[SERVER]: Player is not connected.");
    GivePlayerMoney(targetid, cash);
    format(string, sizeof(string), "[SERVER]: You've gave %s (%d) $%d!", tname, targetid, cash); 
    format(string2, sizeof(string2), "[SERVER]: %s %s gave $%d!", atext, pname, cash);
    SendClientMessage(playerid, CLime, string);
    SendClientMessage(targetid, COrange, string2);
    return 1;
}

public KickPlayer(playerid)
{
    Kick(playerid);
}

public BanPlayer(playerid)
{
    Ban(playerid);
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch( dialogid )
    {
        case D_Register:
        {
            if (!response) return Kick(playerid);
            if(response)
            {
                if(!strlen(inputtext)) return ShowPlayerDialog(playerid, D_Register, DIALOG_STYLE_INPUT, "Create an Account:","You have entered an invalid password.\nType your password below to create a account.","Register","Quit");
                new INI:File = INI_Open(UserPath(playerid));
                INI_SetTag(File,"data");
                INI_WriteInt(File,"Password",udb_hash(inputtext));
                INI_WriteInt(File,"Admin",0);
                INI_Close(File);
			}
        }

        case D_Login:
        {
            if ( !response ) return Kick ( playerid );
            if( response )
            {
                if(udb_hash(inputtext) == PlayerInfo[playerid][pPass])
                {
                    INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
					ShowPlayerDialog(playerid, D_Login2, DIALOG_STYLE_MSGBOX,"Login:","You have successfully logged in!","Ok","");
                }
                else
                {
                    ShowPlayerDialog(playerid, D_Login, DIALOG_STYLE_INPUT,"Login:","You have entered an incorrect password.\n""Type your password below to login.","Login","Quit");
                }
                return 1;
            }
        }
    }
    return 1;
}

// -----------------------------[ Stocks: ]------------------------------ //

stock UserPath(playerid)
{
    new string[128],playername[MAX_PLAYER_NAME];
    GetPlayerName(playerid,playername,sizeof(playername));
    format(string,sizeof(string),PATH,playername);
    return string;
}

stock udb_hash(buf[]) {
    new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}
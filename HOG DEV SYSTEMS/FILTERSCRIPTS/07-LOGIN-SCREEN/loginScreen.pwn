/*
	Arquivo:
		modules/visual/login.pwn

	Descri��o:
		- Este m�dulo � direcionado ao login do jogador. Trabalha com
		uma tela de login em TextDraws, com bot�es Registrar, Entrar,
		Sobre e Vers�o.

	�ltima atualiza��o:
		03/08/17

	Copyright (C) 2017 Hogwarts RP/G
		(Adejair "Adejair_Junior" J�nior,
		Bruno "Bruno13" Travi,
		Jo�o "BarbaNegra" Paulo,
		Renato "Misterix" Venancio)

	Esqueleto do c�digo:
	|
	 *
	 * INCLUDES
	 *
	|
	 *
	 * DEFINITIONS
	 *
	|
	 *
	 * ENUMERATORS
	 *
	|
	 *
	 * VARIABLES
	 *
	|
	 *
	 * NATIVE CALLBACKS
	 *
	|
	 *
	 * MY CALLBACKS
	 *
	|
	 *
	 * FUNCTIONS
	 *
	|
	 *
	 * COMPLEMENTS
	 *
	|
*/
/*
 * INCLUDES
 ******************************************************************************
 */
#include <a_samp>
#include <fixes2>
#include <zcmd>
#include <FCNPC>
#include <..\..\..\INCLUDES\00-FADER\hogFader.inc>
#include <..\..\..\INCLUDES\01-MAGIC-ANIMATIONS\magicAnimation.inc>
/*
 * DEFINES
 ******************************************************************************
 */
static stock stringF[256];

#if !defined call
	#define call:%0(%1) forward %0(%1); public %0(%1)
#endif

#if !defined SendClientMessageEx
	#define SendClientMessageEx(%0,%1,%2,%3) format(stringF, sizeof(stringF),%2,%3) && SendClientMessage(%0, %1, stringF)
#endif

#define NPC_LOGIN_SCENARIO_NAME "NPC_LOGIN_CENARIO"

const
	
	SCENARIO_WEATHER		= 78,
	NPC_LOGIN_SCENARIO_SKIN	= 171,

	LOGIN_VIRTUAL_WORLD = 99;
/*
 * VARIABLES
 ******************************************************************************
 */
enum E_LOGIN_SCREEN_TEXT
{
	Text:E_LOGIN_TITLE[3],

	Text:E_LOGIN_BUTTON[3],

	Text:E_LOGIN_TEXT[4]
}

enum E_NPC_LOGIN_SCENARIO
{
	E_NPC_ID,
	bool:E_NPC_ANIMATING
}

static

	Text:textLoginScreen[E_LOGIN_SCREEN_TEXT],

	bool:playerInLoginScreen[MAX_PLAYERS char],

	mapBlock,

	npcLoginScenario[E_NPC_LOGIN_SCENARIO],
	playerDeath[MAX_PLAYERS];
/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnFilterScriptInit()
{
	CreateGlobalTDLoginScreen();

	CreateNPCLoginScenario();

	mapBlock = GangZoneCreate(-10000.0, -11000.0, 10000.0, 11000.0);

	print("\n-------------------------------------");
	print("      [HOG] Login Screen loaded");
	print("-------------------------------------\n");

	return 1;
}

public OnPlayerConnect(playerid)
{
	playerInLoginScreen[playerid] = true;
	playerDeath[playerid] = false;

	CreatePlayerFade(playerid, true);
    
	OpenLoginScreenToPlayer(playerid);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(playerInLoginScreen[playerid])
		PositionPlayerLoginScreen(playerid);

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;
   
	if(playerInLoginScreen[playerid])
	{
		TogglePlayerSpectating(playerid, 1);
		return 1;
	}

	if(playerDeath[playerid])
		playerDeath[playerid] = false;
	else
		SpawnPlayer(playerid);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	playerDeath[playerid] = true;

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == textLoginScreen[E_LOGIN_TEXT][0])
		OutPlayerOfScenario(playerid);

	return 1;
}
/*
 * MY CALLBACKS
 ******************************************************************************
 */
public OnFadeScreenPlayerChanged(playerid, bool:fadeType)
{
	if(fadeType == FADE_OUT)
		ShowTextDrawsLoginScreen(playerid, 0);
}

call:SetPlayerSpawn(playerid)
	SpawnPlayer(playerid);

call:StartFadeOut(playerid)
	fadeOut(playerid, 50);

call:ShowTextDrawsLoginScreen(playerid, tape)
{
	switch(tape)
	{
		case 0:
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TITLE][0]),
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TITLE][1]),
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TITLE][2]);
		case 1:
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_BUTTON][0]),
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TEXT][0]);
		case 2:
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_BUTTON][1]),
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TEXT][1]);
		case 3:
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_BUTTON][2]),
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TEXT][2]);
		case 4:
			TextDrawShowForPlayer(playerid, textLoginScreen[E_LOGIN_TEXT][3]);
	}

	if(tape != 4) SetTimerEx("ShowTextDrawsLoginScreen", 200, false, "ii", playerid, tape+1);
}
/*
 * FUNCTIONS
 ******************************************************************************
 */
OutPlayerOfScenario(playerid)
{
	static i;

	for(i = 0; i < 4; i++)
	{
		TextDrawHideForPlayer(playerid, textLoginScreen[E_LOGIN_TEXT][i]);

		if(i < 3)
			TextDrawHideForPlayer(playerid, textLoginScreen[E_LOGIN_TITLE][i]),
			TextDrawHideForPlayer(playerid, textLoginScreen[E_LOGIN_BUTTON][i]);
	}

	playerInLoginScreen[playerid] = false;

	CancelSelectTextDraw(playerid);

	SetCameraBehindPlayer(playerid);

	TogglePlayerSpectating(playerid, 0);

	SpawnPlayer(playerid);

    SetPlayerVirtualWorld(playerid, 0);

    SetPlayerInterior(playerid, 11);

	TogglePlayerControllable(playerid, true);
}
//----------------------
CreateNPCLoginScenario()
{
	npcLoginScenario[E_NPC_ANIMATING] = false;

	npcLoginScenario[E_NPC_ID] = FCNPC_Create(NPC_LOGIN_SCENARIO_NAME);

	if(npcLoginScenario[E_NPC_ID] == INVALID_PLAYER_ID)
		return print(" <!> Erro ao criar NPC_LOGIN_SCENARIO");

	if(!FCNPC_Spawn(npcLoginScenario[E_NPC_ID], NPC_LOGIN_SCENARIO_SKIN, 324.2294, 8824.7646, 14.3335))
		return print(" <!> Erro ao spawnar NPC_LOGIN_SCENARIO");

	FCNPC_SetAngle(npcLoginScenario[E_NPC_ID], 41.4946);
	FCNPC_SetInterior(npcLoginScenario[E_NPC_ID], 0);
	FCNPC_SetVirtualWorld(npcLoginScenario[E_NPC_ID], LOGIN_VIRTUAL_WORLD);

	LoadNPCAnimations(npcLoginScenario[E_NPC_ID]);

	print("    > NPC_LOGIN_SCENARIO criado");

	return true;
}

StartNPCMagicAnimation()
{
	if(!FCNPC_IsValid(npcLoginScenario[E_NPC_ID]))
		return printf(" <!> Erro ao iniciar anima��o m�gica do NPC_LOGIN_SCENARIO");

	if(npcLoginScenario[E_NPC_ANIMATING])
		return false;

	npcLoginScenario[E_NPC_ANIMATING] = true;

	LoadNPCAnimations(npcLoginScenario[E_NPC_ID]);

	StartFloatNPC(npcLoginScenario[E_NPC_ID]);

	return true;
}

StopNPCMagicAnimation()
{
	if(!FCNPC_IsValid(NPC_LOGIN_SCENARIO))
		return printf(" <!> Erro ao parar anima��o m�gica do NPC_LOGIN_SCENARIO");

	if(!npcLoginScenario[E_NPC_ANIMATING])
		return false;
	
	npcLoginScenario[E_NPC_ANIMATING] = false;

	StopFloatNPC(npcid);

	return true;
}
//-------------------------------
LoadPlayerLoginScenario(playerid)
{
	if(npcLoginScenario[E_NPC_ID] == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, -1, "N�o foi poss�vel carregar o cen�rio.");

	if(!npcLoginScenario[E_NPC_ANIMATING])
		StartNPCMagicAnimation();

	return true;
}

OpenLoginScreenToPlayer(playerid)
{
	TogglePlayerSpectating(playerid, 0);

	SetSpawnInfo(playerid, 0, 171, 324.2294, 8824.7646, 14.3335, 41.4946, 0, 0, 0, 0, 0, 0);

	SpawnPlayer(playerid);
}

PositionPlayerLoginScreen(playerid)
{
	GangZoneShowForPlayer(playerid, mapBlock, 0x000000FF);

	SetPlayerWeather(playerid, SCENARIO_WEATHER);
	SetPlayerVirtualWorld(playerid, LOGIN_VIRTUAL_WORLD);
	SetPlayerCameraPos(playerid, 321.521942, 8827.158203, 13.316607 + 1.4);
	SetPlayerCameraLookAt(playerid, 324.171295, 8824.163085, 13.204122 + 1.4);
	SetPlayerPos(playerid, 319.4734, 8829.8604, 12.9612);

	TogglePlayerControllable(playerid, false);

	SelectTextDraw(playerid, 0xDDDDDDAA);

	LoadPlayerLoginScenario(playerid);

	SetTimerEx("StartFadeOut", 3000, false, "i", playerid);
}

CreateGlobalTDLoginScreen()
{
	textLoginScreen[E_LOGIN_TITLE][0] = TextDrawCreate(345.529327, 118.833290, "H");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TITLE][0], 1.053176, 5.006666);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TITLE][0], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_TITLE][0], -1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][0], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TITLE][0], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TITLE][0], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TITLE][0], 1);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TITLE][0], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][0], 0);

	textLoginScreen[E_LOGIN_TITLE][1] = TextDrawCreate(369.058837, 141.583312, "ogwarts");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TITLE][1], 0.406587, 1.920830);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TITLE][1], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_TITLE][1], -1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][1], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TITLE][1], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TITLE][1], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TITLE][1], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TITLE][1], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][1], 0);

	textLoginScreen[E_LOGIN_TITLE][2] = TextDrawCreate(431.646972, 155.000030, "rp/g");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TITLE][2], 0.152941, 1.144997);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TITLE][2], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_TITLE][2], -1523963137);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][2], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TITLE][2], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TITLE][2], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TITLE][2], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TITLE][2], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TITLE][2], 0);

	textLoginScreen[E_LOGIN_BUTTON][0] = TextDrawCreate(333.764434, 79.166687, "-");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_BUTTON][0], 9.116230, 19.636692);
	TextDrawAlignment(textLoginScreen[E_LOGIN_BUTTON][0], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_BUTTON][0], -1523963178);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][0], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_BUTTON][0], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_BUTTON][0], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_BUTTON][0], 1);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_BUTTON][0], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][0], 0);

	textLoginScreen[E_LOGIN_TEXT][0] = TextDrawCreate(397.294097+1.0, 180.666748, "Entrar");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TEXT][0], 0.426822, 2.224164);
	TextDrawTextSize(textLoginScreen[E_LOGIN_TEXT][0], 25.000000, 100.000000);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TEXT][0], 2);
	TextDrawColor(textLoginScreen[E_LOGIN_TEXT][0], -1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][0], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TEXT][0], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TEXT][0], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TEXT][0], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TEXT][0], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][0], 0);
	TextDrawSetSelectable(textLoginScreen[E_LOGIN_TEXT][0], true);

	textLoginScreen[E_LOGIN_BUTTON][1] = TextDrawCreate(333.764434, 121.166725, "-");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_BUTTON][1], 9.116230, 19.636692);
	TextDrawAlignment(textLoginScreen[E_LOGIN_BUTTON][1], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_BUTTON][1], -1523963178);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][1], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_BUTTON][1], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_BUTTON][1], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_BUTTON][1], 1);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_BUTTON][1], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][1], 0);

	textLoginScreen[E_LOGIN_TEXT][1] = TextDrawCreate(397.294097+1.0, 223.833328-1.0, "registrar");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TEXT][1], 0.426822, 2.224164);
	TextDrawTextSize(textLoginScreen[E_LOGIN_TEXT][1], 25.000000, 100.000000);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TEXT][1], 2);
	TextDrawColor(textLoginScreen[E_LOGIN_TEXT][1], -1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][1], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TEXT][1], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TEXT][1], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TEXT][1], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TEXT][1], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][1], 0);
	TextDrawSetSelectable(textLoginScreen[E_LOGIN_TEXT][1], true);

	textLoginScreen[E_LOGIN_BUTTON][2] = TextDrawCreate(333.764434, 160.833358, "-");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_BUTTON][2], 9.116230, 19.636692);
	TextDrawAlignment(textLoginScreen[E_LOGIN_BUTTON][2], 1);
	TextDrawColor(textLoginScreen[E_LOGIN_BUTTON][2], -1523963178);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][2], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_BUTTON][2], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_BUTTON][2], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_BUTTON][2], 1);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_BUTTON][2], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_BUTTON][2], 0);

	textLoginScreen[E_LOGIN_TEXT][2] = TextDrawCreate(397.294097+1.0, 262.916748, "sobre");
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TEXT][2], 0.426822, 2.224164);
	TextDrawTextSize(textLoginScreen[E_LOGIN_TEXT][2], 22.000000, 100.000000);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TEXT][2], 2);
	TextDrawColor(textLoginScreen[E_LOGIN_TEXT][2], -1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][2], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TEXT][2], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TEXT][2], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TEXT][2], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TEXT][2], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][2], 0);
	TextDrawSetSelectable(textLoginScreen[E_LOGIN_TEXT][2], true);

	textLoginScreen[E_LOGIN_TEXT][3] = TextDrawCreate(446.705780, 293.250091, ConvertToGameText("vers�o ~r~1~w~.~r~0~w~.~r~0~w~a"));
	TextDrawLetterSize(textLoginScreen[E_LOGIN_TEXT][3], 0.141644, 0.777495);
	TextDrawTextSize(textLoginScreen[E_LOGIN_TEXT][3], 490.000000, 8.000000);
	TextDrawAlignment(textLoginScreen[E_LOGIN_TEXT][3], 3);
	TextDrawColor(textLoginScreen[E_LOGIN_TEXT][3], -1/*-1378294017*/);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][3], 0);
	TextDrawSetOutline(textLoginScreen[E_LOGIN_TEXT][3], 0);
	TextDrawBackgroundColor(textLoginScreen[E_LOGIN_TEXT][3], 255);
	TextDrawFont(textLoginScreen[E_LOGIN_TEXT][3], 2);
	TextDrawSetProportional(textLoginScreen[E_LOGIN_TEXT][3], 1);
	TextDrawSetShadow(textLoginScreen[E_LOGIN_TEXT][3], 0);
	TextDrawSetSelectable(textLoginScreen[E_LOGIN_TEXT][3], true);
}
/*
 * COMPLEMENTS
 ******************************************************************************
 */
/// <author>
/// Toribio
/// </author>
/// <summary>
/// Converte um texto espec�fico com acentos para ser utilizado em TextDraws ou
/// GameTexts.
/// </summary>
/// <param name="in">Texto.</param>
/// <returns>Texto convertido.</returns>
static ConvertToGameText(in[])
{
    new string[256];
    for(new i = 0; in[i]; ++i)
    {
        string[i] = in[i];
        switch(string[i])
        {
            case 0xC0 .. 0xC3: string[i] -= 0x40;
            case 0xC7 .. 0xC9: string[i] -= 0x42;
            case 0xD2 .. 0xD5: string[i] -= 0x44;
            case 0xD9 .. 0xDC: string[i] -= 0x47;
            case 0xE0 .. 0xE3: string[i] -= 0x49;
            case 0xE7 .. 0xEF: string[i] -= 0x4B;
            case 0xF2 .. 0xF5: string[i] -= 0x4D;
            case 0xF9 .. 0xFC: string[i] -= 0x50;
            case 0xC4, 0xE4: string[i] = 0x83;
            case 0xC6, 0xE6: string[i] = 0x84;
            case 0xD6, 0xF6: string[i] = 0x91;
            case 0xD1, 0xF1: string[i] = 0xEC;
            case 0xDF: string[i] = 0x96;
            case 0xBF: string[i] = 0xAF;
        }
    }
    return string;
}
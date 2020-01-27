/*
	Arquivo:
		modules/player/character.pwn

	Descri��o:
		- Este m�dulo � direcionado ao gerenciamento de personagens do jogador.

	�ltima atualiza��o:
		11/08/17

	Copyright (C) 2017 Hogwarts RP/G
		(Adejair "Adejair_Junior" J�nior,
		Bruno "Bruno13" Travi,
		Jo�o "BarbaNegra" Paulo,
		Jo�o "JPedro" Pedro,
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
	 * HOOKS
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
	 *
	 * COMMANDS
	 *
	|
*/
/*
 * INCLUDES
 ******************************************************************************
 */
//#include <YSI\y_hooks>

/*
 * DEFINITIONS
 ******************************************************************************
 */
forward ActorConversation(playerid, actorIndex, conversationType);

const

	/// <summary> 
	///	Defini��es das conversas entre os atores.</summary>
	CONVERSATION_TYPE_SPEECH	= 0,
	CONVERSATION_TYPE_RESPONSE	= 1,

	/// <summary> 
	///	Defini��o do m�ximo de slots.</summary>
	MAX_CHARACTERS_SLOTS		= 5,

	/// <summary> 
	///	Defini��es dos tipos de contas.</summary>
	ACCOUNT_TYPE_NORMAL			= 3,
	ACCOUNT_TYPE_PREMIUM		= 5,

	/// <summary> 
	///	Defini��es do slots.</summary>
	CONFIG_RESET_SLOT			= 0,
	CONFIG_SET_CHAR_SLOT		= 1,
	CONFIG_BLOCK_SLOT			= 2,

	/// <summary> 
	///	Defini��es do estado dos slots.</summary>
	STATE_EMPTY					= 0,
	STATE_CREATED				= 1,
	STATE_BLOCKED				= 2,

	/// <summary> 
	///	Defini��o de slot inv�lido.</summary>
	INVALID_CHAR_SLOT			= -1,

	/// <summary> 
	///	Defini��es da numera��o dos dialogs.</summary>
	DIALOG_SLOT_MESSAGE			= 19888;

/*
 * ENUMERATORS
 ******************************************************************************
 */
/// <summary> 
///	Enumerador da vari�vel 'playerActorScenario[MAX_PLAYERS][E_ACTOR_SCENARIO]'.</summary>
enum E_ACTOR_SCENARIO
{
	E_ACTOR_ID[2],
	E_ACTOR_CONVERSATION_TIMER[2]
}

/// <summary> 
///	Enumerador da vari�vel 'textCharSelectionGlobal[E_TEXT_CHAR_SELECTION_GLOBAL]'.</summary>
enum E_TEXT_CHAR_SELECTION_GLOBAL
{
	Text:E_HEADER[2],
	Text:E_CHAR_SLOT[MAX_CHARACTERS_SLOTS],
	Text:E_BUTTON_EDIT,
	Text:E_BUTTON_EDIT_TEXT,
	Text:E_BUTTON_EXIT,
	Text:E_BUTTON_EXIT_TEXT,
	Text:E_BUTTON_TRASH,
	Text:E_BUTTON_TRASH_TEXT,
	Text:E_BUTTON_TRASH_ICON,
	Text:E_BUTTON_DELETE[MAX_CHARACTERS_SLOTS]
}

/// <summary> 
///	Enumerador da vari�vel 'textCharCreationGlobal[E_TEXT_CHAR_CREATION_GLOBAL]'.</summary>
enum E_TEXT_CHAR_CREATION_GLOBAL
{
	Text:E_HEADER,
	Text:E_BUTTON_BACK,
	Text:E_BACKGROUND[7],
	Text:E_BACKGROUND_GENDER[2],
	Text:E_BUTTON_NAME,
	Text:E_BUTTON_SKIN,
	Text:E_BUTTON_HAIR,
	Text:E_BUTTON_EYE,
	Text:E_BUTTON_CREATE,
	Text:E_TEXT_CREATE
}

/// <summary> 
///	Enumerador da vari�vel 'textCharSelectionPrivate[MAX_PLAYERS][E_TEXT_CHAR_SELECTION_PRIVATE]'.</summary>
enum E_TEXT_CHAR_SELECTION_PRIVATE
{
	PlayerText:E_CHAR_SLOT_SKIN[MAX_CHARACTERS_SLOTS],
	PlayerText:E_CHAR_SLOT_NAME[MAX_CHARACTERS_SLOTS],
	PlayerText:E_CHAR_SLOT_LAST_ACESS[MAX_CHARACTERS_SLOTS]
}

/// <summary> 
///	Enumerador da vari�vel 'textCharCreationPrivate[MAX_PLAYERS][E_TEXT_CHAR_CREATION_PRIVATE]'.</summary>
enum E_TEXT_CHAR_CREATION_PRIVATE
{
	PlayerText:E_CHAR_NAME,
	PlayerText:E_CHAR_SKIN,
	PlayerText:E_CHAR_HAIR,
	PlayerText:E_CHAR_EYE,
	PlayerText:E_BUTTON_GENDER_MALE,
	PlayerText:E_BUTTON_GENDER_FEMALE
}

/// <summary> 
///	Enumerador da vari�vel 'textSelectedControl[MAX_PLAYERS][E_TEXT_SELECTED_CONTROL]'.</summary>
enum E_TEXT_SELECTED_CONTROL
{
	E_CHAR_SLOT,
	bool:E_BUTTON_EDIT
}

const
	size_E_CHAR_NAME = MAX_CHARACTERS_SLOTS * MAX_PLAYER_NAME,
	size_E_CHAR_LAST_ACESS = MAX_CHARACTERS_SLOTS * 5;

/// <summary> 
///	Enumerador da vari�vel 'playerCharacters[MAX_PLAYERS][E_PLAYER_CHARACTERS]'.</summary>
enum E_PLAYER_CHARACTERS
{
	E_ACCOUNT_TYPE,//TOTAL SLOTS
	E_CHAR_STATE[MAX_CHARACTERS_SLOTS],
	E_CHAR_SKIN[MAX_CHARACTERS_SLOTS],
	E_CHAR_NAME[size_E_CHAR_NAME],
	E_CHAR_LAST_ACESS[size_E_CHAR_LAST_ACESS]//0 - dia | 1 - m�s | 2 - ano | 3 - hora | 4 - min
}

#define E_CHAR_NAME][%1][%2] E_CHAR_NAME][((%1)*MAX_PLAYER_NAME)+(%2)]
#define E_CHAR_LAST_ACESS][%1][%2] E_CHAR_LAST_ACESS][((%1)*5)+(%2)]

/// <summary> 
///	Enumerador da matriz 'actorsConvesation[][E_ACTORS_CONVERSATION]'.</summary>
enum E_ACTORS_CONVERSATION
{
	E_ANIM_LIB[12],
	E_ANIM_NAME[15],
	E_ANIM_COMPLETION_TIME,
	E_CONVERSATION_TYPE
}
/*
 * VARIABLES
 ******************************************************************************
 */
static

	/// <summary> 
	///	Vari�vel para dos atores criados para o jogador.</summary>
	playerActorScenario[MAX_PLAYERS][E_ACTOR_SCENARIO],

	/// <summary> 
	///	Vari�veis de controle das TextDraws Globais/Privadas.</summary>
	Text:textCharSelectionGlobal[E_TEXT_CHAR_SELECTION_GLOBAL],
	Text:textCharCreationGlobal[E_TEXT_CHAR_CREATION_GLOBAL],
	PlayerText:textCharSelectionPrivate[MAX_PLAYERS][E_TEXT_CHAR_SELECTION_PRIVATE],
	PlayerText:textCharCreationPrivate[MAX_PLAYERS][E_TEXT_CHAR_CREATION_PRIVATE],

	/// <summary>
	/// Vari�vel para controle das TextDraws selecionadas, isso inclu� tanto slots quanto bot�es.</summary>
	textSelectedControl[MAX_PLAYERS][E_TEXT_SELECTED_CONTROL],

	/// <summary> 
	///	Vari�vel de controle de todos personagens do jogador.</summary>
	playerCharacters[MAX_PLAYERS][E_PLAYER_CHARACTERS],

	/// <summary> 
	///	Matriz com anima��es que ser�o aplicadas aos atores.</summary>
	actorsConvesation[][E_ACTORS_CONVERSATION] = {
		{"COP_AMBIENT", "Coplook_think", 3812, CONVERSATION_TYPE_RESPONSE},//338
		{"GANGS", "Invite_No", 3453, CONVERSATION_TYPE_RESPONSE},//602
		{"GANGS", "Invite_Yes", 4130, CONVERSATION_TYPE_RESPONSE},//603
		{"GANGS", "prtial_gngtlkA", 4501, CONVERSATION_TYPE_SPEECH},//607
		{"GANGS", "prtial_gngtlkB", 6570, CONVERSATION_TYPE_SPEECH},//608
		{"GANGS", "prtial_gngtlkC", 7306, CONVERSATION_TYPE_SPEECH},//609
		{"GANGS", "prtial_gngtlkD", 3417, CONVERSATION_TYPE_SPEECH},//610
		{"GANGS", "prtial_gngtlkE", 3140, CONVERSATION_TYPE_SPEECH},//611
		{"GANGS", "prtial_gngtlkF", 5182, CONVERSATION_TYPE_SPEECH},//612
		{"GANGS", "prtial_gngtlkG", 6771, CONVERSATION_TYPE_SPEECH},//613
		{"GANGS", "prtial_gngtlkH", 6000, CONVERSATION_TYPE_SPEECH},//614
		{"OTB", "wtchrace_lose", 4526, CONVERSATION_TYPE_RESPONSE},//966
		{"ped", "IDLE_chat", 6804, CONVERSATION_TYPE_SPEECH},//1195
		{"PLAYIDLES", "strleg", 4052, CONVERSATION_TYPE_RESPONSE}//1307
	};

/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined character_OnGameModeInit
		character_OnGameModeInit();
	#endif

	/// <summary>
	/// Nesta callback:
	///		- inicia o m�dulo;
	///		- cria todas TextDraws Globais utilizadas pelo menu Sele��o de Personagem.
	///		- cria objetos globais do cen�rio.
	/// </summary>

	ModuleInit("player/character.pwn");

	CreateGlobalTDCharSelection();

	CreateScenarioGlobal();

	return 1;
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit character_OnGameModeInit
#if defined character_OnGameModeInit
	forward character_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
	#if defined character_OnPlayerConnect
		character_OnPlayerConnect(playerid);
	#endif

	if(IsPlayerNPC(playerid))
		return 1;
	
	/// <summary>
	/// Nesta callback:
	///		- cria todas TextDraws Privadas utilizadas pelo menu Sele��o de Personagem.
	///		- cria objetos privados do cen�rio.
	///		- configura os valores dos personagens do player(valores iniciais para testes).
	/// </summary>

	CreatePrivateTDCharSelection(playerid);
	CreateScenarioPrivate(playerid);

	ConfigureMenuSelectionCharacter(playerid);
	ConfigureCharactersValues(playerid);

	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect character_OnPlayerConnect
#if defined character_OnPlayerConnect
	forward character_OnPlayerConnect(playerid);
#endif

/*public OnPlayerSpawn(playerid)
{
	/// <summary>
	/// Nesta callback:
	///		- carrega o cen�rio ao jogador.
	/// </summary>

	LoadSelectionCharacterScenario(playerid);

	ShowMenuSelectionCharacter(playerid);

	return 1;
}*/

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	#if defined character_OnPlayerClickTextDraw
		character_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#endif

	if(_:clickedid == INVALID_TEXT_DRAW)
		return 1;

	if(clickedid == textCharSelectionGlobal[E_BUTTON_EDIT])
	{
		if((textSelectedControl[playerid][E_BUTTON_EDIT] = !textSelectedControl[playerid][E_BUTTON_EDIT]))
		{
			TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH]);
			TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_TEXT]);
			TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_ICON]);

			for(new i; i < 5; i++) TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_DELETE][i]);
		}
		else
		{
			TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH]);
			TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_TEXT]);
			TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_ICON]);

			for(new i; i < 5; i++) TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_DELETE][i]);
		}

		return 1;
	}
	else if(clickedid == textCharSelectionGlobal[E_BUTTON_EXIT])
	{
		RemovePlayerCharacterMenu(playerid);

		return 1;
	}
	else
	{
		for(new i; i < MAX_CHARACTERS_SLOTS; i++)
		{
			if(clickedid == textCharSelectionGlobal[E_CHAR_SLOT][i])
			{
				if(playerCharacters[playerid][E_CHAR_STATE][i] == STATE_BLOCKED)
				{
					CancelSelectTextDraw(playerid);

					ShowPlayerDialog(playerid, DIALOG_SLOT_MESSAGE, DIALOG_STYLE_MSGBOX, "Slot bloqueado", "Este slot est� bloqueado. Para saber como adquir�-lo acesse:\n\tMinha conta > Planos premium", "Confirmar", "");
				}
			}
		}
	}

	return 1;
}
#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw character_OnPlayerClickTextDraw
#if defined character_OnPlayerClickTextDraw
	forward character_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

/*public OnPlayerHideCursor(playerid, hovercolor)
{

	return 1;
}*/

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#if defined character_OnDialogResponse
		character_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#endif

	if(dialogid == DIALOG_SLOT_MESSAGE)
	{
		SelectTextDraw(playerid, 0xDDDDDD40);
	}

	return 1;
}
#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse character_OnDialogResponse
#if defined character_OnDialogResponse
	forward character_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

/*
 * MY CALLBACKS
 ******************************************************************************
 */
/// <summary>
/// Timer para aplicar as anima��es aos atores de um jogador espec�fico. As
/// anima��es s�o rand�micas e simulam uma conversa entre dois atores, tal
/// essa sem fim.
/// Intervalo: Definido pela matriz 'actorsConversation'
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="actorIndex">Index do ator a ser aplicado a anima��o.</param>
/// <param name="conversationType">Tipo da posi��o do ator na conversa.</param>
/// <returns>N�o retorna valores.</returns>
public ActorConversation(playerid, actorIndex, conversationType)
{
	new index,
		randomAnimation,
		validAnimations[sizeof(actorsConvesation)];

	for(new i = 0; i < sizeof(actorsConvesation); i++)
	{
		if(actorsConvesation[i][E_CONVERSATION_TYPE] == conversationType)
		{
			validAnimations[index] = i;
			index++;
		}
	}
	randomAnimation = random(index);
	randomAnimation = validAnimations[randomAnimation];

	ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][actorIndex], actorsConvesation[randomAnimation][E_ANIM_LIB], actorsConvesation[randomAnimation][E_ANIM_NAME], 4.1, 0, 1, 1, 1, 1);

	playerActorScenario[playerid][E_ACTOR_CONVERSATION_TIMER][actorIndex] = SetTimerEx("ActorConversation", actorsConvesation[randomAnimation][E_ANIM_COMPLETION_TIME], false, "iii", playerid, actorIndex, conversationType);
}

/*public OnFadeScreenPlayerChanged(playerid, bool:fadeType)
{
	#if defined char_OnFadeScreenPlayerChanged
		char_OnFadeScreenPlayerChanged(playerid, fadeType);
	#endif

	if(!IsPlayerCharacterMenu(playerid)) return;

	SendClientMessage(playerid, -1, "OnFadeScreenPlayerChanged character");

	if(fadeType == FADE_OUT)
	{
		UnfreezePlayer(playerid);
	}
	else
	{
		SetPlayerPos(playerid, outMenuSelectionCharPosition[E_OUT_MENU_POS_X], outMenuSelectionCharPosition[E_OUT_MENU_POS_Y], outMenuSelectionCharPosition[E_OUT_MENU_POS_Z]);
		SetPlayerFacingAngle(playerid, outMenuSelectionCharPosition[E_OUT_MENU_ROT]);
		SetCameraBehindPlayer(playerid);

		fadeOut(playerid, 50);
	}
}
#if defined _ALS_OnFadeScreenPlayerChanged
	#undef OnFadeScreenPlayerChanged
#else
	#define _ALS_OnFadeScreenPlayerChanged
#endif
#define OnFadeScreenPlayerChanged char_OnFadeScreenPlayerChanged
#if defined char_OnFadeScreenPlayerChanged
	forward char_OnFadeScreenPlayerChanged(playerid, bool:fadeType);
#endif*/

/*
 * FUNCTIONS
 ******************************************************************************
 */
///	<summary>
/// Cria todas as Textdraws Globais do menu Sele��o de Personagem.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static CreateGlobalTDCharSelection()
{
	textCharSelectionGlobal[E_HEADER][0] = TextDrawCreate(-94.058837, 141.583404, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_HEADER][0], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_HEADER][0], 316.352752, 25.250009);
	TextDrawAlignment(textCharSelectionGlobal[E_HEADER][0], 1);
	TextDrawColor(textCharSelectionGlobal[E_HEADER][0], -1523963137);
	TextDrawSetShadow(textCharSelectionGlobal[E_HEADER][0], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_HEADER][0], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_HEADER][0], 255);
	TextDrawFont(textCharSelectionGlobal[E_HEADER][0], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_HEADER][0], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_HEADER][0], 0);

	textCharSelectionGlobal[E_HEADER][1] = TextDrawCreate(4.823533, 146.249984, "Selecionar Personagem");
	TextDrawLetterSize(textCharSelectionGlobal[E_HEADER][1], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_HEADER][1], 1);
	TextDrawColor(textCharSelectionGlobal[E_HEADER][1], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_HEADER][1], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_HEADER][1], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_HEADER][1], 255);
	TextDrawFont(textCharSelectionGlobal[E_HEADER][1], 2);
	TextDrawSetProportional(textCharSelectionGlobal[E_HEADER][1], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_HEADER][1], 0);

	textCharSelectionGlobal[E_CHAR_SLOT][0] = TextDrawCreate(12.764693, 179.500015, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_CHAR_SLOT][0], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_CHAR_SLOT][0], 209.529342, 40.999992);
	TextDrawAlignment(textCharSelectionGlobal[E_CHAR_SLOT][0], 1);
	TextDrawColor(textCharSelectionGlobal[E_CHAR_SLOT][0], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][0], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_CHAR_SLOT][0], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_CHAR_SLOT][0], 255);
	TextDrawFont(textCharSelectionGlobal[E_CHAR_SLOT][0], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_CHAR_SLOT][0], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][0], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_CHAR_SLOT][0], true);

	textCharSelectionGlobal[E_CHAR_SLOT][1] = TextDrawCreate(12.764693, 222.666702, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_CHAR_SLOT][1], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_CHAR_SLOT][1], 209.529342, 40.999992);
	TextDrawAlignment(textCharSelectionGlobal[E_CHAR_SLOT][1], 1);
	TextDrawColor(textCharSelectionGlobal[E_CHAR_SLOT][1], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][1], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_CHAR_SLOT][1], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_CHAR_SLOT][1], 255);
	TextDrawFont(textCharSelectionGlobal[E_CHAR_SLOT][1], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_CHAR_SLOT][1], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][1], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_CHAR_SLOT][1], true);

	textCharSelectionGlobal[E_CHAR_SLOT][2] = TextDrawCreate(12.764693, 265.833374, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_CHAR_SLOT][2], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_CHAR_SLOT][2], 209.529342, 40.999992);
	TextDrawAlignment(textCharSelectionGlobal[E_CHAR_SLOT][2], 1);
	TextDrawColor(textCharSelectionGlobal[E_CHAR_SLOT][2], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][2], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_CHAR_SLOT][2], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_CHAR_SLOT][2], 255);
	TextDrawFont(textCharSelectionGlobal[E_CHAR_SLOT][2], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_CHAR_SLOT][2], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][2], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_CHAR_SLOT][2], true);

	textCharSelectionGlobal[E_CHAR_SLOT][3] = TextDrawCreate(12.764693, 309.000061, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_CHAR_SLOT][3], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_CHAR_SLOT][3], 209.529342, 40.999992);
	TextDrawAlignment(textCharSelectionGlobal[E_CHAR_SLOT][3], 1);
	TextDrawColor(textCharSelectionGlobal[E_CHAR_SLOT][3], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][3], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_CHAR_SLOT][3], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_CHAR_SLOT][3], 255);
	TextDrawFont(textCharSelectionGlobal[E_CHAR_SLOT][3], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_CHAR_SLOT][3], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][3], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_CHAR_SLOT][3], true);

	textCharSelectionGlobal[E_CHAR_SLOT][4] = TextDrawCreate(12.764693, 352.166748, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_CHAR_SLOT][4], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_CHAR_SLOT][4], 209.529342, 40.999992);
	TextDrawAlignment(textCharSelectionGlobal[E_CHAR_SLOT][4], 1);
	TextDrawColor(textCharSelectionGlobal[E_CHAR_SLOT][4], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][4], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_CHAR_SLOT][4], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_CHAR_SLOT][4], 255);
	TextDrawFont(textCharSelectionGlobal[E_CHAR_SLOT][4], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_CHAR_SLOT][4], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_CHAR_SLOT][4], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_CHAR_SLOT][4], true);

	textCharSelectionGlobal[E_BUTTON_EDIT] = TextDrawCreate(12.764693, 395.333435, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_EDIT], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_EDIT], 209.529342, 15.916650);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_EDIT], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_EDIT], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EDIT], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_EDIT], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_EDIT], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_EDIT], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_EDIT], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EDIT], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_EDIT], true);

	textCharSelectionGlobal[E_BUTTON_EDIT_TEXT] = TextDrawCreate(118.235298, 397.083374, "editar");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 0.186351, 1.179998);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 2);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 2);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EDIT_TEXT], 0);

	textCharSelectionGlobal[E_BUTTON_EXIT] = TextDrawCreate(12.764693, 413.416564, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_EXIT], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_EXIT], 209.529342, 15.916650);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_EXIT], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_EXIT], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EXIT], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_EXIT], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_EXIT], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_EXIT], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_EXIT], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EXIT], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_EXIT], true);

	textCharSelectionGlobal[E_BUTTON_EXIT_TEXT] = TextDrawCreate(118.235298, 414.583221, "sair");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 0.186351, 1.179998);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 2);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 2);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_EXIT_TEXT], 0);

	textCharSelectionGlobal[E_BUTTON_TRASH] = TextDrawCreate(228.294281, 395.333221, "LD_SPAC:white");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_TRASH], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_TRASH], 37.293998, 15.916650);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_TRASH], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_TRASH], 70);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_TRASH], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_TRASH], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_TRASH], 4);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_TRASH], 0);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_TRASH], true);

	textCharSelectionGlobal[E_BUTTON_TRASH_TEXT] = TextDrawCreate(249.529022, 397.083129, "lixeira");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 0.186351, 1.179998);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 2);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 2);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH_TEXT], 0);

	textCharSelectionGlobal[E_BUTTON_TRASH_ICON] = TextDrawCreate(219.353042, 393.000183, "");
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 0.000000, 0.000000);
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 17.999980, 19.416666);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 0);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 5);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 0);
	TextDrawSetPreviewModel(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 1328);
	TextDrawSetPreviewRot(textCharSelectionGlobal[E_BUTTON_TRASH_ICON], 337.000000, 0.000000, 0.000000, 1.000000);

	textCharSelectionGlobal[E_BUTTON_DELETE][0] = TextDrawCreate(223.599533, 189.416641, "x");
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_DELETE][0], 233.000000, 15.000000);
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_DELETE][0], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_DELETE][0], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_DELETE][0], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][0], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_DELETE][0], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_DELETE][0], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_DELETE][0], 1);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_DELETE][0], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][0], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_DELETE][0], true);

	textCharSelectionGlobal[E_BUTTON_DELETE][1] = TextDrawCreate(223.599533, 232.583328, "x");
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_DELETE][1], 233.000000, 15.000000);
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_DELETE][1], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_DELETE][1], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_DELETE][1], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][1], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_DELETE][1], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_DELETE][1], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_DELETE][1], 1);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_DELETE][1], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][1], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_DELETE][1], true);

	textCharSelectionGlobal[E_BUTTON_DELETE][2] = TextDrawCreate(223.599533, 275.750183, "x");
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_DELETE][2], 233.000000, 15.000000);
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_DELETE][2], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_DELETE][2], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_DELETE][2], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][2], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_DELETE][2], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_DELETE][2], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_DELETE][2], 1);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_DELETE][2], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][2], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_DELETE][2], true);

	textCharSelectionGlobal[E_BUTTON_DELETE][3] = TextDrawCreate(223.599533, 318.916870, "x");
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_DELETE][3], 233.000000, 15.000000);
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_DELETE][3], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_DELETE][3], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_DELETE][3], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][3], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_DELETE][3], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_DELETE][3], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_DELETE][3], 1);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_DELETE][3], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][3], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_DELETE][3], true);

	textCharSelectionGlobal[E_BUTTON_DELETE][4] = TextDrawCreate(223.599533, 362.083557, "x");
	TextDrawTextSize(textCharSelectionGlobal[E_BUTTON_DELETE][4], 233.000000, 15.000000);
	TextDrawLetterSize(textCharSelectionGlobal[E_BUTTON_DELETE][4], 0.400000, 1.600000);
	TextDrawAlignment(textCharSelectionGlobal[E_BUTTON_DELETE][4], 1);
	TextDrawColor(textCharSelectionGlobal[E_BUTTON_DELETE][4], -1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][4], 0);
	TextDrawSetOutline(textCharSelectionGlobal[E_BUTTON_DELETE][4], 0);
	TextDrawBackgroundColor(textCharSelectionGlobal[E_BUTTON_DELETE][4], 255);
	TextDrawFont(textCharSelectionGlobal[E_BUTTON_DELETE][4], 1);
	TextDrawSetProportional(textCharSelectionGlobal[E_BUTTON_DELETE][4], 1);
	TextDrawSetShadow(textCharSelectionGlobal[E_BUTTON_DELETE][4], 0);
	TextDrawSetSelectable(textCharSelectionGlobal[E_BUTTON_DELETE][4], true);

	/*
	 *****************************************************************************/

	textCharCreationGlobal[E_HEADER] = TextDrawCreate(217.532165, 146.250015, "criar_personagem");
	TextDrawLetterSize(textCharCreationGlobal[E_HEADER], 0.400000, 1.600000);
	TextDrawAlignment(textCharCreationGlobal[E_HEADER], 3);
	TextDrawColor(textCharCreationGlobal[E_HEADER], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_HEADER], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_HEADER], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_HEADER], 255);
	TextDrawFont(textCharCreationGlobal[E_HEADER], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_HEADER], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_HEADER], 0);

	textCharCreationGlobal[E_BUTTON_BACK] = TextDrawCreate(3.886538, 142.750000, "<");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_BACK], 0.328783, 2.440001);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_BACK], 17.000000, 20.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_BACK], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_BACK], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_BACK], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_BACK], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_BACK], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_BACK], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_BACK], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_BACK], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_BACK], true);

	textCharCreationGlobal[E_BACKGROUND][0] = TextDrawCreate(12.764693, 179.500015, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][0], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BACKGROUND][0], 209.399993, 249.399993);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][0], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][0], 70);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][0], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][0], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][0], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][0], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][0], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][0], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BACKGROUND][0], true);

	textCharCreationGlobal[E_BACKGROUND][1] = TextDrawCreate(18.000000, 183.000000, "Nome");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][1], 0.242576, 1.086665);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][1], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][1], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][1], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][1], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][1], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][1], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][1], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][1], 0);

	textCharCreationGlobal[E_BUTTON_NAME] = TextDrawCreate(18.000000, 194.000000, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_NAME], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_NAME], 199.000000, 16.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_NAME], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_NAME], 50);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_NAME], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_NAME], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_NAME], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_NAME], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_NAME], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_NAME], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_NAME], true);

	textCharCreationGlobal[E_BACKGROUND][2] = TextDrawCreate(18.000000, 214.999908, "Genero");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][2], 0.242576, 1.086665);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][2], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][2], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][2], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][2], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][2], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][2], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][2], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][2], 0);

	textCharCreationGlobal[E_BACKGROUND_GENDER][0] = TextDrawCreate(18.000000, 226.000000, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 199.000000, 16.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 50);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND_GENDER][0], 0);

	textCharCreationGlobal[E_BACKGROUND_GENDER][1] = TextDrawCreate(118.000000, 229.683868, "]");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 0.242576, 1.086665);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 2);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND_GENDER][1], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND_GENDER][1], 0);

	textCharCreationGlobal[E_BUTTON_SKIN] = TextDrawCreate(18.000000, 258.083160, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_SKIN], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_SKIN], 199.000000, 16.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_SKIN], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_SKIN], 50);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_SKIN], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_SKIN], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_SKIN], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_SKIN], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_SKIN], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_SKIN], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_SKIN], true);

	textCharCreationGlobal[E_BACKGROUND][4] = TextDrawCreate(18.000000, 279.083557, "Cabelo");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][4], 0.242576, 1.086665);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][4], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][4], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][4], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][4], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][4], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][4], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][4], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][4], 0);

	textCharCreationGlobal[E_BUTTON_HAIR] = TextDrawCreate(18.000000, 290.083801, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_HAIR], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_HAIR], 199.000000, 16.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_HAIR], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_HAIR], 50);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_HAIR], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_HAIR], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_HAIR], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_HAIR], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_HAIR], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_HAIR], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_HAIR], true);

	textCharCreationGlobal[E_BACKGROUND][5] = TextDrawCreate(18.000000, 311.383819, "Olho");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][5], 0.242576, 1.086665);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][5], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][5], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][5], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][5], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][5], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][5], 2);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][5], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][5], 0);

	textCharCreationGlobal[E_BUTTON_EYE] = TextDrawCreate(18.000000, 322.083801, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_EYE], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_EYE], 199.000000, 16.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_EYE], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_EYE], 50);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_EYE], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_EYE], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_EYE], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_EYE], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_EYE], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_EYE], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_EYE], true);

	textCharCreationGlobal[E_BACKGROUND][6] = TextDrawCreate(18.205001, 342.083740, "~r~NOTA~w~: Tenha certeza das caracteristicas que quer~n~para seu personagem, nao sera possivel alterar~n~futuramente, somente_");
	TextDrawLetterSize(textCharCreationGlobal[E_BACKGROUND][6], 0.242576, 1.127498);
	TextDrawAlignment(textCharCreationGlobal[E_BACKGROUND][6], 1);
	TextDrawColor(textCharCreationGlobal[E_BACKGROUND][6], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][6], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BACKGROUND][6], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BACKGROUND][6], 255);
	TextDrawFont(textCharCreationGlobal[E_BACKGROUND][6], 1);
	TextDrawSetProportional(textCharCreationGlobal[E_BACKGROUND][6], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_BACKGROUND][6], 0);

	textCharCreationGlobal[E_BUTTON_CREATE] = TextDrawCreate(18.000000, 395.000000, "LD_SPAC:white");
	TextDrawLetterSize(textCharCreationGlobal[E_BUTTON_CREATE], 0.000000, 0.000000);
	TextDrawTextSize(textCharCreationGlobal[E_BUTTON_CREATE], 199.000000, 28.000000);
	TextDrawAlignment(textCharCreationGlobal[E_BUTTON_CREATE], 1);
	TextDrawColor(textCharCreationGlobal[E_BUTTON_CREATE], 100);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_CREATE], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_BUTTON_CREATE], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_BUTTON_CREATE], 255);
	TextDrawFont(textCharCreationGlobal[E_BUTTON_CREATE], 4);
	TextDrawSetProportional(textCharCreationGlobal[E_BUTTON_CREATE], 0);
	TextDrawSetShadow(textCharCreationGlobal[E_BUTTON_CREATE], 0);
	TextDrawSetSelectable(textCharCreationGlobal[E_BUTTON_CREATE], true);

	textCharCreationGlobal[E_TEXT_CREATE] = TextDrawCreate(118.000000, 399.000000, "CRIAR");
	TextDrawLetterSize(textCharCreationGlobal[E_TEXT_CREATE], 0.562574, 2.049165);
	TextDrawAlignment(textCharCreationGlobal[E_TEXT_CREATE], 2);
	TextDrawColor(textCharCreationGlobal[E_TEXT_CREATE], -1);
	TextDrawSetShadow(textCharCreationGlobal[E_TEXT_CREATE], 0);
	TextDrawSetOutline(textCharCreationGlobal[E_TEXT_CREATE], 0);
	TextDrawBackgroundColor(textCharCreationGlobal[E_TEXT_CREATE], 255);
	TextDrawFont(textCharCreationGlobal[E_TEXT_CREATE], 3);
	TextDrawSetProportional(textCharCreationGlobal[E_TEXT_CREATE], 1);
	TextDrawSetShadow(textCharCreationGlobal[E_TEXT_CREATE], 0);
}

///	<summary>
/// Cria todas as Textdraws Privadas do menu Sele��o de Personagem.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static CreatePrivateTDCharSelection(playerid)
{
	textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0] = CreatePlayerTextDraw(playerid, 6.647084, 177.166687, "");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 46.705848, 44.499980);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 5);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0);
	PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 171);
	PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][0], 0.000000, 0.000000, 0.000000, 1.045655);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0] = CreatePlayerTextDraw(playerid, 45.764713, 183.583312, "Bruno Travi Teixeira");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 0.407999, 1.792497);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 1);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][0], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0] = CreatePlayerTextDraw(playerid, 45.764713, 198.166580, "Acessado por ultimo as 16:20 de_00/00/00");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 0.186351, 1.179998);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], -5963521);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 2);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][0], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1] = CreatePlayerTextDraw(playerid, 6.647084, 220.333374, "");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 46.705848, 44.499980);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 5);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0);
	PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 171);
	PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][1], 0.000000, 0.000000, 0.000000, 1.045655);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1] = CreatePlayerTextDraw(playerid, 45.764713, 226.750000, "Bruno Travi Teixeira");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 0.407999, 1.792497);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 1);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][1], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1] = CreatePlayerTextDraw(playerid, 45.764713, 241.333267, "Acessado por ultimo as 16:20 de_00/00/00");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 0.186351, 1.179998);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], -5963521);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 2);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][1], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2] = CreatePlayerTextDraw(playerid, 6.647084, 263.500061, "");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 46.705848, 44.499980);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 5);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0);
	PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 171);
	PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][2], 0.000000, 0.000000, 0.000000, 1.045655);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2] = CreatePlayerTextDraw(playerid, 45.764713, 269.916687, "Bruno Travi Teixeira");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 0.407999, 1.792497);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 1);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][2], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2] = CreatePlayerTextDraw(playerid, 45.764713, 284.499969, "Acessado por ultimo as 16:20 de_00/00/00");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 0.186351, 1.179998);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], -5963521);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 2);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][2], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3] = CreatePlayerTextDraw(playerid, 6.647084, 306.666748, "");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 46.705848, 44.499980);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 5);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0);
	PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 171);
	PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][3], 0.000000, 0.000000, 0.000000, 1.045655);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3] = CreatePlayerTextDraw(playerid, 45.764713, 313.083374, "Bruno Travi Teixeira");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 0.407999, 1.792497);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 1);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][3], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3] = CreatePlayerTextDraw(playerid, 45.764713, 327.666656, "Acessado por ultimo as 16:20 de_00/00/00");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 0.186351, 1.179998);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], -5963521);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 2);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][3], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4] = CreatePlayerTextDraw(playerid, 6.647084, 349.833435, "");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 46.705848, 44.499980);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 5);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0);
	PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 171);
	PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][4], 0.000000, 0.000000, 0.000000, 1.045655);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4] = CreatePlayerTextDraw(playerid, 45.764713, 356.250061, "Bruno Travi Teixeira");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 0.407999, 1.792497);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], -1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 1);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][4], 0);

	textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4] = CreatePlayerTextDraw(playerid, 45.764713, 370.833343, "Acessado por ultimo as 16:20 de_00/00/00");
	PlayerTextDrawLetterSize(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 0.186351, 1.179998);
	PlayerTextDrawAlignment(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 1);
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], -5963521);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 0);
	PlayerTextDrawSetOutline(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 255);
	PlayerTextDrawFont(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 2);
	PlayerTextDrawSetProportional(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 1);
	PlayerTextDrawSetShadow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][4], 0);

	/*
	 *************************************************************************/

	textCharCreationPrivate[playerid][E_CHAR_NAME] = CreatePlayerTextDraw(playerid, 118.000000, 196.000000, "Bruno Travi");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 0.242576, 1.086665);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 2);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME], 0);

	textCharCreationPrivate[playerid][E_CHAR_SKIN] = CreatePlayerTextDraw(playerid, 118.000000, 260.600036, "555");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 0.242576, 1.086665);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 2);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN], 0);

	textCharCreationPrivate[playerid][E_CHAR_HAIR] = CreatePlayerTextDraw(playerid, 118.000000, 292.683898, "Padrao");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 0.242576, 1.086665);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 2);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR], 0);

	textCharCreationPrivate[playerid][E_CHAR_EYE] = CreatePlayerTextDraw(playerid, 118.000000, 324.583831, "Azul");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 0.242576, 1.086665);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 2);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE], 0);

	textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE] = CreatePlayerTextDraw(playerid, 51.938522, 229.166564, "Masculino");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 0.242576, 1.086665);
	PlayerTextDrawTextSize(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 109.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 1);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], 0);
	PlayerTextDrawSetSelectable(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE], true);

	textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE] = CreatePlayerTextDraw(playerid, 129.713027, 229.166564, "Feminino");
	PlayerTextDrawLetterSize(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 0.242576, 1.086665);
	PlayerTextDrawTextSize(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 177.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 1);
	PlayerTextDrawColor(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], -1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 0);
	PlayerTextDrawSetOutline(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 0);
	PlayerTextDrawBackgroundColor(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 255);
	PlayerTextDrawFont(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 2);
	PlayerTextDrawSetProportional(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 1);
	PlayerTextDrawSetShadow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], 0);
	PlayerTextDrawSetSelectable(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE], true);
}

/// <summary>
/// Cria os objetos globais do cen�rio de apresenta��o do personagem.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static CreateScenarioGlobal()
{
	CreateDynamicObject(14390, 1254.05969, -775.77258, 1086.24707, 0.00000, 0.00000, -90.00000, .interiorid = 5);
	CreateDynamicObject(14390, 1252.07983, -771.75250, 1086.24707, 0.00000, 0.00000, -90.00000, .interiorid = 5);
	CreateDynamicObject(19377, 1273.71692, -792.10327, 1082.92444, 0.00000, 90.00000, 0.00000, .interiorid = 5);
	CreateDynamicObject(14399, 1271.29700, -788.77606, 1083.00781, 0.00000, 0.00000, -180.00000, .interiorid = 5);
}

/// <summary>
/// Cria os objetos privados do cen�rio de apresenta��o do personagem.
/// </summary>
/// <param name="playerid">ID do jogador ao qual deve ser aplicado as fun��es privadas.</param>
/// <returns>N�o retorna valores.</returns>
static CreateScenarioPrivate(playerid)
{
	RemoveBuildingForPlayer(playerid, 2292, 1268.7813, -796.3672, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1268.7891, -795.8828, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2104, 1273.2891, -795.0000, 1083.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 2229, 1272.2266, -794.5313, 1083.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1268.7891, -794.9063, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2296, 1277.2813, -794.6875, 1083.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1788, 1278.1172, -794.8281, 1083.2031, 0.25);
	RemoveBuildingForPlayer(playerid, 1788, 1278.1172, -794.8281, 1083.3672, 0.25);
	RemoveBuildingForPlayer(playerid, 2229, 1279.8359, -794.9453, 1083.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1268.7891, -793.9219, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2028, 1276.2266, -793.5313, 1083.2500, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1268.7891, -792.9453, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1275.2266, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1274.2500, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2292, 1273.7656, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1278.1719, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1277.1875, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1276.2109, -791.4766, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2292, 1279.6484, -791.4688, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2292, 1268.7813, -791.4609, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1269.2656, -791.4609, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2291, 1270.2500, -791.4609, 1083.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 2292, 1271.7266, -791.4609, 1083.0000, 0.25);
}

/// <summary>
/// Carrega e seta um jogador espec�fico no cen�rio de sele��o de personagens.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
LoadSelectionCharacterScenario(playerid)
{
	SetPlayerInterior(playerid, 5);
	SetPlayerPos(playerid, 1276.4379, -794.2152, 1084.1719);
	SetPlayerFacingAngle(playerid, 274.0/*272.9013*/);
	SetPlayerSkin(playerid, 171);

	TogglePlayerControllable(playerid, false);

	SetPlayerCameraPos(playerid, 1278.5630, -794.0517, 1084.3660);
	SetPlayerCameraLookAt(playerid, 1277.5581, -794.0945, 1084.2833);

	/*SetPlayerCameraPos(playerid, 1277.9937, -794.2797, 1084.8776);
	SetPlayerCameraLookAt(playerid, 1276.9946, -794.2579, 1084.6156);*/

	//olhos e cabelo
	/*SetPlayerCameraPos(playerid, 1277.3708, -794.2350, 1084.9235);
	SetPlayerCameraLookAt(playerid, 1276.3722, -794.0945, 1084.8417);*/

	CreateScenarioActors(playerid);
}

/// <summary>
/// Remove um jogador espec�fico do cen�rio de sele��o de personagens.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
OutSelectionCharacterScenario(playerid)
{
	KillTimer(playerActorScenario[playerid][E_ACTOR_CONVERSATION_TIMER][0]);
	KillTimer(playerActorScenario[playerid][E_ACTOR_CONVERSATION_TIMER][1]);

	DestroyActor(playerActorScenario[playerid][E_ACTOR_ID][0]);
	DestroyActor(playerActorScenario[playerid][E_ACTOR_ID][1]);
}
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Cria os atores do cen�rio de apresenta��o do personagem ao jogador.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static CreateScenarioActors(playerid)
{
	new virtualworld = GetPlayerVirtualWorld(playerid);

	playerActorScenario[playerid][E_ACTOR_ID][0] = CreateActor(171, 1273.0809, -793.1731, 1084.1718, 0.6119);
	playerActorScenario[playerid][E_ACTOR_ID][1] = CreateActor(171, 1273.0214, -792.4755, 1084.1611, 185.7939);

	SetActorVirtualWorld(playerActorScenario[playerid][E_ACTOR_ID][0], virtualworld);
	SetActorVirtualWorld(playerActorScenario[playerid][E_ACTOR_ID][1], virtualworld);

	LoadActorAnimations(playerid);
	LoadActorsConversation(playerid);
}

/// <summary>
/// Carrega todas livrarias de anima��es usadas pelos atores de um jogador
/// espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
static LoadActorAnimations(playerid)
{
	for(new i; i < 2; i++)
	{
		ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][i], "COP_AMBIENT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][i], "GANGS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][i], "OTB", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][i], "ped", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyActorAnimation(playerActorScenario[playerid][E_ACTOR_ID][i], "PLAYIDLES", "null", 0.0, 0, 0, 0, 0, 0);
	}
}

/// <summary>
/// Carrega e da in�cio a conversa��o entre os 2 atores de um jogador
/// espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
static LoadActorsConversation(playerid)
{
	new idSpeech = random(2);//id 0 ou 1

	ActorConversation(playerid, idSpeech, CONVERSATION_TYPE_SPEECH);
	ActorConversation(playerid, !idSpeech, CONVERSATION_TYPE_RESPONSE);
}
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Configura valores espec�ficos(definidos para testes) dos Personagens.
/// *Fun��o tempor�ria. 
/// </summary>
/// <param name="playerid">ID do jogador a se setar esses valores.</param>
/// <returns>N�o retorna valores.</returns>
static ConfigureCharactersValues(playerid)
{
	playerCharacters[playerid][E_ACCOUNT_TYPE] = ACCOUNT_TYPE_NORMAL;

	new i;

	for(i = 0; i < playerCharacters[playerid][E_ACCOUNT_TYPE]; i++)
		ConfigureCharacterSlot(playerid, CONFIG_RESET_SLOT, i),
		UpdateTDCharacterSlot(playerid, i);

	for(i = playerCharacters[playerid][E_ACCOUNT_TYPE]; i < ACCOUNT_TYPE_PREMIUM; i++)
		ConfigureCharacterSlot(playerid, CONFIG_BLOCK_SLOT, i),
		UpdateTDCharacterSlot(playerid, i);
}

/// <summary>
/// Configura um Personagem espec�fico de um jogador espec�fico atrav�s do seu
/// slot.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="configureType">Tipo da configura��o a ser aplicada no slot do personagem. (CONFIG_REST_SLOT|CONFIG_SET_CHAR_SLOT|CONFIG_BLOCK_SLOT)</param>
/// <param name="slotID">ID do slot do Personagem.</param>
/// <param name="auxValue">Vari�vel auxiliar para armazenar o id da skin do personagem passada quando configureType for CONFIG_SET_CHAR_SLOT.</param>
/// <param name="auxString">Vari�vel auxiliar para armazenar o nome do personagem passado quando configureType for CONFIG_SET_CHAR_SLOT.</param>
/// <returns>N�o retorna valores.</returns>
static ConfigureCharacterSlot(playerid, configureType, slotID, auxValue = -1, auxString[MAX_PLAYER_NAME] = "")
{
	switch(configureType)
	{
		case CONFIG_RESET_SLOT:
		{
			playerCharacters[playerid][E_CHAR_STATE][slotID] = STATE_EMPTY;
			playerCharacters[playerid][E_CHAR_SKIN][slotID] = 19134;//create char icon
			playerCharacters[playerid][E_CHAR_NAME][slotID] = EOS;

			for(new i; i < 5; i++) playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][i] = 0;

		}
		case CONFIG_SET_CHAR_SLOT:
		{
			playerCharacters[playerid][E_CHAR_STATE][slotID] = STATE_CREATED;
			playerCharacters[playerid][E_CHAR_SKIN][slotID] = auxValue;

			format(playerCharacters[playerid][E_CHAR_NAME][slotID], sizeof(auxString), auxString);

			for(new i; i < 5; i++) playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][i] = 0;
		}
		case CONFIG_BLOCK_SLOT:
		{
			playerCharacters[playerid][E_CHAR_STATE][slotID] = STATE_BLOCKED;
			playerCharacters[playerid][E_CHAR_SKIN][slotID] = 19804;//block slot icon
			playerCharacters[playerid][E_CHAR_NAME][slotID] = EOS;

			for(new i; i < 5; i++) playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][i] = 0;
		}
	}
}

/// <summary>
/// Mostra o menu de Sele��o de Personagem a um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
ShowMenuSelectionCharacter(playerid)
{
	new i;

	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_HEADER][0]);
	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_HEADER][1]);

	for(i = 0; i < 5; i++)
		TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_CHAR_SLOT][i]);

	for(i = 0; i < 5; i++)
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][i]),
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][i]),
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][i]);

	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EDIT]);
	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EDIT_TEXT]);

	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EXIT]);
	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EXIT_TEXT]);

	SelectTextDraw(playerid, 0xDDDDDD40);//0xDDDDDDAA
}

/// <summary>
/// Esconde o menu de Sele��o de Personagem a um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="hideCursor">True para esconder o cursor, False para n�o.</param>
/// <returns>N�o retorna valores.</returns>
HideMenuSelectionCharacter(playerid, bool:hideCursor = true)
{
	new i;

	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_HEADER][0]);
	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_HEADER][1]);

	for(i = 0; i < 5; i++)
		TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_CHAR_SLOT][i]);

	for(i = 0; i < 5; i++)
		PlayerTextDrawHide(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][i]),
		PlayerTextDrawHide(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][i]),
		PlayerTextDrawHide(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][i]);

	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EDIT]);
	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EDIT_TEXT]);

	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EXIT]);
	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_EXIT_TEXT]);

	if(textSelectedControl[playerid][E_BUTTON_EDIT])
	{
		TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH]);
		TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_TEXT]);
		TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_TRASH_ICON]);

		for(i = 0; i < 5; i++)
			TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_BUTTON_DELETE][i]);
	}

	if(hideCursor)
		CancelSelectTextDraw(playerid);
}

/// <summary>
/// Mostra o menu de Cria��o de Personagem a um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="showCursor">True para mostrar o cursor, False para n�o.</param>
/// <returns>N�o retorna valores.</returns>
ShowMenuCreationCharacter(playerid, bool:showCursor)
{
/*
	/// <summary> 
	///	Enumerador da vari�vel 'textCharCreationGlobal[E_TEXT_CHAR_CREATION_GLOBAL]'.</summary>
	enum E_TEXT_CHAR_CREATION_GLOBAL
	{
		Text:E_HEADER,
		Text:E_BUTTON_BACK,
		Text:E_BACKGROUND[7],
		Text:E_BACKGROUND_GENDER[2],
		Text:E_BUTTON_NAME,
		Text:E_BUTTON_GENDER_MALE,
		Text:E_BUTTON_GENDER_FEMALE,
		Text:E_BUTTON_SKIN,
		Text:E_BUTTON_HAIR,
		Text:E_BUTTON_EYE,
		Text:E_BUTTON_CREATE,
		Text:E_TEXT_CREATE
	}
*/
/*
	/// <summary> 
	///	Enumerador da vari�vel 'textCharCreationPrivate[MAX_PLAYERS][E_TEXT_CHAR_CREATION_PRIVATE]'.</summary>
	enum E_TEXT_CHAR_CREATION_PRIVATE
	{
		PlayerText:E_CHAR_NAME,
		PlayerText:E_CHAR_SKIN,
		PlayerText:E_CHAR_HAIR,
		PlayerText:E_CHAR_EYE
	}
*/

	new i;

	TextDrawShowForPlayer(playerid, textCharSelectionGlobal[E_HEADER][0]);
	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_HEADER]);
	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_BACK]);

	for(i = 0; i < 7; i++)
		TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND][i]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_NAME]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND_GENDER][0]);
	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND_GENDER][1]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_SKIN]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_HAIR]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_EYE]);
	PlayerTextDrawShow(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE]);

	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_BUTTON_CREATE]);
	TextDrawShowForPlayer(playerid, textCharCreationGlobal[E_TEXT_CREATE]);

	if(showCursor)
		SelectTextDraw(playerid, 0xDDDDDD40);
}

/// <summary>
/// Esconde o menu de Cria��o de Personagem a um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="hideCursor">True para esconder o cursor, False para n�o.</param>
/// <returns>N�o retorna valores.</returns>
HideMenuCreationCharacter(playerid, bool:hideCursor)
{
	new i;

	TextDrawHideForPlayer(playerid, textCharSelectionGlobal[E_HEADER][0]);
	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_HEADER]);
	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_BACK]);

	for(i = 0; i < 7; i++)
		TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND][i]);

	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_NAME]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_CHAR_NAME]);

	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND_GENDER][0]);
	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BACKGROUND_GENDER][1]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_MALE]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_BUTTON_GENDER_FEMALE]);

	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_SKIN]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_CHAR_SKIN]);

	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_HAIR]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_CHAR_HAIR]);

	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_EYE]);
	PlayerTextDrawHide(playerid, textCharCreationPrivate[playerid][E_CHAR_EYE]);
	
	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_BUTTON_CREATE]);
	TextDrawHideForPlayer(playerid, textCharCreationGlobal[E_TEXT_CREATE]);

	if(hideCursor)
		CancelSelectTextDraw(playerid);
}

/// <summary>
/// Reseta configura��es do menu de Sele��o de Personagem de um jogador
/// espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
static ConfigureMenuSelectionCharacter(playerid)
{
	textSelectedControl[playerid][E_CHAR_SLOT] = INVALID_CHAR_SLOT;
	
	textSelectedControl[playerid][E_BUTTON_EDIT] = false;
}

/// <summary>
/// Atualiza as informa��es da TextDraw de um Personagem espec�fico
/// (atrav�s do slotID) de um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="slotID">ID do slot do Personagem.</param>
/// <param name="showChanges">True para mostrar modifica��es, False para n�o.</param>
/// <returns>N�o retorna valores.</returns>
static UpdateTDCharacterSlot(playerid, slotID, bool:showChanges = false)
{
	PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], -5963521);
	switch(playerCharacters[playerid][E_CHAR_STATE][slotID])
	{
		case STATE_EMPTY:
		{
			PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], playerCharacters[playerid][E_CHAR_SKIN][slotID]);
			PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], 0.000000, 0.000000, 90.000000, 1.045655);
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], -1);

			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], "Novo personagem");
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], -1);

			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], "Criar novo personagem");
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], -1378294017);
		}
		case STATE_CREATED:
		{
			new string[43];

			PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], playerCharacters[playerid][E_CHAR_SKIN][slotID]);
			PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], 0.000000, 0.000000, 0.000000, 1.045655);
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], -1);
			
			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], playerCharacters[playerid][E_CHAR_NAME][slotID]);
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], -1);
			
			format(string, sizeof(string), "Acessado por ultimo as %02d:%02d de %02d/%02d/%d", playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][0],playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][1], playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][2],playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][3],playerCharacters[playerid][E_CHAR_LAST_ACESS][slotID][4]);
			
			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], string);
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], -1378294017);
		}
		case STATE_BLOCKED:
		{
			PlayerTextDrawSetPreviewModel(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], playerCharacters[playerid][E_CHAR_SKIN][slotID]);
			PlayerTextDrawSetPreviewRot(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], 0.000000, 0.000000, 0.000000, 1.045655);
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID], 255);

			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], "BLOQUEADO");
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID], 255);
			
			PlayerTextDrawSetString(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], ConvertToGameText("Este slot n�o est� dispon�vel."));
			PlayerTextDrawColor(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID], 255);
		}
	}

	if(showChanges)
	{
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_SKIN][slotID]);
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_NAME][slotID]);
		PlayerTextDrawShow(playerid, textCharSelectionPrivate[playerid][E_CHAR_SLOT_LAST_ACESS][slotID]);
	}
}

/*
 * COMMANDS
 ******************************************************************************
 */
/// <summary>
/// Comando tempor�rio para carregar e setar o jogador ao cen�rio.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores espec�ficos.</returns>
CMD:char(playerid)
{
	LoadSelectionCharacterScenario(playerid);
	return 1;
}

/// <summary>
/// Comando tempor�rio para sair da c�mera setada ao jogador que carregar o
/// cen�rio.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores espec�ficos.</returns>
CMD:actor(playerid)
{
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	return 1;
}

/// <summary>
/// Comando tempor�rio para criar um ator. Imprime c�digo da aplica��o da
/// fun��o no console.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores espec�ficos.</returns>
CMD:c_actor(playerid)
{
	new Float:pos[4];

	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(playerid, pos[3]);

	new id = CreateActor(GetPlayerSkin(playerid), pos[0], pos[1], pos[2], pos[3]);

	printf("CreateActor(%d, %.4f, %.4f, %.4f, %.4f);", GetPlayerSkin(playerid), pos[0], pos[1], pos[2], pos[3]);

	SendClientMessageFormat(playerid, -1, "Ator criado. ID = %d", id);

	return 1;
}

/// <summary>
/// Comando tempor�rio para deletar um ator espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="params">Par�metros a serem utilizados: <id do ator>.</param>
/// <returns>N�o retorna valores espec�ficos.</returns>
CMD:d_actor(playerid, params[])
{
	if(isnull(params)) return 1;

	DestroyActor(strval(params));

	SendClientMessageFormat(playerid, -1, "Ator %d destru�do.", strval(params));

	return 1;
}
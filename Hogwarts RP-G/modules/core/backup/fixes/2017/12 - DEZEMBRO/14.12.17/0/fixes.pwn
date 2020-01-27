/*
	Arquivo:
		modules/core/fixes.pwn

	Descri��o:
		- Este m�dulo � respons�vel pela corre��o de diferentes bugs do SA-MP.

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
	 * DEFINITIONS
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
	 * FIXES
	 *
	|
	 *
	 * HOOKS
	 *
	|
*/
/*
 * DEFINITIONS
 ******************************************************************************
 */
forward KickPlayer(playerid);

/*
 * VARIABLES
 ******************************************************************************
 */
/*static
	/// <summary> 
	///	Vari�vel de controle da TextDraw utilizada para fixar bug das transpar�ncias.</summary>
	Text:textBugFix;*/

/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined fixes_OnGameModeInit
		fixes_OnGameModeInit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- inicializa o m�dulo.
	/// </summary>

	ModuleInit("core/fixes.pwn");

	return 1;
}

/*
public OnPlayerConnect(playerid)
{
	#if defined fixes_OnPlayerConnect
		fixes_OnPlayerConnect(playerid);
	#endif
	/// <summary>
	/// Nesta callback:
	///		- mostra a TextDraw respons�vel por fixar o bug das transpar�ncias
	///		  ao jogador.
	/// </summary>

	if(IsPlayerNPC(playerid))
		return 1;

	FixShowTextDrawTransparency(playerid);

	return 1;
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect fixes_OnPlayerConnect
#if defined fixes_OnPlayerConnect
	forward fixes_OnPlayerConnect(playerid);
#endif*/

/*
 * MY CALLBACKS
 ******************************************************************************
 */
public KickPlayer(playerid)
	return Kick(playerid);

/*
 * FIXES
 ******************************************************************************
 */
/*
	TextDraw Transparency bug fix:
		A transpar�ncia de uma TextDraw muitas vezes n�o � mostrada ao jogador
		por motivo desconhecido. Como solu��o, basta criar uma TextDraw
		invis�vel e mostrar para o jogador ao conectar, e as TextDraws
		transparentes ser�o apresentadas normalmente.
*/
/*/// <summary>
/// Fun��o respons�vel por criar a TextDraw Fix.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static FixCreateTextDrawTransparency()
{
	textBugFix = TextDrawCreate(0.0, 0.0, "fix");
	TextDrawLetterSize(textBugFix, 0.000000, 0.000000);
}

/// <summary>
/// Fun��o respons�vel por mostrar a TextDraw Fix a um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
static FixShowTextDrawTransparency(playerid)
	TextDrawShowForPlayer(playerid, textBugFix);*/
//-----------------------------------------------------------------------------
/*
	Kick Time fix:
		Ao kickar um jogador utilizando a fun��o padr�o Kick, mensagens cliente
		ou dialogs enviados antes da fun��o n�o s�o mostrados ao jogador. Com
		isso, esse hook chama a fun��o Kick 70ms ap�s ser chamada.
*/
/// <summary>
/// Hook da fun��o Kick que atrasa a mesma 70ms.
/// </summary>
/// <returns>Retorna sempre 1.</returns>
KickEx(playerid)
{
	SetTimerEx("KickPlayer", 70, false, "i", playerid);
	return 1;
}
#if defined _ALS_Kick
	#undef Kick
#else
	#define _ALS_Kick
#endif
#define Kick KickEx

/*
 * FIXES
 ******************************************************************************
 */
/// <summary>
/// Hook da callback OnGameModeInit.
/// </summary>
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit fixes_OnGameModeInit
#if defined fixes_OnGameModeInit
	forward fixes_OnGameModeInit();
#endif
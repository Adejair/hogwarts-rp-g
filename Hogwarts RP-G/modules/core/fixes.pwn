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
 * MY CALLBACKS
 ******************************************************************************
 */
/// <summary>
/// Timer para kickar um jogador espec�fico.
/// Intervalo: 70 ms.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>Retorna sempre 1.</returns>
timer KickPlayer[70](playerid)
	return Kick(playerid);

/*
 * FIXES
 ******************************************************************************
 */
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
	defer KickPlayer(playerid);
	return 1;
}

/*
 * HOOKS
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
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Hook da fun��o Kick.
/// </summary>
#if defined _ALS_Kick
	#undef Kick
#else
	#define _ALS_Kick
#endif
#define Kick KickEx
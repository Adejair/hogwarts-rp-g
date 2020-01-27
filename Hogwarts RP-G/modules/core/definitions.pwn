/*
	Arquivo:
		modules/core/definitions.pwn

	Descri��o:
		- Este m�dulo � respons�vel por declarar algumas defini��es utilizadas
		em outros m�dulos.

	�ltima atualiza��o:
		02/01/18

	Copyright (C) 2017 Hogwarts RP/G
		(Bruno "Bruno13" Travi,
		Jo�o "BarbaNegra" Paulo,
		Jo�o "JPedro" Pedro,
		Jo�o "JPedro" Vithinn,
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
	 * COMMANDS
	 *
	|
	 *
	 * HOOKS
	 *
	|
*/
/*
 * INCLUDES
 ******************************************************************************
 */

/*
 * DEFINITIONS
 ******************************************************************************
 */
const

	INVALID_MODULE_ID	= -1,
	MODULE_LOGIN		= 0,
	MODULE_CHARACTER	= 1;
/*
 * ENUMERATORS
 ******************************************************************************
 */

/*
 * VARIABLES
 ******************************************************************************
 */

/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined definitions_OnGameModeInit
		definitions_OnGameModeInit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- inicializa o m�dulo;
	/// </summary>

	ModuleInit("core/definitions.pwn");

	return 1;
}

/*
 * MY CALLBACKS
 ******************************************************************************
 */

/*
 * FUNCTIONS
 ******************************************************************************
 */

/*
 * COMMANDS
 ******************************************************************************
 */

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
#define OnGameModeInit definitions_OnGameModeInit
#if defined definitions_OnGameModeInit
	forward definitions_OnGameModeInit();
#endif
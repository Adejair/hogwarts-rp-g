/*
	Arquivo:
		modules/core/colors.pwn

	Descri��o:
		- Este m�dulo � respons�vel pela defini��o de todas cores utilizadas.

	�ltima atualiza��o:
		24/08/17

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
	 * HOOKS
	 *
	|
*/
/*
 * DEFINITIONS
 ******************************************************************************
 */
stock const

	/// <summary>
	///	Defini��o das cores.</summary>
	COLOR_DEFAULT	=	0xA9C4E4AA,
	COLOR_RED		=	0xE84F33AA,
	COLOR_GREEN		=	0x9ACD32AA,
	COLOR_YELLOW	=	0xFCD440AA;

/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined colors_OnGameModeInit
		colors_OnGameModeInit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- inicia o m�dulo;
	/// </summary>
	
	ModuleInit("core/colors.pwn");
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
#define OnGameModeInit colors_OnGameModeInit
#if defined colors_OnGameModeInit
	forward colors_OnGameModeInit();
#endif
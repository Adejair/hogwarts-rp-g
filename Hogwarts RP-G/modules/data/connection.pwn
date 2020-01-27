/*
	Arquivo:
		modules/data/connection.pwn

	Descri��o:
		- Este m�dulo � respons�vel pela conex�o MySql � database.

	�ltima atualiza��o:
		21/08/17

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
	 * HOOKS
	 *
	|
*/
/*
 * VARIABLES
 ******************************************************************************
 */
new static const

	/// <summary>
	///	Vari�veis para armazenar os dados da database.</summary>
	mySQLHost[] 	= "localhost",
	mySQLUser[] 	= "root",
	mySQLDatabase[] = "hogs",
	mySQLPassword[] = "";

new

	/// <summary>
	///	Vari�vel para formatar a requisi��o sql.</summary>
	mySQLQuery[500],

	/// <summary>
	///	Vari�vel para armazenar a requisi��o sql.</summary>
	MySQL:mySQLHandle;

/*
 * MY CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined connection_OnGameModeInit
		connection_OnGameModeInit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- inicia o m�dulo.
	///		- define o registro de logs do MySQL para registrar tudo;
	///		- faz a conex�o MySQL;
	///		- checa a database das contas.
	/// </summary>

	ModuleInit("data/connection.pwn");

	mysql_log(ALL);

	MySqlConnect();

	MySqlCheckDatabase();

	return 1;
}

public OnGameModeExit()
{
	#if defined connection_OnGameModeExit
		connection_OnGameModeExit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- encerra a conex�o MySQL.
	/// </summary>

	MySqlDisconnect();

	return 1;
}

/*
 * FUNCTIONS
 ******************************************************************************
 */
/// <summary>
/// Faz a conex�o MySQL com o servidor. SE a conex�o falhar, o servidor console
/// fecha em alguns segundos.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static MySqlConnect()
{
	mySQLHandle = mysql_connect(mySQLHost, mySQLUser, mySQLPassword, mySQLDatabase);

	if(!IsAValidMySqlHandle(mySQLHandle))
	{
		print("  <!> MySQL: Falha ao conectar a database.");
		SendRconCommand("exit");
		return;
	}
	else
		printf("  * MySQL: Conectado a database '%s' com sucesso!", mySQLDatabase);
}

/// <summary>
/// Encerra a conex�o MySQL com o servidor.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static MySqlDisconnect()
{
	if(!IsAValidMySqlHandle(mySQLHandle))
		return;

	mysql_close(mySQLHandle);
}

/// <summary>
/// Cria a tabela das contas na database caso n�o exista.
/// </summary>
/// <returns>N�o retorna valores.</returns>
static MySqlCheckDatabase()
{
	if(!IsAValidMySqlHandle(mySQLHandle))
		return;

	mysql_query(mySQLHandle, "CREATE TABLE IF NOT EXISTS `accounts`(`id` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, `user` VARCHAR(24) NOT NULL, `password` VARCHAR(65) NOT NULL, `salt` VARCHAR(11) NOT NULL, `registerdate` DATE NOT NULL, `email` VARCHAR(64) NOT NULL, `lastlogin` INT(11) NOT NULL)", false);
}

/// <summary>
/// V�lida se o handle da conex�o com a database � v�lido.
/// </summary>
/// <param name="handle">ID do handle.</param>
/// <returns>True se for, False for inv�lido ou houver erro.</returns>
static IsAValidMySqlHandle(MySQL:handle)
	return !(handle == MYSQL_INVALID_HANDLE || mysql_errno(handle) != 0);

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
#define OnGameModeInit connection_OnGameModeInit
#if defined connection_OnGameModeInit
	forward connection_OnGameModeInit();
#endif

/// <summary>
/// Hook da callback OnGameModeExit.
/// </summary>
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit connection_OnGameModeExit
#if defined connection_OnGameModeExit
	forward connection_OnGameModeExit();
#endif
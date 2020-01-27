/*
	Arquivo:
		modules/data/player.pwn

	Descri��o:
		- Este m�dulo � respons�vel pelo carregamento e salvamento dos dados do
		jogador.

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
	 * FUNCTIONS
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
forward MySqlCheckAccountResponse(playerid);
forward MySqlLoadAccountResponse(playerid);
forward MySqlRegisterAccountResponse(playerid);

/*
 * ENUMERATORS
 ******************************************************************************
 */
/// <summary>
///	Enumerador da vari�vel 'playerAccountControl[MAX_PLAYERS][E_PLAYER_ACCOUNT_CONTROL]'.</summary>
enum E_PLAYER_ACCOUNT_CONTROL
{
	bool:E_PLAYER_REGISTRED,
	bool:E_PLAYER_LOGGED
}

/// <summary>
///	Enumerador da vari�vel 'playerAccountData[MAX_PLAYERS][E_PLAYER_ACCOUNT_DATA]'.</summary>
enum E_PLAYER_ACCOUNT_DATA
{
	E_PLAYER_DATABASE_ID,
	E_PLAYER_PASSWORD[65],
	E_PLAYER_SALT[11],
	E_PLAYER_EMAIL[64],
	E_PLAYER_LAST_LOGIN,
	bool:E_PLAYER_REMEMBER_LOGIN_IP
}

/*
 * VARIABLES
 ******************************************************************************
 */
static
	
	/// <summary>
	///	Vari�vel para controles da conta do jogador.</summary>
	playerAccountControl[MAX_PLAYERS][E_PLAYER_ACCOUNT_CONTROL],

	/// <summary>
	///	Vari�vel para armazenar dados da conta do jogador.</summary>
	playerAccountData[MAX_PLAYERS][E_PLAYER_ACCOUNT_DATA];

/*
 * NATIVE CALLBACKS
 ******************************************************************************
 */
public OnGameModeInit()
{
	#if defined player_OnGameModeInit
		player_OnGameModeInit();
	#endif
	/// <summary>
	/// Nesta callback:
	///		- inicia o m�dulo;
	/// </summary>

	ModuleInit("data/player.pwn");

	return 1;
}

public OnPlayerConnect(playerid)
{
	#if defined player_OnPlayerConnect
		player_OnPlayerConnect(playerid);
	#endif
	/// <summary>
	/// Nesta callback:
	///		- se o jogador for um NPC: retorna 1;
	///		- reseta a vari�vel de controle da conta do jogador;
	///		- checa a contra do jogador para controles.
	/// </summary>

	if(IsPlayerNPC(playerid))
		return 1;
	
	ResetPlayerAccountControl(playerid);
	CheckPlayerAccount(playerid);
	return 1;
}

/*
 * MY CALLBACKS
 ******************************************************************************
 */
/// <summary>
/// Callback resposta da requisi��o MySQL da fun��o CheckPlayerAccount para
/// realizar controles e armazenar dados do jogador.
/// Intervalo: -
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
public MySqlCheckAccountResponse(playerid)
{
	new rows;

	cache_get_row_count(rows);

	if(rows > 0)
	{
		cache_get_value_name_int(0, "id", playerAccountData[playerid][E_PLAYER_DATABASE_ID]);
		cache_get_value_name(0, "password", playerAccountData[playerid][E_PLAYER_PASSWORD], 65);
		cache_get_value_name(0, "salt", playerAccountData[playerid][E_PLAYER_SALT], 11);
		cache_get_value_name(0, "email", playerAccountData[playerid][E_PLAYER_EMAIL], 64);

		playerAccountControl[playerid][E_PLAYER_REGISTRED] = true;
	}
	else
		playerAccountControl[playerid][E_PLAYER_REGISTRED] = false;
}

/// <summary>
/// Callback resposta da requisi��o MySQL da fun��o LoadPlayerAccount para
/// realizar o login do jogador.
/// Intervalo: -
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
public MySqlLoadAccountResponse(playerid)
{
	new rows;

	if(cache_get_row_count(rows))
	{
		new lastLogin[11];

		cache_get_value_name_int(0, "lastlogin", playerAccountData[playerid][E_PLAYER_LAST_LOGIN]);

		mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "UPDATE `accounts` SET `lastlogin` = '%d' WHERE `id` = '%d'", gettime(), playerAccountData[playerid][E_PLAYER_DATABASE_ID]);
		mysql_tquery(mySQLHandle, mySQLQuery, "", "");

		GetDateFromTime(playerAccountData[playerid][E_PLAYER_LAST_LOGIN], lastLogin);

		SendClientMessageFormat(playerid, COLOR_GREEN, MESSAGE_LOGIN_SUCCESSFUL, GetNameOfPlayer(playerid), lastLogin);
	}
	else
		SendClientMessage(playerid, COLOR_RED, MESSAGE_LOGIN_ERROR);
}

/// <summary>
/// Callback resposta da requisi��o MySQL da fun��o RegisterPlayerAccount
/// para realizar controles e armazenar dados do jogador.
/// Intervalo: -
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
public MySqlRegisterAccountResponse(playerid)
{
	playerAccountData[playerid][E_PLAYER_DATABASE_ID] = cache_insert_id();
	playerAccountControl[playerid][E_PLAYER_REGISTRED] = true;
}

/*
 * FUNCTIONS
 ******************************************************************************
 */
/// <summary>
/// Obt�m a data de um unixtime espec�fico e armazena na vari�vel string.
/// </summary>
/// <param name="timestamp">Tempo em unixtime.</param>
/// <param name="string">Vari�vel para armazenar o resultado.</param>
/// <returns>True se o cache foi deletado, False se n�o.</returns>
static GetDateFromTime(timestamp, string[11])
{
	new Cache:result;
	
	mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "SELECT FROM_UNIXTIME(%d,%s)", timestamp, "'%d/%m/%Y'");
	result = mysql_query(mySQLHandle, mySQLQuery, true);
	cache_get_value_index(0, 0, string);
	return cache_delete(result);
}
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Realiza uma requisi��o MySQL para validar se um nome espec�fico j� foi
/// registrado.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="name">Nome.</param>
/// <returns>N�o retorna valores.</returns>
CheckNameAlreadyRegistered(playerid, const name[])
{
	mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "SELECT `id` FROM `accounts` WHERE `user` = '%e'", name);
	mysql_tquery(mySQLHandle, mySQLQuery, "CheckNameRegisteredResponse", "is", playerid, name);
}
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Reseta os controles da conta de um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
static ResetPlayerAccountControl(playerid)
{
	playerAccountControl[playerid][E_PLAYER_REGISTRED] = playerAccountControl[playerid][E_PLAYER_LOGGED] = false;
}
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Valida se um jogador espec�fico est� registrado.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>True se estiver, False se n�o.</returns>
IsPlayerRegistred(playerid)
	return ((IsPlayerConnected(playerid) ? (playerAccountControl[playerid][E_PLAYER_REGISTRED]) : (false)));
/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Obt�m o email da conta de um jogador espec�fico.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>Email do jogador.</returns>
GetPlayerAccountEmail(playerid)
{
	new email[64];

	format(email, 64, playerAccountData[playerid][E_PLAYER_EMAIL]);
	return email;
}

/*
-----------------------------------------------------------------------------*/
/// <summary>
/// Realiza uma requisi��o MySQL para alterar a senha de um jogador espec�fico
/// para uma nova senha espec�fica.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="password">Nova senha.</param>
/// <returns>N�o retorna valores.</returns>
ChangePlayerPassword(playerid, password[])
{
	new salt[11];

	for(new i; i < 10; i++)
		salt[i] = random(79) + 47;

	salt[10] = 0;

	SHA256_PassHash(password, salt, playerAccountData[playerid][E_PLAYER_PASSWORD], 65);

	mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "UPDATE `accounts` SET `password` = '%e', `salt` = '%e' WHERE `id` = '%d'",
		playerAccountData[playerid][E_PLAYER_PASSWORD],
		salt,
		playerAccountData[playerid][E_PLAYER_DATABASE_ID]);

	mysql_tquery(mySQLHandle, mySQLQuery, "", "");

	format(playerAccountData[playerid][E_PLAYER_SALT], 11, salt);
}

/// <summary>
/// Realiza uma requisi��o MySQL para carregar a conta de um jogador
/// espec�fico atrav�s da senha informada por este.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="password">Senha do jogador.</param>
/// <returns>True se a senha estiver correta, False se n�o.</returns>
LoadPlayerAccount(playerid, password[])
{
	if(!IsPlayerRegistred(playerid))
		return false;

	new hash[65];

    SHA256_PassHash(password, playerAccountData[playerid][E_PLAYER_SALT], hash, 65);

	if(!strcmp(hash, playerAccountData[playerid][E_PLAYER_PASSWORD]))
	{
		mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "SELECT * FROM `accounts` WHERE `id` = '%d'", playerAccountData[playerid][E_PLAYER_DATABASE_ID]);
		mysql_tquery(mySQLHandle, mySQLQuery, "MySqlLoadAccountResponse", "i", playerid);

		return true;
	}
	return false;
}

/// <summary>
/// Registra a conta de um jogador espec�fico, com senha e email espec�ficos.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <param name="password">Senha do jogador.</param>
/// <param name="email">Email do jogador.</param>
/// <returns>N�o retorna valores.</returns>
RegisterPlayerAccount(playerid, password[], email[])
{
	new salt[11];

	for(new i; i < 10; i++)
		salt[i] = random(79) + 47;

	salt[10] = 0;

	SHA256_PassHash(password, salt, playerAccountData[playerid][E_PLAYER_PASSWORD], 65);

	mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "INSERT INTO `accounts` (`user`, `password`, `salt`, `registerdate`, `email`, `lastlogin`) VALUES ('%e', '%e', '%e', now(), '%e', %d)",
		GetNameOfPlayer(playerid),
		playerAccountData[playerid][E_PLAYER_PASSWORD],
		salt,
		email,
		gettime());

	mysql_tquery(mySQLHandle, mySQLQuery, "MySqlRegisterAccountResponse", "i", playerid);
}

/// <summary>
/// Realiza uma requisi��o MySQL para checar se a conta do jogador existe e
/// fazer os controles da mesma.
/// </summary>
/// <param name="playerid">ID do jogador.</param>
/// <returns>N�o retorna valores.</returns>
CheckPlayerAccount(playerid)
{
	mysql_format(mySQLHandle, mySQLQuery, sizeof(mySQLQuery), "SELECT `id`, `password`, `salt`, `email` FROM `accounts` WHERE `user` = '%e'", GetNameOfPlayer(playerid));
	mysql_tquery(mySQLHandle, mySQLQuery, "MySqlCheckAccountResponse", "i", playerid);
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
#define OnGameModeInit player_OnGameModeInit
#if defined player_OnGameModeInit
	forward player_OnGameModeInit();
#endif

/// <summary>
/// Hook da callback OnPlayerConnect.
/// </summary>
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect player_OnPlayerConnect
#if defined player_OnPlayerConnect
	forward player_OnPlayerConnect(playerid);
#endif
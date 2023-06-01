#pragma semicolon 1
#pragma newdecls required

#include <butcher_core>
#include <sdktools_stringtables>
#include <sdktools_functions>
#include <smartdm>

ConVar
	cvModels[2],
	cvTimerSetModel;

char
	sModels[2][512];

char sModelsT[4][PLATFORM_MAX_PATH] =
{
	"models/player/t_phoenix.mdl",
	"models/player/t_leet.mdl",
	"models/player/t_arctic.mdl",
	"models/player/t_guerilla.mdl"
};

char sModelsCT[4][PLATFORM_MAX_PATH] =
{
	"models/player/ct_urban.mdl",
	"models/player/ct_gsg9.mdl",
	"models/player/ct_sas.mdl",
	"models/player/ct_gign.mdl"
};

public Plugin myinfo =
{
	name = "[Butcher Core] Set models",
	author = "Nek.'a 2x2 | ggwp.site ",
	description = "Установка модели Мяснику",
	version = "1.0.0",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvTimerSetModel = CreateConVar("sm_butcher_model_timer", "2.0", "Через сколько секунд будет установлена модель Мясника?");

	cvModels[0] = CreateConVar("sm_butcher_ct", "models/player/ggwp/zombie/l4d/hunter/hunterggwp.mdl", "Скин МЯСНИКА для CT");

	cvModels[1] = CreateConVar("sm_butcher_t", "models/player/ggwp/ter/jason/jason.mdl", "Скин МЯСНИКА для T");

	HookEvent("player_spawn", Event_PlayerSpawn);

	AutoExecConfig(true, "models", "butcher");
}

public void OnMapStart()
{
	char sBuffer[512];
	
	for(int i; i < 2; i++)
	{
		cvModels[i].GetString(sBuffer, sizeof(sBuffer));
		if(sBuffer[0])
		{
			sModels[i] = sBuffer;
			PrecacheModel(sBuffer);
			Downloader_AddFileToDownloadsTable(sBuffer);
		}
	}
}

void Event_PlayerSpawn(Handle hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if(IsValidClient(client) && !IsFakeClient(client) && BUTCHER_GetStstusButcher(client))
	{
		CreateTimer(cvTimerSetModel.FloatValue, SetModelTimer, GetClientUserId(client));
	}
}

public void BUTCHER_ActiveStart(int client)
{
	CreateTimer(cvTimerSetModel.FloatValue, SetModelTimer, GetClientUserId(client));
}

Action SetModelTimer(Handle hTimer, int UserId)
{
	int client = GetClientOfUserId(UserId);

	if(GetClientTeam(client) == 2 && sModels[0][0])
		SetEntityModel(client, sModels[0]);
	else if(GetClientTeam(client) == 3 && sModels[1][0])
        SetEntityModel(client, sModels[1]);

	return Plugin_Stop;
}

public void BUTCHER_Reset(int client)
{
	SwitchTeam(client, GetClientTeam(client));
}

void SwitchTeam(int client, int iTeam)
{
	char sModel[2][PLATFORM_MAX_PATH];
	GetClientModel(client, sModel[0], sizeof(sModel[]));
		
	if (iTeam == 3)
	{
		if(StrContains(sModel[0], sModelsT[0], false)) sModel[1] = sModelsCT[0];
		if(StrContains(sModel[0], sModelsT[1], false)) sModel[1] = sModelsCT[1];
		if(StrContains(sModel[0], sModelsT[2], false)) sModel[1] = sModelsCT[2];
		if(StrContains(sModel[0], sModelsT[3], false)) sModel[1] = sModelsCT[3];
	}
	else if(iTeam == 2)
	{
		if(StrContains(sModel[0], sModelsCT[0], false)) sModel[1] = sModelsT[0];
		if(StrContains(sModel[0], sModelsCT[1], false)) sModel[1] = sModelsT[1];
		if(StrContains(sModel[0], sModelsCT[2], false)) sModel[1] = sModelsT[2];
		if(StrContains(sModel[0], sModelsCT[3], false)) sModel[1] = sModelsT[3];
	}
	SetEntityModel(client, sModel[1]);
}

stock bool IsValidClient(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client);
}
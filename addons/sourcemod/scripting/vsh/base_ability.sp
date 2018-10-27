#define MAX_BOSS_ABILITY 	8
#define TOTAL_MAX_ABILITY	(MAX_BOSS_ABILITY*TF_MAXPLAYERS)

static char g_sAbilityType[TOTAL_MAX_ABILITY][64];
static int g_iLinkedClient[TOTAL_MAX_ABILITY];
static bool g_bSuperRage[TF_MAXPLAYERS+1];
static float g_flLastRagingTime[TF_MAXPLAYERS+1];

methodmap IAbility
{
	property int Index
	{
		public get()
		{
			return view_as<int>(this);
		}
	}
	
	property int Client
	{
		public get()
		{
			return g_iLinkedClient[this.Index];
		}
	}
	
	property float flLastRageTime
	{
		public get()
		{
			return g_flLastRagingTime[this.Client];
		}
	}
	
	property bool bSuperRage
	{
		public get()
		{
			return g_bSuperRage[this.Client];
		}
	}
	
	public bool FindFunction(char[] sName)
	{
		char sFunc[1000];
		Format(sFunc, sizeof(sFunc), "%s.%s", g_sAbilityType[this.Index], sName);
		Function func;
		if ((func = GetFunctionByName(INVALID_HANDLE, sFunc)) != INVALID_FUNCTION)
		{
			Call_StartFunction(INVALID_HANDLE, func);
			Call_PushCell(this);
			return true;
		}
		return false;
	}
	
	public IAbility(int client, int abilityslot, char[] type)
	{
		//Calculate ability unique ID
		int iUniqueID = (((client-1)*MAX_BOSS_ABILITY)+abilityslot);
		strcopy(g_sAbilityType[iUniqueID], sizeof(g_sAbilityType[]), type);
		g_iLinkedClient[iUniqueID] = client;
		IAbility ability = view_as<IAbility>(iUniqueID);
		if (ability.FindFunction(type))
			Call_Finish();
		g_flLastRagingTime[client] = 0.0;
		g_bSuperRage[client] = false;
		return ability;
	}
	
	public char GetType(char[] sType, int iLength)
	{
		strcopy(sType, iLength, g_sAbilityType[this.Index]);
	}
	
	public void Think()
	{
		if (this.FindFunction("Think"))
			Call_Finish();
	}
	
	public void OnPlayerKilled(int iVictim, Event eventInfo)
	{
		if (this.FindFunction("OnPlayerKilled"))
		{
			Call_PushCell(iVictim);
			Call_PushCell(eventInfo);
			Call_Finish();
		}
	}
	
	public void OnRage(bool bSuperRage)
	{
		g_flLastRagingTime[this.Client] = GetGameTime();
		g_bSuperRage[this.Client] = bSuperRage;
		if (this.FindFunction("OnRage"))
		{
			Call_PushCell(bSuperRage);
			Call_Finish();
		}
	}
	
	public Action OnButton(int button)
	{
		Action action = Plugin_Continue;
		if (this.FindFunction("OnButton"))
		{
			Call_PushCell(button);
			Call_Finish(action);
		}
		return action;
	}
	
	public void OnButtonPress(int button)
	{
		if (this.FindFunction("OnButtonPress"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
	}
	
	public void OnButtonHold(int button)
	{
		if (this.FindFunction("OnButtonHold"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
	}
	
	public void OnButtonRelease(int button)
	{
		if (this.FindFunction("OnButtonRelease"))
		{
			Call_PushCell(button);
			Call_Finish();
		}
	}
	
	public void Destroy()
	{
		if (this.FindFunction("Destroy"))
			Call_Finish();
	}
}

const IAbility INVALID_ABILITY = view_as<IAbility>(-1);
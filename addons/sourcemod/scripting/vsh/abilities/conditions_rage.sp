static float 	 g_flRageCondDuration[TF_MAXPLAYERS+1];
static ArrayList g_aConditions[TF_MAXPLAYERS+1];

methodmap CRageAddCond < IAbility
{
	property float flRageCondDuration
	{
		public set(float flVal)
		{
			g_flRageCondDuration[this.Client] = flVal;
		}
		public get()
		{
			return g_flRageCondDuration[this.Client];
		}
	}
	
	public void AddCond(TFCond cond)
	{
		g_aConditions[this.Client].Push(cond);
	}
	
	public CRageAddCond(IAbility ability)
	{
		if (g_aConditions[ability.Client] == null)
			g_aConditions[ability.Client] = new ArrayList();
		g_aConditions[ability.Client].Clear();
	}
	
	public void OnRage(bool bSuperRage)
	{
		int iLength = g_aConditions[this.Client].Length;
		float flDuration = this.flRageCondDuration;
		if (bSuperRage)
			flDuration *= 2.0;
		for (int i = 0; i < iLength; i++)
			TF2_AddCondition(this.Client, g_aConditions[this.Client].Get(i), flDuration);
	}
}

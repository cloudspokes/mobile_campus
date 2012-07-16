trigger ResetAssignmentCounters on Term__c (after update) {

/*
	boolean resetCounters = false;
	
	for(Term__c t : trigger.new)
	{
		if(t.Is_Current_Term__c && (t.Is_Current_Term__c != trigger.oldMap.get(t.Id).Is_Current_Term__c))
		{
			resetCounters = true;
		}
		
	}
	
	if(resetCounters)
	{
		List<User> updatedUsers = new List<User>();
		for(User u : [Select u.No_of_Leads_in_Inquiry_Status__c, u.No_of_Active_Leads_Assigned__c From User u where u.Admissions_Group__c != null])
		{
			u.No_of_Active_Leads_Assigned__c = 0;
			u.No_of_Leads_in_Inquiry_Status__c = 0;
			updatedUsers.add(u);
		}
		
		if(!updatedUsers.isEmpty())
			update updatedUsers;
	}
	*/
}
trigger LeadReAssignmentTrigger on Contact (before update) {
	List<Contact> leads = new List<Contact>();
	Set<Id> ownersToCheck = new Set<Id>();
	
	/* If the lead has been reactivated and the owning rep is no longer
	   active, reassign the lead.
	*/
	for (Contact c: trigger.new) {
		if (c.Recruiting_Status__c != 'Inactive' &&
			(trigger.oldMap.get(c.Id).Recruiting_Status__c != c.Recruiting_Status__c || 
			 trigger.oldMap.get(c.Id).Current_Opp_Id__c != c.Current_Opp_Id__c)) 
		{
			ownersToCheck.add(c.OwnerId);
		}
	}
	System.debug(LoggingLevel.INFO, 'Owners to check: ' + ownersToCheck);
	if (!ownersToCheck.isEmpty()) {
		Set<Id> inactiveOwners = new Set<Id>();
		for (User user :[select Id from User where isActive = False and Id in :ownersToCheck]) {
			inactiveOwners.add(user.Id);
			System.debug(LoggingLevel.INFO, 'Owner Inactive: ' + user);
		}
		if (!inactiveOwners.isEmpty()) {
			for (Contact c : trigger.new) {
				if (inactiveOwners.contains(c.OwnerId) && c.Recruiting_Status__c != 'Inactive') {
					c.Reassign_Lead__c = true;
					System.debug(LoggingLevel.INFO, 'Reassigning due to inactive owner: ' + c);					
				}
			}
		}			
	}
	
	/* Reassign leads removed from Telemarketer's call list */
	for(Contact c : trigger.new)
	{
		//only execute if record type is one of the 3  Lead types
 		if(c.RecordTypeId == '012800000002dPnAAI' || c.RecordTypeId == '012800000002dKrAAI' || c.RecordTypeId == '012800000002dLxAAI')
		{
			 if((c.Telemarketer_Assignment_Cancelled__c != trigger.oldMap.get(c.Id).Telemarketer_Assignment_Cancelled__c
			 	&& c.Telemarketer_Assignment_Cancelled__c == true
			 	&& (c.OwnerId == '00580000001owcI' || c.OwnerId == '00580000002g8gg')))
			 {
			 	c.Reassign_Lead__c = true;
			 }
		}
	}
	
	for (Contact c : trigger.new) {
		if (c.Reassign_Lead__c == true) {
			leads.add(c);
		}
	}

	LeadAssignmentManager mgr = new LeadAssignmentManager();
	
	
	
	if(!leads.isEmpty())
	{
		List<Contact> updatedLeads = mgr.assignLeads(leads);
		
		
		for (Contact c : trigger.new)
		{
			for(Contact l : updatedLeads)
			{
				if(c.Id == l.Id)
				{
					c = l;
					c.Reassign_Lead__c = false;   //reset the reassignment flag
					//c.Telemarketer_Assignment_Cancelled__c = false;
				}
			}
		}
		
	}
	
}
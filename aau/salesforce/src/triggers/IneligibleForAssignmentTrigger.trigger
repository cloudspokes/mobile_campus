trigger IneligibleForAssignmentTrigger on User (before update) {
	/*
	for(User u : trigger.new)
	{
		if(u.Admissions_Group__c != null && u.Admissions_Group__c.contains('Domestic Undergraduate Admissions'))
		{
			//handle the case that not every admin officier was defaulted to 0
			
			
			if(u.No_of_Leads_in_Inquiry_Status__c > 50 || u.No_of_Active_Leads_Assigned__c > 800)
			{
				u.Eligible_for_Lead_Assignment__c = false;
			}
		}
	}
	*/
}
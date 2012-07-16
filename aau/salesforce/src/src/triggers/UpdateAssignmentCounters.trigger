trigger UpdateAssignmentCounters on Contact (after update) {
/* gsl

//TODO: after update check if old value of contact status changed from one of the 3 assignment types into Contacted - No Response, Registered, Inactive
//if so decrement the counters.
	Map<String, AssignmentDecrementVO> decrementCountByUser = new Map<String, AssignmentDecrementVO>();
	Map<Id, String> searchCriteria = new Map<Id, String>();
	List<TermAssignment__c> termsForUpdating = new List<TermAssignment__c>();
	
	for(Contact c : trigger.new)
	{
		//only execute if record type is one of the 3  Lead types
 		if(c.RecordTypeId == '012800000002dPnAAI' || c.RecordTypeId == '012800000002dKrAAI' || c.RecordTypeId == '012800000002dLxAAI')
		{
			Contact oldc = trigger.oldMap.get(c.Id);
			 if((oldc.Recruiting_Status__c == 'Inquiry' || oldc.Recruiting_Status__c == 'Contacted' || oldc.Recruiting_Status__c == 'Prospect') &&
			 	(c.Recruiting_Status__c == 'Contacted - No Response' || c.Recruiting_Status__c == 'Registered' || c.Recruiting_Status__c =='Inactive'))
			 {
			 	searchCriteria.put(c.OwnerId, c.Start_Term_Latest_Opp__c);
			 	String key = c.OwnerId+c.Start_Term_Latest_Opp__c;
			 	
			  	//add all active
			 	AssignmentDecrementVO activeVO = null;
			 	if(decrementCountByUser.containsKey(key))
			 	{
			 		activeVO = decrementCountByUser.get(key);
			 		decrementCountByUser.remove(key);
			 	}
			 	else
			 	{
			 		activeVO = new AssignmentDecrementVO();
			 		activeVO.userid = c.OwnerId;
			 		activeVO.termName = c.Start_Term_Latest_Opp__c;	
			 	}
			 			
			 	activeVO.activeCounter++;
			 	
			 	if(oldc.Recruiting_Status__c == 'Inquiry')
			 		activeVO.inquiryCounter++;
			 	
			 	decrementCountByUser.put(key, activeVO);
				 		
			 }
		}
	}
	//check all active - as this will always be equal or greater than inquiry count
	if(!decrementCountByUser.isEmpty())
	{
		
		AssignmentDecrementVO avo = null;
		Double currInq = 0;
		Double currActive = 0;
		
		for (TermAssignment__c t : [Select t.Term__r.Name, t.Term__c, t.Number_of_Leads_in_Inquiry_Status__c, t.Number_of_Leads_Assigned__c, t.Id, t.Admissions_Officer__c, t.Admissions_Officer__r.Username
									From TermAssignment__c t where t.Admissions_Officer__c in :searchCriteria.keySet() And t.Term__r.Name in :searchCriteria.values()])
		{
			String tkey = t.Admissions_Officer__c+t.Term__r.Name;
			
			if(decrementCountByUser.containsKey(tkey))
			{
				avo = decrementCountByUser.get(tkey);
				currInq = t.Number_of_Leads_in_Inquiry_Status__c;
				currActive = t.Number_of_Leads_Assigned__c;
				
				if(currInq - avo.inquiryCounter <= 0)
					t.Number_of_Leads_in_Inquiry_Status__c = 0;
				else
					t.Number_of_Leads_in_Inquiry_Status__c = currInq - avo.inquiryCounter;
					
				if(currActive - avo.activeCounter <= 0)
					t.Number_of_Leads_Assigned__c = 0;
				else
					t.Number_of_Leads_Assigned__c = currActive - avo.activeCounter;
				
				termsForUpdating.add(t);
			}	
		}
		
		if(!termsForUpdating.isEmpty())
			update termsForUpdating;
		
	}
*/	
}
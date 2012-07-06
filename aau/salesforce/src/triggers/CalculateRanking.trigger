trigger CalculateRanking on Contact(before insert, before update) 
{
	Map<String, Contact> contacts = new Map<String, Contact>();
	
	for(Contact c : trigger.new)
	{
		//only execute if record type is one of the 3  Lead types
 		if(c.PeopleSoft_Person_Id__c != null && c.RecordTypeId == '012800000002dPnAAI') // || c.RecordTypeId == '012800000002dKrAAI' || c.RecordTypeId == '012800000002dLxAAI')
		{
				//we need to use the peoplesoft ID as on 'before insert' we dont have 
				// a contact id yet
				if(trigger.isInsert)
				{
					if((c.Country__c == 'United States' && c.Recruiting_Status__c == 'Prospect') || c.Country__c != 'United States')
						contacts.put(c.PeopleSoft_Person_ID__c, c);
				}
				if(trigger.isUpdate)
				{
					if((c.Country__c == 'United States' && c.Recruiting_Status__c == 'Prospect') || c.Country__c != 'United States')
					{
						Contact oldc = trigger.oldMap.get(c.Id);
						if(c.Country__c !=  oldc.Country__c || c.State_Province__c != oldc.State_Province__c ||
						   c.Referral_Source__c != oldc.Referral_Source__c || c.Service_Indicators_Non_Editable__c !=  oldc.Service_Indicators_Non_Editable__c ||
						   c.Have_you_taken_classes_at_AAU_before__c != oldc.Have_you_taken_classes_at_AAU_before__c ||
						   c.Transcript_Review_Completed__c != oldc.Transcript_Review_Completed__c)
						   		contacts.put(c.PeopleSoft_Person_ID__c, c);
					}
				}
		}
	}
	
	if(!contacts.isEmpty())
	{
		//  Move all this to asynchronous job
		/*
		LeadScoreManager scorer = new LeadScoreManager();
		Map<String, Double> scores = scorer.scoreApplications(contacts);
		Map<String, String> rankings = scorer.getRankings(scores);
	
		for (Contact c : contacts.values())
		{
			if(c.RecordTypeId == '012800000002dPnAAI')
			{
					c.Score__c = scores.get(c.PeopleSoft_Person_ID__c);
				c.Ranking__c = rankings.get(c.PeopleSoft_Person_ID__c);
			}
		}
		*/
		for (Contact c : contacts.values())
		{
			c.Calculate_Ranking__c = True;
		}
	}
}
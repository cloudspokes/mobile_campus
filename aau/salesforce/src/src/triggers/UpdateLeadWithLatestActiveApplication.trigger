trigger UpdateLeadWithLatestActiveApplication on Admissions_Opportunity__c (after insert, after update) {
	
	Set<ID> leadIds = new Set<ID>();
	for (Admissions_Opportunity__c application : Trigger.new) {
		leadIds.add(application.Lead__c);
	}

	Map<ID, Contact> leadMap = new Map<ID, Contact>([select Id, Name 
	                                                      , Application_Status_Latest_Opp__c, Career_Latest_Opp__c
	                                                      , Recruiting_Center_Latest_Opp__c, Start_Term_Latest_Opp__c
	                                                      , Current_Opp_Id__c
	                                                      , (select Application_Status__c, Career__c, Recruiting_Center__c, Start_Term__c 
	                                                         from Applications__r 
	                                                         where Application_Status__c in ('Active','Matriculated') 
	                                                         order by CreatedDate desc
	                                                        )
	                                                 from Contact 
	                                                 where Id in :leadIds
	                                                ]);

	Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

	if (Trigger.isInsert) {
		for (Admissions_Opportunity__c application : Trigger.new) {
			Contact lead = leadMap.get(application.Lead__c);

			lead.Application_Status_Latest_Opp__c = application.Application_Status__c;
			lead.Career_Latest_Opp__c = application.Career__c;
			lead.Recruiting_Center_Latest_Opp__c = application.Recruiting_Center__c;
			lead.Start_Term_Latest_Opp__c = application.Start_Term__c;
			lead.Current_Opp_Id__c = application.Id;

			if(!contactsToUpdate.containsKey(lead.id))
				contactsToUpdate.put(lead.id, lead);
		}
	}
	else {
		for (Admissions_Opportunity__c application : Trigger.new) {
			Contact lead = leadMap.get(application.Lead__c);

			if (application.Application_Status__c != Trigger.oldMap.get(application.Id).Application_Status__c) {
				if (application.Application_Status__c == 'Inactive') {
					if (!lead.Applications__r.isEmpty()) {
						Admissions_Opportunity__c latestActiveApplication = lead.Applications__r[0];

						lead.Application_Status_Latest_Opp__c = latestActiveApplication.Application_Status__c;
						lead.Career_Latest_Opp__c = latestActiveApplication.Career__c;
						lead.Recruiting_Center_Latest_Opp__c = latestActiveApplication.Recruiting_Center__c;
						lead.Start_Term_Latest_Opp__c = latestActiveApplication.Start_Term__c;
						lead.Current_Opp_Id__c = application.Id;
					}
					else {
						lead.Application_Status_Latest_Opp__c = 'Inactive';
						lead.Current_Opp_Id__c = application.Id;
					}
				} 
				else {
					lead.Application_Status_Latest_Opp__c = application.Application_Status__c;
					lead.Career_Latest_Opp__c = application.Career__c;
					lead.Recruiting_Center_Latest_Opp__c = application.Recruiting_Center__c;
					lead.Start_Term_Latest_Opp__c = application.Start_Term__c;
					lead.Current_Opp_Id__c = application.Id;
				}

				if(!contactsToUpdate.containsKey(lead.id))
					contactsToUpdate.put(lead.id, lead);
			}

			if ( ((application.Recruiting_Center__c != Trigger.oldMap.get(application.Id).Recruiting_Center__c)
			    ||(application.Start_Term__c != Trigger.oldMap.get(application.Id).Start_Term__c))
			    && lead.Current_Opp_Id__c == application.Id
			   ) {
				lead.Recruiting_Center_Latest_Opp__c = application.Recruiting_Center__c;
				lead.Start_Term_Latest_Opp__c = application.Start_Term__c;
				
				if(!contactsToUpdate.containsKey(lead.id))
					contactsToUpdate.put(lead.id, lead);
			}
		}
	}

	if (!contactsToUpdate.isEmpty())
		update contactsToUpdate.values();
		
}
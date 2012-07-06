trigger UpdateLeadWithCurrentAdmOpp on Admissions_Opportunity__c (after insert, after update) {
    
    List<Admissions_Opportunity__c> oppsOfInterest = new List<Admissions_Opportunity__c>();
    
    if (Trigger.isInsert) {
        oppsOfInterest = Trigger.new;
    } else {
        for (Admissions_Opportunity__c opp: Trigger.new) {
            Admissions_Opportunity__c oldOpp = Trigger.oldMap.get(opp.Id);
            if (opp.Application_Status__c != oldOpp.Application_Status__c ||
                opp.Career__c != oldOpp.Career__c ||
                opp.Recruiting_Center__c != oldOpp.Recruiting_Center__c ||
                opp.Start_Term__c != oldOpp.Start_Term__c ||
                opp.Current_No_of_Units_Enrolled__c != oldOpp.Current_No_of_Units_Enrolled__c ||
                (opp.PeopleSoft_Application_Id__c != null && oldOpp.PeopleSoft_Application_Id__c == null)) {
                    oppsOfInterest.add(opp);
            } 
        }
    }
    
    
    if (!oppsOfInterest.isEmpty()) {
        Set<ID> leadIds = new Set<ID>();
        Set<String> terms = new Set<String>();
        for (Term__c t : [select Name from Term__c 
                           where Is_Current_Term__c = True or Is_Future_Term__c = 'Future' 
                           order by Name]) 
        {
            terms.add(t.name);
        } 
        for (Admissions_Opportunity__c opp : oppsOfInterest) 
        {
            leadIds.add(opp.Lead__c);
        }

        Map<ID, Contact> leadMap = new Map<ID, Contact>([select Id, Name, 
                                                                Application_Status_Latest_Opp__c, Career_Latest_Opp__c,
                                                                Recruiting_Center_Latest_Opp__c, Start_Term_Latest_Opp__c,
                                                                Current_Opp_Id__c, Recruiting_Status__c, 
                                                                OwnerId, Owner.UserRole.Name,
                                                                Reassign_Lead__c, Telemarketer_Assignment_Cancelled__c,
                                                                School_Attending__c,
                                                                (select Id, Application_Status__c, Career__c, Recruiting_Center__c, 
                                                                        Start_Term__c, PeopleSoft_Application_ID__c,
                                                                        Current_No_of_Units_Enrolled__c  
                                                                 from Applications__r 
                                                                 where Application_Status__c in ('Active','Matriculated')
                                                                   and Start_Term__c in :terms 
                                                                 order by Start_Term__c, Name
                                                                 limit 1  
                                                                )
                                                         from Contact 
                                                         where Id in :leadIds
                                                        ]);

        Map<Id, Contact> leadsToUpdate = new Map<Id, Contact>();
        
        for (Admissions_Opportunity__c opp : oppsOfInterest) {
            if (!leadsToUpdate.containsKey(opp.Lead__c)) {
                
                Contact lead = leadMap.get(opp.Lead__c);
                String oldRecruitingStatus = lead.Recruiting_Status__c;
                Id oldCurrentOppId = lead.Current_Opp_Id__c;
                Admissions_Opportunity__c currentOpp = opp;
                
                if (!lead.Applications__r.isEmpty()) {
                    currentOpp = lead.Applications__r;
                    lead.Current_Opp_Id__c = currentOpp.Id;
                }
                                
                if (lead.Current_Opp_Id__c == currentOpp.Id) {
                    lead.Application_Status_Latest_Opp__c = currentOpp.Application_Status__c;
                    lead.Career_Latest_Opp__c = currentOpp.Career__c;
                    lead.Recruiting_Center_Latest_Opp__c = currentOpp.Recruiting_Center__c;
                    lead.Start_Term_Latest_Opp__c = currentOpp.Start_Term__c;
                    leadsToUpdate.put(lead.Id, lead);
                    
                    /* Set the recruiting status of the lead based on the status of the current opp */
                    if (currentOpp.Current_No_of_Units_Enrolled__c != null && 
                        Double.valueOf(currentOpp.Current_No_of_Units_Enrolled__c) > 0)
                    {
                        lead.Recruiting_Status__c = 'Registered';
                    } else {
                        if (currentOpp.PeopleSoft_Application_Id__c != null) {
                            if (currentOpp.Application_Status__c == 'Active' ||
                                currentOpp.Application_Status__c =='Matriculated') 
                            {
                            	if (lead.Career_Latest_Opp__c != 'NM') {
                                	lead.Recruiting_Status__c = 'Applicant';
                            	} else {
                            		lead.Recruiting_Status__c = 'Participant';
                            	}
                            } else {
                                if (currentOpp.Application_Status__c == 'Withdrawn') {
                                    if (lead.Recruiting_Status__c == 'Registered') {
                                    	if (lead.Career_Latest_Opp__c != 'NM') {
                                        	lead.Recruiting_Status__c = 'Applicant';
                                    	} else {
                                    		lead.Recruiting_Status__c = 'Participant';
                                    	}
                                    }
                                }
                            }
                            /* If the lead is now an applicant, ensure it is removed from telemarketers portfolio */
                            if (lead.Owner.UserRole.Name == 'Telemarketer' && lead.Telemarketer_Assignment_Cancelled__c == false) {
                                lead.Telemarketer_Assignment_Cancelled__c = true;
                            }
                        } else {
                            if (lead.Recruiting_Status__c == 'Applicant' ||
                            	lead.Recruiting_Status__c == 'Participant' ||
                                lead.Recruiting_Status__c == 'Registered' ||
                                lead.Recruiting_Status__c == 'Contacted - No Response' ||
                                lead.Recruiting_Status__c == 'Inactive') 
                            {
                                if (currentOpp.Application_Status__c == 'Active') {
                                    lead.Recruiting_Status__c = 'Prospect';
                                }
                            }
                        }
                    }
                }
                
                if (lead.School_Attending__c != null && lead.Recruiting_Status__c != 'Attending Other School')
                {
                    lead.School_Attending__c = null;
                }  
                
            } 
        }
        
        update leadsToUpdate.values();
    }               
}
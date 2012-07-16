trigger ProgramPlanChangeToPSFT on Program_Plan_SubPlan__c (after insert, after update, before delete) {
    Set<ID> applicationIds = new Set<ID>();
    
    if (UserInfo.getProfileId() != '00e800000012o2gAAA') {
		if (Trigger.isDelete) {
			for (Program_Plan_SubPlan__c plan : Trigger.old) {
				applicationIds.add(plan.Admissions_Opportunity__c);
			}
		} else {
	        for (Program_Plan_SubPlan__c plan : Trigger.New) {
    	        if (Trigger.isInsert) {
        	        applicationIds.add(plan.Admissions_Opportunity__c);
            	} else {
                	Program_Plan_SubPlan__c oldp = Trigger.oldMap.get(plan.Id);
            		if (plan.Program__c != oldp.Program__c || 
            		    plan.Plan__c != oldp.Plan__c || 
            			plan.Sub_Plan__c != oldp.Sub_Plan__c)
                	{ 
                    	applicationIds.add(plan.Admissions_Opportunity__c);
                	}
    	        }
            }
        }

        if (!applicationIds.isEmpty()) {
			List<Admissions_Opportunity__c> affectedApplications = new List<Admissions_Opportunity__c>();
			
            for (Id app_id : applicationIds) {
            	Admissions_Opportunity__c application = new Admissions_Opportunity__c(Id=app_id, Send_Opp_to_PSFT__c = true);
            	affectedApplications.add(application);
            }

            update affectedApplications;
        }
    }
}
trigger ProgramPlanDeletedToPSFT on Program_Plan_SubPlan__c (before delete) {
	/*
    Set<ID> applicationIds = new Set<ID>();
    
    if (UserInfo.getProfileId() != '00e800000012o2gAAA') {
        for (Program_Plan_SubPlan__c plan : Trigger.Old) {
            applicationIds.add(plan.Admissions_Opportunity__c);
        }

        List<Admissions_Opportunity__c> affectedApplications = [select Id, Send_Opp_to_PSFT__c
                                                                from Admissions_Opportunity__c 
                                                                where Id in :applicationIds
                                                               ];

        for (Admissions_Opportunity__c application : affectedApplications) {
            application.Send_Opp_to_PSFT__c = true;
        }

        if (!affectedApplications.isEmpty())
            update affectedApplications;
            
    }
    */
}
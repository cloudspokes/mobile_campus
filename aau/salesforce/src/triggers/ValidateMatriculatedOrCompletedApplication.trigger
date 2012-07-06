trigger ValidateMatriculatedOrCompletedApplication on Admissions_Opportunity__c (before update) {
	/*
    Set<String> statuses = new Set<String>{'Matriculated', 'Completed'};
    List<Admissions_Opportunity__c> opportunitiesAffected = new List<Admissions_Opportunity__c>();

    // check whether anyone is setting the recruiting status to 'Applicant'
    for (Admissions_Opportunity__c opportunity : Trigger.new) {
        if (statuses.contains(opportunity.Application_Status__c) 
            && !statuses.contains(Trigger.oldMap.get(opportunity.Id).Application_Status__c)
           ){
            opportunitiesAffected.add(opportunity);
        }
    }

    if (!opportunitiesAffected.isEmpty()) {
        for (Admissions_Opportunity__c application : [select Id, Name, (select Id, Name from Program_Plan_SubPlan__r) 
                                                      from Admissions_Opportunity__c
                                                      where Id in :opportunitiesAffected
                                                     ]) {
            if (application.Program_Plan_SubPlan__r.size() != 1) {
                Trigger.newMap.get(application.Id).Application_Status__c.addError('There must be one and only one record in the Program-Plan-SubPlan related list in order to set Application Status to Matriculated OR Completed.');
            }
        }
    }
*/
}
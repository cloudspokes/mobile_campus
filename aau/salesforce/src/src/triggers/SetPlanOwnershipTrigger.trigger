trigger SetPlanOwnershipTrigger on Program_Plan_SubPlan__c (before insert) {
/*
    Set<ID> applicationIds = new Set<ID>();
    for (Program_Plan_SubPlan__c plan : Trigger.new) {
        applicationIds.add(plan.Admissions_Opportunity__c);
    }

   Map<ID, Admissions_Opportunity__c> applicationMap = new Map<ID, Admissions_Opportunity__c>([select Id, Lead__r.OwnerId
                                                                                                from Admissions_Opportunity__c 
                                                                                               where Id in :applicationIds
                                                                                               ]);

    for (Program_Plan_SubPlan__c plan : Trigger.new) {
        if (applicationMap.get(plan.Admissions_Opportunity__c) != null) {
            if (applicationMap.get(plan.Admissions_Opportunity__c).Lead__c != null) {
                plan.OwnerId = applicationMap.get(plan.Admissions_Opportunity__c).Lead__r.OwnerId;
            }
        }
    }
*/    
}
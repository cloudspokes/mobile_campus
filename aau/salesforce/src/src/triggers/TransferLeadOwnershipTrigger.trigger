trigger TransferLeadOwnershipTrigger on Contact (after update) {
/*	
	Map<ID, Contact> transferredLeadMap = new Map<ID, Contact>();
	for (Contact lead : Trigger.new) {
		// if the owner changed, then modify the related list items
		if (lead.OwnerId != Trigger.oldMap.get(lead.Id).OwnerId) {
			transferredLeadMap.put(lead.Id, lead);
		}
	}

	if (!transferredLeadMap.isEmpty()) {
		Map<ID, Admissions_Opportunity__c> applicationMap = new Map<ID, Admissions_Opportunity__c>();
		List<Admissions_Opportunity__c> allApps = new List<Admissions_Opportunity__c>();
		
		for(List<Admissions_Opportunity__c> aoc : [select Id, Lead__r.OwnerId 
                                                   from Admissions_Opportunity__c 
                                                   where Lead__c in :transferredLeadMap.keySet()
                                                   and Application_Status__c != 'Completed'])
         {
         	allApps.addAll(aoc);
         }
         
         for(Admissions_Opportunity__c a : allApps)
         	applicationMap.put(a.Id, a);

		// update Program_Plan_SubPlan__c objects
		List<Program_Plan_SubPlan__c> allTransferredPlans = new List<Program_Plan_SubPlan__c>();
		for(List<Program_Plan_SubPlan__c> transferredPlans : [select Id, OwnerId, Admissions_Opportunity__c
						                                      from Program_Plan_SubPlan__c 
						                                      where Admissions_Opportunity__c in :applicationMap.keySet()])
         {
         	for (Program_Plan_SubPlan__c transferredPlan : transferredPlans) 
         	{
				transferredPlan.OwnerId = applicationMap.get(transferredPlan.Admissions_Opportunity__c).Lead__r.OwnerId;
			}	
			allTransferredPlans.addAll(transferredPlans);
         }
	
		if (!allTransferredPlans.isEmpty())
			update allTransferredPlans;
	}
*/	
}
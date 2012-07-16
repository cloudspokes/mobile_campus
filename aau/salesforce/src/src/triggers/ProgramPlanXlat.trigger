trigger ProgramPlanXlat on Program_Plan_SubPlan__c (before insert, before update) {

	ProgramPlanXlat xlat = new ProgramPlanXlat();
	
	if (Trigger.isUpdate) {
		for (Program_Plan_SubPlan__c plan : Trigger.New) {
            Program_Plan_SubPlan__c oldp = Trigger.oldMap.get(plan.Id);
            if (plan.Program__c != oldp.Program__c || 
            	plan.Plan__c != oldp.Plan__c || 
            	plan.Sub_Plan__c != oldp.Sub_Plan__c) 
            {
            	// Blank out the existing PeopleSoft external Id and 
            	// recalculate by calling 'repair'
            	plan.Psft_Plan_Id__c = null;
            }
        }
	}
	
	xlat.repair(Trigger.new);
	//Map<Boolean, List<Program_Plan_SubPlan__c>> repairResults = xlat.repair(Trigger.new);
	//System.assert(repairResults.get(False).size() == 0);
	
}
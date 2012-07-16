trigger ProgramPlanValue on Program_Plan_Value__c (after update) {

	List<Id> idsChanged = new List<Id>();
	List<Program_Plan_Value__c> updateSettings = new List<Program_Plan_Value__c>();
	
	for (Program_Plan_Value__c val : Trigger.new) {
		Program_Plan_Value__c oldVal = Trigger.oldMap.get(val.Id);
		if (val.Psft_Lookup_Id__c != oldVal.Psft_Lookup_Id__c ||
			val.Sfdc_Lookup_Id__c != oldVal.Sfdc_Lookup_Id__c) 
		{
			idsChanged.add(val.Id);
			updateSettings.add(val);
		}
	}

	if (!idsChanged.isEmpty()) {
		// Update all of the child records when parent values change
		List<Program_Plan_Value__c> children = [select Id,
													   Psft_Id__c,
													   Psft_Lookup_Id__c,
													   Sfdc_Lookup_Id__c
												from Program_Plan_Value__c 
												where Parent__c in :idsChanged];
		if (!children.isEmpty()) {
			update children; // workflow set to always re-evaluate on update
		}
	}
	
	if (!updateSettings.isEmpty()) {
		ProgramPlanXlat.updateSettings(updateSettings);
	}
	
}
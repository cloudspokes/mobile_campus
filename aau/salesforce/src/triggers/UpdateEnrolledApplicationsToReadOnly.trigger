trigger UpdateEnrolledApplicationsToReadOnly on Admissions_Opportunity__c (before insert, before update) {
	List<Admissions_Opportunity__c> opportunitiesAffected = new List<Admissions_Opportunity__c>();

	// check whether anyone is setting the Stick_Date_No_of_Units_Enrolled__c
	for (Admissions_Opportunity__c application : Trigger.new) {
		if (application.Stick_Date_No_of_Units_Enrolled__c != null
		    && (Trigger.isInsert || Trigger.oldMap.get(application.Id).Stick_Date_No_of_Units_Enrolled__c == null)
		   ){
			opportunitiesAffected.add(application);
		}
	}

	if (!opportunitiesAffected.isEmpty()) {
		AdmissionUtils.updateApplicationsRecordType( opportunitiesAffected
		                                           , 'Program-Plan-SubPlan (Read Only)'
		                                           , 'Admissions Opportunity (Read-Only)'
		                                           , 'Lead (Read Only)'
		                                           );
	}
}
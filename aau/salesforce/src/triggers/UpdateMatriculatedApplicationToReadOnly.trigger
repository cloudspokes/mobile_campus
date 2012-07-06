trigger UpdateMatriculatedApplicationToReadOnly on Admissions_Opportunity__c (before insert, before update) {
	List<Admissions_Opportunity__c> opportunitiesAffected = new List<Admissions_Opportunity__c>();

	// check whether anyone is setting the recruiting status to 'Applicant'
	for (Admissions_Opportunity__c application : Trigger.new) {
		if (application.Application_Status__c == 'Matriculated' 
		    && (Trigger.isInsert || Trigger.oldMap.get(application.Id).Application_Status__c != 'Matriculated')
		   ){
			opportunitiesAffected.add(application);
		}
	}

	if (!opportunitiesAffected.isEmpty()) {
		System.debug('opportunitiesAffected: ' + opportunitiesAffected);
		AdmissionUtils.updateApplicationsRecordType( opportunitiesAffected
		                                           , 'Program-Plan-SubPlan (Read Only)'
		                                           , 'Admissions Opportunity (Read-Only)'
		                                           , 'Lead (Read Only EXCEPT Bio-Demo)'
		                                           );
		System.debug('opportunitiesAffected (AFTER): ' + opportunitiesAffected);
	}
}
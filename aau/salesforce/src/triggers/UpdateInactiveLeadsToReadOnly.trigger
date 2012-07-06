trigger UpdateInactiveLeadsToReadOnly on Contact (before update) {
	List<Contact> leadsAffected = new List<Contact>();

	// check whether anyone is setting the recruiting status to 'Inactive'
	for (Contact lead : Trigger.new) {
		if (lead.Recruiting_Status__c == 'Inactive'
		    && Trigger.oldMap.get(lead.Id).Recruiting_Status__c != 'Inactive' 
		   ){
			leadsAffected.add(lead);
		}
	}

	if (!leadsAffected.isEmpty()) {
		AdmissionUtils.updateLeadsRecordType( leadsAffected
		                                    , 'Program-Plan-SubPlan (Read Only)'
		                                    , 'Admissions Opportunity (Read-Only)'
		                                    , 'Lead (Read Only)'
		                                    );
	}
}
trigger CloseActiveOpps on Contact (after update) {

	Set<ID> inactivedContacts = new Set<Id>();
	for (Contact c: Trigger.new) {
		if (c.Recruiting_Status__c == 'Inactive' || 
			c.Recruiting_Status__c =='Contacted - No Response') {
			Contact oldContact = Trigger.oldMap.get(c.Id);
			if (oldContact.Recruiting_Status__c != 'Inactive' &&
				oldContact.Recruiting_Status__c != 'Contacted - No Response') {
				inactivedContacts.add(c.ID);
			}
		}
	}
	
	if (!inactivedContacts.isEmpty()) {
		List<Admissions_Opportunity__c> openOpps = new List<Admissions_Opportunity__c>();
		openOpps = [select Id, Application_Status__c, Lead__c
					from Admissions_Opportunity__c
					where Lead__c in :inactivedContacts
					  and Application_Status__c = 'Active'];
		for (Admissions_Opportunity__c opp: openOpps) {
			opp.Application_Status__c = Trigger.newMap.get(opp.Lead__c).Recruiting_Status__c;
		}															 
		
		update openOpps;
	}
}
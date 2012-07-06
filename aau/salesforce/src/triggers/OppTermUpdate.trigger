trigger OppTermUpdate on Admissions_Opportunity__c (before insert, before update) {

	Map<String, List<Admissions_Opportunity__c>> oppsByTerm = new Map<String, List<Admissions_Opportunity__c>>();
	for(Admissions_Opportunity__c opp : Trigger.new) {
		if (opp.Term__c == null || opp.Term__r.Name != opp.Start_Term__c) {
			if (oppsByTerm.containsKey(opp.Start_Term__c)) {
				oppsByTerm.get(opp.Start_Term__c).add(opp);
			} else {
				oppsByTerm.put(opp.Start_Term__c, new List<Admissions_Opportunity__c>{opp});
			}
		}
	}
	
	if (!oppsByTerm.isEmpty()) {
		List<Term__c> terms = [select Id, Name 
								 from Term__c where Name in :oppsByTerm.keySet()];
		for (Term__c term : terms) {
			for (Admissions_Opportunity__c opp : oppsByTerm.get(term.Name)) {
				opp.Term__c = term.Id;
			}
		}
	}
}
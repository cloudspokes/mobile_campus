trigger SetPsftOppId on Admissions_Opportunity__c (before update, before insert, after update) {
	
	List<Admissions_Opportunity__c> oppsToUpdate = new List<Admissions_Opportunity__c>();
	for (Admissions_Opportunity__c opp : Trigger.new) {
		
		String psft_opp_id = opp.PeopleSoft_Student_Id__c + 
							 '|' + opp.Career__c.substring(0,2).toUpperCase();
							 
		if (opp.PeopleSoft_Application_ID__c != null){
			psft_opp_id = psft_opp_id + '|' + opp.PeopleSoft_Application_Id__c;
		}	
		
		if (psft_opp_id <> opp.Psft_Opp_Id__c) {
			opp.Psft_Opp_Id__c = psft_opp_id;
			oppsToUpdate.add(opp);
		}
									 
	}
	
	if (Trigger.isAfter && !oppsToUpdate.isEmpty()) {
		update oppsToUpdate;
	}

}
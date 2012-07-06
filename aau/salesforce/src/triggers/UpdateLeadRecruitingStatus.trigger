trigger UpdateLeadRecruitingStatus on Admissions_Opportunity__c (after insert, after update) {
    List<ID> applicantsAffected = new List<ID>();
//    List<ID> registeredAffected = new List<ID>();

    // determine users who are integration users 
    //Map<ID, User> integrationUserMap = new Map<ID, User>([select Id from User where Profile.Name = 'Integration']);

    // only Peoplesoft integration user can update
    //if (integrationUserMap.keySet().contains(UserInfo.getUserId())) {
	if (UserInfo.getProfileId() == '00e800000012o2gAAA') {
    	
        for (Admissions_Opportunity__c opportunity : Trigger.new) {

            // automatically set recruiting status to 'Applicant' if application status is Active
            if (opportunity.Application_Status__c == 'Active' 
                && (Trigger.isInsert || Trigger.oldMap.get(opportunity.Id).PeopleSoft_Application_ID__c == null)
                && opportunity.PeopleSoft_Application_ID__c != null
               ) {
                applicantsAffected.add(opportunity.Lead__c);
            }
/*
            if (opportunity.Current_No_of_Units_Enrolled__c != null
                && (Trigger.isInsert || Trigger.oldMap.get(opportunity.Id).Current_No_of_Units_Enrolled__c == null)
               ) {
                registeredAffected.add(opportunity.Lead__c);
            }
*/            
        }

        if (!applicantsAffected.isEmpty()) {
            List<Contact> updateLeads = new List<Contact>();
            for (Contact lead : [select Id, Name, Career_Latest_Opp__c, Recruiting_Status__c, Owner.UserRole.Name from Contact where Id in :applicantsAffected]) {
                if (lead.Recruiting_Status__c != 'Applicant' &&
                	lead.Recruiting_Status__c != 'Participant') {
                		if (lead.Career_Latest_Opp__c != 'NM') {
                    		lead.Recruiting_Status__c = 'Applicant';
                		} else {
                			lead.Recruiting_Status__c = 'Participant';
                		}

                    // if the lead owner is a telemarketer, then cancel the telemarketer assignment
                    if (lead.Owner.UserRole.Name == 'Telemarketer') {
                        lead.Telemarketer_Assignment_Cancelled__c = true;
                    }

                    updateLeads.add(lead);
                }
            }

            if (!updateLeads.isEmpty()) {
                update updateLeads;
            }
        }

/*
        // automatically set recruiting status to 'Registered' if current units enrolled is populated
        if (!registeredAffected.isEmpty()) {
            List<Contact> updateLeads = new List<Contact>();
            List<Exception_Log__c> exceptions = new List<Exception_Log__c>();
            for (Contact lead : [select Id, Name, Recruiting_Status__c, (select Id from Applications__r where Application_Status__c in ('Active')) from Contact where Id in :registeredAffected]) {
                if (lead.Applications__r.size() > 1) {
                    exceptions.add(new Exception_Log__c(Message__c = 'Error: More than 1 Active Admissions Opportunities exists for ' + lead));
                }
                else {
                    lead.Recruiting_Status__c = 'Registered';
                    updateLeads.add(lead);
                }
            }

            if (!updateLeads.isEmpty()) {
                update updateLeads;
            }

            if (!exceptions.isEmpty()) {
                insert exceptions;
            }
        }
*/    
    }
}
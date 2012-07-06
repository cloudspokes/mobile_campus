global class BatchRanking implements Schedulable, Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soql = 'Select Id, Calculate_Ranking__c, Country__c,' + 
                      ' Have_you_taken_classes_at_AAU_before__c, Name,' +
                      ' PeopleSoft_Person_ID__c, RecordTypeId,' +
                      ' Referral_Source__c, Ranking__c, Score__c,' +
                      ' Service_Indicators_Non_Editable__c,' +
                      ' State_Province__c, Transcript_Review_Completed__c,' +
                      ' (Select Id, IsDeleted, CampaignId, LeadId, ContactId, Status, HasResponded, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, FirstRespondedDate, Campaign.Name From CampaignMembers),' +
        			  ' (Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, Priority, ActivityType, IsClosed, IsAllDayEvent, DurationInMinutes, Location, Description, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, Category__c, Context__c, Method__c, Direction__c, PeopleSoft_Event_ID__c, Campus_Meeting_Type__c, Admin_Function__c, Marketing_Code__c, Career__c, Aid_Year__c, Comments_Category__c, Educator__c, Last_Modified_Date_Time_CALC__c, PeopleSoft_Owner__c From ActivityHistories)' +
                      ' from Contact where Calculate_Ranking__c = True' +
                      ' and PeopleSoft_Person_Id__c != null';
        return Database.getQueryLocator(soql);
    }
        
	global void execute(SchedulableContext sc) {
		BatchRanking b = new BatchRanking(); 
    	Database.executebatch(b);
	}
   
   global void execute(Database.BatchableContext BC, SObject[] batch) {
        Map<String, Contact> contacts = new Map<String, Contact>();
        Map<String, Contact> leadsToRank = new Map<String, Contact>();
        for (sObject s : batch) {
            Contact c = (Contact)s;
            c.Calculate_Ranking__c = False;
            contacts.put(c.Id, c);
            if(c.RecordTypeId == '012800000002dPnAAI' && c.PeopleSoft_Person_Id__c != null) {
                leadsToRank.put(c.PeopleSoft_Person_Id__c, c);
            }
        }

        if (!leadsToRank.isEmpty()) {
            LeadScoreManager scorer = new LeadScoreManager();
            Map<String, Double> scores = scorer.scoreApplications(leadsToRank);
            Map<String, String> rankings = scorer.getRankings(scores);
            
            for (Contact lead : leadsToRank.values())
            {
                Contact c = contacts.get(lead.Id);
                c.Score__c = scores.get(c.PeopleSoft_Person_ID__c);
                c.Ranking__c = rankings.get(c.PeopleSoft_Person_ID__c);
            }
        }

        update contacts.values();
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}
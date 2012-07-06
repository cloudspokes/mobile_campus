/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class LeadScoreTest {

    static testMethod void scoreApplications() {
        Map<ID, Contact> apps = new Map<ID, Contact>();
        for(Contact c : [Select Name, FirstName, LastName, Service_Indicators_Non_Editable__c, Referral_Source__c, Recruiting_Status__c, Residency_Status__c, Start_Term_Latest_Opp__c, OwnerId,
	        						Country__c, Have_you_taken_classes_at_AAU_before__c, State_Province__c, (Select Id, IsDeleted, CampaignId, LeadId, ContactId, Status, HasResponded, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, FirstRespondedDate, Campaign.Name From CampaignMembers),
	        						 Transcript_Review_Completed__c, Recruiting_Center_Latest_Opp__c, Career_Latest_Opp__c, Application_Status_Latest_Opp__c,
	        						 (Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, Priority, ActivityType, IsClosed, IsAllDayEvent, DurationInMinutes, Location, Description, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, Category__c, Context__c, Method__c, Direction__c, PeopleSoft_Event_ID__c, Campus_Meeting_Type__c, Admin_Function__c, Marketing_Code__c, Career__c, Aid_Year__c, Comments_Category__c, Educator__c, Last_Modified_Date_Time_CALC__c, PeopleSoft_Owner__c From ActivityHistories)
	        						from Contact where Recruiting_Status__c = 'Prospect' and Country__c in ('United States', 'China') LIMIT 5])
	    {
	    	apps.put(c.id, c);	
	    }
	    
	    if(!apps.isEmpty())
	    {
	    	LeadScore scorer = new LeadScore();
	    	scorer.scoreApplications(apps);
	    	CriterionScoreHelper.convertYesNoToBoolean('yes');
	    	CriterionScoreHelper.scoreCriterion(CriterionScoreHelper.ISIR, apps);
	    }
	    
	    
	   
    }
}
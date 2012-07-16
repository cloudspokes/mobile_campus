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
private class CalculateRankingTriggerTest {
	
	static testMethod void testLeadScoreManager() {
        Map<String, Contact> leadsToRank = new Map<String, Contact>([Select Id, Calculate_Ranking__c, Country__c,
        															        Have_you_taken_classes_at_AAU_before__c, Name, 
        															        PeopleSoft_Person_ID__c, RecordTypeId, 
        															        Referral_Source__c, Ranking__c, Score__c,
																			Service_Indicators_Non_Editable__c, 
        															        State_Province__c, Transcript_Review_Completed__c,
        															        (Select Id, IsDeleted, CampaignId, LeadId, ContactId, Status, HasResponded, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, FirstRespondedDate, Campaign.Name From CampaignMembers),
        															        (Select Id, AccountId, WhoId, WhatId, Subject, IsTask, ActivityDate, OwnerId, Status, Priority, ActivityType, IsClosed, IsAllDayEvent, DurationInMinutes, Location, Description, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, Category__c, Context__c, Method__c, Direction__c, PeopleSoft_Event_ID__c, Campus_Meeting_Type__c, Admin_Function__c, Marketing_Code__c, Career__c, Aid_Year__c, Comments_Category__c, Educator__c, Last_Modified_Date_Time_CALC__c, PeopleSoft_Owner__c From ActivityHistories)
        															 from Contact 
        															 where PeopleSoft_Person_Id__c != null limit 10]);

        LeadScoreManager scorer = new LeadScoreManager();
		Map<String, Double> scores = scorer.scoreApplications(leadsToRank);
		Map<String, String> rankings = scorer.getRankings(scores);
	}
	/**
	 * Use this method to test scores on an adhoc basis
	 */
	 /*
	static testMethod void printUsersScorecard() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = [select Service_Indicators_Non_Editable__c, Name, FirstName, Referral_Source__c, LastName, Status__c, Recruiting_Status__c, Residency_Status__c, Start_Term_Latest_Opp__c,
	        						  Transcript_Review_Completed__c, Have_you_taken_classes_at_AAU_before__c, Country__c, State_Province__c, Recruiting_Center_Latest_Opp__c, Career_Latest_Opp__c, Application_Status_Latest_Opp__c, RecordTypeId
	        						 from Contact where id = '0038000000biQ4a'];
	        c.phone = '9999';
	        update c;						 
	        
	        //Map<Id, Contact> cs = new Map<Id, Contact>();
	        //cs.put(c.Id, c);
	        //LeadScore scorer = new LeadScore();
	        //System.debug('Manual Scorecard test for '+c.FirstName +' '+c.LastName);
	        //Map<Id, Double> results = scorer.scoreApplications(cs);
	        System.AssertEquals(1,1);
	        
        }
               
        
      }
*/

/** gsl
static testMethod void testNoServiceIndicators() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Referral_Source__c='Tour', LastName='TestNoServ', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						 State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						 PeopleSoft_Person_Id__c='FakeId');
	        //create new application
	        insert c; 
        }
        Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestNoServ'];
    	c2.Country__c='United States';
    	update c2;
    	Test.startTest();
        Database.executeBatch(new BatchRanking());
        Test.stopTest();
        
  	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestNoServ'];
        
        System.AssertEquals('Fair', c3.Ranking__c);
      }
     
	static testMethod void testLowRanking() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', LastName='TestLow', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						 State_Province__c='GA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						 PeopleSoft_Person_Id__c='FakeId');
	        //create new application
	        insert c; 
        }
      Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestLow'];
    	c2.Country__c='United States';
    	update c2;
        Test.startTest();
    	Database.executeBatch(new BatchRanking());
    	Test.stopTest();
  	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestLow'];
        
        System.AssertEquals('Low', c3.Ranking__c);
      }

	static testMethod void testStrongRanking() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Service_Indicators_Non_Editable__c='Eligible for GI Bill;', Referral_Source__c='Tour', LastName='TestStrong', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						  State_Province__c='CA', Have_you_taken_classes_at_AAU_before__c='Yes', Transcript_Review_Completed__c=true, Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						  PeopleSoft_Person_Id__c = 'FakeId');
	        //create new application
	        insert c; 
        }
        
    	Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestStrong'];
    	c2.Country__c='United States';
    	update c2;
    	
        Test.startTest();
    	Id BatchId = Database.executeBatch(new BatchRanking());
    	Test.stopTest();
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :batchId];
		System.debug('\n\nFinal results are: '+a);
		//gsl System.AssertEquals('Completed', a.status);
		//gsl System.AssertEquals(0, a.NumberOfErrors);
		
  	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestStrong'];
        
        System.AssertEquals('Strong', c3.Ranking__c); 
      }
      
      static testMethod void testFairRanking() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Service_Indicators_Non_Editable__c='Eligible for GI Bill;', Referral_Source__c='Tour', LastName='TestFair', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						  State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						  PeopleSoft_Person_Id__c= 'FakeId');
	        //create new application
	        insert c; 
        }
       	Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestFair'];
    	c2.Country__c='United States';
    	update c2;
    	Test.startTest(); 
        Database.executeBatch(new BatchRanking());
		Test.stopTest();
		
  	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestFair'];
        
        System.AssertEquals('Fair', c3.Ranking__c); 
      }
gsl **/
      /*
      static testMethod void testRankingWithCampaigns() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Service_Indicators_Non_Editable__c='Eligible for GI Bill\n', Referral_Source__c='Tour', LastName='TestCampaigns', Status__c='Active', Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 2009 Summer',
	        						 State_Province__c='CA', Have_you_taken_classes_at_AAU_before__c='Yes', Transcript_Review_Completed__c=true, Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
	        
        }
        
        
         Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestCampaigns'];
    	/*
        List<CampaignMember> members = new List<CampaignMember>(); 
        
        Integer i = 0;
        for (Campaign c : [Select c.Name, c.Id From Campaign c])
        {
        	c2.CampaignMembers[i].CampaignId = c.Id;
        	c2.CampaignMembers[i].ContactId = c2.Id;
        	i++;
        }
      
      
      update c2;
      
  	
    	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestCampaigns'];
        System.AssertEquals('Strong', c3.Ranking__c); 
      }
      */
      /*
      static testMethod void testRankingWithActivities() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Service_Indicators_Non_Editable__c='Eligible for GI Bill\n', Referral_Source__c='Tour', LastName='TestStrong', Status__c='Active', Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Have_you_taken_classes_at_AAU_before__c='Yes', Transcript_Review_Completed__c=true, Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        
	        insert c;
	        
	        //create/add activities 
	        ActivityHistory ah = new ActivityHistory();
	     
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestStrong'];
    	c2.Background__c = 'test run';
    	update c2;
  
  	Contact c3 = [select Id, Ranking__c, FirstName, OwnerId from Contact where FirstName = 'Score' And LastName='TestStrong'];
        
        System.AssertEquals('Fair', c3.Ranking__c); 
      }
      */

static testMethod void testBatchRanking() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Referral_Source__c='Tour', LastName='TestNoServ', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						 State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						 PeopleSoft_Person_Id__c='FakeIda');
	        //create new application
	        insert c; 
        }
        Contact c2a = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c='FakeIda'];
    	c2a.Country__c='United States';
    	update c2a;
    	
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', LastName='TestLow', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						 State_Province__c='GA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						 PeopleSoft_Person_Id__c='FakeIdb');
	        //create new application
	        insert c; 
        }
      Contact c2b = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c='FakeIdb'];
    	c2b.Country__c='United States';
    	update c2b;
    	
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Score', Service_Indicators_Non_Editable__c='Eligible for GI Bill;', Referral_Source__c='Tour', LastName='TestStrong', Status__c='Active', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1090 | 2010 Fall',
	        						  State_Province__c='CA', Have_you_taken_classes_at_AAU_before__c='Yes', Transcript_Review_Completed__c=true, Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						  PeopleSoft_Person_Id__c = 'FakeIdc');
	        //create new application
	        insert c; 
        }
        
    	Contact c2c = [select Id, Ranking__c, Background__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c = 'FakeIdc'];
    	c2c.Country__c='United States';
    	update c2c;
    	    	
    	Test.startTest();
        Database.executeBatch(new BatchRanking());
        Test.stopTest();
        
  	Contact c3a = [select Id, Ranking__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c='FakeIda'];
        
        //System.AssertEquals('Fair', c3a.Ranking__c);
        
  	Contact c3b = [select Id, Ranking__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c='FakeIdb'];
        
        //System.AssertEquals('Low', c3b.Ranking__c);        

  	Contact c3c = [select Id, Ranking__c, FirstName, OwnerId from Contact where PeopleSoft_Person_Id__c='FakeIdc'];
        
        //System.AssertEquals('Strong', c3c.Ranking__c);        
      }
}
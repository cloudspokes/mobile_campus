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
private class IneligibleAssignmentTriggerTest {

/*
    static testMethod void inquiryStatusDeactivateTest() 
    {
    	TermAssignment__c t = new TermAssignment__c();
    	t.Admissions_Officer__c
         User u1 = [select Id from User where alias='tuser'];
         u1.No_of_Leads_in_Inquiry_Status__c = 51;
         u1.Eligible_for_Lead_Assignment__c = true;
         
         update u1;
         
         User u2 = [select Id, Eligible_for_Lead_Assignment__c from User where alias='tuser'];
         System.assertEquals(false, u2.Eligible_for_Lead_Assignment__c);
    }
    
    static testMethod void activeLeadsDeactivateTest() 
    {
         User u1 = [select Id from User where alias='tuser'];
         u1.No_of_Active_Leads_Assigned__c  = 888;
         u1.Eligible_for_Lead_Assignment__c = true;
         
         update u1;
         
         User u2 = [select Id, Eligible_for_Lead_Assignment__c from User where alias='tuser'];
         System.assertEquals(false, u2.Eligible_for_Lead_Assignment__c);
    }
  */  
}
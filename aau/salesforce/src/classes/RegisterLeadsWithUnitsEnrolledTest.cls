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
private class RegisterLeadsWithUnitsEnrolledTest {

    static testMethod void testUnitsEnrolled() {
        //first create a lead, er contact
	        Contact c = new Contact(FirstName='Test', LastName='Test', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						PeopleSoft_Person_Id__c='FakeId');
	        						
	        insert c; 
	        
	        //create an admin opty
	        Admissions_Opportunity__c adopp = new Admissions_Opportunity__c(Lead__c=c.id, Career__c = 'Undergraduate', Start_Term__c='1590 | 2015 Fall', Recruiting_Center__c='Onsite', Current_No_of_Units_Enrolled__c='10');
	        insert adopp;
	        
	        //make sure the recruiting status has been updated.
	        Contact c1 = [select Recruiting_Status__c from Contact where id = :c.id];
	        System.assertEquals('Registered', c1.Recruiting_Status__c);
	 }
	 
	  static testMethod void testUnitsEnrolledWithHalfUnits() {
        //first create a lead, er contact
	        Contact c = new Contact(FirstName='Test', LastName='Test', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						PeopleSoft_Person_Id__c='FakeId');
	        						
	        insert c; 
	        
	        //create an admin opty
	        Admissions_Opportunity__c adopp = new Admissions_Opportunity__c(Lead__c=c.id, Career__c = 'Undergraduate', Start_Term__c='1590 | 2015 Fall', Recruiting_Center__c='Onsite', Current_No_of_Units_Enrolled__c='3.5');
	        insert adopp;
	        
	        //make sure the recruiting status has been updated.
	        Contact c1 = [select Recruiting_Status__c from Contact where id = :c.id];
	        System.assertEquals('Registered', c1.Recruiting_Status__c);
	 }
}
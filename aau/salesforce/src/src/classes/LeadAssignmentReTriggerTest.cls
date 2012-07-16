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
private class LeadAssignmentReTriggerTest {



    static testMethod void testLeadReAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestReassignment', Status__c='Active', Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, Telemarketer_Assignment_Cancelled__c, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestReassignment'];
        
        c2.Telemarketer_Assignment_Cancelled__c = true;
         update c2;
         
        User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
       
        System.AssertNotEquals('Telemarketer (CARS)', u2.Admissions_Group__c);
      }
    
}
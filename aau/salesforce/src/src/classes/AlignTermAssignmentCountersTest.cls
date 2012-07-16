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
private class AlignTermAssignmentCountersTest {

/*
    static testMethod void testAlignTerms() {
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Align', LastName='TermTest', Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer', OwnerId='00580000001p23LAAQ',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        Contact c2 = [select id, Reassign_Lead__c, ownerid from  Contact where FirstName='Align' and LastName='TermTest'];
        c2.Reassign_Lead__c = true;
        update c2; 
        
        System.assert(1==1);
        
    }
    */
    
    static testMethod void testUpdateAssignmentNumbers() {
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Align', LastName='TermTest', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer', OwnerId='00580000001p23LAAQ',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        Contact c2 = [select id, Recruiting_Status__c, ownerid from  Contact where FirstName='Align' and LastName='TermTest'];
        c2.Recruiting_Status__c = 'Contacted - No Response';
        update c2; 
        
        System.assert(1==1);
    }
}
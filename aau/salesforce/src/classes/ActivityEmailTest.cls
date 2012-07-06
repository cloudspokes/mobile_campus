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
private class ActivityEmailTest {

    static testMethod void testEventEmail() {
		User rep = [select ID from User where alias='telemktr'];
		Contact c = [select ID from Contact where OwnerId = :rep.Id limit 1];
		
        System.RunAs(rep) {
	        Event e = new Event(WhoId = c.Id,Subject='Student Meeting - In Person', 
	        					OwnerId=rep.Id, DurationInMinutes = 30,
	        					ActivityDateTime = Datetime.newInstance(2012, 12, 01, 12, 0, 0),
	        					StartDateTime = Datetime.newInstance(2012, 12, 01, 12, 0, 0),
	        					Send_Email__c = 'Test Event Email');
    	    insert e;
        }
        
    }

    static testMethod void testTaskEmail() {
		User rep = [select ID from User where alias='telemktr'];
		Contact c = [select ID from Contact where OwnerId = :rep.Id limit 1];
		
        System.RunAs(rep) {
	        Task t = new Task(WhoId = c.Id,Subject='ATO - Department Approved Waiver-Substitution Results', 
	        				  OwnerId=rep.Id, Send_Email__c = 'Test Task Email');
    	    insert t;
        }
        
    }

}
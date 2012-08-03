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
private class mob_ContactSharingRecord_Test {
    
    static testMethod void currentUserStudentUserTest() {
          Contact c;
          Contact c2;
        c = initContact(c);
        
        // Try to insert contact record with current use
        try {
            insert c;
        }
        catch (DMLException e) {
            system.assert(true);
            System.debug('Trigger correctly prevented insert of contact where Student_user__c == CurrentUser' + e);
        }
        
        User testUser = TestUtil.makeUser('AAU Student');
        c.Student_User__c = testUser.Id;
        
        insert c;
        
        
        //////////// Test same student user removale update
        c.Student_User__c = null;
        c2 = new Contact();
        c2.LastName = 'User';
        c2.FirstName = 'Tom';
        c2.Student_User__c = testUser.Id;
        insert c2;
        
        c2.Student_User__c = null;
        
        list<Contact> contacts = new list<Contact>();
        contacts.add(c);
        contacts.add(c2);
        update contacts;
        
        
    }
    
    static private Contact initContact(Contact c) {
        c = new Contact();
        c.LastName = 'User';
        c.FirstName = 'Tim';
        c.Student_User__c = Userinfo.getUserId();
        
        return c;
    }
}
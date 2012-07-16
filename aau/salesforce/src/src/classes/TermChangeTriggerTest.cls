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
private class TermChangeTriggerTest {

    static testMethod void testTermChange() {
        
        List<Term__c> terms = new List<Term__c>();
        /*
        Term__c oldt = [Select t.Name, t.Is_Current_Term__c From Term__c t where t.Is_Current_Term__c = true];
        oldt.Is_Current_Term__c = false;
        terms.add(oldt);
        */
        
        Term__c newt = [Select t.Name, t.Is_Current_Term__c From Term__c t where t.Name = '1190 | 2011 Fall'];
        newt.Is_Current_Term__c = false;
        terms.add(newt);
        
        update terms;
            
    }

    static testMethod void testTermChange2() {
        
        List<Term__c> terms = new List<Term__c>();
        /*
        Term__c oldt = [Select t.Name, t.Is_Current_Term__c From Term__c t where t.Is_Current_Term__c = true];
        oldt.Is_Current_Term__c = false;
        terms.add(oldt);
        */
        
        Term__c newt = [Select t.Name, t.Is_Current_Term__c From Term__c t where t.Name = '1090 | 2010 Fall'];
        newt.Is_Current_Term__c = false;
        terms.add(newt);
        
        update terms;
            
    }
}
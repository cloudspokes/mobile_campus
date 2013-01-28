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
private class mob_TeletracInfoRest_Test {

    static testMethod void testTeletracRest() {
        User aaUStudent = mob_TestUtil.makeUser('AAU Student - Platform');            // Create user for test
        System.runAs(aaUStudent) {
        	
        	//init custom settings for testing
        	initCustomSettings();
        	
        	map<String, String> teletracInfoResult = new map<String, String>();     // Create Map for storing results
        	
        	teletracInfoResult = mob_teletracInfoRest.returnTeletracInfo();
        	
        	if(teletracInfoResult.containsKey('Account')) {
        		System.assert(true, '*** Response contains Account key');
        		if(teletracInfoResult.get('Account') != null) {
        			System.assert(true, '*** Response value for key Account not null ' + teletracInfoResult.get('Account'));
        		}
        		else {
        			System.assert(false, '*** Response value for key Account is null');
        		}
        	}
        	else {
        		System.assert(false, '*** Response does not contain Account key');
        	}
        	
        	if(teletracInfoResult.containsKey('Username')) {
            System.assert(true, '*** Response contains Username key');
            if(teletracInfoResult.get('Username') != null) {
              System.assert(true, '*** Response value for key Username not null ' + teletracInfoResult.get('Username'));
            }
            else {
              System.assert(false, '*** Response value for key Username is null');
            }
          }
          else {
            System.assert(false, '*** Response does not contain Username key');
          }
        
	        if(teletracInfoResult.containsKey('Password')) {
	            System.assert(true, '*** Response contains Password key');
	            if(teletracInfoResult.get('Password') != null) {
	              System.assert(true, '*** Response value for key Password not null ' + teletracInfoResult.get('Password'));
	            }
	            else {
	              System.assert(false, '*** Response value for key Password is null');
	            }
	          }
	        else {
	            System.assert(false, '*** Response does not contain Password key');
	        }
	        
	        if(teletracInfoResult.containsKey('RefreshRate')) {
	            System.assert(true, '*** Response contains RefreshRate key');
	            if(teletracInfoResult.get('RefreshRate') != null) {
	              System.assert(true, '*** Response value for key RefreshRate not null ' + teletracInfoResult.get('RefreshRate'));
	            }
	            else {
	              System.assert(false, '*** Response value for key RefreshRate is null');
	            }
	          }
	        else {
	            System.assert(false, '*** Response does not contain RefreshRate key');
	        }
    } // System.runAs
  }// testTeletracRest
  
  private static void initCustomSettings() {
  	//init custom settings
  	mob_Student__c testSettings = new mob_Student__c(Name = 'TestValues');
  	
  	testSettings.Teletrac_Account__c = '123456';
  	testSettings.Teletrac_Username__c = 'TestUsername';
  	testSettings.Teletrac_Password__c = 'TestPassword';
  	testSettings.Bus_Refresh_Rate__c = 30000;
  	
  	insert testSettings;
  	
  }
}// end of class
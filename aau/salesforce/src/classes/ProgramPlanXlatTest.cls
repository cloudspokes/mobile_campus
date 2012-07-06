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
private class ProgramPlanXlatTest {

    static testMethod void testProgramPlanValue() {
    	Test.startTest();
    	
    	RecordType recordType = [select Id from RecordType where SobjectType = 'Program_Plan_Value__c' and DeveloperName = 'Program'];
 		Program_Plan_Value__c progVal = new Program_Plan_Value__c(Name='Test Program', 
 																  RecordTypeId=recordType.Id, 
 																  Psft_Id__c='TEST1');
 		insert progVal;
 		
    	recordType = [select Id from RecordType where SobjectType = 'Program_Plan_Value__c' and DeveloperName = 'Plan'];
 		Program_Plan_Value__c planVal = new Program_Plan_Value__c(Name='Test Plan', 
 																  RecordTypeId=recordType.Id, 
 																  Psft_ID__c='TEST2', 
 																  Parent__c=progVal.Id);
		insert planVal;
 		
    	recordType = [select Id from RecordType where SobjectType = 'Program_Plan_Value__c' and DeveloperName = 'SubPlan'];
 		Program_Plan_Value__c splanVal = new Program_Plan_Value__c(Name='Test SubPlan', 
 																   RecordTypeId=recordType.Id, 
 																   Psft_Id__c='TEST3', 
 																   Parent__c=planVal.Id);
		insert splanVal;

		progVal.Psft_ID__c = 'TEST1A';
		progVal.Name = 'Test Program-a';
		update progVal;
		
		Test.stopTest();
		
 		progVal = [select Name, Psft_Lookup_Id__c, Sfdc_Lookup_Id__c from Program_Plan_Value__c where Id = :progVal.Id];
 		planVal = [select Name, Psft_Lookup_Id__c, Sfdc_Lookup_Id__c from Program_Plan_Value__c where Id = :planVal.Id];
 		splanVal = [select Name, Psft_Lookup_Id__c, Sfdc_Lookup_Id__c from Program_Plan_Value__c where Id = :splanVal.Id];
 																   
		String expected = 'TEST1A'; 																   
		System.assert(progVal.Psft_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + progVal.Psft_Lookup_Id__c + '\'');

		expected = 'Test Program-a'; 																   
		System.assert(progVal.Sfdc_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + progVal.Sfdc_Lookup_Id__c + '\'');

		expected = 'TEST1A*TEST2'; 																   
		System.assert(planVal.Psft_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + planVal.Psft_Lookup_Id__c + '\'');

		expected = 'Test Program-a;Test Plan'; 																   
		System.assert(planVal.Sfdc_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + planVal.Sfdc_Lookup_Id__c + '\'');

		expected = 'TEST1A*TEST2*TEST3'; 																   
		System.assert(splanVal.Psft_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + splanVal.Psft_Lookup_Id__c + '\'');

		expected = 'Test Program-a;Test Plan;Test SubPlan'; 																   
		System.assert(splanVal.Sfdc_Lookup_Id__c == expected, 'Expected \'' + expected + '\', found \'' + splanVal.Sfdc_Lookup_Id__c + '\'');
		
		Map<String, ProgramPlanXlatPs2Sf__c> settings = ProgramPlanXlatPs2Sf__c.getall(); 
		for (Program_Plan_Value__c val : new List<Program_Plan_Value__c>{progVal, planVal, splanVal}) {
			System.assert(settings.containsKey(val.Psft_Lookup_Id__c));
			ProgramPlanXlatPs2Sf__c setting = settings.get(val.Psft_Lookup_Id__c); 
			System.assert(setting.Sfdc_Lookup_Id__c == val.Sfdc_Lookup_Id__c);
			System.assert(setting.Program_Plan_Value_ID__c == val.Id);
		}		 				
														   
    }
    
    static testMethod void testProgramPlanXlat() {
        List<Program_Plan_SubPlan__c> plans = [Select Id,        
													  Psft_Plan_Id__c,
													  Admissions_Opportunity__c, 
        											  Program__c, 
        											  Plan__c, 
        											  Sub_Plan__c 
        									   from Program_Plan_SubPlan__c
        									   where Sub_Plan__c = null 
        									   limit 10];
        ProgramPlanXlat xlat = new ProgramPlanXlat();
		Map<Boolean, List<Program_Plan_SubPlan__c>> repairResult = xlat.repair(plans);
		if (repairResult.get(True).size() > 0) {
			update repairResult.get(True);
		}
    }
    
    static testMethod void testProgramPlanXlatBatch() {
    	ProgramPlanXlatBatch xlat = new ProgramPlanXlatBatch('limit 10');
    	Test.startTest();
    	ID batchprocessid = Database.executeBatch(xlat);
    	Test.stopTest();
    }
    
}
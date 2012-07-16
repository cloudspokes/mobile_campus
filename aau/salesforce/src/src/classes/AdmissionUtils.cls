public class AdmissionUtils {
	public static void updateApplicationsRecordType (List<Admissions_Opportunity__c> applications, String planRecordTypeName, String applicationRecordTypeName, String leadRecordTypeName) {
		// get the read only record types
		List<String> nameList = new List<String>{planRecordTypeName, applicationRecordTypeName, leadRecordTypeName};

		// get the read only record types
		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
		for (RecordType recordType : [select Id, Name, SObjectType
		                              from RecordType 
		                              where SObjectType in ('Program_Plan_SubPlan__c', 'Admissions_Opportunity__c', 'Contact')
		                              and Name in :nameList
		                             ]) {
			recordTypeMap.put(recordType.SObjectType, recordType);
		}

		// use a Map to prevent the same Lead from being updated more than once (which would throw an Exception)
		Map<ID, Contact> leadsAffectedMap = new Map<ID, Contact>();
		for (Admissions_Opportunity__c opportunity : applications) {
			// note: this line assumes that this is a before trigger - therefore no update DML statement is used
			opportunity.RecordTypeId = recordTypeMap.get('Admissions_Opportunity__c').Id;

			leadsAffectedMap.put(opportunity.Lead__c, new Contact(Id = opportunity.Lead__c, RecordTypeId = recordTypeMap.get('Contact').Id));
		}

		if (!leadsAffectedMap.isEmpty()) 
			update leadsAffectedMap.values();

		List<String> validRecordTypes = new List<String>();
		validRecordTypes.add('012800000002dPnAAI');
		validRecordTypes.add('012800000002dKrAAI');
		validRecordTypes.add('012800000002dLxAAI');
		
		
		// make related plans associated with the affected leads read only 
		List<Program_Plan_SubPlan__c> relatedPlansAffected = new List<Program_Plan_SubPlan__c>();
		for (Program_Plan_SubPlan__c plan : [select Id, RecordTypeId 
											 from Program_Plan_SubPlan__c 
											 where Admissions_Opportunity__c != null And RecordTypeId != null And RecordTypeId in :validRecordTypes And
											 Admissions_Opportunity__c in :applications
											]) {
			plan.RecordTypeId = recordTypeMap.get('Program_Plan_SubPlan__c').Id;
			relatedPlansAffected.add(plan);
		}

		if (!relatedPlansAffected.isEmpty()) 
			update relatedPlansAffected;
	}

	public static void updateLeadsRecordType (List<Contact> contacts, String planRecordTypeName, String applicationRecordTypeName, String leadRecordTypeName) {
		// get the read only record types
		List<String> nameList = new List<String>{planRecordTypeName, applicationRecordTypeName, leadRecordTypeName};

		// get the read only record types
		Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
		for (RecordType recordType : [select Id, Name, SObjectType
		                              from RecordType 
		                              where SObjectType in ('Program_Plan_SubPlan__c', 'Admissions_Opportunity__c', 'Contact')
		                              and Name in :nameList
		                             ]) {
			recordTypeMap.put(recordType.SObjectType, recordType);
		}

		// set contact to read only
		for (Contact lead : contacts) {
			lead.RecordTypeId = recordTypeMap.get('Contact').Id;
		}

		// make all other applications associated with the affected leads read only also
		List<Admissions_Opportunity__c> relatedOpportunitiesAffected = new List<Admissions_Opportunity__c>();
		for (Admissions_Opportunity__c opportunity : [select Id from Admissions_Opportunity__c where Lead__c in :contacts]) {
			opportunity.RecordTypeId = recordTypeMap.get('Admissions_Opportunity__c').Id;
			relatedOpportunitiesAffected.add(opportunity);
		}

		if (!relatedOpportunitiesAffected.isEmpty()) 
			update relatedOpportunitiesAffected;

		// make all plans associated with the affected leads read only 
		List<Program_Plan_SubPlan__c> relatedPlansAffected = new List<Program_Plan_SubPlan__c>();
		for (Program_Plan_SubPlan__c plan : [select Id, RecordTypeId 
											 from Program_Plan_SubPlan__c 
											 where Admissions_Opportunity__c in :relatedOpportunitiesAffected
											]) {
			plan.RecordTypeId = recordTypeMap.get('Program_Plan_SubPlan__c').Id;
			relatedPlansAffected.add(plan);
		}

		if (!relatedPlansAffected.isEmpty()) 
			update relatedPlansAffected;
	}

	public static testmethod void testAdminUtils() {
		Contact lead = TestUtil.makeLead('Marc', 'Benioff');
		Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

		AdmissionUtils.updateApplicationsRecordType( new List<Admissions_Opportunity__c>{application}
		                                           , 'Program-Plan-SubPlan (Read Only)'
		                                           , 'Admissions Opportunity (Read-Only)'
		                                           , 'Lead (Read Only EXCEPT Bio-Demo)'
		                                           );

		AdmissionUtils.updateLeadsRecordType( new List<Contact>{lead}
		                                    , 'Program-Plan-SubPlan (Read Only)'
		                                    , 'Admissions Opportunity (Read-Only)'
		                                    , 'Lead (Read Only)'
		                                    );
	}
}
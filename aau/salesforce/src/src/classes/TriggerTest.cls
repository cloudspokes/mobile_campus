@isTest
private class TriggerTest {
	// Test UpdateRecruitingStatus (requirements #4 & #7) using an Integration user
	static testmethod void testUpdateRecruitingStatusWithIntegrationUser() {
		User integrationUser = TestUtil.makeUser('Integration');

		System.runAs(integrationUser) {
			try {
				Contact lead = TestUtil.makeLead('Marc', 'Benioff');
				Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

				// edit application
				application.Application_Status__c = 'Active';
				application.Current_No_of_Units_Enrolled__c = '15';
				update application;
			}
			catch (Exception e) {System.debug(e);}
		}
	}

	// Test UpdateRecruitingStatus (requirements #4 & #7) using a non-Integration user
	static testmethod void testUpdateRecruitingStatusWithNonIntegrationUser() {
		User nonIntegrationUser = TestUtil.makeUser('Standard User');

		System.runAs(nonIntegrationUser) {
			try {
				Contact lead = TestUtil.makeLead('Marc', 'Benioff');
				Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

				// edit application
				application.Application_Status__c = 'Active';
				update application;
			}
			catch (Exception e) {System.debug(e);}
		}
	}

	// Test ValidateMatriculatedOrCompletedApplication (requirements #5) 
	static testmethod void testValidateMatriculatedOrCompletedApplication() {
		try {
			Contact lead = TestUtil.makeLead('Marc', 'Benioff');
			Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

			// edit application
			application.Application_Status__c = 'Completed';
			update application;
		}
		catch (Exception e) {System.debug(e);}
	}

	// Test UpdateMatriculatedApplicationToReadOnly (requirements #6) 
	static testmethod void testUpdateMatriculatedApplicationToReadOnly() {
		try {
			Contact lead = TestUtil.makeLead('Marc', 'Benioff');
			Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

			// edit application
			application.Application_Status__c = 'Matriculated';
			update application;
		}
		catch (Exception e) {System.debug(e);}
	}

	// Test UpdateEnrolledApplicationsToReadOnly and UpdateInactiveLeadsToReadOnly(requirements #8) 
	static testmethod void testUpdateToReadOnly() {
		try {
			Contact lead = TestUtil.makeLead('Marc', 'Benioff');
			Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

			// test UpdateEnrolledApplicationsToReadOnly
			application.Stick_Date_No_of_Units_Enrolled__c = '15';
			update application;

			// test UpdateInactiveLeadsToReadOnly
			lead.Recruiting_Status__c = 'Inactive';
			update lead;
		}
		catch (Exception e) {System.debug(e);}
	}

	// Test UpdateLeadWithLatestActiveApplication(requirements #9) 
	static testmethod void testUpdateLeadWithLatestActiveApplication() {
		try {
			Contact lead = TestUtil.makeLead('Marc', 'Benioff');
			Admissions_Opportunity__c application = TestUtil.makeApplication(lead);

			// test recruiting status inactive
			lead.Recruiting_Status__c = 'Inactive';
			update lead;
		}
		catch (Exception e) {System.debug(e);}
	}

	// Test TransferLeadOwnershipTrigger and SetPlanOwnershipTrigger (requirements #12 and #13) 
	static testmethod void testLeadOwnership() {
		try {
			Contact lead = TestUtil.makeLead('Marc', 'Benioff');
			Admissions_Opportunity__c application = TestUtil.makeApplication(lead);
			Program_Plan_SubPlan__c plan = TestUtil.makePlan(application);

			// delete plan
			delete plan;
		}
		catch (Exception e) {System.debug(e);}
	}

	// Test ProgramPlanChangeToPSFT 
	static testmethod void testProgramPlanChange() {
		User nonIntegrationUser = TestUtil.makeUser('System Administrator');

		System.runAs(nonIntegrationUser) {
			try {
				Contact lead = TestUtil.makeLead('Marc', 'Benioff');
				Admissions_Opportunity__c application = new Admissions_Opportunity__c(Lead__c = lead.Id, Application_Status__c = 'Active', Career__c = 'NM', Current_No_of_Units_Enrolled__c = '0.000');
				insert application;
				Program_Plan_SubPlan__c plan = new Program_Plan_SubPlan__c(Admissions_Opportunity__c = application.Id);
				plan.Program__c = 'High School Art Experience';
				plan.Plan__c = 'Saturday/Summer Art Experience';
				
				insert plan;
				
				plan.Plan__c = 'AA Fine Arts - Sculpture';
				update plan;
					// delete plan
				delete plan;
			}
			catch (Exception e) {System.debug(e);}
		}
	}

	static testmethod void testCurrentOpp() {
		Contact lead = new Contact(FirstName = 'Marc', LastName = 'Benioff', 
								   PeopleSoft_Person_Id__c = '99999999',
								   Recruiting_Status__c = 'Inquiry', 
								   Residency_Status__c = 'U.S. Citizen', 
								   HomePhone = '415-555-1212', 
								   Career_Latest_Opp__c = 'Undergraduate');
		insert lead;
		
		Admissions_Opportunity__c opp = new Admissions_Opportunity__c(Lead__c = lead.id,
																	  Career__c = 'Undergraduate',
																	  Recruiting_Center__c = 'Onsite', 
																	  Application_Status__c = 'Active',
																	  Start_Term__c = '1030 | 2010 Spring');
		insert opp;

	}
	
	static testmethod void testInPersonMeetingConfirmation() {
		Contact lead = new Contact(FirstName = 'Marc', LastName = 'Benioff', 
								   PeopleSoft_Person_Id__c = '99999999',
								   Recruiting_Status__c = 'Inquiry', 
								   Residency_Status__c = 'U.S. Citizen', 
								   HomePhone = '415-555-1212', 
								   Career_Latest_Opp__c = 'Undergraduate');
		insert lead;
		Date today = Date.today();
		Event event = new Event(whoId = lead.ID, 
								Subject='Student Meeting - In Person',
								StartDateTime = today,
								DurationInMinutes = 60);
		insert event;		
	}
	
}
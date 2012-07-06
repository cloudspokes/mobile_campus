public class TestUtil {
	public static User getUserByUsername(String username) {
		User user = [select Id, Alias, Email, LastName, Profileid
		                  , Username, CommunityNickname, EmailEncodingKey
		                  , LanguageLocaleKey
		             from User 
		             where Username = :username
		            ];
		return user;
	}

	public static User getUserById(ID userId) {
		User user = [select Id, Alias, Email, LastName, Profileid
		                  , Username, CommunityNickname, EmailEncodingKey
		                  , LanguageLocaleKey
		             from User 
		             where Id = :userId
		            ];
		return user;
	}

	public static Contact makeLead(String firstName, String lastName) {
		Contact contact = new Contact(LastName = lastName, FirstName = firstName, Recruiting_Status__c = 'Applicant' );
		insert contact;
		return contact;
	}

	public static Admissions_Opportunity__c makeApplication(Contact lead) {
		return makeApplication(lead, null, 'Undergraduate', null);
	}

	public static Admissions_Opportunity__c makeApplication(Contact lead, String applicationStatus, String career, String unitsEnrolled) {
		Admissions_Opportunity__c application = new Admissions_Opportunity__c(Lead__c = lead.Id, Application_Status__c = applicationStatus, Career__c = career, Current_No_of_Units_Enrolled__c = unitsEnrolled);
		insert application;
		return application;
	}

	public static Program_Plan_SubPlan__c makePlan(Admissions_Opportunity__c application) {
		Program_Plan_SubPlan__c plan = new Program_Plan_SubPlan__c(Admissions_Opportunity__c = application.Id);
		insert plan;
		return plan;
	}

	public static User makeUser(String profileName) {
		return makeUser(profileName, 'Testing', 'en_US', 'America/Los_Angeles');
	}

	public static User makeUser(String profileName, String lastName, String locale, String timezone) {
		Profile profile = [select Id, Name 
		                   from Profile 
		                   where Name = :profileName
		                  ];

		String name = 'test' + Math.random() + '@example.org';

		User user = new User( Alias = 'testuser'
		                    , Email = name
		                    , EmailEncodingKey = 'UTF-8'
		                    , LastName = lastName
		                    , LanguageLocaleKey = locale
		                    , LocalesIdKey = locale
		                    , ProfileId = profile.id
		                    , TimezonesIdKey = timezone
		                    , UserName = name
		                    );
		insert user;

		return user;
	}

	public static testmethod void testTestUtil() {
		User testUser = TestUtil.makeUser('Standard User');
		testUser = TestUtil.getUserById(testUser.Id);
		testUser = TestUtil.getUserByUsername(testUser.Username);

		Contact lead = TestUtil.makeLead('Marc', 'Benioff');
		Admissions_Opportunity__c application = TestUtil.makeApplication(lead);
	}
}
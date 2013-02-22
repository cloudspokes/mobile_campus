public class mob_TestUtil {
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
        //Contact contact = new Contact(LastName = lastName, FirstName = firstName, Recruiting_Status__c = 'Applicant' );
        Contact contact = new Contact(LastName = lastName, FirstName = firstName);
        insert contact;
        return contact;
    }

    public static User makeUser(String profileName) {
        return makeUser(profileName, 'Testing', 'en_US', 'America/Los_Angeles');
    }

    public static User makeUser(String profileName, String lastName, String locale, String timezone) {
        Profile profile = [select Id, Name 
                           from Profile 
                           where Name = :profileName
                          ];

        String name = 'test' + Math.random() + '@academyart.edu';

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

    /*
      Methods Added by Virendra for test Classes of AAU Mobile
    */
    public static ps_Term__c createNewTerm(String termCode,String termName){
        ps_Term__c term = new ps_Term__c();
        term.Start_Date__c = System.today().addDays(-10);
        term.End_Date__c = System.today().addDays(10);
        term.Term_Code__c = termCode;
        term.name = termName; 
        insert term;
        return term;
    }

	//For ClassHistory
    public static ps_Term__c createOldTerm(String termCode,String termName){
        ps_Term__c term = new ps_Term__c();
        term.Start_Date__c = System.today().addDays(-30);
        term.End_Date__c = System.today().addDays(-10);
        term.Term_Code__c = termCode;
        term.name = termName; 
        insert term;
        return term;
    }
    
    public static ps_Class__c createClass(String termId,String className,String subject,String CatalogNbr,String section,
                                          String title,String component,String extId){
        ps_Class__c psClass = new ps_Class__c();
        psClass.Term__c = termId;
        psClass.name = className;
        psClass.Subject__c =  subject;
        psClass.Catalog_Nbr__c =  CatalogNbr;
        psClass.Class_Section__c =  section;
        psClass.Course_Title__c = title;
        psClass.Course_Component__c=component;
        psClass.Psft_Ext_Id__c=extId;
        
        insert psClass;
        return psClass;
    }
    
    public static ps_Class_Meeting__c createClassMeeting(String classId,String name,Integer meetingNo,String extId){
        ps_Class_Meeting__c psClassMeeting = new ps_Class_Meeting__c();
        psClassMeeting.Class_Section__c = classId;
        psClassMeeting.Name = name;
        psClassMeeting.Class_Meeting_Number__c= meetingNo;
        psClassMeeting.Psft_Ext__c = extId;
        psClassMeeting.End_Date__c = System.today().addDays(10);
        psClassMeeting.Start_Date__c = System.today().addDays(10);
        psClassMeeting.Monday__c = true;
        psClassMeeting.Wednesday__c = true;
        psClassMeeting.Friday__c = true;
        insert psClassMeeting;
        return psClassMeeting;
    }

	//For ClassHistory
    public static ps_Class_Meeting__c createOldClassMeeting(String classId,String name,Integer meetingNo,String extId){
        ps_Class_Meeting__c psClassMeeting = new ps_Class_Meeting__c();
        psClassMeeting.Class_Section__c = classId;
        psClassMeeting.Name = name;
        psClassMeeting.Class_Meeting_Number__c= meetingNo;
        psClassMeeting.Psft_Ext__c = extId;
        psClassMeeting.Start_Date__c = System.today().addDays(-30);
        psClassMeeting.End_Date__c = System.today().addDays(-10);
        psClassMeeting.Monday__c = true;
        psClassMeeting.Wednesday__c = true;
        psClassMeeting.Friday__c = true;
        insert psClassMeeting;
        return psClassMeeting;
    }
    
    public static ps_Enrollment__c createEnrollment(String classId,String name,String studentId){
        ps_Enrollment__c psEnrollment = new ps_Enrollment__c();
        psEnrollment.Class_Section__c = classId;
        psEnrollment.Name = name;
        psEnrollment.Student__c = studentId;
        psEnrollment.Enrollment_Status__c = 'E';
        insert psEnrollment;
        return psEnrollment;
    }
    
    public static Bus_Route__c createBusRoute(String name){
        Bus_Route__c busRoute = new Bus_Route__c();
        busRoute.name = name;
        insert busRoute;
        return busRoute;
    }
    
    public static Bus_Stop__c createBusStop(String name,Double lat,Double longitute){
        Bus_Stop__c busStop = new Bus_Stop__c();
        busStop.name = name;
        busStop.Active__c = true;
        busStop.Lat__c = lat;
        busStop.Long__c = longitute;
        busStop.High_Fidelity_Waypoint__c = false; 
        busStop.Order__c = 0;
        insert busStop;
        return busStop;
    }

    public static Bus_Stop_Schedule__c createBusSchedule(id stop, id route, Integer ord, String tim){
        Bus_Stop_Schedule__c schedule = new Bus_Stop_Schedule__c();
        schedule.Bus_Route__c = route;
        schedule.Bus_Stop__c = stop;
        schedule.Sub_Route__c = '0';
        schedule.name = 'test' + ord;
        schedule.Order__c = ord;
        schedule.Time__c = tim;
        insert schedule;
        return schedule;
    }
    
    public static Bus_Stops_Routes__c createBusStopRoute(id stop, id route, Integer ord){
    	Bus_Stops_Routes__c stoproute = new Bus_Stops_Routes__c();
    	stoproute.Bus_Route__c = route;
    	stoproute.Bus_Stop__c = stop;
    	stoproute.name = 'test' + ord;
    	stoproute.Stop_Order__c =  ord;
    	insert stoproute;
    	return stoproute;
    }
    
    public static testmethod void testTestUtil() {
        User testUser = mob_TestUtil.makeUser('Standard User');
        testUser = mob_TestUtil.getUserById(testUser.Id);
        testUser = mob_TestUtil.getUserByUsername(testUser.Username);

        Contact lead = mob_TestUtil.makeLead('Marc', 'Benioff');
        //Admissions_Opportunity__c application = mob_TestUtil.makeApplication(lead);
    }
    
    
}
@RestResource(urlMapping='/classSchedule/*')
global with sharing class mob_StudentRest {

    @HttpGet
	global static PsEnrollments getEnrollments(RestRequest req, RestResponse res) {
		String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    	PsEnrollments psEnrlMents = new PsEnrollments();
		psEnrlMents.startDate = date.today();
		psEnrlMents.lastDate = date.today()+7;
		
		psEnrlMents.mobStudentsEnrolled = new Map<String,mobStudentEnrolled>();
		psEnrlMents.classMeetings = new Map<String,ClassMeeting>();
		 
		Set<Id> enrolledClasses = new Set<Id>();
		if(contactId!=null && contactId.startsWith('005')){
			for(ContactShare conShare :[Select contactid from ContactShare where UserOrGroupId =:contactId and rowcause='Manual']){
				contactId = conShare.ContactId;
			}
		}  
	    for(ps_Enrollment__c ps_Enrolmnt:[SELECT Id,Class_Section__c,Student__r.Id,Student__r.Name,Class_Section__r.Name,Class_Section__r.Course_Description__c,Class_Section__r.Catalog_Nbr__c, Class_Section__r.Term__c,Class_Section__r.Term__r.End_Date__c From ps_Enrollment__c 
	               where Student__c =: contactId AND Enrollment_Status__c = 'Enrolled' AND Class_Section__r.Term__r.End_Date__c > :date.today() ]){
	    	MobStudentEnrolled mobStdEnrolled = new MobStudentEnrolled();
	       	mobStdEnrolled.enrollmentId = ps_Enrolmnt.Id;
	       	mobStdEnrolled.studentId = ps_Enrolmnt.Student__r.Id;
	       	mobStdEnrolled.studentName = ps_Enrolmnt.Student__r.Name;
	       	mobStdEnrolled.className = ps_Enrolmnt.Class_Section__r.Name;
	       	mobStdEnrolled.classCatalogNbr = ps_Enrolmnt.Class_Section__r.Catalog_Nbr__c;
	       	mobStdEnrolled.classSectionId = ps_Enrolmnt.Class_Section__c;
	       	mobStdEnrolled.classDescription = ps_Enrolmnt.Class_Section__r.Course_Description__c;

		    enrolledClasses.add(ps_Enrolmnt.Class_Section__c);
	       	psEnrlMents.mobStudentsEnrolled.put(ps_Enrolmnt.Class_Section__c,mobStdEnrolled);
	    }
	    
	    if(!enrolledClasses.isEmpty()){
	    	for(ps_Class_Meeting__c psClassMeeting:[Select id,Class_Section__c,Wednesday__c, Tuesday__c, Thursday__c, Sunday__c, Start_Time__c, Start_Date__c, 
	                                                Special_Topic__c, Saturday__c, Name, Monday__c, Location__c, Friday__c, End_Time__c,
	                                                End_Date__c,Instructor_1__r.Name From ps_Class_Meeting__c where Class_Section__c in :enrolledClasses order by Start_Date__c
	                                                ]){
            	ClassMeeting clsMeeting = new ClassMeeting();
              	clsMeeting.classMeetingId =  psClassMeeting.id;
			  	clsMeeting.classSection =psClassMeeting.Class_Section__c;
			  	clsMeeting.isMonday = psClassMeeting.Monday__c;
			  	clsMeeting.isTuesday = psClassMeeting.Tuesday__c;
			  	clsMeeting.isWednesday = psClassMeeting.Wednesday__c;
			  	clsMeeting.isThursday = psClassMeeting.Thursday__c;
			  	clsMeeting.isFriday = psClassMeeting.Friday__c;
			  	clsMeeting.isSaturday = psClassMeeting.Saturday__c;
			  	clsMeeting.isSunday = psClassMeeting.Sunday__c;
			  	clsMeeting.startTime = psClassMeeting.Start_Time__c;
			  	clsMeeting.endTime = psClassMeeting.End_Time__c;
			  	clsMeeting.startDate = psClassMeeting.Start_Date__c;
			  	clsMeeting.endDate = psClassMeeting.End_Date__c;	
		      	clsMeeting.specialTopic = psClassMeeting.Special_Topic__c;
		      	clsMeeting.name = psClassMeeting.Name;
		      	clsMeeting.location = psClassMeeting.Location__c;
		      	clsMeeting.instructorName = psClassMeeting.Instructor_1__r.Name;
			  	psEnrlMents.classMeetings.put(psClassMeeting.Id,clsMeeting);     
	        }
	    }
	    return  psEnrlMents;
	}
	
	global class PsEnrollments{
	  	public Map<String,mobStudentEnrolled>	mobStudentsEnrolled {get;set;}
	  	public Map<String,ClassMeeting> classMeetings {get;set;}
	  	public Date startDate{get;set;}
	  	public Date lastDate{get;set;}
	}
	
	public class MobStudentEnrolled{
		String enrollmentId {get;set;}
	   	String studentId {get;set;}
	   	String studentName {get;set;}
	   	String className {get;set;}
	   	String classCatalogNbr {get;set;}
	   	String classSectionId {get;set;}
	   	String classDescription{get;set;}
	} 
	
	public class ClassMeeting{
		String  classMeetingId {get;set;}
	  	String  classSection {get;set;}
	  	boolean isMonday{get;set;}
	  	boolean isTuesday{get;set;}
	  	boolean isWednesday{get;set;}
	  	boolean isThursday{get;set;}
	  	boolean isFriday{get;set;}
	  	boolean isSaturday{get;set;}
	  	boolean isSunday{get;set;}
	  	String  startTime{get;set;}
	  	String  endTime{get;set;}
	  	Date    startDate{get;set;}
	  	Date    endDate{get;set;}	
      	String  specialTopic{get;set;}
      	String  name{get;set;}
      	String  location{get;set;}
      	String  instructorName{get;set;}
	}
}
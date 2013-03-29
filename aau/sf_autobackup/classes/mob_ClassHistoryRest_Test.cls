@isTest
private class mob_ClassHistoryRest_Test {

  public static Contact leadContact;
  public static  User sysAdmin;
  public static  User aaUStudent;
  public static User aaUStudentUser;
  public static User aaUStudentUser1;
  static{
     sysAdmin = mob_TestUtil.makeUser('System Administrator');
       aaUStudent = mob_TestUtil.makeUser('AAU Student - Platform');
       aaUStudentUser = mob_TestUtil.makeUser('AAU Student - Platform');
       aaUStudentUser1 = mob_TestUtil.makeUser('AAU Student - Platform');
       //leadContact = new Contact(LastName = 'lName', FirstName = 'fName', Recruiting_Status__c = 'Applicant',student_user__c=sysAdmin.Id);
       leadContact = new Contact(LastName = 'lName', FirstName = 'fName',student_user__c=sysAdmin.Id);
    insert leadContact;
  }
  static testmethod void testHistoryRest() {
   System.runAs(sysAdmin) {
      
        Contact lead = mob_TestUtil.makeLead('Test', 'ContactShare');
        lead.student_user__c = aaUStudentUser.Id;
        update lead;
        
        //Create Contact Share record using Trigger 
        ContactShare conShare = [Select id,ContactId,UserorGroupId from ContactShare where contactId=:lead.Id and UserorGroupId =:aaUStudentUser.Id  and  rowCause='Manual' limit 1];
        System.assertEquals(lead.student_user__c,conShare.UserorGroupId);
        
        lead.student_user__c = aaUStudentUser1.Id;
        update lead;
        
        conShare = [Select id,ContactId,UserorGroupId from ContactShare where contactId=:lead.Id and UserorGroupId =:aaUStudentUser1.Id  and  rowCause='Manual' limit 1];
        System.assertEquals(aaUStudentUser1.Id,conShare.UserorGroupId);
        
        
        
        ps_Term__c pTerm = mob_TestUtil.createOldTerm('T01', 'Test Term1');
      
        ps_Class__c pClass= mob_TestUtil.createClass(pTerm.Id, 'SFDC 401','Work', 'A11','A12', 'Workles', 'Field', 'ext11');
        ps_Class_Meeting__c  pClassMeeting= mob_TestUtil.createOldClassMeeting(pClass.Id, 'First Meeting', 1,'M21');
        ps_Enrollment__c pEnrollment = mob_TestUtil.createEnrollment(pClass.Id, 'EName', leadContact.Id);
        system.debug('::Student User on Contact :: '+aaUStudentUser1.Id);
        
        
        RestRequest req = new RestRequest(); 
          RestResponse res = new RestResponse();
                req.addParameter('id',lead.id);
                // pass the req and resp objects to the method     
                //req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/classHistory';  
                //req.httpMethod = 'GET';
          //mob_ClassHistoryRest.getEnrollments(req,res);
          mob_ClassHistoryRest.getEnrollments();
    }
  }
}
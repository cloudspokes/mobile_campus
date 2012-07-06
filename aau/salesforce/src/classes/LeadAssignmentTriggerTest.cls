/** 
 *Tests the LeadAssignmentTrigger
 */
@isTest
private class LeadAssignmentTriggerTest {

	/*
	static testMethod void testTriageDeactiveUsers() {
		RuleManager mgr = new RuleManager();
		List<User> activeusers = mgr.triageDeactiveUsers();	
		System.assertEquals(8, activeusers.size());
	}
	
	
	 
	static testMethod void testPrepareAdminOfficers() {
		RuleManager mgr = new RuleManager();
		mgr.prepareAdminOfficers();	
		for (User u : mgr.activeUsersForAssignment)
			System.debug('USER: '+u.Name+' GROUP: '+u.Admissions_Group__c);
			
		System.assertEquals(2, mgr.domesticCurrCA.size());
	}
	
	*/
	
	static testMethod void testEACarsAssignmentRules() {
		Contact c = [Select FirstName, LastName, Recruiting_Status__c, Residency_Status__c, Start_Term_Latest_Opp__c, OwnerId,
	        						Country__c, State_Province__c, Recruiting_Center_Latest_Opp__c, Career_Latest_Opp__c, Application_Status_Latest_Opp__c 
	        						from Contact where PeopleSoft_Person_ID__c = '03101408'];
	   
	   System.debug('TESTEACARS: orig owner is: '+c.ownerId);
	   c.Reassign_Lead__c = true;
	   update c;
	   
	    Contact c2 = [select Id, FirstName, OwnerId from Contact where PeopleSoft_Person_ID__c = '03101408'];
	    User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'EACars lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('00580000001owcIAAQ', c2.ownerid);	    
 	}
	
	static testMethod void testApplyAssignmentRules() {
		
		//List<Contact> contacts = [Select FirstName, LastName, Status__c, Recruiting_Status__c, Residency_Status__c, Start_Term_Latest_Opp__c,
	     //   		MailingCountry, MailingState, Recruiting_Center_Latest_Opp__c, Career_Latest_Opp__c, Application_Status_Latest_Opp__c from Contact where lastName = 'Trump'];
		
		//data prep
	        Contact c = new Contact(FirstName='Test', LastName='Test', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
	        
	        List<Contact> contacts = new List<Contact>();
	        contacts.add(c);
	        
	        List<Term__c> terms = [Select t.Name, t.Is_Future_Term__c, t.Is_Current_Term__c From Term__c t];
	        
		RuleManager mgr = new RuleManager();
		contacts = mgr.applyAssignmentRules(contacts,terms);	
		
		//System.assertEquals(1, contacts.size());
	}
	
	
	
	static testMethod void testIsFutureTerm() {
		LeadAssignmentManager lam = new LeadAssignmentManager();
		lam.prepareTerms();
		System.assertNotEquals(true, lam.isFutureTerm('0960 | 2009 Summer'));
		
	}
	/*
	static testMethod void testNumberOfLeadsAssignedCounter() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestCount', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestCount'];
        
       // TermAssignment__c t = [Select t.Term__r.Name, t.Term__c, t.Number_of_Leads_in_Inquiry_Status__c, t.Number_of_Leads_Assigned__c, t.Id, t.Admissions_Officer__c, t.Admissions_Officer__r.Username
		//					From TermAssignment__c t where t.Admissions_Officer__c = :c2.OwnerId And t.Term__c = 'A0Q80000000NbiEEAS'];
		
		List<TermAssignment__c> terms = [Select t.Term__r.Name, t.Term__c, t.Number_of_Leads_in_Inquiry_Status__c, t.Number_of_Leads_Assigned__c, t.Id, t.Admissions_Officer__c, t.Admissions_Officer__r.Username from TermAssignment__c t];				
        
        for (TermAssignment__c t : terms)
        {
        	System.debug('testcounterassignment for '+t.Admissions_Officer__r.Username+ 'in term '+t.Term__r.Name);
        	System.debug('has this many active leads: '+t.Number_of_Leads_Assigned__c);
        }
        System.Assert(terms.size() > 0); 
       }
    */
    static testMethod void testDomesticCAAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestDomestic', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1190 | 2011 Fall',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestDomestic'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('Domestic Undergraduate Admissions - Current Business (SF)', u2.Admissions_Group__c);
      }

     static testMethod void testEANM() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestUGO', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1360 | 2013 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Online', Career_Latest_Opp__c='NM', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						Birthdate=Date.today());
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestUGO'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('Early Admissions', u2.Admissions_Group__c);
      }
        
     static testMethod void testUndergradOnline() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestUGO', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1190 | 2011 Fall',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Online', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestUGO'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        //System.AssertEquals('Domestic Undergraduate Admissions - Current Business (Denver)', u2.Admissions_Group__c);
        System.AssertEquals('Domestic Undergraduate Admissions - Current Business (SF)', u2.Admissions_Group__c);
      }
    
    
    // should hit telemarketer due to start term being in the future and state != CA
    static testMethod void testTelemarketerAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestTelemarketer', Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1190 | 2011 Fall', Phone='99999999',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestTelemarketer'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.AssertEquals('Recruiting_Agency CARS', u2.Name);
      }
    
      // should hit blacklist due to country
    static testMethod void testBlacklistAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestBlacklist',  Recruiting_Status__c='Inquiry', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1190 | 2011 Fall',
	        						Country__c='Iraq', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
       
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestBlacklist'];
        
         User u2 = [select Name, Alias, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.AssertNotEquals('qwall', u2.Alias);
      }
    
    static testMethod void testInternationalAssignment()
    {
    	User u1 = [select Id from User where alias='qwall'];
      
        System.RunAs(u1)
        {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestInternational', Recruiting_Status__c='Inquiry', Residency_Status__c='International/Foreign Student', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='China', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestInternational'];
        
        User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Admissions_Group__c);
        System.AssertEquals('International Admissions', u2.Admissions_Group__c);
    }
    
    static testMethod void testGraduateAssignment()
    {
    		User u1 = [select Id from User where alias='qwall'];
      
        System.RunAs(u1)
        {
        
	        //data prep
	         Contact c = new Contact(FirstName='Assignment', LastName='TestGraduate', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='CA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Graduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	       
	        insert c; 

        	//update contact to retrigger trigger
        	//c.phone = '88888888';
        	//update c;
        	
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestGraduate'];
        
        User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('Graduate Admissions', u2.Admissions_Group__c);
    }
    
    static testMethod void testDomesticDenverAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestDomesticDenver', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='0960 | 2009 Summer',
	        						Country__c='United States', State_Province__c='IA', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestDomesticDenver'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.DEBUG, 'XXTest lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        //System.AssertEquals('Domestic Undergraduate Admissions - Current Business (Denver)', u2.Admissions_Group__c);
      }
    
    //EAT due to start term
    static testMethod void testEarlyAdmissionsAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestEarlyAdmission', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1360 | 2013 Summer',
	        						Country__c='United States', State_Province__c='TX', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='Undergraduate', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						Birthdate=Date.today());
	        //create new application
	        insert c;  
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestEarlyAdmission'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('Early Admissions', u2.Admissions_Group__c);
      }
      
      //EAT due to career type
    static testMethod void testNMEarlyAdmissionsAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestEarlyAdmissionNM', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1360 | 2013 Summer',
	        						Country__c='United States', State_Province__c='TX', Recruiting_Center_Latest_Opp__c='Onsite', Career_Latest_Opp__c='NM', Application_Status_Latest_Opp__c='Inquiry', RecordTypeId='012800000002dPnAAI',
	        						Birthdate=Date.today());
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestEarlyAdmissionNM'];
        
         User u2 = [select Name, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.debug(LoggingLevel.INFO, 'Test lead assigned to '+u2.Name+' of group '+u2.Admissions_Group__c);
        System.AssertEquals('Early Admissions', u2.Admissions_Group__c);
      }
     
  
    //should go to No Rep Assigned because career_latest_opp is null 
    static testMethod void testNoRepAssignment() {

        
        //setup user
        User u1 = [select Id from User where alias='qwall'];
      
       System.RunAs(u1)
       {
        
	        //data prep
	        Contact c = new Contact(FirstName='Assignment', LastName='TestAOS', Recruiting_Status__c='Prospect', Residency_Status__c='U.S. Citizen', Start_Term_Latest_Opp__c='1360 | 2013 Summer',
	        						Country__c='United States', State_Province__c='GA', Recruiting_Center_Latest_Opp__c='Onsite', Application_Status_Latest_Opp__c='Active', RecordTypeId='012800000002dPnAAI');
	        //create new application
	        insert c; 
        }
        
        
        //check to make sure the lead was assigned to someone other than qwall (who created it)
        Contact c2 = [select Id, FirstName, OwnerId from Contact where FirstName = 'Assignment' And LastName='TestAOS'];
        
         User u2 = [select Alias, Admissions_Group__c from User where Id = :c2.ownerid];
        
        System.AssertEquals('nassi', u2.Alias);
      }
    
}
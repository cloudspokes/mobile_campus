/**
 * Manage the lead assignment process. This class understands the 'flow' of activities
 */
public class LeadAssignmentManager {
	

	private List<Term__c> currentTerms = new List<Term__c>();
	private List<Term__c> terms;
	private List<Admissions_Opportunity__c> applications;
	
	private Map<Id, Admissions_Opportunity__c> applicationsByContactID = new Map<Id,Admissions_Opportunity__c>();
	private Set<Id> leadsWithMultipleApps = new Set<Id>();
	
	List<Contact> telemarketerLeads = new List<Contact>();
	List<Contact> blacklistedLeads = new List<Contact>();
	
	/**
	 * This method controls the flow of activities, for lead assignment. 
	 */ 
	public List<Contact> assignLeads(List<Contact> contacts)
	{
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: start of assignLeads');
		prepareTerms();
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: terms prepared. About to prepare contacts with existing apps');
		//prepareApplications(contacts); dont need this anymore as we are using the field: contact.Start_Term_Latest_Opp__c
		contacts = prepareLeadsWithExistingApps(contacts);
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: (before triaging) Contacts left to assign: '+contacts.size());
		
		
		//triage out as many as we can before doing the actual rule assignment
		contacts = triageInternationalBlacklists(contacts);
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: (after triaging blacklist) Contacts left to assign: '+contacts.size());
		contacts = triageTelemarketingLeads(contacts);
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: (after triaging telemarketer) Contacts left to assign: '+contacts.size());
		RuleManager mgr = new RuleManager();
		contacts = mgr.applyAssignmentRules(contacts,terms);
		//System.debug(LoggingLevel.INFO, '**LEAD TRIGGER: after assigning rules. Contacts number are: '+contacts.size());
		
		contacts.addAll(telemarketerLeads);
		contacts.addAll(blacklistedLeads);
		
		//System.debug(LoggingLevel.INFO, 'LEAD TRIGGER: final number of contacts to update: '+contacts.size());
		
		return contacts;
	}
	/* gsl
	private Map<Id, Contact> prepareContactsByID(List<Contact> contacts)
	{
		Map<Id, Contact> contactsbyid = new Map<Id, Contact>();
		
		for(Contact c : contacts)
		{
			contactsbyid.put(c.id, c);
		}
		return contactsbyid;
	}
	
	private void prepareApplications(List<Contact> contacts)
	{
		Map<Id, Contact> contactsbyid = prepareContactsbyID(contacts);
		 
		
		applications = [Select a.Start_Term__c, a.Recruiting_Center__c, a.Portfolio_Status__c, 
							   a.PeopleSoft_Application_ID__c, a.No_of_Units_Transferred__c, a.Need_Housing__c, 
							   a.Need_Financial_Aid__c, a.Name, a.Language_Test_Score__c, 
							   a.Interested_in_Online_Classes__c, a.Id, a.Housing_Fees__c, 
							   a.Current_Units_Enrolled_Changed__c, a.Current_No_of_Units_Enrolled__c, 
							   a.Career__c, a.Application_Status__c, a.Application_Fees_Paid__c, a.Lead__r.Id
						From Admissions_Opportunity__c a
						where a.Lead__r.Id in :contactsbyid.keySet()];
		
		for( Admissions_Opportunity__c a : applications)
		{
			if(applicationsByContactID.containsKey(a.Lead__r.Id))
				leadsWithMultipleApps.add(a.Lead__r.Id);
			else
				applicationsByContactID.put(a.Lead__r.Id, a);
		}
	}
	gsl*/
	public void prepareTerms()
	{
		terms = [Select t.Name, t.Is_Future_Term__c, t.Is_Current_Term__c From Term__c t];
		
		for(Term__c  t : terms)
		{
			if(t.Is_Current_Term__c)
				currentTerms.add(t);
		}
	}
	
	private List<Contact> prepareLeadsWithExistingApps(List<Contact> contacts)
	{
		List<Contact> leadsForAssignment = new List<Contact>();
		
		for(Contact c: contacts)
		{
				
			if(leadsWithMultipleApps.contains(c.Id))
			{
				if(c.Recruiting_Status__c == 'Contacted - No Reponse' || c.Recruiting_Status__c == 'Registered' || c.Recruiting_Status__c == 'Inactive')
				{
					c.Recruiting_Status__c = 'Prospect';
					c.RecordTypeId = '012800000002dPnAAI'; //Lead
				}
			}
			leadsForAssignment.add(c);	
		}
		return leadsForAssignment;
	}
	
	/**
	 * A country score of 6 indicates a blacklisted country
	 */
	private List<Contact> triageInternationalBlacklists(List<Contact> contacts)
	{
		Set<String> checkCountries = new Set<String>();
		for(Contact contact : contacts)
		{
			if(contact.Country__c != 'United States')  //usa is a special case as we dont assign scores for usa, but it exists in the country table
		     	checkCountries.add(contact.Country__c); 
		}
		List<Lead_Score__c> countries = [select Name, Score__c 
		                                 from Lead_Score__c 
		                                 where Score__c <= 6
		                                   and Scoring_Category__r.Name = 'Country'
		                                   and Name in :checkCountries];

		// List<Lead_Score__c> countries = [Select c.Name, c.Score__c From Lead_Score__c c where c.Score__c = 6 AND c.Scoring_Category__r.Name = 'Country'];
		List<Contact> leadsForAssignment = new List<Contact>();
		
		//User blacklistUser = [select id from User where Name = 'BlackListed Countries'];
		
		Set<String> blacklistedCountries = new Set<String>();
		for( Lead_Score__c c : countries)
		{
				System.debug('Adding blacklist country: '+c.Name);
				blacklistedCountries.add(c.Name);
		}
		for(Contact c: contacts)
		{
			if(blacklistedCountries.contains(c.Country__c))
			{
				//System.debug('Sending lead '+c.FirstName+' '+c.LastName+' to blacklist');
				c.OwnerId = '00580000001p6aXAAQ'; //blacklisted countries user
				blacklistedLeads.add(c);
			}
			else
				leadsForAssignment.add(c);
		}
		
		return leadsForAssignment;
	}
	
	private List<Contact> triageTelemarketingLeads(List<Contact> contacts)
	{
		List<Contact> leadsForAssignment = new List<Contact>();
		
		//User telemarketerUser = [select id from User where Name = 'Telemarketer (CARS)'];
		
		//TODO:
		//so you would have to query the related Application, then the related Prog-Plan-SubPlan records and if any one of those Prog-Plan-SubPlan records had a Program = "2nd Bachelor of Fine Arts" then do NTO assign to TM
	
		for(Contact c : contacts)
		{
			if(c.Telemarketer_Assignment_Cancelled__c == true)
				leadsForAssignment.add(c);
			 else if(
				c.Recruiting_Status__c == 'Inquiry' && 
			   (c.Residency_Status__c == 'U.S. Citizen' || c.Residency_Status__c == 'U.S. Resident (Green Card)') &&
			   c.Career_Latest_Opp__c == 'Undergraduate' &&
			    (c.Phone != null || c.MobilePhone != null || c.HomePhone != null))
			 {
			 	System.debug('ASSIGNING TO TELEMARKETER QUEUE: '+c.FirstName+' '+c.LastName);
			 	c.OwnerId = '00580000001owcIAAQ'; //telemarketer user
			 	telemarketerLeads.add(c);
			 }
			 else
			 	leadsForAssignment.add(c);			
		}
		
		return leadsForAssignment;
	}
	


	//TODO
	public void termUpdated() {}
	
	
	public Boolean isCurrentTerm(String termname)
	{
		Boolean iscurrent = false;
		System.debug('checking current term against termname: '+termname);
		for(Term__c t : currentTerms)
		{
			System.debug('checking current term: '+t.Name);
			if(t.Name == termname)
				iscurrent = true;
		}	
		return iscurrent;
	}
	
	public boolean isFutureTerm(String termname)
	{
		for(Term__c t : terms)
		{
			if(t.Name == termname)
			{
				if(t.Is_Future_Term__c == 'Future' && !t.Is_Current_Term__c)
					return true;
				else
					return false;
			}
		}
		return true;  //more destructive if not future.
	}

}
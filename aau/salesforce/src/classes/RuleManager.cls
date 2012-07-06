/**
 * Assign Leads based on rules in the AssignmentRule table
 */
public class RuleManager {
	
	List<Assignment_Rule__c> rules;
	List<User> usersForUpdating = new List<User>();
	Map<Id, User> usersMap = new Map<Id, User>();
	Map<String, TermAssignment__c> assignmentByTerm = new Map<String, TermAssignment__c>();
	Map<String, TermAssignment__c> assignmentsToUpdate = new Map<String, TermAssignment__c>();
	private Map<String, Term__c> terms = new Map<String, Term__c>();
	Map<Id, Double> oldInquiryLeads = new Map<Id, Double>();
	
	public List<User> activeUsersForAssignment = null;
	User aosUser = null;
	
	/*
	public Map<Id, User> domesticCurrCA = new Map<Id, User>();
	public Map<Id, User> domesticCurrNoCA = new Map<Id, User>();
	public Map<Id, User> undergradOL = new Map<Id, User>();
	public Map<Id, User> eatUG = new Map<Id, User>();
	public Map<Id, User> eatNM = new Map<Id, User>();
	public Map<Id, User> internationalOL = new Map<Id, User>();
	public Map<Id, User> grad = new Map<Id, User>();
	public Map<Id, User> intOLGrad = new Map<Id, User>();
	
	public static String DUA_CBSF = 'Domestic Undergraduate Admissions - Current Business (SF)';
	public static String DUA_CBD = 'Domestic Undergraduate Admissions - Current Business (Denver)';
	public static String UGO = 'Undergraduate Online';
	public static String EA = 'Early Admissions';
	public static String EANM = 'Early Admissions - NM';
	public static String IA = 'International Admissions';
	public static String GA = 'Graduate Admissions';
	public static String IOGA = 'International OL Graduate Admissions';
	*/
	
	public Map<String, Map<ID, User>> admGroups = new Map<String, Map<ID, User>>();
		
	
	public List<Contact> applyAssignmentRules(List<Contact> contacts, List<Term__c> allTerms)
	{
		for(Term__c t : allTerms)
		{
			terms.put(t.Name, t);
		}
		
		//System.debug('ABOUT TO ASSIGN RULES');
		rules = [Select a.Student_Admissions_Group__c, 
										  a.State_USA__c, a.Residency_Status__c,
										  a.Recruiting_Center__c, a.Name, a.Id, 
										  a.Career__c, a.Admit_Term__c,
										  a.Distribute_By_Name__c,
										  a.Age_From__c, a.Age_To__c 
								  		 From Assignment_Rule__c a
								  		 Order By Priority__c];
								  		 
		for (Assignment_Rule__c rule : rules) {
			if (!admGroups.containsKey(rule.Student_Admissions_Group__c)) {
				admGroups.put(rule.Student_Admissions_Group__c, new Map<ID, User>());
			}
		}
								 
		prepareAdminOfficers(); 
		
		User u;
		Map<Id, User> admGroup;
		//loop through contacts - compare rule, and assign.
		List<Contact> updatedContacts = new List<Contact>();
		
		for(Contact c : contacts)
		{
			System.debug('CHECKING RULES FOR LEAD: '+c.FirstName+' '+c.LastName);
			for( Assignment_Rule__c r : rules)
			{
				//System.debug('CHECKING RULE: '+r.Name);
				
				if(contactContainsAnyNulls(c))
				{
					c.OwnerId = '00580000001ywmAAAQ'; //no rep assigned user
					updatedContacts.add(c);
				}
				else if(r.Residency_Status__c.contains(c.Residency_Status__c) && r.Career__c.contains(c.Career_Latest_Opp__c) &&
				 r.Recruiting_Center__c.contains(c.Recruiting_Center_Latest_Opp__c) && 
				 matchesAge(c, r) && matchesAdmitTerm(c.Start_Term_Latest_Opp__c, r.Admit_Term__c) && 
				 matchesState(c, r))
				 {
				 	System.debug('USING RULE: '+r.Name+' for lead '+c.FirstName+' '+c.LastName);
				 	
				 	//u = assignToOfficer(r.Student_Admissions_Group__c, c);
				 	admGroup = admGroups.get(r.Student_Admissions_Group__c);
				 	if (r.Distribute_By_Name__c == True) {
				 		u = getInternationalUserWithLowestWorkload(admGroup, c);	
				 	} else {
						u = getUserWithLowestWorkload(admGroup, c);				 		
				 	}
					admGroup.remove(u.Id);
					admGroup.put(u.Id, u);
					
				 	c.ownerId = u.Id;
				 	
				 	//System.debug('UPDATING ASSIGNEE: '+u.Name+' and status is: '+c.Recruiting_Status__c+'.');
				 	updatedContacts.add(c);
				
				 	usersMap.put(u.id, u);
				 	break; //match on the first rule in case there are non-exclusive rules
				 }
			}
			
		}
		
		System.debug('USERS FOR UPDATING:'+usersMap.size());
		if(!usersMap.isEmpty())
		{
			System.debug('USERS FOR UPDATING: BEFORE UPDATE');
			List<Database.Saveresult> sr = Database.update(usersMap.values());
			
			for(Database.Saveresult s : sr)
			{
				if(s.isSuccess())
					System.debug('USERS UPDATED SUCCESSFULLY');
				else
				{
					for(Database.Error e : s.getErrors())
						System.debug('USER UPDATE ERROR: '+ e.getMessage());
				}
			}
			
			//need to update term assignments, but there can be more than 100 records which is the limit in a trigger
			//so we need to split and batch
			System.debug('There are '+assignmentByTerm.size()+ ' termAssignments to update...about to split and process');
			
			
			/*
			TODO: make an async call here to another class to do term assignment updates.
			List<TermAssignment__c> assignmentBatch = new List<TermAssignment__c>();
			
			System.debug('TERMASSIGNMENTS UPDATED: upsert this many new term assignments:'+assignmentsToUpdate.size());
			if(!assignmentsToUpdate.isEmpty())
				upsert assignmentsToUpdate.values();
			*/
		}
		return updatedContacts;
	}
	
	/*
	private User assignToOfficer(String groupName, Contact c)
	{
		User assignee;
		System.debug('GROUP NAME IS: '+groupName+' for lead '+c.FirstName+' '+c.LastName);
		//assign based on rules and officier assignment criteria.
		if(groupName == DUA_CBSF)
		{	
			assignee = getUserWithLowestWorkload(domesticCurrCA, c);
			domesticCurrCA.remove(assignee.Id);
			domesticCurrCA.put(assignee.Id, assignee);
		}
		else if(groupName == DUA_CBD)
		{	
			System.debug('USING GROUP: '+DUA_CBD+' There are this many admin users: '+domesticCurrNoCA.size());
			assignee = getUserWithLowestWorkload(domesticCurrNoCA, c);
			System.debug('Assignee is '+assignee.Name+' for lead '+c.FirstName+' '+c.LastName);
			domesticCurrNoCA.remove(assignee.Id);
			domesticCurrNoCA.put(assignee.Id, assignee);
		}
		else if(groupName == UGO)
		{	
			assignee = getUserWithLowestWorkload(undergradOL, c);
			undergradOL.remove(assignee.Id);
			undergradOL.put(assignee.Id, assignee);
		}
		else if(groupName == EA)
		{	
			assignee = getUserWithLowestWorkload(eatUG, c);
			eatUG.remove(assignee.Id);
			eatUG.put(assignee.Id, assignee);
		}
		else if(groupName == EANM)
		{	
			assignee = getUserWithLowestWorkload(eatNM, c);
			eatNM.remove(assignee.Id);
			eatNM.put(assignee.Id, assignee);
		}
		else if(groupName == IA)
		{	
			assignee = getInternationalUserWithLowestWorkload(internationalOL, c);
			internationalOL.remove(assignee.Id);
			internationalOL.put(assignee.Id, assignee);
		}
		else if(groupName == GA)
		{	
			assignee = getUserWithLowestWorkload(grad, c);
			grad.remove(assignee.Id);
			grad.put(assignee.Id, assignee);
		}
		else if(groupName == IOGA)
		{	
			assignee = getInternationalUserWithLowestWorkload(intOLGrad, c);
			intOLGrad.remove(assignee.Id);
			intOLGrad.put(assignee.Id, assignee);
		}

		return assignee;
	}
	*/
	
	private User getInternationalUserWithLowestWorkload(Map<Id, User> userGroup, Contact c)
	{
		String lastName = c.LastName;
		
		if(userGroup.isEmpty())
			return aosUser;
			
		User lowest = userGroup.values().get(0);
		
		for(User u : userGroup.values())
		{
			if(u.Alphabets_for_Internatl_Lead_Assignment__c != null && u.Alphabets_for_Internatl_Lead_Assignment__c.contains(lastName.substring(0,1)))
			{
				//handle the case that a new rep may never have had leads assigned
				if(u.Lead_Last_Assigned__c == null && u.Eligible_for_Lead_Assignment__c)
					lowest = u;
				else if((u.Lead_Last_Assigned__c <= lowest.Lead_Last_Assigned__c) && u.Eligible_for_Lead_Assignment__c)
					lowest = u;
			}
			
		}
		lowest.Lead_Last_Assigned__c = Datetime.now();
		//TODO: move to async assignment rules call
		//lowest = applyAssignmentLimitRules(lowest,c);
		userGroup.remove(lowest.id);
		userGroup.put(lowest.id, lowest);
	
		
		return lowest;	
	}
	
	private User getUserWithLowestWorkload(Map<Id, User> userGroup, Contact c)
	{
		if(userGroup.isEmpty())
			return aosUser;
			
		User lowest = userGroup.values().get(0);
		
		for(User u : userGroup.values())
		{
			//handle the case that a new rep may never have had leads assigned
			if(u.Lead_Last_Assigned__c == null && u.Eligible_for_Lead_Assignment__c)
					lowest = u;
			else if((u.Lead_Last_Assigned__c <= lowest.Lead_Last_Assigned__c) && u.Eligible_for_Lead_Assignment__c)
				lowest = u;
		}
		
		//TODO: move this to an async call
		//lowest = applyAssignmentLimitRules(lowest,c);
		lowest.Lead_Last_Assigned__c = Datetime.now();
		userGroup.remove(lowest.id);
		userGroup.put(lowest.id, lowest);
	
		return lowest;	
	}
	
	/**
	 * Currently not used.
	 * TODO: move this to an aysnc class
	 */
	 /* gsl
	private User applyAssignmentLimitRules(User u, Contact c)
	{
		System.debug('Starting ApplyAssignmentLimitRules for user '+u.Name + ' and contact '+c.FirstName+' '+c.LastName);
		
		if(u.Id == '00580000001ywmAAAQ') //no rep assigned user
		{
			System.debug('Applying Assignment Rules, but user is No rep Assigned');
			return u;
			
		}
			
		Double numInquiry = 0;
		Double numActiveLeads = 0;
		boolean foundAssignments = false;
		TermAssignment__c term = null;
		
		
		for(TermAssignment__c t : assignmentByTerm.values())
		{
			if(t.Admissions_Officer__c == u.Id && t.Term__r.Name == c.Start_Term_Latest_Opp__c )
			{
				System.debug('Found an existing term assignment for '+u.Username+' in term '+c.Start_Term_Latest_Opp__c);
				foundAssignments = true;
				term = t;
				numInquiry = t.Number_of_Leads_in_Inquiry_Status__c;
				numActiveLeads = t.Number_of_Leads_Assigned__c;
			}
		}
	 		
		if(c.Recruiting_Status__c == 'Inquiry')
	 	{
	 		numInquiry++;
	 	}	
	 	if(c.Recruiting_Status__c == 'Inquiry' || c.Recruiting_Status__c == 'Contacted' || c.Recruiting_Status__c == 'Prospect')
	 	{
	 		numActiveLeads++;
	 		u.No_of_Active_Leads_Assigned__c++;
	 	}
	 	
		if(u.Admissions_Group__c != null && u.Admissions_Group__c.contains('Domestic Undergraduate Admissions'))
		{
			Double oldLeadCounter = 0;
			if(oldInquiryLeads.containsKey(u.Id))
				oldLeadCounter = oldInquiryLeads.get(u.Id);
				
			if(numActiveLeads+1 > 800 || oldLeadCounter > 50)
				u.Eligible_for_Lead_Assignment__c = false; 	
		}
		
		
		if(numActiveLeads > 0 || numInquiry > 0)
		{
			if(foundAssignments)
			{
				assignmentByTerm.remove(term.Term__r.Name+u.Username);
				if(assignmentsToUpdate.containsKey(term.Term__r.Name+u.Username))
					assignmentsToUpdate.remove(term.Term__r.Name+u.Username);
			}
			else
			{
				System.debug('Didnt find an existing term assignment for '+u.Username+' in term '+c.Start_Term_Latest_Opp__c+'. Sheesh...gotta create a new one');
					
				term = new TermAssignment__c();
				term.Admissions_Officer__c = u.Id;
				term.Term__c = terms.get(c.Start_Term_Latest_Opp__c).Id;
			}
			
				System.debug('Adding a new assignment by term '+terms.get(c.Start_Term_Latest_Opp__c).Name+u.Username);
				System.debug('They have this many leads assigned: '+numActiveLeads);
			
				term.Number_of_Leads_Assigned__c = numActiveLeads;
				term.Number_of_Leads_in_Inquiry_Status__c = numInquiry;
						
				assignmentByTerm.put(terms.get(c.Start_Term_Latest_Opp__c).Name+u.Username, term);
				assignmentsToUpdate.put(terms.get(c.Start_Term_Latest_Opp__c).Name+u.Username, term);
		}
		u.Lead_Last_Assigned__c = Datetime.now();
		return u;
		
	}
	*/
	public void prepareAdminOfficers()
	{
		activeUsersForAssignment = getActiveUsers();
		for(User u : activeUsersForAssignment )
		{
			//System.debug(LoggingLevel.DEBUG, 'Preparing admin officer '+u.Name+' who is a member of the group: '+ u.Admissions_Group__c);
			if (u.Admissions_Group__c != null)  //dont want to assign aos, telemarketer, or blacklist user
			{
				/*
				if(u.Admissions_Group__c == DUA_CBSF)
				{
					//System.debug('ADDING A DOMESTIC USER:'+u.Name);
					domesticCurrCA.put(u.id, u);
				}
				else if(u.Admissions_Group__c == DUA_CBD)
					domesticCurrNoCA.put(u.id, u);
				else if(u.Admissions_Group__c == UGO)
					undergradOL.put(u.id, u);
				else if(u.Admissions_Group__c == EA)
					eatUG.put(u.id, u);
				else if(u.Admissions_Group__c == EANM)
					eatNM.put(u.id, u);
				else if(u.Admissions_Group__c == IA)
					internationalOL.put(u.id, u);
				else if(u.Admissions_Group__c == GA)
					grad.put(u.id, u);
				else if(u.Admissions_Group__c == IOGA)
					intOLGrad.put(u.id, u);
				*/
				if (admGroups.containsKey(u.Admissions_Group__c)) {
					// User Group must match a group associated with a rule 
					admGroups.get(u.Admissions_Group__c).put(u.id, u);
				}
			}
		}
	}
	
	public List<User> getActiveUsers()
	{					  
		List<User> allActiveUsers = new List<User>();
		
		
		for(List<User> activeusers : [Select u.Username, u.UserType, u.UserRoleId,
										 u.No_of_Active_Leads_Assigned__c, u.No_of_Leads_in_Inquiry_Status__c, u.Name, u.IsActive, u.Id, 
										 u.EmployeeNumber, u.Email, u.Eligible_for_Lead_Assignment__c, u.Lead_Last_Assigned__c,
										 u.Alphabets_for_Internatl_Lead_Assignment__c, u.Admissions_Group__c  
							  From User u
							  Where u.Eligible_for_Lead_Assignment__c = true And u.isActive = true])
		{
			allActiveUsers.addAll(activeusers);
		}
		
		
		List<Id> userids = new List<Id>();
		for(User u : allActiveUsers)
		{
			if(u.Id == '00580000001ywmAAAQ') //no rep
				aosUser = u;
			else	
				userids.add(u.Id);
		}
		
		/* TODO: move to async method.
		List<TermAssignment__c> allTermAss = new List<TermAssignment__c>();
		
		for (List<TermAssignment__c>  t1 :[Select t.Term__r.Name, t.Term__c, t.Number_of_Leads_in_Inquiry_Status__c, t.Number_of_Leads_Assigned__c, t.Id, t.Admissions_Officer__c, t.Admissions_Officer__r.Username
							From TermAssignment__c t where t.Admissions_Officer__c in : userids])
		{
			allTermAss.addAll(t1);
			
		}
		System.debug('There are this many term assignments: '+allTermAss.size());
		for(TermAssignment__c t : allTermAss)
		{
			//need -to use a unique string, not an ID as we may need to insert new assignments
			assignmentByTerm.put(t.Term__r.Name+t.Admissions_Officer__r.Username, t);
		}
		
		//we need to also do a count on number of leads that have been in inquiry for 7 days
		Double leadcount = 0;
		for(List<Contact> c1 : [select id, Owner.Id, createddate from Contact 
								where Recruiting_Status__c != null And createddate != null And owner.id != null And isDeleted != null
								And isDeleted = false And Recruiting_Status__c = 'Inquiry' and createddate < LAST_WEEK and owner.id in :userids ])
		{
			for(Contact c : c1)
			{
				if(oldInquiryLeads.containsKey(c.Owner.id))
				{
					Double count = oldInquiryLeads.get(c.Owner.Id);
					oldInquiryLeads.put(c.Owner.Id, count+1);
				}
				else
				{
					oldInquiryLeads.put(c.Owner.Id, 1);
				}
			}
		}
		*/
		System.debug(LoggingLevel.INFO, '*** activeuser count is '+allActiveUsers.size());
		return allActiveUsers;	
	}
	
	private boolean matchesAdmitTerm(String startTerm, String ruleTerms)
	{
		if(ruleTerms.contains('ANY') || ruleTerms.contains(startTerm))
			return true;
		else
			return false;
	}
	
	private boolean matchesAge(Contact c, Assignment_Rule__c r)
	{
		if ((c.Age__c != null && c.Age__c >= r.Age_From__c && c.Age__c <= r.Age_To__c) ||
			(r.Age_From__c == null && r.Age_To__c == null)) {
			return true;
		}	
		return false;
	}
	
	private boolean matchesState(Contact c, Assignment_Rule__c r)
	{

		if(c.Country__c == 'United States')
		{
			if(r.State_USA__c == null)
			{
				//System.debug(LoggingLevel.ERROR, 'Missing State values for rule '+r.Name+'. This rule accepts domestic students. Please add at least one state.');
				//return false;
				// 2009-04-12 Changing this to return true i/o false.  If a rule does not have any states specified then that means that there is no specific state criteria for the rule.
				return true;
			}
			else if(c.State_Province__c == null)
			{
				System.debug(LoggingLevel.ERROR, 'Missing State values for contact '+c.FirstName+' '+c.LastName+'. This user has country of USA and should have a state.');
				return false;
			}
			else if(r.State_USA__c.contains(c.State_Province__c))
				return true;
			else
				return false;
		}
		else if (r.State_USA__c == null) {
				// Count this is as match since this rule is not specific to any state.
				return true;
		} else {
				return false;
		}
	}
	
	private Boolean contactContainsAnyNulls(Contact c)
	{
		if(c.Residency_Status__c == null || c.Career_Latest_Opp__c == null ||
		   c.Recruiting_Center_Latest_Opp__c == null || c.Start_Term_Latest_Opp__c == null)
				 return true;
		else
			return false;
	}

}
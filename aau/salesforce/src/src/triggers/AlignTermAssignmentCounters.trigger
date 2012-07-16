/**
 * Trigger used to update term assignment counters post migration load to make sure historical lead assignments
 * are reflected in the term assignment counters
 * This is intended to be a once-off execution, and no current term assignments will exist (the table will have been wiped in prep of data migration)
 */
trigger AlignTermAssignmentCounters on Contact (after update) {

	List<Contact> leads = new List<Contact>();
	
	for(Contact c : trigger.new)
	{
		//only execute if record type is one of the 3  Lead types
 		if((c.RecordTypeId == '012800000002dPnAAI' || c.RecordTypeId == '012800000002dKrAAI' || c.RecordTypeId == '012800000002dLxAAI') 
 			&& c.Reassign_Lead__c == true)
		{
				leads.add(c);
		}
	}
	
	if(!leads.isEmpty())
	{
		Map<String, Id> allterms = new Map<String, Id>();
		for(Term__c tt : [select id, Name from Term__c])
		{
			allterms.put(tt.Name, tt.Id);
		}
		
		Map<String, TermAssignment__c> terms = new Map<String, TermAssignment__c>();
		
		for(List<TermAssignment__c> batch : [Select t.Term__c, t.Term__r.Name, t.OwnerId, t.Number_of_Leads_in_Inquiry_Status__c, t.Number_of_Leads_Assigned__c, t.Name, t.Id, t.Admissions_Officer__r.Username, t.Admissions_Officer__c From TermAssignment__c t])
		{
			for(TermAssignment__c t : batch)
			{
				terms.put(t.Term__r.Name+t.Admissions_Officer__r.Username, t);
			}
		}
		
		for(Contact c : leads)
		{	
			TermAssignment__c cur = null;
			Double assignedLeads = 0;
			Double inquiryLeads = 0;
			
			if(c.Start_Term_Latest_Opp__c != null || allterms.containsKey(c.Start_Term_Latest_Opp__c))
			{
				String key = c.Start_Term_Latest_Opp__c+c.Owner.Username;
			
				if(terms.containsKey(key))
				{
					cur = terms.get(key);
					terms.remove(key);
					assignedLeads = cur.Number_of_Leads_Assigned__c;
					inquiryLeads = cur.Number_of_Leads_in_Inquiry_Status__c;
				}
				else
				{
					cur = new TermAssignment__c();	
					cur.Term__c = allterms.get(c.Start_Term_Latest_Opp__c);
					cur.Admissions_Officer__c = c.Ownerid;
				}
				
				if(c.Recruiting_Status__c == 'Inquiry')
					inquiryLeads++;
				
				if(c.Recruiting_Status__c == 'Inquiry' || c.Recruiting_Status__c == 'Contacted' || c.Recruiting_Status__c == 'Prospect')
					assignedLeads++;
				
				cur.Number_of_Leads_Assigned__c = assignedLeads;
				cur.Number_of_Leads_in_Inquiry_Status__c = inquiryLeads;
				
				terms.put(key, cur);
			}
		}
			
		if(!terms.isEmpty())
		{
			upsert terms.values();
		}
	}
}
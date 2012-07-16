trigger LeadAssignmentTrigger on Contact (before insert) {
System.debug(LoggingLevel.INFO, '>>>>>STARTING leadassignment trigger');
	List<Contact> leads = new List<Contact>();
	
	for(Contact c : trigger.new)
	{
		//only execute if record type is one of the 3  Lead types
 		if(c.RecordTypeId == '012800000002dPnAAI' || c.RecordTypeId == '012800000002dKrAAI' || c.RecordTypeId == '012800000002dLxAAI')
		{
				leads.add(c);
		}
	}
	System.debug(LoggingLevel.INFO, '>>>>>>LEAD TRIGGER: assign this many leads:'+leads.size());
	
	LeadAssignmentManager mgr = new LeadAssignmentManager();
	
	if(!leads.isEmpty())
	{
		List<Contact> updatedLeads = mgr.assignLeads(leads);
		
		Map<String, Contact> keyedUpdated = new Map<String, Contact>();
		// need to match on first & last name because it may be a new contact, and therefor no Id yet
		for(Contact c1 : updatedLeads)
		{
			keyedUpdated.put(c1.FirstName+c1.LastName, c1);
		}
	
		for (Contact c : trigger.new)
		{
			if(keyedUpdated.containsKey(c.FirstName+c.LastName))
				c = keyedUpdated.get(c.FirstName+c.LastName);
		}
	}
}
public class LeadAssignmentController {
	/*
	public String residencystatus { get; set; }
	public String startterm { get; set; }
	public String career { get; set; }
	public String recruitingcenter { get; set; }
	public String sag { get; set; }
	public String USAstates { get; set; }
	
	public List<Assignment_Rule__c> currentrules = new List<Assignment_Rule__c>();

	public LeadAssignmentController()
	{
		
	}
	
	public PageReference addrule()
	{
		
		Assignment_Rule__c rule = new Assignment_Rule__c();
		rule.Student_Admissions_Group__c = sag;
		rule.Career__c = career;
		rule.Recruiting_Center__c = recruitingcenter;
		rule.Residency_Status__c = residencystatus;
		System.debug('****1');
		System.debug('****1'+startterm);
		rule.start_term__c = startterm;
		System.debug('****2');
		rule.State_USA__c = USAstates;
		
		insert rule;
		
		return null;
	}
	
	public List<Assignment_Rule__c> getCurrentRules()
	{
		
		return [Select a.Student_Admissions_Group__c, a.Residency_Status__c, a.Recruiting_Center__c, a.Career__c, a.Admit_Term__c, a.State_USA__c 
				From Assignment_Rule__c a];
	}
	
	public List<SelectOption> getSags()
	{
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult =
				  Assignment_Rule__c.Student_Admissions_Group__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	
	public List<SelectOption> getCareers()
	{
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult =
				  Admissions_Opportunity__c.Career__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	
	public List<SelectOption> getRecruitingCenters()
	{
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult =
				  Admissions_Opportunity__c.Recruiting_Center__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	
	public List<SelectOption> getResidencies()
	{
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult =
				 Contact.Residency_Status__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	
	public List<SelectOption> getStates()
	{
	       List<SelectOption> options = new List<SelectOption>();
	       
	       for(State__c s : [select name from state__c])
	       {
	       		options.add(new SelectOption(s.Name, s.Name));
	       }       
	   return options;
	}
	
	public List<SelectOption> getTerms()
	{
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult =
				 Admissions_Opportunity__c.Start_Term__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   options.add(new SelectOption('All Admit Terms', 'All Admit Terms'));
	   for( Schema.PicklistEntry f : ple)
	   {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	*/
}
public class LeadSearchController {

        //search criteria
        public String psoftStudentID { get; set; }
        public String fname { get; set; }
        public String lname { get; set; }
        public String career { get; set; }
        public List<Contact> searchresults = new List<Contact>();
        public String selectedid;
        
                
        public LeadSearchController()
        {
        }
        
        
         public PageReference dosearch()
         {
         		System.debug('FirstName:'+fname);
         		System.debug('LastName:'+lname);
         		System.debug('FirstName:'+fname);
         		System.debug('FirstName:'+fname);
         		System.debug('FirstName:'+fname);
         		
                searchresults = [Select c.PeopleSoft_Person_ID__c, c.Owner.FirstName, c.Owner.LastName, c.OwnerId, c.LastName, c.Id, c.FirstName, c.Career_Latest_Opp__c
                                                                 From Contact c
                                                                 Where  c.PeopleSoft_Person_ID__c LIKE :psoftStudentID+'%' AND 
                                                                 c.FirstName LIKE :fname+'%' AND c.LastName LIKE :lname+'%' AND c.Career_Latest_Opp__c LIKE :career+'%' LIMIT 100];
                
               System.debug('number of search results:'+searchresults.size());
                return null;
         }
         
         public List<Contact> getSearchresults()
         {
                return searchresults;   
         }
         
        public List<SelectOption> getCareers()
        {
          List<SelectOption> options = new List<SelectOption>();
                
           Schema.DescribeFieldResult fieldResult =
                                 Admissions_Opportunity__c.Career__c.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           //add blank
           options.add(new SelectOption('%','Any'));
           
           for( Schema.PicklistEntry f : ple)
           {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }       
           return options;
        }
        
        public PageReference showLeadDetails()
        {
                selectedid = System.currentPageReference().getParameters().get('selectedid');
                System.debug('*** LeadSearch selectedid: '+selectedid);
                ContactShare contactShr = new ContactShare();
                contactShr.ContactId = selectedid;
                contactShr.UserOrGroupId = System.Userinfo.getUserId();
                contactShr.ContactAccessLevel = 'Read';
                Database.Saveresult sr = Database.insert(contactShr, false);
        
        if(sr.isSuccess())
        {
                System.debug('database insert was successful');
                return new PageReference('/'+selectedid); 
        }
        else
        {
                // Get first save result error.
                        Database.Error err = sr.getErrors()[0];
                        System.debug('database error: '+err);
                        return new PageReference('/'+selectedid); 
                        //return null;
        }
                
        }
        
}
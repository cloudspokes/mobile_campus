@isTest(SeeAllData=true)
public  class mob_testClasses {
	   
          static  testmethod void  testSubscribeToStudentServicesTrigger() {
	         Profile profile = [select Id, Name 
	                           from Profile 
	                           where Name = 'AAU Student - Platform'
	                          ];
	
	        String name = 'test' + Math.random() + '@academyart.edu';
	
			List<CollaborationGroup> grp=[select id from CollaborationGroup where name='Student Services'];
			
			if(grp.size() ==0 ){
				CollaborationGroup grp1 = new CollaborationGroup(name='Student Services',CollaborationType='Public' );
			
				insert grp1;
			}
	        User user = new User( Alias = 'testuser'
	                            , Email = name
	                            , EmailEncodingKey = 'UTF-8'
	                            , LastName = 'test' + Math.random()
	                            , ProfileId = profile.id
	                            , UserName = name
	                            , LanguageLocaleKey = 'en_US'
                            	, LocalesIdKey = 'en_US'
                            	, TimezonesIdKey =  'America/Los_Angeles'
	                            );
	        insert user;
	        
	        
	
	        
         }
         static testMethod void testBatchUpdateStudentUsers()
	    {
	    	test.starttest() ;
	    	database.Executebatch(new BatchUpdateStudentUsers()) ;
	    	Test.stopTest() ;
	    	
	    }
}
global class BatchUpdateStudentUsers implements Database.Batchable<SObject>{


    global Database.QueryLocator start(Database.BatchableContext context) {
        // Get list of available user student Records
        String query = 'Select id from user where profile.name = \'AAU Student - Platform\' and isActive = true ' ;
        if(Test.isRunningTest()) {
        	query += ' limit 3' ;
        }
        Database.QueryLocator ans = Database.getQueryLocator(query);
           
        return ans;
    }
    
    global void execute(Database.BatchableContext context, List<SOBject> objects){ 
    	List<User> usrStudents = (List<User>)(objects);
    	
    	string GroupName = 'Student Services';
        //Retrieve Student Service Chatter group
		List<CollaborationGroup> studentServicesGroup = [Select id,name from CollaborationGroup where name = :GroupName limit 1];
		if(studentServicesGroup.size() == 0){
			system.debug('CollaborationGroup Student Services does not exist');
			return;
		}
		
		//Create set of Student ids
		Set<id> studentIds =new Set<Id>();
		for(User u : usrStudents){
			studentIds.add(u.id);
			
		}
		
		//Retrieve List of existing memberships
		List<CollaborationGroupMember> existingMembership =[Select MemberId, CollaborationGroup.Name, CollaborationGroupId 
															From CollaborationGroupMember
															where MemberId in :studentIds
																  and CollaborationGroupId =:studentServicesGroup[0].id];
		
		//Remove ids with existing memberships 													  
		for(CollaborationGroupMember member : existingMembership)	{
			studentIds.remove(member.MemberId);
		}	
		
		//Create new memberships
		List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
		for(Id studentID : studentIds){
			CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=studentId,CollaborationGroupId =studentServicesGroup[0].id );
			newMembers.add(newMembership);
			
		}	
		insert newMembers;	
		
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
    
    
    
}
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
		set<string> Groups = new Set<string>();
		set<string> GroupIds = new Set<string>();
		Groups.add('Student Services');
		Groups.add('AAU Campus Admin');
		
		//Retrieve Student Service Chatter group
		List<CollaborationGroup> studentServicesGroup = [Select id,name from CollaborationGroup where name in :Groups ];
		if(studentServicesGroup.size() == 0){
			system.debug('CollaborationGroup Student Services does not exist');
			return;
		}
		map<ID,set<ID>> existingMembersMap = new map<ID,set<ID>>();
		
		for(CollaborationGroup grp:studentServicesGroup){
			GroupIds.add(grp.id);
			existingMembersMap.put(grp.id,new set<ID>());
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
																  and CollaborationGroupId in :GroupIds];
		
		system.debug('_________________' + existingMembership);
		
		//Remove ids with existing memberships 													  
		for(CollaborationGroupMember member : existingMembership)	{
			existingMembersMap.get(member.CollaborationGroupId).add(member.MemberId);
			//studentIds.remove(member.MemberId);
		}	
		
		List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
		for(Id studentID : studentIds){
			for(ID groupId : GroupIds)	{
				
				if(!existingMembersMap.get(groupId).contains(studentID)){
					CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=studentID,CollaborationGroupId =groupId);
					newMembers.add(newMembership);
					
				}
				
			}
		}  
		
		insert newMembers;	
		
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
    
    
    
}
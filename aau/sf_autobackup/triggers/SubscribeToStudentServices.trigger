trigger SubscribeToStudentServices on User (after insert,after update) {
	
	System.debug('SubscribeToStudentServices _______' );
	//retrieve Student profile
	List<Profile> stdProfile = [Select id,name from Profile where name = 'AAU Student - Platform' limit 1];
	if(stdProfile.size() == 0){
		system.debug('Student profile does not exist');
		return;
	}
	string GroupName = 'Student Services';
	set<string> Groups = new Set<string>();
	set<string> GroupIds = new Set<string>();
	
	/*
	Groups.add('Student Services');
	Groups.add('AAU Campus Admin');
	
	//Retrieve Student Service Chatter group
	List<CollaborationGroup> studentServicesGroup = [Select id,name from CollaborationGroup where name in :Groups ];
	if(studentServicesGroup.size() == 0){
		system.debug('CollaborationGroup Student Services does not exist');
		return;
	}
	*/
	map<ID,set<ID>> existingMembersMap = new map<ID,set<ID>>();
	
	/*
	 * Updates by Virendra related to Student Services Chatter Group customizable
	 */
	//Map<id,boolean> allStudentGroups = new Map<id,boolean>();  
	//for(Student_Group__c sGroup:[Select Group_Id__c,All_Students__c From Student_Group__c where Name in :Groups]){
	for(Student_Group__c sGroup:[Select Name,Group_Id__c,All_Students__c From Student_Group__c where All_Students__c = true]){
		//allStudentGroups.put(sGroup.Group_Id__c,sGroup.All_Students__c);
			GroupIds.add(sGroup.Group_Id__c);
			existingMembersMap.put(sGroup.Group_Id__c,new set<ID>());
	}
/*	
	for(CollaborationGroup grp:studentServicesGroup){
		/* 
	 	 * If All_Students__c = True, then will add any new/edited student records to the proper Chatter Group 
		 *
		if(allStudentGroups.containsKey(grp.id) && allStudentGroups.get(grp.id)){
			GroupIds.add(grp.id);
			existingMembersMap.put(grp.id,new set<ID>());
		}
	}
*/
	
	if(!GroupIds.isEmpty()){
		//Create set of Student ids
		Set<id> studentIds =new Set<Id>();
		for(User u : trigger.new){
			if(u.profileId == stdProfile[0].id){
				studentIds.add(u.id);
			}
		}
		
		if(studentIds.size() == 0){
			system.debug('No students in list of new students');
			return;
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
		
		list<string> newMembersList = new list<string>();
		
		
		for(Id studentID : studentIds){
			for(ID groupId : GroupIds)	{
				if(!existingMembersMap.get(groupId).contains(studentID)){
					newMembersList.add(groupId + '-' +studentID);
				}
				//studentIds.remove(member.MemberId);
			}
		}  
		
		
		mob_studentSubscriptionHelper.addMembers(newMembersList)	;	    					
	}
	
}
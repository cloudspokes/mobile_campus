trigger SubscribeToStudentServices on User (after insert,after update) {
	
	System.debug('SubscribeToStudentServices _______' );
	//retrieve Student profile
	List<Profile> stdProfile = [Select id,name from Profile where name = 'AAU Student - Platform' limit 1];
	if(stdProfile.size() == 0){
		system.debug('Student profile does not exist');
		return;
	}
	string GroupName = 'Student Services';
	
	//Retrieve Student Service Chatter group
	List<CollaborationGroup> studentServicesGroup = [Select id,name from CollaborationGroup where name = :GroupName limit 1];
	if(studentServicesGroup.size() == 0){
		system.debug('CollaborationGroup Student Services does not exist');
		return;
	}
	
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
															  and CollaborationGroupId =:studentServicesGroup[0].id];
	
	//Remove ids with existing memberships 													  
	for(CollaborationGroupMember member : existingMembership)	{
		studentIds.remove(member.MemberId);
	}	
	
	//Create new memberships
	/*List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
	for(Id studentID : studentIds){
		CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=studentId,CollaborationGroupId =studentServicesGroup[0].id );
		newMembers.add(newMembership);
		
	}	
	insert newMembers;	
	*/
	mob_studentSubscriptionHelper.addMembers(studentIds,studentServicesGroup[0].id)	;	   					
	
}
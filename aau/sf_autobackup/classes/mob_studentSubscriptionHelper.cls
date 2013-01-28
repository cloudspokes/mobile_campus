global without sharing class mob_studentSubscriptionHelper {
	@future
	 public static void addMembers(Set<Id> studentIds,Id groupId) {
	 	
	 	List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
		for(Id studentID : studentIds){
			CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=studentId,CollaborationGroupId =groupId );
			newMembers.add(newMembership);
			
		}	
		insert newMembers;	
	 	
	}

}
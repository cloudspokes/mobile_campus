global without sharing class mob_studentSubscriptionHelper {
	/*@future
	 public static void addMembers_old(Set<Id> studentIds,Id groupId) {
	 	
	 	List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
		for(Id studentID : studentIds){
			CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=studentId,CollaborationGroupId =groupId );
			newMembers.add(newMembership);
			
		}	
		insert newMembers;	 
	 	
	}
	*/
	@future
	 public static void addMembers(list<string> newMembersList) {
	 	
	 	List<CollaborationGroupMember> newMembers = new List<CollaborationGroupMember>();
	 	
	 	
	 	for(string membership:newMembersList){
	 		 string grpId = membership.split('-')[0];
	 		 string stdId = membership.split('-')[1];
	 		 CollaborationGroupMember newMembership= new CollaborationGroupMember(MemberId=stdId,CollaborationGroupId = grpId,NotificationFrequency = 'N' );
			 newMembers.add(newMembership);
	 		 
	 	}
	 	 
	 	insert newMembers;	  
	 	
	}  

}
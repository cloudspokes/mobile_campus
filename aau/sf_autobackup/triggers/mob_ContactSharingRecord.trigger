trigger mob_ContactSharingRecord on Contact (after insert, after update) {
	 
	List<ContactShare> newContactShares = new List<ContactShare>();
	Map<Id,set<Id>> delContactShares = new Map<Id,set<Id>>();
	Id currentUserId = Userinfo.getUserId();
	
	//Updated as per T-83584 ContactShare Trigger: check if User is Active
	List<Id> contactStudentUsers = new List<Id>();
	for(Contact con:Trigger.new){
		if(con.Student_user__c != null){
		  contactStudentUsers.add(con.Student_user__c);
		}
	}
	
	Map<Id,User> inactiveUsers = new Map<Id,User>([Select Id From User where id in :contactStudentUsers and IsActive = false]);
	 
	for(Contact con:Trigger.new){
		/* if(inactiveUsers.containsKey(con.Student_user__c)){
		   		con.addError('Please Select Active Student User');
		 }*/
		//Check if Conatct is for Update and Student User Changed 
		if(trigger.oldMap != null && trigger.oldMap.get(con.id).Student_user__c != con.Student_user__c){
				//Student User removed from Contact so put it for deleted the share records
				if(delContactShares.containsKey(con.Id)){
					delContactShares.get(con.Id).add(trigger.oldMap.get(con.id).Student_user__c);	
				}else{
					Set<Id> users = new Set<Id>();
					users.add(trigger.oldMap.get(con.id).Student_user__c);
					delContactShares.put(con.Id,users);
				}
				if(con.Student_user__c != null && !inactiveUsers.containsKey(con.Student_user__c)){
					ContactShare conShare = new ContactShare();
					conShare.UserOrGroupId = con.Student_user__c;
					conshare.contactId = con.Id;
					conshare.ContactAccessLevel ='read';
					newContactShares.add(conShare);
				}
		
		}
		//Check for New Contact Insert and Student User Availbale  
		if(trigger.isInsert && con.Student_user__c != null && !inactiveUsers.containsKey(con.Student_user__c)){
			if(currentUserId == con.Student_user__c){
				   con.addError('Please Select Other Student User');
				   break;
		    }
			ContactShare conShare = new ContactShare();
			conShare.UserOrGroupId = con.Student_user__c;
			conshare.contactId = con.Id;
			conshare.ContactAccessLevel ='read';
			newContactShares.add(conShare);
		}
	}
	
	if(!newContactShares.isEmpty()){
		insert newContactShares;
	}
	
	//Delete  ContactShare Records  
	if(!delContactShares.isEmpty()){
		List<ContactShare> delShareRecords = new List<ContactShare>(); 
		List<Id> userIds = new List<Id>();
		
		for(Id keyId:delContactShares.keySet()){
		    userIds.addAll(delContactShares.get(keyId));	
		}
		for(ContactShare conShare:[Select id,UserOrGroupId,contactId  from contactShare where UserOrGroupId in: userIds and contactId in:delContactShares.keySet() and rowcause='manual']){
		 	if(delContactShares.containsKey(conShare.contactId) && delContactShares.get(conShare.contactId).contains(conShare.UserOrGroupId)){
		 		delShareRecords.add(conShare);
		 	}
		 }
		if(!delShareRecords.isEmpty()){
		  delete delShareRecords;	
		}
	}
		  
}
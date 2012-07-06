public with sharing class LastActivity {

	public static void updateContact(List<Task> tasks) {
		Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
		List<Task> tasklist;
		
		for (Task task:tasks) {
 			if (task.Status == 'Completed' && task.WhoId != null
 				&& task.Admin_Function__c == null 
 				&& task.LastModifiedById == task.OwnerId) {
 				String whoId = task.WhoId;
 				String whoIdPrefix = whoId.substring(0,3);
 				// Contacts start with '003'
 				if (whoIdPrefix == '003') {
 					if (taskMap.containsKey(whoId)) {
 						tasklist = taskMap.get(whoId);
						tasklist.add(task);
 					} else {
 						tasklist = new List<Task>();
 						tasklist.add(task);
 						taskMap.put(whoId, tasklist);
 					}
 				}
 			}
		}
		
		List<Contact> contacts = [Select Id, OwnerId, OwnerLastActivityDate__c,
									     Lead_owner_change_date__c 
								  From Contact where Id in :taskMap.keySet()];
		List<Contact> contactsToUpdate = new List<Contact>();
		for (Contact contact: contacts) {
			tasklist = taskMap.get(contact.Id);
			for (Task task:tasklist) {
				if (task.OwnerId == contact.OwnerId 
					&& (contact.OwnerLastActivityDate__c < task.LastModifiedDate
						|| contact.OwnerLastActivityDate__c == null)
					&& contact.Lead_owner_change_date__c < task.LastModifiedDate) 
					{
						contact.OwnerLastActivityDate__c = task.LastModifiedDate;
						contactsToUpdate.add(contact);					
				} 
			}
		}
		if (!contactsToUpdate.isEmpty()) {
			update contactsToUpdate;
		}
	}
}
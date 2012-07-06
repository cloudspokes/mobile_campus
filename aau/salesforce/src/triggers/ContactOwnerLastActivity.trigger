trigger ContactOwnerLastActivity on Task (after insert, after update) {

	List<Task> tasks = new List<Task>();
	
	for (Task task:trigger.new) {
		if (task.Status == 'Completed') {
			if (trigger.isInsert) {
				tasks.add(task);
			} else {
				Task otask = trigger.oldMap.get(task.Id);
				if (task.Status != otask.Status) {
					tasks.add(task);
				}				
			}
		}
	}

	if (!tasks.isEmpty()) {
		LastActivity.updateContact(tasks);
	}
}
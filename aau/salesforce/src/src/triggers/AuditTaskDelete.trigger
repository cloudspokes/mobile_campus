trigger AuditTaskDelete on Task (before delete) {
	/* Undergrad reps cannot delete tasks they did not create, 
	   even if they own them.
	*/
	if (UserInfo.getProfileId() == '00e800000012jLNAAY') {
		for (Task t: Trigger.old) {
			if (t.CreatedById != UserInfo.getUserId() || t.Status == 'Completed') {
				t.addError('You do not have permission to delete this task.');
			}
		}
	}

}
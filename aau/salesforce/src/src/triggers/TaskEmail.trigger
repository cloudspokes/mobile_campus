trigger TaskEmail on Task (before update) {
    List<Task_Email__c> emails = new List<Task_Email__c>();
    for (Task t: Trigger.new) {
        if (t.Send_Email__c != null) {
            Task_Email__c em = new Task_Email__c();
            em.OwnerId = t.OwnerId;
            em.TaskId__c = t.Id;
            em.Name = t.Send_Email__c;
            em.ContactId__c = t.WhoId;
            emails.add(em);
            t.Send_Email__c = null;
        }
    }
    if (!emails.isEmpty()) {                                                          
        insert emails;
    }
}
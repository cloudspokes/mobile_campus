trigger EventEmail on Event (before update) {
    List<Event_Email__c> emails = new List<Event_Email__c>();
    for (Event e: Trigger.new) {
        if (e.Send_Email__c != null) {
            Event_Email__c em = new Event_Email__c();
            em.OwnerId = e.OwnerId;
            em.EventId__c = e.Id;
            em.Name = e.Send_Email__c;
            em.Contact__c = e.WhoId;
            em.StartDateTime__c = e.StartDateTime;
            emails.add(em);
            e.Send_Email__c = null;
        }
    }
    if (!emails.isEmpty()) {                                                          
        insert emails;
    }
}
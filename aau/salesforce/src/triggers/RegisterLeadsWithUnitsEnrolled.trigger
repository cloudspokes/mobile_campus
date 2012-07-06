/**
 * if a lead has units enrolled their recruiting status should be changed to registered
 */
trigger RegisterLeadsWithUnitsEnrolled on Admissions_Opportunity__c (after insert, after update) {

    List<Id> leads = new List<Id>();

    
    for (Admissions_Opportunity__c application : Trigger.new) {
        if (application.Current_No_of_Units_Enrolled__c != null)
        {
            Double currUnits = Double.valueOf(application.Current_No_of_Units_Enrolled__c);
            if(Trigger.isInsert && currUnits > 0)
            {
                leads.add(application.Lead__c);
            }
            else if(Trigger.isUpdate && Trigger.oldMap.get(application.Id).Current_No_of_Units_Enrolled__c != application.Current_No_of_Units_Enrolled__c && currUnits > 0)
            {
                leads.add(application.Lead__c);
            }
        }
    }
    
    if(!leads.isEmpty())
    {
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c: [select id, Recruiting_Status__c from Contact where id in :leads])
        {
            c.Recruiting_Status__c = 'Registered';
            contactsToUpdate.add(c);
        }
        update contactsToUpdate;
    }
}
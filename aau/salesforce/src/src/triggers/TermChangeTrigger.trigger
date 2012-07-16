trigger TermChangeTrigger on Term__c (after update) {
/*
    List<String> terms = new List<String>();
    for(Term__c t : trigger.new)
    {
        //if a term has become current, we need to reassign anyone that had start_term which is
        //now current, we need to run assignment rules for them again
        if(t.Is_Current_Term__c == true && trigger.oldMap.get(t.Id).Is_Current_Term__c == false)
        {
            //need to get all contact where term == new term
            terms.add(t.Name);
        }
        //if term changed from being current, we need to reassign anyone that was in current term
        else if(t.Is_Current_Term__c == false && trigger.oldMap.get(t.Id).Is_Current_Term__c == true)
        {
            terms.add(t.Name);
        }
    }
    
    if(!terms.isEmpty())
    {
        List<String> recruitingStatus = new List<String>();
        recruitingStatus.add('Inquiry');
        recruitingStatus.add('Contacted');
        recruitingStatus.add('Prospect');
        recruitingStatus.add('Applicant');
        recruitingStatus.add('Registered');
        recruitingStatus.add('Uninterested');
        recruitingStatus.add('Ineligible');
        
        List<String>recordTypes = new List<String>();
        recordTypes.add('012800000002dPnAAI');
        recordTypes.add('012800000002dKrAAI');
        recordTypes.add('012800000002dLxAAI');
        
        //results can be over 1000, so we need to batch process. This will mean that the body
        //of the for loop will execute once for every 200 records.
        List<Contact> allContacts = new List<Contact>();
        
        for( List<Contact> contactBatch : 
            [Select c.Zip_Postal_Code__c, c.Transcript_Review_Completed__c, c.Title,
                    c.Telemarketer_Lead_Sent_Successfully__c, c.Telemarketer_Assignment_Cancelled__c, 
                    c.Street__c, c.Status__c, c.State_Province__c, c.Start_Term_Latest_Opp__c, 
                    c.Service_Indicators_Non_Editable__c, c.Service_Indicators_Editable__c, 
                    c.Residency_Status__c, c.Referral_Source__c, c.Recruiting_Status__c, c.Recruiting_Center_Latest_Opp__c, 
                    c.RecordTypeId, 
                    c.Phone, c.OwnerId, 
                    c.No_of_Transcripts_Reviewed__c, c.Name, 
                    c.MobilePhone,  c.LastName,   
                    c.IsDeleted, c.HomePhone, 
                    c.Have_you_taken_classes_at_AAU_before__c, c.FirstName,
                    c.Email, c.Department,c.Country_of_Citizenship__c, 
                    c.Country__c, c.Contact_Type__c,  c.City__c, c.Career_Latest_Opp__c, 
                    c.Application_Status_Latest_Opp__c, c.Age__c
                From Contact c
                Where c.OwnerId != null And c.Owner.Admissions_Group__c != null And c.Start_Term_Latest_Opp__c != null
                 And c.Recruiting_Status__c != null And c.IsDeleted != null And c.RecordTypeId != null
                And c.Start_Term_Latest_Opp__c in :terms 
                And c.Recruiting_Status__c in :recruitingStatus
                And c.IsDeleted = false
                And c.RecordTypeId in :recordTypes
                And c.Owner.Admissions_Group__c = 'Early Admissions'])
            {
                if(!contactBatch.isEmpty())
                    allContacts.addAll(contactBatch);
            }
            
            // now we have all the records, asign the suckers
            //note: if we cant have this many items in a list, we will need to move it back into the for loop,
            //and potentially assignLeads 200 at a time.
            if(!allContacts.isEmpty())
            {
                LeadAssignmentManager mgr = new LeadAssignmentManager();
                List<Contact> updatedLeads = mgr.assignLeads(allContacts);
                
                if(!updatedLeads.isEmpty())
                    update updatedLeads;
            }
    }
*/    
}
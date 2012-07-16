global class LeadSearchSharingPurge implements Schedulable, Database.Batchable<sObject> {

	public static void schedule() {
		/* Schedule job to run every hour on the hour.
		   Current online scheduler only allows for daily at most.
		   To run, execute LeadSearchSharingPurge.schedule() anonymously.
		 */
		LeadSearchSharingPurge b = new LeadSearchSharingPurge();
		System.schedule('Purge Lead Search Sharing', '0 0 * * * ?', b);
	}
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	Datetime current_dttm = datetime.newinstance(System.currentTimeMillis());
    	Datetime lastmodified_dttm = current_dttm.addHours(-1);
    	
        String soql = 'Select c.Id, c.LastModifiedById, c.UserOrGroupId ' +
        			  'from ContactShare c  ' + 
        			  'where c.RowCause = \'Manual\' ' +
        			  'and c.LastModifiedDate < ' + 
        			  lastmodified_dttm.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') ;
        return Database.getQueryLocator(soql);
    }
    
   	global void execute(Database.BatchableContext BC, SObject[] batch) {
        Map<String, ContactShare> sharing = new Map<String, ContactShare>();
        for (sObject s : batch) {
            ContactShare c = (ContactShare)s;
            if (c.LastModifiedById == c.UserOrGroupId) {
            	sharing.put(c.Id, c);
            }
        }

        if (!sharing.isEmpty()) {
        	delete sharing.values();
        }

    }
    
    global void execute(SchedulableContext sc) {
		LeadSearchSharingPurge b = new LeadSearchSharingPurge(); 
    	Database.executebatch(b);
	}
 	
 	global void finish(Database.BatchableContext BC) {
    }
         
}
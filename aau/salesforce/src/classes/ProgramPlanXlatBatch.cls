global class ProgramPlanXlatBatch implements Database.Batchable<sObject>, Database.Stateful {

	private String extraParams;
	private ProgramPlanXlat xlat;
	
	global ProgramPlanXlatBatch() {
		this(null);
	}
	
	global ProgramPlanXlatBatch(String extraParams) {
		xlat = new ProgramPlanXlat();
		this.extraParams = extraParams;	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query;
		query = 'select Id, Program__c, Plan__c, Sub_Plan__c, ' +
		        'Admissions_Opportunity__c, ' + 
		        'Psft_Plan_Id__c ' +
		        'from Program_Plan_SubPlan__c';
		if (extraParams != null){
			query = query + ' ' + extraParams;
		}
		return Database.getQueryLocator(query);
	}
	
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Program_Plan_SubPlan__c> plans = new List<Program_Plan_SubPlan__c>();
		for (sObject s : scope) {
			Program_Plan_SubPlan__c plan = (Program_Plan_SubPlan__c) s;
			plans.add(plan);
		}
		List<Program_Plan_SubPlan__c> result = xlat.repair(plans).get(True);
		if (result.size() > 0) {
			update result;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
	}

}
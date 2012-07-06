public with sharing class ProgramPlanXlat {
	
	@future
	private static void updateSettings(List<String> values) {
		List<ProgramPlanXlatPs2Sf__c> settings = new List<ProgramPlanXlatPs2Sf__c>();
		Integer i = 0;
		while (i < values.size()) {
			// TODO: Should we check if an upsert is necessary?
			settings.add(new ProgramPlanXlatPs2Sf__c(Name = values[i++],
													 Sfdc_Lookup_Id__c = values[i++],
													 Program_Plan_Value_Id__c = values[i++]));
		}
		
		if (!settings.isEmpty()) {
			upsert settings Program_Plan_Value_Id__c;
		}
	}
	
	public static void updateSettings(List<Program_Plan_Value__c> values) {
		List<String> settings = new List<String>();
		for (Program_Plan_Value__c val : values) {
			settings.addAll(new List<String>{val.Psft_Lookup_Id__c,
											 val.Sfdc_Lookup_Id__c,
											 val.Id});
		}
		if (!settings.isEmpty()) {
			updateSettings(settings);
		}
	}
	
	public static void updateSettings() {
		updateSettings([select Id,
							   Psft_Lookup_Id__c,
							   Sfdc_Lookup_Id__c
						from Program_Plan_Value__c]);	
	}
	
	
	// byPicklist - used to lookup PeopleSoft Id for records entered online
	// Would use another Custom Settings object but the keys are too long.
	private Map<String, String> byPicklist = new Map<String, String>();
	
	private String getPsftLookupKey(String sfdc_lup_key) {
		// Tried populating byPicklist with all values in the constructor.
		// That resulted in the debug log capturing all of the get and put
		// method calls needed, which exceeded the maximum debug log length.
		// So, now we are just going to loop through the setting's values,
		// caching the result, as needed.
		if (sfdc_lup_key == null) {
			return null;
		}
		String result = byPicklist.get(sfdc_lup_key);
		if (result == null) {
			for(ProgramPlanXlatPs2Sf__c val: ProgramPlanXlatPs2Sf__c.getall().values()) {
				if (val.Sfdc_Lookup_Id__c == sfdc_lup_key) {
					// store it so we don't need to do this again
					result = val.Name;
					byPicklist.put(sfdc_lup_key, result);
					return result;
				}
			}
		}
		return result;
	}
	
	private String getSfdcLookupKey(String psft_lup_key) {
		if (psft_lup_key == null) return null; // BUG: 2010-02-09 - (API version 18) null key with 'getInstance()' on "Custom Setting" returns erroneous value instead of null
		ProgramPlanXlatPs2Sf__c result = ProgramPlanXlatPs2Sf__c.getInstance(psft_lup_key);
		if (result != null ) {
			return result.Sfdc_Lookup_Id__c;
		}
		return null;
	}
	
	private String getPsftLookupKey(Program_Plan_SubPlan__c plan) {
		if (plan.Psft_Plan_Id__c == null) {
			return null;
		}

		// remove the opportunity Id from plan's external id
		List<String> parts = plan.Psft_Plan_Id__c.split('\\*', 2);
		if (parts.size() < 2 || parts[1] == null) {
			return null;
		}
		String result = parts[1];
		
		if (getSfdcLookupKey(result) == null) {
			return null;
		}
		return result;
	}
	
	private String getSfdcLookupKey(Program_Plan_SubPlan__c plan) {
		if (plan.Program__c == null || plan.Plan__c == null) {
			return null;
		}
		String result = plan.Program__c + ';' + plan.Plan__c;
		if (plan.Sub_Plan__c != null) {
			result = result + ';' + plan.Sub_Plan__c;
		}
		
		return result;
	}
	
	private Boolean setPsftId(Program_Plan_SubPlan__c plan) {
		String key = getPsftLookupKey(getSfdcLookupKey(plan));
		if (key != null) {
			plan.Psft_Plan_Id__c = plan.Admissions_Opportunity__c + '*' + key;
			return True;
		}
		plan.Psft_Plan_Id__c = null;
		return False;
	}	

	private Boolean setPicklistValues(Program_Plan_SubPlan__c plan) {
		String key = getSfdcLookupKey(getPsftLookupKey(plan));
		if (key != null) {
			List<String> picklistValues = key.split(';', 3);
			// guarantee at least three values in list
			picklistValues.addAll(new List<String>{'', '', ''});
			plan.Program__c = picklistValues[0];
			plan.Plan__c = picklistValues[1];
			plan.Sub_Plan__c = picklistValues[2];
			return True;
		}
		plan.Program__c = null;
		plan.Plan__c = null;
		plan.Sub_Plan__c = null;
		return False;
	}
	
	public Map<Boolean, List<Program_Plan_SubPlan__c>> repair(List<Program_Plan_SubPlan__c> plans) {
		List<Program_Plan_SubPlan__c> fixed = new List<Program_Plan_SubPlan__c>();
		List<Program_Plan_SubPlan__c> invalid = new List<Program_Plan_SubPlan__c>();
		List<Program_Plan_SubPlan__c> valid = new List<Program_Plan_SubPlan__c>();
		
		for (Program_Plan_SubPlan__c plan : plans) {
			String key_by_psft_id = getSfdcLookupKey(getPsftLookupKey(plan));
			String key_by_sfdc_id = getSfdcLookupKey(plan);
			if (key_by_psft_id == key_by_sfdc_id) {
				if (key_by_psft_id == null) {
					System.assert(key_by_psft_id == null && key_by_sfdc_id == null);
					// both values are null, can't fix
					invalid.add(plan);
				} else {
					valid.add(plan);
				}
			} else if (key_by_psft_id == null) {
					if (setPsftId(plan)) {
						fixed.add(plan);
					} else {
						invalid.add(plan);
					}
			} else if (key_by_sfdc_id == null) {
					if (setPicklistValues(plan)) {
						fixed.add(plan);
					} else {
						invalid.add(plan);
					}
			} else {
				// Should never get here
				System.assert(false, '[' + key_by_psft_id + ' <> ' + key_by_sfdc_id + ']');
			}
		}

		Map<Boolean, List<Program_Plan_SubPlan__c>> result = new Map<boolean, List<Program_Plan_SubPlan__c>>();
		result.put(True, fixed);
		result.put(null, valid);
		result.put(False, invalid);
		//System.debug('Results of repair: ' + result);
		return result;
	}
		
}
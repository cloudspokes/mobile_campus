public with sharing class Utilities {

	public static void limitPicklistCount(SObject sobj, String val, Integer max, Schema.Sobjectfield fld) {
		/* Restrict number of values allowed in a multi-select picklist.
		   Sample usage:
			 for (Contact c: Trigger.new) {
		         Utilities.limitPicklistCount(c, c.Service_Indicators_Editable__c, 4, Contact.Service_Indicators_Editable__c);
	         }
	    */
	    if (val != null) {
			String[] vals = val.split(';');
			String label = fld.getDescribe().getLabel();
			if (vals.size() > max) {
    			sobj.addError('Maximum of '+ max +' values allowed for ' + label + '.');
			}
	    }    			
	}
	
}
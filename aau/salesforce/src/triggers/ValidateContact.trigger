trigger ValidateContact on Contact (before insert, before update) {

for (Contact c: Trigger.new) {

  if(c.Educator_type__c != null) {
    Utilities.limitPicklistCount(c, c.Educator_Type__c, 2, Contact.Educator_Type__c);
  }
  if(c.Classes_Taught__c != null) {
    Utilities.limitPicklistCount(c, c.Classes_Taught__c, 3, Contact.Classes_Taught__c);
  }
 }
}
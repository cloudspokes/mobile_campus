trigger ServiceIndicatorEditToPSFT on Contact (before update) {

	if (UserInfo.getProfileId() != '00e800000012o2gAAA') {

		for (Contact contact : Trigger.New) {
			if (contact.Service_Indicators_Editable__c != Trigger.oldMap.get(contact.Id).Service_Indicators_Editable__c) {
				contact.Send_Lead_to_PSFT__c = true;
			}	
		}
	}
}
@isTest
private class mob_LinksREST_Test {

	static testmethod void testmobLinkRest() {
		Mobile_Links__c mobLink = new Mobile_Links__c();
		mobLink.name = 'Test Link 1';
		mobLink.Url__c = 'www.testLink1.com';
		mobLink.Active__c = true;
		insert mobLink;
		
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        // pass the req and resp objects to the method		 
        req.requestURI = 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/ExternalLinks';  
        req.httpMethod = 'GET';
		mob_LinksREST.getExternalLinks(req,res);
	}

}
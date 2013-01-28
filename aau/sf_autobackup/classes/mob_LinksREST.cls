//
// Tim Pickard - Changed query to order by Order__c 8/20/2012
//
@RestResource(urlMapping='/ExternalLinks')
global with sharing class mob_LinksREST {
    
    @HttpGet
    global static List<ExtenralLink> getExternalLinks(RestRequest req, RestResponse res) {
        List<ExtenralLink> links = new List<ExtenralLink>();
        for(Mobile_Links__c link:[Select Name,Url__c from Mobile_Links__c where Active__c =:true ORDER BY Order__c NULLS LAST]){
            ExtenralLink elink = new ExtenralLink();
            elink.linkName = link.name;
            elink.linkUrl = link.Url__c;
            links.add(elink);
        }
        return links;
    }
    
    global class ExtenralLink{
        public String linkName{get;set;}
        public String linkUrl{get;set;}
    }

}
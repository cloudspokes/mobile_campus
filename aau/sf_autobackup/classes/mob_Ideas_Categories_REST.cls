@RestResource(urlMapping='/ideaCategories/*')	
global with sharing class mob_Ideas_Categories_REST {
    @HttpGet
    global static List<String> getCategories() {
    	List<string> categoryList = new List<string>();

    	 Schema.DescribeFieldResult fieldResult = Idea.Categories.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple)
	   {
	      categoryList.add(f.getLabel()); 
	   }
    	
    	return 	categoryList;
    }
}
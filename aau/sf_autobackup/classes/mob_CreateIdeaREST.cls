@RestResource(urlMapping='/creteIdea/*')
global with sharing class  mob_CreateIdeaREST {
	
	 @HttpGet
    global static String   createNewIdea() {
    	RestRequest req = RestContext.request;
    	Map<String,String> qryParams =  req.params;
    	NewIdea newIdea = new NewIdea();
    	if(qryParams != null){ 
	    	if(qryParams.containsKey('title') && qryParams.get('title') != null)
	    	    newIdea.title = qryParams.get('title');
	        if(qryParams.containsKey('ideaCategory') && qryParams.get('ideaCategory') != null)    	{    
	    	 //   newIdea.ideaCategory = qryParams.get('ideaCategory');
	        }
	    	if(qryParams.containsKey('description') && qryParams.get('description') != null)    	    
	    	    newIdea.description = qryParams.get('description');
	    	if(qryParams.containsKey('owner') && qryParams.get('owner') != null)   { 	    
	    	    //newIdea.owner = qryParams.get('owner');    
	    	}
    	}else{
    		return 'Parameter missing to create New Idea';
    	}
    	
    	try{
    		createNewIdea(newIdea);
    		return 'New idea created';
    	}catch(Exception ex){
    		return ex.getMessage();
    	}
    	
    }
    
    private static void createNewIdea(NewIdea newIdea){
    	String communityId;
    	for(Community ideaCommunity:[Select Id From Community  where  name = 'Student Ideas' and isActive=true]){
    		communityId = IdeaCommunity.Id;
    	}
    	Idea createIdea = new Idea();
    	createIdea.CommunityId = communityId;
    	createIdea.Title = newIdea.title;
    	createIdea.Body = newIdea.description;
    	createIdea.Categories =  newIdea.ideaCategory;
    	insert createIdea;
    }
    
     private class NewIdea{
    	private  String  title;
    	private  String  ideaCategory;
		private  String  description;
        private  String  owner;
        private  String ideaCommunity='Student Ideas'; 
    }
    	
}
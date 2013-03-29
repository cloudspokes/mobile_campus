@RestResource(urlMapping='/voteToIdea/*')
global with sharing class mob_VoteIdeaREST {

	 @HttpGet
    global static String voteAndCommentOnIdea(){
        RestRequest req = RestContext.request;
    	Map<String,String> qryParams =  req.params;
        String ideaId;
        String ideaComment;
        String thumbsUp;
        String thumbsDown;
            	
        if(qryParams != null){       	                    
	    	if(qryParams != null && qryParams.containsKey('ideaId') && qryParams.get('ideaId') != null){
	    	  	ideaId = qryParams.get('ideaId');
	    	}      
	    	if(qryParams != null && qryParams.containsKey('ideaComment') && qryParams.get('ideaComment') != null){
	    	  	ideaComment = qryParams.get('ideaComment');
	    	}
	    	if(qryParams != null && qryParams.containsKey('thumbsUp') && qryParams.get('thumbsUp') != null){
	    	  	thumbsUp = qryParams.get('thumbsUp');
	    	}
	    	if(qryParams != null && qryParams.containsKey('thumbsDown') && qryParams.get('thumbsDown') != null){
	    	  	thumbsDown = qryParams.get('thumbsDown');
	    	}   
	    	if(ideaId != null && isValidIdea(ideaId)){
	    		 if(ideaComment != null){
	    		 	/*
	    		 	  Create new Comment on given idea 
	    		 	*/
	    		 	createComment(ideaId,ideaComment);
	    		 }else{
	    		 	return 'Comment Test Missing';
	    		 }
	    		 /*
	    		   Create Vote on given idea 
	    		 */
	    		 createVote(ideaId,thumbsUp,thumbsDown);
	    	}else{
	    		return 'Idea Id for comment is missing';
	    	}
        }else{
        	return 'Parameter missing for Idea Comment and Vote';
        }
        return 'Idea Voted / Comments successfully';
    }
    
    private static void createComment(String ideaId,String commentBody){
    	IdeaComment iComment = new IdeaComment();
    	iComment.CommentBody = commentBody;
    	iComment.IdeaId = ideaId;
    	insert iComment;
    }
    
    private static boolean isValidIdea(String ideaId){
      for(Idea checkIdea :[Select id from Idea where id=:ideaId and Community.Name =:'Student Ideas']){
      	return true;
      }	
      return false;	
    }
    
    private static void createVote(String ideaId,String thumbsUp,STring thumbsDown){
	   	Vote newVote = new Vote(); 
	   	newVote.ParentId = ideaId;
	   	if(thumbsUp != null)
	   		newVote.Type ='Up';
	   	else if(thumbsDown != null)
	   	    newVote.Type ='Down';
	   	insert newVote;     	 
    }
}
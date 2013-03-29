@RestResource(urlMapping='/ideas/*')
global with sharing class mob_GetIdeasREST {

    @HttpGet
    global static List<PopularIdea> getIdeas() {
    	List<popularIdea> popularIdeasList = new List<popularIdea>();

    	String ideaQuery =  'Select id,VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, LastCommentId,CreatedDate,'+
    	                    'Community.Name, CommunityId, Categories, CreatedBy.Name,Body,(Select Id, IdeaId, CommentBody, CreatedBy.Name, CreatedDate,'+
    	                    'IsHtml From Comments),(Select Id, ParentId, Type, CreatedDate, CreatedBy.Name From Votes where  Isdeleted= false)'+
    	                    'From Idea where Community.Name = \'Student Ideas\'';
        
        RestRequest req = RestContext.request;
    	Map<String,String> qryParams =  req.params; 
    	
    	boolean getLatest = false;
    	boolean isSearch = false;
    	if(qryParams != null){       	                    
	    	if(qryParams.containsKey('category') && qryParams.get('category') != null){
	    	  	ideaQuery += ' And Categories=\''+qryParams.get('category')+'\'';
	    	}      
	    	if(qryParams.containsKey('searchTerm') && qryParams.get('searchTerm') != null){
	    	  	ideaQuery += ' And (Title like \'%'+qryParams.get('searchTerm')+'%\'';
	    	  	ideaQuery += ' OR Categories includes (\''+qryParams.get('searchTerm')+'\'))'; 
	    	 	
	    	 	isSearch =true; 			
	    	}
	    	
	    	if(qryParams.containsKey('getLatest') && qryParams.get('getLatest') != null){
	    	  	getLatest = true; 
	    	}              
    	}
    	
    	if (getLatest){
    		ideaQuery +=  '  order by  CreatedDate desc limit 50';
    	}else{
    		ideaQuery +=  '  order by  voteTotal desc limit 50';
    	}
    	
    	System.debug(':: ideaQuery:: ::'+ideaQuery);  
    	   
    	for(Idea popularIdea:Database.query(ideaQuery)){
    	    /*
    	     * If there are multiple categories selected for single Idea Then it is 
    	     * creating the duplicate idea for each category
    	     TODO:: Confirm with tony on this case how to create the record
    	    */	
    	    if(isSearch){
	    	 		PopularIdea newIdea = createNewPopularIdea(popularIdea);
	    	 		if(popularIdea.Categories <> null && popularIdea.Categories <> ''){
	    	 			newIdea.ideaCategory = popularIdea.Categories.replace(';', ' ');
	    	 		}
	    	   		popularIdeasList.add(newIdea);
    	    }
    	    else{
    	   		for(String ideaCategory:toList(popularIdea.Categories)){
	    	 		PopularIdea newIdea = createNewPopularIdea(popularIdea);
	    	 		newIdea.ideaCategory = ideaCategory;
	    	   		popularIdeasList.add(newIdea);
	    	    }
    	    }
    	}
    	
    	if (!getLatest){
	    	/*
	    	  Sort the Ideas on The Idea Category Ascending
	    	*/
	    	sortIdeaOnCategoryList(popularIdeasList,'asc');
	    	Map<String,List<PopularIdea>> popularMaps = new Map<String,List<PopularIdea>>();
	    	Set<String> categorySet = new Set<String>(); 
	    	
	    	for(PopularIdea pIdea:popularIdeasList){
	    		if(!categorySet.contains(pIdea.ideaCategory))
	    	 		categorySet.add(pIdea.ideaCategory);
	    	    /*
	    	      Create map of category with  list of ideas to sort on Votes Descending  
	    	    */ 		
	    	 	if(!popularMaps.containsKey(pIdea.ideaCategory)){
	    	 	   popularMaps.put(pIdea.ideaCategory,new List<PopularIdea>());	
	    	 	}
	    	 	popularMaps.get(pIdea.ideaCategory).add(pIdea);
	    	 }
	    	 for(String keyCategory:popularMaps.keySet()){
	    	 	//Sort each Category List on Vote
	    	 	sortIdeaOnVotes(popularMaps.get(keyCategory),'dsc');
	    	 }
	    	 /*
	    	  Clear the Original List
	    	 */
	    	 //popularIdeasList.clear();
	    	 /*
	    	   Populate Again with the Category Order as sorted earlier 
	    	 */
	    	 
	    	 List<popularIdea> sortedPopularIdeasList = new List<popularIdea>();
	    	 system.debug('::categorySet::'+categorySet);
	    	 
	    	 for(String keyCategory:categorySet){
	    	 	system.debug('::keyCategory:::'+keyCategory);
	    	 	sortedPopularIdeasList.addAll(popularMaps.get(keyCategory));
	    	 }
	    	 system.debug(':sortedPopularIdeasList:'+sortedPopularIdeasList);
    	}
    	 return popularIdeasList;
    }
    
     private static void sortIdeaOnVotes(List<PopularIdea> items,String order){
       List<PopularIdea> resultList = new List<PopularIdea>();
        //Create a map that can be used for sorting 
       Map<object, List<PopularIdea>> objectMap = new Map<object, List<PopularIdea>>();
       for(PopularIdea ob : items){
       	     if(objectMap.get(ob.VoteTotal) == null){  // For non PopularIdea use obj.ProperyName
                objectMap.put(ob.VoteTotal, new List<PopularIdea>()); 
             }
          objectMap.get(ob.VoteTotal).add(ob);
       }       
        //Sort the keys
       List<object> keys = new List<object>(objectMap.keySet());
       keys.sort();
       
       for(object key : keys){ 
         resultList.addAll(objectMap.get(key)); 
       }
       //Apply the sorted values to the source list
       items.clear();
       if(order.toLowerCase() == 'asc'){
           for(PopularIdea ob : resultList){
               items.add(ob); 
           }
       }else if(order.toLowerCase() == 'desc'){
           for(integer i = resultList.size()-1; i >= 0; i--){
               items.add(resultList[i]);  
           }
       }
       
       system.debug('::sortIdeaOnVotes::: List ::'+items);
    }
    
    private static void sortIdeaOnCategoryList(List<PopularIdea> items,String order){
       List<PopularIdea> resultList = new List<PopularIdea>();
        //Create a map that can be used for sorting 
       Map<object, List<PopularIdea>> objectMap = new Map<object, List<PopularIdea>>();
       for(PopularIdea ob : items){
       	     if(objectMap.get(ob.ideaCategory) == null){  // For non PopularIdea use obj.ProperyName
                objectMap.put(ob.ideaCategory, new List<PopularIdea>()); 
             }
          objectMap.get(ob.ideaCategory).add(ob);
       }       
        //Sort the keys
       List<object> keys = new List<object>(objectMap.keySet());
       keys.sort();
       
       for(object key : keys){ 
         resultList.addAll(objectMap.get(key)); 
       }
       //Apply the sorted values to the source list
       items.clear();
       if(order.toLowerCase() == 'asc'){
           for(PopularIdea ob : resultList){
               items.add(ob); 
           }
       }else if(order.toLowerCase() == 'desc'){
           for(integer i = resultList.size()-1; i >= 0; i--){
               items.add(resultList[i]);  
           }
       }
       
       system.debug('::sortIdeaOnCategoryList::: List ::'+items);
    }
    
    private static PopularIdea createNewPopularIdea(Idea popularIdea){
    	PopularIdea newPopularIdea = new PopularIdea();
    	newPopularIdea.voteTotal = popularIdea.VoteTotal;
    	newPopularIdea.ideaId = popularIdea.Id;
    	newPopularIdea.voteScore = popularIdea.VoteScore;
    	newPopularIdea.createdDate = popularIdea.createdDate;
    	newPopularIdea.title = popularIdea.Title;
    	newPopularIdea.status =  popularIdea.Status; 
    	newPopularIdea.parentIdeaId =  popularIdea.ParentIdeaId;
    	newPopularIdea.numComments = popularIdea.NumComments;
    	newPopularIdea.body = popularIdea.body;
    	newPopularIdea.createdByName = popularIdea.CreatedBy.Name;
    	newPopularIdea.popularIdeaComments = new List<PopularIdeaComment>();
    	newPopularIdea.numLikes =0;
    	newPopularIdea.numDislikes = 0;
    	for(IdeaComment ideaComment:popularIdea.comments){
    	  newPopularIdea.popularIdeaComments.add(createPopularIdeaComment(ideaComment));
    	}
    	newPopularIdea.ideaVotes = new List<IdeaVote>();
    	for(Vote ideaVote:popularIdea.Votes){
    	   newPopularIdea.ideaVotes.add(createNewPopularIdea(ideaVote));
    	   if(ideaVote.type=='Up'){
    	   		newPopularIdea.numLikes++;
    	   }else{
    	   		newPopularIdea.numDislikes++;
    	   }   
    	}
    	return newPopularIdea;
    }
    
    private static List<string> toList(string storedValue){
		List<string> values = new List<string>();
		if(storedValue == null || storedValue == ''){
			values.add(''); 
			return values;
		}
		else{			
			string[] splitValues = storedValue.split(';');
			for(string v : splitValues){
				if(v != null && v != '')
					values.add(v);
			}
			return values;
		}
	}
	
	
    private static  PopularIdeaComment createPopularIdeaComment(IdeaComment comment){
    	PopularIdeaComment ppIdeaComment = new PopularIdeaComment();
    	ppIdeaComment.commentBody = comment.CommentBody;
    	ppIdeaComment.createdByName = comment.CreatedBy.Name;
    	ppIdeaComment.IdeaId = comment.IdeaId;
    	ppIdeaComment.Id = comment.Id;
    	ppIdeaComment.createdDate = comment.CreatedDate;
    	ppIdeaComment.isHtml = comment.IsHtml;
    	return ppIdeaComment;
    }
    
   
    private static IdeaVote createNewPopularIdea(Vote ideaVote){
    	IdeaVote iVote = new IdeaVote();
    	iVote.id = ideaVote.id;
    	iVote.createdByName = ideaVote.CreatedBy.Name;
    	iVote.parentId = ideaVote.ParentId;
    	return iVote;
    }
    
    /*
	   Main Idea Class to be sent to FE
	*/
    global class PopularIdea{
    	global Double voteTotal;
    	global Double  voteScore;
    	global String  title;
    	global String  status;
    	global String  parentIdeaId;
    	global Integer numComments;
    	global String  ideaCategory;
    	global String  body;
    	global String createdByName;
    	global List<PopularIdeaComment> popularIdeaComments;
    	global List<IdeaVote> ideaVotes;
    	global String ideaId;
    	global Datetime createdDate;
    	global Integer numLikes;
    	global Integer numDislikes;
    	 
    }
     /*Idea Comments representing class
    */
    global class PopularIdeaComment{
    	global String id;
    	global String ideaId;
    	global String commentBody;
    	global String createdByName;
    	global Datetime createdDate;
    	global Boolean  isHtml; 
    }
     /*Idea Votes representing class
    */
    global class IdeaVote{
        global String id;
        global String parentId;
        global String type;
        global String createdByName;	
    }
}
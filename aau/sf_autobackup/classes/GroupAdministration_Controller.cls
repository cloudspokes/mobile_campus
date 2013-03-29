public with sharing class GroupAdministration_Controller {

	public list<string> lst_Groups{get;set;}
	public list<User> lst_Students{get;set;}
	public static set<string> Groups = new Set<string>();
	static{
		Groups.add('Student Services');
		Groups.add('AAU Campus Admin');
	}
	
	public GroupAdministration_Controller(){
		
		lst_Students =[select name,id from user where profile.Name ='AAU Student - Platform' limit 10];
		
	}
	
	@RemoteAction
	public static list<User>  get_Students(){
		list<User> lst_Students =[select name,id from user where profile.Name ='AAU Student - Platform' limit 10];
		
		return lst_Students;
	}
	
	@RemoteAction
	public static list<CollaborationGroup> get_groups(){
		
		set<string> GroupIds = new Set<string>();
		
		//Retrieve Student Service Chatter group
		List<CollaborationGroup> studentServicesGroup = [Select id,name from CollaborationGroup where name in :Groups ];
		
		map<ID,set<ID>> existingMembersMap = new map<ID,set<ID>>();
		
		/*for(CollaborationGroup grp:studentServicesGroup){
			GroupIds.add(grp.id);
			existingMembersMap.put(grp.id,new set<ID>());
		}*/
		return studentServicesGroup;
	}
}
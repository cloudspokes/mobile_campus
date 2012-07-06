/**
 * Lead Score Manager is intended to be called from a trigger and operates on bulk applications
 */
public class LeadScoreManager {

	List<Recruitment_Event__c> ranges = new List<Recruitment_Event__c>();
	Set<String> qualifyingEvents = new Set<String>();
	Map<String, Lead_Score__c> allScoreData = new Map<String, Lead_Score__c>();
	
	public Map<String, Double> scoreApplications(Map<String, Contact> newContacts)
	{
		// prepareLeadScoreData();
		prepareLeadScoreData(newContacts);
		Map<String, Double> countryScores = getCountryScores(newContacts);
		Map<String, Double> stateScores = getStateScores(newContacts);
		Map<String, Double> leadrefScores = getLeadRefScores(newContacts);
		
		Map<String, Double> transcriptScores = getTranscriptsReceivedScores(newContacts);
		Map<String, Double> isirScores = getISIRScores(newContacts);
		Map<String, Double> takenClassesBeforeScores = getTakenClassesScores(newContacts);
		
		Map<String, Double> servIndScores = getServiceIndicatorScores(newContacts);
		
		prepareRecruitmentEvents();
		Map<String, Double> campaignScores = getCampaignScores(newContacts);
		Map<String, Double> activityScores = getActivitiesScores(newContacts);
		
		return totalScores(newContacts, countryScores, stateScores, leadrefScores, transcriptScores, isirScores, takenClassesBeforeScores, servIndScores, campaignScores, activityScores);
	}
	
	// private void prepareLeadScoreData()
	private void prepareLeadScoreData(Map<String, Contact> contacts)
	{
		// only retrieve the scoring names that we need (this avoids the 'too many rows' exception)
		Set<String> scoringNames = new Set<String>();
		scoringNames.add('Transcripts Received');
		scoringNames.add('Taken Classes at Academy Before');
		scoringNames.add('Campaigns');

		for (Contact contact : contacts.values()) {
			scoringNames.add(contact.Country__c);
			scoringNames.add(contact.State_Province__c);
			scoringNames.add(contact.Referral_Source__c);

			if (contact.Service_Indicators_Non_Editable__c != null) {
				for (String indicator : contact.Service_Indicators_Non_Editable__c.split(';')) {
					scoringNames.add(indicator);
				}
			}
		}
		
		// only retrieve the scoring categories that we need (this avoids the 'too many rows' exception)
		Set<String> scoringCategories = new Set<String>{'Campaigns', 'Activities'};

		// for( Lead_Score__c leadScore : [Select l.Scoring_Category__r.Weight__c, l.Scoring_Category__r.Name, l.Scoring_Category__c, l.Name, l.Score__c From Lead_Score__c l])
		for(Lead_Score__c leadScore : [select Scoring_Category__r.Weight__c, Scoring_Category__r.Name, Scoring_Category__c, Name, Score__c 
		                               from Lead_Score__c 
		                               where Name in :scoringNames
		                                  or Scoring_Category__r.Name in :scoringCategories])
		{
			allScoreData.put(leadScore.Name, leadScore);
		}
		
	}
	
	private Map<String, Double> getCountryScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			if(c.Country__c == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else if(allScoreData.get(c.Country__c) == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else
			{
				Lead_Score__c country = allScoreData.get(c.Country__c);
				
				scores.put(c.PeopleSoft_Person_ID__c, country.Score__c * country.Scoring_Category__r.Weight__c);
				System.debug('*** COUNTRY SCORE FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
			}
		}
		return scores;
	}
	
	//we only score states for Domestic Applications
	private Map<String, Double> getStateScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		for(Contact c : contacts.values())
		{
			if(c.State_Province__c == null || c.Country__c == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else if(c.State_Province__c != null && c.Country__c == 'United States')
			{
				if(allScoreData.get(c.State_Province__c) == null)
					scores.put(c.PeopleSoft_Person_ID__c, 0);
				else
				{
					Lead_Score__c state = allScoreData.get(c.State_Province__c);
					scores.put(c.PeopleSoft_Person_ID__c, state.Score__c * state.Scoring_Category__r.Weight__c);
					System.debug('*** STATE SCORE FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
				}
			}
			else
				scores.put(c.PeopleSoft_Person_ID__c,0);
		}
		return scores;
	}
	
		
	private Map<String, Double> getLeadRefScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			if(c.Referral_Source__c == null)
					scores.put(c.PeopleSoft_Person_ID__c, 0);
			else if(allScoreData.get(c.Referral_Source__c) == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else 
			{
				Lead_Score__c item = allScoreData.get(c.Referral_Source__c);
				
				scores.put(c.PeopleSoft_Person_ID__c, item.Score__c * item.Scoring_Category__r.Weight__c);
				System.debug('*** LEADREF SCORE FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
			}
		}
		return scores;
	}
	
	private Map<String, Double> getTranscriptsReceivedScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			if(c.Transcript_Review_Completed__c == null || c.Transcript_Review_Completed__c == false)
					scores.put(c.PeopleSoft_Person_ID__c, 0);
			else if(allScoreData.get('Transcripts Received') == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else 
			{
				Lead_Score__c item = allScoreData.get('Transcripts Received');
				
				scores.put(c.PeopleSoft_Person_ID__c, item.Score__c * item.Scoring_Category__r.Weight__c);
				System.debug('*** TRANSCRIPT SCORE FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
			}
		}
		return scores;
	}
	
	private Map<String, Double> getTakenClassesScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			if(c.Have_you_taken_classes_at_AAU_before__c == null || convertYesNoToBoolean(c.Have_you_taken_classes_at_AAU_before__c) == false)
					scores.put(c.PeopleSoft_Person_ID__c, 0);
			else if(allScoreData.get('Taken Classes at Academy Before') == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else 
			{
				Lead_Score__c item = allScoreData.get('Taken Classes at Academy Before');
				
				scores.put(c.PeopleSoft_Person_ID__c, item.Score__c * item.Scoring_Category__r.Weight__c);
				System.debug('*** TAKEN CLASSES FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
			}
		}
		return scores;
	}
	
	/**
	 * currently not implemented as we dont have an isir field yet.
	 */
	private Map<String, Double> getISIRScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			scores.put(c.PeopleSoft_Person_ID__c, 0);
		}
		return scores;
	}
	
	private Map<String, Double> getServiceIndicatorScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		for(Contact c : contacts.values())
		{
			if(c.Service_Indicators_Non_Editable__c == null)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else
			{
				String[] indicators = c.Service_Indicators_Non_Editable__c.split(';');
				Double score = 0;
				if(indicators.size() == 0)
					scores.put(c.PeopleSoft_Person_ID__c, 0);
				else
				{
					for(Integer i = 0; i < indicators.size(); i++)
					{
						Lead_Score__c item = allScoreData.get(indicators[i]);
						
						if(item != null)
							score += item.Score__c * item.Scoring_Category__r.Weight__c;
					}
					scores.put(c.PeopleSoft_Person_ID__c, score);
					System.debug('*** SERVICE IND SCORE FOR '+c.Name+ ' is:'+scores.get(c.PeopleSoft_Person_ID__c));
					
				}
			}
		}
		return scores;
	}
	
	private void prepareRecruitmentEvents()
	{
		ranges = [Select r.Score__c, r.Range_Low__c, r.Range_High__c, r.Scoring_Category__r.Weight__c, r.Event_Type__c
								From Recruitment_Event__c r];
		
		
		for( Lead_Score__c sec : allScoreData.values())
		{
			if(sec.Scoring_Category__r.Name == 'Campaigns' || sec.Scoring_Category__r.Name == 'Activities')
				qualifyingEvents.add(sec.Name);
		}
								
	}
	private Map<String, Double> getCampaignScores(Map<String, Contact> contacts)
	{
		Map<String, Double> scores = new Map<String, Double>();
		
		
		Set<String> criteria = new Set<String>();
		for(Contact c : contacts.values())
		{
			Integer count = 0;
			System.debug('CHECKING IF '+c.Name+' HAS ANY CAMPAIGNS');
			for(CampaignMember m : c.CampaignMembers)
			{
				System.debug(c.Name+' IS A CAMPAIGNMEMBER!');
				for(String sec : qualifyingEvents)
				{
					System.Debug('CHECKING QUALEVENT:' +sec);
					if(m.Campaign.Name == sec)
					{	
						count++;
						System.debug('QUALEVENT MATCH. Score is: '+count);
					}
				}
			} 
			
			if(count == 0)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else
			{
				for(Recruitment_Event__c range : ranges)
				{
					if(count > range.Range_Low__c && count <= range.Range_High__c && range.Event_Type__c == 'Campaigns')
						scores.put(c.PeopleSoft_Person_ID__c, range.Score__c * range.Scoring_Category__r.Weight__c);
				}
			}
			if (!scores.containsKey(c.PeopleSoft_Person_ID__c)) scores.put(c.PeopleSoft_Person_ID__c, 0);
		}
		return scores;
	}
	
	private Map<String, Double> getActivitiesScores(Map<String, Contact> contacts)
	{
		
		Map<String, Double> scores = new Map<String, Double>();
		
		
		Set<String> criteria = new Set<String>();
		for(Contact c : contacts.values())
		{
			Integer count = 0;
		
			for(ActivityHistory m : c.ActivityHistories)
			{
				for(String sec : qualifyingEvents)
				{
					if(m.Category__c != null && m.Category__c.contains(sec))
					{
						count++;
					}
				}
			} 
			
			if(count == 0)
				scores.put(c.PeopleSoft_Person_ID__c, 0);
			else
			{
				for(Recruitment_Event__c range : ranges)
				{
					if(count > range.Range_Low__c && count <= range.Range_High__c && range.Event_Type__c == 'Activities')
						scores.put(c.PeopleSoft_Person_ID__c, range.Score__c * range.Scoring_Category__r.Weight__c);
				}
			}
			if (!scores.containsKey(c.PeopleSoft_Person_ID__c)) scores.put(c.PeopleSoft_Person_ID__c, 0);
		}
		return scores;
	}
	
	
	private Map<String, Double> totalScores(Map<String, Contact> contacts, Map<String, Double> countryScores, 
										   Map<String, Double> stateScores,  
										   Map<String, Double> leadrefScores, 
										   Map<String, Double> transcriptScores, 
										   Map<String, Double> isirScores, 
										   Map<String, Double> takenClassesBeforeScores,
										   Map<String, Double> servIndScores, 
										   Map<String, Double> campaignScores, 
										   Map<String, Double> activityScores)
   {
   		Map<String, Double> finalScores = new Map<String, Double>();
   		
   		Double score = 0;
   		for(Contact c : contacts.values())
   		{
   			if(c.Country__c != 'United States')
   			{
   				
   				score = countryScores.get(c.PeopleSoft_Person_ID__c) + leadrefScores.get(c.PeopleSoft_Person_ID__c);
   				System.debug('Scoring for International contact '+c.Name+': '+score);
   			}
   			else if(c.Country__c == 'United States')
   			{
   				System.debug('------------------------------------------------');
   				System.debug('------------------------------------------------');
   				System.debug('            SCORE CARD FOR'+c.Name);
   				System.debug('Country           : '+countryScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('State             : '+stateScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Lead Ref          : '+leadrefScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Transcripts       : '+transcriptScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('ISIR              : '+isirScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Taken Classes     : '+takenClassesBeforeScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Service Indicators: '+servIndScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Campaigns         : '+campaignScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('Activities        : '+activityScores.get(c.PeopleSoft_Person_ID__c));
   				System.debug('------------------------------------------------');
   				System.debug('------------------------------------------------');
   				
   				score = countryScores.get(c.PeopleSoft_Person_ID__c) + stateScores.get(c.PeopleSoft_Person_ID__c)+ leadrefScores.get(c.PeopleSoft_Person_ID__c)+ transcriptScores.get(c.PeopleSoft_Person_ID__c)+
   						isirScores.get(c.PeopleSoft_Person_ID__c)+ takenClassesBeforeScores.get(c.PeopleSoft_Person_ID__c) + servIndScores.get(c.PeopleSoft_Person_ID__c)+ campaignScores.get(c.PeopleSoft_Person_ID__c)+ activityScores.get(c.PeopleSoft_Person_ID__c);
   			}
   	
   			finalScores.put(c.PeopleSoft_Person_ID__c, score);
   		}
   		return finalScores;
   }
	
	public Map<String, String> getRankings(Map<String, Double> scores)
	{
		Map<String, String> rankings = new Map<String, String>();
		List<Ranking__c> ranges = [Select r.Name, r.Range_Low__c, r.Range_High__c from Ranking__c r];
						  	
		Double score = 0;
		for(String id :scores.keySet())
		{
			score = scores.get(id);
			System.debug('***** SCORE FOR ID '+id+ ' is: '+score);
			for(Ranking__c r : ranges)
			{
				if(score >= r.Range_Low__c && score <= r.Range_High__c)
					rankings.put(id, r.Name);
			}
		}
		return rankings;
	}
	
	public Boolean convertYesNoToBoolean(String yesno)
	{
		if(yesno == null)
			return false;
		if(yesno.toLowerCase() == 'yes')
			return true;
		else
			return false;
	}
}
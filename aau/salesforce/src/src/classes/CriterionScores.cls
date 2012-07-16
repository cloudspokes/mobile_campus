public class CriterionScores
{
	public static final String TRANSCRIPTS_RECEIVED = 'Transcripts Received';
	public static final String ISIR = 'ISIR';
	public static final String TAKEN_CLASSES_BEFORE = 'Taken Classes at Academy Before';
	
	Map<String, Score_Criteria__c> keyedResults = new Map<String, Score_Criteria__c>();
	
	public CriterionScores(){}
	
	public void prepareCriterion()
	{
		for(Score_Criteria__c c : [Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From Score_Criteria__c s])
		{
			keyedResults.put(c.Name, c);
		}
	
	}	
	
	public Map<Id, Double> getCriterionScore(String criterionType, Map<ID, Contact> contacts)
	{
		Set<String> criteria = new Set<String>();
		
		Map<Id, Double> scores = new Map<Id, Double>();
		
		for(Contact c : contacts.values())
		{
			Score_Criteria__c item = keyedResults.get(criterionType);
			Boolean valid = false;
			System.debug('CRITERION_SCORE: checking type: '+criterionType);
			
			if(criterionType == TRANSCRIPTS_RECEIVED)
			{
				if(c.Transcript_Review_Completed__c == null)
					valid = false;
				else
					valid = c.Transcript_Review_Completed__c;
			}
			else if(criterionType == TAKEN_CLASSES_BEFORE)
			{
				if(c.Have_you_taken_classes_at_AAU_before__c == null)
					valid = false;
				else
					valid = convertYesNoToBoolean(c.Have_you_taken_classes_at_AAU_before__c);
			}
			else if (criterionType == ISIR)
				valid = false; //there is currently no isir
			
			System.debug('CRITERION_SCORE: for +'+c.Name+' is valid?: '+valid);
			
			if(valid)
				scores.put(c.Id, item.Score__c * item.Scoring_Category__r.Weight__c);
			else
				scores.put(c.Id, 0);
		}
		return scores;
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
public class CriterionScoreHelper 
{
	public static final String TRANSCRIPTS_RECEIVED = 'Transcripts Received';
	public static final String ISIR = 'ISIR';
	public static final String TAKEN_CLASSES_BEFORE = 'Taken Classes at Academy Before';
	
		
	public static Map<Id, Double> scoreCriterion(String criterionType, Map<ID, Contact> contacts)
	{
		Set<String> criteria = new Set<String>();
		
		Map<Id, Double> scores = new Map<Id, Double>();
		List<Score_Criteria__c> results = 
			[Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From Score_Criteria__c s where s.Name = :criterionType];
		
		Map<String, Score_Criteria__c> keyedResults = new Map<String, Score_Criteria__c>();
		for(Score_Criteria__c c : results)
		{
			keyedResults.put(c.Name, c);
		}
	
		for(Contact c : contacts.values())
		{
			Score_Criteria__c item = keyedResults.get(criterionType);
			Boolean valid = false;
			if(criterionType == TRANSCRIPTS_RECEIVED)
				valid = c.Transcript_Review_Completed__c;
			else if(criterionType == TAKEN_CLASSES_BEFORE)
				valid = CriterionScoreHelper.convertYesNoToBoolean(c.Have_you_taken_classes_at_AAU_before__c);
			else if (criterionType == ISIR)
				valid = false; //there is currently no isir
			
			if(valid)
				scores.put(c.Id, item.Score__c * item.Scoring_Category__r.Weight__c);
			else
				scores.put(c.Id, 0);
		}
		return scores;
	}
	
	public static Boolean convertYesNoToBoolean(String yesno)
	{
		if(yesno == null)
			return false;
		if(yesno.toLowerCase() == 'yes')
			return true;
		else
			return false;
	}
	
	
}
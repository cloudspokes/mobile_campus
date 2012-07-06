/**
 * Lead Score is intended to be called from a trigger and operates on bulk applications
 */
public class LeadScore {

    List<Recruitment_Event__c> ranges = new List<Recruitment_Event__c>();
    Set<String> qualifyingEvents = new Set<String>();
    
    public Map<Id, Double> scoreApplications(Map<ID, Contact> newContacts)
    {
        prepareLeadScores();
        Map<ID, Double> countryScores = getCountryScores(newContacts);
        Map<ID, Double> stateScores = getStateScores(newContacts);
        Map<ID, Double> leadrefScores = getLeadRefScores(newContacts);
        
        CriterionScores helper = new CriterionScores();
        helper.prepareCriterion();
        Map<ID, Double> transcriptScores = helper.getCriterionScore(CriterionScoreHelper.TRANSCRIPTS_RECEIVED, newContacts);
        Map<ID, Double> isirScores = helper.getCriterionScore(CriterionScoreHelper.ISIR, newContacts);
        Map<ID, Double> takenClassesBeforeScores = helper.getCriterionScore(CriterionScoreHelper.TAKEN_CLASSES_BEFORE, newContacts);
        
        Map<ID, Double> servIndScores = getServiceIndicatorScores(newContacts);
        
        prepareRecruitmentEvents();
        Map<ID, Double> campaignScores = getCampaignScores(newContacts);
        Map<ID, Double> activityScores = getCampaignScores(newContacts);//getActivitiesScores(newContacts);
        
        return totalScores(newContacts, countryScores, stateScores, leadrefScores, transcriptScores, isirScores, takenClassesBeforeScores, servIndScores, campaignScores, activityScores);
    }
    
    private void prepareLeadScores()
    {
        
    }
    
    private Map<Id, Double> getCountryScores(Map<ID, Contact> contacts)
    {
        Set<String> countryNames = new Set<String>();
        for(Contact c : contacts.values())
        {
            countryNames.add(c.Country__c); 
        }
        
        Map<Id, Double> scores = new Map<Id, Double>();
        List<Country__c> countries = 
            [Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From Country__c s where s.Name in :countryNames];
        
        Map<String, Country__c> keyedCountries = new Map<String, Country__c>();
        for(Country__c c : countries)
        {
            keyedCountries.put(c.Name, c);
        }
    
        for(Contact c : contacts.values())
        {
            if(keyedCountries.get(c.Country__c) == null)
                scores.put(c.Id, 0);
            else
            {
                Country__c country = keyedCountries.get(c.Country__c);
            
                scores.put(c.Id, country.Score__c * country.Scoring_Category__r.Weight__c);
                System.debug('*** COUNTRY SCORE FOR '+c.Name+ ' is:'+scores.get(c.id));
            }
        }
        return scores;
    }
    
    //we only score states for Domestic Applications
    private Map<Id, Double> getStateScores(Map<ID, Contact> contacts)
    {
        Map<Id, Double> scores = new Map<Id, Double>();
        List<State__c> states = new List<State__c>();
        
        
            Set<String> stateNames = new Set<String>();
            for(Contact c : contacts.values())
            {
                stateNames.add(c.State_Province__c); 
            }
            
            
            if(stateNames.size() > 0)
            {
                states = [Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From State__c s where s.Name in :stateNames];
            }
            
            Map<String, State__c> keyedStates = new Map<String, State__c>();
            
            
            if(states.size() > 0)
            {
                for(State__c c : states)
                {
                    keyedStates.put(c.Name, c);
                }
            
                for(Contact c : contacts.values())
                {
                
                    if(c.Country__c == 'United States')
                    {
                        if(keyedStates.get(c.State_Province__c) == null)
                            scores.put(c.Id, 0);
                        else
                        {
                            State__c state = keyedStates.get(c.State_Province__c);
                            scores.put(c.Id, state.Score__c * state.Scoring_Category__r.Weight__c);
                            System.debug('*** STATE SCORE FOR '+c.Name+ ' is:'+scores.get(c.id));
                        }
                    }
                    else
                        scores.put(c.Id,0);
                }
            }
        return scores;
    }
    
        
    private Map<Id, Double> getLeadRefScores(Map<ID, Contact> contacts)
    {
        Set<String> criteria = new Set<String>();
        for(Contact c : contacts.values())
        {
            criteria.add(c.Referral_Source__c); 
        }
        
        Map<Id, Double> scores = new Map<Id, Double>();
        Map<String, Referral_Source__c> keyedResults = new Map<String, Referral_Source__c>();
        
        for(Referral_Source__c ref : [Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From Referral_Source__c s where s.Name in :criteria])
        {
            keyedResults.put(ref.Name, ref);
        }
        for(Contact c : contacts.values())
        {
            Referral_Source__c item = keyedResults.get(c.Referral_Source__c);
            if(item != null)
            {
                scores.put(c.Id, item.Score__c * item.Scoring_Category__r.Weight__c);
                System.debug('*** LEADREF SCORE FOR '+c.Name+ ' is:'+scores.get(c.id));
            }
            else
                scores.put(c.Id,0);
        }
        return scores;
    }
    
    private Map<Id, Double> getServiceIndicatorScores(Map<ID, Contact> contacts)
    {
        Set<String> criteria = new Set<String>();
        String[] serviceIndicators;
        Map<Id, String[]> serviceIndicatorsByContact = new Map<Id, String[]>();
        
        for(Contact c : contacts.values())
        {
            if(c.Service_Indicators_Non_Editable__c == null)
            {
                //no indicators
                serviceIndicatorsByContact.put(c.Id, new String[]{});
            }
            else
            {
                serviceIndicators = c.Service_Indicators_Non_Editable__c.split(';');

                //need to loop through the string and add to the set to remove any duplicates
                for(Integer i = 0; i < serviceIndicators.size(); i++)
                {
                    criteria.add(serviceIndicators[i]);
                }
                serviceIndicatorsByContact.put(c.Id, serviceIndicators);
            } 
        }
        
        Map<Id, Double> scores = new Map<Id, Double>();
        List<Service_Indicator__c> results = 
            [Select s.Scoring_Category__r.Weight__c, s.Score__c, s.Name From Service_Indicator__c s where s.Name in :criteria];
        
        Map<String, Service_Indicator__c> keyedResults = new Map<String, Service_Indicator__c>();
        for(Service_Indicator__c res : results)
        {
            keyedResults.put(res.Name, res);
        }
    
        for(Contact c : contacts.values())
        {
            String[] indicators = serviceIndicatorsByContact.get(c.Id);
            Double score = 0;
            if(keyedResults.size() == 0)
                scores.put(c.Id, 0);
            else
            {
                for(Integer i = 0; i < indicators.size(); i++)
                {
                    Service_Indicator__c item = keyedResults.get(indicators[i]);
                    if(item != null)
                        score += item.Score__c * item.Scoring_Category__r.Weight__c;
                }
                scores.put(c.Id, score);
                System.debug('*** SERVICE IND SCORE FOR '+c.Name+ ' is:'+scores.get(c.id));
                
            }
        }
        return scores;
    }
    
    private void prepareRecruitmentEvents()
    {
        ranges = [Select r.Score__c, r.Range_Low__c, r.Range_High__c, r.Scoring_Category__r.Weight__c
                                From Recruitment_Event__c r];
        
        
        for( Scored_Event__c sec : [select Name from Scored_Event__c])
        {
            qualifyingEvents.add(sec.Name);
        }
                                
    }
    private Map<Id, Double> getCampaignScores(Map<ID, Contact> contacts)
    {
        Map<Id, Double> scores = new Map<Id, Double>();
        
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
                scores.put(c.Id, 0);
            else
            {
                for(Recruitment_Event__c range : ranges)
                {
                    if(count > range.Range_Low__c && count <= range.Range_High__c && range.Event_Type__c == 'Campaigns')
                        scores.put(c.Id, range.Score__c * range.Scoring_Category__r.Weight__c);
                }
            }
        }
        
        return scores;
    }
    
    /*
    private Map<Id, Double> getActivitiesScores(Map<ID, Contact> contacts)
    {
        
        Map<Id, Double> scores = new Map<Id, Double>();
        
        
        Set<String> criteria = new Set<String>();
        for(Contact c : contacts.values())
        {
            Integer count = 0;
        
            for(ActivityHistory m : c.ActivityHistories)
            {
                if(!qualifyingEvents.isEmpty() && qualifyingEvents != null)
                {
                    for(String sec : qualifyingEvents)
                    {
                        if((m != null && m.Category__c != null && sec != null) && m.Category__c.contains(sec))
                        {
                            count++;
                        }
                    }
                }
            } 
            
            if(count == 0)
                scores.put(c.Id, 0);
            else
            {
                for(Recruitment_Event__c range : ranges)
                {
                    if(count > range.Range_Low__c && count <= range.Range_High__c && range.Event_Type__c == 'Activities')
                        scores.put(c.Id, range.Score__c * range.Scoring_Category__r.Weight__c);
                }
            }
        }
        return scores;
    }
    */
    
    private Map<ID, Double> totalScores(Map<ID, Contact> contacts, Map<ID, Double> countryScores, 
                                           Map<ID, Double> stateScores,  
                                           Map<ID, Double> leadrefScores, 
                                           Map<ID, Double> transcriptScores, 
                                           Map<ID, Double> isirScores, 
                                           Map<ID, Double> takenClassesBeforeScores,
                                           Map<ID, Double> servIndScores, 
                                           Map<ID, Double> campaignScores, 
                                           Map<ID, Double> activityScores)
   {
        Map<Id, Double> finalScores = new Map<Id, Double>();
        
        Double score = 0;
        for(Contact c : contacts.values())
        {
            if(c.Country__c != 'United States')
            {
                
                score = countryScores.get(c.id) + leadrefScores.get(c.Id);
                System.debug('Scoring for International contact '+c.Name+': '+score);
            }
            else if(c.Country__c == 'United States')
            {
                System.debug('----------------------------');
                System.debug('----------------------------');
                System.debug('            SCORE CARD FOR'+c.FirstName+' '+c.LastName);
                System.debug('Country           : '+countryScores.get(c.id));
                System.debug('State             : '+stateScores.get(c.id));
                System.debug('Lead Ref          : '+leadrefScores.get(c.id));
                System.debug('Transcripts       : '+transcriptScores.get(c.id));
                System.debug('ISIR              : '+isirScores.get(c.id));
                System.debug('Taken Classes     : '+takenClassesBeforeScores.get(c.id));
                System.debug('Service Indicators: '+servIndScores.get(c.id));
                System.debug('Campaigns         : '+campaignScores.get(c.id));
                //System.debug('Activities        : '+activityScores.get(c.id));
                System.debug('-------------------------------');
                System.debug('-------------------------------');
                
                score = countryScores.get(c.id) + 0+ leadrefScores.get(c.Id)+ transcriptScores.get(c.Id)+
                        isirScores.get(c.Id)+ takenClassesBeforeScores.get(c.Id) + servIndScores.get(c.Id)+ campaignScores.get(c.Id)+ activityScores.get(c.Id);
            }
    
            finalScores.put(c.Id, score);
        }
        return finalScores;
   }
    
    public Map<ID, String> getRankings(Map<Id, Double> scores)
    {
        Map<ID, String> rankings = new Map<ID, String>();
        List<Ranking__c> ranges = [Select r.Name, r.Range_Low__c, r.Range_High__c from Ranking__c r];
                            
        Double score = 0;
        for(Id id :scores.keySet())
        {
            score = scores.get(id);
            System.debug('***** SCORE FOR ID '+id+ 'is: '+score);
            for(Ranking__c r : ranges)
            {
                if(score > r.Range_Low__c && score <= r.Range_High__c)
                    rankings.put(id, r.Name);
            }
        }
        return rankings;
    }
    
}
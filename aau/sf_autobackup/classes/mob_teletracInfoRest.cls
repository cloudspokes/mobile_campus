@RestResource(urlMapping='/teletracInfo/')

global with sharing class mob_teletracInfoRest {
  
  @HttpGet
  global static map<String,String> returnTeletracInfo() {
    map<String,String> teletracInfo = new map<String,String>();
    mob_Student__c mobSetting = mob_Student__c.getInstance();
    
    teletracInfo.put('Account', mobSetting.Teletrac_Account__c);
    teletracInfo.put('Username', mobSetting.Teletrac_Username__c);
    teletracInfo.put('Password', mobSetting.Teletrac_Password__c);
    teletracInfo.put('RefreshRate', String.valueOf(mobSetting.Bus_Refresh_Rate__c));
    teletracInfo.put('cacheTimeout', mobSetting.Cache_Timeout__c);
    
    return teletracInfo;
  }
}
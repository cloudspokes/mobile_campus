trigger generateCrosses on Bus_Stops_Routes__c (after update, after insert) {     
    List<Key_Val__c> vals = new List<Key_Val__c>();
    
    vals.addAll([select Id, Val__c from Key_Val__c where Name = 'bus_router_crosses']);
    
    if(vals.size() < 1) {
        vals.add(new Key_Val__c(Name = 'bus_router_crosses'));
    }
    
    BusRouterController con = new BusRouterController('dummy');
    vals[0].Val__c = JSON.serialize(con.getCrosses());
    upsert vals[0] Id;
}
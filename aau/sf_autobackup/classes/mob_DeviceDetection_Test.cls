@isTest
public class mob_DeviceDetection_Test {
	
	 static testMethod void testDeviceDetection() {
       //test for android 
       
        PageReference ref = new PageReference('/apex/mob_StudentHome?User-Agent=Android&appVersion=1_3');
        Test.setCurrentPage(ref);
        System.currentPageReference().getHeaders().put('User-Agent','iPhone Android iPhone/window'); 
        ApexPages.currentPage().getParameters().put('appVersion','1_3');
        
        mob_DeviceDetection con = new mob_DeviceDetection();
        System.assertEquals(con.isAndroid,true);
       
        //Test afor other then Android
        ref = new PageReference('/apex/mob_StudentHome?User-Agent=Android&appVersion=1_3');
        Test.setCurrentPage(ref);
        System.currentPageReference().getHeaders().put('User-Agent','iPhone Apple iPhone/window'); 
        ApexPages.currentPage().getParameters().put('appVersion','1_3');
        
        con = new mob_DeviceDetection();
        System.assertEquals(con.isAndroid,false);
        
	 }

}
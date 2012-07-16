public with sharing class TeletracController {

	public String getBusInfo() {
		Httprequest req = new Httprequest();
		req.setEndpoint('https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles?strAccountId=309411&strUserName=api_account&strPwd=9sb^jd8G2');
		req.setMethod('GET');
		
		Http transport = new Http();
		
		Httpresponse resp = transport.send(req);
		
		return resp.getBody();
	}

}
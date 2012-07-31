public class mob_teletracRest{

	@RemoteAction
	public static String getVehicles() {
		HttpRequest httpReq = initHttpRequest();
		
		HttpResponse httpRes = sendRequest(httpReq);
		
		String decodedBody = EncodingUtil.urlDecode(httpRes.getBody(), 'UTF-8');
		system.debug(decodedBody);
		return decodedBody;
	}
	
	private static HttpRequest initHttpRequest() {
        
        String accountId = '309411';
        String userName = 'api_account';
        String pwd = '9sb%5Ejd8G2';
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles?' + 
                                                                'strAccountId=' + accountID +
                                                                '&strUserNAme=' + userName +
                                                                '&strPwd=' + pwd);
        httpReq.setMethod('GET');
  
        return httpReq;
    }
    
    private static HttpResponse sendRequest(HttpRequest req) {
        Http http = new Http();
        HTTPResponse httpRes = http.send(req);
        
        return httpRes;
    }
}
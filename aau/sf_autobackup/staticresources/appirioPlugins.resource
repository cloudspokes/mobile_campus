var AppirioStoragePlugin = {
    /**
     * Downloads a remote file to local storage. The parameter opts has the following properties:
     *   fileUrl - the remote url
     *   fileVersionId - a unique id used for this specific version of the file. In SFDC Content, this is ContentVersion.Id.
     *   fileName - the name of the file
     *   showProgress - whether to show a progress bar control during download
     *   fileDocumentId - a unqiue id of the parent document for the file. In SFDC Content, this is ContentVersion.ContentDocumentId
     *   fileSize - number of bytes in the file (optional)
     *   progressLabel - if progress is shown, a text message shown (optional)
     *   hideProgressOnCompletion - if progress is shown, whether to hide the progress view when the file download is complete. (optional).
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    downloadFile: function(opts) {
        opts = $.extend( {showProgress:true, fileSize:0, hideProgressOnCompletion:true, onSuccess:$.noop, onFailure:$.noop}, opts);
        
        // if progressLabel isn't set, the argument list is off
        if (!opts.progressLabel) {
            opts.progressLabel = "";
        }
        
        aauMobile.nativeAdapter.exec(opts.onSuccess, opts.onFailure, "com.appirio.mobile.storage","storeFile",
                      [opts.fileUrl, opts.fileVersionId, opts.fileName, opts.showProgress, opts.fileDocumentId, opts.fileSize, 
                       opts.progressLabel, opts.hideProgressOnCompletion]);
    },
        
    /**
     * Retrieves a URL for a previously downloaded file, if it exists. If the file does not exist, an empty string is returned.
     *   fileVersionId - a unique id used for this specific version of the file. In SFDC Content, this is ContentVersion.Id.
     *   fileName - the name of the file
     *   fileDocumentId - a unqiue id of the parent document for the file. In SFDC Content, this is ContentVersion.ContentDocumentId
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    getLocalFileUrl: function(fileVersionId, fileName, fileDocumentId, onSuccess, onFailure) {
        aauMobile.nativeAdapter.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "urlForFile", [fileVersionId, fileName, fileDocumentId]);
    },
    
    /**
     * Retrieves a URL for a previously downloaded file, if it exists. If the file does not exist, an empty string is returned.
     *   fileVersionId - a unique id used for this specific version of the file. In SFDC Content, this is ContentVersion.Id.
     *   fileDocumentId - a unqiue id of the parent document for the file. In SFDC Content, this is ContentVersion.ContentDocumentId
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    deleteFile: function(fileVersionId, fileDocumentId, onSuccess, onFailure) {
        aauMobile.nativeAdapter.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "deleteFile", [fileVersionId, fileDocumentId]);
    },
    
    /**
     * Collects all local content and returns a JSON string describing the files. When parsed, the returned object is an array of 
     * object with properties fileDocumentId and fileId.
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    getLocalFiles: function(onSuccess, onFailure) {
        aauMobile.nativeAdapter.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "localFiles", []);
    }
};

var WebViewerPlugin = { 
    /**
     * Loads a URL into a modal web viewer. When the user closes the viewer, the js function appirioMobile.content.onViewerDone() will
     * be called.
     *   url - the URL to load
     *   title - title of the viewer
     *   showOpenIn - whether to display the "Open In..." button to open the content in an external app. Only available for local content.
     *   showBookmark - whether to show a bookmark button
     *   isBookmarked - whether the content is currently bookmarked
     */
    loadUrl: function(url, title, showOpenIn, showBookmark, isBookmarked) {
        aauMobile.nativeAdapter.exec("com.appirio.mobile.webviewer.loadUrl", url, title, showOpenIn, showBookmark, isBookmarked);
    },
    
    /**
     * Hides the progress view.
     */
    hideProgress: function(onSuccess, onFailure) {
        if (onSuccess == null) {
            onSuccess = $.noop;
        }
        if (onFailure == null) {
            onFailure = $.noop;
        }
        aauMobile.nativeAdapter.exec(onSuccess, onFailure, "com.appirio.mobile.webviewer", "hideModalIndeterminateProgress", []);
    },
    
    /**
     * Displays a modal indeterminate progress view
     *   label - a text label to display
     */
    showProgress: function(label) {
        aauMobile.nativeAdapter.exec("com.appirio.mobile.webviewer.showModalIndeterminateProgress", label);
    }
};

var SalesforceAuth = {

	Logout: function() {
	    //utils.log("### Phonegap ###" + JSON.stringify(PhoneGap));
		//aauMobile.nativeAdapter.exec("com.salesforce.oauth", "logout", '');
		//aauMobile.nativeAdapter.exec("com.salesforce.oauth.oauth", "logout", '');
		//if(aauMobile.isAndroid){
			//aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth","logoutCurrentUser",[]);
			//console.log('Lougout Message 2');
			//aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth","resetAppState",[]);
		//}else{
			//aauMobile.nativeAdapter.exec(null, null, "com.appirio.mobile.logout","LogoutManager",[]);
		//}
		//if(aauMobile.isAndroid()){
			aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth","authenticate",[]);
			aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth","logoutCurrentUser",[]);
			console.log('Logout ');
			aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth","resetAppState",[]);
	/*	}else{
			alert('SFDCAuth: Logging out');
			aauMobile.nativeAdapter.exec(SalesforceAuth.Authenticate, null, "com.salesforce.oauth","logoutCurrentUser",[]);
		}*/
	},
	Authenticate: function(){
		alert('Logged out. Calling Authenticate.');
		aauMobile.nativeAdapter.exec(function(){alert('Successfully called Authenticate');}, null, "com.salesforce.oauth","authenticate",[]);
	}

};
var SalesforceOAuthPlugin = {

	/**
	* Obtain authentication credentials, calling 'authenticate' only if necessary.
	* Most index.html authors can simply use this method to obtain auth credentials
	* after onDeviceReady.
    *   success - The success callback function to use.
    *   fail    - The failure/error callback function to use.
	* PhoneGap returns a dictionary with:
	* 	accessToken
	* 	refreshToken
    *   clientId
	* 	userId
	* 	orgId
    *   loginUrl
	* 	instanceUrl
	* 	userAgent
	*/
    getAuthCredentials: function(success, fail) {
        aauMobile.nativeAdapter.exec(success, fail, "com.salesforce.oauth","getAuthCredentials",[]);
    },
    
    /**
     * Initiates the authentication process, with the given app configuration.
     *   success         - The success callback function to use.
     *   fail            - The failure/error callback function to use.
     *   oauthProperties - The configuration properties for the authentication process.
     *                     See OAuthProperties() below.
     * PhoneGap returns a dictionary with:
     *   accessToken
     *   refreshToken
     *   clientId
     *   userId
     *   orgId
     *   loginUrl
     *   instanceUrl
     *   userAgent
     */
    authenticate: function(success, fail, oauthProperties) {
        aauMobile.nativeAdapter.exec(success, fail, "com.salesforce.oauth", "authenticate", [JSON.stringify(oauthProperties)]);
    },


    /**
     * Logout the current authenticated user. This removes any current valid session token
     * as well as any OAuth refresh token.  The user is forced to login again.
     * This method does not call back with a success or failure callback, as 
     * (1) this method must not fail and (2) in the success case, the current user
     * will be logged out and asked to re-authenticate.
     */
    logout: function() {
        aauMobile.nativeAdapter.exec(null, null, "com.salesforce.oauth", "logoutCurrentUser", []);
    },
    
    /**
     * Gets the app's homepage as an absolute URL.  Used for attempting to load any cached
     * content that the developer may have built into the app (via HTML5 caching).
     *
     * This method will either return the URL as a string, or an empty string if the URL has not been
     * initialized.
     */
    getAppHomeUrl: function(success) {
        aauMobile.nativeAdapter.exec(success, null, "com.salesforce.oauth", "getAppHomeUrl", []);
    }
};

/**
 * OAuthProperties data structure, for plugin arguments.
 *   remoteAccessConsumerKey - String containing the remote access object ID (client ID).
 *   oauthRedirectURI        - String containing the redirect URI configured for the remote access object.
 *   oauthScopes             - Array of strings specifying the authorization scope of the app (e.g ["api", "visualforce"]).
 *   autoRefreshOnForeground - Boolean, determines whether the container automatically refreshes OAuth session when app is foregrounded
 */
function OAuthProperties(remoteAccessConsumerKey, oauthRedirectURI, oauthScopes, autoRefreshOnForeground) {
    this.remoteAccessConsumerKey = remoteAccessConsumerKey;
    this.oauthRedirectURI = oauthRedirectURI;
    this.oauthScopes = oauthScopes;
    this.autoRefreshOnForeground = autoRefreshOnForeground;
};

var WebViewer = {

	showWebView: function(url) {
		//alert('a'); 
		aauMobile.nativeAdapter.exec(null, null, "com.appirio.mobile.webviewer","showWebView",[url]);
		//aauMobile.nativeAdapter.exec(null, null, "com.phonegap.navigator.screenOrientation", "set", ["landscape"]);
		//aauMobile.nativeAdapter.navigator.screenOrientation.set("landscape");
		//alert('b');
		
		}
};

var RestDataPlugin = {

	//these need to be set in a VF page
	/* PARTH: Onotialize values from variables defined on the VF Page */
	accessToken:  str_accessToken,	//$Api.Session_ID
	clientKey: str_clientKey,		//$Setup.mob_Student__c.Client_Key__c
	baseUrl: str_baseUrl,		//$Setup.mob_Student__c.Base_Url__c
	restUrl: str_restUrl,		//$Setup.mob_Student__c.Rest_Url__c
	//offline: false,
	
	getData: function(successCallback, failureCallback, restPath, isSFDC, restType, dataType) {
		var isSuccess = false;
		var isTimeout = false
		if(RestDataPlugin.isPhonegap()){
			console.log('Rest call via Phonegap...');
			//RestDataPlugin.getPhonegapData(successCallback, failureCallback, restPath, isSFDC, restType, dataType);
			/*setTimeout(function(){
			 					
				if( !isSuccess){
					isTimeout = true;
					//alert("We cannot complete the request at this time. Try again when you are connected to the internet.");
					//alert("Timeout! Due to slow or no connection, this action has been canceled. Please try again later.");
					alert("Due to slow or no connection, this action is taking longer than expected.");
					//commented this out so that the load on startup continues...
					//failureCallback("");
				}else{
					isTimeout = false;
				}
			},2000);
			*/

			RestDataPlugin.getPhonegapData(function (rawResult) {
			  							
				isSuccess = true;
				/*if(isTimeout){
					return ;//failureCallback("");
				}*/

				isTimeout = false;
				appirioUtils.log("This is the rawResult from PhoneGap: " + rawResult);
				try {
					var json = JSON.parse(rawResult);
					successCallback(json);
				} catch (e) {
					successCallback(rawResult);		 	  
				} 
			}, function (rawResult){
				isSuccess = true;
				/*if(isTimeout){
					return ;//failureCallback("");
				}*/

				isTimeout = false;
				failureCallback(rawResult);
			}, restPath);
		}else{
			console.log('Rest call via AJAX Toolkit...');
			RestDataPlugin.getAjaxDataByForceTK(successCallback, failureCallback, restPath, isSFDC, restType, dataType);
		}
	},
	
	/** 
	 * This method does not retry on request timeout
	called from transitManager for teletrac autoRefreshVehiclesPosition **/
	getData_ignoreTimeout: function(successCallback, failureCallback, restPath, isSFDC, restType, dataType) {
		
		if(RestDataPlugin.isPhonegap()){
			console.log('Rest call via Phonegap...');
			//RestDataPlugin.getPhonegapData(successCallback, failureCallback, restPath, isSFDC, restType, dataType);
			
			RestDataPlugin.getPhonegapData(function (rawResult) {
			  								
											  appirioUtils.log("This is the rawResult from PhoneGap: " + rawResult);
											  try {
											    var json = JSON.parse(rawResult);
											    successCallback(json);
											  } catch (e) {
								                successCallback(rawResult);		 	  
											  } 
											}
											, function (rawResult){
													failureCallback(rawResult);
													} 
											, restPath);
		}else{
			console.log('Rest call via AJAX Toolkit...');
			RestDataPlugin.getAjaxDataByForceTK(successCallback, failureCallback, restPath, isSFDC, restType, dataType);
		}
	},
	getPhonegapData: function(successCallback, failureCallback, restPath) {
		//append the rest path if this is a Salesforce REST call
		if(restPath.substring(0,1) == '/' && restPath.indexOf('services')  < 0){
			restPath = RestDataPlugin.restUrl + '/services/apexrest' + restPath;
		}else if(restPath.substring(0,1) == '/' && restPath.indexOf('services') > -1){
			restPath = RestDataPlugin.restUrl +  restPath;
		}
		//alert('Calling REST via Phonegap - ' + restPath);
		console.log('REST CALL - '+ [restPath]);
		aauMobile.nativeAdapter.exec(successCallback, failureCallback, "com.appirio.mobile.webservice", "getRestData", [restPath]);
	},

	getAjaxDataByForceTK: function(successCallback, failureCallback, restPath, isSFDC, restType, dataType) {

		// Get an instance of the REST API client and set the session ID
		var client = new forcetk.Client(RestDataPlugin.clientKey);
		//console.log('::Access Token ::'+RestDataPlugin.accessToken); 
		client.setSessionToken(RestDataPlugin.accessToken);
		client.setRefreshToken(RestDataPlugin.accessToken);
		
		if(restPath.match(/teletrac/g)){	//don't run the call to Teletrac, cuz the creds are on Native side
			successCallback(null);
		}else{
		//alert('REST CALL - '+  restPath);
		if(restPath.substring(0,1) == '/' && restPath.indexOf('services') > -1){
			restPath = RestDataPlugin.restUrl +  restPath;
		}
		
		//alert('Calling REST via AJAX - ' + restPath);
		client.apexrest(restPath, successCallback, failureCallback, restType, RestDataPlugin.baseUrl + '/services/proxy', isSFDC, dataType);
		
		}
	},
  getAJAXRestFeed: function(successCallback, failureCallback, restPath, isSFDC, restType, dataType) {
 	 	var credential = ' OAuth ' + RestDataPlugin.accessToken; // '{!GETSESSIONID()}'; // native VF function
 	 	
        var apiUrl = RestDataPlugin.restUrl + restPath; //'/services/data/v26.0/chatter/feeds/news/me/feed-items'; // "https://na1.salesforce.com/services/data/v26.0/chatter/users/me"
        
        alert('Calling REST via getAJAXRestFeed - ' + apiUrl);
        
        $.ajax({
            type: restType, //"GET",
            url: RestDataPlugin.baseUrl + '/services/proxy', //"https://c.na1.visual.force.com/services/proxy"
            contentType: 'application/json',
            cache: false,
            success : function(response) {
                         successCallback(response);
                   },
            error : function(response) {
                          failureCallback(response);
                   },                 
            dataType: dataType, //"json",
            beforeSend: function(xhr) {
                xhr.setRequestHeader('SalesforceProxy-Endpoint', apiUrl);
                xhr.setRequestHeader("Authorization", credential);
                xhr.setRequestHeader('X-User-Agent', 'AAU');
            }
                   

        });
 },

	isPhonegap: function(){
	    var isPhonegapAvailable = false;
		//PARTH: In case of browser return false
		//alert("comment this if statement!!!");
		if(!appirioUtils.isIOS() && !appirioUtils.isAndroid()){
			isPhonegapAvailable = false; 
			return isPhonegapAvailable;
		}
		if(appirioUtils.isAndroid() || deviceReady) {
		  isPhonegapAvailable = true;
		} else {
		  isPhonegapAvailable = PhoneGap.available;
		}
		return isPhonegapAvailable;
	}

	/*
	getAjaxData: function(successCallback, failureCallback, restPath, restType, dataType) {
	     console.log(':::Access Token  :::'+accessToken);
		$.ajax({
			type: restType || "GET",
			url: "https://aau--dev6--c.cs12.visual.force.com/services/proxy",
			dataType: dataType,
			contentType:"application/json",
			cache: false,
			data:'003V0000009kTMpIAM', // to be remove after testing  
			success: function(data, ts, xhr){
				var result = xhr.responseText;
				if(dType == 'xml'){
					result = $.xml2json(result);
				}
				console.log("SUCCESS: " + ts);
                console.log("DATA: "+ JSON.stringify(data));
				console.log('Success with REST call: ' + JSON.stringify(result));
				
				successCallback(result);
			},
			error: function(jqXHR, ts, et) {
				console.log('Error in REST call: ' + JSON.stringify(jqXHR));
				failureCallback(jqXHR);
			},
			headers: {Authorization: "OAuth " + accessToken,
			"SalesforceProxy-Endpoint": 'https://aau--dev6.cs12.my.salesforce.com/services/apexrest/classSchedule'}
		});
	}
	*/
};

/*// Object with utility functions
var Utils = function() {
    // Determines if loggin is enabled, if false calls to utils.log will not
    // output to the console (ideal for production release). Use true while developing
    var loggingEnabled = true;
    var android = null;
    
    return {
        isAndroid: function() {
          if(android == null) {
            var ua = navigator.userAgent.toLowerCase();
	        android = ua.indexOf("android") > -1;
          }
          
          return android;
        },
        
        // Logs an object to the console if the console is available and if logging is enabled
        log: function(value) {
            if(loggingEnabled) {
                if(console) {
                    console.log(value);
                }
            }
        },

		formatDate: function(myDate){
			var dayList = new Array ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
			var monthList = new Array('January','February','March','April','May','June','July','August','September','October','November','December');

			return dayList[myDate.getDay()]+', '+monthList[myDate.getMonth()]+' '+myDate.getDate();
		}
    }
};

var utils = new Utils();*/


if (typeof cordova !== "undefined") {
	/**
	 * Constructor
	 */
	function DatePicker() {
		this._callback;
	}

	/**
	 * show - true to show the ad, false to hide the ad
	 */
	DatePicker.prototype.show = function(options, cb) {
		if (options.date) {
			options.date = (options.date.getMonth() + 1) + "/" + (options.date.getDate()) + "/" + (options.date.getFullYear()) + "/"
					+ (options.date.getHours()) + "/" + (options.date.getMinutes());
		}
		var defaults = {
			mode : '',
			date : '',
			allowOldDates : true
		};

		for ( var key in defaults) {
			if (typeof options[key] !== "undefined")
				defaults[key] = options[key];
		}
		this._callback = cb;

		return cordova.exec(cb, failureCallback, 'DatePickerPlugin', defaults.mode, new Array(defaults));
	};

	DatePicker.prototype._dateSelected = function(date) {
		var d = new Date(parseFloat(date) * 1000);
		if (this._callback)
			this._callback(d);
	};

	function failureCallback(err) {
		console.log("datePickerPlugin.js failed: " + err);
	}

	cordova.addConstructor(function() {
		if (!window.plugins) {
			window.plugins = {};
		}
		window.plugins.datePicker = new DatePicker();
	});
};

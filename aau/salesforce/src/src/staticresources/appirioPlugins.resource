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
        
        PhoneGap.exec(opts.onSuccess, opts.onFailure, "com.appirio.mobile.storage","storeFile",
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
        PhoneGap.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "urlForFile", [fileVersionId, fileName, fileDocumentId]);
    },
    
    /**
     * Retrieves a URL for a previously downloaded file, if it exists. If the file does not exist, an empty string is returned.
     *   fileVersionId - a unique id used for this specific version of the file. In SFDC Content, this is ContentVersion.Id.
     *   fileDocumentId - a unqiue id of the parent document for the file. In SFDC Content, this is ContentVersion.ContentDocumentId
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    deleteFile: function(fileVersionId, fileDocumentId, onSuccess, onFailure) {
        PhoneGap.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "deleteFile", [fileVersionId, fileDocumentId]);
    },
    
    /**
     * Collects all local content and returns a JSON string describing the files. When parsed, the returned object is an array of 
     * object with properties fileDocumentId and fileId.
     *   onSuccess - success callback. called with the local URL for the file
     *   onFailure - failure callback
     */
    getLocalFiles: function(onSuccess, onFailure) {
        PhoneGap.exec(onSuccess, onFailure, "com.appirio.mobile.storage", "localFiles", []);
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
        PhoneGap.exec("com.appirio.mobile.webviewer.loadUrl", url, title, showOpenIn, showBookmark, isBookmarked);
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
        PhoneGap.exec(onSuccess, onFailure, "com.appirio.mobile.webviewer", "hideModalIndeterminateProgress", []);
    },
    
    /**
     * Displays a modal indeterminate progress view
     *   label - a text label to display
     */
    showProgress: function(label) {
        PhoneGap.exec("com.appirio.mobile.webviewer.showModalIndeterminateProgress", label);
    }
};

var RestDataPlugin = {

	getPhonegapData: function(successCallback, failureCallback, restPath) {
		console.log('In RestDataPlugin.  Calling Phonegap...');
		PhoneGap.exec(successCallback, failureCallback, "com.appirio.mobile.webservice", "getContent", [restPath]);
		console.log('In RestDataPlugin.  Returned from Phonegap...');
	},

	getAjaxData: function(successCallback, failureCallback, restPath, restType, dataType) {
	     console.log(':::Access Token  :::'+accessToken);
		$.ajax({
			type: restType || "GET",
			url: "https://aau--dev6--c.cs12.visual.force.com/services/proxy",
			dataType: dataType,
			contentType:"application/json",
			cache: false,
			data:'003V0000009kTMpIAM', /** to be remove after testing **/ 
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
	},
	
	getAjaxDataByForceTK: function(successCallback, failureCallback, restPath, restType, dataType,webUrl,client) {
		    var server = "https://" + window.location.host + "/services/Soap/u/7.0"
			var wsPath =  restPath;
			var clientId = client;
			console.log('AccessToken: ' + accessToken);
			// Get an instance of the REST API client and set the session ID
			var client = new forcetk.Client(clientId); //, loginUrl);
			client.setSessionToken(accessToken);
			client.setRefreshToken(accessToken);
			client.apexrest(wsPath, function(result){
				//console.log('Success! '+JSON.stringify(result)); //+JSON.stringify(result));
				successCallback(result);
			}, function(error){
				//console.log('Error! '+JSON.stringify(error));
				failureCallback(result);
			}, 'GET',webUrl);
	},
	

	isPhonegap: function(){
	    if (!PhoneGap.available){
			return false;
		}else{
			return true;
		}
	}
	
};






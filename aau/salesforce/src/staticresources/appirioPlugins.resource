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



/*

File: utils.js
Description: Utility functions

Change Log:

Mauricio Created on 07/05/12

*/

// Object with utility functions
var Utils = function() {
    // Determines if loggin is enabled, if false calls to utils.log will not
    // output to the console (ideal for production release). Use true while developing
    var loggingEnabled = true;
    
    return {
        // Logs an object to the console if the console is available and if logging is enabled
        log: function(value) {
            if(loggingEnabled) {
                if(console) {
                    console.log(value);
                }
            }
        }
    }
};

var utils = new Utils();
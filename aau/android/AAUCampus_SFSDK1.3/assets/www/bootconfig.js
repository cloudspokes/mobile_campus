     
     
//-----------------------------------------------------------------
// Replace the values below with your own app configuration values.
//-----------------------------------------------------------------

// When debugMode is true, logToConsole() messages will be written to a
// "debug console" section of the page.
var debugMode = false;

// The client ID value specified for your remote access object that defines
// your application in Salesforce.
//var remoteAccessConsumerKey = "3MVG9CVKiXR7Ri5ref1HmPTy8XeK_IF39U4xjE4BD2X9a.wuLMiKebAKEWXoIPih1v9EFDFvDJdib_UwRhY7.";
//var remoteAccessConsumerKey = "3MVG9Oe7T3Ol0ea4rCgfMtZo3n_mXSltHtoXuUmTdm2z8ejIRdnI0YcJzQsnNJhBykE346daTM7FRrh6wCitY";
//var remoteAccessConsumerKey = "3MVG98dostKihXN5.FFmqH4daeflGQOEDPQNxulfC7mn5oPhzooVtCo0RDjeLsVNwgM.AHLv3C69GF4gnLs5F";    
// Dev 7 test key
var remoteAccessConsumerKey = "3MVG98dostKihXN6UJFri4fKjPBBzKsNkI_fIy3wnvP5_NSj0HxOTJD9ZE1bKRL7ZXbPuLkzBAPvj4eTB.HI6";

// The redirect URI value specified for your remote access object that defines
// your application in Salesforce.
var oauthRedirectURI = "aautransit:///mobilesdk/detect/oauth/done";
//var oauthRedirectURI = "sfdc://success";

// The authorization/access scope(s) you wish to define for your application.
var oauthScopes = ["web", "api"];

//The start data associated with the application.  Use SFHybridApp.LocalAppStartData for a "local"
//PhoneGap-based application, and SFHybridApp.RemoteAppStartData for a Visualforce-based
//application.  The default representations are below, or you can look at the data
//classes in SFHybridApp.js to see how you can further customize your options.
//var startData = new SFHybridApp.LocalAppStartData();  // Used for local REST-based "index.html" PhoneGap apps.
var startData = new SFHybridApp.RemoteAppStartData("apex/mob_StudentHome"); // Used for Visualforce-based apps.


// Whether the container app should automatically refresh our oauth session on app foreground:
// generally a good idea for Visualforce pages.  For REST-based apps we recommend using
// onAppResume to refresh if needed.
var autoRefreshOnForeground = true; //Use true for Visualforce-based apps

// Whether the container app should automatically refresh our oauth session periodically
var autoRefreshPeriodically = true; 

//-----------------------------------------------------------------
// End configuration block
//-----------------------------------------------------------------
        
            


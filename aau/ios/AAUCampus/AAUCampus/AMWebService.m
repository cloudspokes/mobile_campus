//
//  AMWebService.m
//  GGP Mobile
//
//  Created by Marlin Scott on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMWebService.h"
#import "AppDelegate.h"
#import "MetadataManager.h"

@implementation AMWebService
@synthesize receivedData = _receivedData;
@synthesize callbackId = _callbackId;
@synthesize queue = _queue;



- (void)getRestData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    
    if (_queue == nil) {
        _queue = [[NSMutableDictionary alloc] init];
    }
    [[MetadataManager sharedManager]getTeletracCredentials];

    NSString *_accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] refreshToken];
    
    
    _callbackId = (NSString*)[arguments objectAtIndex:0];
    NSMutableString* url = [(NSString*) [arguments objectAtIndex:1] mutableCopy];
    
    NSRange textRange;
    textRange =[[url lowercaseString] rangeOfString:[@"teletrac.net" lowercaseString]];
    
    if(textRange.location != NSNotFound)
    {
        NSLog(@"add password");
        NSDictionary *teleCreds = [[MetadataManager sharedManager] teletracCreds] ;
        url = [[url stringByAppendingFormat:@"?strAccountId=%@&strUserName=%@&strPwd=%@",[teleCreds objectForKey:@"Account"], [teleCreds objectForKey:@"Username"], [teleCreds objectForKey:@"Password"]] mutableCopy];
        //Does contain the substring
        
    }
    
    
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    
    url = (NSMutableString *) [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestDictionary setValue:[arguments objectAtIndex:0] forKey:@"callbackId"];
    [requestDictionary setValue:[arguments objectAtIndex:1] forKey:@"url"];
    [requestDictionary setValue:[NSMutableData data] forKey:@"data"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:600];
    
    // only add oauth info to force.com urls
    if ([[[NSURL URLWithString:url] host] rangeOfString:@"force.com" options:NSBackwardsSearch].location != NSNotFound) {
        // add oauth header to request in case this is authenticated content.
        // TODO: should only do this for salesforce domains
        NSString* oauthHeader = [NSString stringWithFormat:@"OAuth %@", _accessToken];
        
        [request addValue:oauthHeader forHTTPHeaderField:@"Authorization"];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        
    } else {
        
        [_queue setObject:requestDictionary forKey:[NSValue valueWithPointer:(__bridge void*)connection]];
    }
    
    
}

#pragma mark delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did receive response %@", [response MIMEType] );
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)connection]];
    [[queueObject objectForKey:@"data"] setLength:0];
}

// called for each data chunk received.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did receive data");
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)connection]];
    [[queueObject objectForKey:@"data"]  appendData:data];
    
}

// NOTE: this is not documented in the NSURLConnectionDelegate doc but in "URL Loading System Programming Guide"
-(void)connectionDidFinishLoading:(NSURLConnection*)conn {
    NSLog(@"did finish");
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)conn]];
    NSLog(@"Succeeded! Received %d bytes of data",[[queueObject objectForKey:@"data"] length]);
    NSString *dataString = [[NSString alloc] initWithData:[queueObject objectForKey:@"data"] encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@", dataString);
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:dataString];
    [self writeJavascript:[pluginResult toSuccessCallbackString:[queueObject objectForKey:@"callbackId"]]];
    
    [_queue removeObjectForKey:[NSValue valueWithPointer:(__bridge const void*)conn]];
    NSLog(@"queue count: %d", [_queue count]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"did fail with error %@", error);
    
}


@end

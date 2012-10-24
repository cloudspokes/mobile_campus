//
//  MetadataManager.m
//  AAU Hybrid
//
//  Created by Marlin Scott on 8/1/12.
//
//

#import "MetadataManager.h"
#import "AppDelegate.h"
//#import "SalesforceHybridSDK/SFJsonUtils.h"

@implementation MetadataManager

@synthesize teletracCreds = _teletracCreds;
@synthesize receivedData = _receivedData;


+ (id)sharedManager
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (void)getTeletracCredentials{
        
    if (_teletracCreds || retrievingCreds) {
        return;
    }
    
    retrievingCreds = YES;
    NSString *_accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] refreshToken];
    NSString *_instanceUrl = [(AppDelegate *)[[UIApplication sharedApplication] delegate] instanceUrl];
    

    NSString* url =[NSString stringWithFormat:@"%@/services/apexrest/teletracInfo/", _instanceUrl];
    
    
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        
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
        
        _receivedData = [NSMutableData data] ;
    }
    
    
}

#pragma mark delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did receive response %@", [response MIMEType] );
    [_receivedData setLength:0];
}

// called for each data chunk received.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did receive data");
    [_receivedData  appendData:data];
    
}

// NOTE: this is not documented in the NSURLConnectionDelegate doc but in "URL Loading System Programming Guide"
-(void)connectionDidFinishLoading:(NSURLConnection*)conn {
    NSLog(@"did finish");
    NSString *dataString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    //SBJsonParser *parser = [[SBJsonParser alloc] init];
    //_teletracCreds = [SFJsonUtils objectFromJSONString:dataString] ;
    NSError *e;
    _teletracCreds = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONWritingPrettyPrinted error:&e];
    
    NSLog(@"data: %@", dataString);
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"did fail with error %@", error);
    
}


@end

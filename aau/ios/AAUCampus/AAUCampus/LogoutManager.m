//
//  LogoutManager.m
//  AAU Hybrid
//
//  Created by Marlin Scott on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogoutManager.h"
#import "AppDelegate.h"//;
#import "SalesforceHybridSDK/CDVPlugin.h"//;
//#import "SalesforceHybridSDK/SalesforceOAuthPlugin.h"//;
//#import "SalesforceHybridSDK/SFOAuthCoordinator.h"//;
#import "SalesforceHybridSDK/SFContainerAppDelegate.h"//;

@implementation LogoutManager


- (void)LogoutManager:(NSArray *)params withDict:(NSDictionary *)dictionary{
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] ];
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] setLoggedOut:YES ];
    
    //NSString *js = @"aauMobile.init.resetApplication();";

    
//    [(SalesforceOAuthPlugin *) [(AppDelegate *)[[UIApplication sharedApplication] delegate] getAuthPlugin] logout];
////    [(SalesforceOAuthPlugin *) [(AppDelegate *)[[UIApplication sharedApplication] delegate] getAuthPlugin] resetAppState];
//    [(SFOAuthCoordinator *) [(AppDelegate *)[[UIApplication sharedApplication] delegate] getCoordinator] authenticate];
//
//    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] webView] performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];


}



@end

//
//  LogoutManager.h
//  AAU Hybrid
//
//  Created by Marlin Scott on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesforceHybridSDK/CDVPlugin.h"//;
//#import "SalesforceHybridSDK/SalesforceOAuthPlugin.h"//;
//#import "SalesforceHybridSDK/SFOAuthCoordinator.h"//;
//#import "SalesforceHybridSDK/SFContainerAppDelegate.h"//;



@interface LogoutManager : CDVPlugin{
   
}

- (void)LogoutManager:(NSString *)url withDict:(NSDictionary *)dictionary;


@end

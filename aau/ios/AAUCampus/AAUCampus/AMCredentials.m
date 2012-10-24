//
//  AMCredentials.m
//  AAU Hybrid
//
//  Created by Marlin Scott on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMCredentials.h"
#import "AppDelegate.h"

@implementation AMCredentials

- (void)AMCredentials:(NSArray *)params withDict:(NSDictionary *)dictionary{
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] ];
    //[(AppDelegate *)[[UIApplication sharedApplication] delegate] setLoggedOut:YES ];
    NSLog(@"**** creds ****");
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setInstanceUrl:[params objectAtIndex:1]];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRefreshToken:[params objectAtIndex:3]];    
}

@end

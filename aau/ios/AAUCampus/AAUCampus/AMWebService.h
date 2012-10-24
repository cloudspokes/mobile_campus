//
//  AMWebService.h
//  GGP Mobile
//
//  Created by Marlin Scott on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesforceHybridSDK/CDVPlugin.h"//;

@interface AMWebService : CDVPlugin{
    NSMutableData *receivedData;
    NSString* callbackId;
    
    NSMutableDictionary *queue;
}

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString* callbackId;
@property (nonatomic, retain) NSMutableDictionary *queue;

- (void)getRestData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

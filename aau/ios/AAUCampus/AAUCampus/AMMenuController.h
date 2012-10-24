//
//  AMMenuController.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/18/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesforceHybridSDK/CDVPlugin.h"

@interface AMMenuController : CDVPlugin

- (void)toggleMenu:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

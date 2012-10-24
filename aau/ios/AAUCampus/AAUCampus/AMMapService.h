//
//  AMMapService.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/16/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalesforceHybridSDK/CDVPlugin.h"

@class AMMapViewController;

@interface AMMapService : CDVPlugin{
    AMMapViewController *mapView;
    UINavigationController *navController;

}

@property (nonatomic, strong) AMMapViewController *mapView;
@property (nonatomic, strong) UINavigationController *navController;

- (void)showMap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end

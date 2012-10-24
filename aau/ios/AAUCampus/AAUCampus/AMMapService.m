//
//  AMMapService.m
//  AAUCampus
//
//  Created by Marlin Scott on 10/16/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import "AMMapService.h"
#import "AMMapViewController.h"
#import "AppDelegate.h"


@implementation AMMapService
@synthesize mapView = _mapView;
@synthesize navController = _navController;


- (void)showMap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options{
    _mapView = [[AMMapViewController alloc] init];
    
    _navController = [[UINavigationController alloc] initWithRootViewController:_mapView] ;
    [[_navController navigationBar] setBarStyle:UIBarStyleBlack];
    
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] addSubview:[_navController view]];
    
}



@end

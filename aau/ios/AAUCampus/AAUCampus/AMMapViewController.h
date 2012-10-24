//
//  AMMapViewController.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/16/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AMMapViewController : UIViewController <MKMapViewDelegate>{
    MKMapView *mapView;
    NSMutableDictionary *queue;
    NSMutableDictionary *stops;
    NSMutableDictionary *routes;
    
    BOOL locationSet;

}

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableDictionary *queue;
@property (nonatomic, strong) NSMutableDictionary *stops;
@property (nonatomic, strong) NSMutableDictionary *routes;


- (void)loadStops;
- (void)loadBuses;
- (void)addBusStops:(NSArray *)stops;

@end

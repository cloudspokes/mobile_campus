//
//  AMRouteOverLay.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/19/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AMRouteOverLay : UIView  {
	MKMapView *mapView;
	NSArray *routes;
	UIColor *lineColor;
}

- (id)initWithMapView:(MKMapView *)mapView;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) UIColor *lineColor;

@end

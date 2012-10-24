//
//  BusAnnotation.m
//  AAUCampus
//
//  Created by Marlin Scott on 10/17/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import "BusAnnotation.h"

@implementation BusAnnotation

@synthesize image;
@synthesize latitude;
@synthesize longitude;
@synthesize stopName = _stopName;
@synthesize stopSubTitle = _stopSubTitle;


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [latitude doubleValue];
    theCoordinate.longitude = [longitude doubleValue];
    return theCoordinate;
}



- (NSString *)title
{
    return _stopName;
}

// optional
- (NSString *)subtitle
{
    return _stopSubTitle;
}

@end

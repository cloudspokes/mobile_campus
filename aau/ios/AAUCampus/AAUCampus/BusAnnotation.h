//
//  BusAnnotation.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/17/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BusAnnotation : NSObject<MKAnnotation>
{
    UIImage *image;
    NSNumber *latitude;
    NSNumber *longitude;
    NSString *stopName;
    NSString *stopSubTitle;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSString *stopSubTitle;

@end

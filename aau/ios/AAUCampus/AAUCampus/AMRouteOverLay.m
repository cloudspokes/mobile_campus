//
//  AMRouteOverLay.m
//  AAUCampus
//
//  Created by Marlin Scott on 10/19/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import "AMRouteOverLay.h"

@implementation AMRouteOverLay
@synthesize mapView = _mapView;
@synthesize routes = _routes;
@synthesize lineColor = _lineColor;

- (id)initWithMapView:(MKMapView *)myMapView {
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, mapView.frame.size.width, mapView.frame.size.height)];
	if (self != nil) {
		_mapView = myMapView;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		[_mapView addSubview:self];
	}
	
	return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if(!self.hidden && self.routes != nil && self.routes.count > 0) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		if(!self.lineColor) {
			self.lineColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
		}
		
		CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
		CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
		
		CGContextSetLineWidth(context, 4.0f);
		
		for(int i = 0; i < self.routes.count; i++) {
			CLLocation* location = [self.routes objectAtIndex:i];
			CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:self];
			
			if(i == 0) {
				CGContextMoveToPoint(context, point.x, point.y);
			} else {
				CGContextAddLineToPoint(context, point.x, point.y);
			}
		}
		
		CGContextStrokePath(context);
	}

}


- (void)setRoutes:(NSArray *)routePoints {
	if (_routes != routePoints) {
		_routes = routePoints;
		
		CLLocationDegrees maxLat = -90.0f;
		CLLocationDegrees maxLon = -180.0f;
		CLLocationDegrees minLat = 90.0f;
		CLLocationDegrees minLon = 180.0f;
		
		for (int i = 0; i < self.routes.count; i++) {
			CLLocation *currentLocation = [self.routes objectAtIndex:i];
			if(currentLocation.coordinate.latitude > maxLat) {
				maxLat = currentLocation.coordinate.latitude;
			}
			if(currentLocation.coordinate.latitude < minLat) {
				minLat = currentLocation.coordinate.latitude;
			}
			if(currentLocation.coordinate.longitude > maxLon) {
				maxLon = currentLocation.coordinate.longitude;
			}
			if(currentLocation.coordinate.longitude < minLon) {
				minLon = currentLocation.coordinate.longitude;
			}
		}
		
		MKCoordinateRegion region;
		region.center.latitude     = (maxLat + minLat) / 2;
		region.center.longitude    = (maxLon + minLon) / 2;
		region.span.latitudeDelta  = maxLat - minLat;
		region.span.longitudeDelta = maxLon - minLon;
		
		[_mapView setRegion:region animated:YES];
		
		[self setNeedsDisplay];
	}
}


@end

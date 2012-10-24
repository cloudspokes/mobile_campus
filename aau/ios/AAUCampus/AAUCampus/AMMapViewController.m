//
//  AMMapViewController.m
//  AAUCampus
//
//  Created by Marlin Scott on 10/16/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import "AMMapViewController.h"
#import "MetadataManager.h"
#import "AppDelegate.h"
#import "XMLReader.h"

@interface AMMapViewController ()

@end

@implementation AMMapViewController
@synthesize mapView = _mapView;
@synthesize queue = _queue;
@synthesize stops = _stops;
@synthesize routes = _routes;

#pragma mark -

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 20.0f;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *buttonImage = [UIImage imageNamed:@"text-list.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[aButton layer] setCornerRadius:5.0];
    [aButton setBackgroundColor:[UIColor redColor]];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    // Initialize the UIBarButtonItem
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    [aButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.leftBarButtonItem = aBarButtonItem;	// Do any additional setup after loading the view.
    
    UIImage *rightButtonImage = [UIImage imageNamed:@"info.png"];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[rightButton layer] setCornerRadius:5.0];
    [rightButton setBackgroundColor:[UIColor redColor]];
    [rightButton setImage:rightButtonImage forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0.0, 0.0, rightButtonImage.size.width, rightButtonImage.size.height);
    
    // Initialize the UIBarButtonItem
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    
    [rightButton addTarget:self action:@selector(showTransitPopOver:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;	// Do any additional setup after loading the view.
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:YES];
    [_mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    [self loadStops];
    [self loadBuses];

    
    [[self view] addSubview:_mapView];
    
    //[[MetadataManager sharedManager]getTeletracCredentials];
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!locationSet) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = _mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.02;
        mapRegion.span.longitudeDelta = 0.02;
        
        [_mapView setRegion:mapRegion animated: YES];
        locationSet = YES;
    }
    
    
}

- (void)loadStops{
    
    if (_queue == nil) {
        _queue = [[NSMutableDictionary alloc] init];
    }
    
    NSString *_accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] refreshToken];
    NSString *_instanceUrl = [(AppDelegate *)[[UIApplication sharedApplication] delegate] instanceUrl];
    
    NSMutableString* url = [NSString stringWithFormat:@"%@/services/apexrest/BusStops/", _instanceUrl];
    
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    
    url = (NSMutableString *) [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestDictionary setValue:@"loadBusStops" forKey:@"callback"];
    [requestDictionary setValue:url forKey:@"url"];
    [requestDictionary setValue:[NSMutableData data] forKey:@"data"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:600];
    
    // only add oauth info to force.com urls
    if ([[[NSURL URLWithString:url] host] rangeOfString:@"force.com" options:NSBackwardsSearch].location != NSNotFound) {
        // add oauth header to request in case this is authenticated content.
        // TODO: should only do this for salesforce domains
        NSString* oauthHeader = [NSString stringWithFormat:@"OAuth %@", _accessToken];
        
        [request addValue:oauthHeader forHTTPHeaderField:@"Authorization"];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        
    } else {
        NSLog(@"call made");
        [_queue setObject:requestDictionary forKey:[NSValue valueWithPointer:(__bridge void*)connection]];

    }
    
}


- (void)loadBuses{
    if (_queue == nil) {
        _queue = [[NSMutableDictionary alloc] init];
    }
    [[MetadataManager sharedManager]getTeletracCredentials];
    
    NSString *_accessToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] refreshToken];
    
    NSMutableString* url = [@"https://xmlgateway.teletrac.net/AsciiService.asmx/GetVehicles" mutableCopy];
    
    
    url = (NSMutableString *) [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSRange textRange;
    textRange =[[url lowercaseString] rangeOfString:[@"teletrac.net" lowercaseString]];
    
    if(textRange.location != NSNotFound)
    {
        NSLog(@"add password");
        NSDictionary *teleCreds = [[MetadataManager sharedManager] teletracCreds] ;
        url = [[url stringByAppendingFormat:@"?strAccountId=%@&strUserName=%@&strPwd=%@",[teleCreds objectForKey:@"Account"], [teleCreds objectForKey:@"Username"], [teleCreds objectForKey:@"Password"]] mutableCopy];
        //Does contain the substring
        
    }
    
    
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    
    url = (NSMutableString *) [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestDictionary setValue:@"loadBuses" forKey:@"callback"];
    [requestDictionary setValue:[NSMutableData data] forKey:@"data"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:600];
    
    // only add oauth info to force.com urls
        
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        
    } else {
        
        [_queue setObject:requestDictionary forKey:[NSValue valueWithPointer:(__bridge void*)connection]];
    }

    
    
}

#pragma  - NSURLConnect Delegate Methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did receive response %@", [response MIMEType] );
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)connection]];
    [[queueObject objectForKey:@"data"] setLength:0];
}

// called for each data chunk received.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did receive data");
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)connection]];
    [[queueObject objectForKey:@"data"]  appendData:data];
    
}

// NOTE: this is not documented in the NSURLConnectionDelegate doc but in "URL Loading System Programming Guide"
-(void)connectionDidFinishLoading:(NSURLConnection*)conn {
    NSLog(@"did finish");
    NSMutableDictionary *queueObject = [_queue objectForKey:[NSValue valueWithPointer:(__bridge const void*)conn]];
    NSLog(@"Succeeded! Received %d bytes of data",[[queueObject objectForKey:@"data"] length]);
    NSString *dataString = [[NSString alloc] initWithData:[queueObject objectForKey:@"data"] encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@", dataString);
    
    NSError *error;
    if ([[queueObject objectForKey:@"callback"] isEqualToString:@"loadBusStops"]) {
        NSArray *stopDict = [NSJSONSerialization JSONObjectWithData:[queueObject objectForKey:@"data"] options:NSJSONWritingPrettyPrinted error:&error];
        [self addBusStops:stopDict];
    } else if ([[queueObject objectForKey:@"callback"] isEqualToString:@"loadBuses"]) {
        NSError *parserError = nil;
        
        NSDictionary *busDict = [XMLReader dictionaryForXMLData:[queueObject objectForKey:@"data"] error:&parserError];
        [self addBuses:[[busDict objectForKey:@"TResponse"] objectForKey:@"Vehicle"]];
    }
    
    [_queue removeObjectForKey:[NSValue valueWithPointer:(__bridge const void*)conn]];
    NSLog(@"queue count: %d", [_queue count]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"did fail with error %@", error);
    
}


- (void)addBusStops:(NSArray *)myStops{
    
    _routes = [[NSMutableDictionary alloc] init];
    _stops = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *route in myStops) {
        NSLog(@"route: %@", [route objectForKey:@"routeName"]);
        [_routes setValue:[route objectForKey:@"routeName"] forKey:[route objectForKey:@"routeName"]];
        for (NSDictionary *routeStop in [route objectForKey:@"stops"]) {
            if ([_stops objectForKey:[routeStop objectForKey:@"stopName"]] == nil) {
                BusStopAnnotation *annotation = [[BusStopAnnotation alloc] init];
                [annotation setStopName:[routeStop objectForKey:@"stopName"]];
                [annotation setImage:[UIImage imageNamed:@"marker_busstop.png"]];
                [annotation setLatitude:[NSNumber numberWithFloat:[[routeStop objectForKey:@"latitude"] doubleValue]]];
                [annotation setLongitude:[NSNumber numberWithFloat:[[routeStop objectForKey:@"longitude"] doubleValue]]];
                [_mapView addAnnotation:annotation];
                
                [_stops setValue:routeStop forKey:[routeStop objectForKey:@"stopName"]];
            }
        }
    }
    
    
}

- (void)addBuses:(NSArray *)myBuses{
    
    
    
    for (NSDictionary *bus in myBuses) {
        NSLog(@"bus: %@", bus);
        NSArray *nameParts = [(NSString *)[[bus objectForKey:@"VehicleName"] objectForKey:@"text"] componentsSeparatedByString:@"_"];
        
        if ([nameParts count] == 3) {
            NSLog(@"add vehicle");
            BusAnnotation *annotation = [[BusAnnotation alloc] init];
            [annotation setStopName:[NSString stringWithFormat:@"Route: %@", [nameParts objectAtIndex:1]]];
            [annotation setStopSubTitle:[NSString stringWithFormat:@"Vehicle: %@ %@", [nameParts objectAtIndex:0], [nameParts objectAtIndex:2]]];
            NSString *busImageString = [NSString stringWithFormat:@"marker_%@.png", [nameParts objectAtIndex:1]];
            [annotation setImage:[UIImage imageNamed:busImageString]];
            [annotation setLatitude:[NSNumber numberWithFloat:[[[bus objectForKey:@"Latitude"] objectForKey:@"text"] doubleValue]]];
            [annotation setLongitude:[NSNumber numberWithFloat:[[[bus objectForKey:@"Longitude"] objectForKey:@"text"] doubleValue]]];
            [_mapView addAnnotation:annotation];

        }

    }
    
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[BusStopAnnotation class]]) // for Golden Gate Bridge
    {
        static NSString* BusStopAnnotationIdentifier = @"BusStopAnnotationIdentifier";
        MKPinAnnotationView* pinView =
        (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:BusStopAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:BusStopAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *markerImage = [(BusStopAnnotation *)annotation image];
            
            CGRect resizeRect;
            
            resizeRect.size = CGSizeMake(25.0, 30.0);
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [AMMapViewController annotationPadding],
                                         [AMMapViewController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [AMMapViewController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [markerImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:markerImage];
            //annotationView.leftCalloutAccessoryView = sfIconView;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showSchedule:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
            
            return annotationView;
        } 
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    } else if ([annotation isKindOfClass:[BusAnnotation class]]) {
        static NSString* BusAnnotationIdentifier = @"BusAnnotationIdentifier";
        MKPinAnnotationView* pinView =
        (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:BusAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:BusAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            
            UIImage *markerImage = [(BusStopAnnotation *)annotation image];
            
            CGRect resizeRect;
            
            resizeRect.size = CGSizeMake(25.0, 30.0);
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [AMMapViewController annotationPadding],
                                         [AMMapViewController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [AMMapViewController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [markerImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
            annotationView.opaque = NO;
            
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showSchedule:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;

            
            return annotationView;
        }
    }
    
    return nil;
}

- (void)showSchedule:(id)sender{
    NSLog(@"show schedule");
    BusScheduleTableViewController *scheduleView = [[BusScheduleTableViewController alloc] init];
    [[self navigationController] pushViewController:scheduleView animated:YES];
}

- (void)showTransitPopOver:(id)sender{
    NSLog(@"show transit popover");
}

- (void)showMenu:(id)sender{
    NSLog(@"show menu");
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGPoint center = self.navigationController.view.center;
                         if (center.x > self.view.frame.size.width/2) {
                             center.x = self.view.frame.size.width/2;
                         } else {
                             center.x +=180;
                         }
                         
                         self.navigationController.view.center = center;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
- (void)done:(id)sender{
    [[[self navigationController] view] removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

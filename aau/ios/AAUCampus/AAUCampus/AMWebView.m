//
//  AMWebView.m
//  AAU Hybrid
//
//  Created by Marlin Scott on 7/26/12.
//
//

#import "AMWebView.h"
#import "ModalWebViewController.h"
#import "AppDelegate.h"

@implementation AMWebView
@synthesize modalWebView = _modalWebView;
@synthesize navController = _navController;

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    //self = (AMWebViewer*)[super initWithWebView:theWebView];
    return self;
}


- (void)showWebView:(NSArray *)params withDict:(NSDictionary *)dictionary{
    
    NSString *url = [params objectAtIndex:1];
    _modalWebView = [[ModalWebViewController alloc] init] ;
    [_modalWebView setDelegate:self];
    [_modalWebView setUrl:url];

    _navController = [[UINavigationController alloc] initWithRootViewController:_modalWebView] ;
    [[_navController navigationBar] setBarStyle:UIBarStyleBlack];
    
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] addSubview:[_navController view]];

}

- (void)closeWindow:(id)sender{
    NSLog(@"close window");
    [[_navController view] removeFromSuperview];
    _modalWebView = nil;
    _navController = nil;
}

@end

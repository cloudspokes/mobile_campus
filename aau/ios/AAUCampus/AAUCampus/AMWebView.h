//
//  AMWebView.h
//  AAU Hybrid
//
//  Created by Marlin Scott on 7/26/12.
//
//

#import <Foundation/Foundation.h>
#import "SalesforceHybridSDK/CDVPlugin.h"//;

@class ModalWebViewController;

@interface AMWebView : CDVPlugin{
    ModalWebViewController *modalWebView;
    UINavigationController *navController;
}

@property (nonatomic, strong) ModalWebViewController *modalWebView;
@property (nonatomic, strong) UINavigationController *navController;


- (void)showWebView:(NSString *)url withDict:(NSDictionary *)dictionary;
- (void)closeWindow:(id)sender;

@end

//
//  AMMenuViewController.h
//  AAUCampus
//
//  Created by Marlin Scott on 10/10/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMMenuViewController : UIViewController <UIWebViewDelegate>{
    UIWebView *webView;
}

@property (nonatomic, strong) UIWebView *webView;

@end

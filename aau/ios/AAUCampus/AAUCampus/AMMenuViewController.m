//
//  AMMenuViewController.m
//  AAUCampus
//
//  Created by Marlin Scott on 10/10/12.
//  Copyright (c) 2012 Brandon Jones. All rights reserved.
//

#import "AMMenuViewController.h"

@interface AMMenuViewController ()

@end

@implementation AMMenuViewController
@synthesize webView = _webView;

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
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor redColor]];
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    [self.view addSubview:_webView];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, 200.0, 44.0)];
    [testLabel setText:@"Menu View"];
    [self.view addSubview:testLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

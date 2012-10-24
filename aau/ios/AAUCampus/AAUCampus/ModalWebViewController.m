//
//  ModalWebViewController.m
//  AAU Hybrid
//
//  Created by Marlin Scott on 7/26/12.
//
//

#import "ModalWebViewController.h"

@interface ModalWebViewController ()

@end

@implementation ModalWebViewController
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadUrl:(NSString *)url{
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"start loading");
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"finished");
    [_activityIndicator stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _webView = [[UIWebView alloc] init] ;
    [_webView setFrame:self.view.bounds];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_webView];
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_delegate action:@selector(closeWindow:)];
    closeBtn.tintColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.094f alpha:1.0f];
    self.navigationItem.rightBarButtonItem = closeBtn;
    
        // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView setScalesPageToFit:YES];
    [_webView loadRequest:request];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ModalWebViewController.h
//  AAU Hybrid
//
//  Created by Marlin Scott on 7/26/12.
//
//

#import <UIKit/UIKit.h>

@interface ModalWebViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    NSString *url;
    
    id delegate;
}

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loadUrl:(NSString *)url;
@end

/*
 Copyright (c) 2011-2012, salesforce.com, inc. All rights reserved.
 Author: Todd Stellanova
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "SalesforceHybridSDK/SFHybridViewController.h"
//#import "SalesforceHybridSDK/SalesforceOAuthPlugin.h"
//#import "SalesforceHybridSDK/SFOAuthCoordinator.h"

//#import "iRate.h"


@implementation AppDelegate
@synthesize loggedOut;
@synthesize refreshToken = _refreshToken;
@synthesize instanceUrl = _instanceUrl;
@synthesize menu = _menu;

#pragma mark - App lifecycle

// NOTE: be sure to call all super methods you override.



- (SalesforceOAuthPlugin *)getAuthPlugin{

    return _oauthPlugin;
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [super applicationDidBecomeActive:application];
    _menu = [[AMMenuViewController alloc] init];
    [[_menu view] setFrame:self.window.bounds];
    [[self window] insertSubview:[_menu view] atIndex:0];
    //[[self window] addSubview:[_menu view]];

}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSLog(@"did become active");
    //[iRate sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks-lite";
	//[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable debug mode
    //[iRate sharedInstance].debug = NO;
    
    NSString *js = @"aauMobile.init.appActivation();";
    [[self viewController] performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:js waitUntilDone:NO];
        
}


- (void)loggedIn{
    [[self viewController] loadStartPageIntoWebView];
    _menu = [[AMMenuViewController alloc] init];
    [[_menu view] setFrame:self.window.bounds];
    //[[self window] insertSubview:[_menu view] atIndex:0];
    [[self window] addSubview:[_menu view]];
}


@end

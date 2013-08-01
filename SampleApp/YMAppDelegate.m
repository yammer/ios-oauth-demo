//
//  YMAppDelegate.m
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "YMAppDelegate.h"

#import "YMSampleHomeViewController.h"
#import "YMLoginController.h"

@implementation YMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Yammer Sample App: YMHomeViewController is a sample with some basic functionality
    self.ymSampleHomeViewController = [[YMSampleHomeViewController alloc] init];

    self.window.rootViewController = self.ymSampleHomeViewController;
    [self.window makeKeyAndVisible];

    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer SDK:
// This is the method (launch point) that will be called when the user clicks the "Allow" button in mobile Safari after logging in to Yammer.
// The mobile-safari to app-launch functionality is enabled by adding a custom scheme and URL to your Info.plist file.  See the README.MD file
// that comes with this sample app or the Yammer iOS SDK Instructions on how to do this.  The custom scheme and URI/URL you add to the plist
// file must match the redirect URI you set on the Yammer client applications web site.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    // If we arrive here it means the login was successful, so now let's get the authToken to be used on all subsequent requests
    if ([[YMLoginController sharedInstance] handleLoginRedirectFromUrl:url sourceApplication:sourceApplication])
        return YES;
    
    // URL was not a match, or came from an application other than Safari
    return NO;
}

@end

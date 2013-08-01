//
//  YMAppDelegate.h
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLoginController.h"

@class YMSampleHomeViewController;
@class YMLoginController;

@interface YMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YMSampleHomeViewController *ymSampleHomeViewController;

@end

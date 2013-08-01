//
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//


#import "YMConstants.h"

// TODO: remove staging from URL and test on prod before shipping SDK.  Then remove this comment line.
NSString * const YAMMER_BASE_URL = @"https://www.yammer.com";

NSString * const YAMMER_MOBILE_SAFARI_STRING = @"com.apple.mobilesafari";

NSString * const YAMMER_AUTH_REDIRECT_URI = @"comyammersampleoauth://com.yammer.oauthscheme.returncode";

// Put your Yammer App's Client ID here
NSString * const YAMMER_APP_CLIENT_ID = @"";

// Put your Yammer App's Client Secret here.  How you manage this and where you store it is up to you.  This is just a static sample.
NSString * const YAMMER_APP_CLIENT_SECRET = @"";

NSString * const YMYammerSDKErrorDomain = @"com.yammer.YammerSDK.ErrorDomain";

const NSInteger YMYammerSDKLoginAuthenticationError = 1001;
const NSInteger YMYammerSDKLoginObtainAuthTokenError = 1002;

NSString * const YMYammerSDKLoginDidCompleteNotification = @"YMYammerSDKLoginDidCompleteNotification";
NSString * const YMYammerSDKLoginDidFailNotification = @"YMYammerSDKLoginDidFailNotification";

NSString * const YMYammerSDKAuthTokenUserInfoKey = @"YMYammerSDKAuthTokenUserInfoKey";
NSString * const YMYammerSDKErrorUserInfoKey  = @"YMYammerSDKErrorUserInfoKey";

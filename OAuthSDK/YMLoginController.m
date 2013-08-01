//
// Created by Jerry Destremps on 6/26/13.
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//


#import "YMLoginController.h"
#import "YMConstants.h"
#import "PDKeychainBindings.h"
#import "YMHTTPClient.h"
#import "NSURL+YMQueryParameters.h"

/////////////////////////////////////////////////////////
// Yammer iOS Client SDK
/////////////////////////////////////////////////////////

NSString * const YAMMER_QUERY_PARAM_CODE = @"code";
NSString * const YAMMER_QUERY_PARAM_ERROR = @"error";
NSString * const YAMMER_QUERY_PARAM_ERROR_REASON = @"error_reason";
NSString * const YAMMER_QUERY_PARAM_ERROR_DESCRIPTION = @"error_description";

// Note: In this sample app, we assuming single-network access.  If you have to work with mutliple networks you may
// want to save your authTokens differently (per network)
NSString * const YAMMER_KEYCHAIN_AUTH_TOKEN_KEY = @"yammerAuthToken";
NSString * const YAMMER_KEYCHAIN_STATE_KEY = @"yammerState";

@implementation YMLoginController

+ (YMLoginController *)sharedInstance
{
    static YMLoginController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

/////////////////////////////////////////////////////////
// Step 1: Attempt to login using Safari browser
/////////////////////////////////////////////////////////
- (void)startLogin
{
    NSString *stateParam = [self uniqueIdentifier];
    [[PDKeychainBindings sharedKeychainBindings] setObject:stateParam forKey:YAMMER_KEYCHAIN_STATE_KEY];
    
    NSDictionary *params = @{@"client_id": YAMMER_APP_CLIENT_ID,
                             @"redirect_uri": YAMMER_AUTH_REDIRECT_URI,
                             @"state": stateParam};
    
    NSString *query = AFQueryStringFromParametersWithEncoding(params, NSUTF8StringEncoding);
    NSString *urlString = [NSString stringWithFormat:@"%@/dialog/oauth?%@", YAMMER_BASE_URL, query];

    // Yammer SDK: This will launch mobile (iOS) Safari and begin the two-step login process.
    // The app delegate will intercept the callback from the login page.  See app delegate for method call.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (NSString *)uniqueIdentifier
{
    return [[NSUUID UUID] UUIDString];
}

/////////////////////////////////////////////////////////
// Step 2: See if we got the "code" in the response
/////////////////////////////////////////////////////////
- (BOOL)handleLoginRedirectFromUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    BOOL isValid = NO;

    // Make sure redirect is coming from mobile safari and URL has correct prefix
    if ( [sourceApplication isEqualToString:YAMMER_MOBILE_SAFARI_STRING] && [url.absoluteString hasPrefix:YAMMER_AUTH_REDIRECT_URI] )
    {
        NSDictionary *params = [url ym_queryParameters];

        NSString *state = params[@"state"];
        NSString *code = params[YAMMER_QUERY_PARAM_CODE];
        NSString *error = params[YAMMER_QUERY_PARAM_ERROR];
        NSString *error_reason = params[YAMMER_QUERY_PARAM_ERROR_REASON];
        NSString *error_description = params[YAMMER_QUERY_PARAM_ERROR_DESCRIPTION];
        
        NSString *storedState = [[PDKeychainBindings sharedKeychainBindings] objectForKey:YAMMER_KEYCHAIN_STATE_KEY];
        if ([state isEqualToString:storedState]) {
            [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:YAMMER_KEYCHAIN_STATE_KEY];
        }
        else {
            return NO;
        }

        if ( code || error ) {
            isValid = YES;
        }

        if ( error ) {

            NSString *errorString = error;
            if ( error_reason ) {
                errorString = [errorString stringByAppendingString:error_reason];
            }
            if ( error_description ) {
                errorString = [errorString stringByAppendingString:error_description];
            }

            // DEVELOPER: Put your error display/processing code here...
            NSLog(@"error: %@", errorString);
            
            NSError *error = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginAuthenticationError userInfo:@{NSLocalizedDescriptionKey: errorString}];
            
            [self.delegate loginController:self didFailWithError:error];
            [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification object:self userInfo:@{YMYammerSDKErrorUserInfoKey: error}];
        } else if ( code ) {

            NSLog(@"Credentials accepted, code received, on to part 2 of login process.");

            [self obtainAuthTokenForCode:code];
        }
    }

    return isValid;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step 3: Once you have the code, you must continue the login process in order to get the auth token.
//         This requires another call to the server with the code, clientId, and client secret
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)obtainAuthTokenForCode:(NSString *)code
{
    // The YMHTTPClient uses a "baseUrl" with paths appended.  The baseUrl looks like "https://www.mydomain.com"
    NSURL *baseURL = [NSURL URLWithString: YAMMER_BASE_URL];

    // Query params
    NSDictionary *params =
            @{@"client_id" : YAMMER_APP_CLIENT_ID,
            @"client_secret" : YAMMER_APP_CLIENT_SECRET,
            @"code" : code};

    // Yammer SDK: Note that once we have the authToken, we use a different constructor to create the client:
    //- (id)initWithBaseURL:(NSURL *)baseURL authToken:(NSString *)authToken.
    // But we don't have the authToken yet, so we use this:
    YMHTTPClient *client = [[YMHTTPClient alloc] initWithBaseURL:baseURL];

    __weak YMLoginController* weakSelf = self;

    [client postPath:@"/oauth2/access_token.json"
          parameters:params
             success:^(id responseObject) {
                 
                 NSDictionary *jsonDict = (NSDictionary *) responseObject;
                 NSDictionary *access_token = jsonDict[@"access_token"];
                 NSString *authToken = access_token[@"token"];
                 
                 // For debugging purposes only
                 NSLog(@"Yammer Login JSON: %@", responseObject);
                 NSLog(@"authToken: %@", authToken);
                 
                 // Save the authToken in the KeyChain
                 [weakSelf storeAuthTokenInKeychain:authToken];
                 
                 [weakSelf.delegate loginController:weakSelf didCompleteWithAuthToken:authToken];
                 [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidCompleteNotification object:weakSelf userInfo:@{YMYammerSDKAuthTokenUserInfoKey: authToken}];
             }
             failure:^(NSInteger statusCode, NSError *error) {
                 NSMutableDictionary *userInfo = [@{NSLocalizedDescriptionKey: @"Unable to retrieve authentication token from code"} mutableCopy];
                 if (error) {
                     userInfo[NSUnderlyingErrorKey] = error;
                     userInfo[NSLocalizedFailureReasonErrorKey] = [error localizedDescription];
                 }
                 
                 NSError *newError = [NSError errorWithDomain:YMYammerSDKErrorDomain code:YMYammerSDKLoginObtainAuthTokenError userInfo:userInfo];
                 
                 [weakSelf.delegate loginController:weakSelf didFailWithError:newError];
                 [[NSNotificationCenter defaultCenter] postNotificationName:YMYammerSDKLoginDidFailNotification object:weakSelf userInfo:@{YMYammerSDKErrorUserInfoKey: newError}];
             }
     ];
}

- (void)clearAuthToken
{
    [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:YAMMER_KEYCHAIN_AUTH_TOKEN_KEY];
}

- (void)storeAuthTokenInKeychain:(NSString *)authToken
{
    PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
    [bindings setObject:authToken forKey:YAMMER_KEYCHAIN_AUTH_TOKEN_KEY];
}

- (NSString *)storedAuthToken
{
    return [[PDKeychainBindings sharedKeychainBindings] objectForKey:YAMMER_KEYCHAIN_AUTH_TOKEN_KEY];
}

@end
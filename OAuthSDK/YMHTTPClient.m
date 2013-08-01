//
//  YMHTTPClient.m
//
// Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "YMLoginController.h"
#import "YMHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "NSURL+YMQueryParameters.h"
#import <sys/utsname.h>

@interface YMHTTPClient ()

@property (nonatomic, strong, readonly) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSURL *baseURL;

@end

@implementation YMHTTPClient
{
    AFHTTPClient *_httpClient;
    NSString *_authToken;
}

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
    [self updateAuthToken];
}

- (NSString *)authToken
{
    return _authToken;
}

- (void)updateAuthToken
{
    [_httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", self.authToken]];
}

- (id)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    
    if (self) {
        _baseURL = baseURL;
    }
    
    return self;
}

- (id)initWithBaseURL:(NSURL *)baseURL authToken:(NSString *)authToken
{
    self = [self initWithBaseURL:baseURL];
    
    if (self) {
        _authToken = authToken;
    }
    
    return self;
}

- (AFHTTPClient *)httpClient
{
    if (_httpClient)
        return _httpClient;
    
    _httpClient = [[AFHTTPClient alloc] initWithBaseURL:self.baseURL];
    [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [_httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [_httpClient setDefaultHeader:@"User-Agent" value:[self userAgent]];
    if (self.authToken) {
        [self updateAuthToken];
    }
    
    return _httpClient;
}

//example: Yammer/4.0.0.141 (iPhone; iPhone OS 5.0.1; tr_TR; en)
- (NSString *)userAgent
{
    //Yammer/{app_version} ({Device type, eg: iPhone/iPad/iPod}; {iOS version}; {locale}; {language})
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // Device Name (e.g. iPhone2,1 or iPad3,1 or x86_64 for simulator)
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *localeName = [[NSLocale currentLocale] localeIdentifier];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *userAgent = [NSString stringWithFormat:@"Yammer/%@ (%@; %@ %@; %@; %@)", appVersion, deviceModel, systemName, systemVersion, localeName, language];
    return userAgent;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure
{
    NSLog(@"GET %@", path);
    [self.httpClient getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(id responseObject))success
         failure:(void (^)(NSInteger statusCode, NSError *error))failure
{
    NSLog(@"POST %@", path);
    [self.httpClient postPath:path
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      success(responseObject);
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      // Forward the error
                      NSHTTPURLResponse *response = [operation response];
                      NSInteger statusCode = [response statusCode];
                      failure(statusCode, error);
                  }];
}

@end

//
//  NSURL+YMQueryParameters.m
//  YammerOAuth2SampleApp
//
//  Created by Dave Weston on 7/17/13.
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import "NSURL+YMQueryParameters.h"

@implementation NSURL (YMQueryParameters)

- (NSDictionary *)ym_queryParameters
{
    NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] init];
    
    NSArray *params = [self.query componentsSeparatedByString:@"&"];
    for (NSString *param in params) {
        NSArray *paramParts = [param componentsSeparatedByString:@"="];
        
        if (paramParts.count == 2) {
            NSString *paramName = [self ym_stringByDecodingURLFormat: [paramParts objectAtIndex:0]];
            NSString *paramValue = [self ym_stringByDecodingURLFormat: [paramParts objectAtIndex:1]];
            [queryDict setValue:paramValue forKey:paramName];
        }
    }
    
    return queryDict;
}

- (NSString *)ym_stringByDecodingURLFormat:(NSString *)urlPart
{
    NSString *result = [urlPart stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end

//
//  NSURL+YMQueryParameters.h
//  YammerOAuth2SampleApp
//
//  Created by Dave Weston on 7/17/13.
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (YMQueryParameters)

- (NSDictionary *)ym_queryParameters;

@end

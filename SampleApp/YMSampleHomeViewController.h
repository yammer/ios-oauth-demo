//
//  YMSampleHomeViewController.h
//  YammerOAuth2SampleApp
//
//  Copyright (c) 2013 Yammer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLoginController.h"

@interface YMSampleHomeViewController : UIViewController <YMLoginControllerDelegate>

@property (nonatomic) BOOL attemptingSampleAPICall;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;
@property (weak, nonatomic) IBOutlet UILabel *tokenExists;

// Yammer Sample App

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer Sample Code:
// Here's an example of attempting an API call.  First check to see if the authToken is available.
// If it's not available, then the user must login as the first step in acquiring the authToken.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)attemptYammerApiCall:(id)sender;

// This is the direct call to start the login flow (for testing purposes)
- (IBAction)login:(id)sender;

// This deletes the authToken from the keychain (for testing purposes)
- (IBAction)deleteToken:(id)sender;

// This clears the sample API call JSON results from the text field on the iPad. (for testing API calls)
- (IBAction)clearResults:(id)sender;

@end

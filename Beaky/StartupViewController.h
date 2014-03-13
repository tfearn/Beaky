//
//  StartupViewController.h
//  Joios
//
//  Created by Todd Fearn on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "ASIHTTPRequest.h"
#import "Globals.h"
#import "BaseViewController.h"
#import "Utility.h"

@interface StartupViewController : BaseViewController {
}

- (IBAction)loginWithFacebookButtonPressed:(id)sender;

@end

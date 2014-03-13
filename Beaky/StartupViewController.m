//
//  StartupViewController.m
//  Joios
//
//  Created by Todd Fearn on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StartupViewController.h"

@implementation StartupViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SIGN UP";
}

- (IBAction)loginWithFacebookButtonPressed:(id)sender {
    
	// TODO: Don't retain this object
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"email", nil];
    
    [self showWaitView:@"Please Wait..."];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if(!user) {
            [self dismissWaitView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"The Facebook login was cancelled.  A Facebook login is required to continue." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } 
        else  {
#if 0
            if(user.isNew) {
                // Post to Facebook
                FBRequest *request = [FBRequest requestForPostStatusUpdate:@"Just became part of Beaky. Join in at www.beaky.com"];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    // Don't worry about errors on this
                }];
            }
#endif
            
            // Grab the Facebook graph
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(error != nil) {
                    [self dismissWaitView];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"A Facebook request error occurred, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
                else {
                    [self parseFacebookGraph:result];
                }
            }];
        }
    }];
}

- (void)parseFacebookGraph:(id)result {
	NSDictionary *dict = result;
	MyLog(@"%@", dict);
    
    PFUser *user = [PFUser currentUser];
    NSString *fb_username = [dict objectForKey:@"name"];
    NSString *fb_userid = [dict objectForKey:@"id"];
    
    // Retrieve the facebook image
    NSString *imageUrl = [NSString stringWithFormat:kUrlFacebookPicture, fb_userid];
    NSURL *url = [NSURL URLWithString:imageUrl];
    __weak ASIHTTPRequest *picRequest = [ASIHTTPRequest requestWithURL:url];
    [picRequest setCompletionBlock:^{
        NSData *imageData = [picRequest responseData];
        
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error != nil) {
                [self dismissWaitView];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            // Create a UUID for the user
            NSString *uuid = [Utility getUUID];
            
            // Update the User record
            [user setObject:fb_username forKey:@"displayname"];
            [user setObject:imageUrl forKey:@"imageUrl"];
            [user setObject:imageFile forKey:@"imageFile"];
            [user setObject:dict forKey:@"facebookGraph"];
            [user setObject:uuid forKey:@"uuid"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error != nil) {
                    [self dismissWaitView];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Could not save Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginComplete object:self userInfo:nil];
            }];
        }];
    }];
    [picRequest setFailedBlock:^{
        [self dismissWaitView];
        NSError *error = [picRequest error];
        MyLog(@"%@", [error description]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Could not retrieve Facebook user information, please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    [picRequest startAsynchronous];
};

@end

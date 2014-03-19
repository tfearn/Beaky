//
//  User.m
//  Beaky
//
//  Created by Todd Fearn on 3/18/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize userId = _userId;
@synthesize imageFile = _imageFile;
@synthesize imageUrl = _imageUrl;
@synthesize image = _image;
@synthesize userName = _userName;
@synthesize displayName = _displayName;
@synthesize bio = _bio;
@synthesize distance = _distance;
@synthesize uuid = _uuid;

- (void)assignValuesFromObject:(PFUser *)user {
    self.userId = user.objectId;
    
    // Make sure this object has been retrieved
    NSArray *allKeys = user.allKeys;
    if([allKeys count] > 0) {
        self.imageFile = [Utility objectNotNSNull:[user objectForKey:@"imageFile"]];
        if(self.imageFile)
            self.imageUrl = [NSURL URLWithString:self.imageFile.url];
        self.userName = [Utility objectNotNSNull:[user objectForKey:@"username"]];
        self.displayName = [Utility objectNotNSNull:[user objectForKey:@"displayname"]];
    }
}

@end

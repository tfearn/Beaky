//
//  User.h
//  Beaky
//
//  Created by Todd Fearn on 3/18/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Utility.h"

@interface User : NSObject {
    NSString *_userId;
    PFFile *_imageFile;
    NSString *_imageUrl;
    UIImage *_image;
    NSString *_userName;
    NSString *_displayName;
    NSString *_bio;
    int _distance;
    NSString *_uuid;
}
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *bio;
@property int distance;
@property (nonatomic, strong) NSString *uuid;

- (void)assignValuesFromObject:(PFUser *)user;

@end

//
//  AppDelegate.h
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    BOOL locationDetermined;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

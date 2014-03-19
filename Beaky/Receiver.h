//
//  Receiver.h
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Globals.h"

@protocol ReceiverDelegate <NSObject>
-(void)beaconsFound:(NSArray *)uuids;
@end

@interface Receiver : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    NSMutableArray *_beaconRegions;
}
@property (assign) id<ReceiverDelegate> delegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *beaconRegions;

- (void)monitor:(NSString *)uuid;

@end

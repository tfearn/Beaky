//
//  Transmitter.h
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Utility.h"

@interface Transmitter : NSObject <CBPeripheralManagerDelegate> {
    CLBeaconRegion *_beaconRegion;
    NSDictionary *_beaconData;
    CBPeripheralManager *_peripheralManager;
}
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

- (void)start:(NSString *)guid;
- (void)stop;

@end

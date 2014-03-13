//
//  Transmitter.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "Transmitter.h"

@implementation Transmitter
@synthesize beaconRegion = _beaconRegion;
@synthesize beaconData = _beaconData;
@synthesize peripheralManager = _peripheralManager;

- (void)start:(NSString *)guid {
    // Create a NSUUID object
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:guid];
    
    // Initialize the Beacon Region
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:1 minor:1 identifier:@"com.idata.testregion"];
}

- (void)stop {
    
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // Bluetooth is on
        
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.beaconData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
    }
}

@end

//
//  Receiver.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "Receiver.h"

@implementation Receiver
@synthesize locationManager = _locationManager;
@synthesize beaconRegions = _beaconRegions;

- (id)init {
    if(self == [super init]) {
        _beaconRegions = [[NSMutableArray alloc] init];
        
        // Initialize location manager and set ourselves as the delegate
        _locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)monitor:(NSString *)uuid {
    
    // Are we already monitoring this UUID?
    BOOL found = NO;
    for(CLBeaconRegion *beaconRegion in self.beaconRegions) {
        NSString *uuidString = [[beaconRegion proximityUUID] UUIDString];
        if([uuidString isEqualToString:uuid]) {
            found = YES;
            break;
        }
    }
    
    if(! found) {
        NSUUID *realUUID = [[NSUUID alloc] initWithUUIDString:uuid];
        
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:realUUID identifier:@"com.idata.testregion"];
        
        // Tell location manager to start monitoring for the beacon region
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
        
        [self.beaconRegions addObject:beaconRegion];
    }
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region {
    // Beacon found!

    NSMutableArray *uuids = [[NSMutableArray alloc] init];
    for(CLBeacon *beacon in beacons) {
        [uuids addObject:beacon.proximityUUID.UUIDString];
    }

    if(self.delegate != nil)
        [self.delegate beaconsFound:uuids];
}

@end

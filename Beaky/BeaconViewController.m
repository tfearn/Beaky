//
//  BeaconViewController.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "BeaconViewController.h"

#define kTransceiverLabelOn     @"  Listening..."
#define kTransceiverLabelOff    @"Touch to listen"

@interface BeaconViewController ()

@end

@implementation BeaconViewController
@synthesize animatedView = _animatedView;
@synthesize statusLabel = _statusLabel;
@synthesize transmitter = _transmitter;
@synthesize receiver = _receiver;
@synthesize users = _users;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginComplete) name:kNotificationLoginComplete object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTransceiver) name:kNotificationMyLocationUpdated object:nil];
        
        _users = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    
    PFUser *currentUser = [PFUser currentUser];
    if(! currentUser) {
        StartupViewController *startupViewController = [[StartupViewController alloc] initWithNibName:@"StartupViewController" bundle:nil];
        [self.navigationController presentViewController:startupViewController animated:YES completion:nil];
    }
    
    [self initTransceiverView:self.view];
    tranceiverOn = YES;
    self.statusLabel.text = kTransceiverLabelOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)applicationWillEnterForeground {
    self.animatedView = nil;
    
    [self initTransceiverView:self.view];
}

- (void)loginComplete {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initTransceiverView:(UIView *)parentView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(112, 100, 100, 100)];
    view.backgroundColor = [UIColor greenColor];
    view.layer.cornerRadius = 50;
    
    [parentView addSubview:view];
    [parentView sendSubviewToBack:view];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.5;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.1];
    
    [view.layer addAnimation:scaleAnimation forKey:@"scale"];
    self.animatedView = view;
}

-(void)pauseAnimation {
    CALayer *layer = self.animatedView.layer;
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeAnimation {
    CALayer *layer = self.animatedView.layer;
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (IBAction)touchAnimatedButton:(id)sender {
    if(tranceiverOn)
        [self pauseAnimation];
    else
        [self resumeAnimation];
    tranceiverOn = !tranceiverOn;
    
    if(tranceiverOn)
        self.statusLabel.text = kTransceiverLabelOn;
    else
        self.statusLabel.text = kTransceiverLabelOff;
}

- (void)startTransceiver {
    
    // Startup the Transmitter to broadcast our location
    _transmitter = [[Transmitter alloc] init];
    PFUser *user = [PFUser currentUser];
    NSString *uuid = [user objectForKey:@"uuid"];
    [self.transmitter start:uuid];

    // Setup the Receiver
    _receiver = [[Receiver alloc] init];
    self.receiver.delegate = self;
    
    // Retrieve the User object
    PFQuery *query = [PFUser query];
    PFUser *userObject = (PFUser *)[query getObjectWithId:user.objectId];
    
    // Retrieve all of the UUIDs in my Geolocation
    PFGeoPoint *userGeoPoint = [userObject objectForKey:@"location"];
    query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"location" nearGeoPoint:userGeoPoint];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if(error == nil) {
            for(PFUser *user in users) {
                // Skip myself
                if([user.objectId isEqualToString:[PFUser currentUser].objectId])
                    continue;
                
                NSString *uuid = [user objectForKey:@"uuid"];
                
                [self.receiver monitor:uuid];
            }
        }
    }];
}

#pragma mark -
#pragma mark ReceiverDelegate Methods

- (void)beaconsFound:(NSArray *)uuids {
    
    if(processingBeacons)
        return;
    processingBeacons = YES;
    
    NSMutableArray *newBeacons = [[NSMutableArray alloc] init];
    for(NSString *uuid in uuids) {
        
        // Did we already find this beacon?
        BOOL found = NO;
        for(User *user in self.users) {
            if([user.uuid isEqualToString:uuid]) {
                found = YES;
                break;
            }
        }
        if(! found)
           [newBeacons addObject:uuid];
    }
    
    if([newBeacons count]) {
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"uuid" containedIn:newBeacons];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(error == nil) {
                for(id object in objects) {
                    User *user = [[User alloc] init];
                    [user assignValuesFromObject:object];
                    
                    [self.users addObject:user];
                }
                
                processingBeacons = NO;
            }
        }];
    }
}

@end

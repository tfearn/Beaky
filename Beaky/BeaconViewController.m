//
//  BeaconViewController.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "BeaconViewController.h"

#define kListeningLabelOn       @" Listening for beacons..."
#define kListeningLabelOff      @"Touch to Listen"

@interface BeaconViewController ()

@end

@implementation BeaconViewController
@synthesize animatedListeningView = _animatedListeningView;
@synthesize listeningLabel = _listeningLabel;
@synthesize resultsLabel = _resultsLabel;
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
    
    // Setup the animated view
    [self initAnimatedView:self.view];
    listeningOn = YES;
    transmittingOn = YES;
    self.listeningLabel.text = kListeningLabelOn;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector: @selector(getUUIDs) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)applicationWillEnterForeground {
    self.animatedListeningView = nil;
    
    [self initAnimatedView:self.view];
}

- (void)loginComplete {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initAnimatedView:(UIView *)parentView {

    // Setup the transmitting view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(112, 140, 100, 100)];
    view.backgroundColor = [UIColor greenColor];
    view.layer.cornerRadius = 50;
    
    [parentView addSubview:view];
    [parentView sendSubviewToBack:view];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.45;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    [view.layer addAnimation:scaleAnimation forKey:@"scale"];
    self.animatedListeningView = view;
}

-(void)pauseAnimation:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeAnimation:(CALayer *)layer {
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

- (IBAction)touchAnimatedListeningButton:(id)sender {
    if(transmittingOn)
        [self pauseAnimation:self.animatedListeningView.layer];
    else
        [self resumeAnimation:self.animatedListeningView.layer];
    transmittingOn = !transmittingOn;
    
    if(transmittingOn)
        self.listeningLabel.text = kListeningLabelOn;
    else
        self.listeningLabel.text = kListeningLabelOff;
}

- (IBAction)touchFoundButton:(id)sender {
    if([self.users count] > 0) {
        PeopleNearMeViewController *peopleNearMeViewController = [[PeopleNearMeViewController alloc] initWithNibName:@"PeopleNearMeViewController" bundle:nil];
        peopleNearMeViewController.users = self.users;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:peopleNearMeViewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
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
}

- (IBAction)getUUIDs {
    
    // Is the receiver inititalized?
    if(! self.receiver)
        return;
    
    // No re-entry
    if(retrievingUUIDs)
        return;
    retrievingUUIDs = YES;
    
    // Retrieve the User object
    PFQuery *query = [PFUser query];
    PFUser *userObject = (PFUser *)[query getObjectWithId:[PFUser currentUser].objectId];
    
    // Retrieve all of the UUIDs in my Geolocation
    PFGeoPoint *userGeoPoint = [userObject objectForKey:@"location"];
    query = [PFQuery queryWithClassName:@"_User"];
    if(userGeoPoint != nil)
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
        
        retrievingUUIDs = NO;
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
                
                if([self.users count] == 1)
                    self.resultsLabel.text = @"Found 1 person, touch here";
                else
                    self.resultsLabel.text = [NSString stringWithFormat:@"Found %lu people, touch here", (unsigned long)[self.users count]];
                
                processingBeacons = NO;
            }
        }];
    }
    else {
        processingBeacons = NO;
    }
}

@end

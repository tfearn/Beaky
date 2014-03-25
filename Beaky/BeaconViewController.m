//
//  BeaconViewController.m
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "BeaconViewController.h"

#define kListeningLabelOn       @"  Listening..."
#define kListeningLabelOff      @"Touch to listen"
#define kTransmittingLabelOn    @"  Transmitting..."
#define kTransmittingLabelOff   @"Touch to Transmit"

@interface BeaconViewController ()

@end

@implementation BeaconViewController
@synthesize animatedListeningView = _animatedListeningView;
@synthesize animatedTransmittingView = _animatedTransmittingView;
@synthesize listeningLabel = _listeningLabel;
@synthesize transmittingLabel = _transmittingLabel;
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
    
    [self initAnimatedViews:self.view];
    listeningOn = YES;
    transmittingOn = YES;
    self.listeningLabel.text = kListeningLabelOn;
    self.transmittingLabel.text = kTransmittingLabelOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)applicationWillEnterForeground {
    self.animatedListeningView = nil;
    self.animatedTransmittingView = nil;
    
    [self initAnimatedViews:self.view];
}

- (void)loginComplete {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initAnimatedViews:(UIView *)parentView {

    // Setup the listening view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(112, 30, 100, 100)];
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
    self.animatedListeningView = view;
    
    
    // Setup the transmitting view
    view = [[UIView alloc] initWithFrame:CGRectMake(112, 150, 100, 100)];
    view.backgroundColor = [UIColor blueColor];
    view.layer.cornerRadius = 50;
    
    [parentView addSubview:view];
    [parentView sendSubviewToBack:view];
    
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 0.45;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.1];
    
    [view.layer addAnimation:scaleAnimation forKey:@"scale"];
    self.animatedTransmittingView = view;
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
    if(listeningOn)
        [self pauseAnimation:self.animatedListeningView.layer];
    else
        [self resumeAnimation:self.animatedListeningView.layer];
    listeningOn = !listeningOn;
    
    if(listeningOn)
        self.listeningLabel.text = kListeningLabelOn;
    else
        self.listeningLabel.text = kListeningLabelOff;
}

- (IBAction)touchAnimatedTransmittingButton:(id)sender {
    if(transmittingOn)
        [self pauseAnimation:self.animatedTransmittingView.layer];
    else
        [self resumeAnimation:self.animatedTransmittingView.layer];
    transmittingOn = !transmittingOn;
    
    if(transmittingOn)
        self.transmittingLabel.text = kTransmittingLabelOn;
    else
        self.transmittingLabel.text = kTransmittingLabelOff;
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

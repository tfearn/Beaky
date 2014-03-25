//
//  BeaconViewController.h
//  Beaky
//
//  Created by Todd Fearn on 3/13/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "BaseViewController.h"
#import "StartupViewController.h"
#import "Transmitter.h"
#import "Receiver.h"
#import "User.h"

@interface BeaconViewController : BaseViewController <ReceiverDelegate> {
    UIView *_animatedListeningView;
    UIView *_animatedTransmittingView;
    IBOutlet UILabel *_listeningLabel;
    IBOutlet UILabel *_transmittingLabel;
    Transmitter *_transmitter;
    Receiver *_receiver;
    NSMutableArray *_users;
    
    BOOL listeningOn;
    BOOL transmittingOn;
    BOOL processingBeacons;
}
@property (strong, nonatomic) UIView *animatedListeningView;
@property (strong, nonatomic) UIView *animatedTransmittingView;
@property (strong, nonatomic) UILabel *listeningLabel;
@property (strong, nonatomic) UILabel *transmittingLabel;
@property (strong, nonatomic) Transmitter *transmitter;
@property (strong, nonatomic) Receiver *receiver;
@property (strong, nonatomic) NSMutableArray *users;

@end

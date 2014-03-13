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

@interface BeaconViewController : BaseViewController {
    UIView *_animatedView;
    IBOutlet UILabel *_statusLabel;
    IBOutlet UITableView *_tableView;
    Transmitter *_transmitter;
    Receiver *_receiver;
    
    BOOL tranceiverOn;
}
@property (strong, nonatomic) UIView *animatedView;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) Transmitter *transmitter;
@property (strong, nonatomic) Receiver *receiver;

@end

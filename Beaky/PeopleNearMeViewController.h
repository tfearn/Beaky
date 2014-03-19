//
//  PeopleNearMeViewController.h
//  Beaky
//
//  Created by Todd Fearn on 3/18/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PeopleViewCell.h"
#import "User.h"

@interface PeopleNearMeViewController : BaseViewController {
    IBOutlet UITableView *_tableView;
    NSMutableArray *_users;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *users;

@end

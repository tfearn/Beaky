//
//  PeopleViewCell.h
//  Beaky
//
//  Created by Todd Fearn on 3/18/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleViewCell : UITableViewCell {
    IBOutlet UIImageView *_userImageView;
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_distanceLabel;
    IBOutlet UILabel *_commentLabel;
}
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *commentLabel;


@end

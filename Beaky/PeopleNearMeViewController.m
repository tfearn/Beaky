//
//  PeopleNearMeViewController.m
//  Beaky
//
//  Created by Todd Fearn on 3/18/14.
//  Copyright (c) 2014 iData Corporation. All rights reserved.
//

#import "PeopleNearMeViewController.h"

@interface PeopleNearMeViewController ()

@end

@implementation PeopleNearMeViewController
@synthesize tableView = _tableView;
@synthesize users = _users;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

void PeopleImageFromURL( NSURL * URL, void (^imageBlock)(UIImage * image), void (^errorBlock)(void) )
{
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
        NSData * data = [[NSData alloc] initWithContentsOfURL:URL];
        UIImage * image = [[UIImage alloc] initWithData:data];
        dispatch_async( dispatch_get_main_queue(), ^(void){
            if( image != nil ) {
                imageBlock( image );
            } else {
                errorBlock();
            }
        });
    });
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableview {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CustomCellIdentifier = @"PeopleViewCellIdentifier";
	
	User *user = [self.users objectAtIndex:[indexPath row]];
    
    PeopleViewCell *cell = (PeopleViewCell *)[tableview dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell == nil)  {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PeopleViewCell" owner:self options:nil];
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[PeopleViewCell class]])
                cell = (PeopleViewCell *)oneObject;
    }
    
    cell.nameLabel.text = user.displayName;
    
    [cell.userImageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [cell.userImageView.layer setBorderWidth:1.0];
    if(user.imageUrl != nil) {
        if(user.image != nil) {
            cell.userImageView.image = user.image;
        }
        else {
            NSURL *url = [NSURL URLWithString:user.imageUrl];
            PeopleImageFromURL(url, ^(UIImage *image) {
                cell.userImageView.image = image;
                user.image = image;
            }, ^(void) {
                // do nothing on error
            });
        }
    }
    else {
        cell.userImageView.image = [UIImage imageNamed:@"default-user.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end

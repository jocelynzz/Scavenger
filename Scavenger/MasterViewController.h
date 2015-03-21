//
//  MasterViewController.h
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scavenger-Swift.h"

@interface MasterViewController : UITableViewController <MenuViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray *myNotes;
@property (strong, nonatomic) NSUserDefaults *standardUserDefaults;
@property (strong, nonatomic) UIImage *full;
@property (strong, nonatomic) UIImage *prev;
@end


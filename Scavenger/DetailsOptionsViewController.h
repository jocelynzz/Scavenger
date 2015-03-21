//
//  DetailsOptionsViewController.h
//  Scavenger
//
//  Created by Jocelyn on 3/15/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesDoc.h"

@interface DetailsOptionsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (strong, nonatomic) IBOutlet UISwitch *visibilityToggle;
@property (weak,nonatomic) NotesDoc *note;
@end

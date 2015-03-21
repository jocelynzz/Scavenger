//
//  DetailsOptionsViewController.m
//  Scavenger
//
//  Created by Jocelyn on 3/15/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "DetailsOptionsViewController.h"
#import "Social/Social.h"

@interface DetailsOptionsViewController ()

@end

@implementation DetailsOptionsViewController

- (void)awakeFromNib
{
    self.preferredContentSize = CGSizeMake(400.0, 100.0);
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_note.publicReadAccess) {
        [_visibilityToggle setOn:YES];
        _visibilityLabel.text = @"Note Visibility: Everyone";
    } else {
        [_visibilityToggle setOn:NO];
        _visibilityLabel.text = @"Note Visibility: Myself";
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];CGRect bounds = [self.tableView bounds];
    [self.tableView setBounds:CGRectMake(bounds.origin.x,
                                    bounds.origin.y,
                                    bounds.size.width,
                                    bounds.size.height/3)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)visibilityChanged:(id)sender {
    UISwitch *uiSwtich = sender;
    if ([uiSwtich isOn]) {
        [_note setPublicReadAccess:YES];
        _visibilityLabel.text = @"Note Visibility: Everyone";
    } else {
        [_note setPublicReadAccess:NO];
        _visibilityLabel.text = @"Note Visibility: Myself";
    }
}

- (IBAction)shareOnTwitter:(id)sender {
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    NSLog(@"tweet %@", _note.title);
    NSString *tweetContent = [NSString stringWithFormat:@"%@: %@ @scavenger", _note.title, _note.body];
    [tweetSheet setInitialText:tweetContent];
    [self presentViewController:tweetSheet animated:YES completion:nil];
}

@end

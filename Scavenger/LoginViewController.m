//
//  LoginViewController.m
//  Scavenger
//
//  Created by Jocelyn on 3/8/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (IBAction)login:(UIButton *)sender {
    NSLog(@"Login requested: username:%@ password:%@",
          _usernameTextField.text, _pwTextField.text);
    [PFUser logInWithUsernameInBackground:_usernameTextField.text
                                 password:_pwTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self performSegueWithIdentifier:@"showMainApp" sender:self];
                                        } else {
                                            NSLog(@"Failed to login. %@", [error userInfo]);
                                        }
                                    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    self.pwTextField.delegate = self;
    
    [Parse setApplicationId:@"QIsIQ3K5T2JF73NeL6vffhwBHQIe7x4ZJbbFSH20" clientKey:@"MOl3RBBDyHGZZ2mOiWJVBsWGJbEaJb0eoBUdJAiM"];
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    // Optionally enable public read access while disabling public write access.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


@end

//
//  MasterViewController.m
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NotesDoc.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface MasterViewController () {
    
__weak IBOutlet UIBarButtonItem *menu;

} @end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                    message:@"Failed To Fetch Notes"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (void)getNotes {
    /****download notes from backend*****/
    CGSize newSize = CGSizeMake(44,44);
    UIGraphicsBeginImageContext(newSize);
    [self.full drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *prev = UIGraphicsGetImageFromCurrentImageContext();
    prev =[UIImage imageNamed:@"cali.png"];
    UIGraphicsEndImageContext();
    
    PFQuery *query = [PFQuery queryWithClassName:@"Notes"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            [_myNotes removeAllObjects];
            for (NSInteger i = 0; i < [results count]; i++) {
                PFObject *obj = [results objectAtIndex:i];
                NotesDoc *doc = [[NotesDoc alloc] initWithTitle:obj[@"title"]
                                                        preview:self.prev
                                                       fullsize:[UIImage imageNamed:@"cali.png"]];
                if (obj[@"photo"] != nil) {
                    [obj[@"photo"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *fullsize = [UIImage imageWithData:data];
                            CGSize newSize = CGSizeMake(44,44);
                            UIGraphicsBeginImageContext(newSize);
                            [fullsize drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                            UIImage *preview = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            [doc setImages:preview fullsize:fullsize];
                            [self.tableView reloadData];
                        }
                    }];
                }
                [doc setBody:obj[@"body"]];
                [doc setObjectId:obj.objectId];
                [doc setLatitude:obj[@"latitude"]];
                [doc setLongitude:obj[@"longitude"]];
                [doc setCreatedAt:obj.createdAt];
                [doc setPublicReadAccess:[obj.ACL getPublicReadAccess]];
                [_myNotes addObject:doc];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"Error fetching notes");
            [self showAlert];
        }
        if (self.refreshControl) {
            [self.refreshControl endRefreshing];
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Loading notes");
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myNotes = [[NSMutableArray alloc] init];
    _standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [self getNotes];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //  refresh control
    UIRefreshControl *pullToRefresh = [[UIRefreshControl alloc] init];
    pullToRefresh.tintColor = [[UIColor alloc] initWithRed:255/255.f green:143/255.f blue:128/255.f alpha:1];
    [pullToRefresh addTarget:self action:@selector(refreshAction) forControlEvents: UIControlEventValueChanged];
    self.refreshControl = pullToRefresh;
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    [addButton setTintColor:[[UIColor alloc] initWithRed:255/255.f green:143/255.f blue:128/255.f alpha:1]];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.title = @"My Notes";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
   // self.tableView.backgroundColor = [UIColor purpleColor];
}




- (void)refreshAction {
    NSLog(@"Refreshing my notes.");
    [self getNotes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender {
    NotesDoc *note = [[NotesDoc alloc]
                      initWithTitle:[NSString stringWithFormat:@"New Note %ld", [_myNotes count] + 1]
                      preview:self.prev
                      fullsize:[UIImage imageNamed:@"cali.png"]];
    [note setBody:@""];
    [note setCreatedAt:[[NSDate alloc] init]];
    NSLog(@"%@", [_standardUserDefaults objectForKey:@"new_note_visible_to_everyone"]);
    NSNumber * visibility = [_standardUserDefaults objectForKey:@"new_note_visible_to_everyone"];
    if ([visibility intValue] == 1) {
        note.publicReadAccess = YES;
    }
    [_myNotes addObject:note];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:[_myNotes count] - 1 inSection:0]
                                animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

#pragma mark - Segues
-(void)didMoveToParentViewController:(UIViewController *)parent{
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NotesDoc *note = [_myNotes objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:note];
    } else if ([[segue identifier] isEqualToString:@"presentMenu"]) {
        MenuViewController *controller = [segue destinationViewController];
        [controller setDelegate:self];
    }
}

- (void)menu:(MenuViewController *)menuViewController didSelectItemAtIndex:(NSInteger)index atPoint:(CGPoint)point {
    if (index == 0) {
        [menuViewController dismissViewControllerAnimated:YES completion:nil];
    } else if (index == 1) {
        [menuViewController dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:@"showMapView" sender:self];
        }];
    }
}

- (void)menuDidCancel:(MenuViewController *)menuTarget {
    [menuTarget dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_myNotes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    NotesDoc *currentNote = [self.myNotes objectAtIndex:indexPath.row];
    cell.textLabel.text = currentNote.title;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[currentNote createdAt]];
    cell.detailTextLabel.text =dateString;
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 1.0f;
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width/2;
    cell.imageView.clipsToBounds = YES;
    
    cell.imageView.image = currentNote.preview;
    
    cell.clipsToBounds = YES;
    
//    CALayer* layer = cell.layer;
//    [layer setBounds:<#(CGRect)#>]
//    [layer setCornerRadius:8.0f];
//    [layer setMasksToBounds:YES];
//    [layer setBorderWidth:2.0f];
//    [layer setBorderColor:[[UIColor purpleColor] CGColor]];
  //   [UIColor colorWithHexString:@"#555555"];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NotesDoc *note = [_myNotes objectAtIndex:indexPath.row];
        if (note.objectId != nil) {
            PFObject *obj = [PFObject objectWithoutDataWithClassName:@"Notes"
                                                               objectId:note.objectId];
            [obj deleteEventually];
        }
        [_myNotes removeObject:note];
        [self.tableView reloadData];
    }
}

#pragma mark - Fetched results controller

@end

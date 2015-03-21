//
//  DetailViewController.m
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//
#import "DetailViewController.h"
#import "DetailsOptionsViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *noteText;
@property (weak, nonatomic) IBOutlet UITextField *noteTitle;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UILabel *myDate;


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NotesDoc*)item {
    item.delegate = self;
    if (_detailItem != item) {
        _detailItem = item;
        // Update the view.
        [self configureView];
    }
}

- (void)imageChanged:(UIImage *)preview fullsize:(UIImage *)fullsize {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userImage.image = fullsize;
    });
}

- (IBAction)addLocation:(id)sender {
    [[LocationManager getInstance] addLocationManagerDelegate:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }

    return YES;
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"EEE, MMM. dd, yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:[_detailItem createdAt]];
        self.myDate.text = dateString;
        
        self.userImage.image = self.detailItem.fullsize;

        
        //To make the border look very close to a UITextField
//        [self.noteBodyTextField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
//        [self.noteBodyTextField.layer setBorderWidth:2.0];
        
        //pecify the view's corner radius:
//        self.noteBodyTextField.layer.cornerRadius = 15;
//        self.noteBodyTextField.clipsToBounds = YES;
        
        self.noteTitle.textColor = [UIColor whiteColor];
        self.noteTitle.backgroundColor =[UIColor clearColor];
        
        self.myDate.alpha = 0.8;
        
        [self.navigationController.navigationBar setTintColor:[[UIColor alloc] initWithRed:255/255.f green:143/255.f blue:128/255.f alpha:1]];
        
        
        NSString *titleText = [self.detailItem title];
        self.titleTextField.text = titleText;
        self.noteBodyTextField.text = [self.detailItem body];
        if (_detailItem.longitude != nil && _detailItem.latitude != nil) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[_detailItem.latitude doubleValue]
                                                              longitude:[_detailItem.longitude doubleValue]];
            [self annotateMapWithNoteLocation:location];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleTextField.delegate = self;
    self.noteText.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)annotateMapWithNoteLocation:(CLLocation*)location {
    CLGeocoder *geocoder = [[LocationManager getInstance] geocoder];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            NSString *title = [NSString stringWithFormat:@"%@, %@, %@ %@",
                               placemark.name, placemark.thoroughfare,
                               placemark.locality,
                               placemark.administrativeArea];
            NSLog(@"Annotating small map with note location: %@", title);
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            [point setTitle:title];
            [point setCoordinate:location.coordinate];
            [_noteLocationMap addAnnotation:point];
        } else {
            NSLog(@"Unable to obtain placemark for location. %@", error.debugDescription);
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            [point setTitle:_detailItem.title];
            [point setCoordinate:location.coordinate];
            [_noteLocationMap addAnnotation:point];
        }
    } ];
}

- (void)locationUpdated:(CLLocation*)location {
    NSLog(@"location update: %@", location);
    _detailItem.latitude = [[NSNumber alloc] initWithDouble:location.coordinate.latitude];
    _detailItem.longitude = [[NSNumber alloc] initWithDouble:location.coordinate.longitude];
    [self annotateMapWithNoteLocation:location];
    [[LocationManager getInstance] removeLocationManagerDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_detailItem setTitle:_titleTextField.text];
    [_detailItem setBody:_noteBodyTextField.text];
    PFQuery *query = [PFQuery queryWithClassName:@"Notes"];
    if (_detailItem.objectId != nil) {
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:_detailItem.objectId block:^(PFObject *note, NSError *error) {
            [self fillInPFNote:note];
            [note saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    _detailItem.pendingFileUpload = NO;
                    [_detailItem setImages:_detailItem.preview fullsize:_detailItem.fullsize];
                }
            }];
        }];
    } else {
        PFObject *note = [PFObject objectWithClassName:@"Notes"];
        note[@"author"] = [PFUser currentUser];
        [self fillInPFNote:note];
        [note saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Able to create a new note, titled - %@!", _detailItem.title);
                _detailItem.objectId = note.objectId;
                _detailItem.createdAt = note.createdAt;
                [_detailItem setImages:_detailItem.preview fullsize:_detailItem.fullsize];
                _detailItem.pendingFileUpload = NO;
            } else {
                NSLog(@"Unable to create a new note %@", error);
            }
        }];
    }
}

-(void) fillInPFNote:(PFObject*)note {
    note[@"title"] = _detailItem.title;
    note[@"body"] = _detailItem.body;
    [note.ACL setPublicReadAccess:_detailItem.publicReadAccess];
    if (_detailItem.longitude != nil && _detailItem.latitude != nil) {
        note[@"latitude"] = _detailItem.latitude;
        note[@"longitude"] = _detailItem.longitude;
    }
    if (_detailItem.pendingFileUpload) {
        PFFile *file = [PFFile fileWithData:UIImagePNGRepresentation(_detailItem.fullsize)];
        note[@"photo"] = file;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showNoteSettings"]) {
        DetailsOptionsViewController *destNav = segue.destinationViewController;
        
        UIPopoverPresentationController *popPC = destNav.popoverPresentationController;
        popPC.delegate = self;
        [destNav setNote:_detailItem];
    }
}

-(UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (IBAction)imagePressed:(id)sender {
    if (self.imagePicker== nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.allowsEditing = NO;
    }
    [self presentViewController:_imagePicker animated:YES completion:nil];
    NSLog(@"imagePressed");
}

#pragma mark aDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *fullImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize newSize = CGSizeMake(44,44);
    UIGraphicsBeginImageContext(newSize);
    [fullImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *preview = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.userImage.layer.backgroundColor=[[UIColor clearColor] CGColor];

    [_detailItem setImages:preview fullsize:fullImage];
    [_detailItem setPendingFileUpload:YES];
}

@end

//
//  DetailViewController.h
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NotesDoc.h"
#import "LocationManager.h"

@interface DetailViewController : UIViewController<LocationManagerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, NoteImage, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NotesDoc *detailItem;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteBodyTextField;
@property (strong, nonatomic) IBOutlet MKMapView *noteLocationMap;
@property (retain, nonatomic) UIImagePickerController *imagePicker;
//- (IBAction)titleFieldChanged:(id)sender;
- (IBAction)imagePressed:(id)sender;

@end


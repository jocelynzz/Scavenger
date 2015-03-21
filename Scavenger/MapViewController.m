//
//  MapViewController.m
//  Scavenger
//
//  Created by Jocelyn on 3/14/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "MapViewController.h"
#import "LocationManager.h"
#import "MasterViewController.h"
#import <Parse/Parse.h>

@interface MapViewController ()
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mapLoadingIndicator;

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated {
    _mapView.delegate = self;
    [_mapLoadingIndicator startAnimating];
    PFQuery *query = [PFQuery queryWithClassName:@"Notes"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            for (NSInteger i = 0; i < [results count]; i++) {
                PFObject *note = [results objectAtIndex:i];
                if (note[@"longitude"] != nil && note[@"latitude"] != nil) {
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:[note[@"latitude"] doubleValue]
                                                                 longitude:[note[@"longitude"] doubleValue]];
                    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                    [point setTitle:note[@"title"]];
                    [point setCoordinate:location.coordinate];
                    [_mapView addAnnotation:point];
                }
            }
        } else {
            NSLog(@"Error fetching notes");
        }
    }];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView
                       fullyRendered:(BOOL)fullyRendered {
    if (fullyRendered) {
        [_mapLoadingIndicator stopAnimating];        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"presentMenu"]) {
        MenuViewController *controller = [segue destinationViewController];
        [controller setDelegate:self];
    }
}

- (void)menu:(MenuViewController *)menu didSelectItemAtIndex:(NSInteger)index atPoint:(CGPoint)point {
    if (index == 1) {
        [menu dismissViewControllerAnimated:YES completion:nil];
    } else if (index == 0) {
        [menu dismissViewControllerAnimated:YES completion:^(){
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (void)menuDidCancel:(MenuViewController *)menuTarget {
    [menuTarget dismissViewControllerAnimated:YES completion:nil];
}

@end

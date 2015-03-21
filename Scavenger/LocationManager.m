//
//  LocationManager.m
//  Scavenger
//
//  Created by Jocelyn on 3/13/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()
@property (strong, nonatomic) NSMutableArray *delgates;
@end

@implementation LocationManager
static int errorCount = 0;
#define MAX_LOCATION_ERROR 3

+ (id)getInstance
{
    static dispatch_once_t pred;
    static LocationManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init
{
    if ( self = [super init] ) {
        if (nil == _locationManager)
            _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = 1000; // meters
    }
    _delgates = [[NSMutableArray alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    return self;
}

- (void) addLocationManagerDelegate:(id<LocationManagerDelegate>)delegate {
    if (![_delgates containsObject:delegate]) {
        [_delgates addObject:delegate];
    }
    [_locationManager startUpdatingLocation];
}

- (void) removeLocationManagerDelegate:(id<LocationManagerDelegate>)delegate {
    if ([_delgates containsObject:delegate]) {
        [_delgates removeObject:delegate];
    }
    if ([_delgates count] == 0) {
        [_locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_locationManager stopUpdatingLocation];
    for(id<LocationManagerDelegate> del in _delgates) {
        if (del) {
            [del locationUpdated:[locations lastObject]];
        }
    }
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    errorCount += 1;
    if(errorCount >= MAX_LOCATION_ERROR) {
        [_locationManager stopUpdatingLocation];
        errorCount = 0;
    }
}

@end

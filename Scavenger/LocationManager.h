//
//  LocationManager.h
//  Scavenger
//
//  Created by Jocelyn on 3/13/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

- (void)locationUpdated:(CLLocation*)location;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>
+(id)getInstance;
-(void)addLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
-(void)removeLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

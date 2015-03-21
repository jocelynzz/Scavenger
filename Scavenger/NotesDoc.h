//
//  NotesDoc.h
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol NoteImage
- (void)imageChanged:(UIImage*)preview fullsize:(UIImage*)fullsize;
@end

@class NotesData;

@interface NotesDoc : NSObject

@property(strong) NSString *objectId;
@property(strong) NSString *title;
@property(strong) NSString *body;
@property(strong) NSDate *createdAt;
@property(strong) NSNumber *latitude;
@property(strong) NSNumber *longitude;
@property (strong) UIImage *preview;
@property (strong) UIImage *fullsize;
@property bool pendingFileUpload;
@property bool publicReadAccess;

@property (weak) id<NoteImage> delegate;

-(void) setImages:(UIImage*)preview fullsize:(UIImage*)fullsize;

-(id)initWithTitle: (NSString*)title preview:(UIImage *)preview fullsize:(UIImage *)fullsize;
@end

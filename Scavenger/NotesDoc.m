//
//  NotesDoc.m
//  Scavenger
//
//  Created by Jocelyn on 3/7/15.
//  Copyright (c) 2015 Jocelyn. All rights reserved.
//

#import "NotesDoc.h"

@implementation NotesDoc

- (id)initWithTitle:(NSString*)title preview:(UIImage *)preview fullsize:(UIImage *)fullsize{
    if ((self = [super init])) {
        self.title = title;
        self.preview = preview;
        self.fullsize = fullsize;
    }
    return self;
}

-(void) setImages:(UIImage*)preview fullsize:(UIImage*)fullsize {
    self.preview = preview;
    self.fullsize = fullsize;
    if (_delegate != nil) {
        [_delegate imageChanged:preview fullsize:fullsize];
    }
}

@end

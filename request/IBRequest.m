//
//  IBRequest.m
//
//
//  Created by Ilya Bukonkin on 4/23/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequest.h"

@implementation IBRequest

@synthesize params;
@synthesize context;
@synthesize result;
@synthesize delegate;

- (BOOL)canStart {
    return !(self.cancelled || self.executing || self.finished);
}

- (void)setIsExecuting:(BOOL)value {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    isFinished = !value;
    isExecuting = value;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)startWithContext:(id)_context {
    if(!self.canStart) return;
    
    OSSpinLockLock(&spinLock);
    
    if(!self.canStart) {
        OSSpinLockUnlock(&spinLock);
        return;
    }
    
    context = _context;
    
    [self setIsExecuting: YES];
    
    OSSpinLockUnlock(&spinLock);
    
    [self main];
    
    [self setIsExecuting: NO];
}

- (void)start {
    [self startWithContext: nil];
}


- (BOOL)isExecuting {
    return isExecuting;
}

- (BOOL)isFinished {
    return isFinished;
}

@end

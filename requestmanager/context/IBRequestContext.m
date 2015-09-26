//
//  IBRequestContext.m
//
//
//  Created by Ilya Bukonkin on 7/12/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequestContext.h"

@implementation IBRequestContext

@synthesize callingThread;
@synthesize receiver;

- (id)initWithCallingThread:(NSThread *)_callingThread
                andReceiver:(id <IBRequestManagerDelegate> )_receiver {
    self = [super init];
    
    callingThread = _callingThread;
    receiver = _receiver;
    
    return self;
}


- (BOOL)isEqual:(IBRequestContext *)object {
    if(self == object) return YES;
    
    if(![object isKindOfClass:[IBRequestContext class]])
        return NO;
    
    if ((callingThread == object->callingThread) &&
        (receiver == object->receiver))
        return YES;
    
    return NO;
}

@end


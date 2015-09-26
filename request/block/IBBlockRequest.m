//
//  IBBlockRequest.m
//
//
//  Created by Ilya Bukonkin on 4/27/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBBlockRequest.h"

@implementation IBBlockRequest


- (void)main {
    if(self.isCancelled) return;
    
    for (NSInteger index = 0; index < [ requests count]; index ++) {
        
        if(self.isCancelled) return;
        if(failed) break;
        
        currentRequest = [requests objectAtIndex:index];
        currentRequest.delegate = self;
        
        [currentRequest startWithContext: previousRequestResult];
    }
    
    if(failed) {
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        
        return;
    }
    
    if([delegate respondsToSelector:@selector(requestDidFinishExecution:)])
        [delegate requestDidFinishExecution:self];
    
}

- (void)cancel {
    [super cancel];
    [currentRequest cancel];
}


#pragma mark - IBRequestDelegate
- (void)requestDidFinishExecution:(IBRequest *)request {
    previousRequestResult = request.result;
}


- (void)requestDidFailToExecute:(IBRequest *)request {
    result = request.result;
    failed = YES;
}

@end

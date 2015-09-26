//
//  IBRequest.h
//
//
//  Created by Ilya Bukonkin on 4/23/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

@class IBRequest;

@protocol IBRequestDelegate <NSObject>
@optional
- (void)requestDidFinishExecution:(IBRequest *)request;
- (void)request:(IBRequest *)request reportsState:(id)state;
- (void)requestDidFailToExecute:(IBRequest *)request;
@end


@interface IBRequest : NSOperation {
@private
    BOOL                                isFinished;
    BOOL                                isExecuting;
    volatile OSSpinLock                 spinLock;
    id                                  context;
    
@protected
    NSArray                             *params;
    id                                  result;
    __weak id <IBRequestDelegate>       delegate;
}


@property (nonatomic, weak) id <IBRequestDelegate> delegate;
@property (nonatomic, readonly) NSArray *params;
@property (nonatomic, readonly) id result;
@property (nonatomic, readonly) id context;

- (void)startWithContext:(id)context;

@end

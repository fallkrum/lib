//
//  IBRequestManager.h
//
//
//  Created by Ilya Bukonkin on 6/3/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IBRequestToContextMap.h"
#import "IBRequest.h"

@class IBRequestManager;

@protocol IBRequestManagerDelegate <NSObject>
@optional
- (void)requestManager:(IBRequestManager *)requestManager
requestDidFinishExecution:(IBRequest *)request;

- (void)requestManager:(IBRequestManager *)requestManager
requestDidFailToExecute:(IBRequest *)request;

- (void)requestManager:(IBRequestManager *)requestManager
               request:(IBRequest *)request
          reportsState:(id)state;
@end


@interface IBRequestManager : NSObject <IBRequestDelegate> {
@private
    IBRequestToContextMap               *requestToContext;
    NSLock                              *lock;
}

@property (atomic, readonly) NSInteger requestCount;
@property (atomic, readonly) NSInteger receiverCount;

+ (IBRequestManager *)sharedInstance;

- (void)removeReceiver:(id <IBRequestManagerDelegate>) receiver;
- (void)addReceiver:(id <IBRequestManagerDelegate>) receiver
         forRequest:(IBRequest *)request;


- (void)performRequest:(IBRequest *)request
           forReceiver:(id <IBRequestManagerDelegate>)receiver
             inContext:(id)context;

@end

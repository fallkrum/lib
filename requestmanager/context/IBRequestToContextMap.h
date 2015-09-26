//
//  IBRequestContextManager.h
//
//
//  Created by Ilya Bukonkin on 7/12/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBRequest;
@class IBRequestContext;
@protocol IBRequestManagerDelegate;


@interface IBRequestToContextMap : NSObject {
@protected
    NSMutableArray                      *contexts;
    NSMutableArray                      *requests;
    NSInteger                           contextCount;
}

@property (nonatomic, readonly) NSInteger contextCount;
@property (nonatomic, readonly) NSInteger requestCount;

- (void)addContext:(IBRequestContext *)context
        forRequest:(IBRequest *)request;
- (void)removeRequest:(IBRequest *)request;
- (void)removeContext:(IBRequestContext *)context;
- (void)removeContextWithReceiver:(id <IBRequestManagerDelegate>)receiver
                       forRequest:(IBRequest *)request;
- (void)removeContextsWithReceiver:(id <IBRequestManagerDelegate>)receiver;
- (NSArray *)contextsForRequest:(IBRequest *)request;

@end

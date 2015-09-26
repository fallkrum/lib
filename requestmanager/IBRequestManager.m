//
//  IBRequestManager.m
//
//
//  Created by Ilya Bukonkin on 6/3/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequestManager.h"
#import "IBRequestContext.h"

static dispatch_queue_t request_queue;
static dispatch_queue_t context_queue;
static IBRequestManager *manager;

@implementation IBRequestManager

@synthesize receiverCount;
@synthesize requestCount;

+ (id)alloc {
    return [self sharedInstance];
}

+ (IBRequestManager *)sharedInstance {
    if(manager) return manager;
    
    static dispatch_once_t isInitialized = 0;
    dispatch_once(&isInitialized, ^{
        manager = [[super alloc] init];
        manager->requestToContext = [IBRequestToContextMap new];
        manager->lock = [NSLock new];
        
        request_queue =
        dispatch_queue_create("requestManager.request.queue",
                              DISPATCH_QUEUE_CONCURRENT);
        
        context_queue =
        dispatch_queue_create("requestManager.context.queue",
                              DISPATCH_QUEUE_SERIAL);
        
    });
    
    return manager;
}

- (void)removeReceiver:(id<IBRequestManagerDelegate>)receiver {
    dispatch_async(context_queue, ^{
        [lock lock];
        [requestToContext removeContextsWithReceiver:receiver];
        [lock unlock];
    });
}

- (void)addReceiver:(id<IBRequestManagerDelegate>)receiver
         forRequest:(IBRequest *)request {
    IBRequestContext * requestContext =
    [[IBRequestContext alloc] initWithCallingThread:[NSThread currentThread]
                                        andReceiver:receiver];
    
    dispatch_async(context_queue, ^{
        [lock lock];
        [requestToContext addContext:requestContext forRequest:request];
        [lock unlock];
    });
}

- (void)performRequest:(IBRequest *)request
           forReceiver:(id<IBRequestManagerDelegate>)receiver
             inContext:(id)context {
    
    request.delegate = self;
    
    IBRequestContext * requestContext =
    [[IBRequestContext alloc] initWithCallingThread:[NSThread currentThread]
                                        andReceiver:receiver];
    
    dispatch_async(request_queue, ^{
        [lock lock];
        [requestToContext addContext:requestContext forRequest:request];
        [lock unlock];
        
        [request startWithContext:context];
        
        [lock lock];
        [requestToContext removeRequest:request];
        [lock unlock];
    });
}


- (void)executeDelegateSelector:(SEL)selector withParams:(NSArray *) params {
    if(![params count]) return;
    IBRequest *request = [params firstObject];
    
    [lock lock];
    NSArray *contexts = [requestToContext contextsForRequest:request];
    [lock unlock];
    
    for (IBRequestContext *context in contexts) {
        if(![context.receiver respondsToSelector:selector])
            continue;
    
        __weak NSObject *receiver = context.receiver;
    
        NSMethodSignature *methodSignature =
        [receiver methodSignatureForSelector:selector];
    
        NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:methodSignature];
    
        invocation.target = context.receiver;
        invocation.selector = selector;
        [invocation setArgument:&manager atIndex:2];
    
        for (NSInteger i = 3; i < [params count] + 3; i ++) {
            NSObject *object = [params objectAtIndex:i - 3];
        
            if([object isKindOfClass:[NSValue class]]) {
                NSValue *value = (NSValue *)object;
            
                NSUInteger valueSize = 0;
                NSGetSizeAndAlignment(value.objCType, &valueSize, NULL);
            
                void *value_buffer = malloc(valueSize);
                [value getValue:value_buffer];
            
                [invocation setArgument:value_buffer atIndex:i ];
                free(value_buffer);
            
            } else
                [invocation setArgument:&object atIndex: i];
        }
        
        [invocation retainArguments];
        [invocation performSelector:@selector(invoke)
                           onThread:context.callingThread
                         withObject:nil
                      waitUntilDone:NO];
    }
}

- (void)requestDidFailToExecute:(IBRequest *)request {
    [self executeDelegateSelector:@selector(requestManager:requestDidFailToExecute:)
                       withParams:@[request]];
    
}

- (void)request:(IBRequest *)request reportsState:(id)state {
    SEL selector = @selector(requestManager:request:reportsState:);
    [self executeDelegateSelector:selector
                       withParams:@[request, state]];
}

- (void)requestDidFinishExecution:(IBRequest *)request {
    [self executeDelegateSelector:@selector(requestManager:requestDidFinishExecution:)
                       withParams:@[request]];
    
}

- (NSInteger)requestCount {
    [lock lock];
    NSInteger count = requestToContext.contextCount;
    [lock unlock];
    
    return count;
}

- (NSInteger)receiverCount {
    [lock lock];
    NSInteger count = requestToContext.requestCount;
    [lock unlock];
    
    return count;
}

@end

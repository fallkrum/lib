//
//  IBRequestContextManager.m
//
//
//  Created by Ilya Bukonkin on 7/12/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequestToContextMap.h"
#import "IBRequestContext.h"

@implementation IBRequestToContextMap

@synthesize contextCount;

- (id)init {
    self = [super init];
    
    contexts = [NSMutableArray new];
    requests = [NSMutableArray new];
    
    return self;
}


- (void)removeContextsWithReceiver:(id<IBRequestManagerDelegate>)receiver
                      fromContexts:(NSMutableArray *)_contexts {
    NSInteger index = 0;
    
    while (index < [_contexts count]){
        IBRequestContext *contextToRemove = [_contexts objectAtIndex:index];
        
        if(contextToRemove.receiver != receiver)
            continue;
        
        [_contexts removeObject:contextToRemove];
       
        contextCount --;
        index ++;
        
        break;
    }
}

- (void)removeContextsEqualToContext:(IBRequestContext *)context
                        fromContexts:(NSMutableArray *)_contexts {
    NSInteger index = 0;
    
    while (index < [_contexts count]){
        IBRequestContext *contextToRemove = [_contexts objectAtIndex:index];
        
        if(![contextToRemove isEqual:context])
            continue;
        
        [_contexts removeObject:contextToRemove];
        
        contextCount --;
        index ++;
        
        break;
    }
}

- (void)addContext:(IBRequestContext *)context forRequest:(IBRequest *)request {
   
    NSMutableArray *requestContexts = [NSMutableArray new];
    NSInteger index = [requests indexOfObject:request];
    
    if(index == NSNotFound) {
        [requests addObject:request];
        [contexts addObject:requestContexts];
    } else  requestContexts = [contexts objectAtIndex:index];
    
    for (IBRequestContext *requestContext in requestContexts)
        if([requestContext isEqual:context]) return;
    
    [requestContexts addObject:context];
    
    contextCount ++;
}

- (void)removeRequest:(IBRequest *)request {
    NSInteger index = [requests indexOfObject:request];
    if(index == NSNotFound) return;
    
    [requests removeObject:request];
    [contexts removeObjectAtIndex:index];
}

- (void)removeContext:(IBRequestContext *)context {
    for (NSMutableArray *requestContexts in contexts)
        [self removeContextsEqualToContext:context
                              fromContexts:requestContexts];
}


- (void)removeContextWithReceiver:(id <IBRequestManagerDelegate>)receiver
                       forRequest:(IBRequest *)request {
    NSInteger index = [requests indexOfObject:request];
    if(index == NSNotFound) return;
    
    NSMutableArray *requestContexts = [contexts objectAtIndex:index];
    [self removeContextsWithReceiver:receiver
                        fromContexts:requestContexts];
}

- (void)removeContextsWithReceiver:(id<IBRequestManagerDelegate>)receiver {
    for (NSMutableArray *requestContexts in contexts)
        [self removeContextsWithReceiver:receiver
                            fromContexts:requestContexts];
}

- (NSArray *)contextsForRequest:(IBRequest *)request {
    NSInteger index = [requests indexOfObject:request];
    if(index == NSNotFound) return nil;
    
    return [[contexts objectAtIndex:index] copy];
}

- (NSInteger)requestCount {
    return [requests count];
}

@end

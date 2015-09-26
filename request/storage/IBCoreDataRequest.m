//
//  IBCoreDataRequest.m
//
//
//  Created by Ilya Bukonkin on 4/27/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBCoreDataRequest.h"


NSString * const IBCoreDataRequestErrorDomain = @"IBCoreDataRequestErrorDomain";
NSInteger const IBCoreDataRequestNoEntityName = 0;
NSInteger const IBCoreDataRequestNoNSFetchRequest = 1;


@implementation IBCoreDataRequest

- (id)init {
    self = [super init];
    
    batchSize = 20;
    sortDescriptors = @[];
    
    return self;
}


- (void)setErrorWithErrorCode:(NSInteger)code andUserInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError errorWithDomain:IBCoreDataRequestErrorDomain
                                         code:code
                                     userInfo:userInfo];
    result = error;
}

- (void)setNoEntityName {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"No Entity name provided."};
    
    [self setErrorWithErrorCode:IBCoreDataRequestNoEntityName
                    andUserInfo:userInfo];
}

- (void)setUnableCreateNSFetchRequest {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Unable to create NSFetchRequest."};
    
    [self setErrorWithErrorCode:IBCoreDataRequestNoNSFetchRequest
                    andUserInfo:userInfo];
}



- (NSFetchRequest *)requestForManagedObjectContext:(NSManagedObjectContext *)_context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
 
    NSEntityDescription *entityDescription =
    [NSEntityDescription entityForName:entityName inManagedObjectContext:_context];
    

    [request setEntity:entityDescription];
    [request setPredicate: predicate];
    [request setSortDescriptors:sortDescriptors];
    [request setFetchBatchSize:batchSize];
    
    return request;
}

- (void)main {
    if(self.isCancelled) return;
    
    if(!entityName) {
        [self setNoEntityName];
        
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        
        return;
    }

    NSFetchRequest *request = [self requestForManagedObjectContext:self.context];
    
    if(!request) {
        [self setUnableCreateNSFetchRequest];
        
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        
        return;
    }
    
    NSError *requestError = nil;
    result = [self.context executeFetchRequest:request error:&requestError];
    
    if(self.isCancelled) return;
    
    if(requestError) {
        result = requestError;
        
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        
        return;
    }
    
    if([delegate respondsToSelector:@selector(requestDidFinishExecution:)])
        [delegate requestDidFinishExecution:self];

}

@end

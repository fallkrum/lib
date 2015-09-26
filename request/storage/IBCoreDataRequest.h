//
//  IBCoreDataRequest.h
//
//
//  Created by Ilya Bukonkin on 4/27/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "IBRequest.h"

extern NSString * const IBCoreDataRequestErrorDomain;
extern NSInteger const IBCoreDataRequestNoEntityName;
extern NSInteger const IBCoreDataRequestNoNSFetchRequest;


 
@interface IBCoreDataRequest : IBRequest {
@protected
    NSString                        *entityName;
    NSPredicate                     *predicate;
    NSArray                         *sortDescriptors;
    NSInteger                       batchSize;
    __weak NSManagedObjectContext   *parentContext;
}

- (NSFetchRequest *)requestForManagedObjectContext:(NSManagedObjectContext *)context;

@end

//
//  IBRequestContext.h
//
//
//  Created by Ilya Bukonkin on 7/12/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IBRequestManagerDelegate;

@interface IBRequestContext : NSObject {
@private
    __weak  NSThread                        *callingThread;
    __weak  id <IBRequestManagerDelegate>   receiver;
}

@property (nonatomic, readonly, weak) NSThread *callingThread;
@property (nonatomic, readonly, weak) id <IBRequestManagerDelegate> receiver;

- (id)initWithCallingThread:(NSThread *)callingThread
                andReceiver:(id <IBRequestManagerDelegate> )receiver;

@end

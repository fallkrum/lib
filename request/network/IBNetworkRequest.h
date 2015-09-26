//
//  IBNetworkRequest.h
//
//
//  Created by Ilya Bukonkin on 4/24/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequest.h"
#import "IBBuffer.h"

extern NSString * const IBNetworkRequestErrorDomain;
extern NSInteger const IBNetworkRequestNoNSURLRequest;
extern NSInteger const IBNetworkRequestNoNSURLConnection;



@interface IBNetworkRequestState : NSObject {
@protected
    float                           connectionSpeed;
    float                           percentOfWorkDone;
    float                           timeToFinish;
}


- (id)initWithConnectionSpeed:(float)speed
            percentOfWorkDone:(float)percent
                 timeToFinish:(float)time;

@property (nonatomic, readonly) float connectionSpeed;
@property (nonatomic, readonly) float percentOfWorkDone;
@property (nonatomic, readonly) float timeToFinish;

@end



@interface IBNetworkRequest : IBRequest
<NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
@private
    NSURLConnection                 *connection;
    BOOL                            isCompleted;
    long long                       resourceSize;
    NSString                        *resourceName;
    NSDictionary                    *resourceHeaders;
    time_t                          startTime;
    float                           connectionSpeed;
    float                           downloadTime;
    
@protected
    NSArray                         *trustedHosts;
    NSURLCredential                 *credentials;
    NSURLRequest                    *request;
    IBBuffer                        *buffer;
}

+ (IBNetworkRequest *)requestWithBuffer:(IBBuffer *)buffer;

@property (nonatomic, readonly) long long resourceSize;
@property (nonatomic, readonly) NSString *resourceName;
@property (nonatomic, readonly) NSDictionary *resourceHeaders;

@end


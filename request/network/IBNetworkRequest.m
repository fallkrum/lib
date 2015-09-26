//
//  IBNetworkRequest.m
//
//
//  Created by Ilya Bukonkin on 4/24/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBNetworkRequest.h"
#import "IBMemoryBuffer.h"


NSString * const IBNetworkRequestErrorDomain = @"IBNetworkRequestErrorDomain";
NSInteger const IBNetworkRequestNoNSURLRequest = 0;
NSInteger const IBNetworkRequestNoNSURLConnection = 1;


@implementation IBNetworkRequestState

@synthesize timeToFinish;
@synthesize connectionSpeed;
@synthesize percentOfWorkDone;

- (id)initWithConnectionSpeed:(float)speed
            percentOfWorkDone:(float)percent
                 timeToFinish:(float)time {
    self = [self init];
    
    connectionSpeed = speed;
    percentOfWorkDone = percent;
    timeToFinish = time;
    
    return self;
}

@end




@implementation IBNetworkRequest

@synthesize resourceHeaders;
@synthesize resourceName;
@synthesize resourceSize;

+ (IBNetworkRequest *)requestWithBuffer:(IBBuffer *)buffer {
    IBNetworkRequest *request = [[self alloc] init];
    request->buffer = buffer;
    
    return request;
}

- (void)setErrorWithErrorCode:(NSInteger)code andUserInfo:(NSDictionary *)userInfo {
    NSError *error = [NSError errorWithDomain:IBNetworkRequestErrorDomain
                                         code:code
                                     userInfo:userInfo];
    result = error;
}

- (void)setNoNSURLRequestError {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"No NSURLRequest provided."};
    
    [self setErrorWithErrorCode:IBNetworkRequestNoNSURLRequest
                    andUserInfo:userInfo];
}

- (void)setUnableCreateNSURLConnection {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Unable to create NSURLConnection."};
    
    [self setErrorWithErrorCode:IBNetworkRequestNoNSURLConnection
                    andUserInfo:userInfo];
}

- (id)init {
    self = [super init];

    buffer = [IBMemoryBuffer new];
    
    return self;
}

- (void)main {
    if(self.isCancelled) return;
    
    if(!request) {
        [self setNoNSURLRequestError];
        
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        return;
    }
    
    connection =
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    if(!connection) {
        [self setUnableCreateNSURLConnection];
       
        if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
            [delegate requestDidFailToExecute:self];
        return;
    }
    
    [connection start];
    
    BOOL status = YES;
  
    do {
        status = [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                                          beforeDate:[NSDate distantFuture]];
    
    }while (status && (!isCompleted && !self.isCancelled));
    
    [connection cancel];
}


- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    NSString *host = challenge.protectionSpace.host;
    NSString *authMethod = challenge.protectionSpace.authenticationMethod;
    SecTrustRef trustRef = challenge.protectionSpace.serverTrust;
    
    if(credentials) {
        [challenge.sender useCredential:credentials forAuthenticationChallenge:challenge];
        return;
    }
    
    if([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([trustedHosts containsObject:host]) {
            NSURLCredential *credentilas =
            [NSURLCredential credentialForTrust:trustRef];
            
            [challenge.sender useCredential:credentilas
                 forAuthenticationChallenge:challenge];
            
            return;
        }
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    resourceName = [httpResponse suggestedFilename];
    resourceSize = [httpResponse expectedContentLength];
    resourceHeaders = [httpResponse allHeaderFields];
    
    startTime = time(NULL);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [buffer write:data];
    
    time_t receiveTime = time(NULL);
    
    
    if(receiveTime - startTime) {
        connectionSpeed = (float)buffer.offset / (receiveTime - startTime);
        downloadTime = (resourceSize - buffer.offset) / connectionSpeed;
    }
    
    float percentDone = (buffer.offset * 100) / resourceSize;
    
    IBNetworkRequestState *state =
    [[IBNetworkRequestState alloc] initWithConnectionSpeed:connectionSpeed
                                         percentOfWorkDone:percentDone
                                              timeToFinish:downloadTime];
    
    if([delegate respondsToSelector:@selector(request:reportsState:)])
        [delegate request:self reportsState:state];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    result = buffer;
    
    isCompleted = YES;
    
    if([delegate respondsToSelector:@selector(requestDidFinishExecution:)])
        [delegate requestDidFinishExecution:self];
        
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    result = error;
    
    isCompleted = YES;
    
    if([delegate respondsToSelector:@selector(requestDidFailToExecute:)])
        [delegate requestDidFailToExecute:self];
}

@end

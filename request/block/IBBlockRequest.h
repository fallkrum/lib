//
//  IBBlockRequest.h
//
//
//  Created by Ilya Bukonkin on 4/27/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBRequest.h"

@interface IBBlockRequest : IBRequest  <IBRequestDelegate> {
@private
    IBRequest               *currentRequest;
    id                      previousRequestResult;
    
@protected
    BOOL                    failed;
    NSArray                 *requests;
}

@end

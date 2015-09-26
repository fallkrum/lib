//
//  IBMemoryStream.h
//
//
//  Created by Ilya Bukonkin on 6/6/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBBuffer.h"

@interface IBMemoryBuffer : IBBuffer {
@protected
    id                      data;
    NSLock                  *lock;
    long long               offset;
}

- (id)initWithBuffer:(id)buffer;

@end

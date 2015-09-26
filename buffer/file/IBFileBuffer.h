//
//  IBFileBuffer.h
//
//
//  Created by Ilya Bukonkin on 7/13/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBBuffer.h"

enum IBFileBufferDirection {
    IBFileBufferDirectionRead,
    IBFileBufferDirectionWrite,
    IBFileBufferDirectionReadWrite
};


@interface IBFileBuffer : IBBuffer {
@private
    NSFileHandle                    *fileHandle;
    NSString                        *path;
    enum IBFileBufferDirection      direction;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, readonly) enum IBFileBufferDirection direction;

- (id)initWithFilePath:(NSString *)path
    andBufferDirection:(enum IBFileBufferDirection) direction;
- (id)initWithFilePath:(NSString *)path;

@end

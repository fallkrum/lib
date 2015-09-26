//
//  IBFileBuffer.m
//
//
//  Created by Ilya Bukonkin on 7/13/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBFileBuffer.h"
#include <fcntl.h>

@implementation IBFileBuffer

@synthesize path;
@synthesize direction;

- (id)initWithFilePath:(NSString *)_path {
    self = [self initWithFilePath:_path
               andBufferDirection:IBFileBufferDirectionReadWrite];
    
    return self;
}

- (id)initWithFilePath:(NSString *)_path
    andBufferDirection:(enum IBFileBufferDirection)_direction {
    self = [super init];
    
    direction = _direction;
    path = [_path copy];
    
    int openingFlag = O_CREAT;
    
    switch (direction) {
        case IBFileBufferDirectionRead: openingFlag |= O_RDONLY; break;
        case IBFileBufferDirectionWrite: openingFlag |= O_WRONLY; break;
            
        default: openingFlag |= O_RDWR;
    }
    
    int handle =
    open([path cStringUsingEncoding:NSUTF8StringEncoding], openingFlag);
    if(!handle) return nil;
    
    fileHandle =
    [[NSFileHandle alloc] initWithFileDescriptor:handle closeOnDealloc:YES];
    if(!fileHandle) return nil;
    
    return self;
}

- (id)read:(NSInteger)size {
    return [fileHandle readDataOfLength:size];
}

- (void)write:(id)data {
    [fileHandle writeData:data];
}

- (long long)offset {
    return fileHandle.offsetInFile;
}

- (void)setOffset:(long long)offset {
    [fileHandle seekToFileOffset:offset];
}

- (NSInputStream *)inputStream {
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
    
    return inputStream;
}


@end

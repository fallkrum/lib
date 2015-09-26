//
//  IBMemoryStream.m
//
//
//  Created by Ilya Bukonkin on 6/6/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import "IBMemoryBuffer.h"

@implementation IBMemoryBuffer

- (id)init {
    self = [super init];
    
    data = [NSMutableData new];
    lock = [NSLock new];
    
    return self;
}

- (id)initWithBuffer:(id)buffer {
    self = [super init];
    
    data = buffer;
    lock = [NSLock new];
    
    return self;
}

- (long long)size {
    return [data length];
}

- (long long)offset {
    return offset;
}

- (void)setOffset:(long long)_offset {
    [lock lock];
    
    if(_offset > [data length]) _offset = [data length];
    
    offset = _offset;
    
    [lock unlock];
}

- (id)read:(NSInteger)size {
    [lock lock];
    
    NSInteger bytesToRead = size;
    
    NSInteger bytesLeft = [data length] - offset;
    if(bytesLeft < bytesToRead) bytesToRead = bytesLeft;
    
    id subData =
    [data subdataWithRange: NSMakeRange(offset, bytesToRead)];
    
    offset += [subData length];
    
    [lock unlock];
    
    return subData;
}

- (id)readAllData {
    return [self read:[data length]];
}

- (id)buffer {
    return data;
}

- (void)write:(id)_data {
    [lock lock];
    
    NSInteger rangeSize = [data length] - offset;
    if([_data length] < rangeSize) rangeSize = [_data length];
    
    NSRange range = NSMakeRange(offset, rangeSize);
    
    [data replaceBytesInRange:range
                    withBytes:[_data bytes]
                       length:[_data length]];
    
    offset += [_data length];
    
    [lock unlock];
}

- (NSInputStream *)inputStream {
    [lock lock];
    
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    
    [lock unlock];
    
    return stream;
}


@end

//
//  IBStream.h
//
//
//  Created by Ilya Bukonkin on 6/5/15.
//  Copyright (c) 2015 Ilya Bukonkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IBBuffer : NSObject {

}

@property (atomic, readwrite) long long offset;
@property (nonatomic, readonly) long long size;
@property (nonatomic, readonly) id buffer;
@property (nonatomic, readonly) NSInputStream *inputStream;


- (void)write:(id)data;
- (id)read:(NSInteger)size;
- (id)readAllData;

@end

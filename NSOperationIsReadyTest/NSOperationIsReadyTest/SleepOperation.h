//
//  SleepOperation.h
//  NSOperationIsReadyTest
//
//  Created by Damian Stewart on 24.04.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepOperation : NSOperation

@property (assign,atomic,readwrite) BOOL shouldRun; // defaults to NO

/// @abstract block that is called once this operation has slept
@property (atomic,copy,readwrite) void (^sleptBlock)();


- (id)initWithSleepTime:(float)sleepTime;

@end

//
//  SleepOperation.m
//  NSOperationIsReadyTest
//
//  Created by Damian Stewart on 24.04.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import "SleepOperation.h"

@interface SleepOperation()
@property (assign,atomic,readwrite) float sleepTime;
@property (assign,atomic,readwrite) int uuid;
@end

@implementation SleepOperation

- (id)initWithSleepTime:(float)sleepTime
{
	self = [super init];
	if ( self )
	{
		static int uuidCounter = 0;
		self.uuid = uuidCounter++;
		self.shouldRun = NO;
		self.sleepTime = sleepTime;
	}
	return self;
}

- (BOOL)isReady
{
	NSLog(@"op %i was queried for ready status; super ready status is %@, cancelled %@", self.uuid, [super isReady]?@"YES":@"NO", [self isCancelled]?@"YES":@"NO");
	return self.shouldRun;
}

- (void)main
{
	NSLog(@"op %i main begun", self.uuid );
	/*if ( self.isCancelled )
	{
		NSLog(@"op %i was cancelled", self.uuid );
	}
	else*/
	{
		float delayInSeconds = self.sleepTime;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if ( self.sleptBlock )
			{
				NSLog(@"op %i about to call sleptBlock", self.uuid );
				self.sleptBlock();
			}
		});
	}
	
	NSLog(@"op %i main finished", self.uuid );
	
}



@end

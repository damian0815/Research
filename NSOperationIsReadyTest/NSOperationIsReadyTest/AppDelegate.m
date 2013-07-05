//
//  AppDelegate.m
//  NSOperationIsReadyTest
//
//  Created by Damian Stewart on 24.04.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import "AppDelegate.h"
#import "SleepOperation.h"

@interface AppDelegate()

@property (strong,readwrite,atomic) NSOperationQueue* opQueue;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	// make serial queue
	self.opQueue = [[NSOperationQueue alloc] init];
	self.opQueue.maxConcurrentOperationCount = 1;
	
	float sleepTimes[5] = { 3.0f,2.0f,5.0f,1.0f,4.0f };
	SleepOperation* prevSleepOp = nil;
	for ( int i=0; i<5; i++ )
	{
		SleepOperation* sleepOp = [[SleepOperation alloc] initWithSleepTime:sleepTimes[i]];
		if ( i==0 )
		{
			sleepOp.shouldRun = YES;
			[self.opQueue addOperation:sleepOp];
		}
		else
		{
			prevSleepOp.sleptBlock = ^(){
				sleepOp.shouldRun = YES;
				NSLog(@"   sleptBlock: adding operation %i, opQueue is %@", i, self.opQueue.isSuspended?@"suspended":@"running");
				[self.opQueue addOperation:sleepOp];
			};
		}
		
		if ( i==3 )
		{
			[sleepOp cancel];
		}
		
		prevSleepOp = sleepOp;
	}
}

@end

 
 /*
     File: SimpleTableViewAppDelegate.m
 Abstract: Application delegate that sets up the navigation controller and the root view controller.
 
  Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "SimpleTableViewAppDelegate.h"
#import "RootViewController.h"

#import "NEIndexSetCoalescer.h"

@implementation SimpleTableViewAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
		
	/*
	 Create and configure the navigation and view controllers.
     */	
	
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	// Retrieve the array of known time zone names, then sort the array and pass it to the root view controller.
	rootViewController.source = @[@"A", @"B", @"C"];
		
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	[aNavigationController release];
	[rootViewController release];
	
	// Configure and display the window.
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	NSIndexPath* (^makeIP)(int idx) = ^(int idx) {
		return [NSIndexPath indexPathForItem:idx inSection:0];
	};
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		rootViewController.source = @[@"C", @"D", @"A"];
		[rootViewController setVisibleBlack];
		rootViewController.source = @[@"C", @"D", @"A"];
		
		
		NEIndexSetCoalescer* coalescer = [[NEIndexSetCoalescer alloc] init];
		NSIndexSet* adds = [NSIndexSet indexSetWithIndex:1];
		NSIndexSet* removes = [NSIndexSet indexSetWithIndex:1];
		[coalescer coalesceAdds:nil removes:removes];
		[coalescer coalesceAdds:adds removes:nil];
		NSLog(@"Expected: %@", coalescer);
		
		
		// works
		// move outside block
		[rootViewController.tableView moveRowAtIndexPath:makeIP(0) toIndexPath:makeIP(2)];
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(0)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];
		
		 /*
		// works
		// move inside block
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView moveRowAtIndexPath:makeIP(0) toIndexPath:makeIP(2)];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];*/
		
		/*
		// works
		// move outside block
		[rootViewController.tableView moveRowAtIndexPath:makeIP(2) toIndexPath:makeIP(0)];
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(2)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];
		 
		// works
		// all inside block
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView moveRowAtIndexPath:makeIP(2) toIndexPath:makeIP(0)];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];
		 */
		
		/*
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];
		[rootViewController.tableView moveRowAtIndexPath:makeIP(0) toIndexPath:makeIP(2)];*/
	});
}



- (void)dealloc {
	[navigationController release];
    [window release];
    [super dealloc];
}


@end

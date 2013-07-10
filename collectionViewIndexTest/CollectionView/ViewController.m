/*
     File: ViewController.m
 Abstract: The primary view controller for this app.
 
  Version: 1.0
 
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
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "ViewController.h"
#import "DetailViewController.h"
#import "Cell.h"
#import "NEIndexSetCoalescer.h"
#import "Header.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *kCellID = @"cellID";                          // UICollectionViewCell storyboard id
NSString *kHeaderID = @"headerID";

@interface ViewController()

@property (assign,readwrite,atomic) int numberOfRuns;
@property (assign,readwrite,atomic) int failCount;
@property (assign,readwrite,atomic) int passCount;

@end

@implementation ViewController

NSIndexPath* makeIP(int idx)
{
	return [NSIndexPath indexPathForItem:idx inSection:0];
}

NSIndexSet* makeIS(int idx)
{
	return [NSIndexSet indexSetWithIndex:idx];
}

- (NSArray*)initialArrayContents
{
	return @[@"A", @"B", @"C", @"D"];
}

- (NSString*)stringFromArray:(NSArray*)array
{
	NSString* labelString = @"";
	for ( NSString* str in array )
	{
		labelString = [labelString stringByAppendingFormat:@"%2s ", [str UTF8String] ];
	}
	return labelString;
}

- (void)updateLabel
{
	NSString* labelString = [self stringFromArray:self.titles];
	[self.headerLabel setText:labelString];
}

- (NSArray*)visibleCellTitles
{
	NSArray* visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
	NSArray* visibleCells = [self.collectionView visibleCells];
	NSMutableArray* cellTitles = [NSMutableArray array];
	
	int prevIndexPathIndex = -1;
	int firstIndex = -1;
	for ( unsigned int i=0; i<[visibleCells count]; i++ )
	{
		// find the next index in visibleIndexPaths
		
		// visibleIndexPaths is not sorted, nor is visible cells, aargh
		unsigned int bestArrayIndex = NSNotFound;
		int bestIndexPathIndex = NSNotFound;
		for ( unsigned int j=0; j<[visibleCells count]; j++ )
		{
			NSIndexPath* indexPath = [visibleIndexPaths objectAtIndex:j];
			int indexPathIndex = indexPath.item;
			if ( indexPathIndex>prevIndexPathIndex && indexPathIndex<(int)bestIndexPathIndex )
			{
				bestIndexPathIndex = (int)indexPathIndex;
				bestArrayIndex = j;
			}
		}
		prevIndexPathIndex = bestIndexPathIndex;
		
		if ( firstIndex==-1 )
			firstIndex = bestIndexPathIndex;
		
		NSIndexPath* indexPath = [visibleIndexPaths objectAtIndex:bestArrayIndex];
		Cell* cell = [visibleCells objectAtIndex:bestArrayIndex];
		
		NSString* title = cell.label.text;
		[cellTitles addObject:title];
	}
	
	// insert dummies
	if ( firstIndex>0 )
	{
		NSMutableArray* dummies = [NSMutableArray array];;
		for ( int i=0; i<firstIndex; i++ )
		{
			[dummies addObject:@"_"];
			
		}
		NSIndexSet* dummyIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0,firstIndex)];
		[cellTitles insertObjects:dummies atIndexes:dummyIndexes];
	}
	
	return cellTitles;
	
}

- (void)doRandomIndexSetCoalescerTest:(int)runIndex
{

	NSMutableArray* titles = [self.titles mutableCopy];
	
	NEIndexSetCoalescer* coalescer = [[NEIndexSetCoalescer alloc] init];
	int moveFrom = rand()%self.titles.count;
	int moveTo = rand()%self.titles.count;
	NSString* itemToMove = nil;
	if ( moveFrom != moveTo )
	{
		itemToMove = [titles objectAtIndex:moveFrom];
		DLog(@"move %@ at %i to %i", itemToMove, moveFrom, moveTo );
		[titles removeObjectAtIndex:moveFrom];
		[titles insertObject:itemToMove atIndex:moveTo];
		[coalescer coalesceMoveFrom:moveFrom to:moveTo];
	}
	
	NSMutableIndexSet* insertions = [[NSMutableIndexSet alloc] init];
	NSMutableArray* inserted = [NSMutableArray array];
	int insertionCount = rand()%3;
	for ( int i=0; i<insertionCount; i++ )
	{
		int index = rand()%(self.titles.count+i+1);
		if ( [insertions containsIndex:index] )
			// try again
			i--;
		else
		{
			[insertions addIndex:index];
			[inserted addObject:[NSString stringWithFormat:@"s%i",i]];
		}
	}
	[titles insertObjects:inserted atIndexes:insertions];
	[coalescer coalesceAdds:insertions removes:nil];
	
	
	NSMutableIndexSet* removes = [[NSMutableIndexSet alloc] init];
	/*
	int removeCount = rand()%3;
	for ( int i=0; i<removeCount; i++ )
	{
		int idx = NSNotFound;
		NSString* item = itemToMove;
		while ( item==itemToMove )
		{
			// don't remove the item we moved
			idx = rand()%(self.titles.count);
			item = [self.titles objectAtIndex:idx];
		}
		[removes addIndex:idx];
	}
	[titles removeObjectsAtIndexes:removes];
	[coalescer coalesceAdds:nil removes:removes];
	*/
	
	
	
	DLog(@"insert %@, remove %@", insertions, removes);
	self.titles = titles;
	unsigned int actualMoveTo = NSNotFound;
	if ( itemToMove )
	{
		//if ( moveFrom<moveTo )
			actualMoveTo = [titles indexOfObject:itemToMove];
		//else
		//	actualMoveTo = moveTo;
//		actualMoveTo = moveTo;
	}
	
	NSMutableArray* addsArray = [NSMutableArray array];
	NSMutableArray* removesArray = [NSMutableArray array];
	[coalescer.coalescedAdds enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[addsArray addObject:makeIP(idx)];
	}];
	[coalescer.coalescedRemoves enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[removesArray addObject:makeIP(idx)];
	}];
	
	DLog(@"****** started with %@", [self stringFromArray:[self initialArrayContents]]);
	DLog(@"******   ended with %@", [self stringFromArray:self.titles]);
	[self.collectionView performBatchUpdates:^{
		DLog(@"moving %i to %i (was: %i) and doing coalescer: %@", moveFrom, actualMoveTo, moveTo, coalescer);
		
		if (/* moveFrom!=actualMoveTo && */actualMoveTo!=NSNotFound )
			[self.collectionView moveItemAtIndexPath:makeIP(moveFrom) toIndexPath:makeIP(actualMoveTo)];
			
		if ( addsArray.count )
			[self.collectionView insertItemsAtIndexPaths:addsArray];
		
		if ( removesArray.count )
			[self.collectionView deleteItemsAtIndexPaths:removesArray];
	} completion:^(BOOL finished) {
		[self updateLabel];
		//DLog(@"done, need to compare");
		dispatch_async(dispatch_get_main_queue(), ^()
					   {
						   [self compareCellTitlesCreatedForRun:runIndex viaIndexCoalescer:coalescer withActualTitles:titles];
						   [self doNextRun:runIndex];
					   });
	}];
	
	
	
}

-(void)compareCellTitlesCreatedForRun:(int)runIndex viaIndexCoalescer:(NEIndexSetCoalescer*)coalescer withActualTitles:(NSArray*)actualTitles
{
	NSArray* cellTitles = [self visibleCellTitles];
	
	if ( ![cellTitles isEqual:actualTitles] )
	{
		DLog(@"run %3i: cell titles differ from actual titles", runIndex);
		DLog(@"  initial state: %@", [self stringFromArray:[self initialArrayContents]]);
		DLog(@"    final state: %@", [self stringFromArray:actualTitles] );
		DLog(@"    cell titles: %@", [self stringFromArray:cellTitles] );
		DLog(@"  coalescer: %@", [coalescer longDescription] );
		DLog(@"continuing...");
		self.failCount++;
	}
	else
	{
		self.passCount++;
	}
}

- (void)doNextRun:(int)currentIndex
{
	if ( currentIndex<self.numberOfRuns )
	{
		currentIndex++;
		self.titles = [self initialArrayContents];
		[self.collectionView reloadData];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self doRandomIndexSetCoalescerTest:currentIndex];
		});
	}
	else
	{
		DLog(@"done, %i passed, %i failed", self.passCount, self.failCount);
	}
	
}

- (void)doIndexSetCoalescerTest
{
	self.titles = [self initialArrayContents];
	[self.collectionView reloadData];
	NSMutableArray* titles = [self.titles mutableCopy];
	
	NSString* itemToMove = @"A";
	unsigned int moveFrom = [titles indexOfObject:itemToMove];
	unsigned int moveTo = 2;
	NEIndexSetCoalescer* coalescer = [[NEIndexSetCoalescer alloc] init];
	
	if ( moveFrom != moveTo )
	{
		NSObject* obj = [titles objectAtIndex:moveFrom];
		[titles removeObjectAtIndex:moveFrom];
		[titles insertObject:obj atIndex:moveTo];

		DLog(@"after move: %@", titles);
		//[coalescer coalesceAdds:makeIS(actualTarget) removes:makeIS(moveFrom)];
		/*
		int actualTarget = moveTo;
		if ( moveFrom<moveTo )
			actualTarget++;	*/
		[coalescer coalesceMoveFrom:moveFrom to:moveTo];
	}
	
	
	
	NSMutableIndexSet* newSpacerIndices = [[NSMutableIndexSet alloc] init];
	[newSpacerIndices addIndex:0];
	[newSpacerIndices addIndex:2];
	[newSpacerIndices addIndex:4];
	NSArray* newSpacers = @[@"s0", @"s2", @"s3"];
	[titles insertObjects:newSpacers atIndexes:newSpacerIndices];
	[coalescer coalesceAdds:newSpacerIndices removes:nil];
	
	//NSAssert([coalescer.coalescedAdds isEqual:newSpacerIndices], @"Failure: sets differ");
	
	DLog(@"before delete: %@ %@", titles, [coalescer longDescription]);
	NSMutableIndexSet* removedIndices = [[NSMutableIndexSet alloc] init];
	// remove s1 B
	[removedIndices addIndex:1];
	//[removedIndices addIndex:3];
	[removedIndices addIndex:6];
	[titles removeObjectsAtIndexes:removedIndices];
	DLog(@"after delete: %@", titles );
	[coalescer coalesceAdds:nil removes:removedIndices];
	
	NSMutableArray* adds = [NSMutableArray array];
	NSMutableArray* removes = [NSMutableArray array];
	[coalescer.coalescedAdds enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[adds addObject:makeIP(idx)];
	}];
	[coalescer.coalescedRemoves enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[removes addObject:makeIP(idx)];
	}];
	
	self.titles = titles;
	unsigned int actualMoveTo = [titles indexOfObject:itemToMove];
	[self.collectionView performBatchUpdates:^{
		
		
		DLog(@"moving %i to %i and doing coalescer: %@", moveFrom, actualMoveTo, coalescer);
		
		if ( moveFrom!=actualMoveTo && actualMoveTo!=NSNotFound )
			[self.collectionView moveItemAtIndexPath:makeIP(moveFrom) toIndexPath:makeIP(actualMoveTo)];
			
		if ( adds.count )
			[self.collectionView insertItemsAtIndexPaths:adds];
		
		if ( removes.count )
			[self.collectionView deleteItemsAtIndexPaths:removes];
		//[self.collectionView deleteItemsAtIndexPaths:@[makeIP(1), makeIP(3)]];
///		[self.collectionView deleteItemsAtIndexPaths:@[makeIP(0)]];
		
		
		
	} completion:^(BOOL finished) {
		
		[self updateLabel];
		
		
	}];
	
}

- (void)viewDidLoad
{
	self.titles = [self initialArrayContents];
	[self.collectionView reloadData];
	[self updateLabel];
	

	double delayInSeconds = 1.9;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self swapToBlack];
	});
	
	
	
	delayInSeconds = 2.0;
	popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		self.numberOfRuns = 100;
		[self doNextRun:0];
		return;
		
		self.titles = @[@"C", @"D", @"A"];
		
		
		NEIndexSetCoalescer* coalescer = [[NEIndexSetCoalescer alloc] init];
		NSIndexSet* adds = [NSIndexSet indexSetWithIndex:1];
		NSIndexSet* removes = [NSIndexSet indexSetWithIndex:1];
		[coalescer coalesceAdds:nil removes:removes];
		[coalescer coalesceAdds:adds removes:nil];
		NSLog(@"Expected: %@", coalescer);
		
		
		/*
		// works
		// move outside block
		[rootViewController.tableView moveRowAtIndexPath:makeIP(0) toIndexPath:makeIP(2)];
		[rootViewController.tableView beginUpdates];
		[rootViewController.tableView deleteRowsAtIndexPaths:@[makeIP(0)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView insertRowsAtIndexPaths:@[makeIP(1)] withRowAnimation:UITableViewRowAnimationAutomatic];
		[rootViewController.tableView endUpdates];
		 */
		
		 // works
		 // move inside block
		[self.collectionView performBatchUpdates:^ {
			[self.collectionView moveItemAtIndexPath:makeIP(0) toIndexPath:makeIP(2)];
			[self.collectionView deleteItemsAtIndexPaths:@[makeIP(1)]];
			[self.collectionView insertItemsAtIndexPaths:@[makeIP(1)]];
		} completion:^(BOOL finished) {
		}];
		
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

	});
	
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	DLog(@"%i items", self.titles.count);
    return self.titles.count;
}

- (void)swapToBlack
{
	for ( Cell* cell in self.collectionView.visibleCells )
	{
		cell.label.backgroundColor = [UIColor blackColor];
		cell.label.textColor = [UIColor whiteColor];
	}
}


- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	Header* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];
	
	self.headerLabel = header.label;
	[self updateLabel];
	
	return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    // make the cell's title the actual NSIndexPath value
	cell.label.text = [self.titles objectAtIndex:indexPath.row];
    
    // load the image for this cell
    return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
		/*
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        // load the image, to prevent it from being cached we use 'initWithContentsOfFile'
        NSString *imageNameToLoad = [NSString stringWithFormat:@"%d_full", selectedIndexPath.row];
        NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"JPG"];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathToImage];
        
        DetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.image = image;*/
    }
}

@end

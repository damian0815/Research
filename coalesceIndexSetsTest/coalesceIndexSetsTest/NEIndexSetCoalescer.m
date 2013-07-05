//
//  NEIndexSetCoalescer.m
//  coalesceIndexSetsTest
//
//  Created by Damian Stewart on 05.07.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import "NEIndexSetCoalescer.h"
@interface NEIndexSetCoalescer()


@property (strong,readwrite,nonatomic) NSMutableIndexSet* coalescedAdds;
@property (strong,readwrite,nonatomic) NSMutableIndexSet* coalescedRemoves;

@property (strong,readwrite,atomic) NSMutableArray* stupidArray;

@end

@implementation NEIndexSetCoalescer

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self reset];
	}
	return self;
}

- (NSMutableArray*)sortedArrayOfRangesInIndexSet:(NSIndexSet*)set
{
	NSMutableArray* allRanges = [NSMutableArray array];
	[set enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
		[allRanges addObject:[NSValue valueWithRange:range]];
	}];
	// sort
	[allRanges sortUsingComparator:^NSComparisonResult(NSValue* obj1, NSValue* obj2) {
		NSRange range1 = [obj1 rangeValue];
		NSRange range2 = [obj2 rangeValue];
		if ( range1.location < range2.location )
			return NSOrderedAscending;
		else if ( range1.location > range2.location )
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}];
	
	// check
	NSValue* prevRangeValue = nil;
	for ( NSValue* rangeValue in allRanges )
	{
		if ( prevRangeValue != nil )
		{
			NSRange prev = [prevRangeValue rangeValue];
			NSRange curr = [rangeValue rangeValue];
			NSAssert(prev.location+prev.length<curr.location, @"Failure: ranges overlap");
		}
	}
	
	return allRanges;
}

- (NSMutableArray*)sortedArrayOfIndicesInIndexSet:(NSIndexSet*)set
{
	NSMutableArray* allIndices = [NSMutableArray array];
	// extract to array
	[set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
	 {
		 [allIndices addObject:@(idx)];
	 }];
	// sort
	[allIndices sortUsingComparator:^NSComparisonResult(NSNumber* obj1, NSNumber* obj2)
	 {
		 return [obj1 compare:obj2];
	 }];
	return allIndices;
}

- (void)reset
{
	self.coalescedRemoves = [NSMutableIndexSet indexSet];
	self.coalescedAdds = [NSMutableIndexSet indexSet];
	self.stupidArray = [NSMutableArray array];
}


- (void)coalesceAdds:(NSIndexSet*)newAdded removes:(NSIndexSet*)newRemoved
{
	if ( self.coalescedAdds.count==0 && self.coalescedRemoves.count==0 && self.stupidArray.count==0 )
	{
		// we can just use them as given
		[self.coalescedAdds addIndexes:newAdded];
		[self.coalescedRemoves addIndexes:newRemoved];
	}
	else
	{
		// coalesce into existing
		[self stupidCoalesceAdds:newAdded removes:newRemoved];
		//[self brokeCoalesceAdds:newAdded removes:newRemoved];
		//[self complexCoalesceAdds:newAdded removes:newRemoved];
	}

}

- (void)populateStupidArrayToSize:(unsigned int)requestedSize
{
	if ( requestedSize > self.stupidArray.count )
	{
		//NSLog(@"filling up stupidArray to %i items (has now %u)", requestedSize, (unsigned int)self.stupidArray.count );
		// find the last index in the stupid array
		int lastIndexInStupidArray = -1;
		for ( int i=(int)(self.stupidArray.count)-1; i>=0; i-- )
		{
			// inserts are marked by @"*"
			if ( ![[self.stupidArray objectAtIndex:i] isKindOfClass:[NSString class]] )
			{
				lastIndexInStupidArray = [[self.stupidArray objectAtIndex:i] intValue];
				break;
			}
		}
		// fill up the array
		while ( requestedSize>self.stupidArray.count )
		{
			lastIndexInStupidArray++;
			[self.stupidArray addObject:@(lastIndexInStupidArray)];
		}
		//NSLog(@" -> filled up to %u items: has %@", (unsigned int)self.stupidArray.count, self.stupidArray);
	}
}

- (void)stupidCoalesceAdds:(NSIndexSet*)newAdded removes:(NSIndexSet*)newRemoved
{
	// build an array of ints and perform the operations on it, then read it back at the end to see what happened. HAH FUCK YOU.
	
	NSLog(@" Will perform additions: \n%@\n and removals: \n%@", newAdded, newRemoved );
	
	// sort ranges by start location
	NSMutableArray* newAddedArray = [self sortedArrayOfRangesInIndexSet:newAdded];
	NSMutableArray* newRemovedArray = [self sortedArrayOfRangesInIndexSet:newRemoved];
	
	
	// find the last index in newAdded/newRemoved
	int requiredSize = 0;
	if ( newAddedArray.count )
	{
		NSRange lastRange = [[newAddedArray lastObject] rangeValue];
		requiredSize = MAX(requiredSize,lastRange.location);
	}
	if ( newRemovedArray.count )
	{
		NSRange lastRange = [[newRemovedArray lastObject] rangeValue];
		requiredSize = MAX(requiredSize,(int)NSMaxRange(lastRange));
	}
	[self populateStupidArrayToSize:requiredSize];

	
	// apply the changes
	int offset = 0;
	while ( newAddedArray.count || newRemovedArray.count )
	{
		// find first of newAddedArray[0], newRemovedArray[0]
		NSMutableArray* firstOfNew;
		if ( !newAddedArray.count )
			firstOfNew = newRemovedArray;
		else if ( !newRemovedArray.count )
			firstOfNew = newAddedArray;
		else
		{
			NSRange nextNewAdded = [[newAddedArray objectAtIndex:0] rangeValue];
			NSRange nextNewRemoved = [[newRemovedArray objectAtIndex:0] rangeValue];
			if ( nextNewAdded.location<nextNewRemoved.location )
				firstOfNew = newAddedArray;
			else
				firstOfNew = newRemovedArray;
		}
		
		NSRange nextNewRange = [[firstOfNew objectAtIndex:0] rangeValue];
		[firstOfNew removeObjectAtIndex:0];
		
		nextNewRange.location += offset;
		if ( firstOfNew == newAddedArray )
		{
			// enumerate the range
			NSAssert(nextNewRange.location<=self.stupidArray.count, @"nextNewRange out of bounds");
			NSLog(@"   inserting %@", NSStringFromRange(nextNewRange));
			NSIndexSet* nextNewIndexSet = [NSIndexSet indexSetWithIndexesInRange:nextNewRange];
			[nextNewIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
			 {
				 [self.stupidArray insertObject:@"*" atIndex:idx];
			 }];
			offset += nextNewRange.length;
		}
		else
		{
			NSAssert(NSMaxRange(nextNewRange)<self.stupidArray.count, @"nextNewRange out of bounds");
			NSLog(@"   removing %@", NSStringFromRange(nextNewRange));
			[self.stupidArray removeObjectsInRange:nextNewRange];
			offset -= nextNewRange.length;
		}
		
		
		NSLog(@" -> stupid is %@", self.stupidArray);
		
	}
	
	NSLog(@"done; resulting stupid %@", self.stupidArray);
	
	// parse stupid array to build indices
	NSMutableIndexSet* parsedInsertions = [NSMutableIndexSet indexSet];;
	NSMutableIndexSet* parsedRemovals = [NSMutableIndexSet indexSet];
	int insertedCount = 0;
	int expectedIndex = 0;
	for ( unsigned int i=0; i<self.stupidArray.count; i++ )
	{
		NSObject* o = [self.stupidArray objectAtIndex:i];
		if ( [o isKindOfClass:[NSNumber class]] )
		{
			// found a number, what is it?
			if ( insertedCount>0 )
			{
				// some stuff was inserted at expectedIndex
				NSRange range = NSMakeRange(expectedIndex, insertedCount);
				[parsedInsertions addIndexesInRange:range];
				insertedCount = 0;
			}
			
			int foundIndex = [(NSNumber*)o intValue];
			if ( foundIndex>expectedIndex )
			{
				// some stuff was removed
				NSRange range = NSMakeRange(expectedIndex, foundIndex-expectedIndex);
				[parsedRemovals addIndexesInRange:range];
			}

			// next
			expectedIndex = foundIndex+1;
		}
		else
		{
			insertedCount++;
		}
	}
	if ( insertedCount )
	{
		NSRange range = NSMakeRange(expectedIndex, insertedCount);
		[parsedInsertions addIndexesInRange:range];
	}
	
	self.coalescedAdds = parsedInsertions;
	self.coalescedRemoves = parsedRemovals;
	
	NSLog(@"Coalesce end, result adds %@ removes %@", self.coalescedAdds, self.coalescedRemoves );
}

- (void)complexCoalesceAdds:(NSIndexSet *)newAdded removes:(NSIndexSet *)newRemoved
{
	// sort ranges by start location
	NSMutableArray* currentAddedArray = [self sortedArrayOfRangesInIndexSet:self.coalescedAdds];
	NSMutableArray* currentRemovedArray = [self sortedArrayOfRangesInIndexSet:self.coalescedRemoves];
	NSMutableArray* newAddedArray = [self sortedArrayOfRangesInIndexSet:newAdded];
	NSMutableArray* newRemovedArray = [self sortedArrayOfRangesInIndexSet:newRemoved];
	
	NSMutableIndexSet* resultAdded = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* resultRemoved = [NSMutableIndexSet indexSet];
	
	int offset=0;
	NSLog(@"Coalesce begin");
	while ( newAddedArray.count || newRemovedArray.count )
	{
		// find first of newAddedArray[0], newRemovedArray[0]
		NSMutableArray* firstOfNew;
		if ( !newAddedArray.count )
			firstOfNew = newRemovedArray;
		else if ( !newRemovedArray.count )
			firstOfNew = newAddedArray;
		else
		{
			NSRange nextNewAdded = [[newAddedArray objectAtIndex:0] rangeValue];
			NSRange nextNewRemoved = [[newRemovedArray objectAtIndex:0] rangeValue];
			if ( nextNewAdded.location<nextNewRemoved.location )
				firstOfNew = newAddedArray;
			else
				firstOfNew = newRemovedArray;
		}
		
		NSRange nextNewRange = [[firstOfNew objectAtIndex:0] rangeValue];
		NSLog(@"nextNewRange: %@", NSStringFromRange(nextNewRange));
		
		// move through currentAdded and currentRemoved until they overlap, updating offset
		int overlapOffset = 0;
		BOOL overlapsAdded = NO;
		BOOL overlapsRemoved = NO;
		while ( (currentAddedArray.count && !overlapsAdded) || (currentRemovedArray.count && !overlapsRemoved) )
		{
			NSMutableArray* firstOfCurrent;
			if ( (!currentAddedArray.count) || overlapsAdded )
				firstOfCurrent = currentRemovedArray;
			else if ( (!currentRemovedArray.count) || overlapsRemoved )
				firstOfCurrent = currentAddedArray;
			else
			{
				NSRange nextCurrentAdded = [[currentAddedArray objectAtIndex:0] rangeValue];
				NSRange nextCurrentRemoved = [[currentRemovedArray objectAtIndex:0] rangeValue];
				if ( nextCurrentAdded.location<nextCurrentRemoved.location )
					firstOfCurrent = currentAddedArray;
				else
					firstOfCurrent = currentRemovedArray;
			}
			
			if ( firstOfCurrent == currentAddedArray )
			{
				NSRange currentAddRange = [[currentAddedArray objectAtIndex:0] rangeValue];
				NSLog(@"firstOfCurrent (added) = %@", NSStringFromRange(currentAddRange));
				
				if ( (int)(nextNewRange.location)+offset+overlapOffset > (int)NSMaxRange(currentAddRange) )
				{
					// currentAddRange is completely before nextNewRange
					[resultAdded addIndexesInRange:currentAddRange];
					offset += currentAddRange.length;
					[currentAddedArray removeObjectAtIndex:0];
				}
				else if ( (int)NSMaxRange(nextNewRange)+offset+overlapOffset < (int)currentAddRange.location )
				{
					// currentAddRange is completely after nextNewRange
					break;
				}
				else
				{
					// ranges overlap
					// adjust offset by the overlap amount
					int overlap = (int)NSMaxRange(currentAddRange) - (((int)nextNewRange.location)+offset+overlapOffset);
					overlapOffset -= overlap;
					NSLog(@"Overlaps add");
					overlapsAdded = YES;
				}
			}
			else
			{
				NSRange currentRemoveRange = [[currentRemovedArray objectAtIndex:0] rangeValue];
				NSLog(@"firstOfCurrent (added) = %@", NSStringFromRange(currentRemoveRange));
				if ( (int)(nextNewRange.location)+offset+overlapOffset > (int)NSMaxRange(currentRemoveRange) )
				{
					// currentRemoveRange is completely before nextNewRange
					[resultRemoved addIndexesInRange:currentRemoveRange];
					offset -= currentRemoveRange.length;
					[currentRemovedArray removeObjectAtIndex:0];
				}
				else if ( (int)NSMaxRange(nextNewRange)+offset+overlapOffset < (int)currentRemoveRange.location )
				{
					// currentRemoveRange is completely after nextNewRange
					break;
				}
				else
				{
					// ranges overlap
					// adjust offset by the overlap amount
					int overlap = (int)NSMaxRange(currentRemoveRange) - (((int)nextNewRange.location)+offset+overlapOffset);
					overlapOffset += overlap;
					NSLog(@"Overlaps remove");
					overlapsRemoved = YES;
				}
				
				
			}
		}
		
		// adjust range based on offset
		nextNewRange.location += offset+overlapOffset;
		
		NSLog(@"-> resulting newNewRange %@", NSStringFromRange(nextNewRange));
		
		// see if we overlap a remove set
		NSMutableIndexSet* nextNewIndexSet = [NSMutableIndexSet indexSetWithIndexesInRange:nextNewRange];
		
		// check if this range overlaps with the next currentRemoved range
		for ( unsigned int i=0; i<currentRemovedArray.count; i++ )
		{
			NSRange nextCurrentRemoved = [[currentRemovedArray objectAtIndex:i] rangeValue];
			if ( nextCurrentRemoved.location >= NSMaxRange(nextNewRange) )
			{
				// does not overlap
				break;
			}
			
			// nextCurrentRemoved overlaps
			NSLog(@" - scrubbing current removed %@ from next new added %@", NSStringFromRange(nextCurrentRemoved), nextNewIndexSet);
			[nextNewIndexSet removeIndexesInRange:nextCurrentRemoved];
			NSLog(@"   result %@", nextNewIndexSet);
		}
		
		if ( firstOfNew == newAddedArray )
		{
			[resultAdded addIndexes:nextNewIndexSet];
			[newAddedArray removeObjectAtIndex:0];
		}
		else
		{
			[resultRemoved addIndexes:nextNewIndexSet];
			[newRemovedArray removeObjectAtIndex:0];
		}
	}
	// deal with the leftovers
	for ( NSNumber* added in newAddedArray )
	{
		NSRange addedRange = [added rangeValue];
		addedRange.location += offset;
		[resultAdded addIndexesInRange:addedRange];
	}
	for ( NSNumber* removed in newRemovedArray )
	{
		NSRange removedRange = [removed rangeValue];
		removedRange.location += offset;
		[resultRemoved addIndexesInRange:removedRange];
	}
	for ( NSNumber* added in currentAddedArray )
		[resultAdded addIndexesInRange:[added rangeValue]];
	for ( NSNumber* removed in currentRemovedArray )
		[resultRemoved addIndexesInRange:[removed rangeValue]];
	
	
	NSLog(@"Coalesce end, result adds %@ removes %@", resultAdded, resultRemoved );
	
	self.coalescedAdds = resultAdded;
	self.coalescedRemoves = resultRemoved;
	
}

- (void)brokeCoalesceAdds:(NSIndexSet*)newAdded removes:(NSIndexSet*)newRemoved
{
	NSMutableArray* currentAddedArray = [self sortedArrayOfIndicesInIndexSet:self.coalescedAdds];
	NSMutableArray* currentRemovedArray = [self sortedArrayOfIndicesInIndexSet:self.coalescedRemoves];
	NSMutableArray* newAddedArray = [self sortedArrayOfIndicesInIndexSet:newAdded];
	NSMutableArray* newRemovedArray = [self sortedArrayOfIndicesInIndexSet:newRemoved];
	
	NSMutableIndexSet* resultAdded = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* resultRemoved = [NSMutableIndexSet indexSet];
	
	int offset = 0;
	NSLog(@"Coalesce begin");
	while ( newAddedArray.count || newRemovedArray.count )
	{
		// find smallest of currentAdded[0], currentRemoved[0], newAdded[0]+offset, newRemoved[0]+offset
		NSArray* selection = @[currentAddedArray,currentRemovedArray,newAddedArray,newRemovedArray];
		unsigned int bestFound = 0;
		int bestArrayIndex = -1;
		for ( unsigned int i=0; i<selection.count; i++ )
		{
			NSArray* whichArray = (NSArray*)[selection objectAtIndex:i];
			if ( whichArray.count>0 )
			{
				int test = [(NSNumber*)[whichArray objectAtIndex:0] intValue];
				if ( whichArray==newAddedArray||whichArray==newRemovedArray )
				{
					test += offset;
				}
				if ( bestArrayIndex==-1 || test<bestFound )
				{
					bestArrayIndex = i;
					bestFound = test;
				}
			}
		}
		NSAssert(bestArrayIndex!=-1, @"Failure: no array found");
		
		unsigned int index = bestFound;
		NSMutableArray* bestArray = (NSMutableArray*)selection[bestArrayIndex];
		// if in removed: offset--
		// if in inserted: offset++
		// if in newAdded: resultAdded.addIndex(index+offset)
		// if in newRemoved: resultRemoved.addIndex(index+offset)
		
		if ( bestArray == currentAddedArray )
		{
			offset++;
			NSLog(@" - currentAdded  : %u    offset now %2i", index, offset );
			[currentAddedArray removeObjectAtIndex:0];
			[resultAdded addIndex:index];
		}
		else if ( bestArray == currentRemovedArray )
		{
			offset--;
			NSLog(@" - currentRemoved: %2u   offset now %2i", index, offset );
			[currentRemovedArray removeObjectAtIndex:0];
			[resultRemoved addIndex:index];
		}
		else if ( bestArray == newAddedArray )
		{
			NSLog(@" - newAdded   : % 3i", index );
			NSAssert(index>=0, @"Failure: invalid result index");
			[resultAdded addIndex:(unsigned int)index];
			[newAddedArray removeObjectAtIndex:0];
		}
		else if ( bestArray == newRemovedArray )
		{
			NSLog(@" - newRemoved : % 3i", index );
			NSAssert(index>=0, @"Failure: invalid result index");
			[resultRemoved addIndex:(unsigned int)index];
			[newRemovedArray removeObjectAtIndex:0];
		}
		
	}
	// deal with the leftovers
	for ( NSNumber* added in currentAddedArray )
		[resultAdded addIndex:[added intValue]];
	for ( NSNumber* removed in currentRemovedArray )
		[resultRemoved addIndex:[removed intValue]];
	
	
	NSLog(@"Coalesce end, result adds %@ removes %@", resultAdded, resultRemoved );
	
	self.coalescedAdds = resultAdded;
	self.coalescedRemoves = resultRemoved;
	
}


@end


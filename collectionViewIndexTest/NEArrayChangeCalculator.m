//
//  NEArrayChangeCalculator.m
//  CollectionView
//
//  Created by damian on 10/07/13.
//
//

#import "NEArrayChangeCalculator.h"

@interface NEArrayChangeCalculator()

@property (readwrite,atomic) NSMutableIndexSet* insertedIndicesInternal;
@property (readwrite,atomic) NSMutableIndexSet* removedIndicesInternal;

/*! @abstract Sources and destinations for move operations, as NSNumber objects.
	@discussion
		moveSources.count==moveDestinations.count, each pair of entries defines a move. */
@property (readwrite,atomic) NSMutableArray* moveSourcesInternal;
@property (readwrite,atomic) NSMutableArray* moveDestinationsInternal;


@end


@implementation NEArrayChangeCalculator

- (void)calculateChangesBetweenSource:(NSArray*)source andTarget:(NSArray*)target
{
	self.removedIndicesInternal = [[NSMutableIndexSet alloc] init];
	self.insertedIndicesInternal = [[NSMutableIndexSet alloc] init];
	self.moveSourcesInternal = [NSMutableArray array];
	self.moveDestinationsInternal = [NSMutableArray array];
	
	NSSet* allSourceObjects = [NSSet setWithArray:source];
	NSSet* allTargetObjects = [NSSet setWithArray:target];
	
	/*
	// find moves
	[source enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ( [allTargetObjects containsObject:obj] )
		{
			unsigned int targetIdx = [target indexOfObject:obj];
			if ( idx != targetIdx )
			{
				[self.moveSourcesInternal addObject:@(idx)];
				[self.moveDestinationsInternal addObject:@(targetIdx)];
			}
			
		}
		
	}];*/
	

	// find insertions
	[source enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ( ![allTargetObjects containsObject:obj] )
			[self.removedIndicesInternal addIndex:idx];
	}];
	
	// find removals
	[target enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ( ![allSourceObjects containsObject:obj] )
			[self.insertedIndicesInternal addIndex:idx];
	}];
}

- (NSArray*)moveSources
{
	return self.moveSourcesInternal;
}

- (NSArray*)moveDestinations
{
	return self.moveDestinationsInternal;
}

- (NSIndexSet*)insertedIndices
{
	return self.insertedIndicesInternal;
}

- (NSIndexSet*)removedIndices
{
	return self.removedIndicesInternal;
}

@end

//
//  NEArrayChangeCalculator.h
//  CollectionView
//
//  Created by damian on 10/07/13.
//
//

#import <Foundation/Foundation.h>

@interface NEArrayChangeCalculator : NSObject

@property (readonly,atomic) NSIndexSet* insertedIndices;
@property (readonly,atomic) NSIndexSet* removedIndices;

/*! @abstract Sources and destinations for move operations, as NSNumber objects.
	@discussion
		moveSources.count==moveDestinations.count, each pair of entries defines a move. */
@property (readonly,atomic) NSArray* moveSources;
@property (readonly,atomic) NSArray* moveDestinations;

- (void)calculateChangesBetweenSource:(NSArray*)source andTarget:(NSArray*)target;

@end

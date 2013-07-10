//
//  NEIndexSetCoalescer.h
//  coalesceIndexSetsTest
//
//  Created by Damian Stewart on 05.07.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEIndexSetCoalescer: NSObject

@property (readonly,atomic) NSIndexSet* coalescedAdds;
@property (readonly,atomic) NSIndexSet* coalescedRemoves;

+ (NEIndexSetCoalescer*)indexSetCoalescerWithAdds:(NSIndexSet*)adds removes:(NSIndexSet*)removes;

- (NSString*)longDescription;

- (void)reset;
- (BOOL)isEmpty;

- (void)coalesceAdds:(NSIndexSet*)newAdded removes:(NSIndexSet*)newRemoved;
- (void)coalesceMoveFrom:(unsigned int)from to:(unsigned int)to;

@end

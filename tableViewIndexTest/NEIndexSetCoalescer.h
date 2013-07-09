//
//  NEIndexSetCoalescer.h
//  coalesceIndexSetsTest
//
//  Created by Damian Stewart on 05.07.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEIndexSetCoalescer: NSObject

@property (readonly,nonatomic) NSMutableIndexSet* coalescedAdds;
@property (readonly,nonatomic) NSMutableIndexSet* coalescedRemoves;

+ (NEIndexSetCoalescer*)indexSetCoalescerWithAdds:(NSIndexSet*)adds removes:(NSIndexSet*)removes;

- (void)reset;
- (void)coalesceAdds:(NSIndexSet*)newAdded removes:(NSIndexSet*)newRemoved;

@end

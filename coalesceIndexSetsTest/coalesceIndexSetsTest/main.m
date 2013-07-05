//
//  main.c
//  coalesceIndexSetsTest
//
//  Created by Damian Stewart on 05.07.13.
//  Copyright (c) 2013 Damian Stewart. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "NEIndexSetCoalescer.h"


/*void doRandomIndexSetsTest()
{
	NSMutableIndexSet* added0 
}*/


void doIndexSetsTest()
{
	NSMutableArray* array = [NSMutableArray array];
	for ( int i=0; i<5; i++ )
	{
		[array addObject:@(i)];
	}
	
	NSMutableIndexSet* added0 = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* added1 = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* added2 = [NSMutableIndexSet indexSet];

	NSMutableIndexSet* removed0 = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* removed1 = [NSMutableIndexSet indexSet];
	NSMutableIndexSet* removed2 = [NSMutableIndexSet indexSet];
	
	/*
	[added0 addIndex:3];
	[removed0 addIndex:1];
	
	[added1 addIndex:0];
	[added1 addIndex:1];
	[removed1 addIndex:2];
	
	[added2 addIndex:4];
	[removed2 addIndex:2];
	[removed2 addIndex:3];
	 */
	
	[added0 addIndex:2];
	[removed0 addIndex:0];
	
	[added1 addIndex:2];
	[added1 addIndex:3];
	[added1 addIndex:4];
	
	[added2 addIndex:0];
	[removed2 addIndex:3];
	
	NEIndexSetCoalescer* coalescer = [[NEIndexSetCoalescer alloc] init];
	[coalescer coalesceAdds:added0 removes:removed0];
	[coalescer coalesceAdds:added1 removes:removed1];
	[coalescer coalesceAdds:added2 removes:removed2];
	
	NSLog(@"Result: add %@ remove %@", coalescer.coalescedRemoves, coalescer.coalescedAdds);
	
}



int main(int argc, const char * argv[])
{

	// insert code here...
//	for ( int i=0; i<100; i++ )
	{
		doIndexSetsTest();
	}
	
    return 0;
	
}



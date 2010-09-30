//
//  CellModel.m
//  TreeMap
//
//  Created by freelancer on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CellModel.h"


@implementation CellModel
@synthesize profileImage;
@synthesize indexNo;

- (id)initWithImage:(UIImage*)image 
		atIndex:(NSInteger)index

{
	if (![super init]) 
		return nil;
		
	self.profileImage = image;
	self.indexNo = index;
	return self;
}



- (id)init {
	return [self initWithImage:self.profileImage atIndex:indexNo];
}


- (void)dealloc {
	[self.profileImage release];
    [super dealloc];
}


@end

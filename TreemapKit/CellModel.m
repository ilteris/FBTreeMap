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

- (id)initWithImage:(UIImage*)image {
	self = [super init];
	if(nil != self)
	{
		self.profileImage = image;
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end

//
//  CellModel.h
//  TreeMap
//
//  Created by freelancer on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CellModel : NSObject {
	UIImage *profileImage;
	NSInteger indexNo;
}



- (id)initWithImage:(UIImage*)image atIndex:(NSInteger)index;



@property(nonatomic, retain) UIImage *profileImage;
@property(nonatomic, assign) NSInteger indexNo;

@end

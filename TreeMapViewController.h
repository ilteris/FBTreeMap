//
//  TreeMapViewController.h
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreemapView.h"

@interface TreeMapViewController : UIViewController   <TreemapViewDelegate, TreemapViewDataSource> {
	NSMutableArray *fruits;
}

@property (nonatomic, retain) NSMutableArray *fruits;


- (void)resizeView;
@end

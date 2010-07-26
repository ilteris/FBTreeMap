//
//  TreeMapViewController.h
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreemapView.h"

#import "FbGraph.h"


@interface TreeMapViewController : UIViewController   </*TreemapViewDelegate, TreemapViewDataSource,*/ UIWebViewDelegate> {
    
	NSMutableArray *fruits;
	
	//facebook
	FbGraph *fbGraph;
	
	//we'll use this to store a feed post (when you press 'post me/feed').
	//when you press delete me/feed this is the post that's deleted
	NSString *feedPostId;
}

@property (nonatomic, retain) NSMutableArray *fruits;

//facebook
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) NSString *feedPostId;


//- (void)resizeView;
-(void)getAuthorPictureButtonPressed;
-(void)getMeButtonPressed;

@end

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
#import "RegexKitLite.h"

#import "FBConnect.h"
#import "UserInfo.h"


@class ASINetworkQueue;


@interface TreeMapViewController : UIViewController   <TreemapViewDelegate, TreemapViewDataSource, UIWebViewDelegate> {
   
	
	UserInfo *_userInfo;
	
	ASINetworkQueue *networkQueue;

	NSMutableArray *cells;
	NSMutableArray *destinationPaths;
	
	//facebook
	FbGraph *fbGraph;
	
	//we'll use this to store a feed post (when you press 'post me/feed').
	//when you press delete me/feed this is the post that's deleted
	NSString *feedPostId;
	

	IBOutlet UIView *treeMapView;
	IBOutlet UIWebView *myWebView;
	
	
	BOOL failed;
	BOOL imagesLoaded;
	
	NSMutableArray *plistArray;
	NSMutableArray *fruits;
	NSMutableArray *jsonArray;
	
	NSMutableArray *_backgrounds;
}



@property(nonatomic, retain) UserInfo *userInfo;

@property (nonatomic, retain) NSMutableArray *fruits;
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) NSMutableArray *destinationPaths;
@property (nonatomic, retain) NSMutableArray *plistArray;
@property (nonatomic, retain) NSMutableArray *jsonArray;

//facebook
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) NSString *feedPostId;




@property (nonatomic, retain) IBOutlet UIView *treeMapView;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;


- (void)setTheBackgroundArray;
- (void)resizeView;







@end

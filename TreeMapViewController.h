//
//  TreeMapViewController.h
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreemapView.h"


#import "RegexKitLite.h"

#import "FBConnect.h"
#import "UserInfo.h"
#import "PeopleMapDB.h"

@class ASINetworkQueue;


@interface TreeMapViewController : UIViewController   <TreemapViewDelegate, TreemapViewDataSource, UIWebViewDelegate> {
   
	

	
	ASINetworkQueue *networkQueue;

	NSMutableArray *cells;

	
	//facebook

	
	//we'll use this to store a feed post (when you press 'post me/feed').
	//when you press delete me/feed this is the post that's deleted
	NSString *feedPostId;
	
	PeopleMapDB *_peopleMapDB;
	

	IBOutlet UIView *treeMapView;
	IBOutlet UIWebView *myWebView;
	
	
	BOOL failed;
	BOOL imagesLoaded;
	
	NSMutableArray *plistArray;
	NSMutableArray *fruits;
	NSMutableArray *jsonArray;
	
}



@property (nonatomic, retain) PeopleMapDB *peopleMapDB;


@property (nonatomic, retain) NSMutableArray *fruits;
@property (nonatomic, retain) NSMutableArray *cells;

@property (nonatomic, retain) NSMutableArray *plistArray;
@property (nonatomic, retain) NSMutableArray *jsonArray;

//facebook

@property (nonatomic, retain) NSString *feedPostId;




@property (nonatomic, retain) IBOutlet UIView *treeMapView;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;


- (void)resizeView;
- (void) getLikes;






@end

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

@class ASINetworkQueue;


@interface TreeMapViewController : UIViewController   <TreemapViewDelegate, TreemapViewDataSource, UIWebViewDelegate> {
    ASINetworkQueue *networkQueue;
	NSMutableArray *fruits;
	NSMutableArray *cells;
	NSMutableArray *destinationPaths;
	
	//facebook
	FbGraph *fbGraph;
	
	//we'll use this to store a feed post (when you press 'post me/feed').
	//when you press delete me/feed this is the post that's deleted
	NSString *feedPostId;
	
	IBOutlet UIWebView *myWebView;
	
	BOOL failed;
	BOOL imagesLoaded;
	
	
	
}

@property (nonatomic, retain) NSMutableArray *fruits;
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) NSMutableArray *destinationPaths;

//facebook
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) NSString *feedPostId;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;



- (void)resizeView;

-(void)getMeButtonPressed;

-(void) filterEntries:(NSMutableArray*)mutableArray;

- (void) callAPI;

@end

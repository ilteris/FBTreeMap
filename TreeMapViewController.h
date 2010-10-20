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
	
	
	IBOutlet UIImageView *menu;
	IBOutlet UIButton *like_btn;
	IBOutlet UIButton *comment_btn;
	IBOutlet UIButton *refresh_btn;
	

	BOOL displayMode; //either comment mode or like mode. 1 is comment mode 0 is like mode
	
	
}

@property (nonatomic, retain) NSMutableArray *fruits;
@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) NSMutableArray *destinationPaths;
@property (nonatomic, retain) NSMutableArray *plistArray;
@property (nonatomic, retain) NSMutableArray *jsonArray;

//facebook
@property (nonatomic, retain) FbGraph *fbGraph;
@property (nonatomic, retain) NSString *feedPostId;

@property (nonatomic, retain) IBOutlet UIButton *like_btn;
@property (nonatomic, retain) IBOutlet UIButton *comment_btn;
@property (nonatomic, retain) IBOutlet UIButton *refresh_btn;


@property (nonatomic, retain) IBOutlet UIView *treeMapView;
@property (nonatomic, retain) IBOutlet UIWebView *myWebView;

@property (nonatomic, retain) IBOutlet UIImageView *menu;

- (void)resizeView;

-(void)getMeButtonPressed:(NSString*)key;

-(NSMutableArray*) filterEntries:(NSMutableArray*)mutableArray accordingTo:(NSString*)key;

- (void) downloadImages;

- (IBAction)refreshDisplay;
- (IBAction)displayLikes;
- (IBAction)displayComments;
@end

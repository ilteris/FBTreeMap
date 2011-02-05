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


#import "UserInfo.h"
#import "PeopleMapDB.h"

@class ASINetworkQueue;
@class TreemapViewCell;



@interface TreeMapViewController: NSObject   <TreemapViewDelegate, TreemapViewDataSource, FBDialogDelegate, UserInfoLoadDelegate> {
   

	ASINetworkQueue *_networkQueue;
	

	NSMutableArray *_backgrounds;

	//facebook
	UserInfo *_userInfo;
	
	//we'll use this to store a feed post (when you press 'post me/feed').
	//when you press delete me/feed this is the post that's deleted
	NSString *feedPostId;
	
	PeopleMapDB *_peopleMapDB;
	

	IBOutlet TreemapView *treeMapView;

	
	
	BOOL failed;
	BOOL imagesLoaded;
	
	NSMutableArray *plistArray;
	NSMutableArray *fruits;
	NSMutableArray *jsonArray;
	
}



@property (nonatomic, retain) UserInfo *userInfo;
@property (nonatomic, retain) PeopleMapDB *peopleMapDB;


@property (nonatomic, retain) NSMutableArray *fruits;
@property (nonatomic, retain) NSMutableArray *cells;

@property (nonatomic, retain) NSMutableArray *plistArray;
@property (nonatomic, retain) NSMutableArray *jsonArray;

//facebook

@property (nonatomic, retain) NSString *feedPostId;




@property (nonatomic, retain) IBOutlet TreemapView *treeMapView;



- (void)createCellsFromZero;


-(void) changeTime;
- (void)setTheBackgroundArray;
- (void)resizeView;

- (void)displaySection:(NSString*)section andView:(NSString*)viewType withDuration:(NSString*)duration;
- (void)displayCommentsOfUsers;
- (void)displayCommentsOfPages;
- (void)displayLikesOfPages;
- (void)displayLikesOfUsers;
-(NSString*)returnDurationString:(int)integer;

@end

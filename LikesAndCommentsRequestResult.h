//
//  LikesAndCommentsRequestResult.h
//  TreeMap
//
//  Created by freelancer on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "PeopleMapDB.h"


@protocol LikesAndCommentsRequestDelegate;

@class ASINetworkQueue;

@interface LikesAndCommentsRequestResult : NSObject<FBRequestDelegate>
{
	PeopleMapDB *_peopleMapDB;
	
	NSInteger _categoryMode;
	NSMutableArray *_plistUserArray;
	NSMutableArray *_plistPageArray;
	NSMutableArray *_backgrounds;

	id<LikesAndCommentsRequestDelegate> _likesAndCommentsRequestDelegate;
}

@property (nonatomic, retain) PeopleMapDB *peopleMapDB;


- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate;





@end

@protocol LikesAndCommentsRequestDelegate<NSObject>
- (void)likesAndCommentsRequestComplete;
- (void)userRequestFailed;
@end
						  

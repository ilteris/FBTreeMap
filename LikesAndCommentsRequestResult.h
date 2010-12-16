//
//  LikesAndCommentsRequestResult.h
//  TreeMap
//
//  Created by freelancer on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"


@protocol LikesAndCommentsRequestDelegate;

@class ASINetworkQueue;

@interface LikesAndCommentsRequestResult : NSObject<FBRequestDelegate>
{
	NSInteger _categoryMode;
	NSMutableArray *_plistUserArray;
	NSMutableArray *_plistPageArray;
	NSMutableArray *_backgrounds;

	ASINetworkQueue *_networkQueue;
	id<LikesAndCommentsRequestDelegate> _likesAndCommentsRequestDelegate;
}

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate;
- (void)setTheBackgroundArray;
- (NSMutableArray*) spliceArray:(NSMutableArray*)myArray;
- (void) downloadImagesOf:(NSMutableArray*)myArray forPlistArray:(NSMutableArray*)_plistArray writeWithPrefix:(NSString*)pfx;

@end

@protocol LikesAndCommentsRequestDelegate<NSObject>
- (void)likesAndCommentsRequestComplete;
- (void)userRequestFailed;
@end
						  

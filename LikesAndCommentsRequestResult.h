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
	NSMutableArray *_plistArray;
	NSMutableArray *_backgrounds;

	ASINetworkQueue *networkQueue;
	id<LikesAndCommentsRequestDelegate> _likesAndCommentsRequestDelegate;
}

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate;
- (void)setTheBackgroundArray;
- (NSMutableArray*) spliceArray:(NSMutableArray*)myArray;
- (void) downloadImagesForItems:(NSMutableArray*)myArray;

@end

@protocol LikesAndCommentsRequestDelegate<NSObject>
- (void)likesAndCommentsRequestCompleteWithInfo:(NSMutableArray*)info;
- (void)userRequestFailed;
@end
						  

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
	ASINetworkQueue *networkQueue;
	id<LikesAndCommentsRequestDelegate> _likesAndCommentsRequestDelegate;
}

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate andSection:(NSInteger)val;
							  

@end

@protocol LikesAndCommentsRequestDelegate<NSObject>
- (void)likesAndCommentsRequestCompleteWithInfo:(NSMutableArray*)info;
@end
						  

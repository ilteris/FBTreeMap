/*
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "UserRequestResult.h"
#import "FriendsRequestResult.h"
#import "LikesAndCommentsRequestResult.h"


@protocol UserInfoLoadDelegate;

@interface UserInfo : NSObject<FBRequestDelegate, UserRequestDelegate, FriendsRequestDelegate, LikesAndCommentsRequestDelegate> {
	NSString *_uid;
	NSMutableArray * _friendsList;
	
	
	
	NSMutableArray *_friendsInfo;
	NSMutableArray *_likesAndCommentsInfo;
	
	Facebook *_facebook;
	id<UserInfoLoadDelegate> _userInfoDelegate; 
	FBRequest *_reqUid;
	FBRequest *_reqFriendList;
	FBRequest *_reqFriendInfo;
}

@property(nonatomic, retain) id<UserInfoLoadDelegate> userInfoDelegate;
@property(retain, nonatomic) NSString *uid;
@property(retain, nonatomic) NSMutableArray *friendsList;
@property(retain, nonatomic) NSMutableArray *friendsInfo;
@property(retain, nonatomic) NSMutableArray *likesAndCommentsInfo;
@property(retain, nonatomic) Facebook *facebook;

- (void) requestUid;
- (void) requestFriendsDetail;
- (id) initializeWithFacebook:(Facebook *)facebook andDelegate:(id<UserInfoLoadDelegate>)delegate;
- (void) requestAllInfo;
- (void) requestCountOf;
- (void)requestWithGraph:(NSDictionary*)actionDict andAction:(NSString*)action andHttpMethod:(NSString*)httpMethod;

@end

@protocol UserInfoLoadDelegate <NSObject>
@optional
- (void)userInfoDidLoad;
- (void)likesAndCommentsDidLoad;
- (void)userInfoFailToLoad;

@end

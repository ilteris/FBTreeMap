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

#import "UserInfo.h"
#import "FBConnect.h"



@implementation UserInfo

@synthesize facebook = _facebook,
                 uid = _uid,
         friendsList = _friendsList,
         friendsInfo = _friendsInfo,
		likesAndCommentsInfo = _likesAndCommentsInfo,
    userInfoDelegate = _userInfoDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * initialization
 */
- (id) initializeWithFacebook:(Facebook *)facebook andDelegate:(id<UserInfoLoadDelegate>)delegate 
{
  self = [super init];
  _facebook = [facebook retain];
  _userInfoDelegate = [delegate retain];
  return self;
}

- (void)dealloc 
{
  [_facebook release];
  [_uid release];
  [_friendsList release];
  [_friendsInfo release];
  [_userInfoDelegate release];
  [super dealloc];
}

/**
 * Request all info from the user is start with request user id as the authorization flow does not 
 * return the user id. This is an intermediate solution to obtain the logged in user id
 * All other information are requested in the FBRequestDelegate function after Uid obtained. 
 */
- (void) requestAllInfo 
{
	[self requestUid];
	//[self requestCountOf:(NSString*)entity];
}

/**
 * Request the user id of the logged in user.
 *
 * Currently the authorization flow does not return a user id anymore. This is
 * an intermediate solution to get the logged in user id.
 */
- (void) requestUid
{
  UserRequestResult *userRequestResult = 
    [[[[UserRequestResult alloc] initializeWithDelegate:self] autorelease] retain];
  [_facebook requestWithGraphPath:@"me" andDelegate:userRequestResult];
}

/** 
 * Request friends detail information
 *
 * Use FQL to query detailed friends information
 */
- (void) requestFriendsDetail
{
	NSLog(@"requestFriendsDetail");
  FriendsRequestResult *friendsRequestResult = 
    [[[[FriendsRequestResult alloc] initializeWithDelegate:self] autorelease] retain];
   
  NSString *query = @"SELECT uid, name, is_app_user, pic_square, status FROM user WHERE uid IN (";
  query = [query stringByAppendingFormat:@"SELECT uid2 FROM friend WHERE uid1 = %@)", _uid];
  NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  query, @"query",
                                  nil];
  [_facebook requestWithMethodName: @"fql.query" 
                         andParams: params
                     andHttpMethod: @"POST" 
                       andDelegate: friendsRequestResult]; 
}

/** 
 * Request Likes and Comments from stream
 *
 * Use FQL to query detailed friends information
 */

- (void) requestCountOf
{	
	NSLog(@"requestCountOf");
	LikesAndCommentsRequestResult *likesAndCommentsRequestResult = 
	[[[[LikesAndCommentsRequestResult alloc] initializeWithDelegate:self] autorelease] retain];		
				
	// create the multiquery
	NSLog(@"uid %@", _uid);
	NSString* friendIDs = @"SELECT actor_id, post_id,likes, message, comments, permalink, type, attachment FROM stream WHERE source_id IN(";
	friendIDs = [friendIDs stringByAppendingFormat:@"SELECT target_id FROM connection WHERE source_id=%@) AND is_hidden = 0 LIMIT 80", _uid];
	
	NSString* namesAndPics = [NSString stringWithFormat:@"SELECT name, uid FROM user WHERE uid IN (SELECT actor_id FROM #friendIDs) "];
	NSString* queries = [NSString stringWithFormat:@"{\"friendIDs\":\"%@\",\"namesAndPics\":\"%@\"}", friendIDs, namesAndPics];
	
	 
	 NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:queries, @"queries", nil];
	
	// send it out
	[_facebook requestWithMethodName:@"fql.multiquery" 
						  andParams:params 
					  andHttpMethod:@"GET" 
						 andDelegate:likesAndCommentsRequestResult];
}




/**
 * LikesAndCommentsRequestDelegate
 */
- (void)likesAndCommentsRequestCompleteWithInfo:(NSMutableArray*)info
{
	_likesAndCommentsInfo = [info retain];
	NSLog(@"likesAndCommentsRequestCompleteWithInfo %@", info);
	if ([self.userInfoDelegate respondsToSelector:@selector(likesAndCommentsDidLoad)]) 
	{
		[_userInfoDelegate likesAndCommentsDidLoad];
	}
}




/**
 * UID request
 */
- (void)userRequestCompleteWithUid:(NSString *)uid 
{
	self.uid = uid;
	//[self requestCountOf:(NSString*)entity];
 // [self requestFriendsDetail];
	
	if ([self.userInfoDelegate respondsToSelector:@selector(userInfoDidLoad)]) 
	{
		[_userInfoDelegate userInfoDidLoad];
	}
	
	
}



- (void)userRequestFailed 
{	
	NSLog(@"userRequestFailed %@");

	if ([self.userInfoDelegate respondsToSelector:@selector(userInfoFailToLoad)]) 
	{
		[_userInfoDelegate userInfoFailToLoad];
	}
}




/**
 * FriendsRequestDelegate
 */
- (void)FriendsRequestCompleteWithFriendsInfo:(NSMutableArray *)friendsInfo 
{
  _friendsInfo = [friendsInfo retain];
  if ([self.userInfoDelegate respondsToSelector:@selector(userInfoDidLoad)]) 
  {
    [_userInfoDelegate userInfoDidLoad];
  }
}
  
@end

//
//  LikesAndCommentsRequestResult.m
//  TreeMap
//
//  Created by freelancer on 11/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LikesAndCommentsRequestResult.h"
#import "NSMutableArray_Shuffling.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "RegexKitLite.h"


#define numberOfObjects (8)


@implementation LikesAndCommentsRequestResult
@synthesize peopleMapDB = _peopleMapDB;


- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate
{
	self = [super init];
	_likesAndCommentsRequestDelegate = [delegate retain];

	if (!_peopleMapDB) _peopleMapDB = [[PeopleMapDB alloc] initWithFilename:@"p_local6.db"];
	return self;
}


/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
   // NSMutableArray *fruits = [[[NSMutableArray alloc] init] autorelease];
	//NSLog(@"result %@", result);

	
	
	NSArray *streamArray = [NSArray  arrayWithArray:[[result objectAtIndex:0] objectForKey:@"fql_result_set"]];//stream json object
	NSArray *userArray = [NSArray	arrayWithArray:[[result objectAtIndex:2] objectForKey:@"fql_result_set"]];//name/uids json object
	NSArray *pageArray = [NSArray	arrayWithArray:[[result objectAtIndex:1] objectForKey:@"fql_result_set"]];//page/name/page_id
	
	//unfortunately they do have different length since stupidfacebook don't return the same uids twice for the same items in the stream.
	//so in order to fix that, for every stream item, run through the userArray and match the uid and when there's a match, replace the uid with name.
	
	[userArray arrayByAddingObjectsFromArray:pageArray];
	

	
	NSMutableArray *userAndPageArray = [[NSMutableArray alloc] initWithCapacity:1];

	for(NSInteger k=0; k < [userArray count]; k++)
	{	
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [[userArray objectAtIndex:k] objectForKey:@"uid"], @"uid",
							  [[userArray objectAtIndex:k] objectForKey:@"name"], @"name",
							  @"user", @"fromType",
							  nil];
		[userAndPageArray addObject:dict];
	}
	
	
	for(NSInteger k=0; k < [pageArray count]; k++)
	{	
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  [[pageArray objectAtIndex:k] objectForKey:@"page_id"], @"uid",
							  [[pageArray objectAtIndex:k] objectForKey:@"name"], @"name",
							  @"page", @"fromType",
							  nil];
		[userAndPageArray addObject:dict];
	}
	
	//NSLog(@"userAndPageArray is %@", userAndPageArray);

	
	for (NSInteger i=0; i < [streamArray count]; i++)
	{
		//these are the objects for each dictionary item which is going to be written to the plist file.
		NSString *_post_id;
		NSString *_objectType;
		NSNumber *_likeCount;
		NSNumber *_commentCount;
		NSNumber *_poster_id;
		NSString *_poster_name;
		NSString *_poster_type;
		NSString *_message;
		NSString *_description;
		NSString *_link_name;
		NSString *_image_url;
		NSString *_permalink;
		NSString *_href;
		NSNumber *_user_likes;
		NSNumber *_canPostComment;
		NSNumber *_canRemoveComment;
		NSNumber *_posted_time;
		NSNumber *_updated_time;
		
	
		//traverse the user array and match the actor_id ----> uid, then break the for loop;
		for (NSInteger j=0; j < [userAndPageArray count]; j++)
		{

			if([[[streamArray objectAtIndex:i] objectForKey:@"actor_id"] isEqual:[[userAndPageArray objectAtIndex:j] objectForKey:@"uid"]])	
			{ //this gets only called when the actor_id == uid
				_poster_name = [NSString stringWithFormat:@"%@",[[userAndPageArray objectAtIndex:j] objectForKey:@"name"]];
				_poster_type = [NSString stringWithFormat:@"%@", [[userAndPageArray objectAtIndex:j] objectForKey:@"fromType"]];
				break;
			}
		}//endfor
		
				
		//you have figured out the name now. why don't you go ahead and fill other things too, so we have a proper dictionary/arrays.
		_href =				[NSString stringWithFormat:@""];
		_link_name =		[NSString stringWithFormat:@""];
		_description =		[NSString stringWithFormat:@""];
		//first _categoryValue -->count of current displayMode(likes/comments)
		_likeCount =		[NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"count"] integerValue]];
		_user_likes =		[NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"user_likes"] integerValue]];
		
		_commentCount =		[NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"count"] integerValue]];
		_canPostComment =	[NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"can_post"] integerValue]];
		_canRemoveComment = [NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"can_remove"] integerValue]];

		_permalink =		[NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"permalink"]];
		_poster_id =		[NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
		_posted_time =		[NSNumber numberWithInt:[[[streamArray objectAtIndex:i] objectForKey:@"created_time"] integerValue]];
		_updated_time =		[NSNumber numberWithInt:[[[streamArray objectAtIndex:i] objectForKey:@"updated_time"] integerValue]];
		_post_id =			[NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"post_id"]];
		
		NSLog(@"post_id is %@", [NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"post_id"]]);
		
		
		 
		
		//attachment count is more than 1, it could be everything except facebook status according to facebook API
		if([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count] > 1) 
		{
			//if the media array is empty, these are services like links posted in facebook, twitter etc. which we still 
			//need to use the background image because item only have messages and non media array but attachment object.
			
			if (![[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] isKindOfClass:[NSArray class]])
			{
				
				_image_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
				_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
				_objectType = [NSString stringWithFormat:@"status"];
				//NSLog(@"_post_id %@", _post_id);
				//705660968_163532200362253
				//NSLog(@"item is %@", [streamArray objectAtIndex:i]);
				
				_link_name = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"]];
				//NSLog(@"link_name is %@", _link_name);
				
				_description = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"description"]];

			}
			else
			{
				
				//TODO: huffington
				//http://i.huffpost.com/gen/243476/thumbs/s-MUBARAK-large.jpg
				//images coming from huffington posts can be replaced from -small to -large.
				//images coming from NYtimes can be turned into from ---> http://graphics8.nytimes.com/images/2011/02/14/style/14moncler1/14moncler1-thumbStandard-v2.jpg
				//to ---> http://graphics8.nytimes.com/images/2011/02/14/style/14moncler1/14moncler1-popup.jpg
				
				//independent
				//from --> www.independent.co.uk/multimedia/dynamic/00558/bahrain-ambulance_558401a.jpg
				//to --> www.independent.co.uk/multimedia/archive/00558/bahrain-ambulance_558401a.jpg
				//so change from dynamic to archive and add "a" end of jpg file.
				
				//this is all the objects including internal fb events,fb photos,fb videos,fb links, external; youtube, tumblr, facebook apps and external links.
				//their common attribute they all have media.
				//let's do the split here. first check the objects that only have objectType even if they are empty.
				if ([[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"objectType"]) 
				{ 
					//if the value of objectType is more than 0 then this is internal facebook objects including fb videos, fb events, fb photos, fb albums.
					if ([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"objectType"] length] > 0) 
					{ 
						//NSLog(@"facebook events videos photos or albums");
						//NSLog(@"fb object type is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"objectType"] );
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						
						//NSLog(@"internal shit");
						//NSLog(@"objectType is %@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"objectType"] );
						//NSLog(@"attachment media is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"]);
						NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
						_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
						_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
						//if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
						
						if([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"objectType"] isEqual:@"event"])
						{
							_objectType = [NSString stringWithFormat:@"event"];
						}
						else
						{
							_objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
						}
						   
						//NSLog(@"objectType is %@", _objectType);
						//facebook video
						if([_objectType isEqual:@"video"])
						{
							//  NSString *video_source = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"source_url"]];
							_image_url = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
							//for facebook replace _t with _b
							_image_url = [_image_url stringByReplacingOccurrencesOfString:@"_t" withString:@"_b"];
							
							//NSLog(@"objectType image_url  is %@", _image_url);
							//save videos url in _href
							
							NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"source_url"]];
							
							NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
							//get the second url now:
							NSString *regexString   = @"url=(.+)";
							//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
							//sometimes the urls are facebook links so, grab them instead.
							if(![filePath stringByMatching:regexString capture:1L]) 
							{
								_href =  [NSString stringWithFormat:@"%@", _temp];
							}
							else 
							{
								_href = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
							}
						
						}
						_link_name = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"]];
						_description = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"description"]];

						
					}//endif
					else 	//here we know these could either be external links OR youtube videos as long as objectType == @"" && media is an array.
					{
						//we can differentiate between those two by loooking at the attachment>media>type as youtube type == video and external links type == link.
						//NSLog(@"type is %@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]);
						
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						
						
												
						NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
						
						_link_name = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"]];
						_description = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"description"]];

					//	NSLog(@"_link_name is %@", _link_name);

						NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						//get the second url now:
						NSString *regexString   = @"url=(.+)";
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						//sometimes the urls are facebook links so, grab them instead.
						if(![filePath stringByMatching:regexString capture:1L]) 
						{
							_image_url =  [NSString stringWithFormat:@"%@", _temp];
								
							_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
							//	NSLog(@"_image_url is %@", _image_url);
							//_image_url =  [NSString stringWithFormat:@"%@", _temp];
						}
						else 
						{ //nytimes comes here, probably huffington post comes here too.
						
							_image_url = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
						}
						NSString *caption =  [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"caption"]];
						//nytimes regex.
						if([caption isEqual:@"www.nytimes.com"])
						{
							NSString *regexString2  = @"([^/]+\\.jpg)$"; //grabs the last portion of the string
							//../14moncler1-thumbStandard-v2.jpg
							NSString *lastPortion = [NSString stringWithFormat:@"%@", [_image_url stringByMatching:regexString2 capture:1L]];
							NSString *regexString3  = @"(-.*\\.jpg)$";
							//match anything after first dash if there's one. --> -thumbStandard-v2.jpg
							NSString *new_lastPart  = [lastPortion stringByReplacingOccurrencesOfRegex:regexString3 withString:@"-popup.jpg"];
							//replace the last part with new last part.
							NSString *temp_image_url  = [_image_url stringByReplacingOccurrencesOfRegex:regexString2 withString:new_lastPart];
							_image_url = temp_image_url;
						}//endif
						
						
						
						_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
						
						///NSLog(@"_message is %@", _message);
						//NSLog(@"_message count is %i", [_message length]);
						//if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
						//NSLog(@"_message is %@", _message);
						
						
						_objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
						
						if([_objectType isEqual:@"video"])
						{
							_href = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"source_url"]];
							
							
							NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"] ];
							
							NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
							//get the second url now:
							NSString *regexString   = @"url=(.+)";
							//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
							//sometimes the urls are facebook links so, grab them instead.
							//also there are some stupid youtubevideos that don't have caption... so need to check them out too. and grab their preview_image 
													
							
							NSString *caption =  [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"caption"]];
							if([caption isEqual:@"www.youtube.com"])
							{
								
								//do the youtube things here.
								if([filePath stringByMatching:regexString capture:1L]) 
								{
									//NSLog(@"youtube before %@", _image_url);
									NSString *regexString2  = @"([^/]+\\.jpg)$";
									//change all the last portion /x.jpg to ---> /0.jpg
									NSString *source_string = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
									_image_url  = [source_string stringByReplacingOccurrencesOfRegex:regexString2 withString:@"0.jpg"];
									
									//	NSLog(@"youtube after %@", _image_url);
								}//endif
							}//endif
							else
							{
								if([filePath stringByMatching:regexString capture:1L]) 
								{
									//  NSLog(@"non youtube true %@", _image_url);
									_image_url =  [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
								}//endif
							}//endelse
						}//endif
						else if([_objectType isEqual:@"link"])
						{
							
							_href = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"href"]];
						}
						
						
												
						
					}//endelse

				//	NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
				}//endif
				else //this is most probably an tumblr, instagram, foursquare or a facebook app so expect images as app icons map icons etc... sometimes youtube video and fb page is too!
				{
					//still getting only up to name ---> if that's empty maybe even go further up to description?
					
					//NSLog(@"attachment media is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"]);
					
                    
					
					NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
					
					NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					//get the second url now:
					NSString *regexString   = @"src=(.+)";
					//also you can use look behind assertation.
					//(?<=url=).+
					//NSString *_src   = [filePath stringByMatching:regexString capture:1L];
					//NSLog(@"regexString is ----> %@", _src);
					//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
					//no second src
					if(![filePath stringByMatching:regexString capture:1L]) 
					{
						_image_url =  [NSString stringWithFormat:@"%@", _temp];
						
						_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
						
						//	NSLog(@"_image_url is %@", _image_url);
						//_image_url =  [NSString stringWithFormat:@"%@", _temp];
					}
					else 
					{
						_image_url = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
                        _image_url = [_image_url stringByReplacingOccurrencesOfString:@"_s" withString:@""];
						_image_url = [_image_url stringByReplacingOccurrencesOfString:@"s72-c" withString:@"s1600"];
						
					}
					
					//NSLog(@"_image_url is %@", _image_url);
					
					//blogpost hack
					_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
					
					//if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
					_link_name = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"]];
					_description = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"description"]];

					
                    _objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
					
					
					if([_objectType isEqual:@"link"])
                    {
						// NSLog(@"poster_name %@", _poster_name);
						
                        if([_href length] == 0) _href = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"href"]];
						// NSLog(@"href is %@", _href);
                    }
					else if([_objectType isEqual:@"video"])
					{
						//  NSString *video_source = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"source_url"]];
						NSString *temp_href = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"source_url"]];
						_temp = [temp_href stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

						
						NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"video"] objectForKey:@"preview_img"]];
						
						NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						//get the second url now:
						NSString *regexString   = @"src=(.+)";
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						//sometimes the urls are facebook links so, grab them instead.
						if(![filePath stringByMatching:regexString capture:1L]) 
						{
							_image_url =  [NSString stringWithFormat:@"%@", _temp];
						}
						else 
						{
								//NSLog(@"youtube before %@", _image_url);
								NSString *regexString2  = @"([^/]+\\.jpg)$";
								//change all the last portion /x.jpg to ---> /0.jpg
								NSString *source_string = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
								_image_url  = [source_string stringByReplacingOccurrencesOfRegex:regexString2 withString:@"0.jpg"];
						}
						NSLog(@"_image_url %@", _image_url);
					}//endelseif
				}//endelse
				
			}//endelse
			
		//	NSLog(@"from is %@", _from);
		//	NSLog(@"categoryValue is %@", _categoryValue);
			
			//_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];

			//if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
			//TODO: if message or _link_name is null, just make sure to send empty string with them.
			

			
			
		}//endif
		else //attachment count == 1, this one could be facebook status, so need to separate between those: grab the profile images here but use the background images instead for displaying.
		{
		//	NSLog(@"from is %@", _from);
		//	NSLog(@"categoryValue is %@", _categoryValue);

			_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
		//	NSLog(@"message is 2 %@", _message);
			if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];

		//	NSLog(@"message is 3 %@", _message);
			_image_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
			_objectType = [NSString stringWithFormat:@"status"];
		}//endelse
		
    		
		/*
		 // Dictionary keys
		*/

      //  NSLog(@"dict is %@", _href);

		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _post_id, @"post_id",
							  _objectType, @"objectType", 
							  _likeCount, @"likeCount", 
							  _commentCount, @"commentCount",
							  _poster_id, @"poster_id",
							  _poster_name, @"poster_name",
							  _poster_type, @"poster_type",
							  _user_likes, @"user_likes",
							  _canPostComment, @"canPostComment",
							  _canRemoveComment, @"canRemoveComment",
							  _message, @"message",
							  _link_name, @"link_name",
							  _description, @"description",
                              _href, @"href",
							  _permalink, @"permalink",
							  _image_url, @"image_url",
							  _posted_time, @"posted_time",
							  _updated_time, @"updated_time",
							  nil];
		
		[_peopleMapDB addItemRow:dict];
		NSLog(@"dict is %@", dict);
	}//endfor
	[_likesAndCommentsRequestDelegate likesAndCommentsRequestComplete];

	//[self downloadAndWriteImageFiles];
	
	
		    
}//endfunction


- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	NSLog(@"%@",[error localizedDescription]);
	[_likesAndCommentsRequestDelegate userRequestFailed];
}




#pragma mark imageDownload Delegates 

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	
	
}//endfunction



- (void)imageFetchFailed:(ASIHTTPRequest *)request
{
	/*
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}		failed = YES;
	}
	 */
}


- (void)queueComplete:(ASINetworkQueue*)queue
{
	NSLog(@"Queue finished");
	
	//imagesLoaded = YES;
	
	
	//NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistFile]; 
	//plist file consists of objects of dictionaries wrapped in an array
	
	//NSLog(@"self._plistUserArray %@", _plistUserArray);
	//NSLog(@"self._plistPageArray %@", _plistPageArray);
	//[_plistUserArray writeToFile:plistFileForUsers atomically:NO];
	//[_plistPageArray writeToFile:plistFileForPages atomically:NO];
	
	//[(TreemapView *)self.treeMapView reloadData];
	
	//before I was passing the plist array back to the userInfo from here using the delegate, but what's the necessaty of this, plus I do have a few plist file now, so I am not sending it anymore.
	
}



@end

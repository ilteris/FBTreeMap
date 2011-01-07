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
	[self setTheBackgroundArray];
	if (!_peopleMapDB) _peopleMapDB = [[PeopleMapDB alloc] initWithFilename:@"p_local.db"];
	

	return self;
}


/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
   // NSMutableArray *fruits = [[[NSMutableArray alloc] init] autorelease];
//	NSLog(@"result %@", result);

	
	
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

	
	
	//let's init the arrays to be used for temporary plist holders
	NSMutableArray *userPlistArray = [[NSMutableArray alloc] initWithCapacity:1];
	NSMutableArray *pagePlistArray = [[NSMutableArray alloc] initWithCapacity:1];
	
	
	

	
	
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
		NSString *_image_url;
		NSString *_permalink;
		NSNumber *_posted_time;
		NSNumber *_updated_time;
		
		
		
		/*
		 NSString *_from;
		 NSString *_categoryValue;
		 NSString *_actor_id;
		 NSString *_image_url;
		 NSString *_message;
		 NSString *_post_id;
		 NSString *_type;
		 NSString *_fromType;
		 */
		
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
		
		//first _categoryValue -->count of current displayMode(likes/comments)
		
		_likeCount = [NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"count"] integerValue]];
		_commentCount = [NSNumber numberWithInt:[[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"count"] integerValue]];
		_permalink = [NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"permalink"]];

		//NSString *_post_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"post_id"]];
		//NSString *_from = [NSString stringWithFormat:@"%@",[[userArray objectAtIndex:j] objectForKey:@"name"]];
		//NSString *_type;
		//NSString *_src;
		//NSString *_img_url;
		
		//NSLog(@"attachment count is %i", [[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count]);

		_poster_id =		[NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
		_posted_time =		[NSNumber numberWithInt:[[[streamArray objectAtIndex:i] objectForKey:@"created_time"] integerValue]];
		_updated_time =		[NSNumber numberWithInt:[[[streamArray objectAtIndex:i] objectForKey:@"updated_time"] integerValue]];
		_post_id =			[NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"post_id"]];
		
		//NSLog(@"post_id is %@", [NSString stringWithFormat:@"%@", [[streamArray objectAtIndex:i] objectForKey:@"post_id"]]);
		
		//attachment count is more than 1, it could be everything except facebook status according to facebook API
		if([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count] > 1) 
		{
			//if the media array is empty, these are services which we still need to use the background image because item only have messages and zero media. 
			if (![[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] isKindOfClass:[NSArray class]])
			{
				_image_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
				_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
				_objectType = [NSString stringWithFormat:@"status"];
			}
			else
			{ //this is all the objects including internal fb events,fb photos,fb videos,fb links, external; youtube, tumblr, facebook apps and external links.
				//their common attribute they all have media.
				//let's do the split here. first check the objects that only have fb_object_type even if they are empty.
				if ([[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"fb_object_type"]) 
				{ 
					//if the value of fb_object_type is more than 0 then this is internal facebook objects including fb videos, fb events, fb photos, fb albums.
					if ([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"fb_object_type"] length] > 0) 
					{ 
						//NSLog(@"fb object type is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"fb_object_type"] );
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						
						//NSLog(@"internal shit");
						//NSLog(@"fb_object_type is %@",[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"fb_object_type"] );
						//NSLog(@"attachment media is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"]);
						NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
						_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
						_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
						if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
						_objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
					}//endif
					else 	//here we know these could either be external links OR youtube videos as long as fb_object_type == @"" && media is an array.
					{
						//we can differentiate between those two by loooking at the attachment>media>type as youtube type == video and external links type == link.
						//NSLog(@"type is %@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]);
						
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						
						

						NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
						
						NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						//get the second url now:
						NSString *regexString   = @"url=(.+)";
						//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
						//sometimes the urls are facebook links so, grab them instead.
						if(![filePath stringByMatching:regexString capture:1L]) 
						{
							_image_url =  [NSString stringWithFormat:@"%@", _temp];
						//	NSLog(@"_image_url is %@", _image_url);
							_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
						//	NSLog(@"_image_url is %@", _image_url);
							//_image_url =  [NSString stringWithFormat:@"%@", _temp];
						}
						else 
						{
							_image_url = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
						}

						
						
						_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
						
						///NSLog(@"_message is %@", _message);
						//NSLog(@"_message count is %i", [_message length]);
						if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
						//NSLog(@"_message is %@", _message);
						
						_objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
						
												
						
					}//endelse

				//	NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
				}//endif
				else //this is most probably an tumblr, instagram, foursquare or a facebook app so expect images as app icons map icons etc... sometimes page is too!
				{
					//still getting only up to name ---> if that's empty maybe even go further up to description?
					
				//	NSLog(@"attachment media is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"]);
					
					
					NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
					
					NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					//get the second url now:
					NSString *regexString   = @"src=(.+)";
					//also you can use look behind assertation.
					//(?<=url=).+
					//NSString *_src   = [filePath stringByMatching:regexString capture:1L];
					//NSLog(@"regexString is ----> %@", _src);
					//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
					if(![filePath stringByMatching:regexString capture:1L]) 
					{
						_image_url =  [NSString stringWithFormat:@"%@", _temp];
						//	NSLog(@"_image_url is %@", _image_url);
						_image_url = [_temp stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"];
						//	NSLog(@"_image_url is %@", _image_url);
						//_image_url =  [NSString stringWithFormat:@"%@", _temp];
					}
					else 
					{
						_image_url = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
					}
					
					_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
					
					if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
					_objectType = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
					
					
				}//endelse
				
			}
			
		//	NSLog(@"from is %@", _from);
		//	NSLog(@"categoryValue is %@", _categoryValue);
			
			//_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
		//	NSLog(@"message is 2 %@", _message);
			if([_message length] == 0) _message = [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"name"];
			
		//	NSLog(@"message is 3 %@", _message);
			
			
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
			
		[_peopleMapDB addItemRow:[NSDictionary dictionaryWithObjectsAndKeys:
								_post_id, @"post_id",
								_objectType, @"objectType", 
								_likeCount, @"likeCount", 
								_commentCount, @"commentCount",
								_poster_id, @"poster_id",
								_poster_name, @"poster_name",
								_poster_type, @"poster_type",
								_message, @"message",
								_permalink, @"permalink",
								_image_url, @"image_url",
								_posted_time, @"posted_time",
								_updated_time, @"updated_time",
							  nil]];
		
		
		
		
		//@@@@@@@ 0- split them pages and users separately, why? because we are going to be writing them separately to the filesystem.
		/*
		if([_fromType isEqual:@"user"])
		{
			[userPlistArray addObject:dict];
		}
		else 
		{
			[pagePlistArray addObject:dict];
		}
   
		*/

	}//endfor
	
	
	//NSLog(@"pagePlistArray is %@", pagePlistArray);
	//NSLog(@"userPlistArray is %@", userPlistArray);
	//
	
	//@@@@@@@ 1- filter and splice;	
	NSMutableArray* newUserPlistArray = [[self spliceArray:userPlistArray] retain];
	NSMutableArray* newPagePlistArray = [[self spliceArray:pagePlistArray] retain];
	[userPlistArray release];
	[pagePlistArray release];
	
	
//	NSLog(@"newUserPlistArray is %@", newUserPlistArray);
//	NSLog(@"newPagePlistArray is %@", newPagePlistArray);
	//@@@@@@@ 2- setup the queue.

	
	if (!_networkQueue) {
		_networkQueue = [[ASINetworkQueue alloc] init];	
	}
	
	//failed = NO;
	[_networkQueue reset];
	//[networkQueue setDownloadProgressDelegate:progressIndicator];
	[_networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
	[_networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
	[_networkQueue setQueueDidFinishSelector:@selector(queueComplete:)]; 
	//[networkQueue setShowAccurateProgress:[accurateProgress isOn]];
	[_networkQueue setDelegate:self];
	
	
	[_networkQueue go];
	
	
	
	//@@@@@@@ 3- setup the arrays that will be written.

	
	
	//@@@@@@@ 3- download the images.
	
	if(_plistUserArray == nil) //check if the plist is empty 
	{ 
		_plistUserArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init	
	}
	
	
	if(_plistPageArray == nil) //check if the plist is empty 
	{ 
		_plistPageArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init	
	}
	
	
	
	//[self downloadImagesOf:newUserPlistArray forPlistArray:_plistUserArray writeWithPrefix:@"u"];
	//[self downloadImagesOf:newPagePlistArray forPlistArray:_plistPageArray writeWithPrefix:@"p"];
	//[self downloadImagesForItems:newPagePlistArray];
	
	
	    
}//endfunction


- (NSMutableArray*) spliceArray:(NSMutableArray*)myArray
{
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryValue" ascending: NO];
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
	[myArray sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	[sortDescriptor release];
	
	
	
	
	// here  we are getting rid of the rest of the objects after numberOfObjects
	//check if the array is larger than numberof Objects
	
	
	if ([myArray count] >= numberOfObjects) 
	{
		[myArray removeObjectsInRange: NSMakeRange(numberOfObjects,[myArray count]-numberOfObjects)];
	}

	return myArray;
}//endfunction



- (void) downloadImagesOf:(NSMutableArray*)myArray forPlistArray:(NSMutableArray*)_plistArray writeWithPrefix:(NSString*)pfx
{
	ASIHTTPRequest *req;
	
	for (NSInteger i = 0; i < [myArray count]; i++)
	{
		//don't request to download any image because we are using background images locally with STATUS.
		if([[[myArray objectAtIndex:i] objectForKey:@"type"] isEqual:@"status"])
		{
			NSLog(@"this should be status");
			NSInteger rand_ind = arc4random() % [_backgrounds count];
			NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_backgrounds objectAtIndex:rand_ind]  ofType:@"png"]];
			[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i.png",pfx,i]] atomically:YES];
			NSString *tempFileName = [NSString stringWithFormat:@"%@_%i.png",pfx,i];
			[_backgrounds removeObjectAtIndex:rand_ind];
			if([_backgrounds count] < 1) [self setTheBackgroundArray]; //if the backgroundarray gets empty, refill it.
			
			if(![[[myArray objectAtIndex:i]  objectForKey:@"categoryValue"] isEqual:@"0"]) 
			{
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  [[myArray objectAtIndex:i]  objectForKey:@"from"], @"from",
									  [[myArray objectAtIndex:i]  objectForKey:@"categoryValue"], @"categoryValue", 
									  tempFileName, @"filename",
									  //[[myArray objectAtIndex:i]  objectForKey:@"image_url"], @"image_url",
									  [[myArray objectAtIndex:i]  objectForKey:@"message"], @"message",
									  [[myArray objectAtIndex:i]  objectForKey:@"post_id"], @"post_id",
									  [[myArray objectAtIndex:i]  objectForKey:@"type"], @"type",
									  [[myArray objectAtIndex:i]  objectForKey:@"fromType"], @"fromType",
									  nil];
				
				//adding to the plistArray here.
				[_plistArray insertObject:dict atIndex:0];
				//	NSLog(@"dict %@", dict);	
			}
			
		}
		else if([[[myArray objectAtIndex:i] objectForKey:@"type"] isEqual:@"video"])	
		{
			//don't request to load any image here, only load VIDEO Background since they are videos.
			NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video"  ofType:@"png"]];
			[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i.png",pfx,i]] atomically:YES];
			NSString *tempFileName = [NSString stringWithFormat:@"%@_%i.png",pfx,i];
			
			
			if(![[[myArray objectAtIndex:i]  objectForKey:@"categoryValue"] isEqual:@"0"]) 
			{
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  [[myArray objectAtIndex:i]  objectForKey:@"from"], @"from",
									  [[myArray objectAtIndex:i]  objectForKey:@"categoryValue"], @"categoryValue", 
									  tempFileName, @"filename", 
									  //[[myArray objectAtIndex:i]  objectForKey:@"image_url"], @"image_url",
									  [[myArray objectAtIndex:i]  objectForKey:@"message"], @"message",
									  [[myArray objectAtIndex:i]  objectForKey:@"post_id"], @"post_id",
									  [[myArray objectAtIndex:i]  objectForKey:@"type"], @"type",
									  [[myArray objectAtIndex:i]  objectForKey:@"fromType"], @"fromType",
									  nil];
				
				//adding to the plistArray here.
				[_plistArray insertObject:dict atIndex:0];
				//	NSLog(@"dict %@", dict);	
			}
			
		}
		else 
		{
			
			//load the images for everything except status and video.
			req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[myArray objectAtIndex:i] objectForKey:@"image_url"]]] autorelease];
			[req setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:i], @"ImageNumber", //send the index number to use in the imageFetch delegate method.
							  // [[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"], @"tempArr",
							  // [[tempArr objectAtIndex:1] objectForKey:@"fql_result_set"], @"names",
							  pfx, @"pfx",
							  [myArray objectAtIndex:i], @"item", //send the item itself.
							  _plistArray, @"array",
							  nil]]; 
			[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i.png",pfx,i]]];
			[_networkQueue addOperation:req];
		}//endelse
	}//endfor
	
}


- (void)setTheBackgroundArray
{
	_backgrounds = [[NSMutableArray alloc] initWithCapacity:1];
	NSString *b0 = [NSString stringWithFormat:@"concrete"];
	NSString *b1 = [NSString stringWithFormat:@"leather"];
	//	NSString *b2 = [NSString stringWithFormat:@"play"];
	NSString *b3 = [NSString stringWithFormat:@"rust"];
	//NSString *b4 = [NSString stringWithFormat:@"video"];
	NSString *b5 = [NSString stringWithFormat:@"wood"];
	
	[_backgrounds addObject:b0];
	[_backgrounds addObject:b1];
	//	[_backgrounds addObject:b2];
	[_backgrounds addObject:b3];
	//	[_backgrounds addObject:b4];
	[_backgrounds addObject:b5];
	
}



- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	NSLog(@"%@",[error localizedDescription]);
	[_likesAndCommentsRequestDelegate userRequestFailed];
}




#pragma mark imageDownload Delegates 

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	
	UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
	if (img) 
	{
		int imageNo =  [[[request userInfo] objectForKey:@"ImageNumber"] intValue]; 
		
		NSMutableArray* _plistArray = [[request userInfo] objectForKey:@"array"];
		
		NSString *tempFileName = [NSString stringWithFormat:@"%@_%i.png",[[request userInfo] objectForKey:@"pfx"],imageNo];
		NSString *_categoryValue;
		NSString *_message;
		NSString *_from;
		NSString *_type;
		NSString *_post_id;
		NSString *_fromType;
		
	//	NSLog(@"_plistArray is %@", _plistArray);
		
		
		_categoryValue =	[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"categoryValue"]];
		_from =				[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"from"]];
		_message =			[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"message"]];
		_type =				[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"type"]];
		_post_id =			[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"post_id"]];
		_fromType =			[NSString stringWithFormat:@"%@",[[[request userInfo] objectForKey:@"item"] objectForKey:@"fromType"]];

		
		//if the results are 0 then don't put those in the plist file.
		//NSLog(@"names is %@", [[request userInfo] objectForKey:@"names"]);
		if(![_categoryValue isEqual:@"0"]) 
		{
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  tempFileName, @"filename", 
								  _categoryValue, @"categoryValue", 
								  _from, @"from",
								  _message, @"message",
								  _type, @"type",
								  _post_id, @"post_id",
								  _fromType, @"fromType",
								  nil];
			
			//adding to the plistArray here.
			[_plistArray insertObject:dict atIndex:0];
		//	NSLog(@"dict %@", dict);	
		}//endif
	}//endif
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
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex: 0];
	NSString *plistFileForUsers = [documentsDirectory stringByAppendingPathComponent: @"userData.plist"];
	NSString *plistFileForPages = [documentsDirectory stringByAppendingPathComponent: @"pageData.plist"];
	//NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistFile]; 
	//plist file consists of objects of dictionaries wrapped in an array
	
	//NSLog(@"self._plistUserArray %@", _plistUserArray);
	//NSLog(@"self._plistPageArray %@", _plistPageArray);
	[_plistUserArray writeToFile:plistFileForUsers atomically:NO];
	[_plistPageArray writeToFile:plistFileForPages atomically:NO];
	
	//[(TreemapView *)self.treeMapView reloadData];
	
	//before I was passing the plist array back to the userInfo from here using the delegate, but what's the necessaty of this, plus I do have a few plist file now, so I am not sending it anymore.
	[_likesAndCommentsRequestDelegate likesAndCommentsRequestComplete];
	
}



@end

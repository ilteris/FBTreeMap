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
#import "FbGraph.h"
#import "RegexKitLite.h"


#define numberOfObjects (8)


@implementation LikesAndCommentsRequestResult

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate
{
	self = [super init];
	_likesAndCommentsRequestDelegate = [delegate retain];
	[self setTheBackgroundArray];	

	return self;
}

/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
   // NSMutableArray *fruits = [[[NSMutableArray alloc] init] autorelease];
//	NSLog(@"result %@", result);
	NSMutableArray *tempArr = [result mutableCopy];
	
	
	NSArray *streamArray = [NSArray  arrayWithArray:[[result objectAtIndex:0] objectForKey:@"fql_result_set"]];//stream json object
	NSArray *userArray = [NSArray	arrayWithArray:[[result objectAtIndex:1] objectForKey:@"fql_result_set"]];//name/uids json object
	
	//unfortunately they do have different length since stupidfacebook don't return the same uids twice for the same items in the stream.
	//so in order to fix that, for every stream item, run through the userArray and match the uid and when there's a match, replace the uid with name.
	
	NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:1];
	//NSLog(@"streamArray %@", streamArray);
	//NSLog(@"userArray %@", userArray);
	
	
	
	for (NSInteger i=0; i < [streamArray count]; i++)
	{
		//these are the objects for each dictionary item which is going to be written to the plist file.
		NSString *_from;
		NSString *_categoryValue;
		NSString *_actor_id;
		NSString *_image_url;
		NSString *_message;
		NSString *_post_id;
		NSString *_type;
		
		
		//traverse the user array and match the actor_id ----> uid, then break the for loop;
		for (NSInteger j=0; j < [userArray count]; j++)
		{
			if([[[streamArray objectAtIndex:i] objectForKey:@"actor_id"] isEqual:[[userArray objectAtIndex:j] objectForKey:@"uid"]])	
			{ //this gets only called when the actor_id == uid
				_from = [NSString stringWithFormat:@"%@",[[userArray objectAtIndex:j] objectForKey:@"name"]];
				
				break;
			}
		}//endfor
		
		//you have figured out the name now. why don't you go ahead and fill other things too, so we have a proper dictionary/arrays.
		
		//first _categoryValue -->count of current displayMode(likes/comments)
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
		{
			_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"count"]];
		}
		else //displayMode is 1//comments 
		{
			_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"count"]];
		}//endelse

		


		//NSString *_post_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"post_id"]];
		//NSString *_from = [NSString stringWithFormat:@"%@",[[userArray objectAtIndex:j] objectForKey:@"name"]];
		//NSString *_type;
		//NSString *_src;
		//NSString *_img_url;
		
		//NSLog(@"attachment count is %i", [[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count]);

		_actor_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
		_post_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"post_id"]];
		
		//attachment count is more than 1, it could be everything except facebook status according to facebook API
		if([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count] > 1) 
		{
			//if the media array is empty, these are services which we still need to use the background image because item only have messages and zero media. 
			if (![[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] isKindOfClass:[NSArray class]])
			{
				_image_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
				_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
				_type = [NSString stringWithFormat:@"status"];
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
						_type = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];

						
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
						
						_type = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
						
												
						
					}//endelse

				//	NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
				}//endif
				else //this is most probably an tumblr, instagram, foursquare or a facebook app so expect images as app icons map icons etc...
				{
					//TODO: right now if the message is empty, it's empty, but it could be improved try to get the name if msg is empty and if name empty, get caption etc. 
					
					NSString *_temp = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"src"]];
					
					NSString *filePath = [_temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					//get the second url now:
					NSString *regexString   = @"src=(.+)";
					//also you can use look behind assertation.
					//(?<=url=).+
					//NSString *_src   = [filePath stringByMatching:regexString capture:1L];
					//NSLog(@"regexString is ----> %@", _src);
					//NSLog(@"count one %@", [streamArray objectAtIndex:i] );
					
					_image_url = [NSString stringWithFormat:@"%@", [filePath stringByMatching:regexString capture:1L]];
					_message =   [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
					_type = [NSString stringWithFormat:@"%@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
					
					
				}//endelse
				
	
			}
		
		}//endif
		else //attachment count == 1, this one could be facebook status, grab the profile images here but use the background images instead for displaying.
		{
			
			_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
			_image_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
			_type = [NSString stringWithFormat:@"status"];
		}//endelse
		
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  _from, @"from",
							  _categoryValue, @"categoryValue", 
							  _actor_id, @"actor_id", 
							  _image_url, @"image_url",
							  _message, @"message",
							  _post_id, @"post_id",
							  _type, @"type",
							  nil];
		
	//	NSLog(@"dictionary is %@", dict);
		
		[myArray addObject:dict];
	}//endfor
	
	
	
	//NSLog(@"result %@", result);
	//@@@@@@@ 1- filter and splice!

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryValue" ascending: NO];
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
	[myArray sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	[sortDescriptor release];
	
	//NSLog(@"names %@", [[tempArr objectAtIndex:1] objectForKey:@"fql_result_set"]);

	// here  we are getting rid of the rest of the objects after numberOfObjects
	//check if the array is larger than numberof Objects

	
	if ([myArray count] >= numberOfObjects) 
	{
		[myArray removeObjectsInRange: NSMakeRange(numberOfObjects,[myArray count]-numberOfObjects)];
	}
	/*
	if ([[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] count] >= numberOfObjects) 
	{
		[[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] removeObjectsInRange: NSMakeRange(numberOfObjects,[[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] count]-numberOfObjects)];
	}
	 */
	
	//NSLog(@"myArray: %@", myArray);
	
	[tempArr autorelease];
    
	//@@@@@@@ 2- shuffle!
	//[tempArr shuffle];
	
	//@@@@@@@ 3- download the images.
	//imagesLoaded = NO;
	
	//NSLog(@"tempArr %@", tempArr);
	
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];	
	}
	
	//failed = NO;
	[networkQueue reset];
	//[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
	[networkQueue setQueueDidFinishSelector:@selector(queueComplete:)]; 
	//[networkQueue setShowAccurateProgress:[accurateProgress isOn]];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *req;
	[networkQueue go];
	
		
	
	
	if(_plistArray == nil) //check if the plist is empty 
	{ 
		_plistArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init
		
	}
	
	
	
	
	for (NSInteger i = 0; i < [myArray count]; i++)
	{
		//preparing images for ASIHTTPRequest
		//TODO: need to convert this so, it brings back the urls for the larger images.
		//might need to use the REST API for this!
		
		//NSLog(@"type should be %@", [[myArray objectAtIndex:i] objectForKey:@"type"] );
		//NSLog(@"src should be %@", [[myArray objectAtIndex:i] objectForKey:@"src"] );
		
		
		//NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[myArray objectAtIndex:i] objectForKey:@"actor_id"] ];

		if([[[myArray objectAtIndex:i] objectForKey:@"type"] isEqual:@"status"])
		{
			//don't request to load any image here
			
			NSLog(@"this should be status");
			NSInteger rand_ind = arc4random() % [_backgrounds count];
			
	
			
			NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_backgrounds objectAtIndex:rand_ind]  ofType:@"png"]];
			
	
			[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i]] atomically:YES];
			
			NSString *tempFileName = [NSString stringWithFormat:@"%i.png",i];
			
			[_backgrounds removeObjectAtIndex:rand_ind];
			
			if([_backgrounds count] < 1) [self setTheBackgroundArray];
			
			
			
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
									  nil];
				
				//adding to the plistArray here.
				[_plistArray insertObject:dict atIndex:0];
				NSLog(@"dict %@", dict);	
			}
			
			
			
			
			
		}
		else if([[[myArray objectAtIndex:i] objectForKey:@"type"] isEqual:@"video"])	
		{
			//don't request to load any image here
			NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video"  ofType:@"png"]];
			
			
			[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i]] atomically:YES];
			NSString *tempFileName = [NSString stringWithFormat:@"%i.png",i];

			
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
									   nil];
				
				//adding to the plistArray here.
				[_plistArray insertObject:dict atIndex:0];
				NSLog(@"dict %@", dict);	
			}
		
		}
		else 
		{
			//load the images.
			req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[myArray objectAtIndex:i] objectForKey:@"image_url"]]] autorelease];
			[req setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:i], @"ImageNumber", 
							  // [[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"], @"tempArr",
							  // [[tempArr objectAtIndex:1] objectForKey:@"fql_result_set"], @"names",
							  myArray, @"myArray",
							  nil]]; 
			[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i]]];
			[networkQueue addOperation:req];
			
		}
	
		
		

	}    
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
		
		//NSLog(@"request %@", [request userInfo] );
	
		
		NSString *tempFileName = [NSString stringWithFormat:@"%i.png",imageNo];
		NSString *_categoryValue;
		NSString *_message;
		NSString *_from;
		NSString *_type;
		NSString *_post_id;
		
		if(_plistArray == nil) //check if the plist is empty 
		{ 
			_plistArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init
			
		}
		
		
		//below we should get the type of the posts and then push background or something as the image.
		
		
		
		_categoryValue = [NSString stringWithFormat:@"%@",[[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"categoryValue"]];
		//likeKey = [NSString stringWithFormat:@"likes"];
		
		//NSLog(@" _message is %@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"message"] );			
		_from = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"from"]];

		_message = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"message"]];
		_type = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"type"]];
		_post_id = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"post_id"]];

	
		//NSLog(@" _message is %@", _message);
		
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
								  nil];
			
			//adding to the plistArray here.
			[_plistArray insertObject:dict atIndex:0];
			NSLog(@"dict %@", dict);	
		}
	}
	
}



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
	NSString *plistFile = [documentsDirectory stringByAppendingPathComponent: @"data.plist"];
	//NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistFile]; 
	//plist file consists of objects of dictionaries wrapped in an array
	
	//NSLog(@"self.plistArray %@", _plistArray);
	[_plistArray writeToFile:plistFile atomically:NO];
	//[(TreemapView *)self.treeMapView reloadData];
	[_likesAndCommentsRequestDelegate likesAndCommentsRequestCompleteWithInfo:_plistArray];
	
}





@end

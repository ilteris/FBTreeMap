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

#define numberOfObjects (8)


@implementation LikesAndCommentsRequestResult

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate
{
	self = [super init];
	_likesAndCommentsRequestDelegate = [delegate retain];
	return self;
}

/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
   // NSMutableArray *fruits = [[[NSMutableArray alloc] init] autorelease];
	//NSLog(@"result %@", result);
	NSMutableArray *tempArr = [result mutableCopy];
//	NSMutableArray *myArray = [[NSArray alloc] initWithCapacity:1];
	
	
	
	NSArray *userArray = [NSArray	arrayWithArray:[[result objectAtIndex:1] objectForKey:@"fql_result_set"]];
	NSArray *streamArray = [NSArray  arrayWithArray:[[result objectAtIndex:0] objectForKey:@"fql_result_set"]];
	
	NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:1];
	//NSLog(@"streamArray %@", streamArray);
//	NSLog(@"userArray %@", userArray);
	
	
	for (NSInteger i=0; i < [streamArray count]; i++)
	{
		//NSLog(@"1starr uid number is %@", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]);
		for (NSInteger j=0; j < [userArray count]; j++)
		{

			//NSLog(@"2ndarr uid number is %@", [[userArray objectAtIndex:j] objectForKey:@"uid"]);

			if([[[streamArray objectAtIndex:i] objectForKey:@"actor_id"] isEqual:[[userArray objectAtIndex:j] objectForKey:@"uid"]])	
			{
				//NSLog(@"true it's number ");
				NSString *_categoryValue;
				

				if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
				{
				//		NSLog(@"displayMode is 0");		
					if (!_categoryValue)
					{
						_categoryValue = [NSString stringWithFormat:@"0"];
					}
					else
					{
						_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"count"]];
						
					}
				
				}
				else //displayMode is 1//comments 
				{
				//	NSLog(@"displayMode is 1");
					if (!_categoryValue)
					{
						_categoryValue = [NSString stringWithFormat:@"0"];
					}
					else
					{
						_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"count"]];
					}
	
				}
				NSString *_actor_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
				NSString *_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
				NSString *_from = [NSString stringWithFormat:@"%@",[[userArray objectAtIndex:j] objectForKey:@"name"]];
				NSString *_type;
				
				NSLog(@"attachment count is %i", [[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count]);
				//if the count is more than 1, it means it's not status. 
				
				
				if([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] allKeys] count] != 1) //meaning it's not status
				
				{
					
					//let's see how many of them have array.
					if ([[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] isKindOfClass:[NSArray class]])
					{
						//NSLog(@"attachment media is %@", [[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"]);
						NSLog(@"type is %@", [[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]);
						_type = [NSString stringWithFormat:@"%@",[[[[[streamArray objectAtIndex:i] objectForKey:@"attachment"] objectForKey:@"media"] objectAtIndex:0] objectForKey:@"type"]];
						NSLog(@"array");
					}
					
					else
					{
						NSLog(@"not an array");
						NSLog(@"attachment media is %@", [[streamArray objectAtIndex:i] objectForKey:@"attachment"]);
						//the rest we don't know what type they could be relying on facebook,
						//we can however look at the source of the url and understand what type it's.
						//so let's set it for nil right now.
						_type = [NSString stringWithFormat:@"nil"];
					}
					
				
				} //weird stuff that could be images,tumblr links etc too.
				
					 
			
				else 
				{
					NSLog(@"type is status");
					_type = [NSString stringWithFormat:@"status"];
					
				}


			
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  _actor_id, @"actor_id", 
									  _categoryValue, @"categoryValue", 
									  _from, @"from",
									  _message, @"message",
									  _type, @"type",
									  nil];

				
				[myArray addObject:dict];
				
				break;
			}
		}
		
		
		
	}
	
	
	
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
	
	NSLog(@"myArray: %@", myArray);
	
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
	
	
	
	for (NSInteger i = 0; i < [myArray count]; i++)
	{
		//preparing images for ASIHTTPRequest
		//TODO: need to convert this so, it brings back the urls for the larger images.
		//might need to use the REST API for this!
		
		
		NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[myArray objectAtIndex:i] objectForKey:@"actor_id"] ];


	
		NSLog(@"url_string %@", url_string);
		
		req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url_string]] autorelease];
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

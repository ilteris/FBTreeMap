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
	NSLog(@"streamArray %@", streamArray);
	NSLog(@"userArray %@", userArray);
	
	
	for (NSInteger i=0; i < [streamArray count]; i++)
	{
		NSLog(@"1starr uid number is %@", [[streamArray objectAtIndex:i] objectForKey:@"actor_id"]);
		for (NSInteger j=0; j < [userArray count]; j++)
		{

			NSLog(@"2ndarr uid number is %@", [[userArray objectAtIndex:j] objectForKey:@"uid"]);

			if([[[streamArray objectAtIndex:i] objectForKey:@"actor_id"] isEqual:[[userArray objectAtIndex:j] objectForKey:@"uid"]])	
			{
				NSLog(@"true it's number ");
				NSDictionary *_categoryValue;

				if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
				{
					NSLog(@"displayMode is 0");
					_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"likes"] objectForKey:@"count"]];
					NSLog(@"_categoryValue is %@", _categoryValue);
										
				}
				else //displayMode is 1//comments 
				{
					NSLog(@"displayMode is 1");
					_categoryValue = [NSString stringWithFormat:@"%@",[[[streamArray objectAtIndex:i] objectForKey:@"comments"] objectForKey:@"count"]];
					NSLog(@"_categoryValue is %@", _categoryValue);
					
					
				}
				NSString *_actor_id = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"actor_id"]];
				NSString *_message = [NSString stringWithFormat:@"%@",[[streamArray objectAtIndex:i] objectForKey:@"message"]];
				NSString *_from = [NSString stringWithFormat:@"%@",[[userArray objectAtIndex:j] objectForKey:@"name"]];
				
				
				
				
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  _actor_id, @"actor_id", 
									  _categoryValue, @"categoryValue", 
									  _from, @"from",
									  _message, @"message",
									  nil];

				
				[myArray addObject:dict];
				
				break;
			}
		}
		
		
		
	}
	
	NSLog(@"myArray is %@", myArray);
	
	/*
	for (NSInteger i = 0; i < [result count]; i++) {
		//for (NSDictionary *info in infok) {
			//[[tempArr objectAtIndex:1] objectForKey:@"fql_result_set"]
			NSLog(@"here here");	

	//	NSLog(@"[[[result objectAtIndex:0] objectForKey:@actor_id %	", [[[result objectAtIndex:i] objectForKey:@"fql_result_set"] count]);
			
		

		
		for (NSInteger x=0; x < [[[result objectAtIndex:i] objectForKey:@"fql_result_set"] count]; x++)
		{
		
			
		//	NSLog(@"info %@", [[[result objectAtIndex:i] objectForKey:@"fql_result_set"] objectAtIndex:x]);																			  
			NSLog(@"x is %i",x);
			
			//[[[[result objectAtIndex:i] objectForKey:@"fql_result_set"] objectAtIndex:x] setValue:@"value forKey:@"objectForKey:@"actor_id"];
				NSLog(@"actor_id %@", [[[[result objectAtIndex:0] objectForKey:@"fql_result_set"] objectAtIndex:x] objectForKey:@"actor_id"]);	
				NSLog(@"actor_id %@", [[[[result objectAtIndex:1] objectForKey:@"fql_result_set"] objectAtIndex:x] objectForKey:@"uid"]);	
			//NSLog(@"allKeys %@", [[[[result objectAtIndex:i] objectForKey:@"fql_result_set"] objectAtIndex:x] allKeys]);	
				NSLog(@"actor_name %@", [[[[result objectAtIndex:1] objectForKey:@"fql_result_set"] objectAtIndex:x] objectForKey:@"name"]);	

			if(x==0)
			{
				NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] objectAtIndex:i] objectForKey:@"actor_id"] ];
			}
			/*
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  tempFileName, @"filename", 
								  valuesForCategory, likeKey, 
								  _from, @"from",
								  _message, @"message",
								  nil];
			
			//adding to the plistArray here.
			[_plistArray insertObject:dict atIndex:0];
			 */
		//	}

		
//}
	//NSLog(@"result %@", result);
	//@@@@@@@ 1- filter and splice!
	
	
	/*
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
	{
		NSLog(@"displayMode is 0");
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likes.count" ascending: NO];
		//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		[[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		[sortDescriptor release];
		
		
		
	}
	else //displayMode is 1//comments 
	{
		NSLog(@"displayMode is 1");
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		[[[tempArr objectAtIndex:0] objectForKey:@"fql_result_set"] sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		[sortDescriptor release];
	}
	
	 */
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryValue" ascending: NO];
	//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
	[myArray sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	[sortDescriptor release];
	
	//NSLog(@"names %@", [[tempArr objectAtIndex:1] objectForKey:@"fql_result_set"]);

	// here  we are getting rid of the rest of the objects after numberOfObjects
	//check if the array is larger than numberof Objects
	
	//get rid of the zeros. 
	
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
	
	//NSLog(@"tempArr: %@", tempArr);
	
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
		NSString *likeKey;
		NSString *_categoryValue;
		NSString *_message;
		NSString *_from;
		
		
		if(_plistArray == nil) //check if the plist is empty 
		{ 
			_plistArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init
			
		}
		
		
		//below we should get the type of the posts and then push background or something as the image.
		
		/*
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
		{
			NSLog(@"displayMode is 0");
			valuesForCategory = [NSString stringWithFormat:@"%@",[[[[[request userInfo] objectForKey:@"tempArr"] objectAtIndex:imageNo] objectForKey:@"likes"] objectForKey:@"count"]];
			likeKey = [NSString stringWithFormat:@"likes"];
			
	
			
			

		}
		else //displayMode is 1//comments 
		{
			NSLog(@"displayMode is 1");
			valuesForCategory = [NSString stringWithFormat:@"%@",[[[[[request userInfo] objectForKey:@"tempArr"] objectAtIndex:imageNo] objectForKey:@"comments"] objectForKey:@"count"]];
			likeKey = [NSString stringWithFormat:@"comments"];
			NSLog(@" comment count is %@", valuesForCategory);
			
			
			
		}
		 */
		
		_categoryValue = [NSString stringWithFormat:@"%@",[[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"categoryValue"]];
		//likeKey = [NSString stringWithFormat:@"likes"];
		
		//NSLog(@" _message is %@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"message"] );			
		_from = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"from"]];

		_message = [NSString stringWithFormat:@"%@", [[[[request userInfo] objectForKey:@"myArray"] objectAtIndex:imageNo] objectForKey:@"message"]];
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
								  nil];
			
			//adding to the plistArray here.
			[_plistArray insertObject:dict atIndex:0];
			//NSLog(@"dict %@", dict);	
		}

		
		
		
	//	NSLog(@"key is %@", [[request userInfo] objectForKey:@"key"]);
	//	NSLog(@"image No is %i", imageNo);
		
		
		
		
		
		
		
		//NSString *fn = [documentsDirectory stringByAppendingPathComponent: [[fruits objectAtIndex:index] objectForKey:@"likes"]];
		//TODO: add to the plist here? Not really, create an array and add the dictionaries here to the array and once 
		//queue is completed write all of the stuff to the plist file. 
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

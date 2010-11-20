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

- (id) initializeWithDelegate:(id <LikesAndCommentsRequestDelegate>)delegate andSection:(NSInteger)val
{
	self = [super init];
	_categoryMode = val;
	_likesAndCommentsRequestDelegate = [delegate retain];
	return self;
}

/**
 * FBRequestDelegate
 */
- (void)request:(FBRequest*)request didLoad:(id)result{
	
   // NSMutableArray *fruits = [[[NSMutableArray alloc] init] autorelease];
	
	
    for (NSDictionary *info in result) {
		
		//NSLog(@"here here");
		//NSLog(@"result %@", info);
		/*
		
		if (!([[info objectForKey:@"is_app_user"] boolValue])) {
			continue;
		}
		NSString *friend_id = [NSString stringWithString:[[info objectForKey:@"uid"] stringValue]];
		NSString *friend_name = nil;
		if ([info objectForKey:@"name"] != [NSNull null]) {
			friend_name = [NSString stringWithString:[info objectForKey:@"name"]];
		} 
		NSString *friend_pic = [info objectForKey:@"pic_square"];
		NSString *friend_status = [info objectForKey:@"status"];
		NSMutableDictionary *friend_info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											friend_id,@"uid",
											friend_name, @"name", 
											friend_pic, @"pic", 
											friend_status, @"status", 
											nil];
		
		[friendsInfo addObject:friend_info];
		  */
    }
	
	//@@@@@@@ 1- filter and splice!
	NSMutableArray *tempArr = [result mutableCopy];
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
	{
		NSLog(@"displayMode is 0");
		
		
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likes.count" ascending: NO];
		//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		[tempArr sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		[sortDescriptor release];
		
		
		
	}
	else //displayMode is 1//comments 
	{
		NSLog(@"displayMode is 1");
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		//NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"comments.count" ascending: NO];
		[tempArr sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		[sortDescriptor release];
		
		
		
		
	}
	
	NSLog(@"tempArraay %@", tempArr);
	// [[[fruits objectAtIndex:index] objectForKey:@"comments"] objectForKey:@"count"]
	NSLog(@"tempArraay2 %@", tempArr);
//	NSLog(@"tempArr %@", tempArr);
	// here  we are getting rid of the rest of the objects after numberOfObjects
	//check if the array is larger than numberof Objects
	
	//get rid of the zeros. 
	if ([tempArr count] >= numberOfObjects) 
	{
		[tempArr removeObjectsInRange: NSMakeRange(numberOfObjects,[result count]-numberOfObjects)];
	}
	
	//NSLog(@"tempArr: %@", tempArr);
	
	[tempArr autorelease];
    
	//@@@@@@@ 2- shuffle!
	//[tempArr shuffle];
	
	//@@@@@@@ 3- download the images.
	//imagesLoaded = NO;
	
	NSLog(@"tempArr %@", tempArr);
	
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
	
	
	
	for (NSInteger i = 0; i < [tempArr count]; i++)
	{
		//preparing images for ASIHTTPRequest
		//TODO: need to convert this so, it brings back the urls for the larger images.
		//might need to use the REST API for this!
		NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&", [[tempArr objectAtIndex:i] objectForKey:@"actor_id"] ];


	
		NSLog(@"url_string %@", url_string);
		
		req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url_string]] autorelease];
		[req setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber   
																		 numberWithInt:i], @"ImageNumber", tempArr, @"tempArr",nil]]; 
		[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i]]];
		[networkQueue addOperation:req];
	}
	
	
	
	
    
    
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
		NSString *valuesForCategory;

		
		
		if(_plistArray == nil) //check if the plist is empty 
		{ 
			_plistArray = [[NSMutableArray alloc] initWithCapacity:1]; //if it's empty, alloc/init
			
		}
		
		
		
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])//0//likes
		{
			NSLog(@"displayMode is 0");
			valuesForCategory = [NSString stringWithFormat:@"%@",[[[[[request userInfo] objectForKey:@"tempArr"] objectAtIndex:imageNo] objectForKey:@"likes"] objectForKey:@"count"]];
			
			likeKey = [NSString stringWithFormat:@"likes"];
			NSLog(@" like count is %@", valuesForCategory);
	
			
						
			

		}
		else //displayMode is 1//comments 
		{
			NSLog(@"displayMode is 1");
			valuesForCategory = [NSString stringWithFormat:@"%@",[[[[[request userInfo] objectForKey:@"tempArr"] objectAtIndex:imageNo] objectForKey:@"comments"] objectForKey:@"count"]];
			likeKey = [NSString stringWithFormat:@"comments"];
			NSLog(@" comment count is %@", valuesForCategory);
			
			
			
		}
		
		//if the results are 0 then don't put those in the plist file.
		
		if(![valuesForCategory isEqual:@"0"]) 
		{
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tempFileName, @"filename", valuesForCategory, likeKey, nil];
			
			[_plistArray insertObject:dict atIndex:0];
			NSLog(@"dict %@", dict);	
		}

		
		
		
		NSLog(@"key is %@", [[request userInfo] objectForKey:@"key"]);
		NSLog(@"image No is %i", imageNo);
		
		
		
		
		
		
		
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

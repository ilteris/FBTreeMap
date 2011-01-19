#import "TreeMapViewController.h"

#import "SBJSON.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ProportionalFill.h"
#import "UIImage+Tint.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "NSMutableArray_Shuffling.h"




#define numberOfObjects (8)







@implementation TreeMapViewController
   
@synthesize fruits;
@synthesize cells;

@synthesize treeMapView;

@synthesize plistArray;
//fcebook

@synthesize feedPostId;
@synthesize myWebView;
@synthesize jsonArray;

@synthesize peopleMapDB = _peopleMapDB;


#pragma mark -
#pragma mark facebook delegate
- (void)viewDidLoad {
    [super viewDidLoad];
	imagesLoaded = YES;

	/*Facebook Application ID*/
	//NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];
	if (!_peopleMapDB) _peopleMapDB = [[PeopleMapDB alloc] initWithFilename:@"p_local.db"];

	[self setTheBackgroundArray];
	
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

	_valuesArray =[[NSMutableArray alloc] initWithCapacity:1];	
	
	//[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"likeCount" andView:@"user"];
		}
		else 
		{
			[self displaySection:@"likeCount" andView:@"page"];
		}
		
	}
	else
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"commentCount" andView:@"user"];
		}
		else 
		{
			[self displaySection:@"commentCount" andView:@"page"];
		}
	}
	
}

- (void)viewDidAppear:(BOOL)animated 
{
	
}




#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index 
{
	
}



#pragma mark -
#pragma mark TreemapView delegate

- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index 
{
	TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:index];	
	[cell flipIt];
}



#pragma mark -
- (void)resizeView
{
	NSLog(@"resizeView");
	// resize rectangles with animation
	// NSLog(@"resizeView");
	//[UIView beginAnimations:@"reload" context:nil];
	//[UIView setAnimationDuration:0.5];
	
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"likeCount" andView:@"user"];
		}
		else 
		{
			[self displaySection:@"likeCount" andView:@"page"];
			
		}

	}
	else
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"commentCount" andView:@"user"];
		}
		else 
		{
			[self displaySection:@"commentCount" andView:@"page"];
		}
	}
	//this is a hack so that hearts andcomments don't move on orientation change.
	[UIView setAnimationsEnabled:NO];
	
	[(TreemapView *)self.treeMapView reloadData];
	[UIView setAnimationsEnabled:YES];
	//[UIView commitAnimations];
	
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

- (void)displayCommentsOfUsers
{
	[self displaySection:@"commentCount" andView:@"user"];

}

- (void)displayCommentsOfPages
{
	[self displaySection:@"commentCount" andView:@"page"];
	
}


- (void)displayLikesOfPages
{
	[self displaySection:@"likeCount" andView:@"page"];
	
}


- (void)displayLikesOfUsers
{
	[self displaySection:@"likeCount" andView:@"user"];
	
}


-(void)displaySection:(NSString*)section andView:(NSString*)viewType
{
	NSDictionary * row = nil;
	//NSString* s = [NSString stringWithFormat:@"SELECT rowid, poster_name, %@ FROM \"object\" WHERE poster_type = \"%@\" ORDER BY \"%@\" DESC LIMIT 8", count, poster_type, count];
	_valuesArray =[[NSMutableArray alloc] initWithCapacity:1];
	self.fruits = [[NSMutableArray alloc] initWithCapacity:1];

	
	//NSLog(@"%@",s);
	//	NSString* s = [NSString stringWithFormat:@"SELECT rowid, poster_name, %@ FROM \"object\" WHERE poster_type = \"%@\" ORDER BY \"%@\" DESC LIMIT 8", count, poster_type, count];
//SELECT * FROM object WHERE updated >= DATETIME('now', '-5 hours');
	
	//select time('now');
	[self setTheBackgroundArray];
	
	for (row in [_peopleMapDB getQuery:[NSString stringWithFormat:@"SELECT post_id, poster_name, objectType, message, image_url, %@ FROM \"object\" WHERE poster_type = \"%@\" AND updated >= DATETIME('now', '-6 hours') ORDER BY \"%@\" DESC LIMIT 8", section, viewType, section]])
	{
		//[self dispRow:row];
		
		NSLog(@"row is %@", row);

		
		if([[row objectForKey:[NSString stringWithFormat:@"%@",section]] intValue] != 0) 
		{
			NSNumber *value = [row objectForKey:[NSString stringWithFormat:@"%@",section]];
			NSLog(@"value is %@", value);
			NSLog(@"section is %@", section);
			
			[_valuesArray addObject:value];
			[fruits addObject:row];
		}
		
			NSLog(@"file is %@", [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]]);
			
			if([[row objectForKey:@"objectType" ] isEqual:@"video"]) 
			{//then put the video background there.
				if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]]])
					
				{
					NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video"  ofType:@"png"]];
					
					[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]] atomically:YES];
				}	
				
			}//endif
			else if([[row objectForKey:@"objectType" ] isEqual:@"status"]) 
			{//then put the custom background there.
				if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]]])
				{
					
					NSInteger rand_ind = arc4random() % [_backgrounds count];
					NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_backgrounds objectAtIndex:rand_ind]  ofType:@"png"]];
					[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]] atomically:YES];
					[_backgrounds removeObjectAtIndex:rand_ind];
					if([_backgrounds count] < 1) [self setTheBackgroundArray]; //if the backgroundarray gets empty, refill it.
				}
			}//endelseif
			else 
			{//then download the image
				//req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[row objectForKey:@"image_url"]]] autorelease];
				//[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]]];
				//[_networkQueue addOperation:req];
			}//endelse
	
	}
	
	
	//NSLog(@"fruits is %@", self.fruits);
	[(TreemapView *)self.treeMapView reloadData];
}

#pragma mark TreemapView data source
//values that are passed to treemapview --> anytime there's an action with the tableview, source gets called first.

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	NSLog(@"valuesForTreemapView");
	NSLog(@"values %@", _valuesArray);
	
	if(!_valuesArray)
	{
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
		{
			if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
			{
				[self displaySection:@"likeCount" andView:@"user"];
			}
			else 
			{
				[self displaySection:@"likeCount" andView:@"page"];
			}
			
		}
		else
		{
			if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
			{
				[self displaySection:@"commentCount" andView:@"user"];
			}
			else 
			{
				[self displaySection:@"commentCount" andView:@"page"];
			}
		}
		
	}
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) //if switchMode mode is users
	{
		//little hack to bump up the value of the largest item. this gives us a larger cell.
		//this still needs to be improved. -what happens when there's two equal values? need to solve that.
		
		int highestNumber					= 0;
		int highestSecondNumber				= 0;
		int highestNumberIndex				= 0;
		int highestSecondNumberIndex		= 0;
		
		for (NSNumber *theNumber in _valuesArray)
		{
			if ([theNumber intValue] >= highestNumber) {
				highestSecondNumberIndex = highestNumberIndex;
				highestSecondNumber = highestNumber;
				highestNumber = [theNumber intValue];
				highestNumberIndex = [_valuesArray indexOfObject:theNumber];
			}
			else if([theNumber intValue] > highestSecondNumber)
			{
				highestSecondNumber = [theNumber intValue];
				highestSecondNumberIndex = [_valuesArray indexOfObject:theNumber];
			}
		}//endfor
		//TODO: if there's two 1 and 1 item, then this gets called. need to fix it. 
		NSLog(@"Highest number: %i at index: %i", highestNumber, highestNumberIndex);
		NSLog(@" highestSecondNumber: %i at index: %i", highestSecondNumber, highestSecondNumberIndex);
		if(highestNumber==highestSecondNumber)
		{
			
		}
		else 
		{
			if((highestNumber/highestSecondNumber) < 2) //if there's no duplicate winners AND difference between first two highest number is 1/2 then multiply.
			{
				NSInteger tempValue = [[_valuesArray objectAtIndex:highestNumberIndex] intValue];
				tempValue = round(tempValue*2.5);
				NSNumber *_inStr = [NSNumber numberWithInt:tempValue];
				[_valuesArray replaceObjectAtIndex:highestNumberIndex withObject:_inStr];
				NSLog(@"tempValue is %i", tempValue);
			}//endif
		}
	

		
		
		NSLog(@"Highest number: %i at index: %i", highestNumber, highestNumberIndex);
		NSLog(@" highestSecondNumber: %i at index: %i", highestSecondNumber, highestSecondNumberIndex);
		

	}
	else 
	{
		
	}//endelse
 
		
		
	
	return _valuesArray;

}
 

#pragma mark imageDownload Delegates 

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
[(TreemapView *)self.treeMapView reloadData];

	
}//endfunction



- (void)imageFetchFailed:(ASIHTTPRequest *)request
{
	NSLog(@"imageFetchFailed");
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
	
	
}



 

//this gets called @creation for each of the cell. 
- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect 
{
	TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
	
	
	NSLog(@"treemapView cellForIndex");
	//NSLog(@"comments is %@", [[fruits objectAtIndex:index] objectForKey:@"comments"]);
	//NSLog(@"likes is %@", [[fruits objectAtIndex:index] objectForKey:@"likes"]);

	//here give the document thingie so that we can load the images from the plist file.
	
	//[self setTheBackgroundArray];
	
	//need to figure out a way to pass the current stage so that we know what we are looking at here.
	NSNumber *tText;
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 

	{
		tText = [[fruits objectAtIndex:index] objectForKey:@"likeCount"];
	}
	else 
	{
		tText = [[fruits objectAtIndex:index] objectForKey:@"commentCount"];
	}
	

	ASIHTTPRequest *req;
	
	NSString *fn =  [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]];
	UIImage *img = [UIImage imageWithContentsOfFile:fn];
	NSLog(@"the name is %@", [[fruits  objectAtIndex:index] objectForKey:@"poster_name"]);
	if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]]])

	{
		NSLog(@"img is not present %@", [[fruits  objectAtIndex:index] objectForKey:@"image_url"]);
		req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[fruits  objectAtIndex:index] objectForKey:@"image_url"]]] autorelease];
		[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]]];
		[_networkQueue addOperation:req];		
	}
	
	
		 
	if([[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"video"])
	{
		//when it's the video image, don't crop it, it makes the image looks awkward.
		cell.imageViewA.image = img;
		
		//TODO: need to check the size of the frame and display the play button accordingly.
		cell.playBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		cell.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
		cell.playBtn.frame = CGRectMake((cell.imageViewA.bounds.size.width-cell.playBtn.bounds.size.width)/2, (cell.imageViewA.bounds.size.height-cell.playBtn.bounds.size.height)/2, cell.playBtn.frame.size.width, cell.playBtn.frame.size.height);
		UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
		[cell.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
		[tImage release];
		
		[cell.aView addSubview:cell.playBtn];
		cell.contentLabel.text = @"";//	[[fruits objectAtIndex:index] objectForKey:@"message"];

	}
	else if([[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"photo"] || [[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"link"])
	{
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		//cell.contentLabel.text = 	[[fruits objectAtIndex:index] objectForKey:@"message"];
	}else 
	{
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		cell.contentLabel.text = 	[[fruits objectAtIndex:index] objectForKey:@"message"];
	}

	   
	
	cell.countLabel.text = [tText stringValue];
	
	cell.titleLabel.text = [[[fruits objectAtIndex:index] objectForKey:@"poster_name"] uppercaseString];
	
	//add the post_id
	cell.post_id = [[fruits objectAtIndex:index] objectForKey:@"post_id"];
	[self.cells addObject:cell];
	[cell release];
	
	//load the local images first here.
	
//	[self updateCell:cell forIndex:index];
	 
	return cell;
}


//this gets called on the update 
- (void)treemapView:(TreemapView *)treemapView updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index forRect:(CGRect)rect 
{
	[self updateCell:cell forIndex:index];
}





- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	fruits = nil;
}

- (void)dealloc {
	[fruits release];
	
	[super dealloc];
}

@end

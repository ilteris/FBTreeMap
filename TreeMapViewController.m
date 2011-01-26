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

@synthesize jsonArray;

@synthesize peopleMapDB = _peopleMapDB;


#pragma mark -
#pragma mark facebook delegate
-  init {


	/*Facebook Application ID*/
	//NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];
	if (!_peopleMapDB) _peopleMapDB = [[PeopleMapDB alloc] initWithFilename:@"p_local1.db"];

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
	//NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	
	return self;
}


#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index 
{
	
}



#pragma mark -
#pragma mark TreemapView delegate

- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index 
{
	NSLog(@"here");
	TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:index];	
	[cell flipIt];
}

-(NSString*)returnDurationString:(int)integer
{
	NSString *temp_string;

	
	switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]) {
		case 0:
			temp_string = [NSString stringWithFormat:@"-2 hours"];
			break;
		case 1:
			temp_string = [NSString stringWithFormat:@"-6 hours"];
			break;
		case 2:
			temp_string = [NSString stringWithFormat:@"-12 hours"];
			break;
		case 3:
			temp_string = [NSString stringWithFormat:@"-24 hours"];
			break;
			
		default:
			break;
	}
	
	return temp_string;
}


- (void)onCountBtnPress:(id)sender {
	NSLog(@"flipAction");
	
	//NSLog(@"post_id is %@", _post_id);
	
	TreemapViewCell *cell = [self.cells objectAtIndex:[sender tag]];
	
	NSNumber *tempNumber = [NSNumber numberWithInt:[[cell.countLabel text] intValue] + 1];
	NSLog(@"tempNumber %@", tempNumber);
	
	NSNumber *value = [_valuesArray objectAtIndex:[sender tag]];
	
	NSLog(@"value %@", value);

	//replace the old value with the new value
	[_valuesArray replaceObjectAtIndex:[sender tag] withObject:tempNumber];
	
	cell.countLabel.text = [tempNumber stringValue];
	
	[UIView beginAnimations:@"reload" context:nil];
	[UIView setAnimationDuration:0.5];
	
	//[(TreemapView *)self.treeMapView reloadData];
	
	[UIView commitAnimations];
	

	
	
//	NSDictionary *dic = [fruits objectAtIndex:index];
//	[dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"value"] intValue] + 300] forKey:@"value"];

	
	
	
	
}



#pragma mark -


- (void)resizeCell
{
	/*
	 * resize rectangles with animation
	 */
	[UIView beginAnimations:@"reload" context:nil];
	[UIView setAnimationDuration:0.5];
	
	[(TreemapView *)self.treeMapView reloadData];
	
	[UIView commitAnimations];
}


#pragma mark -
- (void)resizeView
{
	NSLog(@"resizeView");
	// resize rectangles with animation
	// NSLog(@"resizeView");
	//[UIView beginAnimations:@"reload" context:nil];
	//[UIView setAnimationDuration:0.5];
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];


	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
	{
		
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"likeCount" andView:@"user" withDuration:durationString];
		}
		else 
		{
			[self displaySection:@"likeCount" andView:@"page" withDuration:durationString];
			
		}

	}
	else
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[self displaySection:@"commentCount" andView:@"user" withDuration:durationString];
		}
		else 
		{	
			[self displaySection:@"commentCount" andView:@"page" withDuration:durationString];
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
//	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
	
	[self resizeView];
	//[self displaySection:@"commentCount" andView:@"user" withDuration:durationString];

}

- (void)displayCommentsOfPages
{
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"switchMode"];
	
	[self resizeView];
	
//	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	//[self displaySection:@"commentCount" andView:@"page" withDuration:durationString];
	
}


- (void)displayLikesOfPages
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"switchMode"];
	
	[self resizeView];
	
//	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	//[self displaySection:@"likeCount" andView:@"page" withDuration:durationString];
	
}


- (void)displayLikesOfUsers
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
	
	[self resizeView];
	
	//NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	//[self displaySection:@"likeCount" andView:@"user" withDuration:durationString];
	
}


-(void)displaySection:(NSString*)section andView:(NSString*)viewType withDuration:(NSString*)duration
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
	//SELECT post_id, poster_name, objectType, message, image_url, commentCount, datetime(posted_time,'unixepoch', 'localtime') FROM "object" WHERE poster_type = "user" AND datetime(posted_time,'unixepoch', 'localtime') >= datetime('now', '-2 hours', 'localtime') ORDER BY "commentCount" DESC LIMIT 8

	for (row in [_peopleMapDB getQuery:[NSString stringWithFormat:@"SELECT post_id, poster_name, objectType, message, image_url, %@ FROM \"object\" WHERE poster_type = \"%@\" AND datetime(posted_time,'unixepoch', 'localtime') >= datetime('now', '%@', 'localtime') ORDER BY \"%@\" DESC LIMIT 8", section, viewType, duration, section]])
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
	NSLog(@"treemap is %@", self.treeMapView);
	[(TreemapView *)self.treeMapView reloadData];
}

#pragma mark TreemapView data source
//values that are passed to treemapview --> anytime there's an action with the tableview, source gets called first.

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	NSLog(@"valuesForTreemapView");
	//NSLog(@"values %@", _valuesArray);
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	
	
	if(!_valuesArray)
	{
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
		{
			if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
			{
				[self displaySection:@"likeCount" andView:@"user" withDuration:durationString];
			}
			else 
			{
				[self displaySection:@"likeCount" andView:@"page" withDuration:durationString];
			}
			
		}
		else
		{
			if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
			{
				[self displaySection:@"commentCount" andView:@"user" withDuration:durationString];
			}
			else 
			{
				[self displaySection:@"commentCount" andView:@"page" withDuration:durationString];
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
			NSLog(@"highestNumber is %i", highestNumber);
			NSLog(@"highestSecondNumber is %i", highestSecondNumber);
			
			if (highestSecondNumber != 0) 
			{
				
				
				if((highestNumber/highestSecondNumber) < 2) //if there's no duplicate winners AND difference between first two highest number is 1/2 then multiply.
				{
					NSInteger tempValue = [[_valuesArray objectAtIndex:highestNumberIndex] intValue];
					tempValue = round(tempValue*2.5);
					NSNumber *_inStr = [NSNumber numberWithInt:tempValue];
					[_valuesArray replaceObjectAtIndex:highestNumberIndex withObject:_inStr];
					NSLog(@"tempValue is %i", tempValue);
				}//endif
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
	
	[cell.countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
	cell.countBtn.tag = index;
	
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

}

- (void)viewDidUnload {

	
	fruits = nil;
}

- (void)dealloc {
	[fruits release];
	[super dealloc];
}

@end

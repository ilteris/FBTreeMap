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


//fcebook

@synthesize feedPostId;

@synthesize jsonArray;

@synthesize peopleMapDB = _peopleMapDB;
@synthesize userInfo = _userInfo;



static CGFloat kTransitionDuration = 0.3;


#pragma mark -
#pragma mark facebook delegate
-  init {
	
	
	/*Facebook Application ID*/
	//NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];
	if (!_peopleMapDB) _peopleMapDB = [[PeopleMapDB alloc] initWithFilename:@"p_local4.db"];
	
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
	

	
	//[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	//NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	
	return self;
}


#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index 
{
	NSLog(@"updating cell");
//	NSLog(@"fruits %@", fruits);
	
	//set the user likes first
	cell.user_likes = [[[fruits  objectAtIndex:index] objectForKey:@"user_likes"] intValue];
	
	
	
	
	//	NSLog(@"cell.user_likes is %i", cell.user_likes);
    cell.canPostComment = [[[fruits  objectAtIndex:index] objectForKey:@"canPostComment"] intValue];
	
	
	cell.titleLabel.text = [[[fruits objectAtIndex:index] objectForKey:@"poster_name"] uppercaseString];
	//add the post_id
	cell.post_id = [[fruits objectAtIndex:index] objectForKey:@"post_id"];
	cell.objectType = [[fruits objectAtIndex:index] objectForKey:@"objectType"];
	
	
	
	NSNumber *tText;
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
		
	{
		tText = [[fruits objectAtIndex:index] objectForKey:@"likeCount"];

		//well give them alpha accordingly to the values.
		if(cell.user_likes)
		{
			cell.countBtn.alpha = 1.0f;
		}
		else 
		{
			cell.countBtn.alpha = 0.5f;
		}
		
	}
	else 
	{
		NSLog(@"display Mode is comment");
		tText = [[fruits objectAtIndex:index] objectForKey:@"commentCount"];
		
		cell.countBtn.alpha = 0.5f;

	}
	
	cell.countLabel.text = [tText stringValue];
	
	ASIHTTPRequest *req;
	
	NSString *fn =  [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]];
	UIImage *img = [UIImage imageWithContentsOfFile:fn];
	//NSLog(@"the name is %@", [[fruits  objectAtIndex:index] objectForKey:@"poster_name"]);
	if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]]])
	{
		NSLog(@"img is not present %@", [[fruits  objectAtIndex:index] objectForKey:@"image_url"]);
		req = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[[fruits  objectAtIndex:index] objectForKey:@"image_url"]]] autorelease];
		[req setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[fruits  objectAtIndex:index] objectForKey:@"post_id" ]]]];
		[_networkQueue addOperation:req];		
	}
	
	NSLog(@"img is  present %@", [[fruits  objectAtIndex:index] objectForKey:@"image_url"]);


	
	if([[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"video"])
	{
		//when it's the video image, don't crop it, it makes the image looks awkward.
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		cell.image = img;
		NSInteger _width = cell.frame.size.width;
		NSInteger _height = cell.frame.size.width;		
		
		NSInteger _areaOfCell = _width*_height;
		NSInteger _areaOfPlayBtn = 56*56;
		
		if(_areaOfCell > _areaOfPlayBtn) //meaning cell area is larger than the playBtn.
		{

			
			
		}
		
		cell.contentLabel.text = @"";//	[[fruits objectAtIndex:index] objectForKey:@"message"];
		
	}
	else if([[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"photo"] || [[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"link"] || [[[fruits objectAtIndex:index] objectForKey:@"objectType"] isEqual:@"event"])
	{
		
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		cell.image = img;
		cell.contentLabel.text = @"";//	[[fruits objectAtIndex:index] objectForKey:@"message"];
	}else //if it's a status just display the background uncropped.
	{
		cell.image = img;
		cell.imageViewA.image = img;
		//cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		cell.contentLabel.text = 	[[fruits objectAtIndex:index] objectForKey:@"message"];
	}
}



#pragma mark -
#pragma mark TreemapView delegate

- (void)onCountBtnPress:(TreemapView*)treemapView onCell:(TreemapViewCell*)cell
{
	NSLog(@"onCountBtnPress on treemapViewController");
	
	//step 1 check if the item is already liked through the local db
	//step 2 if not then like it or comment it to your hearts content
	//step 3 update the local database, so it's not likeable anymore but still commentable. | so pressing heart likes it and press it again unlikes it. | each press of comment adds a new comment.
	
	//NSLog(@"_user_likes is %i", cell.user_likes);
	//NSLog(@"_canPostComment is %i", cell.canPostComment);
	
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
	{
        
        if(!cell.user_likes) // meaning I can like this motherfucker
        {
            NSDictionary *dic = [fruits objectAtIndex:cell.index];
            
            // NSLog(@"dic is %i", [[dic valueForKey:@"likeCount"] intValue]);
            
			//update locally because layout kinda fucks up if we reload the fruits array doing resizeview due nature of creation of treemapview.
            [dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"likeCount"] intValue] + 1] forKey:@"likeCount"];
			[dic setValue:[NSNumber numberWithInt:1] forKey:@"user_likes"];
			//update  local database
			NSNumber* _likeCount = [NSNumber numberWithInt:[[dic valueForKey:@"likeCount"] intValue] + 1];
            NSNumber* _user_likes = [NSNumber numberWithInt:1];
            //cell.user_likes = 0; //cannot like it anymore
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  cell.post_id, @"post_id",
                                 _user_likes, @"user_likes",
                                  _likeCount, @"likeCount",
                                  nil];
            [_peopleMapDB updateItemRow:dict];  
			
			//update facebook here. sending the already prepared dictionary.
			
			[_userInfo requestWithGraph:dict andAction:@"likes" andHttpMethod:@"POST"];
			
			
		}
        else //dislike this motherfucker
        {
            NSDictionary *dic = [fruits objectAtIndex:cell.index];
            
            //   NSLog(@"dic is %i", [[dic valueForKey:@"likeCount"] intValue]);
			//update locally because layout kinda fucks up if we reload the fruits array doing resizeview due nature of creation of treemapview.
            [dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"likeCount"] intValue] - 1] forKey:@"likeCount"];
			[dic setValue:[NSNumber numberWithInt:0] forKey:@"user_likes"];
			 
			//update local database
            NSNumber* _likeCount = [NSNumber numberWithInt:[[dic valueForKey:@"likeCount"] intValue] - 1];
           //it's likeable again.
			NSNumber* _user_likes = [NSNumber numberWithInt:0];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  cell.post_id, @"post_id",
                                  _user_likes, @"user_likes",
                                  _likeCount, @"likeCount",
                                  nil];
            [_peopleMapDB updateItemRow:dict];  
			
			
			//update facebook here. 
			[_userInfo requestWithGraph:dict andAction:@"likes" andHttpMethod:@"DELETE"];
        }
	}
	else //comment area
	{
		/*
			//we can only add comment in the first screen, no removing comment.
            NSDictionary *dic = [fruits objectAtIndex:cell.index];
            
            // NSLog(@"dic is %i", [[dic valueForKey:@"likeCount"] intValue]);
            
			//update locally because layout kinda fucks up if we reload the fruits array doing resizeview due nature of creation of treemapview.
            [dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"commentCount"] intValue] + 1] forKey:@"commentCount"];
		
			//update  local database
			NSNumber* _commentCount = [NSNumber numberWithInt:[[dic valueForKey:@"commentCount"] intValue] + 1];

            //cell.user_likes = 0; //cannot like it anymore
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  cell.post_id, @"post_id",
                                  _commentCount, @"commentCount",
                                  nil];
            [_peopleMapDB updateItemRow:dict];  
		
		NSString* string_ = [NSString stringWithFormat:@"love it!"];
		NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
							  cell.post_id, @"post_id",
							  string_, @"comment_message",
							  nil];
		
			//TODO: update facebook here.
			[_userInfo requestWithGraph:actionDict andAction:@"comments" andHttpMethod:@"POST"];
		 */
		
		
		/*
		CGRect rect = CGRectMake(self.treeMapView.frame.size.width/2-500/2, self.treeMapView.frame.size.height/2-200 , 500, 200);
		CGRect rect1 = CGRectMake(self.treeMapView.frame.size.width/2-520/2, self.treeMapView.frame.size.height/2-210 , 520, 220);

		_tempViewTextField = [[UITextView alloc] initWithFrame:rect];
		_tempViewBg = [[UITextView alloc] initWithFrame:rect1];
		
		_tempViewTextField.backgroundColor = [UIColor whiteColor];
		_tempViewBg.backgroundColor = [UIColor blackColor];

			
		_tempViewTextField.alpha = 1.0;
		
		//added to the mainviewcontrooler.view
		[[self.treeMapView superview] addSubview:_tempViewBg];
		[[self.treeMapView superview] addSubview:_tempViewTextField];
		_tempViewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
		_tempViewTextField.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration/1.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
		_tempViewTextField.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
		_tempViewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);

		[UIView commitAnimations];
		*/
		/*
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.5];
		tempViewAbove.center = CGPointMake(self.treeMapView.frame.size.width/2, self.treeMapView.frame.size.height/2);
		tempViewAbove.alpha = 1.0;
		[UIView commitAnimations];

		
		*/
	}
	
	//[self resizeView]; //so that fruit gets updated for new values to take effect.
	//[self updateCell:cell forIndex:cell.index];
	
	[self.treeMapView reloadData];

}

- (void)bounce1AnimationStopped {
	NSLog(@"bounce1AnimationStopped");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	_tempViewTextField.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	_tempViewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);

	[UIView commitAnimations];
}



- (void)bounce2AnimationStopped {
	NSLog(@"bounce2AnimationStopped");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	[UIView setAnimationDelegate:self];
	_tempViewTextField.transform = CGAffineTransformIdentity;
	_tempViewBg.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)bounce3AnimationStopped {
	NSLog(@"bounce3AnimationStopped");
	[_tempViewTextField becomeFirstResponder];
}







- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index 
{
	NSLog(@"here");
	/*
	for (NSInteger i = 0; i < [self.treeMapView.subviews count]; i++) {
		TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:i];	
		//[cell flipIt];
		
		[cell performSelector:@selector(flipIt) withObject:nil afterDelay:i*.1];

	}
*/
	
	[self performSelector:@selector(createbackView:) withObject:[NSNumber numberWithInt:index]  afterDelay:.5];
	
}



- (void) createbackView:(NSNumber*)index
{
	
	CGRect rect = CGRectMake(0, 0 , self.treeMapView.frame.size.width, self.treeMapView.frame.size.height);


	NSLog(@"createBackrect is %@", NSStringFromCGRect(rect));
	
	//TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:[index integerValue]];

	//UIImageView *_viewBg = [[UIImageView alloc] initWithFrame:rect];
	//[self.treeMapView bringSubviewToFront:cell];
	
	//cell.alpha = 0.0;
	//cell.frame = rect;
	
	//_viewBg.backgroundColor = [UIColor blackColor];
	
	//cell.alpha = 1.0;

	//_viewBg.image = [cell.image imageCroppedToFitSize:rect.size];

	//cell.imageViewA.image = [cell.image imageCroppedToFitSize:rect.size];
	
	//[[self.treeMapView superview] addSubview:_viewBg];

	//added to the mainviewcontrooler.view
	
	UIScrollView *scrollView1 = [[UIScrollView alloc] initWithFrame:rect];
	[scrollView1 setCanCancelContentTouches:NO];
	scrollView1.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	//scrollView1.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1.scrollEnabled = YES;
	scrollView1.pagingEnabled = YES;
	
	NSLog(@" [self.treeMapView.subviews count] is %i",[self.treeMapView.subviews count] );


	for (NSUInteger i = 1; [self.treeMapView.subviews count] > 0; i++)
	{
		NSLog(@"i is %i", i);
		TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:0];	

		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
		NSLog(@"createBackrect frame is %@", NSStringFromCGRect(cell.frame));
		cell.frame = rect;
		cell.tag = i;	// tag our images for later use when we place them in serial fashion
		cell.imageViewA.image = [cell.image imageCroppedToFitSize:rect.size];
		[scrollView1 addSubview:cell];

	}
	
	//[self.treeMapView.subviews enumerateObjectsWithOptions:NSReverseEnumeration block:^(id obj, NSUInteger idx, BOOL *stop) { /* do stuff */ }];
	
	
	
	[self layoutScrollImages:scrollView1 atOffset:index];
	scrollView1.alpha = 0.0f;
	[self.treeMapView addSubview:scrollView1];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	scrollView1.alpha = 1.0;
	
	
	[UIView commitAnimations];

	
		
//	_viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
	/*
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	cell.alpha = 1.0;
	//_viewBg.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
	
	[UIView commitAnimations];
	 */
}

- (void)layoutScrollImages:(UIScrollView*)scrollView atOffset:(NSNumber*)index
{
	CGRect rect = CGRectMake(0, 0 , self.treeMapView.frame.size.width, self.treeMapView.frame.size.height);
	
	
	NSLog(@"layoutScrollImages is %@", NSStringFromCGRect(rect));
	
	NSLog(@"layoutScrollImages is %@", NSStringFromCGRect(rect));
	UIImageView *view = nil;
	NSArray *subviews = [scrollView subviews];
	
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		NSLog(@"layoutScrollImages frame is %@", NSStringFromCGRect(view.frame));
		if ([view isKindOfClass:[TreemapViewCell class]] && view.tag > 0)
		{
			NSLog(@"view is %@", view);
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += self.treeMapView.frame.size.width;
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake(([fruits count] * self.treeMapView.frame.size.width), [scrollView bounds].size.height)];
	[scrollView setContentOffset:CGPointMake([index integerValue]*self.treeMapView.frame.size.width,0) animated:NO];
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


#pragma mark -


- (void)resizeCell
{
	/*
	 * resize rectangles with animation
	 */
	[UIView beginAnimations:@"reload" context:nil];
	[UIView setAnimationDuration:0.5];
	
	//[(TreemapView *)self.treeMapView reloadData];
	
	[UIView commitAnimations];
}


-(void) changeTime
{
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
	
	[self createCellsFromZero];
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
	/*
	[UIView setAnimationsEnabled:NO];
	//[(TreemapView *)self.treeMapView reloadData];
	[UIView setAnimationsEnabled:YES];
	//[UIView commitAnimations];
	*/
//	[UIView beginAnimations:@"reload" context:nil];
//	[UIView setAnimationDuration:0.5];
	
//	[self.treeMapView reloadData];
	
//	[UIView commitAnimations];
	
	
}


- (void) createCellsFromZero
{
	[self.treeMapView removeNodes];
	[self.treeMapView createNodes];
}




#pragma mark TreemapView data source
//values that are passed to treemapview --> anytime there's an action with the tableview, this gets called first.

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	NSLog(@"valuesForTreemapView");
	//NSLog(@"values %@", _valuesArray);
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];
	
	/*
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:fruits.count];
	for (NSDictionary *dic in fruits) {
		[values addObject:[dic valueForKey:@"value"]];
	}
	NSLog(@"values are %@", values);
	 */
	
	
	
	if(!fruits)
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
	
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:fruits.count];
	for (NSDictionary *dic in fruits) {
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) 
		{
			[values addObject:[dic valueForKey:@"likeCount"]];
		}
		else 
		{
			[values addObject:[dic valueForKey:@"commentCount"]];

		}

		
	}
	
	//NSLog(@"fruits %@", fruits);
	
	return values;
	
	
	/*
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
	 */
	
	
	
	//return _valuesArray;
	
}

//this is where I pull back data from local DB. called after resizeView
-(void)displaySection:(NSString*)section andView:(NSString*)viewType withDuration:(NSString*)duration
{
	NSDictionary * row = nil;
	//NSString* s = [NSString stringWithFormat:@"SELECT rowid, poster_name, %@ FROM \"object\" WHERE poster_type = \"%@\" ORDER BY \"%@\" DESC LIMIT 8", count, poster_type, count];
	//_valuesArray =[[NSMutableArray alloc] initWithCapacity:1];
	self.fruits = [[NSMutableArray alloc] initWithCapacity:1];
	
	
	//NSLog(@"%@",s);
	//	NSString* s = [NSString stringWithFormat:@"SELECT rowid, poster_name, %@ FROM \"object\" WHERE poster_type = \"%@\" ORDER BY \"%@\" DESC LIMIT 8", count, poster_type, count];
	//SELECT * FROM object WHERE updated >= DATETIME('now', '-5 hours');
	
	//select time('now');
	[self setTheBackgroundArray];
	//SELECT post_id, poster_name, objectType, message, image_url, commentCount, datetime(posted_time,'unixepoch', 'localtime') FROM "object" WHERE poster_type = "user" AND datetime(posted_time,'unixepoch', 'localtime') >= datetime('now', '-2 hours', 'localtime') ORDER BY "commentCount" DESC LIMIT 8
	
	for (row in [_peopleMapDB getQuery:[NSString stringWithFormat:@"SELECT post_id, poster_name, objectType, message, image_url, user_likes, canPostComment, %@ FROM \"object\" WHERE poster_type = \"%@\" AND datetime(posted_time,'unixepoch', 'localtime') >= datetime('now', '%@', 'localtime') ORDER BY \"%@\" DESC LIMIT 8", section, viewType, duration, section]])
	{
		//[self dispRow:row];
		
		//NSLog(@"row is %@", row);
		
		
		if([[row objectForKey:[NSString stringWithFormat:@"%@",section]] intValue] != 0) 
		{
			//NSNumber *value = [row objectForKey:[NSString stringWithFormat:@"%@",section]];
			//NSLog(@"value is %@", value);
			//NSLog(@"section is %@", section);
			
			//[_valuesArray addObject:value];
			[fruits addObject:row];
		}
		
		//NSLog(@"file is %@", [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [row objectForKey:@"post_id" ]]]);
		
		if([[row objectForKey:@"objectType" ] isEqual:@"video"]) 
		{//then put the video background there.
			if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [row objectForKey:@"post_id" ]]]])
				
			{
			//	NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video"  ofType:@"jpg"]];
			//	
			//	[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [row objectForKey:@"post_id" ]]] atomically:YES];
			}	
			
		}//endif
		else if([[row objectForKey:@"objectType" ] isEqual:@"status"]) 
		{//then put the custom background there.
			if (![[NSFileManager defaultManager] isReadableFileAtPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [row objectForKey:@"post_id" ]]]])
			{
				
				NSInteger rand_ind = arc4random() % [_backgrounds count];
				NSData *imgData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_backgrounds objectAtIndex:rand_ind]  ofType:@"jpg"]];
				[imgData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [row objectForKey:@"post_id" ]]] atomically:YES];
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
	//	NSLog(@"treemap is %@", self.treeMapView);
	//[(TreemapView *)self.treeMapView reloadData];
}




#pragma mark imageDownload Delegates 

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	//[(TreemapView *)self.treeMapView reloadData];
	//[self updateCell:cell forIndex:index];
	
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
	[self.treeMapView reloadData];
	
		
}





//this gets called @creation for each of the cell. 
- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect 
{
	TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
	[self updateCell:cell forIndex:index];
	
	return cell;
}


//this gets called on the update 
- (void)treemapView:(TreemapView *)treemapView updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index forRect:(CGRect)rect 
{
	[self updateCell:cell forIndex:index];
}





//background is being assigned here.
- (void)setTheBackgroundArray
{
	_backgrounds = [[NSMutableArray alloc] initWithCapacity:1];
	NSString *b0 = [NSString stringWithFormat:@"blacksand"];
	NSString *b1 = [NSString stringWithFormat:@"carbonfiber"];
	NSString *b2 = [NSString stringWithFormat:@"concrete"];
	NSString *b3 = [NSString stringWithFormat:@"diamondsteel"];
	NSString *b4 = [NSString stringWithFormat:@"fabricburgundy"];
	NSString *b5 = [NSString stringWithFormat:@"gold"];
	NSString *b6 = [NSString stringWithFormat:@"granulardark"];
	NSString *b7 = [NSString stringWithFormat:@"greenmarble"];
	NSString *b8 = [NSString stringWithFormat:@"ice"];
	NSString *b9 = [NSString stringWithFormat:@"leather"];
	NSString *b10 = [NSString stringWithFormat:@"metalmesh"];
	NSString *b11 = [NSString stringWithFormat:@"metalmesh"];
	NSString *b12 = [NSString stringWithFormat:@"metalscratched"];
	NSString *b13 = [NSString stringWithFormat:@"russian"];
	NSString *b14 = [NSString stringWithFormat:@"rust"];
	NSString *b15 = [NSString stringWithFormat:@"slate"];
	NSString *b16 = [NSString stringWithFormat:@"wood"];
	NSString *b17 = [NSString stringWithFormat:@"concrete"];

	
	
	[_backgrounds addObject:b0];
	[_backgrounds addObject:b1];
	[_backgrounds addObject:b2];
	[_backgrounds addObject:b3];
	[_backgrounds addObject:b4];
	[_backgrounds addObject:b5];
	[_backgrounds addObject:b6];
	[_backgrounds addObject:b7];
	[_backgrounds addObject:b8];
	[_backgrounds addObject:b9];
	[_backgrounds addObject:b10];
	[_backgrounds addObject:b11];
	[_backgrounds addObject:b12];
	[_backgrounds addObject:b13];
	[_backgrounds addObject:b14];
	[_backgrounds addObject:b15];
	[_backgrounds addObject:b16];
	[_backgrounds addObject:b17];
	
}

- (void)displayCommentsOfUsers
{
	//	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];
	
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];

	//[self resizeView];
	[self displaySection:@"commentCount" andView:@"user" withDuration:durationString];
	[self createCellsFromZero];
}

- (void)displayCommentsOfPages
{
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"switchMode"];
	
	//[self resizeView];
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];
	
	[self displaySection:@"commentCount" andView:@"page" withDuration:durationString];
	[self createCellsFromZero];
}


- (void)displayLikesOfPages
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"switchMode"];
	
	
	//[self resizeView];
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];
	
	[self displaySection:@"likeCount" andView:@"page" withDuration:durationString];
	[self createCellsFromZero];
}


- (void)displayLikesOfUsers
{
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
	
	//[self resizeView];
	
	NSString *durationString = [self returnDurationString:[[NSUserDefaults standardUserDefaults] integerForKey:@"durationMode"]];
	
	[self displaySection:@"likeCount" andView:@"user" withDuration:durationString];
	[self createCellsFromZero];
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

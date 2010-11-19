#import "TreeMapViewController.h"
#import "FbGraphFile.h"
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
@synthesize destinationPaths;
@synthesize treeMapView;

@synthesize plistArray;
//fcebook
@synthesize fbGraph;
@synthesize feedPostId;
@synthesize myWebView;



@synthesize jsonArray;

#pragma mark -
#pragma mark facebook delegate
- (void)viewDidLoad {
    [super viewDidLoad];
	imagesLoaded = YES;

	/*Facebook Application ID*/
	//NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];


	
	//alloc and initalize our FbGraph instance
	//self.fbGraph = [[FbGraph alloc] initWithFbClientID:client_id];
	
	
	//begin the authentication process.....
	//[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,read_stream,user_status, user_videos,publish_stream,offline_access"];
	
	/**
	 * OR you may wish to 'anchor' the login UIWebView to a window not at the root of your application...
	 * for example you may wish it to render/display inside a UITabBar view....
	 *
	 * Feel free to try both methods here, simply (un)comment out the appropriate one.....
	 **/
	
	
	//[self.view addSubview:self.myWebView];
	//	[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,read_stream,user_status,user_videos,publish_stream, offline_access" andSuperView:self.view];
	//[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access" andSuperView:self.view];
	
	
}


- (void)viewDidAppear:(BOOL)animated {
	
}



#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index {
	
	
	
	//maybe here do the all extravazanga<--------
	
	//check the type
	//if type is link
		//if type is extralink
		//if type is internalink
	
	//if type is status
	//if type is photo
	//if type is video
	//NSLog(@"---start here");
	//NSLog(@"index %i", index);
	//NSLog(@"type %@", [[fruits objectAtIndex:index] objectForKey:@"type"]);
	
	//NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
	//if the type === status
	if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"status"])
	{
	//	NSLog(@"STATUS");
		//NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
		
		CGSize maximumLabelSize = CGSizeMake(cell.frame.size.width-(10*2),9999);
		
		CGSize expectedLabelSize = [[[fruits objectAtIndex:index] objectForKey:@"message"] sizeWithFont:[UIFont systemFontOfSize:14] 
										  constrainedToSize:maximumLabelSize 
											  lineBreakMode:UILineBreakModeWordWrap]; 
		//adjust the label to the new height.
		CGRect newFrame = cell.countLabel.frame;
		newFrame.size.height = expectedLabelSize.height;
		cell.countLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
		//NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
		cell.countLabel.frame = newFrame;
		
	//	NSLog(@"---end here.");
	}//if the type === link
	else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"link"])
	{
	//	NSLog(@"LINK");
		if([[[fruits objectAtIndex:index] objectForKey:@"link"] isEqual:@"http://www.facebook.com/"])
		{//if the link is internal link
		//	NSLog(@"INTERNAL_LINK");
			cell.countLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
		//	NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
		//	NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
			//if it's the internal link then it could still be internal but the link part is different?
			//doublecheck
			
			
		//	NSLog(@"---end here.");
		}
		else
		{ //the link is external link.
			//grab the second part of the link.
		//	NSLog(@"EXTERNAL_LINK");
			
			
			//NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
		//	NSLog(@"link is %@", [[fruits objectAtIndex:index] objectForKey:@"link"]);
		//	NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
			/*
			 NSString *deviceToken = [[[[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"%2F"withString:@"/"] 
			 stringByReplacingOccurrencesOfString:@"%3A" withString:@":"] 
			 stringByReplacingOccurrencesOfString: @" " withString: @""];
			 */
			
			//done removing the percent escapes
			NSString *filePath = [[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//get the second url now:
		//	NSLog(@"picture is ----> %@", filePath);
			
			NSString *regexString   = @"url=(.+)";
			//also you can use look behind assertation.
			//(?<=url=).+
			NSString *matchedString   = [filePath stringByMatching:regexString capture:1L];
	
		//	NSLog(@"regexString is ----> %@", matchedString);
		//	NSLog(@"---end here.");
		}
	}//if the type === video
	else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"video"])
	{
		
		//TODO: the video could be external OR internal, check it here!
	//	NSLog(@"VIDEO");
	//	NSLog(@"link of video is %@", [[fruits objectAtIndex:index] objectForKey:@"link"]);
	//	NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
		
		/*
		NSString *deviceToken = [[[[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"%2F"withString:@"/"] 
								  stringByReplacingOccurrencesOfString:@"%3A" withString:@":"] 
								 stringByReplacingOccurrencesOfString: @" " withString: @""];
		*/
		
		//done removing the percent escapes
		NSString *filePath = [[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//get the second url now:
	//	NSLog(@"picture is ----> %@", filePath);
		
		NSString *regexString   = @"url=(.+)";
		//also you can use look behind assertation.
		//(?<=url=).+
		
		NSString *matchedString   = [filePath stringByMatching:regexString capture:1L] ;
		
		
		
	//	NSLog(@"picture is ----> %@", matchedString);
		
		
		
	//	NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
	//	NSLog(@"---end here.");
		cell.countLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
	}
	 else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"photo"])
	 {
	// NSLog(@"PHOTO");
	// NSLog(@"link of photo is %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
	 //the photo ends with _s but need to replace that with _n and load it. 
	//	 NSLog(@"---end here.");	 
	// NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
	// cell.countLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
	 }
	 
	

		
	//NSLog(@"cell %@", NSStringFromCGRect(cell.frame));
	
	//NSLog(@"cell bounds: %.0f, %.0f, %3.0f, %3.0f", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
	
	cell.nameLabel.text = [NSString stringWithFormat:@"%@ has %@ likes %@ comments" ,[[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"], [[fruits objectAtIndex:index] objectForKey:@"likes"], [[[fruits objectAtIndex:index] objectForKey:@"comments"] objectForKey:@"count"]];
	//cell.valueLabel.text = [NSString stringWithFormat:@"%@ comments", [[[fruits objectAtIndex:index] objectForKey:@"comments"] objectForKey:@"count"]];
	//if([cell.valueLabel.text isEqual:@"(null) comments"]) cell.valueLabel.text = [NSString stringWithFormat:@"0 comments"];
	//cell.backgroundColor = [UIColor colorWithHue:(float)index / (fruits.count + 3) saturation:1 brightness:0.75 alpha:.3];





		

	//NSLog(@"cell.downloadDestinationPath %@", cell.downloadDestinationPath);
	//if(cell.loaded)	cell.imageView.image = [self scaleAndCropFrame:cell.frame withUIImage:[UIImage imageWithContentsOfFile:cell.downloadDestinationPath]];

	 
	
	/**
	 * Rather than returing a url to the image, Facebook will stream an image file's bits back to us..
	 **/
	
	/*
	if (fb_graph_response.imageResponse != nil) 
	{
		cell.imageView.image = [self scaleAndCropFrame:cell.frame withUIImage:fb_graph_response.imageResponse];
   	}
	 */
	
	
}



#pragma mark -
#pragma mark TreemapView delegate

- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index {
	

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
	[UIView setAnimationsEnabled:NO];
	[(TreemapView *)self.treeMapView reloadData];
	[UIView setAnimationsEnabled:YES];
	//[UIView commitAnimations];
	
	
}

#pragma mark TreemapView data source
//values that are passed to treemapview --> anytime there's an action with the tableview, source gets called first.

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	NSLog(@"valuesForTreemapView");
	
	//TODO: check if the fruits is null when it's coming here/
	
	//if (!fruits) //meaning I just launched the app. 
//	{
		//need to fill the fruits 
		//get the plist

		
		NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex: 0];
		NSString *plistFile = [documentsDirectory stringByAppendingPathComponent: @"data.plist"];
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistFile]; 
		

		
		//if the plist doesn't exist meaning we just launched the app FOR THE FIRST TIME.
		if([array count] == 0) 
			//in this case we are using our plist file that's  bundled with the app.
		{
			NSBundle *bundle = [NSBundle mainBundle];
			NSString *plistPath = [bundle pathForResource:@"data" ofType:@"plist"];
			array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
			NSLog(@"array count is zero");
			
		}
		
		//trying to get the paths of the filenames and like counts here.
		
		self.fruits = [[NSMutableArray alloc] initWithCapacity:1];
		self.destinationPaths = [NSMutableArray arrayWithCapacity:1];
		//NSLog(@"array %@", array);
		//NSLog(@"fruits %@", fruits);
		
	
		//fruits is yet empty here.
		for (NSDictionary *dic in array)  
		{
			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			[fruits addObject:mDic];
		}
	//} //endif
	

	
	//these values go to the treemapview in order to be used for calculating the sizes of the cells
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:1];
	
	NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);

	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
	{
		for (NSDictionary *dic in fruits) 
		{
			// NSLog(@"fruit: %@", [dic objectForKey:@"likes"]);
			//passing the file names from the plist here. hmmmm.
			
			//@"comments.count"
			
			
			// [self.destinationPaths addObject:[dic objectForKey:@"destinationPath"]];
			if(![[dic objectForKey:@"likes"] isEqual:@"0"]) 
			{
				NSLog(@"dic is %@", dic);
				[values addObject:[dic objectForKey:@"likes"]];
			}
		}	
	}
	else //set to comments
	{
		NSLog(@"comments");
		for (NSDictionary *dic in fruits) 
		{
			// NSLog(@"fruit: %@", [dic objectForKey:@"likes"]);
			//passing the file names from the plist here. hmmmm.
			
			//@"comments.count"
			
			
			// [self.destinationPaths addObject:[dic objectForKey:@"destinationPath"]];
			if(![[dic objectForKey:@"comments"] isEqual:@"0"]) 
			{
				NSLog(@"dic is %@", dic);
				[values addObject:[dic objectForKey:@"comments"]];
			}
			
		}
	}//endelse
	NSLog(@"values %@", values);

	
	return values;
}


//this gets called @creation for each of the cell. 
- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect 
{
	TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
	
	
	NSLog(@"treemapView cellForIndex");
	NSLog(@"comments is %@", [[fruits objectAtIndex:index] objectForKey:@"comments"]);
	NSLog(@"likes is %@", [[fruits objectAtIndex:index] objectForKey:@"likes"]);

	//here give the document thingie so that we can load the images from the plist file.
	
	NSString *tText;
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
	{
		 tText = [[fruits objectAtIndex:index] objectForKey:@"likes"];
		NSLog(@"[[fruits objectAtIndex:index] objectForKey:@likes] %@", [[fruits objectAtIndex:index] objectForKey:@"likes"]);
		NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex: 0];
		//match the indexes through the cellForIndex/fruits objectAtIndex.
		NSString *fn = [documentsDirectory stringByAppendingPathComponent: [[fruits objectAtIndex:index] objectForKey:@"filename"]];
		//NSLog(@"fruits is here %@", fn);
		
		
		//NSSearchPathForDirectoriesInDomains
		
		//get the image from the filename.
		UIImage *img = [UIImage imageWithContentsOfFile:fn];
		
		
		//cell.downloadDestinationPath = fn;
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
	}
	else
	{
		tText = [[fruits objectAtIndex:index] objectForKey:@"comments"];
		NSLog(@"[[fruits objectAtIndex:index] objectForKey:comments] %@", [[fruits objectAtIndex:index] objectForKey:@"comments"]);
		NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex: 0];
		//match the indexes through the cellForIndex/fruits objectAtIndex.
		NSString *fn = [documentsDirectory stringByAppendingPathComponent: [[fruits objectAtIndex:index] objectForKey:@"filename"]];
		//NSLog(@"fruits is here %@", fn);
		
		//NSSearchPathForDirectoriesInDomains
		
		//get the image from the filename.
		UIImage *img = [UIImage imageWithContentsOfFile:fn];
		
		
		//cell.downloadDestinationPath = fn;
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		
	}
	
	NSLog(@"tXtext %@", tText);
	
	cell.countLabel.text = tText;
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








#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	
	//NSLog(@"self.bounds.size.width %f self.bounds.size.height %f",self.view.bounds.size.width,self.view.bounds.size.height);

	//if([(TreemapView*)self.treeMapView initialized]) [self resizeView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

	//if([(TreemapView*)self.treeMapView initialized]) [self resizeView];
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

#import "TreeMapViewController.h"
#import "FbGraphFile.h"
#import "SBJSON.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ProportionalFill.h"
#import "UIImage+Tint.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CellModel.h"

#define numberOfObjects (10)


@implementation TreeMapViewController

@synthesize fruits;
@synthesize cells;
@synthesize destinationPaths;

@synthesize myWebView;

//fcebook
@synthesize fbGraph;
@synthesize feedPostId;



#pragma mark -
#pragma mark facebook delegate
- (void)viewDidLoad {
    [super viewDidLoad];
	
}


- (void)viewDidAppear:(BOOL)animated {
	
	imagesLoaded - FALSE;
	
	/*Facebook Application ID*/
	NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];
	
	
	//alloc and initalize our FbGraph instance
	self.fbGraph = [[FbGraph alloc] initWithFbClientID:client_id];
	
	//begin the authentication process.....
	//[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access"];
	
	/**
	 * OR you may wish to 'anchor' the login UIWebView to a window not at the root of your application...
	 * for example you may wish it to render/display inside a UITabBar view....
	 *
	 * Feel free to try both methods here, simply (un)comment out the appropriate one.....
	 **/

	
	[self.view addSubview:self.myWebView];
	[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,read_stream,user_status,offline_access" andSuperView:self.myWebView];

	
}

#pragma mark -
#pragma mark FbGraph Callback Function
/**
 * This function is called by FbGraph after it's finished the authentication process
 **/
- (void)fbGraphCallback:(id)sender {
	
	//pop a message letting them know most of the info will be dumped in the log
	/* 
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"For the simplest code, I've written all output to the 'Debugger Console'." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];

	*/
	
	NSLog(@"------------>CONGRATULATIONS<------------, You're logged into Facebook...  Your oAuth token is:  %@", fbGraph.accessToken);
	
	[self.myWebView removeFromSuperview];
	
	[self getMeButtonPressed];
}

/**
 * DOC:  http://developers.facebook.com/docs/reference/api/photo
 **/


-(void)getMeButtonPressed
{
	
	NSLog(@"getMeButtonPressed");
	
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me/home" withGetVars:nil];
//	NSLog(@"fb_graph_response:  %@", fb_graph_response.htmlResponse);
    
	
	//parse the json into a NSDictionary
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsed_json = [parser objectWithString:fb_graph_response.htmlResponse error:nil];	
	
	
	
    
	//there's 2 additional dictionaries inside this one on the first level ('data' and 'paging')
	NSDictionary *firstPageData = (NSDictionary *)[parsed_json objectForKey:@"data"];
    NSDictionary *secondPage = (NSDictionary *)[parsed_json objectForKey:@"paging"];
	FbGraphResponse *fb_graph_response_page2 = [fbGraph doGraphGetWithUrlString:[secondPage objectForKey:@"next"]];
	NSDictionary *parsed_json2 = [parser objectWithString:fb_graph_response_page2.htmlResponse error:nil];	
	
	
		
	

	NSDictionary *secondPageData = (NSDictionary *)[parsed_json2 objectForKey:@"data"];
    NSDictionary *thirdPage = (NSDictionary *)[parsed_json2 objectForKey:@"paging"];
	
	FbGraphResponse *fb_graph_response_page3 = [fbGraph doGraphGetWithUrlString:[thirdPage objectForKey:@"next"]];
	NSDictionary *parsed_json3 = [parser objectWithString:fb_graph_response_page3.htmlResponse error:nil];	
	
	NSDictionary *thirdPageData = (NSDictionary *)[parsed_json3 objectForKey:@"data"];
    //NSDictionary *fourthPage = (NSDictionary *)[parsed_json3 objectForKey:@"paging"];

	
	[parser release];

    self.fruits = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary *item in firstPageData) 
	{
	
       		[fruits addObject:item];

    }
	
	for (NSDictionary *item in secondPageData) 
	{
		
     	[fruits addObject:item];
		
    }
	
	for (NSDictionary *item in thirdPageData) 
	{
		
   		[fruits addObject:item];
			
    }
		
	
	/*Bring the contacts back to 15 according to the values of @value!*/
	[self filterEntries:fruits];

	//[(TreemapView *)self.view reloadData];
	[self callAPI];
}




-(void) filterEntries:(NSMutableArray*)mutableArray
{
	//here we are sorting according to value.
	
	
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"likes" ascending: NO];
	[mutableArray sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
	[sortDescriptor release];
	
	// here  we are getting rid of the rest of the objects after numberOfObjects
	
	[mutableArray removeObjectsInRange: NSMakeRange(numberOfObjects,[mutableArray count]-numberOfObjects)];
	
	
}


- (void) callAPI
{
	//NSLog(@"fruits %@", fruits);
	
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];	
	}
	
	failed = NO;
	[networkQueue reset];
	//[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(imageFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(imageFetchFailed:)];
	[networkQueue setQueueDidFinishSelector:@selector(queueComplete:)]; 
	//[networkQueue setShowAccurateProgress:[accurateProgress isOn]];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
	[networkQueue go];
	
	
	
	for (NSInteger i = 0; i < [fruits count]; i++)
	{
		//images
		NSString *get_string = [NSString stringWithFormat:@"%@/picture", [[[fruits objectAtIndex:i] objectForKey:@"from"] objectForKey:@"id"]];
		NSLog(@"getString: %@",get_string);
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
		
		[variables setObject:@"large" forKey:@"type"];
		
		NSString *url_string = [fbGraph returnURL:get_string withGetVars:variables];
		//need to send the full url here as a ASIRequest.
		NSLog(@"url_string %@", url_string);
		
		request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url_string]] autorelease];
		[request setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber   
																 numberWithInt:i] forKey:@"ImageNumber"]]; 
		[request setDownloadDestinationPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.png",i]]];
	//	[request setDownloadProgressDelegate:imageProgressIndicator1];
		[networkQueue addOperation:request];
		
	}
	
}

- (void)imageFetchComplete:(ASIHTTPRequest *)request
{
	UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
	if (img) 
	{
		NSLog(@"here");
	
		int imageNo =  [[[request userInfo] objectForKey:@"ImageNumber"] intValue]; 
		
		TreemapViewCell *cell = [self.cells objectAtIndex:imageNo];
		cell.imageView.image = [self scaleAndCropFrame:cell.frame withUIImage:img];
		cell.downloadDestinationPath = [request downloadDestinationPath];
		NSLog(@"cell.downloadDestinationPath %@", cell.downloadDestinationPath);
		
	}
	
}

- (void)imageFetchFailed:(ASIHTTPRequest *)request
{
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}		failed = YES;
	}
}


- (void)queueComplete:(ASINetworkQueue*)queue
{
	NSLog(@"Queue finished");
	imagesLoaded = YES;
//	[(TreemapView *)self.view reloadData];
	
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
	NSLog(@"---start here");
	NSLog(@"index %i", index);
	NSLog(@"type %@", [[fruits objectAtIndex:index] objectForKey:@"type"]);
	
	NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
	//if the type === status
	if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"status"])
	{
		NSLog(@"STATUS");
		//NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
		
		CGSize maximumLabelSize = CGSizeMake(cell.frame.size.width-(10*2),9999);
		
		CGSize expectedLabelSize = [[[fruits objectAtIndex:index] objectForKey:@"message"] sizeWithFont:[UIFont systemFontOfSize:14] 
										  constrainedToSize:maximumLabelSize 
											  lineBreakMode:UILineBreakModeWordWrap]; 
		//adjust the label to the new height.
		CGRect newFrame = cell.textLabel.frame;
		newFrame.size.height = expectedLabelSize.height;
		cell.textLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
		NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
		cell.textLabel.frame = newFrame;
		
		NSLog(@"---end here.");
	}//if the type === link
	else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"link"])
	{
		NSLog(@"LINK");
		if([[[fruits objectAtIndex:index] objectForKey:@"link"] isEqual:@"http://www.facebook.com/"])
		{//if the link is internal link
			NSLog(@"INTERNAL_LINK");
			cell.textLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
			NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
			NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
			//if it's the internal link then it could still be internal but the link part is different?
			//doublecheck
			
			
			NSLog(@"---end here.");
		}
		else
		{ //the link is external link.
			//grab the second part of the link.
			NSLog(@"EXTERNAL_LINK");
			
			
			//NSLog(@"from is ----> %@", [[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"]);
			NSLog(@"link is %@", [[fruits objectAtIndex:index] objectForKey:@"link"]);
			NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
			/*
			 NSString *deviceToken = [[[[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"%2F"withString:@"/"] 
			 stringByReplacingOccurrencesOfString:@"%3A" withString:@":"] 
			 stringByReplacingOccurrencesOfString: @" " withString: @""];
			 */
			
			//done removing the percent escapes
			NSString *filePath = [[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//get the second url now:
			NSLog(@"picture is ----> %@", filePath);
			
			NSString *regexString   = @"url=(.+)";
			//also you can use look behind assertation.
			//(?<=url=).+
			NSString *matchedString   = [filePath stringByMatching:regexString capture:1L];
	
			NSLog(@"regexString is ----> %@", matchedString);
			NSLog(@"---end here.");
		}
	}//if the type === video
	else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"video"])
	{
		
		//TODO: the vide could be external OR internal, check it here!
		NSLog(@"VIDEO");
		NSLog(@"link of video is %@", [[fruits objectAtIndex:index] objectForKey:@"link"]);
		NSLog(@"picture is ----> %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
		
		/*
		NSString *deviceToken = [[[[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"%2F"withString:@"/"] 
								  stringByReplacingOccurrencesOfString:@"%3A" withString:@":"] 
								 stringByReplacingOccurrencesOfString: @" " withString: @""];
		*/
		
		//done removing the percent escapes
		NSString *filePath = [[[fruits objectAtIndex:index] objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//get the second url now:
		NSLog(@"picture is ----> %@", filePath);
		
		NSString *regexString   = @"url=(.+)";
		//also you can use look behind assertation.
		//(?<=url=).+
		
		NSString *matchedString   = [filePath stringByMatching:regexString capture:1L] ;
		
		
		
		NSLog(@"picture is ----> %@", matchedString);
		
		
		
		NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
		NSLog(@"---end here.");
		cell.textLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
	}
	 else if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"photo"])
	 {
	 NSLog(@"PHOTO");
	 NSLog(@"link of photo is %@", [[fruits objectAtIndex:index] objectForKey:@"picture"]);
	 //the photo ends with _s but need to replace that with _n and load it. 
		 NSLog(@"---end here.");	 
	// NSLog(@"message  %@", [[fruits objectAtIndex:index] objectForKey:@"message"]);
	// cell.textLabel.text = [[fruits objectAtIndex:index] objectForKey:@"message"];
	 }
	 
	

		
	//NSLog(@"cell %@", NSStringFromCGRect(cell.frame));
	
	//NSLog(@"cell bounds: %.0f, %.0f, %3.0f, %3.0f", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
	
//	cell.nameLabel.text = [NSString stringWithFormat:@"%@ has %@ likes" ,[[[fruits objectAtIndex:index] objectForKey:@"from"] objectForKey:@"name"], [[fruits objectAtIndex:index] objectForKey:@"likes"]];
//	cell.valueLabel.text = [NSString stringWithFormat:@"%@ comments", [[[fruits objectAtIndex:index] objectForKey:@"comments"] objectForKey:@"count"]];
	//if([cell.valueLabel.text isEqual:@"(null) comments"]) cell.valueLabel.text = [NSString stringWithFormat:@"0 comments"];
	//cell.backgroundColor = [UIColor colorWithHue:(float)index / (fruits.count + 3) saturation:1 brightness:0.75 alpha:.3];





		

	NSLog(@"cell.downloadDestinationPath %@", cell.downloadDestinationPath);
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
	

	TreemapViewCell *cell = (TreemapViewCell *)[self.view.subviews objectAtIndex:index];
	
	[cell flipIt];
/*
	
	

	CABasicAnimation *animation = nil;

	[cell.layer removeAllAnimations]; 

	
	animation = [CABasicAnimation animationWithKeyPath:@"position"]; 
	


	[animation setFromValue:[NSValue valueWithCGPoint:cell.frame.origin]];
	[animation setToValue:[NSValue valueWithCGPoint:CGPointMake(500, 500)]];
	//[animation setAutoreverses:YES]; 
	[animation setDuration:1.0f]; 
	//[animation setRepeatCount:100];
	[cell.layer addAnimation:animation forKey:@"transform"];
	//cell.layer.position = CGPointMake(500, 500);
	
	NSLog(@"cell : %@", cell);
	*/

	/*
	TreemapViewCell *cell = (TreemapViewCell *)[self.view.subviews objectAtIndex:index];
	[cell setBackgroundColor:[UIColor whiteColor]];
	cell.layer.borderWidth = 0.0;
	cell.imageView.image = nil;
	//cell.transform = CGAffineTransformMakeScale(2,2);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.];
	//cell.transform = CGAffineTransformMakeScale(1,1);
	//cell.alpha = 1.0;
	cell.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	
	//NSLog(@"self.view.bounds : %@",NSStringFromCGRect(self.view.bounds) );


		
	[UIView commitAnimations];
	
	
	[self.view bringSubviewToFront:cell];
	 
	 
	  */
	
}

#pragma mark -



- (UIImage *)scaleAndCropFrame:(CGRect)rect withUIImage:(UIImage*)image  
{
	
	UIImage *newImage;

	
	
	//BOOL widthGreaterThanHeight = (image.size.width > image.size.height);
	
	//float sideFull = (widthGreaterThanHeight) ? rect.size.height : rect.size.width;
	//newImage = [image imageScaledToFitSize:CGSizeMake(sideFull, sideFull)];
	newImage = [image imageCroppedToFitSize:rect.size];
	
	
	
	return newImage;
}

									  
									  
									  

- (void)resizeView
{
	
	// resize rectangles with animation
	 
	[UIView beginAnimations:@"reload" context:nil];
	[UIView setAnimationDuration:0.5];
	
	[(TreemapView *)self.view reloadData];
	
	[UIView commitAnimations];
}

#pragma mark TreemapView data source
//this gets called when resizing to get the datasource or creating the first time too. 
- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	NSLog(@"valuesForTreemapView");
	if (!fruits) //meaning just launched the app. 
	{
		//NSLog(@"valuesForTreemapView");
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath = [bundle pathForResource:@"data" ofType:@"plist"];
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
		
		self.fruits = [[NSMutableArray alloc] initWithCapacity:array.count];
		
		for (NSDictionary *dic in array) 
		{
			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			[fruits addObject:mDic];
		 }
	}
	
	
	
	//these values go to the treemapview in order to be used for calculating the sizes of the cells
	// no need to store those in the cellModel.
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:fruits.count];
	destinationPaths = [NSMutableArray arrayWithCapacity:fruits.count];

	for (NSDictionary *dic in fruits) 
	 {
		 NSLog(@"fruit: %@", [dic objectForKey:@"likes"]);
		 [self.destinationPaths addObject:[dic objectForKey:@"destinationPath"]];
		 if([dic objectForKey:@"likes"]) 
		 {
			 [values addObject:[dic objectForKey:@"likes"]];
		 }
		 else 
		 {
			[values addObject:@"0"];
		 }
	}
	return values;
}


//this gets called on the creation/initially. 
- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect {
	TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
	
	//here give the document thingie.
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex: 0];
	
	NSString *fn = [documentsDirectory stringByAppendingPathComponent: [destinationPaths objectAtIndex:index]];
	
	//NSString *fn = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[destinationPaths objectAtIndex:index]];
	//NSSearchPathForDirectoriesInDomains
					
	NSLog(@"fn %@", fn);
	cell.downloadDestinationPath = fn;
	
	//CellModel *cellModel = [[CellModel alloc] initWithFrame:rect atIndex:index];
	[self.cells addObject:cell];
	[cell release];
	
	[self updateCell:cell forIndex:index];
	return cell;
}


//this gets called on the update 
- (void)treemapView:(TreemapView *)treemapView updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index forRect:(CGRect)rect {

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

	if([(TreemapView*)self.view initialized]) [self resizeView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

//	if([(TreemapView*)self.view initialized]) [self resizeView];
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

#import "TreeMapViewController.h"
#import "FbGraphFile.h"
#import "SBJSON.h"
#import <QuartzCore/QuartzCore.h>


#define numberOfObjects (10)


@implementation TreeMapViewController

@synthesize fruits;
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
	
	/*Facebook Application ID*/
	NSString *client_id = @"128496757192973";
	
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
    	[self getMeButtonPressed];
}

/**
 * DOC:  http://developers.facebook.com/docs/reference/api/photo
 **/


-(void)getMeButtonPressed
{
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
		
		NSLog(@"item %@", item);

	    //NSString *likes = [NSString stringWithFormat:@"%@", [item objectForKey:@"likes"]];
		
        NSNumber *value = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"likes"]] intValue ]];
		NSDictionary *fromDict = [NSDictionary dictionaryWithDictionary:[item objectForKey:@"from"]];
      //  NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"type"]];

        
      
       // NSLog(@"from: %@", [fromDict objectForKey:@"name"]);

        
		//NSLog(@"type : %@", type);

		
		NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
								[fromDict objectForKey:@"name"], @"name", 
								  [fromDict objectForKey:@"id"], @"id",
								 value, @"value", nil];
		//NSLog(@"contact %@", contact);
		[fruits addObject:contact];
    }
	
	for (NSDictionary *item in secondPageData) 
	{
		NSLog(@"item %@", item);
		
	    //NSString *likes = [NSString stringWithFormat:@"%@", [item objectForKey:@"likes"]];
		
        NSNumber *value = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"likes"]] intValue ]];
		NSDictionary *fromDict = [NSDictionary dictionaryWithDictionary:[item objectForKey:@"from"]];
		NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"type"]];
		
        
		
		// NSLog(@"from: %@", [fromDict objectForKey:@"name"]);
		
        
		NSLog(@"type : %@", type);
		
		//[fromDict objectForKey:@"id"] ---> how to get the picture of the person?
		
		
		NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
								 [fromDict objectForKey:@"name"], @"name", 
								 [fromDict objectForKey:@"id"], @"id",
								 value, @"value", nil];
		
		
		//NSLog(@"contact %@", contact);
		[fruits addObject:contact];
		
		
		
		
    }
	
	for (NSDictionary *item in thirdPageData) 
	{
		
		NSLog(@"item %@", item);
		
		
	    //NSString *likes = [NSString stringWithFormat:@"%@", [item objectForKey:@"likes"]];
		
        NSNumber *value = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@",[item objectForKey:@"likes"]] intValue ]];
		NSDictionary *fromDict = [NSDictionary dictionaryWithDictionary:[item objectForKey:@"from"]];
		NSString *type = [NSString stringWithFormat:@"%@", [item objectForKey:@"type"]];
		
        
		
		// NSLog(@"from: %@", [fromDict objectForKey:@"name"]);
		
        
		NSLog(@"type : %@", type);
		
		
		NSDictionary *contact = [NSDictionary dictionaryWithObjectsAndKeys:
								 [fromDict objectForKey:@"name"], @"name", 
								  [fromDict objectForKey:@"id"], @"id",
								 value, @"value", nil];
		
		
		//NSLog(@"contact %@", contact);
		[fruits addObject:contact];
		
		
		
		
    }
	
	/*Bring the contacts back to 15 according to the values of @value!*/
	[self filterEntries:fruits];
	
	
	

	[(TreemapView *)self.view reloadData];
}



-(void) filterEntries:(NSMutableArray*)mutableArray
{
	

	
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"value" ascending: NO];
		[mutableArray sortUsingDescriptors: [NSArray arrayWithObject: sortDescriptor]];
		[sortDescriptor release];

		[mutableArray removeObjectsInRange: NSMakeRange(numberOfObjects,[mutableArray count]-numberOfObjects)];
	
	for (NSDictionary *item in mutableArray) 
	{
		NSLog(@"value : %@", [item objectForKey:@"value"]);
	}
	
}

-(void)getAuthorPictureButtonPressed 
{
   // http://graph.facebook.com/stephanvalter/picture?type=large
	
	NSString *get_string = [NSString stringWithFormat:@"%@/picture", @"stephanvalter"];
   // NSLog(@"getString: %@",get_string);
    NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [variables setObject:@"large" forKey:@"type"];
    
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:get_string withGetVars:variables];
	
	/**
	 * Rather than returing a url to the image, Facebook will stream an image file's bits back to us..
	 **/
	if (fb_graph_response.imageResponse != nil) {
		
        /*
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Author's Avatar" message:@"~Cheese~" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		//simply set the UIImage we have in the image view to display....easy as pie.....mmmm pie....
		UIImageView *image_view = [[UIImageView alloc] initWithImage:fb_graph_response.imageResponse];
		[alert addSubview:image_view];
		[alert show];
         
         */
        CGRect imageViewFrame = [self.view frame];
        
        imageViewFrame.origin.y = 0;

        
        UIImageView *image_view = [[UIImageView alloc] initWithImage:fb_graph_response.imageResponse];
        
        image_view.frame = imageViewFrame;
        [self.view addSubview:image_view];


		
	}//end if
}





#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index {
	NSNumber *val = [[fruits objectAtIndex:index] valueForKey:@"value"];
	
	
	//NSLog(@"cell %@", NSStringFromCGRect(cell.frame));
	
	NSLog(@"cell bounds: %.0f, %.0f, %3.0f, %3.0f", cell.frame.origin.x, cell.frame.origin.x, cell.frame.size.width, cell.frame.size.height);
	cell.textLabel.text = [[fruits objectAtIndex:index] valueForKey:@"name"];
	cell.valueLabel.text = [val stringValue];
	cell.backgroundColor = [UIColor colorWithHue:(float)index / (fruits.count + 3) saturation:1 brightness:0.75 alpha:.3];
	
	//imageview
	
	NSString *get_string = [NSString stringWithFormat:@"%@/picture", [[fruits objectAtIndex:index] valueForKey:@"id"]];
	// NSLog(@"getString: %@",get_string);
    NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [variables setObject:@"large" forKey:@"type"];
    
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:get_string withGetVars:variables];
	
	/**
	 * Rather than returing a url to the image, Facebook will stream an image file's bits back to us..
	 **/
	if (fb_graph_response.imageResponse != nil) 
	{
		
       
     //   CGRect imageViewFrame = [self.view frame];
        
      //  imageViewFrame.origin.y = 0;
		
        
       
        //CGRect imageViewFrame = [self.view frame];
        
       // imageViewFrame.origin.y = 0;
		
        
        //UIImageView *image_view = [[UIImageView alloc] initWithImage:fb_graph_response.imageResponse];
        
		
		
       // image_view.frame = imageViewFrame;
		cell.imageView.image = [self scaleAndCropFrame:cell.frame withUIImage:fb_graph_response.imageResponse];
		
     //   [self.view addSubview:image_view];
    //    image_view.frame = imageViewFrame;
     //   [self.view addSubview:image_view];

	}
		
	
		
}

#pragma mark -
#pragma mark TreemapView delegate

- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index {
	
	 // change the value
	 
	//NSDictionary *dic = [fruits objectAtIndex:index];
	//[dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"value"] intValue] + 300] forKey:@"value"];
	
	
	 //resize rectangles with animation
	 
	//[self resizeView];
	
	
    //highlight the background
	 
	[UIView beginAnimations:@"highlight" context:nil];
	[UIView setAnimationDuration:1.0];
	
	TreemapViewCell *cell = (TreemapViewCell *)[self.view.subviews objectAtIndex:index];
	UIColor *color = cell.backgroundColor;
	[cell setBackgroundColor:[UIColor whiteColor]];
	[cell setBackgroundColor:color];
	
	[UIView commitAnimations];
}

#pragma mark -



- (UIImage *)scaleAndCropFrame:(CGRect)rect withUIImage:(UIImage*)image  
{
	//couldn’t find a previously created thumb image so create one first…
	
	UIImageView *mainImageView = [[UIImageView alloc] initWithImage:image];
	BOOL widthGreaterThanHeight = (image.size.width > image.size.height);
	float sideFull = (widthGreaterThanHeight) ? rect.size.height : rect.size.width;
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	//creating a square context the size of the final image which we will then
	// manipulate and transform before drawing in the original image
	UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextClipToRect( currentContext, clippedRect);
	

	if (widthGreaterThanHeight) {
		CGFloat scaleFactor = rect.size.width/sideFull;
		//a landscape image – make context shift the original image to the left when drawn into the context
		CGContextTranslateCTM(currentContext, -((image.size.width-sideFull)*.5)*scaleFactor, 0);
		CGContextScaleCTM(currentContext, scaleFactor, scaleFactor);
	}
	else {
		CGFloat scaleFactor = rect.size.height/sideFull;
		//a portfolio image – make context shift the original image upwards when drawn into the context
		CGContextTranslateCTM(currentContext,0, -((image.size.height-sideFull)*.5)*scaleFactor);
		CGContextScaleCTM(currentContext, scaleFactor, scaleFactor);
	}
	//this will automatically scale any CGImage down/up to the required thumbnail side (length) when the CGImage gets drawn into the context on the next line of code
	
	[mainImageView.layer renderInContext:currentContext];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
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

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView 
{
	
	if (!fruits) 
	{
	
		/*
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath = [bundle pathForResource:@"data" ofType:@"plist"];
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
		
		self.fruits = [[NSMutableArray alloc] initWithCapacity:array.count];
		for (NSDictionary *dic in array) 
		{
			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			[fruits addObject:mDic];
		
		 }
		 */
		
	}
	
	//NSLog(@"fruits: %@", fruits);
	
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:fruits.count];
	for (NSDictionary *dic in fruits) 
	 {
		[values addObject:[dic valueForKey:@"value"]];
	}
	return values;
}



- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect {
	TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
	[self updateCell:cell forIndex:index];
	return cell;
}

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
	//NSLog(@" self.interfaceOrientation %d", [self interfaceOrientation]);
	if([(TreemapView*)self.view initialized]) [self resizeView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if([(TreemapView*)self.view initialized]) [self resizeView];
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

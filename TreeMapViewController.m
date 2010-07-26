#import "TreeMapViewController.h"
#import "FbGraphFile.h"
#import "SBJSON.h"


@implementation TreeMapViewController

@synthesize fruits;

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
		[fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access" andSuperView:self.view];
	
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
    [self getAuthorPictureButtonPressed];
}

/**
 * DOC:  http://developers.facebook.com/docs/reference/api/photo
 **/


-(void)getMeButtonPressed
{
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:nil];
	NSLog(@"getMeButtonPressed:  %@", fb_graph_response.htmlResponse);
	
}



-(void)stephanPressed
{
	
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[variables setObject:@"type" forKey:@"large"];

    
	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"search" withGetVars:variables];
    
	NSLog(@"Raw HTML:  %@", fb_graph_response.htmlResponse);
    
	/**
	 * Lets go into some level of detail of how to parse data out of
	 * the JSON formated response data we get from Facebook.
	 * Personally I like the SBJSON parser which can be found here:
	 * http://code.google.com/p/json-framework/
	 *
	 * There's several solid examples to be found via Google, here's how
	 * I use it....
	 */
	
	//parse the json into a NSDictionary
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *parsed_json = [parser objectWithString:fb_graph_response.htmlResponse error:nil];	
	[parser release];
    
	//there's 2 additional dictionaries inside this one on the first level ('data' and 'paging')
	NSDictionary *data = (NSDictionary *)[parsed_json objectForKey:@"data"];
	
	//how many wall posts have been returned that meet our search criteria (25 max by default)
	NSLog(@"# search results:  %i", [data count]);
    
	NSEnumerator *enumerator = [data objectEnumerator];
	NSDictionary *wall_post;
	
	while ((wall_post = (NSDictionary *)[enumerator nextObject])) {
		
		NSDictionary *posted_by_dict = (NSDictionary *)[wall_post objectForKey:@"from"];
		NSString *from_name = (NSString *)[posted_by_dict objectForKey:@"name"];
		NSString *from_fb_id = (NSString *)[posted_by_dict objectForKey:@"id"];
		
		NSString *message = (NSString *)[wall_post objectForKey:@"message"];
        
		NSLog(@"FromName (FB ID):  Message:  %@ (%@):  %@", from_name, from_fb_id, message);
	}
	
	//Just so you know, this is how the pagination works...Facebook returns to
	//us a link with two links (next & previous)
	NSDictionary *paging = (NSDictionary *)[parsed_json objectForKey:@"paging"];
	NSString *next_page_url = (NSString *)[paging objectForKey:@"next"];
    
	FbGraphResponse *next_page_fb_graph_response = [fbGraph doGraphGetWithUrlString:next_page_url];
    
	NSLog(@"Next Page:  %@", next_page_fb_graph_response.htmlResponse);
}





-(void)getAuthorPictureButtonPressed 
{
   // http://graph.facebook.com/stephanvalter/picture?type=large
	
	NSString *get_string = [NSString stringWithFormat:@"%@/picture", @"stephanvalter"];
    NSLog(@"getString: %@",get_string);
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




/*
#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index {
	NSNumber *val = [[fruits objectAtIndex:index] valueForKey:@"value"];
	cell.textLabel.text = [[fruits objectAtIndex:index] valueForKey:@"name"];
	cell.valueLabel.text = [val stringValue];
	cell.backgroundColor = [UIColor colorWithHue:(float)index / (fruits.count + 3)
									  saturation:1 brightness:0.75 alpha:1];
	
	
}

#pragma mark -
#pragma mark TreemapView delegate

- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index {
	
	 // change the value
	 
	NSDictionary *dic = [fruits objectAtIndex:index];
	[dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"value"] intValue] + 300] forKey:@"value"];
	
	
	 //resize rectangles with animation
	 
	[self resizeView];
	
	
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


- (void)resizeView
{
	
	// resize rectangles with animation
	 
	[UIView beginAnimations:@"reload" context:nil];
	[UIView setAnimationDuration:0.5];
	
	[(TreemapView *)self.view reloadData];
	
	[UIView commitAnimations];
}

#pragma mark TreemapView data source

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView {
	if (!fruits) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath = [bundle pathForResource:@"data" ofType:@"plist"];
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
		
		self.fruits = [[NSMutableArray alloc] initWithCapacity:array.count];
		for (NSDictionary *dic in array) {
			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			[fruits addObject:mDic];
		}
	}
	
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:fruits.count];
	for (NSDictionary *dic in fruits) {
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

*/

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

/*
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	//NSLog(@"self.bounds.size.width %f self.bounds.size.height %f",self.view.bounds.size.width,self.view.bounds.size.height);
	//NSLog(@" self.interfaceOrientation %d", [self interfaceOrientation]);
	if([(TreemapView*)self.view initialized]) [self resizeView];
}
*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if([(TreemapView*)self.view initialized]) [self resizeView];
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

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



#pragma mark -
#pragma mark facebook delegate
- (void)viewDidLoad {
    [super viewDidLoad];
	imagesLoaded = YES;

	/*Facebook Application ID*/
	//NSString *client_id = @"128496757192973";
	self.cells = [[NSMutableArray alloc] initWithCapacity:2];

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
	NSString *plistFile;
	
	NSLog(@"view mode is %i",[[NSUserDefaults standardUserDefaults] integerForKey:@"viewMode"] );
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"viewMode"])
	{
		plistFile = [documentsDirectory stringByAppendingPathComponent: @"userData.plist"];
	}
	else 
	{
		plistFile = [documentsDirectory stringByAppendingPathComponent: @"pageData.plist"];
	}

	
	NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:plistFile]; 
	
	NSLog(@"array is %@", array);
	
	//if the plist doesn't exist meaning we just launched the app FOR THE FIRST TIME.
	if([array count] == 0) 
		//in this case we are using our plist file that's  bundled with the app.
	{
		NSBundle *bundle = [NSBundle mainBundle];
		NSString *plistPath = [bundle pathForResource:@"data" ofType:@"plist"];
		array = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
		NSLog(@"array count is zero");
	}
	
	NSLog(@"array is %@", array);
	//trying to get the paths of the filenames and like counts here.
	
	self.fruits = [[NSMutableArray alloc] initWithCapacity:1];

	//NSLog(@"array %@", array);
	//NSLog(@"fruits %@", fruits);
	
	
	//fruits is yet empty here.
	for (NSDictionary *dic in array)  
	{
		NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
		[fruits addObject:mDic];
	}
	//} //endif
	
	[array release];
	
	//these values go to the treemapview in order to be used for calculating the sizes of the cells
	NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:1];
	
	NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	
	
	for (NSDictionary *dic in fruits) 
	{

		if(![[dic objectForKey:@"categoryValue"] isEqual:@"0"]) 
		{
		//	NSLog(@"dic is %@", dic);
			NSNumber *value = [dic objectForKey:@"categoryValue"];
			[valuesArray addObject:value];
		}
		
		
		
	}
	
	
	NSLog(@"values %@", valuesArray);
	
	
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"viewMode"])
	{
		//little hack to bump up the value of the largest item. this gives us a larger cell.
		//this still needs to be improved. -what happens when there's two equal values? need to solve that.
		
		int highestNumber					= 0;
		int highestSecondNumber				= 0;
		int highestNumberIndex				= 0;
		int highestSecondNumberIndex		= 0;
		for (NSNumber *theNumber in valuesArray)
		{
			if ([theNumber intValue] >= highestNumber) {
				highestSecondNumberIndex = highestNumberIndex;
				highestSecondNumber = highestNumber;
				highestNumber = [theNumber intValue];
				highestNumberIndex = [valuesArray indexOfObject:theNumber];
			}
			else if([theNumber intValue] > highestSecondNumber)
			{
				highestSecondNumber = [theNumber intValue];
				highestSecondNumberIndex = [valuesArray indexOfObject:theNumber];
			}
		}//endfor
		//TODO: if there's two 1 and 1 item, then this gets called. need to fix it. 
		if((highestNumber/highestSecondNumber) < 2 || highestNumber==highestSecondNumber) //if there's no duplicate winners AND difference between first two highest number is 1/2 then multiply.
		{
			
			NSInteger tempValue = [[valuesArray objectAtIndex:highestNumberIndex] intValue];
			
			tempValue = round(tempValue*1.5);
			NSNumber *_inStr = [NSNumber numberWithInt:tempValue];
			[valuesArray replaceObjectAtIndex:highestNumberIndex withObject:_inStr];
			
			NSLog(@"tempValue is %i", tempValue);
			
			
		}//endif
		
		NSLog(@"Highest number: %i at index: %i", highestNumber, highestNumberIndex);
		NSLog(@"Highest number: %i at index: %i", highestSecondNumber, highestSecondNumberIndex);
		

	}
	else 
	{
		
	}//endelse

		
		
	
	return valuesArray;

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
	
	
	NSString *tText = [[fruits objectAtIndex:index] objectForKey:@"categoryValue"];
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex: 0];
	//match the indexes through the cellForIndex/fruits objectAtIndex.
	NSString *fn = [documentsDirectory stringByAppendingPathComponent: [[fruits objectAtIndex:index] objectForKey:@"filename"]];
	UIImage *img = [UIImage imageWithContentsOfFile:fn];
	
	if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"video"])
	{
		
		cell.imageViewA.image = img;
		cell.playBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		cell.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
		cell.playBtn.frame = CGRectMake((cell.imageViewA.bounds.size.width-cell.playBtn.bounds.size.width)/2, (cell.imageViewA.bounds.size.height-cell.playBtn.bounds.size.height)/2, cell.playBtn.frame.size.width, cell.playBtn.frame.size.height);
		UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
		[cell.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
		[tImage release];
		
		[cell.aView addSubview:cell.playBtn];
		cell.contentLabel.text = @"";//	[[fruits objectAtIndex:index] objectForKey:@"message"];

	}
	else
	{
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
		cell.contentLabel.text = 	[[fruits objectAtIndex:index] objectForKey:@"message"];

	}
	   
	cell.countLabel.text = tText;
	cell.titleLabel.text = [[[fruits objectAtIndex:index] objectForKey:@"from"] uppercaseString];
	
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

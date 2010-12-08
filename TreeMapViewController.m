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
	[self setTheBackgroundArray];	
	
	
}


- (void)viewDidAppear:(BOOL)animated {
	
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


#pragma mark -

- (void)updateCell:(TreemapViewCell *)cell forIndex:(NSInteger)index {
	
	
	
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
	
	
	for (NSDictionary *dic in fruits) 
	{
		// NSLog(@"fruit: %@", [dic objectForKey:@"likes"]);
		//passing the file names from the plist here. hmmmm.
		
		//@"comments.count"
		
		
		// [self.destinationPaths addObject:[dic objectForKey:@"destinationPath"]];
		if(![[dic objectForKey:@"categoryValue"] isEqual:@"0"]) 
		{
			NSLog(@"dic is %@", dic);
			[values addObject:[dic objectForKey:@"categoryValue"]];
		}
		
	}
	
	NSLog(@"values %@", values);
	
	
	return values;
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
	
	NSLog(@"_backgrounds %@", _backgrounds);
	
	
	if([[[fruits objectAtIndex:index] objectForKey:@"type"] isEqual:@"status"])
	{
		NSLog(@"this should be status");
		NSInteger rand_ind = arc4random() % [_backgrounds count];
		
		UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_backgrounds objectAtIndex:rand_ind]  ofType:@"png"]];
		
		[_backgrounds removeObjectAtIndex:rand_ind];
		
		if([_backgrounds count] < 1) [self setTheBackgroundArray];
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
	}
	else 
	{
		NSLog(@"this should NOT be status");
		UIImage *img = [UIImage imageWithContentsOfFile:fn];
		cell.imageViewA.image = [img imageCroppedToFitSize:cell.frame.size];
	}

	   
	//check the type of the post and pass an image accordingly.
	
	//cell.downloadDestinationPath = fn;
	
	
	NSLog(@"tXtext %@", tText);
	NSLog(@"[[fruits objectAtIndex:index] objectForKey:from %@", [[fruits objectAtIndex:index] objectForKey:@"from"]);
	cell.contentLabel.text = 	[[fruits objectAtIndex:index] objectForKey:@"message"];
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

#import "TreeMapViewController.h"

@implementation TreeMapViewController

@synthesize fruits;

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
	/*
	 * change the value
	 */
	NSDictionary *dic = [fruits objectAtIndex:index];
	[dic setValue:[NSNumber numberWithInt:[[dic valueForKey:@"value"] intValue]] forKey:@"value"];
	
	/*
	 * resize rectangles with animation
	 */
	[self resizeView];
	
	/*
	 * highlight the background
	 */
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
	/*
	 * resize rectangles with animation
	 */
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



#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//NSLog(@"_______");
	//NSLog(@"self.bounds.size.width %f self.bounds.size.height %f",self.view.bounds.size.width,self.view.bounds.size.height);
	//NSLog(@"orientation=%d", interfaceOrientation);
	//NSLog(@"initialized %d", [(TreemapView*)self.view initialized]);
	//	NSLog(@"self view %@", self.view);
	//NSLog(@" self.interfaceOrientation %d", [self interfaceOrientation]);
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if([(TreemapView*)self.view initialized]) [self resizeView];
}

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

#import "TreemapView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TreemapView

@synthesize dataSource;
@synthesize delegate;



- (void)calcNodePositions:(CGRect)rect 
					nodes:(NSArray *)nodes 
					width:(float)width 
				   height:(float)height 
					depth:(int)depth 
			   withCreate:(BOOL)createNode 
{
    
	
//    NSLog(@"nodes %@", nodes);
	if (nodes.count <= 1) {
		NSLog(@"inside");
	//	NSLog(@"nodes %@", nodes);
		NSInteger index = [[[nodes objectAtIndex:0] objectForKey:@"index"] intValue];
 //      	NSInteger index = [[[nodes objectAtIndex:0] objectForKey:@"index"] integerValue];
  //      NSLog(@"index here is %i", index);
	//	NSLog(@"self.subviews %@", self.subviews);
		if (createNode) 
		{
			TreemapViewCell *cell = [dataSource treemapView:self cellForIndex:index forRect:rect];
			NSLog(@"createNode");
			cell.index = index;
			cell.delegate = self;
			
			[self addSubview:cell];
			
		//	NSLog(@"cell %@", cell);
		//	NSLog(@"index here is %i", index);
			
		}
		else 
		{
			//THIS GETS CALLED ON THE UPDATE
			TreemapViewCell *cell = [self.subviews objectAtIndex:index];
			
			[cell moveAndScale:rect];
			if ([delegate respondsToSelector:@selector(treemapView:updateCell:forIndex:forRect:)])
				[delegate treemapView:self updateCell:cell forIndex:index forRect:rect];
			[cell layoutSubviews];
		}
		return;
	}
	

    
	float total = 0;
	for (NSDictionary *dic in nodes) 
	{
		total += [[dic objectForKey:@"value"] floatValue];
	}
	float half = total / 2.0;
	
	int customSep = NSNotFound;
	if ([dataSource respondsToSelector:@selector(treemapView:separationPositionForDepth:)])
		customSep = [dataSource treemapView:self separationPositionForDepth:depth];
	
	int m;
	if (customSep != NSNotFound) 
	{
		m = customSep;
	}
	else {
		m = nodes.count - 1;
		total = 0.0;
		for (int i = 0; i < nodes.count; i++) {
			if (total > half) {
				m = i;
				break;
			}
			total += [[[nodes objectAtIndex:i] objectForKey:@"value"] floatValue];
		}
		if (m < 1) m = 1;
	}
	
	NSArray *aArray = [nodes subarrayWithRange:NSMakeRange(0, m)];
	NSArray *bArray = [nodes subarrayWithRange:NSMakeRange(m, nodes.count - m)];
	
	float aTotal = 0.0;
	for (NSDictionary *dic in aArray) {
		aTotal += [[dic objectForKey:@"value"] floatValue];
	}
	float bTotal = 0.0;
	for (NSDictionary *dic in bArray) {
		bTotal += [[dic objectForKey:@"value"] floatValue];
	}
	float aRatio = aTotal / (aTotal + bTotal);
	
	CGRect aRect, bRect;
	float aWidth, aHeight, bWidth, bHeight;
	
	BOOL horizontal = (width > height);
	
	float sep = 0.0;
	if ([dataSource respondsToSelector:@selector(treemapView:separatorWidthForDepth:)])
		sep = [dataSource treemapView:self separatorWidthForDepth:depth];
	
	if (horizontal) {
		aWidth = ceil((width - sep) * aRatio);
		bWidth = width - sep - aWidth;
		aHeight = bHeight = height;
		aRect = CGRectMake(rect.origin.x, rect.origin.y, aWidth, aHeight);
		bRect = CGRectMake(rect.origin.x + aWidth + sep, rect.origin.y, bWidth, bHeight);
	}
	else { // vertical layout
		aWidth = bWidth = width;
		aHeight = ceil((height - sep) * aRatio);
		bHeight = height - sep - aHeight;
		aRect = CGRectMake(rect.origin.x, rect.origin.y, aWidth, aHeight);
		bRect = CGRectMake(rect.origin.x, rect.origin.y + aHeight + sep, bWidth, bHeight);
	}
//	NSLog(@"array a %@", aArray);
//	NSLog(@"array b %@", bArray);
	[self calcNodePositions:aRect nodes:aArray width:aWidth height:aHeight depth:depth + 1 withCreate:createNode];
	[self calcNodePositions:bRect nodes:bArray width:bWidth height:bHeight depth:depth + 1 withCreate:createNode];
}


- (NSArray *)getData {
	//NSLog(@"values inside getData");
	NSArray *values = [dataSource valuesForTreemapView:self];
	//	NSLog(@"values inside getData");


	//NSLog(@"values %@",values);	
    
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:values.count];
	for (int i = 0; i < values.count; i++) {
		NSNumber *value = [values objectAtIndex:i];
		NSLog(@"nodes value is %@", value);
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
		[dic setValue:[NSNumber numberWithInt:i] forKey:@"index"];
		[dic setValue:value forKey:@"value"];
		[nodes addObject:dic];
	}
	return nodes;
}

- (void)createNodes {
	NSArray *nodes = [self getData];
	NSLog(@"creating nodes");
	
//	NSLog(@"nodes inside create Nodes %@", nodes);

	
	if (nodes && nodes.count > 0) 
	{

	
		[self calcNodePositions:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
						  nodes:nodes
						  width:ceil(self.bounds.size.width)
						 height:ceil(self.bounds.size.height)
						  depth:0
					 withCreate:YES];
	
	}
}

//changed to withCreate:NO ---> YES;
- (void)resizeNodes {
	NSLog(@"resizing nodes");
	
	NSArray *nodes = [self getData];
	
	//NSLog(@"self.bounds.size.width %f self.bounds.size.height %f",self.bounds.size.width,self.bounds.size.height);
//	NSLog(@"nodes %@", nodes);
	if (nodes && nodes.count > 0) 
	{
		NSLog(@"calling calcNodePositions");
		
		[self calcNodePositions:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
						  nodes:nodes
						  width:ceil(self.bounds.size.width)
						 height:ceil(self.bounds.size.height)
						  depth:0
					 withCreate:YES];
	}
}

- (void)removeNodes {
	for (UIView *view in self.subviews) 
	{
		[view removeFromSuperview];
	}
}




#pragma mark -
#pragma mark Public methods

- (void)reloadData {
	NSLog(@"turning turning");
	[self removeNodes];
	[self resizeNodes];
}

- (BOOL)initialized
{
	return initialized;
}

#pragma mark -
#pragma mark TreemapViewCell delegate

- (void)treemapViewCell:(TreemapViewCell *)treemapViewCell tapped:(NSInteger)index {
	if ([delegate respondsToSelector:@selector(treemapView:tapped:)])
		[delegate treemapView:self tapped:index];
}


#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		initialized = NO;
	}
	return self;
}



- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (!initialized) {
		NSLog(@"initialized initialized");
		[self createNodes];
		initialized = YES;
	}
}

- (void)dealloc {
	[dataSource release];
	[delegate release];

	 
	[super dealloc];
}

@end

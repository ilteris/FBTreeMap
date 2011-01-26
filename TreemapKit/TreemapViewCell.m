#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Tint.h"
#import "UIImage+ProportionalFill.h"

@implementation TreemapViewCell

@synthesize titleLabel;
@synthesize countLabel;
@synthesize contentLabel;
@synthesize imageViewA;
@synthesize imageViewB;
@synthesize index;
@synthesize delegate;
@synthesize aView;
@synthesize bView;

@synthesize downloadDestinationPath;
@synthesize loaded;

@synthesize post_id = _post_id;
@synthesize playBtn = _playBtn;
@synthesize countBtn = _countBtn;

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		self.aView = [[UIView alloc] initWithFrame:self.bounds];
		self.bView = [[UIView alloc] initWithFrame:self.bounds];
		
		self.bView.backgroundColor = [UIColor redColor];
		
		self.imageViewA = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];
		self.imageViewB = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];

		self.imageViewA.contentMode = UIViewContentModeTop; 
		self.imageViewA.clipsToBounds = YES;
		//self.imageViewA.autoresizingMask =  UIViewAutoresizingNone;
		//self.aView.contentMode = UIViewContentModeCenter;
		
		[self.aView addSubview:imageViewA];
		self.bView.backgroundColor = [UIColor whiteColor];
		self.downloadDestinationPath = [NSString stringWithFormat:@""];
		
		loaded = false;
		
		self.layer.borderWidth = .5;

		self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
		NSLog(@"frame : %@", NSStringFromCGRect(self.frame));
		
		//big sized cells
		if(self.frame.size.width > 400 && self.frame.size.height > 200)
		{
			
			self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
			titleLabel.font = [UIFont boldSystemFontOfSize:11];
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			titleLabel.textAlignment = UITextAlignmentLeft;
			titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			titleLabel.shadowColor  = [UIColor blackColor];
			titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
			
			titleLabel.backgroundColor = [UIColor clearColor];
			
			titleLabel.alpha = 1;

			self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
			
			countLabel.numberOfLines = 0;
			countLabel.font = [UIFont boldSystemFontOfSize:60];
			
			
			countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			countLabel.backgroundColor = [UIColor clearColor];
			countLabel.shadowColor  = [UIColor blackColor];
			countLabel.shadowOffset = CGSizeMake(0.0, -1.0);

			
			_countBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
			
			
			
			//	[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];

			
			if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_like_red" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			else 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_comment_blue" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			
			
			_countBtn.alpha = 0.5;
			
			
			
			NSLog(@"status big");
			
			contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];

			contentLabel.font = [UIFont boldSystemFontOfSize:48];
			contentLabel.text = @"";
			contentLabel.textAlignment = UITextAlignmentLeft;
			//contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
			contentLabel.backgroundColor = [UIColor clearColor];
			contentLabel.shadowColor  = [UIColor blackColor];
			contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
			
			contentLabel.numberOfLines = 0;
			
			contentLabel.alpha = 1;
			
		}
		//small sized cells
		else if(((self.frame.size.height > 130 && self.frame.size.height < 200) && self.frame.size.width > 113) || ((self.frame.size.width > 113 && self.frame.size.width < 400) && self.frame.size.height > 200))
		{
			NSLog(@"status small");
			
			self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
			titleLabel.font = [UIFont boldSystemFontOfSize:11];
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			titleLabel.textAlignment = UITextAlignmentLeft;
			titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			titleLabel.shadowColor  = [UIColor blackColor];
			titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
			
			titleLabel.backgroundColor = [UIColor clearColor];
			
			titleLabel.alpha = 1;

			self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
			
			countLabel.numberOfLines = 0;
			countLabel.font = [UIFont boldSystemFontOfSize:60];
			
			
			countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			countLabel.backgroundColor = [UIColor clearColor];
			countLabel.shadowColor  = [UIColor blackColor];
			countLabel.shadowOffset = CGSizeMake(0.0, -1.0);

			
			_countBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
			
			
			
			
		//	[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_like_red" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			else 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_comment_blue" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			
			
			_countBtn.alpha = 0.5;
			
			contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];

			contentLabel.font = [UIFont boldSystemFontOfSize:24];
			contentLabel.text = @"";
			contentLabel.textAlignment = UITextAlignmentLeft;
			contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			contentLabel.backgroundColor = [UIColor clearColor];
			contentLabel.shadowColor  = [UIColor blackColor];
			contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
			
			contentLabel.numberOfLines = 0;
			
			contentLabel.alpha = 1;
			
		}

		//very small sized cells
		else if(self.frame.size.width < 113)
		{
			NSLog(@"frame width is smaller than 113");
			
			self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
			titleLabel.font = [UIFont boldSystemFontOfSize:0];
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			titleLabel.textAlignment = UITextAlignmentLeft;
			titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			titleLabel.shadowColor  = [UIColor blackColor];
			titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
			
			titleLabel.backgroundColor = [UIColor clearColor];
			
			titleLabel.alpha = 1;

			self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
			countLabel.numberOfLines = 0;
			countLabel.font = [UIFont boldSystemFontOfSize:0];
			
			
			countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			countLabel.backgroundColor = [UIColor clearColor];
			countLabel.shadowColor  = [UIColor blackColor];
			countLabel.shadowOffset = CGSizeMake(0.0, -1.0);

			contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
			contentLabel.font = [UIFont boldSystemFontOfSize:0];
			contentLabel.text = @"";
			contentLabel.textAlignment = UITextAlignmentLeft;
			contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			contentLabel.backgroundColor = [UIColor clearColor];
			contentLabel.shadowColor  = [UIColor blackColor];
			contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
			
			contentLabel.numberOfLines = 0;
			
			contentLabel.alpha = 1;
			
			//don't display anything
			//display only user profile.
		}
		else if(self.frame.size.height < 130)
		{
			NSLog(@"frame height is smaller than 130");
			self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
			titleLabel.font = [UIFont boldSystemFontOfSize:11];
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
			titleLabel.textAlignment = UITextAlignmentLeft;
			titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			titleLabel.shadowColor  = [UIColor blackColor];
			titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
			
			titleLabel.backgroundColor = [UIColor clearColor];
			
			titleLabel.alpha = 1;
			
			self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
			
			countLabel.numberOfLines = 0;
			countLabel.font = [UIFont boldSystemFontOfSize:60];
			
			
			countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			countLabel.backgroundColor = [UIColor clearColor];
			countLabel.shadowColor  = [UIColor blackColor];
			countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
			
			
			_countBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
			
			
			
			
		//	[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_like_red" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			else 
			{
				UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_comment_blue" ofType:@"png"]];
				[_countBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
				[tImage release];
			}
			
			
			_countBtn.alpha = 0.5;

			
			
		}
		else 
		{
			NSLog(@"god knows where");
		}

		


		//contentLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		
						
		[self.aView addSubview:countLabel];
		[self.aView addSubview:_countBtn];
		[self.aView addSubview:contentLabel];
		
		[self.aView addSubview:titleLabel];
		
		[self insertSubview:self.aView atIndex:1];
		[self insertSubview:self.bView atIndex:0];
				
	}
	return self;
}






-(void) flipIt
{

	
	//self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.0] CGColor];
	
	[UIView beginAnimations:nil context:NULL]; 
	
	[UIView setAnimationDuration:0.5]; 
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:YES]; 
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	
	[self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];

	[UIView commitAnimations]; 
	
	//TODO: need to put back the border once the animation is done.
	
}

-(void) moveAndScale:(CGRect)rect
{
	//NSLog(@"moveAndScale");

	//NSLog(@"cell.frame: %@", NSStringFromCGRect(self.bounds));
	//NSLog(@"rect %@", NSStringFromCGRect(rect));
	
	
	//self.imageView.alpha = 0.0;
	//CGRect boundRect2 = CGRectMake(0, 0, rect.size.width, rect.size.height);

	self.contentMode = UIViewContentModeCenter;
	[UIView beginAnimations:@"UIBase Hide" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.5f]; 
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	//self.bounds = boundRect2;
	self.frame = rect;
	//self.transform = CGAffineTransformMakeScale(.8, .8);
	[UIView commitAnimations];	
}





- (void)animationDidStop {
	NSLog(@"animationDidStop");
	self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
	self.imageViewA.image = [self.imageViewB.image imageCroppedToFitSize:self.frame.size];
	//self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3] CGColor];
}


- (void)layoutSubviews {
	[super layoutSubviews];

	//[contentLabel sizeToFit];
	
	//countLabel.text = @"1290";	
	NSNumber *tempNumber =  [NSNumber numberWithInt:[countLabel.text intValue]];
	countLabel.text = [tempNumber stringValue];
	
	// calculate the position of the icon according to the width of the countLabel.
	// can you set the width of the countLabel ==>countLabelWidth  to countLabel's width?
	CGSize countLabelWidth = [countLabel.text sizeWithFont:countLabel.font forWidth:countLabel.frame.size.width lineBreakMode:countLabel.lineBreakMode];
	CGRect _countBtn_frame = _countBtn.frame;
	_countBtn_frame.origin.x = countLabel.frame.origin.x + countLabelWidth.width + 4;
	_countBtn.frame = _countBtn_frame;
	
	
	//set the height for the contentLabel.
	CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,self.frame.size.height);
	CGSize expectedLabelSize = [contentLabel.text sizeWithFont:contentLabel.font 
										  constrainedToSize:maximumLabelSize 
											  lineBreakMode:contentLabel.lineBreakMode]; 
	

	//adjust the label to the new height.
	CGRect newFrame = contentLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	contentLabel.frame = newFrame;

	NSLog(@"@@@@@@@@@@@");

	NSLog(@"titleLabel is %@", titleLabel.text);
	
	CGFloat possibleNoOfLines = floorf((self.frame.size.height-countLabel.frame.size.height-60.0f) /contentLabel.font.lineHeight);
	CGFloat actualNoOfLines = (contentLabel.frame.size.height/contentLabel.font.lineHeight);
	
	////if the height of the text is long enough to touch the _countBtn then cut the text off and display the title so it fits. 
	//so if text height + spacing > required area (total height of cell - (height of countLabel+bottom padding))
	
	
	
	//60 comes from top-bottom margins 11/11 and spacing between title and count and content 12/12/12
//	NSLog(@"possibleNoOfLines is %f", floorf((self.frame.size.height-countLabel.frame.size.height-60.0f) /contentLabel.font.lineHeight));
	
//	NSLog(@"actualNoOfLines %f", (contentLabel.frame.size.height/contentLabel.font.lineHeight));
	
	NSLog(@"frame : %@", NSStringFromCGRect(self.frame));

	if(actualNoOfLines >= possibleNoOfLines)
	{
		contentLabel.numberOfLines = (NSInteger)possibleNoOfLines;
		NSLog(@"contentLabel is %@", contentLabel.text);
		CGRect newFrame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, contentLabel.frame.size.width, contentLabel.font.lineHeight*contentLabel.numberOfLines);
		contentLabel.frame = newFrame;
		
		//[contentLabel sizeToFit];
	}
	 
	//(label height - padding) / (fontsize + couple pixels) = number of lines...
	
	//NSLog( contentLabel.frame.size.height / contentLabel.font.size.
	
	titleLabel.frame = CGRectMake(11, contentLabel.frame.origin.y + contentLabel.frame.size.height + 12, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
	
	//titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.titleLabel.frame.size.height);
	imageViewA.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	aView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	bView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

}


#pragma mark -
#pragma mark === Flip action ===
#pragma mark -
- (void)onCountBtnPress:(id)sender {
	NSLog(@"onCountBtnPress");

	
	NSNumber *tempNumber = [NSNumber numberWithInt:[[countLabel text] intValue] + 1];
	NSLog(@"tempNumber %@", tempNumber);
		
	countLabel.text = [tempNumber stringValue];
	
}




- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([delegate respondsToSelector:@selector(treemapViewCell:tapped:)])
		[delegate treemapViewCell:self tapped:index];
}



- (void)dealloc {
	[titleLabel release];
	[countLabel release];
	[contentLabel	release];
	[imageViewA release];
	[imageViewB release];
	[delegate	release];
	[_playBtn release];
	[_countBtn release];
	
	[_post_id release];

	[super dealloc];
}

@end

#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Tint.h"
#import "UIImage+ProportionalFill.h"

@implementation TreemapViewCell

@synthesize valueLabel;
@synthesize countLabel;
@synthesize nameLabel;
@synthesize imageViewA;
@synthesize imageViewB;
@synthesize index;
@synthesize delegate;
@synthesize aView;
@synthesize bView;

@synthesize downloadDestinationPath;
@synthesize loaded;


#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		self.aView = [[UIView alloc] initWithFrame:self.bounds];
		self.bView = [[UIView alloc] initWithFrame:self.bounds];
		
		self.bView.backgroundColor = [UIColor redColor];
		
		self.imageViewA = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];
		self.imageViewB = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];

		[self.aView addSubview:imageViewA];
		self.bView.backgroundColor = [UIColor whiteColor];
		self.downloadDestinationPath = [NSString stringWithFormat:@""];
		
		loaded = false;
		
		self.layer.borderWidth = .5;



		self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
		self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];

		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:62];
		
		
		

		countLabel.textColor = [UIColor whiteColor];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		countLabel.adjustsFontSizeToFitWidth = NO;

			
	
		_like_btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_like_btn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
		{
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_like_red" ofType:@"png"]];
			[_like_btn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
		}
		else 
		{
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_comment_blue" ofType:@"png"]];
			[_like_btn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
		}

	
		nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		
		//CGSize theSize = [nameLabel sizeWithFont:[UIFont systemFontOfSize:30.0] constrainedToSize:CGSizeMake(310.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];

		//Calculate the expected size based on the font and linebreak mode of your label
				
		_like_btn.alpha = 0.5;

		NSLog(@"frame size: %@", NSStringFromCGSize(self.frame.size));
		
		if(self.frame.size.width > 400 && self.frame.size.height > 200)
		{
			NSLog(@"status big");
			nameLabel.font = [UIFont boldSystemFontOfSize:48];
			nameLabel.text = @"Hello this is a text";
		}
		else if(((self.frame.size.height > 130 && self.frame.size.height < 200) && self.frame.size.width > 113) || ((self.frame.size.width > 113 && self.frame.size.width < 400) && self.frame.size.height > 200))
		{
			NSLog(@"status small");
			nameLabel.font = [UIFont boldSystemFontOfSize:24];
			nameLabel.text = @"Hello this is a text";
		}
		else if(self.frame.size.width < 113 || self.frame.size.height < 130)
		{
			NSLog(@"status none");
			//nameLabel.font = [UIFont boldSystemFontOfSize:0];
			//don't display anything
			//display only user profile.
		}

		
		//nameLabel.font = [UIFont boldSystemFontOfSize:24];
		//nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.shadowColor  = [UIColor blackColor];
		nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		//nameLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.5];
		
		nameLabel.lineBreakMode = UILineBreakModeWordWrap;
		nameLabel.adjustsFontSizeToFitWidth = NO;
		nameLabel.numberOfLines = 10;
		
		nameLabel.alpha = 1;
		
			
		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		valueLabel.font = [UIFont boldSystemFontOfSize:10];
		valueLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		valueLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.textColor = [UIColor whiteColor];
		//valueLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3];
		valueLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		valueLabel.adjustsFontSizeToFitWidth = NO;
		valueLabel.backgroundColor = [UIColor clearColor];

		valueLabel.alpha = 1;
				
		[self.aView addSubview:countLabel];
		[self.aView addSubview:_like_btn];
		[self.aView addSubview:nameLabel];
		
		[self.aView addSubview:valueLabel];
		
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
	CGRect boundRect2 = CGRectMake(0, 0, rect.size.width, rect.size.height);

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

//	countLabel.text = @"1290";	
	
	// calculate the position of the icon according to the width of the countLabel.
	// can you set the width of the countLabel ==>countLabelWidth  to countLabel's width?
	CGSize countLabelWidth = [countLabel.text sizeWithFont:countLabel.font forWidth:countLabel.frame.size.width lineBreakMode:countLabel.lineBreakMode];
	CGRect _like_btn_frame = _like_btn.frame;
	_like_btn_frame.origin.x = countLabel.frame.origin.x + countLabelWidth.width + 4;
	_like_btn.frame = _like_btn_frame;
	
	
	//set the height for the namelabel.
	CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,self.frame.size.height);
	CGSize expectedLabelSize = [nameLabel.text sizeWithFont:nameLabel.font 
										  constrainedToSize:maximumLabelSize 
											  lineBreakMode:nameLabel.lineBreakMode]; 
	
	//adjust the label the the new height.
	CGRect newFrame = nameLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	nameLabel.frame = newFrame;

	valueLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y + nameLabel.frame.size.height + 40, self.valueLabel.frame.size.width, self.valueLabel.frame.size.height);
	
	//valueLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.valueLabel.frame.size.height);
	imageViewA.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	aView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	bView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([delegate respondsToSelector:@selector(treemapViewCell:tapped:)])
		[delegate treemapViewCell:self tapped:index];
}

- (void)dealloc {
	[valueLabel release];
	[countLabel release];
	[nameLabel	release];
	[imageViewA release];
	[imageViewB release];
	[delegate	release];

	[super dealloc];
}

@end

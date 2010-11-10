#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Tint.h"
#import "UIImage+ProportionalFill.h"

@implementation TreemapViewCell

@synthesize valueLabel;
@synthesize textLabel;
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

		//self.layer.borderColor = [[UIColor whiteColor] CGColor];

		self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
		self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 50, 56, 48)];

		NSLog(@"current display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
 		NSLog(@"textlabel frame is %@", NSStringFromCGRect(self.textLabel.frame));
		//CGRect textFrame = self.textLabel.frame;
		//textFrame.origin.x +=  5;
		//textFrame.origin.y =  self.frame.size.height - 50;
		//textLabel.frame = textFrame;
		NSLog(@"textlabel frame after is %@", NSStringFromCGRect(self.textLabel.frame));		
		
		//_like_btn = [[UIButton alloc] initWithFrame:CGRectMake(50, self.frame.size.height - 50, 56, 48)];
		
		
		_like_btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		// self.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
//		_like_btn.frame = CGRectMake(textLabel.bounds.origin.x + textLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 50, 56.0, 48.0);
		NSLog(@"self.textLabel.bounds.size.width %i", self.textLabel.frame.size.width);
		
		_like_btn.frame = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.bounds.size.width, 0, 56.0, 48.0);

		//_like_btn.frame = CGRectMake(0,0, 56.0, 48.0);
		
		
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

		
		
		//textLabel.contentMode = UIViewContentModeRedraw;
		textLabel.numberOfLines = 0;
		textLabel.font = [UIFont boldSystemFontOfSize:50];
		//textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		//textLabel.textAlignment = UITextAlignmentLeft;
		textLabel.textColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.shadowColor  = [UIColor blackColor];
		textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		textLabel.lineBreakMode = UILineBreakModeWordWrap;
		textLabel.adjustsFontSizeToFitWidth = NO;
		//textLabel.text = @"5";
		
		[self.aView addSubview:textLabel];
		
		[self.aView addSubview:_like_btn];
		
		//setting it arbitrarily. 
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.aView.frame.size.width, self.aView.frame.size.height)];
		
		
		nameLabel.font = [UIFont boldSystemFontOfSize:50];
		//nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.shadowColor  = [UIColor blackColor];
		nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		//nameLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.5];
		
		nameLabel.lineBreakMode = UILineBreakModeWordWrap;
		nameLabel.adjustsFontSizeToFitWidth = YES;
		
		nameLabel.alpha = .8;
		
		nameLabel.text = @"TEST";
		
		[self.aView addSubview:nameLabel];

		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		valueLabel.font = [UIFont boldSystemFontOfSize:10];
		valueLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		valueLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.textColor = [UIColor whiteColor];
		//valueLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3];
		valueLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		valueLabel.adjustsFontSizeToFitWidth = YES;
		valueLabel.backgroundColor = [UIColor clearColor];

		valueLabel.alpha = .8;
				
		
		
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

	
	
	//textLabel.frame = CGRectMake(15, self.aView.frame.size.height - 50, textLabel.bounds.size.width, textLabel.bounds.size.height);
	
	//nameLabel.frame = CGRectMake(5, 10, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);

	
	valueLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.valueLabel.frame.size.height);
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
	[textLabel release];
	[nameLabel release];
	[imageViewA release];
	[imageViewB release];
	[delegate release];

	[super dealloc];
}

@end

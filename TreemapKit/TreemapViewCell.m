#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TreemapViewCell

@synthesize valueLabel;
@synthesize textLabel;
@synthesize nameLabel;
@synthesize imageView;
@synthesize index;
@synthesize delegate;
@synthesize aView;
@synthesize bView;


#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		self.aView = [[UIView alloc] initWithFrame:self.bounds];
		self.bView = [[UIView alloc] initWithFrame:self.bounds];
		
		self.bView.backgroundColor = [UIColor whiteColor];
		
		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];
		[self.aView addSubview:imageView];
		
		

		
		self.layer.borderWidth = 1;

		//self.layer.borderColor = [[UIColor whiteColor] CGColor];

		self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:.3] CGColor];
		self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];

		
		textLabel.numberOfLines = 0;
		textLabel.font = [UIFont boldSystemFontOfSize:14];
		textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.textColor = [UIColor whiteColor];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.lineBreakMode = UILineBreakModeWordWrap;
		textLabel.adjustsFontSizeToFitWidth = NO;
		
		
		//[self.aView addSubview:textLabel];
		//setting it arbitrarily. 
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width, 10)];
		
		
		nameLabel.font = [UIFont boldSystemFontOfSize:10];
		nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.textColor = [UIColor whiteColor];

		nameLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.5];
		
		nameLabel.lineBreakMode = UILineBreakModeWordWrap;
		nameLabel.adjustsFontSizeToFitWidth = NO;
		
		nameLabel.alpha = .8;
		

		
		[self.aView addSubview:nameLabel];

		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		valueLabel.font = [UIFont boldSystemFontOfSize:10];
		valueLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		valueLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.textColor = [UIColor whiteColor];
		valueLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3];
		valueLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		valueLabel.adjustsFontSizeToFitWidth = YES;
		
		valueLabel.alpha = .8;
				
		
		
		[self.aView addSubview:valueLabel];
		
		[self insertSubview:self.aView atIndex:1];
		[self insertSubview:self.bView atIndex:0];
				
	}
	return self;
}


-(void) flipIt
{
	NSLog(@"here");
		
	
	
	
	[UIView beginAnimations:nil context:NULL]; 
	
	[UIView setAnimationDuration:0.5]; 
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:YES]; 
	
	[self exchangeSubviewAtIndex:1 withSubviewAtIndex:0];


	[UIView commitAnimations]; 
	
	
}


- (void)layoutSubviews {
	[super layoutSubviews];

	textLabel.frame = CGRectMake(0, (self.frame.size.height-textLabel.frame.size.height) - 15, self.frame.size.width-10, self.textLabel.frame.size.height);
	nameLabel.frame = CGRectMake(0, 10, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);

	
	valueLabel.frame = CGRectMake(0, 20, self.frame.size.width, self.valueLabel.frame.size.height);
	imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([delegate respondsToSelector:@selector(treemapViewCell:tapped:)])
		[delegate treemapViewCell:self tapped:index];
}

- (void)dealloc {
	[valueLabel release];
	[textLabel release];
	[nameLabel release];
	[imageView release];
	[delegate release];

	[super dealloc];
}

@end

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

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
				
		self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)];
		[self addSubview:imageView];
		
		

		
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
		
		
		[self addSubview:textLabel];
		//setting it arbitrarily. 
		self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		
		
		nameLabel.font = [UIFont boldSystemFontOfSize:10];
		nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		nameLabel.textAlignment = UITextAlignmentLeft;
		nameLabel.textColor = [UIColor whiteColor];

		nameLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.5];
		
		nameLabel.lineBreakMode = UILineBreakModeWordWrap;
		nameLabel.adjustsFontSizeToFitWidth = NO;
		
		nameLabel.alpha = .8;
		

		
		[self addSubview:nameLabel];

		self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		valueLabel.font = [UIFont boldSystemFontOfSize:10];
		valueLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		valueLabel.textAlignment = UITextAlignmentLeft;
		valueLabel.textColor = [UIColor whiteColor];
		valueLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3];
		valueLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		valueLabel.adjustsFontSizeToFitWidth = YES;
		
		valueLabel.alpha = .8;
				
		
		
		[self addSubview:valueLabel];
		

				
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	textLabel.frame = CGRectMake(10, (self.frame.size.height-textLabel.frame.size.height) - 15, self.frame.size.width-10, self.textLabel.frame.size.height);
	nameLabel.frame = CGRectMake(10, 10, self.nameLabel.frame.size.width, self.nameLabel.frame.size.height);

	
	valueLabel.frame = CGRectMake(10, 20, self.frame.size.width, self.valueLabel.frame.size.height);
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

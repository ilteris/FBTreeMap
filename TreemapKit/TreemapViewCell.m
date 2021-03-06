#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Tint.h"
#import "UIImage+ProportionalFill.h"
#import "CommentView.h"


@implementation TreemapViewCell


@synthesize swipeLeftRecognizer;


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


@synthesize post_id = _post_id;
@synthesize objectType = _objectType;
@synthesize canPostComment = _canPostComment;
@synthesize user_likes = _user_likes;

@synthesize playBtn = _playBtn;
@synthesize countBtn = _countBtn;

@synthesize grayCountLabel = _grayCountLabel;
@synthesize grayCountBtn = _grayCountBtn;
@synthesize image = _image;

#pragma mark -


static CGFloat kTransitionDuration = 0.3;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		self.frame = frame;
		self.aView = [[UIView alloc] initWithFrame:self.bounds];
		self.bView = [[UIView alloc] initWithFrame:self.bounds];
		
		self.bView.backgroundColor = [UIColor redColor];
		
		self.imageViewA = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)] autorelease];
		self.imageViewB = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height-4)] autorelease];
		
		self.imageViewA.contentMode = UIViewContentModeTop; 
		self.imageViewA.clipsToBounds = YES;
		//self.imageViewA.autoresizingMask =  UIViewAutoresizingNone;
		//self.aView.contentMode = UIViewContentModeCenter;
		//self.aView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		
		[self.aView addSubview:imageViewA];
		self.bView.backgroundColor = [UIColor whiteColor];
		self.downloadDestinationPath = [NSString stringWithFormat:@""];
		
		
		

		
		self.layer.borderWidth = .5;
		
		self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
		NSLog(@"frame : %@", NSStringFromCGRect(self.frame));
		
		
		
		
		[self setLayout:self.frame];
		
		
		
		
		[self.aView addSubview:countLabel];
		
		[self.aView addSubview:contentLabel];
		
		[self.aView addSubview:titleLabel];
		
		[self.aView addSubview:_grayCountLabel];
		
		[self insertSubview:self.aView atIndex:1];
		[self insertSubview:self.bView atIndex:0];
		
	}
	return self;
}

- (void) loadScrollingComments:(CGRect)rect
{
	//init the scrollView
	CGRect scrollViewRect = CGRectMake(0, self.frame.size.height, rect.size.width, 383);
	
	_scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
	[_scrollView setCanCancelContentTouches:NO];
	_scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	//scrollView1.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	_scrollView.scrollEnabled = YES;
	_scrollView.pagingEnabled = YES;

	
	CGRect commentRect = CGRectMake(0, 0, 336, 383);

	
	for (NSUInteger i = 1; i < 5; i++)
	{
		
		CommentView* cv = [[CommentView alloc] initWithFrame:commentRect];
		cv.frame = commentRect;
		cv.tag = i;	// tag our images for later use when we place them in serial fashion
		[_scrollView addSubview:cv];
		[cv release];
		
	}
	
	[self layoutScrollImages:_scrollView ];
	[self addSubview:_scrollView];
	[_scrollView release];
	
	_scrollView.alpha = 0.0f;
	
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	_scrollView.alpha = 1.0;
	
	[UIView commitAnimations];
	
	
	/*
     Create a swipe gesture recognizer to recognize right swipes (the default).
     We're only interested in receiving messages from this recognizer, and the view will take ownership of it, so we don't need to keep a reference to it.
     */
	
	UISwipeGestureRecognizer *recognizer;

	
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	[recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
	[self addGestureRecognizer:recognizer];
	[recognizer release];
	

	
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];

	[recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
	[self addGestureRecognizer:recognizer];
	[recognizer release];
   
		
	
}


/*
 In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	

//	[self showImageWithText:@"swipe" atPoint:location];
	_swipeAction = YES;
	NSLog(@"handleSwipeFrom");
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.55];
		
		_grayCountLabel.frame = CGRectMake(_grayCountLabel.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _grayCountLabel.frame.size.height - 11, _grayCountLabel.frame.size.width,_grayCountLabel.frame.size.height);
		_grayCountBtn.frame = CGRectMake(_grayCountBtn.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _grayCountBtn.frame.size.height - 11, _grayCountBtn.frame.size.width,_grayCountBtn.frame.size.height);
		
		
	
		_countBtn.frame = CGRectMake(_countBtn.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _countBtn.frame.size.height - 11, _countBtn.frame.size.width,_countBtn.frame.size.height);
		countLabel.frame = CGRectMake(countLabel.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - countLabel.frame.size.height - 11, countLabel.frame.size.width,countLabel.frame.size.height);
		_scrollView.frame = CGRectMake(_scrollView.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height, _scrollView.frame.size.width,_scrollView.frame.size.height);
		[UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.55];
		_grayCountLabel.frame =  CGRectMake(self.frame.size.width-273, self.frame.size.height-61, 200, 48);
		_grayCountBtn.frame = CGRectMake(self.frame.size.width-56 - 11, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		_countBtn.frame = CGRectMake(_countBtn.frame.origin.x, self.frame.size.height-_countBtn.frame.size.height - 11, _countBtn.frame.size.width,_countBtn.frame.size.height);

		countLabel.frame = CGRectMake(countLabel.frame.origin.x, self.frame.size.height-countLabel.frame.size.height - 11, countLabel.frame.size.width,countLabel.frame.size.height);

		_scrollView.frame = CGRectMake(_scrollView.frame.origin.x, self.frame.size.height, _scrollView.frame.size.width,_scrollView.frame.size.height);
		[UIView commitAnimations];
    }
	
	
}



- (void)layoutScrollImages:(UIScrollView*)scrollView 
{
//	CGRect rect = CGRectMake(0, 0 , self.frame.size.width, self.frame.size.height);
	

	UIImageView *view = nil;
	NSArray *subviews = [scrollView subviews];
	
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		NSLog(@"layoutScrollImages frame is %@", NSStringFromCGRect(view.frame));
		if ([view isKindOfClass:[CommentView class]] && view.tag > 0)
		{

			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;

			curXLoc += view.frame.size.width;
		}
	}
	
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake((4 * 336), [scrollView bounds].size.height)];
	//[scrollView setContentOffset:CGPointMake(5*self.frame.size.width,0) animated:NO];
}



- (void) setLayout:(CGRect)frame
{
	//big sized cells
	
	if(self.frame.size.width >= 700 && self.frame.size.height >= 700 )
	{
		//this is the detailed screen
		NSLog(@"self.frame.size.width >= 800 && self.frame.size.height >= 800 ");
		NSLog(@"status big and title label is %@", titleLabel.text);
		
		if(self.titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 10);
		
		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		
		if(self.countLabel == NULL) self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		
		
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.size.width-273, self.frame.size.height-61, 200, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:60];

		_grayCountLabel.textAlignment = UITextAlignmentRight;

		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		if (_grayCountBtn == NULL) 
		{
			_grayCountBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			//[_grayCountBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];

			[self.aView addSubview:_grayCountBtn];
			
		}
		
		
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) // meaning its set to likes 
		{
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_comment_white" ofType:@"png"]];
			[_grayCountBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
		}
		else 
		{
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_like_white" ofType:@"png"]];
			[_grayCountBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
		}
		
		_grayCountBtn.alpha = .2f;
		
		
		
		if (_countBtn == NULL) 
		{
			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			NSLog(@"count btn is first");
			[self.aView addSubview:self.countBtn];
			
		}
		
		
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
		
		
		self.countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		
		
		
		if(_swipeAction) //set to true once the first gesture happens
		{
			_grayCountLabel.frame = CGRectMake(_grayCountLabel.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _grayCountLabel.frame.size.height - 11, _grayCountLabel.frame.size.width,_grayCountLabel.frame.size.height);
			_grayCountBtn.frame = CGRectMake(_grayCountBtn.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _grayCountBtn.frame.size.height - 11, _grayCountBtn.frame.size.width,_grayCountBtn.frame.size.height);

			countLabel.frame = CGRectMake(countLabel.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - countLabel.frame.size.height - 11, countLabel.frame.size.width,countLabel.frame.size.height);
			_countBtn.frame = CGRectMake(_countBtn.frame.origin.x, self.frame.size.height-_scrollView.frame.size.height - _countBtn.frame.size.height - 11, _countBtn.frame.size.width,_countBtn.frame.size.height);
			NSLog(@"_swipeAction is true");
		}
		else
		{
			NSLog(@"_swipeAction is false");
			
			_grayCountLabel.frame = CGRectMake(self.frame.size.width-273, self.frame.size.height-61, 200, 48);
			_grayCountBtn.frame = CGRectMake(self.frame.size.width-56 - 11, self.aView.frame.size.height - 61, 56.0, 48.0);

			self.countLabel.frame = CGRectMake(11, self.frame.size.height - 61, 200, 48);
			_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.frame.size.height - 61, 56.0, 48.0);
			
		}
		
		
		
		if(contentLabel == NULL) contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		contentLabel.font = [UIFont boldSystemFontOfSize:48];
		//contentLabel.text = @"";
		contentLabel.textAlignment = UITextAlignmentLeft;
		//contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		if([self.objectType isEqual:@"video"])
		{
			NSLog(@"creating button");
			if(self.playBtn==NULL) self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];
			
		}
		
		self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
		
		
	}
	else if(self.frame.size.width >= 500 && self.frame.size.height >= 500 && self.frame.size.width < 700 && self.frame.size.width < 700)
	{
		NSLog(@"self.frame.size.width >= 500 && self.frame.size.height >= 500");
		NSLog(@"status big and title label is %@", titleLabel.text);
		
		if(self.titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 10);

		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(self.countLabel == NULL) self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		
		
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		
		
		if (_countBtn == NULL) 
		{
			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			NSLog(@"count btn is first");
			[self.aView addSubview:self.countBtn];
			
		}
		
		
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
		
		
		
		
		
		
		
		self.countLabel.frame = CGRectMake(11, self.frame.size.height - 61, 200, 48);
		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.frame.size.height - 61, 56.0, 48.0);
		
		
		
		
		
		if(contentLabel == NULL) contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		contentLabel.font = [UIFont boldSystemFontOfSize:48];
		//contentLabel.text = @"";
		contentLabel.textAlignment = UITextAlignmentLeft;
		//contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		if([self.objectType isEqual:@"video"])
		{
			NSLog(@"creating button");
			if(self.playBtn==NULL) self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];

		}
		
		self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);

		
	}
	else if((self.frame.size.width >= 500 && self.frame.size.height >= 200) && self.frame.size.height < 500)
	{
		
		NSLog(@"self.frame.size.width >= 500 && self.frame.size.height >= 200) && self.frame.size.height < 500");
		NSLog(@"status big and title label is %@", titleLabel.text);
		
		if(self.titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10)];
		
		titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 10);
		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(self.countLabel == NULL) self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		
		self.countLabel.frame = CGRectMake(11, self.frame.size.height - 61, 200, 48);
		
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		
		if (_countBtn == NULL) 
		{
			NSLog(@"count btn is second");
			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			[self.aView addSubview:self.countBtn];
			
		}
		
		
		
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
		
		
		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		
	
		
		
		if(contentLabel == NULL) contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		
		
		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		
		contentLabel.font = [UIFont boldSystemFontOfSize:24];
		
		contentLabel.textAlignment = UITextAlignmentLeft;
		
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		if([self.objectType isEqual:@"video"] && self.playBtn == NULL)
		{
			NSLog(@"self.frame.size.width > 400 && self.frame.size.height > 200");
			
			self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];

			
		}
		self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
	}
	else if(((self.frame.size.height > 200 && self.frame.size.height < 500)  && self.frame.size.width > 200) || (self.frame.size.width > 200 && self.frame.size.width < 500 && self.frame.size.height > 500))	
	{
		
		NSLog(@"(self.frame.size.height > 200 && self.frame.size.height < 500)  && self.frame.size.width > 200) || (self.frame.size.width > 200 && self.frame.size.width < 500 && self.frame.size.height > 500)");
		NSLog(@"status big and title label is %@", titleLabel.text);
		if(self.titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		
		titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, 10);
		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(self.countLabel == NULL) self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		
		
		self.countLabel.frame = CGRectMake(11, self.frame.size.height - 61, 200, 48);
		
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		

		if (self.countBtn == NULL) 
		{
			_countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			[self.aView addSubview:_countBtn];
			
		}
		
		
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
		
		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		
	
		
		
		
		if(contentLabel == NULL) contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];

		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		
		contentLabel.font = [UIFont boldSystemFontOfSize:24];
		
		contentLabel.textAlignment = UITextAlignmentLeft;
		
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		if([self.objectType isEqual:@"video"] && self.playBtn == NULL)
		{

			
			self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];

			
		}
		
		self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
		
		
		
		
	}
	else if(((self.frame.size.height > 100 && self.frame.size.height < 200) && self.frame.size.width > 108) || ((self.frame.size.width > 108 && self.frame.size.width < 400) && self.frame.size.height > 200))
	{
		NSLog(@"status small");
		
		if(self.titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(self.countLabel == NULL)  self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		
		
		if (_countBtn == NULL) 
		{
			NSLog(@"count btn is fifth");

			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			[self.aView addSubview:self.countBtn];
			
		}
		
		
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

		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
			
		if(contentLabel == NULL)  contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);

		
		contentLabel.font = [UIFont boldSystemFontOfSize:24];
		contentLabel.textAlignment = UITextAlignmentLeft;
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		if([self.objectType isEqual:@"video"])
		{
			NSLog(@"creating button");
			self.playBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];
			[self.playBtn release];
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);

			
		}
		
		
		
		
		
	}
	else if(self.frame.size.width <= 108)
	{
		NSLog(@"frame width is smaller than 113");
		
		if(titleLabel == NULL) self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		titleLabel.font = [UIFont boldSystemFontOfSize:0];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(countLabel == NULL)  self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];
		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:0];
		
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		
		if (_countBtn == NULL) 
		{
			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];
			
			[self.aView addSubview:self.countBtn];
			
		}
		
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

		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		
		
		
		if(contentLabel == NULL)  contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];
		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		contentLabel.font = [UIFont boldSystemFontOfSize:0];
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
		
		if([self.objectType isEqual:@"video"])
		{
			NSLog(@"creating button");
			if(self.playBtn == NULL)  self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);

			[self.aView addSubview:self.playBtn];

			
		}
		

		
		
		
	}
	else if(self.frame.size.height < 100)
	{
		NSLog(@"frame height is smaller than 130");
		if(self.titleLabel == NULL)  self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
		titleLabel.font = [UIFont boldSystemFontOfSize:11];
		titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		titleLabel.textAlignment = UITextAlignmentLeft;
		titleLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		titleLabel.shadowColor  = [UIColor blackColor];
		titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		
		titleLabel.backgroundColor = [UIColor clearColor];
		
		titleLabel.alpha = 1;
		
		if(self.countLabel == NULL) self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, self.frame.size.height - 61, 200, 48)];

		countLabel.numberOfLines = 0;
		countLabel.font = [UIFont boldSystemFontOfSize:60];
		
		
		countLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		countLabel.backgroundColor = [UIColor clearColor];
		countLabel.shadowColor  = [UIColor blackColor];
		countLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		
		if(_grayCountLabel == NULL) _grayCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-61, 100, 48)];
		_grayCountLabel.numberOfLines = 0;
		_grayCountLabel.font = [UIFont boldSystemFontOfSize:0];
		
		_grayCountLabel.textAlignment = UITextAlignmentRight;
		
		_grayCountLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_grayCountLabel.backgroundColor = [UIColor clearColor];
		_grayCountLabel.shadowColor  = [UIColor blackColor];
		_grayCountLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_grayCountLabel.alpha = .2f;
		
		
		
		if (_countBtn == NULL) 
		{
			self.countBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			[_countBtn addTarget:self action:@selector(onCountBtnPress:) forControlEvents:UIControlEventTouchUpInside];

			[self.aView addSubview:self.countBtn];
		}
		
		
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

		
		
		_countBtn.frame = CGRectMake(countLabel.bounds.origin.x + countLabel.bounds.size.width/2 + 10, self.aView.frame.size.height - 61, 56.0, 48.0);
		
		if(contentLabel == NULL)  contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0)];

		contentLabel.frame = CGRectMake(countLabel.frame.origin.x, 11, self.aView.frame.size.width-20, 0);
		
		contentLabel.font = [UIFont boldSystemFontOfSize:0];
		
		contentLabel.textAlignment = UITextAlignmentLeft;
		
		contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		contentLabel.backgroundColor = [UIColor clearColor];
		contentLabel.shadowColor  = [UIColor blackColor];
		contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		
		contentLabel.numberOfLines = 0;
		
		contentLabel.alpha = 1;
		
		
		if([self.objectType isEqual:@"video"])
		{

			if(self.playBtn == NULL) self.playBtn = [[[UIButton buttonWithType:UIButtonTypeCustom] retain] autorelease];
			self.playBtn.frame = CGRectMake(0, 0, 56.0, 55.0);
			self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);
			UIImage *tImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"]];
			[self.playBtn setBackgroundImage:[tImage stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
			[tImage release];
			
			[self.aView addSubview:self.playBtn];

			
		}
		
		self.playBtn.frame = CGRectMake((self.imageViewA.bounds.size.width-self.playBtn.bounds.size.width)/2, (self.imageViewA.bounds.size.height-self.playBtn.bounds.size.height)/2, self.playBtn.frame.size.width, self.playBtn.frame.size.height);

		
				
	}
	else 
	{
		NSLog(@"god knows where");
	}
	
}



-(void) flipIt
{
	
	
	self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.0] CGColor];
	
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
	NSLog(@"moveAndScale");
	
	//NSLog(@"cell.frame: %@", NSStringFromCGRect(self.bounds));
	//NSLog(@"rect %@", NSStringFromCGRect(rect));
	
	
	//self.imageView.alpha = 0.0;
	//CGRect boundRect2 = CGRectMake(0, 0, rect.size.width, rect.size.height);
	//[UIView setAnimationsEnabled:NO];
	
	self.contentMode = UIViewContentModeCenter;
	self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0] CGColor];
	
	[UIView beginAnimations:@"UIBase Hide" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:.5f]; 
	[UIView setAnimationDidStopSelector:@selector(animationDidStop)];
	//self.bounds = boundRect2;
	self.frame = rect;
	//self.transform = CGAffineTransformMakeScale(.8, .8);
	[UIView commitAnimations];	
	//[UIView setAnimationsEnabled:NO];
}





- (void)animationDidStop {
	NSLog(@"animationDidStop");
	
	self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1] CGColor];
	//self.imageViewA.image = [self.imageViewB.image imageCroppedToFitSize:self.frame.size];
	//self.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:.3] CGColor];
}


/*
- (void)layoutSubviews
{
	[self setLayout:self.frame];
}
*/

- (void)layoutSubviews {
	[super layoutSubviews];
	NSLog(@"layoutSubviews");
	//[contentLabel sizeToFit];
	
	NSLog(@"frame in layoutSubviews : %@", NSStringFromCGRect(self.frame));
	
	
	imageViewA.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	aView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	bView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	
	[self setLayout:self.frame];
	
	//set the height for the contentLabel.
	CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,self.frame.size.height);
	CGSize expectedLabelSize = [contentLabel.text sizeWithFont:contentLabel.font 
											 constrainedToSize:maximumLabelSize 
												 lineBreakMode:contentLabel.lineBreakMode]; 
	//adjust the label to the new height.
	CGRect newFrame = contentLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	contentLabel.frame = newFrame;
	
	//countLabel.text = @"1290";	
	NSNumber *tempNumber =  [NSNumber numberWithInt:[countLabel.text intValue]];
	countLabel.text = [tempNumber stringValue];
	
	// calculate the position of the icon according to the width of the countLabel.
	// can you set the width of the countLabel ==>countLabelWidth  to countLabel's width?
	CGSize countLabelWidth = [countLabel.text sizeWithFont:countLabel.font forWidth:countLabel.frame.size.width lineBreakMode:countLabel.lineBreakMode];
	CGRect _countBtn_frame = _countBtn.frame;
	_countBtn_frame.origin.x = countLabel.frame.origin.x + countLabelWidth.width + 4;
	_countBtn.frame = _countBtn_frame;
	
	
	
	NSLog(@"@@@@@@@@@@@");
	
	
	
	CGFloat possibleNoOfLines = floorf((self.frame.size.height-countLabel.frame.size.height-60.0f) /contentLabel.font.lineHeight);
	CGFloat actualNoOfLines = (contentLabel.frame.size.height/contentLabel.font.lineHeight);
	
	////if the height of the text is long enough to touch the _countBtn then cut the text off and display the title so it fits. 
	//so if text height + spacing > required area (total height of cell - (height of countLabel+bottom padding))
	
	
	
	//60 comes from top-bottom margins 11/11 and spacing between title and count and content 12/12/12
	//	NSLog(@"possibleNoOfLines is %f", floorf((self.frame.size.height-countLabel.frame.size.height-60.0f) /contentLabel.font.lineHeight));
	
	//	NSLog(@"actualNoOfLines %f", (contentLabel.frame.size.height/contentLabel.font.lineHeight));
	
	
	if(actualNoOfLines >= possibleNoOfLines)
	{
		contentLabel.numberOfLines = (NSInteger)possibleNoOfLines;
		//	NSLog(@"contentLabel is %@", contentLabel.text);
		CGRect newFrame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, contentLabel.frame.size.width, contentLabel.font.lineHeight*contentLabel.numberOfLines);
		contentLabel.frame = newFrame;
		
		//[contentLabel sizeToFit];
	}
	
	//(label height - padding) / (fontsize + couple pixels) = number of lines...
	
	//NSLog( contentLabel.frame.size.height / contentLabel.font.size.
	
	titleLabel.frame = CGRectMake(11, contentLabel.frame.origin.y + contentLabel.frame.size.height + 12, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
	
	//titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.titleLabel.frame.size.height);
}


#pragma mark -
#pragma mark === Flip action ===
#pragma mark -
- (void)onCountBtnPress:(id)sender {
	
	NSLog(@"onCountBtnPress on viewCell");
	if ([delegate respondsToSelector:@selector(onCountBtnPress:)])
		[delegate onCountBtnPress:self];
	
	//
	
	
	//NSNumber *tempNumber = [NSNumber numberWithInt:[[countLabel text] intValue] + 1];
	//NSLog(@"tempNumber %@", tempNumber);
	
	//countLabel.text = [tempNumber stringValue];
	
}




- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([delegate respondsToSelector:@selector(treemapViewCell:tapped:)])
		[delegate treemapViewCell:self tapped:index];
}



- (void)dealloc {
	[titleLabel release];
	[countLabel release];
	[contentLabel release];
	[imageViewA release];
	[imageViewB release];
	[delegate	release];
	[_playBtn release];
	[_countBtn release];
	
	
	[_post_id release];
	
	[super dealloc];
}

@end

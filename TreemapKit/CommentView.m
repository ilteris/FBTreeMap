//
//  CommentView.m
//  TreeMap
//
//  Created by freelancer on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentView.h"


@implementation CommentView



//instantiated in the cell for each view wrapped in a uiscrollview. 

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		UIImage *img = [UIImage imageNamed:@"bg_comment.png"];
		UIImageView *bg_image = [[UIImageView alloc] initWithImage:img];
		[self addSubview:bg_image];
		[bg_image release];
		
		UILabel *_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
		_contentLabel.font = [UIFont boldSystemFontOfSize:18];
		_contentLabel.text = @"Lorem ipsum dolares ipsum. Lirsuem, demeli dade.";

		_contentLabel.textAlignment = UITextAlignmentLeft;
		//contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
		_contentLabel.textColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]; 
		_contentLabel.backgroundColor = [UIColor clearColor];
		_contentLabel.shadowColor  = [UIColor blackColor];
		_contentLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_contentLabel.numberOfLines = 2;
		_contentLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
		[self addSubview:_contentLabel];
		[_contentLabel release];
		
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end

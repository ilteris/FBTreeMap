#import <UIKit/UIKit.h>

@protocol TreemapViewCellDelegate;

@interface TreemapViewCell : UIControl 
{
	UILabel *titleLabel;
	UILabel *countLabel;
	UILabel *contentLabel;
	
	UIImageView *imageViewA;
	
	UIImageView *imageViewB;

	
	UIView *aView;
	UIView *bView;
	
	NSInteger index;

	//models
	NSString* downloadDestinationPath;
	


	UIButton *_countBtn;
	UIButton *_playBtn;
	
	
	NSString *_post_id;
	
	
	
	id <TreemapViewCellDelegate> delegate;
}

@property(nonatomic, retain) NSString *post_id;

@property (nonatomic, retain) UIButton *playBtn;
@property (nonatomic, retain) UIButton *countBtn;


@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *countLabel;
@property (nonatomic, retain) UILabel *contentLabel;

@property (nonatomic, retain) UIImageView *imageViewA;
@property (nonatomic, retain) UIImageView *imageViewB;

@property (nonatomic, retain) UIView *aView;
@property (nonatomic, retain) UIView *bView;




@property (nonatomic, retain) NSString *downloadDestinationPath;



@property (nonatomic, assign) NSInteger index;

@property (nonatomic, retain) id <TreemapViewCellDelegate> delegate;



- (id)initWithFrame:(CGRect)frame;
- (void)flipIt;
-(void) moveAndScale:(CGRect)rect;

@end

@protocol TreemapViewCellDelegate <NSObject>

@optional

- (void)treemapViewCell:(TreemapViewCell *)treemapViewCell tapped:(NSInteger)index;

@end

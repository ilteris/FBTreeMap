#import <UIKit/UIKit.h>

@protocol TreemapViewCellDelegate;

@interface TreemapViewCell : UIControl 
{
	
	//view elements
	UILabel *titleLabel;
	UILabel *countLabel;
	UILabel *contentLabel;
	UIButton *_countBtn;
	UIButton *_playBtn;
	UIImageView *imageViewA;
	UIImageView *imageViewB;
	UIView *aView;
	UIView *bView;
	
	
	
	//model elements
	NSString* downloadDestinationPath;
	NSInteger index;
	NSString *_post_id;
	NSInteger _canLike;
	NSInteger _canPostComment;
	//delegates
	id <TreemapViewCellDelegate> delegate;
}

//view elements
@property (nonatomic, retain) UIButton *playBtn;
@property (nonatomic, retain) UIButton *countBtn;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *countLabel;
@property (nonatomic, retain) UILabel *contentLabel;

@property (nonatomic, retain) UIImageView *imageViewA;
@property (nonatomic, retain) UIImageView *imageViewB;

@property (nonatomic, retain) UIView *aView;
@property (nonatomic, retain) UIView *bView;



//models
@property (nonatomic, retain) NSString *downloadDestinationPath;
@property(nonatomic, retain) NSString *post_id;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger canLike;
@property (nonatomic, assign) NSInteger canPostComment;

//delegate
@property (nonatomic, retain) id <TreemapViewCellDelegate> delegate;



- (id)initWithFrame:(CGRect)frame;
- (void)flipIt;
-(void) moveAndScale:(CGRect)rect;
- (void) setLayout:(CGRect)frame;


@end

@protocol TreemapViewCellDelegate <NSObject>

@optional

- (void)treemapViewCell:(TreemapViewCell *)treemapViewCell tapped:(NSInteger)index;
- (void)onCountBtnPress:(TreemapViewCell *)treemapViewCell;
@end

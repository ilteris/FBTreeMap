#import <UIKit/UIKit.h>

@protocol TreemapViewCellDelegate;

@interface TreemapViewCell : UIControl {
	UILabel *valueLabel;
	UILabel *countLabel;
	UILabel *nameLabel;
	
	UIImageView *imageViewA;
	
	UIImageView *imageViewB;

	
	UIView *aView;
	UIView *bView;
	
	NSInteger index;

	//models
	NSString* downloadDestinationPath;
	
	BOOL loaded;
	
	UIButton *_like_btn;
	
	
	
	id <TreemapViewCellDelegate> delegate;
}

@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UILabel *countLabel;
@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UIImageView *imageViewA;
@property (nonatomic, retain) UIImageView *imageViewB;

@property (nonatomic, retain) UIView *aView;
@property (nonatomic, retain) UIView *bView;


@property (nonatomic, retain) NSString *downloadDestinationPath;

@property(nonatomic, assign) BOOL loaded;

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

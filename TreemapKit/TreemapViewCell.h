#import <UIKit/UIKit.h>

@protocol TreemapViewCellDelegate;

@interface TreemapViewCell : UIControl {
	UILabel *valueLabel;
	UILabel *textLabel;
	UILabel *nameLabel;
	
	UIImageView *imageView;

	
	UIView *aView;
	UIView *bView;
	
	NSInteger index;

	id <TreemapViewCellDelegate> delegate;
}

@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UILabel *nameLabel;

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) UIView *aView;
@property (nonatomic, retain) UIView *bView;


@property NSInteger index;

@property (nonatomic, retain) id <TreemapViewCellDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)flipIt;

@end

@protocol TreemapViewCellDelegate <NSObject>

@optional

- (void)treemapViewCell:(TreemapViewCell *)treemapViewCell tapped:(NSInteger)index;

@end

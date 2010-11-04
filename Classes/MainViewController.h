//
//  MainViewController.h
//  
//
//  Created by freelancer on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBLoginButton.h"
#import "FBConnect.h"
#import "Session.h"
#import "UserInfo.h"
#import "TreeMapViewController.h"



@interface MainViewController : UIViewController <FBSessionDelegate,UserInfoLoadDelegate,FBDialogDelegate> 
{

	IBOutlet FBLoginButton *_fbButton;
	Facebook *_facebook;
	Session *_session;
	NSArray *_permissions;
	UserInfo *_userInfo;

	TreeMapViewController *_treemapViewController;
	
	IBOutlet UIView *containerView;
	
	IBOutlet UIImageView *menu;
	IBOutlet UIButton *like_btn;
	IBOutlet UIButton *comment_btn;
	IBOutlet UIButton *refresh_btn;
	
	BOOL displayMode; //either comment mode or like mode. 1 is comment mode 0 is like mode

	
}

	
	

@property(nonatomic, retain) TreeMapViewController *treemapViewController;

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *menu;
@property (nonatomic, retain) IBOutlet UIButton *like_btn;
@property (nonatomic, retain) IBOutlet UIButton *comment_btn;
@property (nonatomic, retain) IBOutlet UIButton *refresh_btn;


- (IBAction) fbButtonClick: (id)sender;
- (IBAction)refreshDisplay: (id)sender;
- (IBAction)displayLikes: (id)sender;
- (IBAction)displayComments: (id)sender;

@end

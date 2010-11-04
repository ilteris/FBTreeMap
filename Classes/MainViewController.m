    //
//  MainViewController.m
//  TreeMap
//
//  Created by freelancer on 11/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "TreeMapViewController.h"

// Your Facebook App Id must be set here!
static NSString* kAppId =  @"128496757192973";


@implementation MainViewController


@synthesize  treemapViewController = _treemapViewController,
menu,like_btn,comment_btn,refresh_btn, containerView;

	
	
#pragma mark -
#pragma mark Private helper function for login/logout	
- (void) login {
	[_facebook authorize:kAppId permissions:_permissions delegate:self];
}

- (void) logout {
	[_session unsave];
	[_facebook logout:self]; 
}



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _permissions =  [[NSArray arrayWithObjects: 
						  @"publish_stream",@"read_stream", @"offline_access",nil] retain];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	 _session = [[Session alloc] init];
	_facebook = [[_session restore] retain];
	
	if (_facebook == nil) {
		_facebook = [[Facebook alloc] init];
		NSLog(@"facebook is nil");
		_fbButton.isLoggedIn = NO;
	//	_addRunButton.hidden = YES;
		//[self.view addSubview:self.logoutView];
	} else {
		NSLog(@"facebook is not nil");
		_fbButton.isLoggedIn = YES;
	//	_addRunButton.hidden = NO;
		[self fbDidLogin];
		///s[self.view addSubview:self.loginView];
	}
	
	 [_fbButton updateImage];
	 [self.containerView addSubview:_fbButton];
	
	
	//displayMode
	displayMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]; // 0 =likes 1 =comments 

	if(!displayMode) //likes
	{
		like_btn.enabled =  NO;
		comment_btn.enabled =  YES;
	}
	
	else //comments
	{
		like_btn.enabled =  YES;
		comment_btn.enabled =  NO;
	}
	
	UIImage *menuBgImage=[[UIImage imageNamed:@"pm_menu_bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:5];
	
	
	
	[menu setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	
	menu.image = menuBgImage;

}




#pragma mark -
#pragma mark IBActions


- (IBAction)refreshDisplay: (id) sender
{
	NSLog(@"refreshDisplay");
	
	//if there's no action going on.
	// in the future, make sure this doesn't get called a few times.
	

		//resetting the self.plistArray so we don't add to the old plistArray.
		//self.plistArray = [[NSMutableArray alloc] initWithCapacity:1];
		//currentDisplayMode
		if([[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //if the comments mode is on
		{
			//[self getMeButtonPressed:@"comments.count"];
		}
		else
		{
			//[self getMeButtonPressed:@"likes"];
		}
		

}

- (IBAction)displayComments: (id) sender
{
	NSLog(@"displayComments");
	like_btn.enabled =  YES;
	comment_btn.enabled =  NO;
	
	//if there's no action going on.
	// in the future, make sure this doesn't get called a few times.


		//resetting the self.plistArray so we don't add to the old plistArray.
		//self.plistArray = [[NSMutableArray alloc] initWithCapacity:1];
		
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
		//[self getMeButtonPressed:@"comments.count"];
		/*
		 NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		 @"SELECT uid,name FROM user WHERE uid=4", @"query",
		 nil];
		 [_facebook requestWithMethodName: @"fql.query" 
		 andParams: params
		 andHttpMethod: @"POST" 
		 andDelegate: self]; 
		 */

	
}



- (IBAction)displayLikes: (id) sender
{
	NSLog(@"displayLikes");
	like_btn.enabled =  NO;
	comment_btn.enabled =  YES;
	
	
	//if there's no action going on.
	// in the future, make sure this doesn't get called a few times.
	

		//resetting the self.plistArray so we don't add to the old plistArray.
		//self.plistArray = [[NSMutableArray alloc] initWithCapacity:1];
		
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
		//[self getMeButtonPressed:@"likes"];

	
}





#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	
	NSLog(@"self.bounds.size.width %f self.bounds.size.height %f",self.view.bounds.size.width,self.view.bounds.size.height);
	NSLog(@"self.treemapViewController %@", self.treemapViewController);
	if([(TreemapView*)self.treemapViewController.treeMapView initialized]) [self.treemapViewController resizeView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
	//if([(TreemapView*)self.treeMapView initialized]) [self resizeView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction

/**
 * IBAction for login/logout button click
 */
- (IBAction) fbButtonClick: (id) sender {
	if (_fbButton.isLoggedIn) {
		[self logout];
	} else {
		[self login];
	}
}


#pragma mark -
#pragma mark FBSessionDelegate


/**
 * FBSessionDelegate
 */ 
-(void) fbDidLogin {
	
	 _fbButton.isLoggedIn         = YES;
	 [_fbButton updateImage];
	
	
	_userInfo = [[[[UserInfo alloc] initializeWithFacebook:_facebook andDelegate: self] 
				  autorelease] 
				 retain];
	[_userInfo requestAllInfo];
}

/**
 * FBSessionDelegate
 */ 
-(void) fbDidLogout {
	 [_session unsave];
	_fbButton.isLoggedIn         = NO;
	[_fbButton updateImage];
	/*
	 [_session unsave];
	 [_loginView removeFromSuperview];
	 [self.view addSubview:_logoutView];
	 _fbButton.isLoggedIn         = NO;
	 [_fbButton updateImage];
	 _addRunButton.hidden = YES;
	 */
}





#pragma mark -
#pragma mark UserInfoLoadDelegate

/*
 * UserInfoLoadDelegate
 */
- (void)userInfoDidLoad 
{
	[_session setSessionWithFacebook:_facebook andUid:_userInfo.uid];
	[_session save];
	
	NSLog(@"loading the new view");
	
	
	_treemapViewController = [[TreeMapViewController alloc] init];
	//_treemapViewController.view.frame = CGRectMake(0, 0, 320, 460);
	//CGRect myFrame = self.view.frame;
	//myFrame.origin.y = 20.0;
	//_treemapViewController.view.frame = myFrame;
	
	[_treemapViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight];
	
	[self.treemapViewController viewWillAppear:YES];
	[self.containerView addSubview:self.treemapViewController.view];
	
	
	
	/*
	 [_session setSessionWithFacebook:_facebook andUid:_userInfo.uid];
	 [_session save];
	 
	 _myRunController = [[MyRunViewController alloc] init];
	 _myRunController.managedObjectContext = _managedObjectContext;
	 _myRunController.userInfo = _userInfo;
	 _myRunController.view.frame = CGRectMake(0, 0, 320, 460);
	 [self.myRunController viewWillAppear:YES];
	 [_loginView addSubview:self.myRunController.view];
	 */
}

- (void)userInfoFailToLoad 
{
	/*
	 [self logout]; 
	 _fbButton.isLoggedIn = NO;
	 _addRunButton.hidden = YES;
	 [self.view addSubview:self.logoutView];
	 */
	
}



	


@end

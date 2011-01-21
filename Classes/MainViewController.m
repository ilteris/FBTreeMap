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
menu,like_btn,comment_btn,refresh_btn, containerView, mySwitch;
@synthesize treeMapView;
@synthesize segmentedControl;	
	
#pragma mark -
#pragma mark Private helper function for login/logout	
- (void) login 
{
	NSLog(@"hereee");
	[_facebook authorize:kAppId permissions:_permissions delegate:self];
}

- (void) logout 
{
	[_session unsave];
	[_facebook logout:self]; 
}



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
        _permissions =  [[NSArray arrayWithObjects: 
						  @"publish_stream", @"read_stream", @"offline_access",nil] retain];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
//[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"displayMode"];
	
	 _session = [[Session alloc] init];
	_facebook = [[_session restore] retain];	
	
	if (_facebook == nil) {
		_facebook = [[Facebook alloc] init];
		NSLog(@"facebook is nil");
		_fbButton.isLoggedIn = NO;

	} else {
		NSLog(@"facebook is not nil");
		_fbButton.isLoggedIn = YES;
		[self fbDidLogin];
	}
	
	
	 [_fbButton updateImage];
	// [self.containerView addSubview:_fbButton];
	
	
	//displayMode
	displayMode = [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]; // 0 =likes 1 =comments 
	NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	
	
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
	
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
	
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"durationMode"]; //set the duration mode to default mode.
	
	
	[mySwitch setOn:NO animated:NO];

	
	_treemapViewController = [[TreeMapViewController alloc] init];
	NSLog(@"treemapView is %@", self.treeMapView);
	[treeMapView setDataSource:_treemapViewController];
	[treeMapView setDelegate:_treemapViewController];
	
	_treemapViewController.treeMapView = treeMapView;
	if([(TreemapView*)self.treemapViewController.treeMapView initialized]) [self.treemapViewController resizeView];
	
}




#pragma mark -
#pragma mark IBActions

-(IBAction) switchValueChanged 
{

	if (!mySwitch.on) //user
	{ 
		NSLog(@"on");
	//	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"switchMode"];
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])
		{
			//load the user for the likes
			[self.treemapViewController displayLikesOfUsers];

		}
		else
		{
			//load the user for the comments
			[self.treemapViewController displayCommentsOfUsers];

		}


	}

	else //page
	{ 
		NSLog(@"off");
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"switchMode"];
		if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"])
		{
			//load the page for the likes
			[self.treemapViewController displayLikesOfPages];

		}
		else
		{
			//load the page for the comments
			[self.treemapViewController displayCommentsOfPages];

		}
		
	}

}


-(IBAction) segmentedControlIndexChanged
{
	
	switch (self.segmentedControl.selectedSegmentIndex) 
	{
		case 0:
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"durationMode"]; //set the duration mode to default mode.
			[self.treemapViewController resizeView];
			NSLog( @"case is 0");
			break;

		case 1:
			[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"durationMode"]; //set the duration mode to default mode.
			[self.treemapViewController resizeView];
			NSLog( @"case is 1");
			break;
		case 2:
			[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"durationMode"]; //set the duration mode to default mode.
			[self.treemapViewController resizeView];
			NSLog( @"case is 2");
			break;
		case 3:
			[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"durationMode"]; //set the duration mode to default mode.
			[self.treemapViewController resizeView];
			NSLog( @"case is 3");
			break;
		default:
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"durationMode"]; //set the duration mode to default mode.
			[self.treemapViewController resizeView];

			break;			
	}
}




- (IBAction)refreshDisplay: (id) sender
{
	NSLog(@"refreshDisplay");
	
	//if there's no action going on.
	// in the future, make sure this doesn't get called a few times.
	

		//resetting the self.plistArray so we don't add to the old plistArray.
		//self.plistArray = [[NSMutableArray alloc] initWithCapacity:1];
		//currentDisplayMode
	//	[_userInfo requestCountOf];
}

- (IBAction)displayComments: (id) sender
{
	NSLog(@"displayComments");
	like_btn.enabled =  YES;
	comment_btn.enabled =  NO;
	
	//if there's no action going on.
	// in the future, make sure this doesn't get called a few times.
	
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"displayMode"];
	//NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) //display comments of users (switch is off)
	{
		NSLog(@"switchMode mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]);

		[self.treemapViewController displayCommentsOfUsers];
	}
	else //display comments of pages
	{
		NSLog(@"switchMode mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]);

		[self.treemapViewController displayCommentsOfPages];
	}
	
	//[_userInfo requestCountOf];
	
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
	NSLog(@"display mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]);
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) //display comments of users (switch is off)
	{
		NSLog(@"switchMode mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]);

		[self.treemapViewController displayLikesOfUsers];
	}
	else //display comments of pages
	{
		NSLog(@"switchMode mode is %i", [[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]);

		[self.treemapViewController displayLikesOfPages];
	}
	
}





#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration	
{
	
	NSLog(@"main.bounds.size.width %f main.bounds.size.height %f",self.view.bounds.size.width,self.view.bounds.size.height);
	//NSLog(@"self.treemapViewController %@", self.treemapViewController);
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
-(void) fbDidLogin 
{
	
	 _fbButton.isLoggedIn         = YES;
	 [_fbButton updateImage];
	
	
	_userInfo = [[[[UserInfo alloc] initializeWithFacebook:_facebook andDelegate: self] 
				  autorelease] 
				 retain];
	//[_userInfo requestCountOf:(NSString*)entity];
	//[_userInfo requestAllInfo];
	[_userInfo requestUid];
	

	

	
//	[_treemapViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight];
	
	//[self.treemapViewController viewWillAppear:YES];
//	[self.containerView addSubview:self.treemapViewController.view];

}

/**
 * FBSessionDelegate
 */ 



- (void)treemapView:(TreemapView *)treemapView tapped:(NSInteger)index 
{
	NSLog(@"here");
	TreemapViewCell *cell = (TreemapViewCell *)[self.treeMapView.subviews objectAtIndex:index];	
	[cell flipIt];
}



-(void) fbDidLogout 
{
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


- (void)likesAndCommentsDidLoad
{

	NSLog(@"likesAndCommentsDidLoad");
	if([(TreemapView*)self.treemapViewController.treeMapView initialized]) [self.treemapViewController resizeView];

	/*
	if(![[NSUserDefaults standardUserDefaults] integerForKey:@"displayMode"]) //likes
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[_treemapViewController displaySection:@"likeCount" andView:@"user"];
		}
		else 
		{
			[_treemapViewController displaySection:@"likeCount" andView:@"page"];
		}
		
	}
	else
	{
		if (![[NSUserDefaults standardUserDefaults] integerForKey:@"switchMode"]) 
		{
			[_treemapViewController displaySection:@"commentCount" andView:@"user"];
		}
		else 
		{
			[_treemapViewController displaySection:@"commentCount" andView:@"page"];
		}
	}
	 */
}


- (void)userInfoDidLoad 
{
	[_session setSessionWithFacebook:_facebook andUid:_userInfo.uid];
	[_session save];
	[_userInfo requestCountOf];
	
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

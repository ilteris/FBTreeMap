//
//  TreeMapAppDelegate.m
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TreeMapAppDelegate.h"
#import "TreeMapViewController.h"
#import "MainViewController.h"

@implementation TreeMapAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
/*	
    // Override point for customization after application launch
	treeMapViewController = [[TreeMapViewController alloc] init];
	CGRect myFrame = treeMapViewController.view.frame;
	myFrame.origin.y = 20.0;
	treeMapViewController.view.frame = myFrame;

	[treeMapViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight];
	[window addSubview:treeMapViewController.view];
*/
	
	// Override point for customization after application launch
	mainViewController = [[MainViewController alloc] init];
	CGRect myFrame = mainViewController.view.frame;
	myFrame.origin.y = 20.0;
	mainViewController.view.frame = myFrame;
	
	[mainViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight];
	[window addSubview:mainViewController.view];
	
	
    
	
	[window makeKeyAndVisible];
    
    return YES;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 * Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
			lastObject];
}




- (void)dealloc {

    [window release];
    [super dealloc];
}


@end

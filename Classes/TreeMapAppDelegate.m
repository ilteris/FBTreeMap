//
//  TreeMapAppDelegate.m
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TreeMapAppDelegate.h"
#import "TreeMapViewController.h"


@implementation TreeMapAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	[window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)dealloc {
	[viewController release];
    [window release];
    [super dealloc];
}


@end

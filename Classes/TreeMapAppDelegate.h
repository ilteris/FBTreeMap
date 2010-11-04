//
//  TreeMapAppDelegate.h
//  TreeMap
//
//  Created by freelancer on 4/29/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TreeMapViewController;
@class MainViewController;


@interface TreeMapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	TreeMapViewController *treeMapViewController;
	MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end


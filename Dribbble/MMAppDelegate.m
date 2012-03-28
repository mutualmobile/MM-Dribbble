//
//  MMAppDelegate.m
//  Dribbble
//
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMAppDelegate.h"

#import "MMViewController.h"
#import "MMFullScreenDribbbleViewController.h"

@interface MMAppDelegate ()

- (void)connectToScreen:(UIScreen*)screen;
- (void)screenDidConnect:(NSNotification*)notification;
- (void)screenDidDisconnect:(NSNotification*)notification;

@end

@implementation MMAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize fullScreenWindow = _fullScreenWindow;
@synthesize fullScreenViewController = _fullScreenViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.viewController = [[MMViewController alloc] initWithNibName:@"MMViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    if([[UIScreen screens] count] >1){
        UIScreen *externalScreen = [[UIScreen screens] objectAtIndex:1];
        
        [self connectToScreen:externalScreen];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenDidConnect:)
                                                 name:UIScreenDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenDidDisconnect:)
                                                 name:UIScreenDidDisconnectNotification
                                               object:nil];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Private Screen Methods
- (void)connectToScreen:(UIScreen*)screen{
    if([screen isEqual:[UIScreen mainScreen]] == NO){
        
        CGSize max;
        UIScreenMode* maxScreenMode;
        
        for(int i = 0; i < [[[[UIScreen screens] objectAtIndex:1] availableModes]count]; i++)
        {
            UIScreenMode* current = [[[[UIScreen screens] objectAtIndex:1] availableModes] objectAtIndex:i];
            if(current.size.width > max.width)
            {
                max = current.size;
                maxScreenMode = current;
            }
        }
        
        screen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
        screen.currentMode = maxScreenMode;
        
        if(!_fullScreenWindow){
            CGRect windowFrame = CGRectMake(0,0, screen.bounds.size.width, screen.bounds.size.height);
            _fullScreenWindow = [[UIWindow alloc] initWithFrame:windowFrame];
            [_fullScreenWindow setScreen:screen];
        }
        
        // Override point for customizing the dribbble username for the user following event attendees, rebound shot id, and the twitter search string.
        if(!_fullScreenViewController){
            _fullScreenViewController = [[MMFullScreenDribbbleViewController alloc] initWithDribbbleUserName:@"seand" reboundShotID:@"464661" twitterSearchString:@"mmdribbble"];
        }
        
        [_fullScreenWindow setRootViewController:_fullScreenViewController];
        [_fullScreenWindow makeKeyAndVisible];
    }
}

- (void)screenDidConnect:(NSNotification*)notification{
    UIScreen * newScreen = (UIScreen*)[notification object];
    [self connectToScreen:newScreen];
    
}

- (void)screenDidDisconnect:(NSNotification*)notification{
    [self setFullScreenWindow:nil];
    [self setFullScreenViewController:nil];
}

@end

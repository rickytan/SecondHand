//
//  SHAppDelegate.m
//  SecondHand
//
//  Created by ricky on 13-4-10.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHAppDelegate.h"
#import <Parse/Parse.h>

#define DEFAULT_COLOR [UIColor colorWithRed:0.0\
                                      green:153.0/255\
                                       blue:1.0\
                                      alpha:1.0]



@implementation SHAppDelegate

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (void)initParse
{
    [Parse setApplicationId:@"1F9n3SjVcKjIG8qC6j7t6lVDGxl8va0oolqIOH0w"
                  clientKey:@"dG048BqrhZE4i3Ga7XPM9aT8PqH5v10KXhRmrISG"];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    
    [PFACL setDefaultACL:defaultACL
withAccessForCurrentUser:YES];
    
    [[PFInstallation currentInstallation] saveEventually];
}

- (void)initUI
{
    [[UINavigationBar appearance] setTintColor:DEFAULT_COLOR];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UISearchBar appearance] setTintColor:DEFAULT_COLOR];
    [[UISearchBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)]];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initParse];
    [self initUI];
    
    /*
     PFLogInViewController *login = [[PFLogInViewController alloc] init];
     login.fields = PFLogInFieldsDefault;
     login.delegate = self;
     
     UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 48)];
     logoLabel.textColor = [UIColor whiteColor];
     logoLabel.textAlignment = UITextAlignmentCenter;
     logoLabel.backgroundColor = [UIColor clearColor];
     logoLabel.font = [UIFont boldSystemFontOfSize:40];
     login.logInView.logo = logoLabel;
     [logoLabel release];
     
     login.logInView.usernameField.placeholder = @"用户名";
     login.logInView.passwordField.placeholder = @"密码";
     login.logInView.signUpLabel.text = @"没有帐号？";
     [login.logInView.logInButton setTitle:@"登录"
     forState:UIControlStateNormal];
     [login.logInView.signUpButton setTitle:@"注册"
     forState:UIControlStateNormal];
     [login.logInView.passwordForgottenButton setTitle:@"忘记密码"
     forState:UIControlStateNormal];
     
     [self.navigationController pushViewController:login
     animated:NO];
     [login release];
     
     if ([PFUser currentUser].isAuthenticated) {*/
    //}
    
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:self.tabBarController] autorelease];
    self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
 {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
 {
 }
 */

#pragma mark - PFLogInViewController Delegate

- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user
{
    
}

- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(NSError *)error
{
    
}

@end

//
//  SHLoginViewController.m
//  SecondHand
//
//  Created by ricky on 13-4-17.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHLoginViewController.h"
#import <Parse/Parse.h>

@interface SHLoginViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation SHLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.fields = PFLogInFieldsDefault & (~PFLogInFieldsPasswordForgotten);
        self.delegate = self;
        
        UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
        logoLabel.textColor = [UIColor whiteColor];
        logoLabel.textAlignment = UITextAlignmentCenter;
        logoLabel.backgroundColor = [UIColor clearColor];
        logoLabel.font = [UIFont boldSystemFontOfSize:24];
        
        PFSignUpViewController *signup = [[PFSignUpViewController alloc] init];
        signup.delegate = self;
        signup.fields = PFSignUpFieldsDefault & (~PFSignUpFieldsEmail);
        signup.signUpView.logo = logoLabel;
        [logoLabel release];
        signup.signUpView.usernameField.placeholder = @"用户名";
        signup.signUpView.passwordField.placeholder = @"密码";
        signup.signUpView.emailField.placeholder = @"邮箱";
        [signup.signUpView.signUpButton setTitle:@"注册"
                                        forState:UIControlStateNormal];
        self.signUpController = signup;
        [signup release];
        
        logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
        logoLabel.textColor = [UIColor whiteColor];
        logoLabel.textAlignment = UITextAlignmentCenter;
        logoLabel.backgroundColor = [UIColor clearColor];
        logoLabel.font = [UIFont boldSystemFontOfSize:24];
        self.logInView.logo = logoLabel;
        [logoLabel release];
        
        //login.logInView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.logInView.usernameField.placeholder = @"用户名";
        self.logInView.passwordField.placeholder = @"密码";
        self.logInView.signUpLabel.text = @"没有帐号？";
        [self.logInView.logInButton setTitle:@"登录"
                                    forState:UIControlStateNormal];
        [self.logInView.signUpButton setTitle:@"注册"
                                     forState:UIControlStateNormal];
        [self.logInView.passwordForgottenButton setTitle:@"忘记密码"
                                                forState:UIControlStateNormal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PFLogin Delegate

- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user
{
    [self dismissModalViewControllerAnimated:YES];
}

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(NSError *)error
{
    
}

#pragma mark - PFSingup Delegate

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info
{
    return YES;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController
               didSignUpUser:(PFUser *)user
{
    [signUpController dismissViewControllerAnimated:YES
                                         completion:^{
                                             [self dismissModalViewControllerAnimated:YES];
                                         }];
}

@end

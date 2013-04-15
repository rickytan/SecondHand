//
//  SHReleaseProductController.m
//  SecondHand
//
//  Created by ricky on 13-4-13.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHReleaseProductController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "SVProgressHUD.h"


@interface SHReleaseProductController ()
<UITextFieldDelegate,
UITextViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
PFLogInViewControllerDelegate,
PFSignUpViewControllerDelegate>
{
    PFLogInViewController                   * _loginController;
}
@property (nonatomic, readonly, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

- (void)reset;
- (void)saveProduct;
@end

@implementation SHReleaseProductController
@synthesize descriptionField = _descriptionField;
@synthesize productImageButton = _productImageButton;
@synthesize contactField = _contactField;
@synthesize priceField = _priceField;
@synthesize productNameField = _productNameField;
@synthesize phoneField = _phoneField;
@synthesize locationManager = _locationManager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView addSubview:self.productImageButton];
    
    [self reset];
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser].isAuthenticated) {
        
        PFLogInViewController *login = [[PFLogInViewController alloc] init];
        login.fields = PFLogInFieldsDefault & (~PFLogInFieldsPasswordForgotten);
        login.delegate = self;
        
        UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
        logoLabel.textColor = [UIColor whiteColor];
        logoLabel.textAlignment = UITextAlignmentCenter;
        logoLabel.backgroundColor = [UIColor clearColor];
        logoLabel.font = [UIFont boldSystemFontOfSize:24];
        
        PFSignUpViewController *signup = [[PFSignUpViewController alloc] init];
        signup.delegate = self;
        signup.fields = PFSignUpFieldsDefault & (~PFSignUpFieldsEmail);
        signup.signUpView.logo = logoLabel;
        signup.signUpView.usernameField.placeholder = @"用户名";
        signup.signUpView.passwordField.placeholder = @"密码";
        signup.signUpView.emailField.placeholder = @"邮箱";
        [signup.signUpView.signUpButton setTitle:@"注册"
                                        forState:UIControlStateNormal];
        login.signUpController = signup;
        [signup release];
        
        logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 48)];
        logoLabel.textColor = [UIColor whiteColor];
        logoLabel.textAlignment = UITextAlignmentCenter;
        logoLabel.backgroundColor = [UIColor clearColor];
        logoLabel.font = [UIFont boldSystemFontOfSize:24];
        login.logInView.logo = logoLabel;
        [logoLabel release];
        
        //login.logInView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        login.logInView.usernameField.placeholder = @"用户名";
        login.logInView.passwordField.placeholder = @"密码";
        login.logInView.signUpLabel.text = @"没有帐号？";
        [login.logInView.logInButton setTitle:@"登录"
                                     forState:UIControlStateNormal];
        [login.logInView.signUpButton setTitle:@"注册"
                                      forState:UIControlStateNormal];
        [login.logInView.passwordForgottenButton setTitle:@"忘记密码"
                                                 forState:UIControlStateNormal];
        _loginController = login;
        [self presentModalViewController:login
                                animated:YES];
        [login release];
        return;
    }
    
    if (![CLLocationManager locationServicesEnabled] ||
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        [[[[UIAlertView alloc] initWithTitle:@"请开启定位服务"
                                     message:@"没有位置信息将无法发布商品！"
                                    delegate:self
                           cancelButtonTitle:@"好"
                           otherButtonTitles:nil] autorelease] show];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                     inSection:0]];
    CGRect r = cell.frame;
    cell.frame = CGRectMake(90, r.origin.y, self.tableView.bounds.size.width - 90, r.size.height);
    
    self.productImageButton.frame = CGRectMake(10, r.origin.y, 100 - 20, 100 - 20);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)onImage:(id)sender
{
    UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"请选择方式"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"拍照",@"从相册中选取", nil];
    [actions showInView:self.view.window];
    [actions release];
}

- (void)onDismissKeyborad:(id)sender
{
    [self.descriptionField resignFirstResponder];
    [self.productNameField resignFirstResponder];
    [self.priceField resignFirstResponder];
    [self.contactField resignFirstResponder];
    [self.phoneField resignFirstResponder];
}

- (void)reset
{
    _pendingSaveProduct = NO;
}

- (BOOL)validateFields
{
    if (self.productNameField.text.length == 0) {
        [self.productNameField becomeFirstResponder];
        return NO;
    }
    if (self.priceField.text.length == 0) {
        [self.priceField becomeFirstResponder];
        return NO;
    }
    if (self.contactField.text.length == 0) {
        [self.contactField becomeFirstResponder];
        return NO;
    }
    if (self.phoneField.text.length == 0) {
        [self.phoneField becomeFirstResponder];
        return NO;
    }
    
    
    return YES;
}

- (UIToolbar*)toolBar
{
    UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    tool.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(onDismissKeyborad:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:NULL];
    tool.items = [NSArray arrayWithObjects:spacer, done, nil];
    [done release], [spacer release];
    
    return [tool autorelease];
}

- (UITextField*)textField
{
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    field.borderStyle = UITextBorderStyleLine;
    field.layer.borderColor = [UIColor lightGrayColor].CGColor;
    field.layer.borderWidth = 1.0f;
    field.placeholder = @"必填";
    field.delegate = self;
    field.font = [UIFont systemFontOfSize:14];
    field.inputAccessoryView = [self toolBar];
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return field;
}

- (CLLocationManager*)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (UITextView*)descriptionField
{
    if (!_descriptionField) {
        _descriptionField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        _descriptionField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _descriptionField.text = @"商品描述";
        _descriptionField.textColor = [UIColor lightGrayColor];
        _descriptionField.delegate = self;
        _descriptionField.inputAccessoryView = [self toolBar];
        _descriptionField.backgroundColor = [UIColor clearColor];
    }
    return _descriptionField;
}

- (UITextField*)phoneField
{
    if (!_phoneField) {
        _phoneField = [self textField];
        _phoneField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneField;
}

- (UITextField*)priceField
{
    if (!_priceField) {
        _priceField = [self textField];
        _priceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _priceField;
}

- (UITextField*)contactField
{
    if (!_contactField) {
        _contactField  = [self textField];
        _contactField.text = [PFUser currentUser].username;
    }
    return _contactField;
}

- (UITextField*)productNameField
{
    if (!_productNameField) {
        _productNameField = [self textField];
    }
    return _productNameField;
}

- (UIButton*)productImageButton
{
    if (!_productImageButton) {
        CGFloat w = 80;
        CGFloat h = 80;
        _productImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _productImageButton.layer.borderWidth = 4.0;
        _productImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(4, h - 2)];
        [path addLineToPoint:CGPointMake(0, h + 6)];
        [path addCurveToPoint:CGPointMake(w, h + 6)
                controlPoint1:CGPointMake(w / 3, h + 1)
                controlPoint2:CGPointMake(2.0 * w / 3, h + 1)];
        [path addLineToPoint:CGPointMake(w - 4, h - 2)];
        [path closePath];
        _productImageButton.layer.shadowPath = path.CGPath;
        _productImageButton.layer.shadowRadius = 2.0f;
        _productImageButton.layer.shadowOpacity = 0.7;
        _productImageButton.layer.shadowColor = [UIColor blackColor].CGColor;
        [_productImageButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"]
                                       forState:UIControlStateNormal];
        [_productImageButton addTarget:self
                                action:@selector(onImage:)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return _productImageButton;
}

- (void)saveProduct
{
    void (^block)(NSString *imageURL) = ^(NSString *imageURL) {
        PFObject *product = [PFObject objectWithClassName:@"Product"];
        
        if (_descriptionEdited)
            [product setObject:self.descriptionField.text
                        forKey:@"desc"];
        else
            [product setObject:@""
                        forKey:@"desc"];
        [product setObject:self.productNameField.text
                    forKey:@"name"];
        [product setObject:[NSNumber numberWithFloat:self.priceField.text.floatValue]
                    forKey:@"price"];
        [product setObject:self.contactField.text
                    forKey:@"contact"];
        [product setObject:self.phoneField.text
                    forKey:@"phone"];
        if (imageURL)
            [product setObject:imageURL
                        forKey:@"image"];
        else
            [product setObject:@""
                        forKey:@"image"];
        [product setObject:[NSNumber numberWithBool:NO]
                    forKey:@"sold"];
        PFGeoPoint *location = [PFGeoPoint geoPointWithLocation:self.location];
        [product setObject:location
                    forKey:@"location"];
        
        if (self.imagePath) {
            NSData *data = [NSData dataWithContentsOfURL:self.imagePath];
            PFFile *imageFile = [PFFile fileWithData:data];
            [product addObject:imageFile
                        forKey:@"imageFile"];
        }
        
        PFRelation *relation = [product relationforKey:@"user"];
        [relation addObject:[PFUser currentUser]];
        
        
        [product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.descriptionField.text = nil;
                self.productNameField.text = nil;
                self.priceField.text = nil;
                [self.productImageButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"]
                                                   forState:UIControlStateNormal];
                [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"保存失败！"];
            }
        }];
    };
    
    if (self.imagePath) {
        [SVProgressHUD showWithStatus:@"正在保存..."
                             maskType:SVProgressHUDMaskTypeClear];
        
        NSData *data = [NSData dataWithContentsOfURL:self.imagePath];
        PFFile *imageFile = [PFFile fileWithData:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            self.imagePath = nil;
            block(imageFile.url);
        }];
    }
    else {
        [SVProgressHUD showWithStatus:@"正在保存..."
                             maskType:SVProgressHUDMaskTypeClear];
        block(nil);
    }
    
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!_descriptionEdited) {
        _descriptionEdited = YES;
        self.descriptionField.text = nil;
        self.descriptionField.textColor = [UIColor blackColor];
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = DEFAULT_COLOR.CGColor;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        textField.layer.borderColor = [UIColor redColor].CGColor;
    }
    else {
        textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) { // 拍照
            if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                [[[[UIAlertView alloc] initWithTitle:@"您的设备不支持拍照！"
                                             message:nil
                                            delegate:nil
                                   cancelButtonTitle:@"好"
                                   otherButtonTitles:nil] autorelease] show];
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            //picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentModalViewController:picker
                                    animated:YES];
            [picker release];
        }
        else {                  // 相册
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [[[[UIAlertView alloc] initWithTitle:@"您的设备不支持相册！"
                                             message:nil
                                            delegate:nil
                                   cancelButtonTitle:@"好"
                                   otherButtonTitles:nil] autorelease] show];
                return;
            }
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:picker
                                    animated:YES];
            [picker release];
        }
    }
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    self.imagePath = url;
    [self.productImageButton setBackgroundImage:image
                                       forState:UIControlStateNormal];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //[self onDismissKeyborad:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    switch (section) {
        case 0:
            num = 1;
            break;
        case 1:
            num = 4;
            break;
        case 2:
            num = 1;
        default:
            break;
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat h = 44.0;
    switch (indexPath.section) {
        case 0:
            h = 120.0;
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        default:
            break;
    }
    return h;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.contentView addSubview:self.descriptionField];
                    self.descriptionField.frame = cell.contentView.bounds;
                    cell.clipsToBounds = YES;
                    cell.contentView.clipsToBounds = YES;
                    break;
                default:
                    break;
            }
            break;
        case 1:
        {
            cell.textLabel.textAlignment = UITextAlignmentRight;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"商品名：";
                    cell.accessoryView = self.productNameField;
                    break;
                case 1:
                    cell.textLabel.text = @"价格：";
                    cell.accessoryView = self.priceField;
                    break;
                case 2:
                    cell.textLabel.text = @"联系人：";
                    cell.accessoryView = self.contactField;
                    break;
                case 3:
                    cell.textLabel.text = @"联系方式：";
                    cell.accessoryView = self.phoneField;
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
            cell.backgroundColor = DEFAULT_COLOR;
            cell.textLabel.text = @"发布商品";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.highlightedTextColor = [UIColor lightTextColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:24];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if ([self validateFields]) {
            if (_located) {
                [self saveProduct];
            }
            else {
                [SVProgressHUD showWithStatus:@"正在定位..."
                                     maskType:SVProgressHUDMaskTypeClear];
                _pendingSaveProduct = YES;
            }
        }
    }
}

#pragma mark - CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    _located = YES;
    self.location = newLocation;
    
    if (_pendingSaveProduct) {
        [self saveProduct];
    }
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tabBarController setSelectedIndex:0];
}

#pragma mark - PFLogin Delegate

- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user
{
    self.contactField.text = user.username;
}

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(NSError *)error
{
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self.tabBarController setSelectedIndex:0];
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
    [signUpController.presentedViewController dismissModalViewControllerAnimated:YES];
    //[signUpController dismissModalViewControllerAnimated:YES];
}

@end

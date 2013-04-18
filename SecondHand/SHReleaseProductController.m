//
//  SHReleaseProductController.m
//  SecondHand
//
//  Created by ricky on 13-4-13.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHReleaseProductController.h"
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "SHMyProductViewController.h"
#import "SHProduct.h"
#import "UIButton+WebCache.h"


@interface SHReleaseProductController ()
<UITextFieldDelegate,
UITextViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
MKMapViewDelegate,
PFLogInViewControllerDelegate,
PFSignUpViewControllerDelegate>
{
    PFLogInViewController                   * _loginController;
}
@property (nonatomic, readonly, retain) CLLocationManager *locationManager;
@property (nonatomic, readonly, retain) MKMapView *mapView;
@property (nonatomic, strong) CLLocation *location;

- (void)onMyProduct:(id)sender;
- (void)onDismiss:(id)sender;
- (void)reset;
- (void)saveProduct;
@end

@implementation SHReleaseProductController
@synthesize descriptionField = _descriptionField;
@synthesize mapView = _mapView;
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
        self.title = @"发布商品";
    }
    return self;
}

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)loadView
{
    UITableView *table = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                      style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    self.view = table;
    [table release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!self.product) {
        UIBarButtonItem *myItem = [[UIBarButtonItem alloc] initWithTitle:@"我的商品"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(onMyProduct:)];
        self.navigationItem.rightBarButtonItem = myItem;
        [myItem release];
    }
    else {
        UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(onDismiss:)];
        self.navigationItem.leftBarButtonItem = dismissItem;
        [dismissItem release];
    }
    
    [self.tableView addSubview:self.productImageButton];
    
    [self reset];
    //[self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    [self.productImageButton release];
    _productImageButton = nil;
    [self.productNameField release];
    _productNameField = nil;
    [self.contactField release];
    _contactField = nil;
    [self.phoneField release];
    _phoneField = nil;
    [self.priceField release];
    _priceField = nil;
    [self.mapView release];
    _mapView.delegate = nil;
    _mapView = nil;
    [self.descriptionField release];
    _descriptionField = nil;
}

#pragma mark - Methods

- (void)onMyProduct:(id)sender
{
    SHMyProductViewController *myController = [[SHMyProductViewController alloc] init];
    [self.navigationController pushViewController:myController
                                         animated:YES];
    [myController release];
}

- (void)onDismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

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
    UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
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
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
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
        _descriptionField.delegate = self;
        _descriptionField.inputAccessoryView = [self toolBar];
        _descriptionField.backgroundColor = [UIColor clearColor];
        
        if (self.product) {
            _descriptionField.textColor = [UIColor blackColor];
            _descriptionEdited = YES;
            _descriptionField.text = self.product.productDescription;
        }
        else {
            _descriptionField.textColor = [UIColor lightGrayColor];
        }
    }
    return _descriptionField;
}

- (UITextField*)phoneField
{
    if (!_phoneField) {
        _phoneField = [self textField];
        _phoneField.text = self.product.phoneNumber;
        _phoneField.keyboardType = UIKeyboardTypePhonePad;
    }
    return _phoneField;
}

- (UITextField*)priceField
{
    if (!_priceField) {
        _priceField = [self textField];
        if (self.product)
            _priceField.text = [NSString stringWithFormat:@"%.2f",self.product.price];
        _priceField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    return _priceField;
}

- (UITextField*)contactField
{
    if (!_contactField) {
        _contactField  = [self textField];
        if (self.product)
            _contactField.text = self.product.contactName;
        else
            _contactField.text = [PFUser currentUser].username;
    }
    return _contactField;
}

- (UITextField*)productNameField
{
    if (!_productNameField) {
        _productNameField = [self textField];
        _productNameField.text = self.product.productName;
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
        [_productImageButton setBackgroundImageWithURL:self.product.productImageURL
                                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [_productImageButton addTarget:self
                                action:@selector(onImage:)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return _productImageButton;
}

- (MKMapView*)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled = NO;
        //        _mapView.layer.cornerRadius = 8.0;
    }
    return _mapView;
}

- (void)saveProduct
{
    static PFFile *imageFile = nil;
    
    void (^block)(PFFile *file) = ^(PFFile *file) {
        PFObject *product = nil;
        if (self.product)
            product = [PFObject objectWithoutDataWithClassName:@"Product"
                                                      objectId:self.product.productID];
        else
            product = [PFObject objectWithClassName:@"Product"];
        
        if (_descriptionEdited)
            [product setObject:self.descriptionField.text
                        forKey:@"desc"];
        
        [product setObject:self.productNameField.text
                    forKey:@"name"];
        [product setObject:[NSNumber numberWithFloat:self.priceField.text.floatValue]
                    forKey:@"price"];
        [product setObject:self.contactField.text
                    forKey:@"contact"];
        [product setObject:self.phoneField.text
                    forKey:@"phone"];
        if (file) {
            [product setObject:file.url
                        forKey:@"image"];
        }
        
        [product setObject:[NSNumber numberWithBool:NO]
                    forKey:@"sold"];
        PFGeoPoint *location = [PFGeoPoint geoPointWithLocation:self.location];
        [product setObject:location
                    forKey:@"location"];
        
        PFRelation *relation = [product relationforKey:@"user"];
        [relation addObject:[PFUser currentUser]];
        
        [product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.descriptionField.text = nil;
                self.productNameField.text = nil;
                self.priceField.text = nil;
                [imageFile release];
                imageFile = nil;
                [self.productImageButton setBackgroundImage:[UIImage imageNamed:@"placeholder.png"]
                                                   forState:UIControlStateNormal];
                [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"保存失败！"];
            }
        }];
    };

    if (self.imageData) {
        [SVProgressHUD showWithStatus:@"正在保存..."
                             maskType:SVProgressHUDMaskTypeClear];
        
        imageFile = [[PFFile fileWithData:self.imageData] retain];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.imageData = nil;
                block(imageFile);
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"保存失败！"];
            }
        }];
    }
    else {
        [SVProgressHUD showWithStatus:@"正在保存..."
                             maskType:SVProgressHUDMaskTypeClear];
        block(imageFile);
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
    textField.layer.borderColor = [UIColor colorWithRed:0
                                                  green:153.0/255
                                                   blue:1.0
                                                  alpha:1.0].CGColor;
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

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _located = YES;
    self.location = userLocation.location;
    userLocation.title = @"我在这儿！";
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 500, 500)
              animated:YES];
    [mapView selectAnnotation:userLocation
                     animated:YES];
    
    if (_pendingSaveProduct) {
        [self saveProduct];
        _pendingSaveProduct = NO;
    }
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = image;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = image.size.height / image.size.width * width;
    if (image.size.width > width) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, width, height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    self.imageData = UIImageJPEGRepresentation(resizedImage, 0.75);
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    switch (section) {
        case 0:
            num = 1;
            break;
        case 1:
            num = 1;
            break;
        case 2:
            num = 4;
            break;
        case 3:
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
            h = 120.0;
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
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.accessoryView = nil;
    
    switch (indexPath.section) {
        case 0:
            [cell.contentView addSubview:self.descriptionField];
            self.descriptionField.frame = cell.contentView.bounds;
            cell.clipsToBounds = YES;
            cell.contentView.clipsToBounds = YES;
            break;
            
        case 1:
        {
            [cell.contentView addSubview:self.mapView];
            self.mapView.frame = cell.contentView.bounds;
            cell.clipsToBounds = YES;
            cell.contentView.clipsToBounds = YES;
            cell.contentView.layer.cornerRadius = 8.0;
            cell.contentView.layer.masksToBounds = YES;
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.startPoint = CGPointMake(0.2, 1.0);
            gradient.endPoint = CGPointMake(0, 0);
            gradient.colors = @[(id)[UIColor colorWithWhite:0.1 alpha:1.0].CGColor,
                                (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
            gradient.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
            [cell.contentView.layer addSublayer:gradient];
            gradient.frame = CGRectMake(0, 0, 300, 120);
            //            gradient.cornerRadius = 8.0f;
            //            gradient.masksToBounds = YES;
        }
            break;
        case 2:
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
        case 3:
            cell.backgroundColor = DEFAULT_COLOR;
            if (!self.product)
                cell.textLabel.text = @"提交商品";
            else
                cell.textLabel.text = @"提交修改";
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
    if (indexPath.section == 3) {
        [self onDismissKeyborad:nil];
        
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
        _pendingSaveProduct = NO;
    }
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.tabBarController setSelectedIndex:0];
}


@end

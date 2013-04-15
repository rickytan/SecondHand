//
//  SHProductDetailViewController.m
//  SecondHand
//
//  Created by ricky on 13-4-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHProductDetailViewController.h"
#import "SHProduct.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface SHProductDetailViewController ()
<UIActionSheetDelegate,
MFMessageComposeViewControllerDelegate>
{
    UIControl               * _filter;
    UIImageView             * _detailImage;
}
@property (nonatomic, readonly, retain) UIButton *productImageButton;
- (void)onDismiss:(id)sender;
- (void)onBuy:(id)sender;
- (void)onFav:(id)sender;
- (void)onImage:(id)sender;
- (void)onRestore:(id)sender;
@end

@implementation SHProductDetailViewController
@synthesize productImageButton = _productImageButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"商品详情";
    }
    return self;
}

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView addSubview:self.productImageButton];
    
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(onDismiss:)];
    UIBarButtonItem *buyItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏"
                                                                style:UIBarButtonItemStyleDone
                                                               target:self
                                                               action:@selector(onFav:)];
    self.navigationItem.leftBarButtonItem = dismissItem;
    self.navigationItem.rightBarButtonItem = buyItem;
    [dismissItem release], [buyItem release];
    
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
        [_productImageButton setBackgroundImage:[UIImage imageNamed:@"product-ph.png"]
                                       forState:UIControlStateNormal];
        [_productImageButton addTarget:self
                                action:@selector(onImage:)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return _productImageButton;
}

- (void)onDismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onBuy:(id)sender
{
    UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:@"联系发布者"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"拨打电话", @"发送短信", nil];
    [actions showInView:self.view];
    [actions release];
}

- (void)onFav:(id)sender
{
    if (![PFUser currentUser].isAuthenticated) {
        
        return;
    }
    PFObject *obj = [PFObject objectWithClassName:@"Favorite"];
    PFRelation *rela = [obj relationforKey:@"user"];
    [rela addObject:[PFUser currentUser]];
    rela = [obj relationforKey:@"product"];
    PFObject *prod = [PFObject objectWithoutDataWithClassName:@"Product"
                                                     objectId:self.product.productID];
    [rela addObject:prod];
    
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"收藏成功！"];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"收藏失败！"];
        }
    }];
}

- (void)onRestore:(id)sender
{
    [UIView animateWithDuration:0.35
                     animations:^{
                         _filter.alpha = 0.0;
                         CGRect r = self.productImageButton.bounds;
                         r = [self.view.window convertRect:r
                                                  fromView:self.productImageButton];
                         _detailImage.frame = r;
                     }
                     completion:^(BOOL finished) {
                         [_filter removeFromSuperview];
                         [_detailImage removeFromSuperview];
                         _filter = nil;
                         _detailImage = nil;
                     }];
}

- (void)onImage:(id)sender
{
    if (!self.product.productImageURL)
        return;
    
    _filter = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _filter.alpha = 0.0;
    _filter.backgroundColor = [UIColor blackColor];
    [_filter addTarget:self
                action:@selector(onRestore:)
      forControlEvents:UIControlEventTouchDown];
    
    CGRect r = self.productImageButton.bounds;
    r = [self.view.window convertRect:r fromView:self.productImageButton];

    UIImageView *image = [[UIImageView alloc] initWithFrame:r];
    image.contentMode = UIViewContentModeScaleAspectFill;
    [image setImageWithURL:self.product.productImageURL
          placeholderImage:[UIImage imageNamed:@"product-ph.png"]];
    _detailImage = image;
    
    [self.view.window addSubview:_filter];
    [self.view.window addSubview:_detailImage];
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         _filter.alpha = 0.8;
                         CGRect r = self.view.window.bounds;
                         _detailImage.bounds = CGRectMake(0,0,r.size.width,240);
                         _detailImage.center = self.view.window.center;
                     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"基本信息";
    return @"详细信息";
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
        {
            CGSize size = [self.product.productDescription sizeWithFont:[UIFont systemFontOfSize:14]
                                                      constrainedToSize:CGSizeMake(320 - 90 - 40, CGFLOAT_MAX)
                                                          lineBreakMode:UILineBreakModeWordWrap];
            h = MAX(80.0,size.height);
        }
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
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"DescCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.product.productDescription.length > 0)
            cell.textLabel.text = self.product.productDescription;
        else
            cell.textLabel.text = @"无描述";
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        [self.productImageButton setBackgroundImageWithURL:self.product.productImageURL
                                          placeholderImage:[UIImage imageNamed:@"product-ph.png"]];
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 1:
        {
            //cell.textLabel.textColor = [UIColor darkGrayColor];
            //cell.textLabel.font = [UIFont systemFontOfSize:14];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"商品名：";
                    cell.detailTextLabel.text = self.product.productName;
                    break;
                case 1:
                    cell.textLabel.text = @"价格：";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%0.2f", self.product.price];
                    break;
                case 2:
                    cell.textLabel.text = @"联系人：";
                    cell.detailTextLabel.text = self.product.contactName;
                    break;
                case 3:
                    cell.textLabel.text = @"联系方式：";
                    cell.detailTextLabel.text = self.product.phoneNumber;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
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

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3) {
        [self onBuy:nil];
    }
}

#pragma mark - MFMessage Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 0:
            {
                NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.product.phoneNumber]];
                if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
                    [[UIApplication sharedApplication] openURL:telURL];
                }
                else {
                    [[[[UIAlertView alloc] initWithTitle:@"您的设备不支持拨打电话！"
                                                 message:nil
                                                delegate:nil
                                       cancelButtonTitle:@"好"
                                       otherButtonTitles:nil] autorelease] show];
                }
            }
                break;
            case 1:
            {
                if ([MFMessageComposeViewController canSendText]) {
                    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
                    message.recipients = @[self.product.phoneNumber];
                    message.messageComposeDelegate = self;
                    [self presentModalViewController:message
                                            animated:YES];
                    [message release];
                }
                else {
                    [[[[UIAlertView alloc] initWithTitle:@"您的设备不支持发送短信！"
                                                 message:nil
                                                delegate:nil
                                       cancelButtonTitle:@"好"
                                       otherButtonTitles:nil] autorelease] show];
                }
            }
                break;
            default:
                break;
        }
    }
}

@end

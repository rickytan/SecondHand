//
//  SHMyProductViewController.m
//  SecondHand
//
//  Created by ricky on 13-4-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHMyProductViewController.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "SHProduct.h"
#import "SVProgressHUD.h"
#import "SHReleaseProductController.h"


@implementation SHTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat h = CGRectGetHeight(self.bounds) - 12 * 2;
    CGFloat w = h;
    if (self.imageView.image.size.height > 0)
        w = h * self.imageView.image.size.width / self.imageView.image.size.height;
    self.imageView.frame = CGRectMake(12, 12, w, h);
    CGRect r = self.textLabel.frame;
    r.origin.x = CGRectGetMaxX(self.imageView.frame) + 4;
    self.textLabel.frame = r;
    
    r = self.detailTextLabel.frame;
    r.origin.x = CGRectGetMaxX(self.imageView.frame) + 4;
    self.detailTextLabel.frame = r;
}

@end

@interface SHMyProductViewController ()
@property (nonatomic, strong) NSArray *productItems;
- (void)onSold:(UISwitch*)onoff;
@end

@implementation SHMyProductViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"我的商品";
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSold:(UISwitch *)onoff
{
    NSUInteger index = onoff.tag;
    
    __block SHProduct *item = [self.productItems objectAtIndex:index];
    PFObject *obj = [PFObject objectWithoutDataWithClassName:@"Product"
                                                    objectId:item.productID];
    [obj setObject:[NSNumber numberWithBool:onoff.isOn]
            forKey:@"sold"];
    
    onoff.enabled = NO;
    __block UISwitch *block = onoff;
    __block BOOL sold = block.isOn;
    
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
            block.on = !sold;
        block.enabled = YES;
        item.sold = sold;
    }];
    
}

- (void)loadData
{
    static PFQuery *query = nil;
    
    [query cancel];
    
    [SVProgressHUD showWithStatus:@"加载中..."
                         maskType:SVProgressHUDMaskTypeClear];
    
    query = [PFQuery queryWithClassName:@"Product"];
    [query whereKey:@"user"
            equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                SHProduct *product = [SHProduct productWithObject:obj];
                [mutArr addObject:product];
            }
            self.productItems = [NSArray arrayWithArray:mutArr];
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
        }
        query = nil;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.productItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (NSString*)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"商品                                       已售出";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[SHTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UISwitch *sold = [[UISwitch alloc] init];
        [sold addTarget:self
                 action:@selector(onSold:)
       forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = sold;
        [sold release];
    }
    
    // Configure the cell...
    SHProduct *item = [self.productItems objectAtIndex:indexPath.row];
    
    [cell.imageView setImageWithURL:item.productImageURL
                   placeholderImage:[UIImage imageNamed:@"product-ph.png"]
                            success:^(UIImage *image, BOOL cached) {
                                [cell setNeedsLayout];
                            }
                            failure:NULL];
    
    cell.textLabel.text = item.productName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%.2f",item.price];
    ((UISwitch*)cell.accessoryView).on = item.isSold;
    cell.accessoryView.tag = indexPath.row;
    
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
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    SHReleaseProductController *release = [[SHReleaseProductController alloc] init];
    release.product = [self.productItems objectAtIndex:indexPath.row];
    release.title = @"修改商品";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:release];
    [release release];
    [self presentModalViewController:nav
                            animated:YES];
    [nav release];
}

@end

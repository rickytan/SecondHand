//
//  SHMyFavViewController.m
//  SecondHand
//
//  Created by ricky on 13-4-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHMyFavViewController.h"
#import "SHMyProductViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "SHProduct.h"
#import "UIImageView+WebCache.h"

@interface SHMyFavViewController ()
@property (nonatomic, strong) NSArray *favoriteItems;
@end

@implementation SHMyFavViewController
@synthesize favoriteItems = _favoriteItems;

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

#pragma mark - Table view data source


- (void)loadData
{
    static PFQuery *query = nil;
    
    [query cancel];
    
    [SVProgressHUD showWithStatus:@"加载中..."
                         maskType:SVProgressHUDMaskTypeClear];
    
    query = [PFQuery queryWithClassName:@"Favorite"];
    [query whereKey:@"user"
            equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                SHProduct *product = [SHProduct productWithObject:obj];
                [mutArr addObject:product];
            }
            self.favoriteItems = [NSArray arrayWithArray:mutArr];
            [self.tableView reloadData];
            query = nil;
            
            [SVProgressHUD dismiss];
        }
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
    return self.favoriteItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
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
    SHProduct *item = [self.favoriteItems objectAtIndex:indexPath.row];
    
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

}

@end

//
//  SHProductDetailViewController.h
//  SecondHand
//
//  Created by ricky on 13-4-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SHProduct;

@interface SHProductDetailViewController : UITableViewController
@property (nonatomic, strong) SHProduct *product;
@end

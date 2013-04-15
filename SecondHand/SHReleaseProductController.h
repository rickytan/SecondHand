//
//  SHReleaseProductController.h
//  SecondHand
//
//  Created by ricky on 13-4-13.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SHReleaseProductController : UITableViewController
{
    BOOL                     _descriptionEdited;
    BOOL                     _pendingSaveProduct;
    BOOL                     _located;
}
@property (nonatomic, readonly, retain) UITextView *descriptionField;
@property (nonatomic, readonly, retain) UITextField *priceField;
@property (nonatomic, readonly, retain) UITextField *contactField;
@property (nonatomic, readonly, retain) UITextField *productNameField;
@property (nonatomic, readonly, retain) UITextField *phoneField;
@property (nonatomic, readonly, retain) UIButton *productImageButton;
@property (nonatomic, strong) NSData *imageData;
@end

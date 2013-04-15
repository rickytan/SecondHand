//
//  SHProduct.h
//  SecondHand
//
//  Created by ricky on 13-4-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PFObject;

@interface SHProduct : NSObject
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *contactName;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, strong) NSURL *productImageURL;

+ (id)productWithObject:(PFObject*)object;

@end

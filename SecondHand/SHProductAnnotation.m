//
//  SHProductAnnotation.m
//  SecondHand
//
//  Created by ricky on 13-4-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHProductAnnotation.h"
#import "SHProduct.h"

@implementation SHProductAnnotation

- (id)initWithProduct:(SHProduct *)product
{
    self = [super init];
    if (self) {
        self.product = product;
    }
    return self;
}

#pragma mark - MKAnnotation Methods

- (NSString*)title
{
    return self.product.productName;
}

- (NSString*)subtitle
{
    return self.product.phoneNumber;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.product.location;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    self.product.location = newCoordinate;
}

@end

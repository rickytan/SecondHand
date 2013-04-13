//
//  SHProductAnnotation.h
//  SecondHand
//
//  Created by ricky on 13-4-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SHProduct;

@interface SHProductAnnotation :  NSObject <MKAnnotation>
@property (nonatomic, strong) SHProduct *product;

- (id)initWithProduct:(SHProduct*)product;
@end

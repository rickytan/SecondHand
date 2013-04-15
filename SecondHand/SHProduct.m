//
//  SHProduct.m
//  SecondHand
//
//  Created by ricky on 13-4-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHProduct.h"
#import <Parse/Parse.h>

@implementation SHProduct

+ (id)productWithObject:(PFObject *)object
{
    SHProduct *p = [[SHProduct alloc] init];
    p.productID = object.objectId;
    p.phoneNumber = [object valueForKey:@"phone"];
    p.productDescription = [object valueForKey:@"desc"];
    p.productImageURL = [object valueForKey:@"image"];
    p.productName = [object valueForKey:@"name"];
    p.contactName = [object valueForKey:@"contact"];
    p.price = [[object objectForKey:@"price"] floatValue];
    p.sold = [[object objectForKey:@"sold"] boolValue];

    CLLocationCoordinate2D loc;
    loc.latitude = ((PFGeoPoint*)[object objectForKey:@"location"]).latitude;
    loc.longitude = ((PFGeoPoint*)[object objectForKey:@"location"]).longitude;
    p.location = loc;
    
    return [p autorelease];
}
@end

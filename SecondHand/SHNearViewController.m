//
//  SHNearViewController.m
//  SecondHand
//
//  Created by ricky on 13-4-10.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "SHNearViewController.h"
#import "SHProductAnnotation.h"
#import "SHProduct.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "SHProductDetailViewController.h"

@interface SHAnnatationView : MKAnnotationView

@end

@implementation SHAnnatationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected)
        [super setSelected:selected
                  animated:animated];
}

@end

@interface SHNearViewController () <UISearchDisplayDelegate, MKMapViewDelegate>

@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKUserTrackingBarButtonItem *trackingItem;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PFQuery *productQuery;
@property (nonatomic, readonly) NSMutableArray *annotations;
@property (nonatomic, strong) NSArray *productItems;

- (void)loadProductsWithLocation:(MKCoordinateRegion)region;
- (void)openCallOut:(id<MKAnnotation>)annotation;

@end

@implementation SHNearViewController
@synthesize annotations = _annotations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.radius = 5000.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MKUserTrackingBarButtonItem *item = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.trackingItem = item;
    [item release];
    
    self.navigationItem.leftBarButtonItem = self.trackingItem;
    self.navigationItem.titleView = self.searchDisplayController.searchBar;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_located) {
        [self loadProductsWithLocation:self.mapView.region];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UINavigationController*)navigationController
{
    return nil;
}

#pragma mark - Methods

- (NSMutableArray*)annotations
{
    if (!_annotations) {
        _annotations = [[NSMutableArray alloc] initWithCapacity:7];
    }
    return _annotations;
}

- (void)loadProductsWithLocation:(MKCoordinateRegion)region
{
    [self.productQuery cancel];

    CLLocationDegrees left = region.center.longitude - region.span.longitudeDelta;
    CLLocationDegrees right = region.center.longitude + region.span.longitudeDelta;
    CLLocationDegrees top = region.center.latitude + region.span.latitudeDelta;
    CLLocationDegrees bottom = region.center.latitude - region.span.latitudeDelta;
    
    if (left < -180.0)
        left = 180.0;
    if (right > 180.0)
        right = 180.0;
    if (top > 90.0)
        top = 90.0;
    if (bottom < -90.0)
        bottom = -90.0;
    
    
    self.productQuery = [PFQuery queryWithClassName:@"Product"];
    
    [self.productQuery whereKey:@"sold"
                     notEqualTo:[NSNumber numberWithBool:YES]];
    [self.productQuery whereKey:@"location"
      withinGeoBoxFromSouthwest:[PFGeoPoint geoPointWithLatitude:bottom
                                                       longitude:left]
                    toNortheast:[PFGeoPoint geoPointWithLatitude:top
                                                       longitude:right]];
    
//    [self.productQuery whereKey:@"user"
//                     notEqualTo:[PFUser currentUser]];
    [self.productQuery orderByDescending:@"createAt"];

    [self.productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            [self.mapView removeAnnotations:self.annotations];
            [self.annotations removeAllObjects];
            
            NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:objects.count];
            for (PFObject *obj in objects) {
                SHProduct *product = [SHProduct productWithObject:obj];
                [mutArr addObject:product];
                SHProductAnnotation *annotation = [[SHProductAnnotation alloc] initWithProduct:product];
                [self.annotations addObject:annotation];
                [annotation release];
            }
            self.productItems = [NSArray arrayWithArray:mutArr];
            [self.mapView addAnnotations:self.annotations];
        }
    }];
}

- (void)openCallOut:(id<MKAnnotation>)annotation
{
    [self.mapView selectAnnotation:annotation
                          animated:YES];
}

#pragma mark - UISearchDisplayController Delegate

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setLeftBarButtonItem:nil
                                     animated:YES];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setLeftBarButtonItem:self.trackingItem
                                     animated:YES];
}


#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView
regionWillChangeAnimated:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _located = YES;
    userLocation.title = @"我在这儿！";
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, self.radius, self.radius)
              animated:YES];
}

- (void)mapView:(MKMapView *)mapView
regionDidChangeAnimated:(BOOL)animated
{
    if (_located) {
        [self loadProductsWithLocation:self.mapView.region];
    }
}

- (void)mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)views
{
    
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    SHProductAnnotation *productAnno = (SHProductAnnotation*)view.annotation;
    SHProduct *product = productAnno.product;
    
    SHProductDetailViewController *detail = [[SHProductDetailViewController alloc] init];
    detail.product = product;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:detail];
    [detail release];
    
    [self presentModalViewController:nav
                            animated:YES];
    [nav release];
}


- (MKAnnotationView*)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *AnnotationIdentifier = @"SecondHandProduct";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[[SHAnnatationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:AnnotationIdentifier] autorelease];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 24)];
        imageView.image = [UIImage imageNamed:@"product-ph.png"];
        annotationView.leftCalloutAccessoryView = imageView;
        [imageView release];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = button;
        annotationView.image = [UIImage imageNamed:@"pin_red.png"];
        annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height / 2 + 3);
    }

    SHProductAnnotation *prod = (SHProductAnnotation*)annotation;
    

    [((UIImageView*)annotationView.leftCalloutAccessoryView) setImageWithURL:prod.product.productImageURL
                                                            placeholderImage:[UIImage imageNamed:@"product-ph.png"]];
    annotationView.canShowCallout = YES;
    
    /*
    [self performSelector:@selector(openCallOut:)
               withObject:annotation
               afterDelay:0.35];
     */
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
didFailToLocateUserWithError:(NSError *)error
{
    
}

@end

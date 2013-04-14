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

@interface SHNearViewController () <UISearchDisplayDelegate, MKMapViewDelegate>

@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKUserTrackingBarButtonItem *trackingItem;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PFQuery *productQuery;
@property (nonatomic, strong) NSArray *productItems;

- (void)loadProductsWithLocation:(MKCoordinateRegion)region;

@end

@implementation SHNearViewController

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

- (void)loadProductsWithLocation:(MKCoordinateRegion)region
{
    [self.productQuery cancel];

    CLLocationDegrees left = region.center.longitude - region.span.longitudeDelta;
    CLLocationDegrees right = region.center.longitude + region.span.longitudeDelta;
    CLLocationDegrees top = region.center.latitude + region.span.latitudeDelta;
    CLLocationDegrees bottom = region.center.latitude - region.span.latitudeDelta;
    
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
            
            self.productItems = objects;
            
        }
    }];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
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


- (MKAnnotationView*)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *AnnotationIdentifier = @"SecondHandProduct";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:AnnotationIdentifier] autorelease];
    }
    else {
        [annotationView prepareForReuse];
    }
    
    if (annotation == mapView.userLocation) {
        annotationView.image = [UIImage imageNamed:@"pin_blue.png"];
    }
    else {
        annotationView.image = [UIImage imageNamed:@"pin_red.png"];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
didFailToLocateUserWithError:(NSError *)error
{
    
}

@end

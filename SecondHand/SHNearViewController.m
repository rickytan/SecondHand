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

@interface SHNearViewController ()
<UISearchDisplayDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
MKMapViewDelegate>

@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKUserTrackingBarButtonItem *trackingItem;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PFQuery *productQuery;
@property (nonatomic, readonly) NSMutableDictionary *annotations;
@property (nonatomic, strong) NSArray *searchWords;
@property (nonatomic, strong) NSString *keyWord;

- (void)loadProductsWithLocation:(MKCoordinateRegion)region;
- (void)loadProductsWithName:(NSString*)name;
- (void)loadSearchWordsWithString:(NSString*)string;
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
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    MKMapView *map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    map.delegate = self;
    map.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    map.mapType = MKMapTypeStandard;
    map.showsUserLocation = YES;
    [self.view addSubview:map];
    
    self.mapView = map;
    [map release];
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
    
    self.searchDisplayController.searchResultsTitle = @"test";
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    if (_located) {
    //        [self loadProductsWithLocation:self.mapView.region];
    //    }
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

- (NSMutableDictionary*)annotations
{
    if (!_annotations) {
        _annotations = [[NSMutableDictionary alloc] initWithCapacity:7];
    }
    return _annotations;
}

- (void)loadProductsWithLocation:(MKCoordinateRegion)region
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        return;
    
    [self.productQuery cancel];
    
    CLLocationDegrees left = region.center.longitude - region.span.longitudeDelta;
    CLLocationDegrees right = region.center.longitude + region.span.longitudeDelta;
    CLLocationDegrees top = region.center.latitude + region.span.latitudeDelta;
    CLLocationDegrees bottom = region.center.latitude - region.span.latitudeDelta;
    
    if (left < -180.0)
        left = -180.0;
    if (right > 180.0)
        right = 179.0;
    if (top >= 90.0)
        top = 89.0;
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
    if ([PFUser currentUser].isAuthenticated)
        [self.productQuery whereKey:@"user"
                         notEqualTo:[PFUser currentUser]];
    if (self.keyWord)
        [self.productQuery whereKey:@"name"
                     containsString:self.keyWord];
    
    [self.productQuery orderByDescending:@"createAt"];
    
    __block NSMutableDictionary * tmpDict = self.annotations;
    [self.productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            NSMutableArray *keysToRemove = [NSMutableArray arrayWithArray:tmpDict.allKeys];
            NSMutableDictionary *objectsToAdd = [NSMutableDictionary dictionaryWithCapacity:objects.count];
            
            for (PFObject *o in objects) {
                if ([keysToRemove containsObject:o.objectId])
                    [keysToRemove removeObject:o.objectId];
                else {
                    SHProduct *product = [SHProduct productWithObject:o];
                    SHProductAnnotation *annotation = [[SHProductAnnotation alloc] initWithProduct:product];
                    [objectsToAdd setObject:annotation
                                     forKey:o.objectId];
                    [annotation release];
                }
            }
            NSArray *annotationsToRemove = [[tmpDict dictionaryWithValuesForKeys:keysToRemove] allValues];
            [self.mapView removeAnnotations:annotationsToRemove];
            [tmpDict removeObjectsForKeys:keysToRemove];
            [tmpDict addEntriesFromDictionary:objectsToAdd];
            [self.mapView addAnnotations:objectsToAdd.allValues];
            
        }
        self.productQuery = nil;
    }];
}

- (void)loadProductsWithName:(NSString *)name
{
    [self.productQuery cancel];
    
    self.productQuery = [PFQuery queryWithClassName:@"Product"];
    [self.productQuery whereKey:@"sold"
                     notEqualTo:[NSNumber numberWithBool:YES]];
    if ([PFUser currentUser].isAuthenticated)
        [self.productQuery whereKey:@"user"
                         notEqualTo:[PFUser currentUser]];
    
    [self.productQuery orderByDescending:@"createAt"];
    
    [self.productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            
        }
        self.productQuery = nil;
    }];
}

- (void)loadSearchWordsWithString:(NSString *)string
{
    static PFQuery *query = nil;
    
    [query cancel];
    
    query = [PFQuery queryWithClassName:@"Product"];
    [query whereKey:@"name"
     containsString:string];
    [query whereKey:@"sold"
            equalTo:[NSNumber numberWithBool:NO]];
    if (![PFUser currentUser].isAuthenticated)
        [query whereKey:@"user"
             notEqualTo:[PFUser currentUser]];
    
    query.limit = 10;
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            self.searchWords = objects;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        query = nil;
    }];
}

- (void)openCallOut:(id<MKAnnotation>)annotation
{
    [self.mapView selectAnnotation:annotation
                          animated:YES];
}

#pragma mark - UISearchDisplayController Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setLeftBarButtonItem:nil
                                     animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setLeftBarButtonItem:self.trackingItem
                                     animated:YES];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if (_needReload) {
        [self loadProductsWithLocation:self.mapView.region];
        _needReload = NO;
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        if(self.keyWord)
            _needReload = YES;
        self.keyWord = nil;
    }
    else {
        _needReload = NO;
        [self loadSearchWordsWithString:searchText];
    }
}

#pragma mark - UITable Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.searchWords.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    PFObject *item = [self.searchWords objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO
                                   animated:YES];
    PFObject *item = [self.searchWords objectAtIndex:indexPath.row];
    self.keyWord = [item objectForKey:@"name"];
    _needReload = NO;
    
    self.searchDisplayController.searchBar.text = self.keyWord;
    
    [self loadProductsWithLocation:self.mapView.region];
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
    if (!_located)
        [self loadProductsWithLocation:self.mapView.region];
    
    _located = YES;
    userLocation.title = @"我在这儿！";
    
    //[mapView setRegion:MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, self.radius, self.radius)
    //          animated:YES];
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

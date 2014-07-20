//
//  IMIMapViewController.m
//  YO MAP
//
//  Created by imicreation on 20/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import "IMIMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"
#import <MapKit/MKAnnotation.h>
#include <QuartzCore/QuartzCore.h>
#import "IMIDetailViewController.h"
#import "IMIAppDelegate.h"
#import "IMIContactModel.h"
#import "NF1ConnectionManager.h"

@interface IMIMapViewController ()

@property (weak, nonatomic) NSMutableArray * _contactModelDataSource;
@property (nonatomic, weak) IMIAppDelegate* appdelegate;
@property (nonatomic, retain)  CLLocationManager *locationManager;

-(void) showLocationOnMapWithDetail:(IMIContactModel*) contactModel;
-(CLLocationDistance)getRadius;
-(void)AddAnnotationtoMapView ;

-(void) setRegionForCurrentLocation:(BOOL)authorized;
- (void)RefreshMapView:(NSNotification *)notification;
-(void)reloadAnnotationView:(NSNotification *)notification;

@end

@implementation IMIMapViewController
@synthesize mapView;
@synthesize _contactModelDataSource;
@synthesize appdelegate;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil    {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    appdelegate =(IMIAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshMapView:)
                                                 name:ApplicationDidFinishContactSyncing
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(StartAppProcess:)
                                                 name:ApplicationDidFinishContactsInitialisation
                                               object:nil];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setDelegate:self];
    [self setRegionForCurrentLocation:YES];
    
     [mapView setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin)];
}

-(void)AddAnnotationtoMapView   {

    [self setRegionForCurrentLocation:YES];
    
    @synchronized(self) {
        for(int i=0; i< [_contactModelDataSource count]; i++)    {
            IMIContactModel* contact =(IMIContactModel*) [_contactModelDataSource objectAtIndex:i];
            
            if(![[appdelegate.sharedContactModelManager getAddressString:contact.personRef] isEqualToString:@"Not Valid"])  {
                [self showLocationOnMapWithDetail:(IMIContactModel*)contact];
            }
            contact = NULL;
        }
    }
}

-(void) dealloc {
    if(appdelegate)
        [appdelegate.sharedContactModelManager removeObserverForAllContacts:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    appdelegate = NULL;
    _contactModelDataSource = NULL;
}

- (void)viewDidUnload   {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"keyPath %@", keyPath);
    if ([keyPath isEqual:@"todaysUpcommingMeets"])
    {
        id newValue = [object valueForKeyPath:keyPath];
        NSLog(@"The keyPath %@ changed to %@", keyPath, newValue);
    }
    else if ([keyPath isEqual:@"futureMeetsExcludingTodaysMeets"])
    {
        id newValue = change[NSKeyValueChangeNewKey];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSLog(@"The keyPath %@ changed from %@ to %@", keyPath, oldValue, newValue);
    }
    [self updateAnnotations];
}

#pragma mark IMIContactModelManager Notification Handler

- (void)RefreshMapView:(NSNotification *)notification {
       [self performSelector:@selector(reloadAnnotationView:)
               withObject:notification
               afterDelay:0.0f];
}

-(void)reloadAnnotationView:(NSNotification *)notification   {
    
    //first remove all pin annotation on map then add put annotation again 
    
    @autoreleasepool {
        NSArray* annotations = [mapView annotations];
        [mapView removeAnnotations:annotations];
        
        [self AddAnnotationtoMapView];
    }
}

#pragma mark IMIAppDelegate Notification Handler

- (void)StartAppProcess:(NSNotification *)notification {
    if(appdelegate)
        [appdelegate.sharedContactModelManager registerObserverForAllContacts:self];
    
    @synchronized(self) {
         _contactModelDataSource = appdelegate.sharedContactModelManager.contactModelArray;
    }
    
    [self AddAnnotationtoMapView];
}


-(void)viewDidAppear:(BOOL)animated    {
    
    [self setRegionForCurrentLocation:YES];
    
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
        
        [locationManager startUpdatingHeading];
        [self setRegionForCurrentLocation:YES];
    }
    else    {
        [self setRegionForCurrentLocation:NO];
    }
    
    if (![CLLocationManager locationServicesEnabled] || ![appdelegate.sharedSettingmanager getGPSValue]) {
        
        [locationManager stopUpdatingLocation];
        [appdelegate showAlertWithTitle:@"Location Service Disabled" withMessage:@"Re-enable Location Service for this app." cancelBtnTitle:@"OK"];
    }
}

-(void)viewWillAppear:(BOOL)animated    {

//    // to update the number of meets
//    NSArray *selectedAnnotations = mapView.selectedAnnotations;
//    [mapView deselectAnnotation:(id <MKAnnotation>)[selectedAnnotations objectAtIndex:0] animated:NO];
//    [mapView selectAnnotation:(id <MKAnnotation>)[selectedAnnotations objectAtIndex:0] animated:YES];
    self.navigationController.navigationBarHidden = YES;
    
    if([appdelegate.sharedSettingmanager getMapTypeValue])
         [mapView setMapType:MKMapTypeHybrid];
    else
         [mapView setMapType:MKMapTypeStandard];
}

-(void)updateAnnotations    {
    // update the colors of pins
    NSArray* annotations = [mapView annotations];
    for(int counter =0; counter<[annotations count]; counter++)  {
        if([annotations objectAtIndex:counter] == self.mapView.userLocation)
            continue;
        
        MyAnnotation *ann =(MyAnnotation*) [annotations objectAtIndex:counter];
        if(ann.contactModel)  {
            int numberOfFutureMeet = ann.contactModel.futureMeetsExcludingTodaysMeets + ann.contactModel.todaysUpcommingMeets;
            
            MKAnnotationView *view = [mapView viewForAnnotation:ann];
            UIButton* btn = (UIButton* )view.rightCalloutAccessoryView;
            if(numberOfFutureMeet >0) {
                if(ann.contactModel.todaysUpcommingMeets > 0)   {
                    view.image = [UIImage imageNamed:@"greenf.png"];
                    [btn setBackgroundColor:[UIColor colorWithRed:0.2157 green:0.7765 blue:0.4471 alpha:1.0]];
                }
                else    {
                    view.image = [UIImage imageNamed:@"redf.png"];
                    [btn setBackgroundColor:[UIColor colorWithRed:0.8980 green:0.3020 blue:0.2588 alpha:1.0]];
                }
                                  
                [btn setTitle:[NSString stringWithFormat:@"%d",numberOfFutureMeet] forState:UIControlStateNormal];
                btn.hidden = NO;
            }
            else    {
                view.image = [UIImage imageNamed:@"bluef.png"];
                [btn setTitle:@"0" forState:UIControlStateNormal];
                btn.hidden = YES;
            }
        }
    }
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
   // self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
}

-(CLLocationDistance)getRadius  {
    NSString* area = [appdelegate.sharedSettingmanager getSearchAreaValue];
    CLLocationDistance radius = 50*1000;
    
    if(area)    {
        radius = [area doubleValue]*1000;
    }
    if(radius <= 0)
        radius = 50*1000;
    
    return radius;
}

-(void) setRegionForCurrentLocation:(BOOL)authorized {
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coord;
    // or a one shot fill
    coord = [location coordinate];
  
	// Do any additional setup after loading the view.
    //    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    //    region.center.latitude = coord.latitude;
    //    region.center.longitude = coord.longitude;
    //    region.span.longitudeDelta = 0.3f;
    //    region.span.latitudeDelta = 0.3f;
    
    CLLocationDistance radius = 50*1000;
    
    if(authorized)  {
       radius = [self getRadius];
    }
    else    {
        radius = 10000*1000;
        [appdelegate.sharedSettingmanager setSearchAreaValue:@"10000"];
    }
        
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
                                                                   CLLocationCoordinate2DMake(coord.latitude, coord.longitude), radius, radius);
    [mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if(status == kCLAuthorizationStatusAuthorized )
        [self setRegionForCurrentLocation:YES];
    else
        [self setRegionForCurrentLocation:NO];
}

-(void) showLocationOnMapWithDetail:(IMIContactModel*) contactModel {
    NSString*name = (NSString*)[appdelegate.sharedContactModelManager getFullName:contactModel.personRef];
    NSMutableString* address = [appdelegate.sharedContactModelManager getAddressString:contactModel.personRef];
    
    if(![address isEqualToString:@"Not Valid"])  {
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:address
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             
                             // Convert the CLPlacemark to an MKPlacemark
                             // Note: There's no error checking for a failed geocode
                             CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                             
                             CLLocation *location = [geocodedPlacemark location];
                             
                             CLLocationCoordinate2D coord = [location coordinate];
                             
                             // Do any additional setup after loading the view.
                             MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
                             region.center.latitude = coord.latitude;
                             region.center.longitude = coord.longitude;
                             
                             MyAnnotation *ann = [[MyAnnotation alloc] init];
                             ann.title = name;
                             ann.subtitle = address;
                             ann.coordinate = region.center;
                             ann.contactModel = contactModel;
                             [mapView addAnnotation:ann];
                             ann = NULL;
                         }];
        }
    }
}

-(void)configureAnnotationView:(MKAnnotationView *)av   {
    MyAnnotation *myAnn = (MyAnnotation *)av.annotation;
    UILabel *labelView = (UILabel *)[av viewWithTag:1];
    //remove image and show label...
    av.image = nil;
    if (labelView == nil)   {
        //create and add label...
        labelView = [[UILabel alloc]
                      initWithFrame:CGRectMake(0, 0, 50, 30)];
        labelView.tag = 1;
        labelView.textColor = [UIColor whiteColor];
        [av addSubview:labelView];
    }
    labelView.backgroundColor = [UIColor colorWithRed:0.8980 green:0.3020 blue:0.2588 alpha:1.0];
    labelView.text =[NSString stringWithFormat:@"%lld",myAnn.contactModel.futureMeetsExcludingTodaysMeets + myAnn.contactModel.todaysUpcommingMeets];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view   {
    
//    MyAnnotation *ann = [view annotation];
//    if([view annotation] == self.mapView.userLocation)
//        return;
//    
//    UIButton* btn = (UIButton* )view.rightCalloutAccessoryView;
//    NSDictionary* dict = (NSDictionary*)[_contactModelDataSource objectAtIndex:ann.annotationId];
//    ABRecordRef person = (__bridge ABRecordRef)[dict objectForKey:@"personRef"];
//    if(person)  {
//        ABRecordID ids = ABRecordGetRecordID(person);
//        
//        DataBase * db= [[DataBase alloc]init];
//        NSMutableArray* dates = [db readAllMeetDatesFromCurrentTimeWithContactId:ids];
//        int numberOfMeet = [dates count];
//        
//        if(numberOfMeet >0) {
//            BOOL havingTodaysMeet = [self havingTodaysMeeting:dates];
//            if(havingTodaysMeet)
//                view.image = [UIImage imageNamed:@"redpin.png"];
//            else
//                view.image = [UIImage imageNamed:@"green.png"];
//
//            [btn setTitle:[NSString stringWithFormat:@"%d",numberOfMeet] forState:UIControlStateNormal];
//            btn.hidden = NO;
//        }
//        else    {
//            view.image = [UIImage imageNamed:@"blue.png"];
//            [btn setTitle:@"0" forState:UIControlStateNormal];
//            btn.hidden = YES;
//        }
//    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation   {
	MKPinAnnotationView *pinView = nil;
	if(annotation != mapView.userLocation)  {
        static NSString *AnnotationViewID = @"annotationViewID";
        
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        if (annotationView == nil)  {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.canShowCallout = YES;
            //annotationView.animatesDrop = YES;
        }
        MyAnnotation *ann  = annotation;
        long int numberOfFutureMeets = ann.contactModel.todaysUpcommingMeets + ann.contactModel.futureMeetsExcludingTodaysMeets;
        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(10, 10, 32, 32)];
        [rightButton setBackgroundColor:[UIColor colorWithRed:0.8980 green:0.3020 blue:0.2588 alpha:1.0]];
        [rightButton setShowsTouchWhenHighlighted:YES];
        [[rightButton layer] setCornerRadius:12.0f];
        [[rightButton layer] setMasksToBounds:NO];
        rightButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        rightButton.layer.borderWidth = 2;
        [rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [rightButton setTitle:[NSString stringWithFormat:@"%ld", numberOfFutureMeets] forState:UIControlStateNormal];
        rightButton.tag = [ann.contactModel getRecordId];
        [rightButton addTarget:self
                        action:nil
              forControlEvents:UIControlEventTouchUpInside];
    
        annotationView.rightCalloutAccessoryView = rightButton;
        
        if(numberOfFutureMeets == 0) {
            annotationView.image = [UIImage imageNamed:@"bluef.png"];
            rightButton.hidden = YES;
        }
        else if(numberOfFutureMeets > 0)   {
            if(ann.contactModel.todaysUpcommingMeets > 0)   {
                annotationView.image = [UIImage imageNamed:@"greenf.png"];
                [rightButton setBackgroundColor:[UIColor colorWithRed:0.2157 green:0.7765 blue:0.4471 alpha:1.0]];
            }
            else    {
                 [rightButton setBackgroundColor:[UIColor colorWithRed:0.8980 green:0.3020 blue:0.2588 alpha:1.0]];
                 annotationView.image = [UIImage imageNamed:@"redf.png"];
            }
            rightButton.hidden = NO;
            [rightButton setTitle:[NSString stringWithFormat:@"%ld",numberOfFutureMeets] forState:UIControlStateNormal];
        }
        annotationView.annotation = annotation;
        return annotationView;
	}
	else    {
		[mapView.userLocation setTitle:@"You are here"];
//        static NSString *AnnotationViewID = @"annotationViewID";
//        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        if (annotation == mapView.userLocation) customPinView.image = [UIImage imageNamed:@"greenf.png"];
//        customPinView.animatesDrop = NO;
//        customPinView.canShowCallout = YES;
//        return customPinView;
        
//        static NSString* AnnotationIdentifier = @"Annotation";
//        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
//        
//        if (!pinView) {
//            
//            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
//            if (annotation == mapView.userLocation) customPinView.image = [UIImage imageNamed:@"gray.png"];
//            customPinView.animatesDrop = NO;
//            customPinView.canShowCallout = YES;
//            return customPinView;
//            
//        } else {
//            
//            pinView.annotation = annotation;
//        }
//        return pinView;
	}
    return pinView;
}

- (void) mapView: (MKMapView *) mapView annotationView: (MKAnnotationView *) view calloutAccessoryControlTapped: (UIControl *) control {
    
    if( control == view.leftCalloutAccessoryView ) {
        NSLog( @"-- Left button pressed" );
    } else if( control == view.rightCalloutAccessoryView ) {
         [self performSegueWithIdentifier:@"MapDetailSegue" sender:view];
        
    } else {
        NSLog( @"-- Neither right not left button pressed?" );
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender    {
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MapDetailSegue"]) {
        IMIDetailViewController *vc = [segue destinationViewController];
        
        MKAnnotationView * view = (MKAnnotationView *)sender;
         MyAnnotation *ann = [view annotation];
        [vc setContactModel:ann.contactModel];
        [vc setIsComeFromMap:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

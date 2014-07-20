//
//  IMIMapViewController.h
//  YO MAP
//
//  Created by imicreation on 20/09/13.
//  Copyright (c) 2013 Sean Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface IMIMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

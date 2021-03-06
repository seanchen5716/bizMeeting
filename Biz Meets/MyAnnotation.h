//
//  MyAnnotation.h
//  Mapper
//
//  Created by Geppy on 22/07/2009.
//  Copyright 2009 iNVASIVE CODE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "IMIContactModel.h"

@interface MyAnnotation : NSObject <MKAnnotation> 
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
    IMIContactModel*contactModel;
}

@property(nonatomic, weak) IMIContactModel* contactModel;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end

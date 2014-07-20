//
//  MyAnnotation.m
//  Mapper
//
//  Created by Geppy on 22/07/2009.
//  Copyright 2009 iNVASIVE CODE. All rights reserved.
//

#import "MyAnnotation.h"


@implementation MyAnnotation

@synthesize coordinate, title, subtitle;
@synthesize contactModel = _contactModel;

-(void)dealloc  {
    
    title = NULL;
    subtitle = NULL;
    
}

@end



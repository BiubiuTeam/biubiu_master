//
//  BMKMapLocationView.h
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BMKMapView.h"

@interface BMKMapLocationView : BMKMapView

- (void)setLocation:(CLLocationCoordinate2D)location withInfo:(NSString*)info;

@end

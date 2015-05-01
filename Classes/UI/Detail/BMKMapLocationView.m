//
//  BMKMapLocationView.m
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "BMKMapLocationView.h"
#import "DPLbsInformationView.h"
#import "DPLbsServerEngine.h"

@interface BMKMapLocationView ()

@property (nonatomic, strong) DPLbsInformationView* lbsInfoView;

@end

@implementation BMKMapLocationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = nil;
        [self createMapView];
        self.zoomLevel = 17;
        //切换为普通地图
        [self setMapType:BMKMapTypeStandard];
    }
    return self;
}

- (void)createMapView
{
    _lbsInfoView = [[DPLbsInformationView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [_lbsInfoView updateLabelTextColor:RGBACOLOR(0xff, 0xa2, 0x00, 1) font:[DPFont systemFontOfSize:FONT_SIZE_MIDDLE]];
    [_lbsInfoView resetLbsIcon:LOAD_ICON_USE_POOL_CACHE(@"bb_location_icon_hot.png")];
    
    _lbsInfoView.backgroundColor = RGBACOLOR(0xf7, 0xe0, 0x67, 0.5);
    
    [self addSubview:_lbsInfoView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_lbsInfoView) {
        _lbsInfoView.frame = self.bounds;
        [_lbsInfoView centerOpt];
    }
    [self bringSubviewToFront:_lbsInfoView];
}

- (void)setLocation:(CLLocationCoordinate2D)location withInfo:(NSString*)info
{
    //位置信息
    [_lbsInfoView updateLbsInformationWithText:info];
    [_lbsInfoView centerOpt];
    
    if (location.latitude == 0 && location.longitude == 0) {
        self.centerCoordinate = [[DPLbsServerEngine shareInstance] userLocation].location.coordinate;
    }else{
        self.centerCoordinate = location;
    }
}

- (void)dealloc
{
    DPTrace("释放地图展示区域");
}

@end

//
//  DPRefreshLbsInfoView.m
//  biubiu
//
//  Created by haowenliang on 15/3/28.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPRefreshLbsInfoView.h"

@interface DPRefreshLbsInfoView()
@property (nonatomic, strong) UIImageView* refreshIcon;
@end

@implementation DPRefreshLbsInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _refreshIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LBS_ICON_RADIUS, LBS_ICON_RADIUS)];
        _refreshIcon.contentMode = UIViewContentModeCenter;
        _refreshIcon.backgroundColor = [UIColor clearColor];
        _refreshIcon.clipsToBounds = YES;
        _refreshIcon.image = LOAD_ICON_USE_POOL_CACHE(@"bb_creator_refresh.png");
        [self addSubview:_refreshIcon];
        
        _refreshIcon.centerY = self.height/2;
        _refreshIcon.right = self.width - LBS_ICON_LEFT;
    }
    return self;
}



@end

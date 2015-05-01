//
//  DPGroupTopicViewController.h
//  biubiu
//
//  Created by haowenliang on 15/3/24.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPTableViewController.h"

typedef NS_ENUM(NSUInteger, UnionListType) {
    UnionListType_Public = 1,
    UnionListType_Mine = 2,
};

@interface DPGroupTopicViewController : DPTableViewController

@property (nonatomic, assign, readonly) UnionListType unionType;
- (instancetype)initWithUnionType:(UnionListType)type;

@end


@class DPSociatyModel;
@interface SociatyViewCell : UITableViewCell

@property (nonatomic, strong) DPSociatyModel* sociaty;
@property (nonatomic, strong) UIImageView* sociatyLogo;

@property (nonatomic, strong) UILabel* ptIcon;
@property (nonatomic, strong) UILabel* ptName;

@end
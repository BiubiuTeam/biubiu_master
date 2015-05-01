//
//  DPHomePageViewController.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPTableViewController.h"

@interface DPHomePageViewController : DPTableViewController

- (void)forceToUpdatePlatformInfo;
@end

typedef NS_ENUM(NSUInteger, HomePageType) {
    HomePageType_Default,
    HomePageType_Question,
    HomePageType_Answer,
    HomePageType_Union,
};

@interface HomePageTableModel : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, assign) HomePageType style;

@end
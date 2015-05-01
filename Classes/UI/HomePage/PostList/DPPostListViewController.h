//
//  DPPostListViewController.h
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPTableViewController.h"
#import "DPHomePageViewController.h"
@interface DPPostListViewController : DPTableViewController

@property (nonatomic, strong) NSMutableArray* datasource;

@property (nonatomic, assign) HomePageType listType;

- (instancetype)initWithPostListStyle:(HomePageType)type;

@end

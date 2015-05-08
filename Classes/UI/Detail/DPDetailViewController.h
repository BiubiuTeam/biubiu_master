//
//  DPDetailViewController.h
//  biubiu
//
//  Created by haowenliang on 15/2/1.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPTableViewController.h"
@class DPQuestionModel;
@interface DPDetailViewController : UIViewController

@property (nonatomic, assign) BOOL highLightUserReply;
@property (nonatomic, strong) DPQuestionModel* postDataModel;

- (instancetype)initWithPost:(id)post;

- (instancetype)initWithUnreadMessage:(id)model;

@property (nonatomic) BOOL inputBarIsFirstResponse;

@end

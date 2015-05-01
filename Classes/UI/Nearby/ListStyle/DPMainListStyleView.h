//
//  DPMainListStyleView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/15.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPMainEventHandler;

@interface DPMainListStyleView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* _tableView;
    CGRect _frame;
}
@property (nonatomic, strong) DPMainEventHandler* eventHandler;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) NSMutableArray* datasource;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic) BOOL isUpPullRefreshing;
@property (nonatomic) BOOL isEndOfMoreData;

@property (nonatomic, copy) DPCallbackBlock loadMoreOpt;

- (void)startAnimation;
- (void)stopAnimation;
- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateFooter:(BOOL)animating withMessage:(NSString*)msg;
@end

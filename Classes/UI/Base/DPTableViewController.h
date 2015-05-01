//
//  DPTableViewController.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

typedef NS_ENUM(NSUInteger, TableViewType) {
    TableViewType_Empty,
    TableViewType_Lbs,
    TableViewType_Network,
    TableViewType_Plain,
    TableViewType_Group,
};

@interface DPTableViewController : UITableViewController <EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    EGORefreshTableHeaderView* _PullDownRefreshView;
    EGORefreshTableHeaderView* _PullUpRefreshView;
    BOOL _reloading;
}


@property (nonatomic, assign) BOOL containsDownRefreshControl;
@property (nonatomic, assign) BOOL containsUpRefreshControl;

- (void)pullRefreshControlUpdatePosition;
- (void)addDownPullRefreshControl;
- (void)addUpPullRefreshControl;
- (void)removeUpPullRefreshControl;
- (void)removeDownPullRefreshControl;
- (void)pullRefreshControlRefreshDone;
- (void)pullRefreshControlStartRefresh:(EGORefreshTableHeaderView*)view;

- (void)removeTableHeaderView;


- (void)showLoadingView:(NSString*)message;
- (void)hideLoading;

@end

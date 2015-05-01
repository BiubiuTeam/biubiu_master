//
//  DPMainEventHandler.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/22.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPMainEventHandler.h"
#import "DPHomePageViewController.h"

//#import "DPDetailsViewController.h"
//#import "DPListViewController.h"

@implementation DPMainEventHandler

- (void)openMyBiuBiuHomePage
{
//    DPHomePageViewController* setting = [[DPHomePageViewController alloc] init];
//    [self.eventController.navigationController pushViewController:setting animated:YES];
}

- (void)openBiuBiuDetailViewController:(id)post
{
    [self openBiuBiuDetailViewController:post highLight:NO];
}

- (void)openBiuBiuDetailViewController:(id)post highLight:(BOOL)highlight
{
//    DPDetailsViewController* detail = [[DPDetailsViewController alloc] initWithPost:post];
//    detail.highLightUserReply = highlight;
//    [self.eventController.navigationController pushViewController:detail animated:YES];
}

- (void)openListViewController
{
//    DPListViewController* listCtr = [[DPListViewController alloc] init];
//    [self.eventController.navigationController pushViewController:listCtr animated:YES];
}

@end

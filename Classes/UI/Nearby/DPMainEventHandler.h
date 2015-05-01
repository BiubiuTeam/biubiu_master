//
//  DPMainEventHandler.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/22.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//


@interface DPMainEventHandler : NSObject

- (void)openMyBiuBiuHomePage;
- (void)openBiuBiuDetailViewController:(id)post;
- (void)openBiuBiuDetailViewController:(id)post highLight:(BOOL)highlight;
- (void)openListViewController;

@end

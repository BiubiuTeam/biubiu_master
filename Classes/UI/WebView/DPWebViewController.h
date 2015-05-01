//
//  DPWebViewController.h
//  TableViewDemo
//
//  Created by haowenliang on 14/12/23.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPWebViewController : UIViewController

/*
 *  default value to be yes
 */
@property (nonatomic, assign) BOOL canResetTitle;

- (instancetype)initWithHtml:(NSString*)html;

@end

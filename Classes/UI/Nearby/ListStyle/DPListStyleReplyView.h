//
//  DPListStyleReplyView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPListStyleReplyView : UIView
{
    NSMutableArray* _datasource;
}

@property (nonatomic, strong) NSMutableArray* datasource;
- (void)appendDatasource:(NSArray *)array;

- (void)resetReplyView;
- (void)setColorType:(NSInteger)type;

@end

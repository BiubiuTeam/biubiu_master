//
//  DPListStyleLeftView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ListStyleViewState) {
    ListStyleViewState_None = 0,
    ListStyleViewState_NotNone = 1,
    ListStyleViewState_Close = 2,
    ListStyleViewState_Open = 3,
};

@interface DPListStyleLeftView : UIButton
{
    UILabel* _numberLabel;
    UILabel* _infoLabel;
    UIView* _colorArea;
    UIImageView* _arrowView;
}

@property (nonatomic, assign) ListStyleViewState contentState;
- (void)displayArrowAndLabel;
- (void)setNumber:(NSInteger)number;

- (void)setColorAreaType:(NSInteger)type;
@end

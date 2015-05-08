//
//  DPListStyleReplyView.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/16.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, INFOTYPE) {
    INFOTYPE_EMPTY = 0,
    INFOTYPE_PROGRESS = 1,
};

@interface DPListStyleReplyView : UIView
{
    NSMutableArray* _datasource;
}

+ (instancetype)shareInstance;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) NSMutableArray* datasource;

@property (nonatomic, assign) NSInteger dankuIndex;

- (void)appendDatasource:(NSArray *)array;
- (void)resetReplyView;
- (void)setInformationType:(INFOTYPE)type;
- (void)removeInformationLabelWithAnimate:(BOOL)animate;
@end

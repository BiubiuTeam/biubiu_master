//
//  DPContentLabel.h
//  biubiu
//
//  Created by haowenliang on 15/1/31.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ContentType) {
    ContentType_Left,
    ContentType_Center,
};

@interface DPContentLabel : UILabel

@property (nonatomic, assign) CGFloat baseWidth;
@property (nonatomic, assign) ContentType type;

- (instancetype)initWithFrame:(CGRect)frame contentType:(ContentType)type;

- (void)setContentText:(NSString *)text;

+ (NSMutableParagraphStyle*)centerContentStyle;

+ (NSMutableParagraphStyle*)leftContentStyle;

+ (CGFloat)caculateHeightOfTxt:(NSString*)content
                   contentType:(ContentType)type
                      maxWidth:(CGFloat)width;

+ (CGFloat)caculateHeightOfTxt:(NSString*)content
                   contentType:(ContentType)type
                      maxWidth:(CGFloat)width
                         lines:(NSInteger)num;
@end

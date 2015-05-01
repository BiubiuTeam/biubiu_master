//
//  DPPublishViewController.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/8.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPHttpService+UnionExtension.h"

@interface DPPublishViewController : UIViewController

@property (nonatomic, assign, readonly) NSInteger curUnionId;
@property (nonatomic, assign, readonly) QuestionType qustionType;

- (instancetype)initWithCurUnionId:(NSInteger)unionId questionType:(QuestionType)type;

@end

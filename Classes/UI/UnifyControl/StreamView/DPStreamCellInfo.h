//
//  DPStreamCellInfo.h
//  StreamView
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dp-soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DPResusableCell <NSObject>

@property (nonatomic, strong) NSString *reuseIdentifier;

@end

@interface DPStreamCellInfo : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSUInteger index;
// You SHOULD ONLY access this property when this object is in visibleCellInfo!
@property (nonatomic, weak) UIView<DPResusableCell> *cell;

@end

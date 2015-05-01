//
//  DPUnionPostViewController.h
//  biubiu
//
//  Created by haowenliang on 15/3/25.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPTableViewController.h"

@interface DPUnionPostViewController : DPTableViewController

@property (nonatomic, assign, readonly) NSUInteger curUnionId;

- (instancetype)initWithUnionId:(NSUInteger)unionId;

@end

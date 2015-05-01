//
//  SSIndexPath.h
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSIndexPath : NSObject

+ (instancetype)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column;

@property(nonatomic, readonly) NSInteger column;
@property(nonatomic,readonly) NSInteger section;
@property(nonatomic,readonly) NSInteger row;

-(NSIndexPath *)innerIndexPath;

@end

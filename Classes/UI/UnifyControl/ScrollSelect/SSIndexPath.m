//
//  SSIndexPath.m
//  BiuBiu
//
//  Created by haowenliang on 15/1/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "SSIndexPath.h"

@interface SSIndexPath ()
@property (nonatomic,strong ) NSIndexPath *innerIndexPath;
@end

@implementation SSIndexPath

- (instancetype)init
{
    if (self = [super init])
    {
        _innerIndexPath = nil;
    }
    return self;
}

+ (SSIndexPath *)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column
{
    SSIndexPath *retVal = [[self alloc] init];
    retVal->_innerIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    retVal->_column = column;
    return retVal;
}

-(NSIndexPath *)innerIndexPath
{
    return self->_innerIndexPath;
}

-(NSInteger)section
{
    return self->_innerIndexPath.section;
}

-(NSInteger)row
{
    return self->_innerIndexPath.row;
}

@end

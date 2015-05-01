//
//  DPStreamCellInfo.m
//  StreamView
//
//  Created by haowenliang on 14/12/17.
//  Copyright (c) 2014年 dp-soft. All rights reserved.
//

#import "DPStreamCellInfo.h"

@implementation DPStreamCellInfo

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[DPStreamCellInfo class]]) return NO;
    
    return _index == [object index];
}

- (NSUInteger)hash
{
    return _index;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: index: %zd>",NSStringFromClass([self class]), _index];
}

@end

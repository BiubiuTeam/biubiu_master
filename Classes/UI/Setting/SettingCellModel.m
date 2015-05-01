//
//  SettingCellModel.m
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "SettingCellModel.h"

@implementation SettingCellModel

- (instancetype)init
{
    if (self = [super init]) {
        _selectionStyle = UITableViewCellSelectionStyleBlue;
        _userInteractionEnabled = YES;
        _cellValue = DPCellValue_Nonthing;
        _accessoryType = (DP_TableCell_Type)UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end

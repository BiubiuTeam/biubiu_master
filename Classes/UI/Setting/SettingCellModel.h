//
//  SettingCellModel.h
//  BiuBiu
//
//  Created by haowenliang on 14/12/21.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITableViewCell.h>

typedef NS_ENUM(NSUInteger, DP_TableCell_Type) {
    DP_TableCell_AccessoryNone,                   // don't show any accessory view
    DP_TableCell_AccessoryDisclosureIndicator,    // regular chevron. doesn't track
    DP_TableCell_AccessoryDetailDisclosureButton, // info button w/ chevron. tracks
    DP_TableCell_AccessoryCheckmark,              // checkmark. doesn't track
    DP_TableCell_AccessoryDetailButton,
    
    DP_TableCell_AccessorySwitch,
    DP_TableCell_AccessoryRedPoint,
};

typedef NS_ENUM(NSUInteger, DPCellValue) {
    DPCellValue_Nonthing = 0,
    DPCellValue_NewReplyNotify,
    DPCellValue_UserFeedBack,
    DPCellValue_ClearCache,
    DPCellValue_CheckUpdate,
    DPCellValue_AboutBB,
    DPCellValue_ContactUs,
    DPCellValue_UserProtocol,
    DPCellValue_GiveMeFive,
    
    DPCellValue_Appeal,//同步老版本数据
    DPCellValue_TestGate,
};

@interface SettingCellModel : NSObject

@property (nonatomic, strong) NSString* cellTitleTxt;
@property (nonatomic, strong) NSString* cellDetailTxt;

@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic) BOOL userInteractionEnabled;
@property (nonatomic) DP_TableCell_Type accessoryType;
@property (nonatomic) DPCellValue cellValue;
@end

//
//  DPLocalDataManager+DebugMode.m
//  biubiu
//
//  Created by haowenliang on 15/2/3.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "DPLocalDataManager+DebugMode.h"
#import "BackSourceInfo_2001.h"
#import "BackSourceInfo_2002.h"
#import "BackSourceInfo_2003.h"
#import "BackSourceInfo_2004.h"
#import "BackSourceInfo_2005.h"
#import "BackSourceInfo_2006.h"
#import "BackSourceInfo_2007.h"
#import "BackSourceInfo_2008.h"
#import "BackSourceInfo_4302.h"

@implementation DPLocalDataManager (DebugMode)


- (NSArray*)loadDebugDataOfCmd_2001
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"resource/a/2001" withExtension:@"json"];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    DPTrace("%@",json);
    
    NSError* err = nil;
    BackSourceInfo_2001* backsource = [[BackSourceInfo_2001 alloc] initWithString:json error:&err];
    
    if (err == nil) {
        DPTrace("%@", backsource.returnData);
        
        return [backsource.returnData contData];
    }else{
        DPTrace("failed");
    }
    return nil;
}

- (NSArray*)loadDebugDataOfCmd_4302
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"resource/a/4302" withExtension:@"json"];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    DPTrace("%@",json);
    
    NSError* err = nil;
    BackSourceInfo_4302* backsource = [[BackSourceInfo_4302 alloc] initWithString:json error:&err];
    
    if (err == nil) {
        DPTrace("%@", backsource.returnData);
        
        return [backsource.returnData contData];
    }else{
        DPTrace("failed");
    }
    return nil;
}
@end

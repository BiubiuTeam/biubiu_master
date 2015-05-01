//
//  DPNavLocationView.h
//  biubiu
//
//  Created by haowenliang on 15/3/30.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPNavLocationView : UIButton
@property (nonatomic, assign) BOOL needsHighlightImage;
- (void)setLbsLabelContent:(NSString*)content;
- (void)updateLayerContent:(UIImage*)image;
@end

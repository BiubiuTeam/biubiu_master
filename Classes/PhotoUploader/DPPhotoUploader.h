//
//  DPPhotoUploader.h
//  ImageCGIUploadDemo
//
//  Created by haowenliang on 14-8-28.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseUploader.h"

@interface DPPhotoUploader : DPBaseUploader
{
    NSURLRequest* request;
}
- (void)createRequestWithImage:(UIImage*)uploadImage;
@end

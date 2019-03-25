//
//  BFsAdAssistant.m
//  iphoneSize
//
//  Created by 刘玲 on 2019/3/22.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsAdAssistant.h"
#import <UIKit/UIKit.h>
#import "BFFileAssistant.h"

#define kPreDeviceBrandType @"PreDeviceBrandType"
#define kPreDeviceBrandTypeLogoPath @"BrandLogo"

@implementation BFsAdAssistant

#pragma mark - API

static BFsAdAssistant *assistant;
static dispatch_once_t onceToken;

+ (instancetype)shareAssistant {
    
    dispatch_once(&onceToken, ^{
        assistant = [[BFsAdAssistant alloc] init];
    });
    
    return assistant;
}

- (void)destoryAssistant {
    
    if (onceToken) {
        onceToken = 0;
        assistant = nil;
    }
}

//- (BOOL)isCachedDataLocally {
//
//    DeviceBrandType preType = [[NSUserDefaults standardUserDefaults] integerForKey:kPreDeviceBrandType];
//    NSArray *localResources = [self querylocalAdReaourceForDeviceType:DeviceBrandTypeAQ03];
//
//    return localResources.count > 0;
//}

- (NSArray *)querylocalAdReaourceForDeviceType:(DeviceBrandType)type {
    
    NSString *dirName = [NSString stringWithFormat:@"deviceType%lu", (unsigned long)type];
    NSString *dirPath = [[BFFileAssistant defaultAssistant] getDirectoryPathFromDirectories:@[dirName]];
    NSArray *resorces = [[BFFileAssistant defaultAssistant] getFilesFromDirectoryPath:dirPath];
    for (int i = 0; i < resorces.count; i++) {
        NSLog(@"i: %d, file name: %@", i, resorces[i]);
    }
    
    return resorces;
}

- (NSArray *)querylocalAdReaourceForDefault {
    
    NSArray *resorces = [self querylocalAdReaourceForDeviceType:DeviceBrandTypeDefault];
    
    return resorces;
}

- (void)downloadAdImageFromUrl:(NSString *)imgUrl asImage:(NSString *)imgName forBrand:(NSString *)brandName andResultBlock:(nonnull returnBlock)block{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        NSData *imgData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgUrl]] returningResponse:NULL error:NULL];
        UIImage *image = [UIImage imageWithData:imgData];
        
        NSString *basicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        if (brandName) {
            basicPath = [basicPath stringByAppendingPathComponent:brandName];
        }
        NSString *filePath = [basicPath stringByAppendingPathComponent:basicPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        // save
        NSData *resultData = UIImagePNGRepresentation(image);
        if (![resultData writeToFile:filePath atomically:YES]) {
            UIImage *newImage = [self scaleImage:image];
            resultData = UIImagePNGRepresentation(newImage);
            if ([resultData writeToFile:filePath atomically:YES]) {// 保存成功
                NSLog(@"%@保存成功", imgName);
            }else{
                NSLog(@"%@保存失败", imgName);
            }
        }
        
        if (block) {
            block(nil, filePath);
        }
    });
}


- (UIImage *)scaleImage:(UIImage *)image{
    //确定压缩后的size
    CGFloat scaleWidth = image.size.width;
    CGFloat scaleHeight = image.size.height;
    CGSize scaleSize = CGSizeMake(scaleWidth, scaleHeight);
    //开启图形上下文
    UIGraphicsBeginImageContext(scaleSize);
    //绘制图片
    [image drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    //从图形上下文获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}

@end

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

- (BOOL)isCachedDataLocally {
    
    return NO;
}

- (void)downloadAdImageFromUrl:(NSString *)imgUrl asImage:(NSString *)imgName forBrand:(NSString *)brandName andResultBlock:(nonnull returnBlock)block{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        UIImage *image = [UIImage imageWithData:imgData];
        
        if (brandName) {
            NSString *basicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [[basicPath stringByAppendingPathComponent:brandName] stringByAppendingPathComponent:imgName];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            // m1
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
            // m2
//            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
//            [fileHandle writeData:imgData];
            
            if (block) {
                block(nil, filePath);
            }            
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

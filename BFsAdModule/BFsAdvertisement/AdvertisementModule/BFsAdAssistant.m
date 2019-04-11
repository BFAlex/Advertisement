//
//  BFsAdAssistant2.m
//  BFsAD
//
//  Created by 刘玲 on 2019/4/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsAdAssistant.h"
#import "BFsBrandMode.h"
#import <UIKit/UIKit.h>
#import "BFFileAssistant.h"

#define kDefaultBrand   @"default"

@interface BFsAdAssistant ()

@end

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

- (void)requireAdvertisementInfo {
    NSString *pUrlStr = @"http://ligoor.com/upload/voxcam/voxcam.gson";
    [self requireAdvertisementDataFromUrl:pUrlStr andResultBlock:^(NSError *error, id result) {
        if (error) {
            // NSLog(@"error: %@", error.description);
        } else {
            // NSLog(@"data: %@", result);
            id modes = [self handleAdData:result];
            if (modes) {
                [self downloadResourcesFromNetwork:modes andResultBlock:^(id result, NSError *error, ResultType type) {
                    //
                    // NSLog(@"result type: %lu", (unsigned long)type);
                    if (ResultTypeSaveResource == type) {
                        // NSLog(@"end");
                    }
                }];
            }
        }
    }];;
}

/*
 返回优先级：
 brand > default > nil
 */
- (id)loadBrandAdvertisement:(NSString *)brand {
    
    if (brand.length < 1) {
        return nil;
    }
    
    BFFileAssistant *fileAssistant = [BFFileAssistant defaultAssistant];
    NSString *brandDirePath = [fileAssistant getDirectoryPathOfFolderInDocumentsDirectory:brand];
    NSArray *files = [fileAssistant getFilesFromDirectoryPath:brandDirePath];
    if (files.count < 1 && ![brand isEqualToString:kDefaultBrand]) {
        return [self loadBrandAdvertisement:kDefaultBrand];
    } else {
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:brand forKey:kBrandKey];
        for (NSString *fileName in files) {
            NSString *filePath = [brandDirePath stringByAppendingPathComponent:fileName];
            [resultDict setObject:filePath forKey:fileName];
        }
        
        return resultDict;
    }
}

#pragma mark - Advertisement

- (void)requireAdvertisementDataFromUrl:(NSString *)pUrlStr andResultBlock:(returnBlock)block {
    
     NSString *urlStr = [pUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 异步请求
    [self requestDataAsynchronously:[NSURL URLWithString:urlStr] andResultBlock:block];
}

- (void)requestDataAsynchronously:(NSURL *)pUrl andResultBlock:(returnBlock)block {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:pUrl];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (block) {
            block(connectionError, data);
        }
    }];
}
// 同步请求
- (id)requestDataSynchronously:(NSURL *)pUrl andError:(NSError **)error {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:pUrl];
    NSData *AdData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    
    return AdData;
}

#pragma mark Data change to mode
- (id)handleAdData:(NSData *)AdData {
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:AdData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        // NSLog(@"error: %@", error.description);
        goto END_Fail;
    } else {
        // NSLog(@"result Dict: %@", resultDict);
        NSDictionary *updatasDict = [resultDict objectForKey:@"updatas"];
        NSArray *updataPlatformArr = [updatasDict objectForKey:@"updataplatform"];
        NSString *targetPlatform = @"ios";
        NSDictionary *targetDict;
        for (id item in updataPlatformArr) {
            NSDictionary *itemDict;
            if ([item isKindOfClass:[NSDictionary class]]) {
                itemDict = (NSDictionary *)item;
            }
            if (!itemDict) {
                continue;
            }
            
            NSString *platform = [itemDict objectForKey:@"platform"];
            if ([platform isEqualToString:targetPlatform]) {
                targetDict = itemDict;
                break;
            }
        }
        if (!targetDict) {
            goto END_Fail;
        }
        
        return [self handlePlatformData:targetDict];
    }
    
END_Fail:
    return nil;
}
- (id)handlePlatformData:(NSDictionary *)dataDict {
    
    NSArray *brands = [dataDict objectForKey:@"updatabrand"];
    NSMutableArray *brandModeArr = [NSMutableArray array];
    // Mode change
    for (NSDictionary *brandDict in brands) {
        BFsBrandMode *brandMode = [BFsBrandMode modeWithData:brandDict];
        [brandModeArr addObject:brandMode];
    }
    
    return [brandModeArr copy];
}

#pragma mark Download Resource

- (void)downloadResourcesFromNetwork:(id)modes andResultBlock:(resultBlock2)block {
    
    // 清空所有品牌对应的tmp文件目录
//    [self clearTempDirectoryResource:modes];
    [self clearTargetDirectoryResource:modes isTempDirectory:YES];
    
    // 下载
    dispatch_queue_global_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t downloadGroup = dispatch_group_create();
    // Task
    __block int taskFinishNum = 0;
    for (BFsBrandMode *mode in modes) {
        
        [self addAsynchronousDownloadTaskInGroup:downloadGroup queue:downloadQueue url:mode.advertDown1 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"task >>> %@: 1", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        [self addAsynchronousDownloadTaskInGroup:downloadGroup queue:downloadQueue url:mode.advertDown2 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"task >>> %@: 2", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        [self addAsynchronousDownloadTaskInGroup:downloadGroup queue:downloadQueue url:mode.advertDown3 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"task >>> %@: 3", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        [self addAsynchronousDownloadTaskInGroup:downloadGroup queue:downloadQueue url:mode.iconDown brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"task >>> %@: icon", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
    }
    // Result
    dispatch_group_notify(downloadGroup, downloadQueue, ^{
        //
        if (taskFinishNum == [self getAllTaskNum:modes]) {
            // NSLog(@" >>>>>> 所有下载任务全部成功完成");
            [self moveFilesFromTempToTargetDirectory:modes andResultBlock:block];
        } else {
            if (block) {
                block(nil, nil, ResultTypeDefault);
            }
        }
    });
}

// 把文件从临时目录转移到需求目录
- (void)moveFilesFromTempToTargetDirectory:(id)modes andResultBlock:(resultBlock2)block {
    
    // 清空目标目录中原有文件
    [self clearTargetDirectoryResource:modes isTempDirectory:NO];
    
    // 转移文件
    dispatch_queue_global_t moveQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t moveGroup = dispatch_group_create();
    
    __block int taskFinishNum = 0;
    for (BFsBrandMode *mode in modes) {
        
        [self addAsynchronousMoveTaskInGroup:moveGroup queue:moveQueue url:mode.advertDown1 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"move >>> %@: 1", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        
        [self addAsynchronousMoveTaskInGroup:moveGroup queue:moveQueue url:mode.advertDown2 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"move >>> %@: 2", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        
        [self addAsynchronousMoveTaskInGroup:moveGroup queue:moveQueue url:mode.advertDown3 brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"move >>> %@: 3", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
        
        [self addAsynchronousMoveTaskInGroup:moveGroup queue:moveQueue url:mode.iconDown brand:mode.brand andResultBlock:^(id result, NSError *error, ResultType type) {
            //
            // NSLog(@"move >>> %@: icon", mode.brand);
            if (type == ResultTypeDefaultSuccess) {
                taskFinishNum++;
            }
        }];
    }
    
    dispatch_group_notify(moveGroup, moveQueue, ^{
        //
        // NSLog(@"finish task num: %d", taskFinishNum);
        NSArray *modeArr = (NSArray *)modes;
        if (taskFinishNum == [self getAllTaskNum:modes] || taskFinishNum == modeArr.count * 2) {
            // NSLog(@" >>>>>> 所有移动任务全部成功完成");
            for (BFsBrandMode *mode in modes) {
                NSString *tmpDirePath = [self getTargetBrandDirectoryPath:mode.brand isTempDirectory:YES];
                NSArray *files = [[BFFileAssistant defaultAssistant] getFilesFromDirectoryPath:tmpDirePath];
                // NSLog(@"%@ tmp file num: %lu", mode.brand, (unsigned long)files.count);
            }
        }
        
        if (block) {
            block(nil, nil, ResultTypeSaveResource);
        }
    });
}

- (int)getAllTaskNum:(id)modes {
    
    NSArray *modeArr = (NSArray *)modes;
    return (int)modeArr.count * 4;
}

// 添加单移动任务
- (void)addAsynchronousMoveTaskInGroup:(dispatch_group_t)taskGroup
                                     queue:(dispatch_queue_t)taskQueue
                                       url:(NSString *)urlStr
                                     brand:(NSString *)brand
                            andResultBlock:(resultBlock2)block {
    
    ResultType resType;
    BFFileAssistant *fileAssistant = [BFFileAssistant defaultAssistant];
    NSString *fileName = [[urlStr componentsSeparatedByString:@"/"] lastObject];
    
    NSString *tmpFileDire = [self getTargetBrandDirectoryPath:brand isTempDirectory:YES];
    BOOL isExists = [fileAssistant fileExists:fileName inDirectoryPath:tmpFileDire];
    if (!isExists) {
        resType = ResultTypeDefaultFail;
    } else {
        
        NSString *tmpFilePath = [self getTargetFilePath:fileName brand:brand isTemp:YES];
        NSString *targetFilePath = [self getTargetFilePath:fileName brand:brand isTemp:NO];
        
        if ([fileAssistant moveFileFromPath:tmpFilePath toPath:targetFilePath]) {
            resType = ResultTypeDefaultSuccess;
            // 移除tmp文件
            [fileAssistant deleteFileAtPath:tmpFilePath error:nil];
        } else {
            resType = ResultTypeDefaultFail;
        }
    }
    
    if (block) {
        block(nil, nil, resType);
    }
}

// 添加单下载任务
- (void)addAsynchronousDownloadTaskInGroup:(dispatch_group_t)taskGroup
                             queue:(dispatch_queue_t)taskQueue
                               url:(NSString *)urlStr
                             brand:(NSString *)brand
                    andResultBlock:(resultBlock2)block {
    
    dispatch_group_async(taskGroup, taskQueue, ^{
    // 方法一（耗时）:
    //            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mode.advertDown1]];
        // 方法二:
        NSData *imgData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] returningResponse:NULL error:NULL];
        UIImage *image = [UIImage imageWithData:imgData];
        if (block) {
            block(image, nil, ResultTypeDownload);
        }
        
        // 把图片保存到本地
        NSString *fileName = [[urlStr componentsSeparatedByString:@"/"] lastObject];
        [self saveToLocalImage:image name:fileName brand:brand andResultBlock:block];
    });
}

- (NSString *)getTargetBrandDirectoryPath:(NSString *)brand isTempDirectory:(BOOL)isTemp {
    
    BFFileAssistant *fileAssistant = [BFFileAssistant defaultAssistant];
    NSString *brandDire = isTemp ? [NSString stringWithFormat:@"tmp%@", brand] : [NSString stringWithFormat:@"%@", brand];
    NSString *direPath = [fileAssistant getDirectoryPathOfFolderInDocumentsDirectory:brandDire];
    
    return direPath;
}

- (void)clearTargetDirectoryResource:(id)modes isTempDirectory:(BOOL)isTemp {
    
    BFFileAssistant *fileAssistant = [BFFileAssistant defaultAssistant];
    
    for (BFsBrandMode *mode in modes) {
        NSString *direPath = [self getTargetBrandDirectoryPath:mode.brand isTempDirectory:isTemp];
        NSArray *files = [fileAssistant getFilesFromDirectoryPath:direPath];
        for (NSString *fileName in files) {
            NSString *filePath = [fileAssistant getFilePath:fileName fromDirectoryPath:direPath];
            [fileAssistant deleteFileAtPath:filePath error:nil];
        }
    }
}

- (NSString *)getTargetFilePath:(NSString *)fileName brand:(NSString *)brand isTemp:(BOOL)isTemp {
    
    BFFileAssistant *fileAssistant = [BFFileAssistant defaultAssistant];
    NSString *direPath = [self getTargetBrandDirectoryPath:brand isTempDirectory:isTemp];
    NSString *filePath = [fileAssistant getFilePath:fileName fromDirectoryPath:direPath];
    
    return filePath;
}

// 图片保存到本地
- (void)saveToLocalImage:(UIImage *)image name:(NSString *)localFileName brand:(NSString *)brand
          andResultBlock:(resultBlock2)block {
    // NSLog(@"name:%@, brand:%@", localFileName, brand);
    
    NSString *tmpFilePath = [self getTargetFilePath:localFileName brand:brand isTemp:YES];
    
    ResultType resType;
    NSData *imgData = UIImagePNGRepresentation(image);
    if (!imgData) {
        resType = ResultTypeDefaultFail;
        goto END;
    }
    
    if (![imgData writeToFile:tmpFilePath atomically:YES]) {
        UIImage *newImage = [self scaleImage:image];
        imgData = UIImagePNGRepresentation(newImage);
        if ([imgData writeToFile:tmpFilePath atomically:YES]) {// 保存成功
            // NSLog(@">>>%@保存成功", localFileName);
            resType = ResultTypeDefaultSuccess;
        }else{
            // NSLog(@">>>%@保存失败", localFileName);
            resType = ResultTypeDefaultFail;
        }
    } else {
        // NSLog(@"》〉》〉%@保存成功", localFileName);
        resType = ResultTypeDefaultSuccess;
    }
    
END:
    if (block) {
        block(nil, nil, resType);
    }
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

//
//  BFsAdAssistant2.h
//  BFsAD
//
//  Created by 刘玲 on 2019/4/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

/*
 版本更新说明
 1、增加了设置品牌的API；
 2、更新了加载品牌广告的API；
 */

#import <Foundation/Foundation.h>

#define kBrandKey  @"brand"

typedef enum : NSUInteger {
    ResultTypeDefault,  // 不作解释
    ResultTypeDownload,
    ResultTypeSaveResource,
    ResultTypeDefaultSuccess,
    ResultTypeDefaultFail,
} BFsResultType;

typedef void(^resultBlock2)(id result, NSError *error, BFsResultType type);
typedef void(^returnBlock)(NSError *error, id result);

NS_ASSUME_NONNULL_BEGIN

@interface BFsAdAssistant2 : NSObject

+ (instancetype)shareAssistant;
- (void)destoryAssistant;
// 加载广告数据
- (void)requireAdvertisementInfoFromUrl:(NSString *)pUrlStr andResultBlock:(returnBlock)block;
// 获取某品牌广告数据
- (id)loadBrandAdvertisements;
// 设备广告品牌
- (void)setBrand:(NSString *)brand;

@end

NS_ASSUME_NONNULL_END

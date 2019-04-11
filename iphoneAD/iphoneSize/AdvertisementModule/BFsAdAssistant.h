//
//  BFsAdAssistant2.h
//  BFsAD
//
//  Created by 刘玲 on 2019/4/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBrandKey  @"brand"

typedef enum : NSUInteger {
    ResultTypeDefault,  // 不作解释
    ResultTypeDownload,
    ResultTypeSaveResource,
    ResultTypeDefaultSuccess,
    ResultTypeDefaultFail,
} ResultType;

typedef void(^resultBlock2)(id result, NSError *error, ResultType type);
typedef void(^returnBlock)(NSError *error, id result);

NS_ASSUME_NONNULL_BEGIN

@interface BFsAdAssistant : NSObject

+ (instancetype)shareAssistant;
- (void)destoryAssistant;
// 加载广告数据
- (void)requireAdvertisementInfo;
// 获取某品牌广告数据
- (id)loadBrandAdvertisement:(NSString *)brand;

@end

NS_ASSUME_NONNULL_END

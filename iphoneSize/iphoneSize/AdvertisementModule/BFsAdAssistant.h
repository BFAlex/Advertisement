//
//  BFsAdAssistant.h
//  iphoneSize
//
//  Created by 刘玲 on 2019/3/22.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^returnBlock)(NSError *error, id result);

NS_ASSUME_NONNULL_BEGIN

@interface BFsAdAssistant : NSObject

+ (instancetype)shareAssistant;
- (void)destoryAssistant;
- (BOOL)isCachedDataLocally;
- (void)downloadAdImageFromUrl:(NSString *)imgUrl asImage:(NSString *)imgName forBrand:(NSString *)brandName andResultBlock:(returnBlock)block;

@end

NS_ASSUME_NONNULL_END

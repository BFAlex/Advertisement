//
//  BFsAdMode.h
//  BFsAD
//
//  Created by 刘玲 on 2019/4/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFsBrandMode : NSObject

@property (nonatomic, strong) NSString *brand;
//
@property (nonatomic, strong) NSString *advertVersion;
@property (nonatomic, strong) NSString *advertDown1;
@property (nonatomic, strong) NSString *advertDown2;
@property (nonatomic, strong) NSString *advertDown3;
//
@property (nonatomic, strong) NSString *iconVersion;
@property (nonatomic, strong) NSString *iconDown;


+ (id)modeWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END

//
//  BFsAdMode.m
//  BFsAD
//
//  Created by 刘玲 on 2019/4/11.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsBrandMode.h"

@implementation BFsBrandMode

+ (id)modeWithData:(NSDictionary *)data {
    
    BFsBrandMode *mode = [[BFsBrandMode alloc] init];
    if (mode && data) {
        
        NSDictionary *advertisementDict = [data objectForKey:@"advertisement"];
        NSDictionary *icontagDict = [data objectForKey:@"icontag"];
        
        mode.brand = [data objectForKey:@"brand"];
        //
        mode.advertVersion = [advertisementDict objectForKey:@"advertversion"];
        mode.advertDown1 = [advertisementDict objectForKey:@"advertdown1"];
        mode.advertDown2 = [advertisementDict objectForKey:@"advertdown2"];
        mode.advertDown3 = [advertisementDict objectForKey:@"advertdown3"];
        //
        mode.iconVersion = [icontagDict objectForKey:@"iconversion"];
        mode.iconDown = [icontagDict objectForKey:@"icondown"];
    }
    
    return mode;
}

@end

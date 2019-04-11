//
//  ViewController.m
//  iphoneSize
//
//  Created by 刘玲 on 2019/3/22.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "ViewController.h"
#import "BFsAdAssistant.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self testAdvertisementModule];
}

- (void)testAdvertisementModule {
    
    NSString *brand = @"AQ03";
    [[BFsAdAssistant shareAssistant] requireAdvertisementInfo];
    //
    NSDictionary *ads = [[BFsAdAssistant shareAssistant] loadBrandAdvertisement:brand];
    NSLog(@"%@ >>> ads: %@", brand, ads);
    NSArray *keys = [ads allKeys];
    NSString *filePath;
    for (NSString *key in keys) {
        NSLog(@"@{%@ : %@}\n", key, [ads objectForKey:key]);
        if (filePath.length < 1 && ![key isEqualToString:kBrandKey]) {
            filePath = [ads objectForKey:key];
        }
    }
    //
    if (filePath.length > 0) {
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        self.imageView.image = [UIImage imageWithData:imgData];
    }
}

@end

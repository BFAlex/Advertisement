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
    
    [self downloadAD];
}

- (void)downloadAD {
    
    NSString *urlStr = @"http://139.224.70.115/upload/voxcam/image/adwance_logo.png";
    NSString *imgName = @"adwance_logo.png";
    NSString *brand = @"AQ03";
    [[BFsAdAssistant shareAssistant] downloadAdImageFromUrl:urlStr asImage:imgName forBrand:brand andResultBlock:^(NSError *error, id result) {
            dispatch_async(dispatch_get_main_queue(), ^{                
                NSString *localPath = (NSString *)result;
                NSData *localData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:localPath]];
                UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                self.imageView.image = image;
            });
    }];
    
    
}

@end

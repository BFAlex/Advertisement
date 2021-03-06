//
//  BFFileAssistant.h
//  BFFileManagerDemo
//
//  Created by 刘玲 on 2018/9/13.
//  Copyright © 2018年 BFAlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^resultBlock)(id target, id result, NSError *error);

@interface BFFileAssistant : NSObject

+ (instancetype)defaultAssistant;

#pragma mark - 本地文件路径
/*
 默认在Documents目录上的一个目录
 **/
- (NSString *)getDirectoryPathOfFolderInDocumentsDirectory:(NSString *)folderName;
/*
 默认在Documents目录上n个级别目录
 **/
- (NSString *)getDirectoryPathFromDirectories:(NSArray *)directoryList;
- (NSString *)getDirectoryPathFromDirectories:(NSArray *)directoryList isBaseOnDocuments:(BOOL)isInDocumentsFolder;
// 文件路径
- (NSString *)getFilePath:(NSString *)fileName fromDirectoryPath:(NSString *)dirtPath;

#pragma mark - Function
#pragma mark  查
- (NSArray *)getFilesFromDirectoryPath:(NSString *)directoryPath;
- (BOOL)fileExists:(NSString *)fileName inDirectoryPath:(NSString *)directoryPath;
#pragma mark  增
- (BOOL)saveFile:(NSData *)fData toPath:(NSString *)filePath;
- (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
#pragma mark  删
- (BOOL)deleteFileAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - Album
- (void)saveImage:(UIImage *)image toAlbum:(NSString *)albumName andResult:(resultBlock)resultBlock;
- (BOOL)saveImage:(UIImage *)image toLocalPath:(NSString *)path;

@end

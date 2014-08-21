//
//  XHImageLoader.h
//  XinHua
//
//  Created by xuzepei on 09-9-8.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCImageHttpRequest.h"

@interface RCImageLoader : NSObject<RCHttpRequestDelegate>{

}

@property (nonatomic, strong) NSMutableArray* imageArray;
@property (nonatomic, strong) NSMutableArray* requestingURLArray;
@property (nonatomic, strong) NSMutableArray* failedURLArray;

+ (RCImageLoader*)sharedInstance;
- (void)downloadImage:(NSString*)url delegate:(id)delegate token:(id)token;
- (void)saveImage:(NSString*)url delegate:(id)delegate token:(id)token;
- (UIImage*)getImage:(NSString*)imagePath;

@end


@protocol RCImageLoaderDelegate
@optional
- (void)startLoad:(id)token;
- (void)succeedLoad:(id)result token:(id)token;
- (void)failedLoadWithError:(id)token;
- (void)loader:(RCImageLoader*)loader succeedLoad:(id)result fromURL:(NSString*)url token:(id)token;
- (void)loader:(RCImageLoader*)loader failedLoadWithError:(NSError*)error fromURL:(NSString*)url token:(id)token;

@end




//
//  RCTool.m
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RCTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "TBXML.h"
#import "RCAppDelegate.h"
#import "MBProgressHUD.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation RCTool

+ (NSString*)getUserDocumentDirectoryPath
{
//	NSArray* array = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
//	if([array count])
//		return [array objectAtIndex: 0];
//	else
//		return @"";
    
    return NSTemporaryDirectory();
}

+ (NSString *)md5:(NSString *)str 
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];	
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    
    for(int i = [windows count] - 1; i >= 0; i--)
    {
        UIWindow *frontWindow = [windows objectAtIndex:i];
        //NSLog(@"window class:%@",[frontWindow class]);
//        if(![frontWindow isKindOfClass:[MTStatusBarOverlay class]])
            return frontWindow;
    }
    
	return nil;
}

+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor*)colorWithHex:(NSInteger)hexValue
{
    return [RCTool colorWithHex:hexValue alpha:1.0];
}

+ (NSDictionary*)parseToDictionary:(NSString*)jsonString
{
    if(0 == [jsonString length])
		return nil;
    
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(nil == data)
        return nil;
    
    NSError* error = nil;
    NSJSONSerialization* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(error)
    {
        NSLog(@"parse errror:%@",[error localizedDescription]);
        return nil;
    }
    
    if([json isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)json;
    }
    
	return nil;
}

+ (void)showIndicator:(NSString*)text
{
    MBProgressHUD * indicator = [MBProgressHUD showHUDAddedTo:[RCTool frontWindow] animated:YES];
    indicator.labelText = text;
}

+ (void)hideIndicator
{
    [MBProgressHUD hideHUDForView:[RCTool frontWindow] animated:YES];
}

+ (UITabBarController*)getTabBarController
{
    UIStoryboard* iPhoneStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    if(iPhoneStoryBoard)
    {
        return [iPhoneStoryBoard instantiateInitialViewController];
    }
    
    return nil;
}

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
    alert.tag = 110;
	[alert show];
    
    
}

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - network

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

+ (BOOL)isReachableViaWiFi
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

#pragma mark - 文件操作

+ (BOOL)saveImage:(NSData*)data path:(NSString*)path
{
	if(nil == data || 0 == [path length])
		return NO;
    
    NSString* directoryPath = [NSString stringWithFormat:@"%@/images",[RCTool getUserDocumentDirectoryPath]];
    if(NO == [RCTool isExistingFile:directoryPath])
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
	
    NSString* suffix = @"";
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound && ([path length] - range.location <= 4))
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	NSString* savePath = nil;
	if([suffix length])
    {
		savePath = [NSString stringWithFormat:@"%@/images/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
    }
	else
		savePath = [NSString stringWithFormat:@"%@/images/%@",[RCTool getUserDocumentDirectoryPath],md5Path];
	
	//保存原图
	if(NO == [data writeToFile:savePath atomically:YES])
        return NO;
	
	
//	//保存小图
//	UIImage* image = [UIImage imageWithData:data];
//	if(nil == image)
//		return NO;
//    
//    if(image.size.width <= 140 || image.size.height <= 140)
//    {
//        return [data writeToFile:saveSmallImagePath atomically:YES];
//    }
//	
//	CGSize size = CGSizeMake(140, 140);
//	// 创建一个bitmap的context  
//	// 并把它设置成为当前正在使用的context  
//	UIGraphicsBeginImageContext(size);  
//	
//	// 绘制改变大小的图片  
//	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];  
//	
//	// 从当前context中创建一个改变大小后的图片  
//	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
//	
//	// 使当前的context出堆栈  
//	UIGraphicsEndImageContext();  
//	
//	NSData* data2 = UIImagePNGRepresentation(scaledImage);
//	if(data2)
//    {
//		return [data2 writeToFile:saveSmallImagePath atomically:YES];
//    }
	
	return YES;
}


+ (UIImage*)getImageFromLocal:(NSString*)path
{
	if(0 == [path length])
		return nil;
	
    NSString* suffix = @"";
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound && ([path length] - range.location <= 4))
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	NSString* savePath = nil;
	if([suffix length])
		savePath = [NSString stringWithFormat:@"%@/images/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		savePath = [NSString stringWithFormat:@"%@/images/%@",[RCTool getUserDocumentDirectoryPath],md5Path];
	
	return [UIImage imageWithContentsOfFile:savePath];
}

+ (NSString*)getImageLocalPath:(NSString *)path
{
	if(0 == [path length])
		return nil;
	
    NSString* suffix = @"";
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound && ([path length] - range.location <= 4))
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	if([suffix length])
		return [NSString stringWithFormat:@"%@/images/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		return [NSString stringWithFormat:@"%@/images/%@",[RCTool getUserDocumentDirectoryPath],md5Path];
}


+ (BOOL)isExistingFile:(NSString*)path
{
	if(0 == [path length])
		return NO;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:path];
}

+ (BOOL)removeFile:(NSString*)filePath
{
    if([filePath length])
        return [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                   error:nil];
    
    return NO;
}

/**
 隐藏UIWebView拖拽时顶部的阴影效果
 */
+ (void)hidenWebViewShadow:(UIWebView*)webView
{
    if(nil == webView)
        return;
    
    if ([[webView subviews] count])
    {
        for (UIView* shadowView in [[[webView subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        
        // unhide the last view so it is visible again because it has the content
        [[[[[webView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
}

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isIpad
{
	UIDevice* device = [UIDevice currentDevice];
	if(device.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
	{
		return NO;
	}
	else if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	
	return NO;
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}


#pragma mark - CoreData

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
	//NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
	//															initWithFetchRequest:fetchRequest
	//															managedObjectContext:context
	//															sectionNameKeyPath:nil
	//															cacheName:@"Root"];
	//
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (void)saveCoreData
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil)
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error])
		{
            
        }
    }
}

#pragma mark - App Info

+ (NSString*)getAdId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_id = [app_info objectForKey:@"ad_id"];
        if([ad_id length])
            return ad_id;
    }
    
    return AD_ID;
}

+ (NSString*)getScreenAdId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_id = [app_info objectForKey:@"mediation_id"];
        if(0 == [ad_id length])
            ad_id = [app_info objectForKey:@"screen_ad_id"];
        
        if([ad_id length])
            return ad_id;
    }
    
    return SCREEN_AD_ID;
}

+ (int)getScreenAdRate
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_rate = [app_info objectForKey:@"screen_ad_rate"];
        if([ad_rate intValue] > 0)
            return [ad_rate intValue];
    }
    
    return SCREEN_AD_RATE;
}

+ (NSString*)getAppURL
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* link = [app_info objectForKey:@"link"];
        if([link length])
            return link;
    }
    
    return APP_URL;
}

+ (BOOL)isOpenAll
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* openall = [app_info objectForKey:@"openall"];
        if([openall isEqualToString:@"1"])
            return YES;
    }
    
    return NO;
}

+ (UIView*)getAdView
{
    RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.adMobAd)
    {
        UIView* adView = appDelegate.adMobAd;
        if(adView)
            return adView;
    }
    
    return nil;
}

+ (NSString*)decryptUseDES:(NSString*)cipherText key:(NSString*)key {
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[4096*100];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    // IV 偏移量不需使用
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          4096*100,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

+ (NSString *)encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[4096*100];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          4096*100,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }else{
        NSLog(@"DES加密失败");
    }
    return plainText;
}

+ (NSString*)decrypt:(NSString*)text
{
    if(0 == [text length])
        return @"";
    
    NSString* key = SECRET_KEY;
    NSString* encrypt = text;
    NSString* decrypt = [RCTool decryptUseDES:encrypt key:key];
    
    if([decrypt length])
        return decrypt;
    
    return @"";
}

+ (NSString*)getTextById:(NSString*)textId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* text_dict = [app_info objectForKey:@"text_dict"];
        if([text_dict isKindOfClass:[NSDictionary class]])
        {
            if([RCTool isOpenAll])
            {
                NSString* text = [text_dict objectForKey:textId];
                if([text length])
                    return text;
            }
        }
    }
    
    if([textId isEqualToString:@"ti_0"])
    {
        return @"设置";
    }
    else if([textId isEqualToString:@"ti_1"])
    {
        return @"精品应用推荐";
    }
    else if([textId isEqualToString:@"ti_2"])
    {
        return @"点击清除缓存";
    }
    else if([textId isEqualToString:@"ti_3"])
    {
        return @"去评价";
    }
    else if([textId isEqualToString:@"ti_4"])
    {
        return @"意见反馈";
    }
    else if([textId isEqualToString:@"ti_5"])
    {
        return @"缓存已成功清除";
    }
    else if([textId isEqualToString:@"ti_6"])
    {
        return @"下拉可以刷新了";
    }
    else if([textId isEqualToString:@"ti_7"])
    {
        return @"松开马上刷新了";
    }
    else if([textId isEqualToString:@"ti_8"])
    {
        return @"正在帮你刷新中...";
    }
    else if([textId isEqualToString:@"ti_9"])
    {
        return @"上拉可以加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_10"])
    {
        return @"松开马上加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_11"])
    {
        return @"正在帮你加载中...";
    }
    
    return @"";
}

+ (NSArray*)getOtherApps
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        if([RCTool isOpenAll])
        {
            return [app_info objectForKey:@"other_apps"];
        }
    }
    
    return nil;
}

+ (NSDictionary*)getAlert
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        if([RCTool isOpenAll])
        {
            NSDictionary* dict = [app_info objectForKey:@"alert"];
            if(dict && [dict isKindOfClass:[NSDictionary class]])
                return dict;
        }
    }
    
    return nil;
}

+ (NSString*)getUrlByType:(int)type
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* info = [app_info objectForKey:[NSString stringWithFormat:@"url_info_%d",type]];
        if(info && [info isKindOfClass:[NSDictionary class]])
        {
            return [info objectForKey:@"url"];
        }
    }
    
    if(0 == type)
    {
        return URL_0;
    }
    else if(1 == type)
    {
        return URL_1;
    }
    else if(2 == type)
    {
        return URL_2;
    }
    else if(3 == type)
    {
        return URL_3;
    }
    
    return @"";
}

+ (BOOL)isEncrypted:(int)type
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* info = [app_info objectForKey:[NSString stringWithFormat:@"url_info_%d",type]];
        if(info && [info isKindOfClass:[NSDictionary class]])
        {
            return [[info objectForKey:@"isen"] isEqualToString:@"1"];
        }
    }

    return YES;
}


@end

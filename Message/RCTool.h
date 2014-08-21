//
//  RCTool.h
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCTool : NSObject {

}

+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (UIWindow*)frontWindow;
+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*)colorWithHex:(NSInteger)hexValue;
+ (NSDictionary*)parseToDictionary:(NSString*)jsonString;
+ (void)showIndicator:(NSString*)text;
+ (void)hideIndicator;
+ (UITabBarController*)getTabBarController;
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize;

#pragma mark - network

+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

#pragma mark - 文件操作
+ (BOOL)saveImage:(NSData*)data path:(NSString*)path;
+ (NSString*)getImageLocalPath:(NSString *)path;
+ (UIImage*)getImageFromLocal:(NSString*)path;
+ (BOOL)isExistingFile:(NSString*)path;
+ (BOOL)removeFile:(NSString*)filePath;

#pragma mark - 兼容iOS6和iPhone5
+ (CGSize)getScreenSize;
+ (CGRect)getScreenRect;
+ (BOOL)isIphone5;
+ (BOOL)isIpad;
+ (CGFloat)systemVersion;

#pragma mark - CoreData

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (void)saveCoreData;

#pragma mark - App Info

+ (NSString*)getAdId;
+ (NSString*)getScreenAdId;
+ (int)getScreenAdRate;
+ (NSString*)getAppURL;
+ (BOOL)isOpenAll;
+ (UIView*)getAdView;
+ (NSString*)decrypt:(NSString*)text;
+ (NSString*)getTextById:(NSString*)textId;
+ (NSArray*)getOtherApps;
+ (NSDictionary*)getAlert;

@end

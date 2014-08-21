//
//  RCAppDelegate.m
//  Message
//
//  Created by xuzepei on 8/5/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCAppDelegate.h"
#import "UMSocial.h"
#import "MobClick.h"
#import "RCHttpRequest.h"
#import "BPush.h"

#define APP_ALERT 111

@implementation RCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if([RCTool systemVersion] >= 7.0)
    {
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
        
        //[[UITabBar appearance] setTintColor:[UIColor redColor]];
        [[UITabBar appearance] setBarTintColor:[RCTool colorWithHex:0x40cbf7]];
        //[[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setBarTintColor:[RCTool colorWithHex:0x48939e]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:30]}];
        
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    }
    
    [UMSocialData setAppKey:UMENG_KEY];
    
    //UMeng 统计
    [MobClick startWithAppkey:UMENG_KEY
                 reportPolicy:SEND_INTERVAL
                    channelId:nil];
    
    //推送设置
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
	[app registerForRemoteNotificationTypes:
	 (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    UIStoryboard* iPhoneStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    if(iPhoneStoryBoard)
    {
        self.window.rootViewController = [iPhoneStoryBoard instantiateInitialViewController];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //推送设置
    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
    
    self.showFullScreenAd = YES;
    [self getAppInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self saveContext];
}

#pragma mark - CoreData

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Message" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Message.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - AdMob

- (void)getAppInfo
{
    NSString* urlString = APP_INFO_URL;
    
    RCHttpRequest* temp = [RCHttpRequest sharedInstance];
    [temp request:urlString delegate:self resultSelector:@selector(finishedGetAppInfoRequest:) token:nil];
}

- (void)finishedGetAppInfoRequest:(NSString*)jsonString
{
    if(0 == [jsonString length])
    {
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
        
        return;
    }
    
    NSDictionary* result = [RCTool parseToDictionary:[RCTool decrypt:jsonString]];
    if(result && [result isKindOfClass:[NSDictionary class]])
    {
        //保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"app_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self doAlert];
        
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
    }
    
}

- (void)initAdMob
{
    if(_adMobAd && _adMobAd.alpha == 0.0 && nil == _adMobAd.superview)
	{
		[_adMobAd removeFromSuperview];
		_adMobAd.delegate = nil;
		_adMobAd = nil;
	}
    
	if(NO == [RCTool isIpad])
	{
		_adMobAd = [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,0,
                                             320.0f,
                                             50.0f)];
	}
	else
	{
        _adMobAd = [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,0,
                                             728.0f,
                                             90.0f)];
	}
    
	
	
	
	_adMobAd.adUnitID = [RCTool getAdId];
	_adMobAd.delegate = self;
	_adMobAd.alpha = 0.0;
	_adMobAd.rootViewController = [RCTool getTabBarController];
	[_adMobAd loadRequest:[GADRequest request]];
	
}

- (void)getAD
{
	NSLog(@"getAD");
    
    if(self.adMobAd && self.adMobAd.superview)
    {
        [self.adMobAd removeFromSuperview];
        self.adMobAd = nil;
    }
    
    if(self.adView && self.adView.superview)
    {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    self.adInterstitial = nil;
    self.interstitial = nil;
	
	[self initAdMob];
    
    [self getAdInterstitial];
}

#pragma mark -
#pragma mark GADBannerDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
	NSLog(@"adViewDidReceiveAd");
	
    if(nil == _adMobAd.superview && _adMobAd.alpha == 0.0)
    {
        _adMobAd.alpha = 1.0;
        CGRect rect = _adMobAd.frame;
        rect.origin.x = ([RCTool getScreenSize].width - rect.size.width)/2.0;
        rect.origin.y = [RCTool getScreenSize].height - _adMobAd.bounds.size.height - 100;
        _adMobAd.frame = rect;
        
        self.isAdMobVisible = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_ADBANNER_NOTIFICATION object:nil userInfo:nil];
    
    //[[RCTool getTabBarController].view addSubview:_adMobAd];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
	NSLog(@"didFailToReceiveAdWithError");
    
    self.isAdMobVisible = NO;
    
    [self performSelector:@selector(initAdMob) withObject:nil afterDelay:10];
}

- (void)getAdInterstitial
{
    if(nil == _adInterstitial)
    {
        _adInterstitial = [[GADInterstitial alloc] init];
        _adInterstitial.adUnitID = [RCTool getScreenAdId];
        _adInterstitial.delegate = self;
    }
    
    [_adInterstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd");
    
    if(self.showFullScreenAd)
    {
        self.showFullScreenAd = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FULLSCREENAD_NOTIFICATION object:nil userInfo:nil];
    }
    
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    [self performSelector:@selector(getAdInterstitial) withObject:nil afterDelay:10];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    _adInterstitial = nil;
    [self getAdInterstitial];
}

- (void)showInterstitialAd:(UIViewController*)rootViewController
{
    if(_adInterstitial)
    {
        [_adInterstitial presentFromRootViewController:rootViewController];
    }
    else if(self.interstitial && self.interstitial.loaded)
    {
        [self.interstitial presentFromViewController:rootViewController];
    }
}

#pragma mark - Push Notification

- (void)sendProviderDeviceToken:(NSData*)devToken
{
	if(nil == devToken)
		return;
    
    NSString* temp = [devToken description];
	NSString* token = [temp stringByTrimmingCharactersInSet:
					   [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	NSLog(@"token:%@",token);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    //[self sendProviderDeviceToken: devToken];
    
    [BPush registerDeviceToken:devToken];
    [BPush bindChannel];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"%@",[userInfo valueForKeyPath:@"aps.alert"]);
	
	UIApplication* app = [UIApplication sharedApplication];
	if(app.applicationIconBadgeNumber)
		app.applicationIconBadgeNumber = 0;
	else
	{
		NSString* message = [userInfo valueForKeyPath:@"aps.alert"];
		if([message length])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"搞笑萌妹纸"
															message: message delegate: self
												  cancelButtonTitle: @"确定"
												  otherButtonTitles: nil];
			[alert show];
		}
	}
}


#pragma mark - App Info

- (void)doAlert
{
    NSDictionary* alert = [RCTool getAlert];
    if(alert)
    {
        int type = [[alert objectForKey:@"type"] intValue];
        NSString* title = [alert objectForKey:@"title"];
        NSString* message = [alert objectForKey:@"message"];
        
        NSString* b0_name = @"Cancel";
        b0_name = [alert objectForKey:@"b0_name"];
        
        NSString* b1_name = @"OK";
        b1_name = [alert objectForKey:@"b1_name"];
        
        if(0 == type)
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
        else
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:b1_name,nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(APP_ALERT == alertView.tag)
    {
        NSLog(@"%d",buttonIndex);
        
        NSDictionary* alert = [RCTool getAlert];
        if(alert)
        {
            int type = [[alert objectForKey:@"type"] intValue];
            if(0 == type || (1 == type && 1 == buttonIndex))
            {
                NSString* urlString = [alert objectForKey:@"url"];
                if([urlString length])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
        }
    }
}

@end

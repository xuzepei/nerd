//
//  Item.h
//  Nerd
//
//  Created by xuzepei on 8/18/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * cateid;
@property (nonatomic, retain) NSString * viewcount;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * imgurl;
@property (nonatomic, retain) NSNumber * isHidden;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * videourl;
@property (nonatomic, retain) NSString* sharecount;
@property (nonatomic, retain) NSString* youkuid;
@property (nonatomic, retain) NSString* youkuweburl;
@property (nonatomic, retain) NSString* commentscount;
@property (nonatomic, retain) NSString* collectcount;

@end

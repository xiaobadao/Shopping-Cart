//
//  Item+CoreDataProperties.h
//  购物车
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 小霸道. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

@class LocationAtHome;
@class LocationAtShop;

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *collected;
@property (nullable, nonatomic, retain) NSNumber *listed;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) Unit *unit;
@property (nullable, nonatomic, retain) LocationAtHome *locationAtHome;
@property (nullable, nonatomic, retain) LocationAtShop *locationAtShop;

@end

NS_ASSUME_NONNULL_END

//
//  Location+CoreDataProperties.h
//  购物车
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 小霸道. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *summary;

@end

NS_ASSUME_NONNULL_END

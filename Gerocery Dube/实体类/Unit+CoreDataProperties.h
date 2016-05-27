//
//  Unit+CoreDataProperties.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Unit.h"

NS_ASSUME_NONNULL_BEGIN

@interface Unit (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Item *> *items;

@end

@interface Unit (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet<Item *> *)values;
- (void)removeItems:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END

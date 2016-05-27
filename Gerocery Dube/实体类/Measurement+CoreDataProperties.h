//
//  Measurement+CoreDataProperties.h
//  Gerocery Dube
//
//  Created by lanmao on 15/12/29.
//  Copyright © 2015年 Tim Roadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Measurement.h"

NS_ASSUME_NONNULL_BEGIN

@interface Measurement (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *collected;
@property (nullable, nonatomic, retain) NSNumber *listed;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSString *abc;

@end

NS_ASSUME_NONNULL_END

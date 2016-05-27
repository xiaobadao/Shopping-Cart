//
//  CoreDataHelper.h
//  Gerocery Dube
//
//  Created by lanmao on 15/12/28.
//  Copyright © 2015年 Tim Roadley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationVC.h"

@interface CoreDataHelper : NSObject<UIAlertViewDelegate,NSXMLParserDelegate>

@property (nonatomic,strong)UIAlertView                     *importAlertView;

@property (nonatomic,strong)MigrationVC                     *migrationVC;

@property (nonatomic,readonly)NSManagedObjectContext        *importContext;

@property (nonatomic,readonly)NSManagedObjectContext        *context;
@property (nonatomic,readonly)NSManagedObjectModel          *model;
@property (nonatomic,readonly)NSPersistentStoreCoordinator  *coordinator;
@property (nonatomic,readonly)NSPersistentStore             *store;
/**
 *  创建源数据所用的CoreData栈
 */
@property (nonatomic,readonly)NSManagedObjectContext        *sourceContext;
@property (nonatomic,readonly)NSPersistentStoreCoordinator  *sourceCoordinator;
@property (nonatomic,readonly)NSPersistentStore             *sourceStore;


@property (nonatomic,strong)NSXMLParser                     *parser;

-(void)setupCoreData;
-(void)saveContext;

@end

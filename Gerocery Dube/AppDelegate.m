//
//  AppDelegate.m
//  购物车
//
//  Created by lanmao on 15/12/28.
//  Copyright © 2015年 小霸道. All rights reserved.
//
#import "AppDelegate.h"
#import "Item.h"
#import "Measurement.h"
#import "Amount.h"
#import "Unit.h"
#import "LocationAtShop.h"
#import "LocationAtHome.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

//协助调试工作而设定 =1 dubug logging 调试日志记录功能就会开启
#define debug 1

-(void)showUnitAndItemCount
{
    //数据库里有多少items
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError *error = nil;
    
    NSArray *fetchedItems = [_coreDataHelper.context executeFetchRequest:fetch error:&error];
    if (!fetchedItems) {
        NSLog(@"%@",error);
    }else
    {
        NSLog(@"Found :%lu items:",(unsigned long)[fetchedItems count]);
    }
    //有多少个Unit
    NSFetchRequest *units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError *unitsError = nil;
    
    NSArray *fetchedUnits = [_coreDataHelper.context executeFetchRequest:units error:&unitsError];
    if (!fetchedUnits) {
        NSLog(@"%@",unitsError);
    }else
    {
        NSLog(@"Found :%lu units:",(unsigned long)[fetchedUnits count]);
    }

}
-(void)demo
{
//    CoreDataHelper *cdh = [self cdh];
//    NSArray *homeLocations = [NSArray arrayWithObjects:@"Fruit Bowl",@"Pantry",@"Nursery",@"Bathroom",@"Fridge", nil];
//    
//    NSArray *shopLocations = [NSArray arrayWithObjects:@"Produce",@"Aisle 1",@"Aisle 2",@"Aisle 3",@"Deli", nil];
//    
//    NSArray *unitNames = [NSArray arrayWithObjects:@"g",@"pkt",@"box",@"ml",@"kg", nil];
//    
//    NSArray *itemNames = [NSArray arrayWithObjects:@"Grapes",@"Biscuits",@"Nappies",@"Shampoo",@"Sausages", nil];
//    
//    int i = 0;
//
//    for (NSString *itemName in itemNames) {
//        
//        LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
//        
//        LocationAtShop *locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
//        
//        Unit *unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
//        
//        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
//        locationAtHome.storeIn = [homeLocations objectAtIndex:i];
//        locationAtShop.aisle = [shopLocations objectAtIndex:i];
//     
//        unit.name = unitNames[i];
//        item.name = itemNames[i];
//        
//        item.locationAtHome = locationAtHome;
//        item.locationAtShop = locationAtShop;
//        
//        item.unit = unit;
//        
//        i++;
//    }
//    [cdh saveContext];
}

/**
 *  获取CoreDataHelper 类型对象
 *
 *  @return 
 */
-(CoreDataHelper *)cdh
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}
//进入后台 或程序终止时候上下文中的数据能够保存
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[self cdh] saveContext];
}
//进入后台 或程序终止时候上下文中的数据能够保存
- (void)applicationWillTerminate:(UIApplication *)application {
    [[self cdh] saveContext];
 
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self cdh];
    [self demo];
}



@end

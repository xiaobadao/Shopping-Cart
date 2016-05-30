//
//  AppDelegate.h
//  购物车
//
//  Created by lanmao on 15/12/28.
//  Copyright © 2015年 小霸道. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic,readonly) CoreDataHelper *coreDataHelper;

-(CoreDataHelper *)cdh;

@end


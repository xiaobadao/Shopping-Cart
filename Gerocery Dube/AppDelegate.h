//
//  AppDelegate.h
//  Gerocery Dube
//
//  Created by lanmao on 15/12/28.
//  Copyright © 2015年 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic,readonly) CoreDataHelper *coreDataHelper;

-(CoreDataHelper *)cdh;

@end


//
//  LocationAtShopVC.h
//  购物车
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface LocationAtShopVC : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong)NSManagedObjectID *selectedObjectID;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@end

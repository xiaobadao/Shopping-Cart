//
//  UnitVC.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface UnitVC : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong)NSManagedObjectID *selectedObjectID;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@end

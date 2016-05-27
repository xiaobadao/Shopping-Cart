//
//  ItemTVC.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/6.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "UnitPickerTF.h"
#import "LocationAtShopPickerTF.h"
#import "LocationAtHomePickerTF.h"

@interface ItemTVC : UIViewController<UITextFieldDelegate,CoreDataPickerTFDelegate>

@property(nonatomic,strong)NSManagedObjectID *selectedItemID;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;

@property (strong, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;
@property (strong, nonatomic) IBOutlet LocationAtHomePickerTF *homeLocationPickerTextField;

@property (strong, nonatomic) IBOutlet LocationAtShopPickerTF *shopLocationTextField;
@property (strong, nonatomic) IBOutlet UITextField *activeTextField;
@end

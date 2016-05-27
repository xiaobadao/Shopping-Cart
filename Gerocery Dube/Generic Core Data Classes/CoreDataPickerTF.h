//
//  CoreDataPickerTF.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@class CoreDataPickerTF;
@protocol CoreDataPickerTFDelegate <NSObject>

-(void)selectedObjectID:(NSManagedObjectID *)objectID changedForPickerTF:(CoreDataPickerTF *)pickerTF;
@optional
-(void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF;

@end
@interface CoreDataPickerTF : UITextField<UIKeyInput,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,weak)id<CoreDataPickerTFDelegate> pickerDelegate;
@property (nonatomic,strong)UIPickerView *picker;
@property (nonatomic,strong)NSArray *pickerData;
@property (nonatomic,strong)UIToolbar *toolbar;
@property(nonatomic)BOOL showToolbar;
@property (nonatomic,strong)NSManagedObjectID *selectesObjectID;

@end

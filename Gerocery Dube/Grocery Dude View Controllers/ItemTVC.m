//
//  ItemTVC.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/6.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "ItemTVC.h"
#import "AppDelegate.h"
#import "Item.h"
#import "LocationAtHome.h"
#import "LocationAtShop.h"
#import "Unit.h"

@interface ItemTVC ()

@end

@implementation ItemTVC

#pragma mark -- VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    DTLOG;
    [self hideKeyboardWhenBackgroundIsTapped];
    
    self.nameTextField.delegate     = self;
    self.quantityTextField.delegate = self;
    
    self.unitPickerTextField.delegate = self;
    self.unitPickerTextField.pickerDelegate = self;
    self.homeLocationPickerTextField.delegate = self;
    self.homeLocationPickerTextField.pickerDelegate = self;
    self.shopLocationTextField.delegate =self;
    self.shopLocationTextField.pickerDelegate = self;
}
/**
 *  刷新数据
 */
-(void)refreshInterface
{
    DTLOG;
    if (self.selectedItemID) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate]cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        self.nameTextField.text = item.name;
        self.quantityTextField.text = item.quantity.stringValue;
        self.unitPickerTextField.text = item.unit.name;
        self.unitPickerTextField.selectesObjectID = item.unit.objectID;
        self.homeLocationPickerTextField.text = item.locationAtHome.storeIn;
        self.homeLocationPickerTextField.selectesObjectID = item.locationAtHome.objectID;
        self.shopLocationTextField.text = item.locationAtShop.aisle;
        self.shopLocationTextField.selectesObjectID = item.locationAtShop.objectID;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    DTLOG;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHiden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    [self refreshInterface];
    if ([self.nameTextField.text isEqualToString:@"New Item"]) {
        
        self.nameTextField.text = @"";
        [self.nameTextField becomeFirstResponder];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    //保存上下文
    [[(AppDelegate*)[[UIApplication sharedApplication]delegate] cdh] saveContext];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
#pragma mark -- INTERACTION
-(void)keyboardDidShow:(NSNotification *)n
{
//    查找键盘输入视图的顶部
    CGRect keyboardRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
//    调整scrollView
    CGRect newScrollViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, keyboardTop);
    newScrollViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    [self.scrollView setFrame:newScrollViewFrame];
    
//    滚动到活动文本字段
    [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
}
-(void)keyboardWillHiden:(NSNotification *)n
{
    CGRect defaultFrame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView setFrame:defaultFrame];
    //
    [self.scrollView scrollRectToVisible:self.nameTextField.frame animated:YES];
}
- (IBAction)done:(id)sender {
    DTLOG;
    [self hideKeyboard];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/**
 *  点击Done 隐藏键盘
 */
-(void)hideKeyboard
{
    DTLOG;
    [self.view endEditing:YES];
}
/**
 *  点击背景隐藏键盘
 */
-(void)hideKeyboardWhenBackgroundIsTapped
{
    DTLOG;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}
#pragma mark -- PICKERS
-(void)selectedObjectID:(NSManagedObjectID *)objectID changedForPickerTF:(CoreDataPickerTF *)pickerTF
{
    if (self.selectedItemID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate]cdh];
        
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        NSError *error = nil;
        if (pickerTF == self.unitPickerTextField) {
            
            Unit *unit = (Unit *)[cdh.context existingObjectWithID:objectID error:&error];
            item.unit = unit;
            self.unitPickerTextField.text = item.unit.name;
        }else if (pickerTF == self.homeLocationPickerTextField)
        {
            LocationAtHome *locationAtHome = (LocationAtHome *)[cdh.context existingObjectWithID:objectID error:&error];
            
            item.locationAtHome = locationAtHome;
            self.homeLocationPickerTextField.text = item.locationAtHome.storeIn;
        }else if (pickerTF == self.shopLocationTextField)
        {
            LocationAtShop *locationAtShop = (LocationAtShop *)[cdh.context existingObjectWithID:objectID error:&error];
            
            item.locationAtShop = locationAtShop;
            self.shopLocationTextField.text = item.locationAtShop.aisle;
        }
        [self refreshInterface];
        if (error) {
            NSLog(@"选择Picker Error:%@-%@",error,error.localizedDescription);
        }
    }
}
-(void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF
{
    if (self.selectedItemID) {
       
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate]cdh];
        
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        
        if (pickerTF == self.unitPickerTextField) {
            
            item.unit = nil;
            self.unitPickerTextField.text = @"";
        }else if (pickerTF == self.homeLocationPickerTextField)
        {
            item.locationAtHome = nil;
            self.homeLocationPickerTextField.text = @"";
        }else if (pickerTF == self.shopLocationTextField)
        {
            item.locationAtShop = nil;
            self.shopLocationTextField.text = @"";
        }
        [self refreshInterface];
    }
}
#pragma mark -- DELEGATE :UITextfield
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    DTLOG;
    if (textField == self.nameTextField) {
        
        if ([self.nameTextField.text isEqualToString:@"New Item"]) {
            self.nameTextField.text = @"";
        }
    }
    
    if (textField == self.unitPickerTextField && self.unitPickerTextField.picker) {
        
        [self.unitPickerTextField fetch];
        [self.unitPickerTextField.picker reloadAllComponents];
    }else if (textField == self.homeLocationPickerTextField && self.homeLocationPickerTextField.picker)
    {
        [self.homeLocationPickerTextField fetch];
        [self.homeLocationPickerTextField.picker reloadAllComponents];
    }else if (textField == self.shopLocationTextField && self.shopLocationTextField.picker)
    {
        [self.shopLocationTextField fetch];
        [self.shopLocationTextField.picker reloadAllComponents];
    }
    _activeTextField = textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate ]cdh];
    Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
    
    if (textField == self.nameTextField) {
        
        if ([self.nameTextField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        
        item.name = self.nameTextField.text;
        
    }else if (textField ==self.quantityTextField)
    {
        item.quantity = [NSNumber numberWithFloat:self.quantityTextField.text.floatValue];
    }
//    _activeTextField = nil;
}
#pragma mark -- DATA
/**
 *  家里是否有item 的摆放位置
 */
-(void)ensureItemHomeLocationIsNotNull
{
    DTLOG;
    if (self.selectedItemID) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (!item.locationAtHome) {
            
            NSFetchRequest *request = [[cdh model] fetchRequestTemplateForName:@"UnknownLocationAtHome"];
           NSArray * fetchedObjects= [cdh.context executeFetchRequest:request  error:nil];
            if (fetchedObjects.count > 0) {
                
                item.locationAtHome = [fetchedObjects objectAtIndex:0];
            }else
            {
                LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:locationAtHome] error:&error]) {
                    
                    NSLog(@"没有包含永久标识：%@",error);
                }
                locationAtHome.storeIn = @"..UnkownLocationAtHome..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}
/**
 *  购物车里是否有item 的摆放位置
 */
-(void)ensureItemShopLocationIsNotNull
{
    DTLOG;
    if (self.selectedItemID) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        Item *item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (!item.locationAtShop) {
            
            NSFetchRequest *request = [[cdh model] fetchRequestTemplateForName:@"UnknownLocationAtShop"];
            NSArray *fetchObjects = [cdh.context executeFetchRequest:request error:nil];
            if (fetchObjects.count > 0) {
                
                item.locationAtShop = [fetchObjects objectAtIndex:0];
            }else
            {
                LocationAtShop *locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
                NSError *error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:locationAtShop] error:&error]) {
                    
                    NSLog(@"没有包含永久标识：%@",error);
                }
                locationAtShop.aisle = @"..UnkownLocationAtShop..";
                item.locationAtShop = locationAtShop;
            }
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

//
//  CoreDataPickerTF.m
//  购物车
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "CoreDataPickerTF.h"

@implementation CoreDataPickerTF

#pragma mark--DELEGATE +DATASOURCE:UIPickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerData count];
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0f;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280.0f;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerData.count > 0) {
        NSManagedObject *object = [self.pickerData objectAtIndex:row];
        [self.pickerDelegate selectedObjectID:object.objectID changedForPickerTF:self];
    }else{}
}
#pragma mark -- INTERACTION
-(void)done
{
    [self resignFirstResponder];
}
-(void)clear
{
    [self.pickerDelegate selectedObjectClearedForPickerTF:self];
    [self resignFirstResponder];
}
#pragma mark -- DATA
-(void)fetch
{
    [NSException raise:NSInternalInconsistencyException format:@"你必须重写 %@ 方法来为Picker提供数据",NSStringFromSelector(_cmd)];
}
-(void)selectDefaultRow
{
    [NSException raise:NSInternalInconsistencyException format:@"你必须重写 %@ 方法来设置Picker的Row",NSStringFromSelector(_cmd)];
}
#pragma mark -- VIEW
-(UIView *)creatInputView
{
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.showsSelectionIndicator = YES;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self fetch];
    return self.picker;
}
-(UIView *)creatInputAccessoryView
{
    self.showToolbar = YES;
    if (!self.toolbar && self.showToolbar) {
        
        self.toolbar = [[UIToolbar alloc] init];
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.toolbar sizeToFit];
        CGRect frame = self.toolbar.frame;
        frame.size.height = 44.0f;
        self.toolbar.frame = frame;
        
        UIBarButtonItem *clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
        
        NSArray *array = [NSArray arrayWithObjects:clearBtn,spacer,doneBtn, nil];
        [self.toolbar setItems:array];
    }
    return self.toolbar;
}
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.inputView = [self creatInputView];
        self.inputAccessoryView = [self creatInputAccessoryView];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.inputAccessoryView = [self creatInputAccessoryView];
        self.inputView = [self creatInputView];
        
    }
    return self;
}
-(void)deviceDidRotate:(NSNotification *)notification
{
    [self.picker setNeedsLayout];
}
@end

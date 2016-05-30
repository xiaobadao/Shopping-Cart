//
//  LocationAtShopVC.m
//  购物车
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "LocationAtShopVC.h"
#import "AppDelegate.h"
#import "LocationAtShop.h"

@interface LocationAtShopVC ()

@end

@implementation LocationAtShopVC


#pragma mark -- VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
}
-(void)hideKeyboardWhenBackgroundIsTapped
{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}
-(void)hideKeyboard
{
    
    [self.view endEditing:YES];
}
-(void)refreshInterface
{
    
    if (self.selectedObjectID) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        LocationAtShop *locationAtShop = (LocationAtShop *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        self.nameTextField.text = locationAtShop.aisle;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self refreshInterface];
    [self.nameTextField becomeFirstResponder];
}

#pragma mark -- TEXTFILED
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate]cdh];
    LocationAtShop *locationAtShop = (LocationAtShop *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
    
    if (self.nameTextField == textField) {
        
        locationAtShop.aisle = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SomethingChanged" object:nil];
    }
}
#pragma mark -- INTERACTION
-(IBAction)done:(id)sender
{
    [self hideKeyboard];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  LocationAtHomePickerTF.m
//  购物车
//
//  Created by lanmao on 16/1/8.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "LocationAtHomePickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtHome.h"

@implementation LocationAtHomePickerTF

#pragma mark -- DATA
-(void)fetch
{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"storeIn" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setFetchBatchSize:50];
    
    NSError *error =nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"error %@",error);
    }
    [self selectDefaultRow];
}
-(void)selectDefaultRow
{
    if (self.selectesObjectID && [self.pickerData count] > 0) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        LocationAtHome *selectedObject = [cdh.context existingObjectWithID:self.selectesObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtHome *locationAtHome, NSUInteger idx, BOOL * _Nonnull stop) {
           
            if ([locationAtHome.storeIn compare:selectedObject.storeIn] == NSOrderedSame) {
                
                [self.picker selectRow:idx inComponent:0 animated:YES];
                [self.pickerDelegate selectedObjectID:self.selectesObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LocationAtHome *locationAtHome = [self.pickerData objectAtIndex:row];
    return locationAtHome.storeIn;
}

@end

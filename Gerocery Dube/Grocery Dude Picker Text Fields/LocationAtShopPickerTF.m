//
//  LocationAtShopPickerTF.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/8.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "LocationAtShopPickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtShop.h"

@implementation LocationAtShopPickerTF

#pragma mark -- DATA
-(void)fetch
{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES];
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
        LocationAtShop *locationAtShop = [cdh.context existingObjectWithID:self.selectesObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([locationAtShop.aisle compare:((LocationAtShop *)obj).aisle] == NSOrderedSame) {
                
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectesObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LocationAtShop *locationAtShop = [self.pickerData objectAtIndex:row];
    return locationAtShop.aisle;
}

@end

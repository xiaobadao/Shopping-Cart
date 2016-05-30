//
//  UnitPickerTF.m
//  购物车
//
//  Created by lanmao on 16/1/8.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "UnitPickerTF.h"
#import "Unit.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"


@implementation UnitPickerTF

#pragma mark -- DATA
-(void)fetch
{
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
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
        Unit *unit = [cdh.context existingObjectWithID:self.selectesObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            if ([unit.name compare:obj] == NSOrderedSame) {
                
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectesObjectID changedForPickerTF:self];
               *stop = YES;
                
            }
        }];
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Unit *unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

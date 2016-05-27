//
//  ShopTVC.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/6.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "ShopTVC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Item.h"
#import "Unit.h"
#import "ItemTVC.h"

@interface ShopTVC ()

@end

@implementation ShopTVC
#pragma mark --VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    DTLOG;
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    static NSString *cellIdentifier = @"Shop Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.frc objectAtIndexPath:indexPath];
    
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@" " options:0 range:NSMakeRange(0, [title length])];
    
    cell.textLabel.text = title;
    
    if (item.collected.boolValue) {
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvatica Neue" size:16]];
        [cell.textLabel setTextColor:[UIColor blueColor]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
    {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvatica Neue" size:18]];
        [cell.textLabel setTextColor:[UIColor orangeColor]];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    return cell;
}
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    DTLOG;
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    Item *item = [self.frc objectAtIndexPath:indexPath];
    if (item.collected.boolValue) {
        
        item.collected = [NSNumber numberWithBool:NO];
    }else
    {
        item.collected = [NSNumber numberWithBool:YES];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}
#pragma mark -- DATA
-(void)configureFetch
{
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [[cdh.model fetchRequestTemplateForName:@"ShoppingList"] copy];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"locationAtShop.aisle" ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    [request setFetchBatchSize:50];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtShop.aisle" cacheName:nil];
    
    self.frc.delegate = self;
}


#pragma mark --INTERACTION
-(IBAction)clear:(id)sender
{
    DTLOG;
    if (self.frc.fetchedObjects.count == 0) {
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"没东西清除" message:@"Add items using the Prepare tab" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    BOOL nothingCleared = YES;
    
    for (Item *item in self.frc.fetchedObjects) {
        
        if (item.collected.boolValue) {
            
            item.listed = [NSNumber numberWithBool:NO];
            item.collected = [NSNumber numberWithBool:NO];
            nothingCleared = NO;
        }else
        {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除" message:@"将项目从列表清除" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

        }
    }

}
#pragma mark -- SEGUE

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    ItemTVC *itemTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemTVC"];
    itemTVC.selectedItemID = [[self.frc objectAtIndexPath:indexPath] objectID];
    [self.navigationController pushViewController:itemTVC animated:YES];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

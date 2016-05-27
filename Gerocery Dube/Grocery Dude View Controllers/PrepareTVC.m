//
//  PrepareTVC.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "PrepareTVC.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "Unit.h"
#import "AppDelegate.h"
#import "ItemTVC.h"


@interface PrepareTVC ()

@end

@implementation PrepareTVC

#pragma mark --VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    DTLOG;
    [self configureFetch];
    [self performFetch];
    self.clearConfirmActionSheet.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    static NSString *cellIdentifier = @"Item Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    Item *item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString *title = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@" " options:0 range:NSMakeRange(0, [title length])];
    
    cell.textLabel.text = title;

    //选中橘子清单
    if ([item.listed boolValue]) {
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
        [cell.textLabel setTextColor:[UIColor orangeColor]];
    }else
    {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
    }
    return cell;
}
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    DTLOG;
    return nil;
}
#pragma mark --DATA 
-(void)configureFetch
{
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.sortDescriptors = [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storeIn" ascending:YES],
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    [request setFetchLimit:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtHome.storeIn" cacheName:nil];
    self.frc.delegate = self;
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Item *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    NSManagedObjectID *itemid = [[self.frc objectAtIndexPath:indexPath] objectID];
    Item *item = [self.frc.managedObjectContext existingObjectWithID:itemid error:nil];
    
    if ([item.listed boolValue]) {
        
        item.listed = [NSNumber numberWithBool:NO];
    }else
    {
        item.listed =[NSNumber numberWithBool:YES];
        item.collected = [NSNumber numberWithBool:NO];
        
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}
#pragma mark --INTERACTION
- (IBAction)clear:(id)sender {
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList = [cdh.context executeFetchRequest:request error:nil];
    if (shoppingList.count > 0) {
       
        self.clearConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"删除购物列表中的实体？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清除" otherButtonTitles: nil];
        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有东西要删除的" message:@"通过prepare tab 添加东西到shopping list，当点击clear shopping list 上的内容被删除" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    shoppingList = nil;
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.clearConfirmActionSheet) {
        
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            
            [self performSelector:@selector(clearList)];
        }else if (buttonIndex == [actionSheet cancelButtonIndex])
        {
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
            
        }
    }
}
-(void)clearList
{
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppinglist = [cdh.context executeFetchRequest:request error:nil];
    for (Item *item in shoppinglist) {
        
        item.listed = [NSNumber numberWithBool:NO];
    }
}
#pragma mark -- SEGUE
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DTLOG;
    ItemTVC *itemTVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Item Segue"]) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
        NSError *error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:newItem] error:&error]) {
            
            NSLog(@"无法获得对象的永久标识: %@",error);
        }
        itemTVC.selectedItemID = newItem.objectID;
    }else
    {
        NSLog(@"身份不明的继续尝试!");
    }
    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    ItemTVC *itemTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemTVC"];
    itemTVC.selectedItemID = [[self.frc objectAtIndexPath:indexPath] objectID];
    [self.navigationController pushViewController:itemTVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

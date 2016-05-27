//
//  UnitstVC.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "UnitstVC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit.h"
#import "UnitVC.h"

@interface UnitstVC ()

@end

@implementation UnitstVC

#pragma mark -- VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    static NSString *indentifierCellID = @"Unit Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierCellID forIndexPath:indexPath];

    Unit *unit = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = unit.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTLOG;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Unit *unit = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:unit];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}
#pragma mark -- DATA
-(void)configureFetch
{
    DTLOG;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];

    [request setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    
    self.frc.delegate = self;
}
#pragma mark -- INTERACTION
-(IBAction)done:(id)sender
{
    DTLOG;
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    UnitVC *unitVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Object Segue"]) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        Unit *newUnit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
        NSError *error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:newUnit] error:&error]) {
            }
        unitVC.selectedObjectID = newUnit.objectID;
    }else if ([segue.identifier isEqualToString:@"Edit Object Segue"])
    {
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        unitVC.selectedObjectID = [[self.frc objectAtIndexPath:indexpath] objectID];
    }else
    {}
}


@end

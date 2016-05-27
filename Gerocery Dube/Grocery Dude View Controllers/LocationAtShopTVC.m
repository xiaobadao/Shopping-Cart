//
//  LocationAtShopTVC.m
//  Gerocery Dube
//
//  Created by lanmao on 16/1/7.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "LocationAtShopTVC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtShopVC.h"
#import "LocationAtShop.h"

@interface LocationAtShopTVC ()

@end

@implementation LocationAtShopTVC

#pragma mark -- VIEW
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    static NSString *indentifierCellID = @"LocationAtShop Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierCellID forIndexPath:indexPath];
    
    LocationAtShop *locationAtShop = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtShop.aisle;
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        LocationAtShop *locationAtShop = [self.frc objectAtIndexPath:indexPath];

        [self.frc.managedObjectContext deleteObject:locationAtShop];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}
#pragma mark -- DATA
-(void)configureFetch
{
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES], nil];
    
    [request setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    
    self.frc.delegate = self;
}
#pragma mark -- INTERACTION
-(IBAction)done:(id)sender
{
   
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    LocationAtShopVC *locationAtShopVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Object Segue"]) {
        
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        LocationAtShop *newlocationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
        NSError *error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:newlocationAtShop] error:&error]) {
        }
        locationAtShopVC.selectedObjectID = newlocationAtShop.objectID;
    }else if ([segue.identifier isEqualToString:@"Edit Object Segue"])
    {
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        locationAtShopVC.selectedObjectID = [[self.frc objectAtIndexPath:indexpath] objectID];
    }else
    {}
}
@end

//
//  CoreDataTVC.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface CoreDataTVC : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic,strong)NSFetchedResultsController *frc;
/**
 *  负责获取并刷新表格 ，当失败时还提供错误会报功能
 */
-(void)performFetch;

@end

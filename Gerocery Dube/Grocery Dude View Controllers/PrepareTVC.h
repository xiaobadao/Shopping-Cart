//
//  PrepareTVC.h
//  购物车
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "CoreDataTVC.h"

@interface PrepareTVC : CoreDataTVC<UIActionSheetDelegate>

@property (nonatomic,strong)UIActionSheet *clearConfirmActionSheet;

@end

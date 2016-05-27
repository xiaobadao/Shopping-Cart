//
//  PrepareTVC.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/5.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//

#import "CoreDataTVC.h"

@interface PrepareTVC : CoreDataTVC<UIActionSheetDelegate>

@property (nonatomic,strong)UIActionSheet *clearConfirmActionSheet;

@end

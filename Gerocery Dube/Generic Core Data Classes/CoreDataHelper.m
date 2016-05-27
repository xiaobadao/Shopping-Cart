//
//  CoreDataHelper.m
//  Gerocery Dube
//
//  Created by lanmao on 15/12/28.
//  Copyright © 2015年 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"
#import <objc/runtime.h>
#import "CoreDataImporter.h"

@implementation CoreDataHelper

//协助调试工作而设定 =1 dubug logging 调试日志记录功能就会开启
#define debug 1

#pragma mark - FILES
/**
 *  用于存储持久化存储区的文件名
 */
NSString *storeFilename = @"Grocery-Dube.sqlite";
/**
 *  源存储区文件
 */
NSString *sourceStoreFilename = @"DefaultData.sqlite";

#pragma mark - PATHS
//获取根目录
-(NSString *)applicationDocumentsDirectory
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
//获取根目录中的stores 路径
-(NSURL *)applicationStoresDirectory
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        
        NSError *error = nil;
        
        if ([fileManager createDirectoryAtPath:[storesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error]) {
            
            if (debug == 1) {
               NSLog(@"创建Stores文件夹成功");
            }
            else
            {
               NSLog(@"创建Stores文件夹失败: %@",error);
            }
        }
    }
    return storesDirectory;
}
//数据存储区的文件名添加到Stores目录的路径下
-(NSURL *)storeURL
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}
-(NSURL *)sourceStoreURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[sourceStoreFilename stringByDeletingPathExtension] ofType:[sourceStoreFilename pathExtension]]];
}
#pragma mark - SETUP
-(instancetype)init
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];//令上下文在主队列中进行
    [_context setPersistentStoreCoordinator:_coordinator];
    
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
       
        [_importContext setPersistentStoreCoordinator:_coordinator];
        [_importContext setUndoManager:nil];//减少导入上下文的资源需求。将其禁止.
    }];
    
    _sourceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _sourceContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_sourceContext performBlockAndWait:^{
       
        [_sourceContext setPersistentStoreCoordinator:_sourceCoordinator];
        [_sourceContext setUndoManager:nil];
    }];
    
    
    return self;
}
-(void)loadStore
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    
    BOOL useMigrationManager = NO;
    
    if (useMigrationManager &&[self isMigrationNecessaryForStore:[self storeURL]]) {
        
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }else
    {
      
//        NSDictionary *options =
//        @{
//          NSMigratePersistentStoresAutomaticallyOption:@YES,
//          NSInferMappingModelAutomaticallyOption:@YES,NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};
        
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
        if (!_store) {
            NSLog(@"未能添加存储store error:%@",error);
            abort();
        }
        else
        {
            if (debug == 1) {
                NSLog(@"成功添加存储 store%@",_store);
            }
        }
    }
}
/**
 *  加载源数据存储区 
 */
-(void)loadSourceStore
{
    if (_sourceStore) {
        return;
    }
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption:@YES,
                              };
    NSError *error = nil;
    
    _sourceStore = [_sourceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self sourceStoreURL] options:options error:&error];
    if (!_sourceStore) {
        
        NSLog(@"失败源数据存储");
    }else
    {
        NSLog(@"成功源数据存储");
    }
    
}

-(void)setupCoreData
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self setDefaultDataStoreAsInitialStore];
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];
}
#pragma mark - SAVING
-(void)saveContext
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changes to persistent store");
        }else
        {
            NSLog(@" failed to save _context : %@",_context);
            [self showValidationError:error];
        }
    }else
    {
         NSLog(@"SKIPPED _context save ,there are no changes ");
    }
}

#pragma mark -- MIGRATION MANAGER 
-(BOOL)isMigrationNecessaryForStore:(NSURL *)storeUrl
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION :Source database missing.");
        }
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl options:nil error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION :Source is already compatible .");
        }
        return NO;
    }
    return YES;
}
-(BOOL)migrationStore:(NSURL *)sourceStore
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
//  STEP 1 创建 元模型
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore options:nil error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
//    目标模型
    NSManagedObjectModel *destinModel =_model;
//    映射模型
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];

//STEP 2 执行迁移假设映射模型不为空
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success = [migrationManager migrateStoreFromURL:sourceStore type:   NSSQLiteStoreType options:nil
                     withMappingModel:mappingModel
                     toDestinationURL:destinStore
                     destinationType:NSSQLiteStoreType
                     destinationOptions:nil error:&error];
        if (success) {
//            STEP 3 用新的存储区取代旧的存储区。
            if ([self replaceStore:sourceStore withStore:destinStore]) {
               
                if (debug == 1) {
                    NSLog(@"SUCCESSFULL MIGRATED  %@ to the current Model ",sourceStore.path);
                }
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        }else
        {
            if (debug == 1) {
                NSLog(@"数据迁移失败 :%@",error);
            }
        }
    }else
    {
        if (debug == 1) {
            NSLog(@"数据迁移失败 :Mapping Model 为空");
        }
    }
    return YES;
}
-(BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    
    BOOL success = NO;
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            
            success = YES;
        }else
        {
            if (debug == 1) {
                NSLog(@"移到新区失败 ：%@",error);
            }
        }
        
    }else
    {
        if (debug == 1) {
            NSLog(@"移除旧区 ：%@ 失败 ：%@",old,error);
        }
    }
    return success;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress * 10;
            NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%",percentage];
            NSLog(@"%@",string);
            self.migrationVC.lable.text = string;
        });
    }
}
/**
 *  允许在后台通过 migrationManager 来迁移数据
 *
 *  @param storeURL
 */
-(void)performBackgroundManagedMigrationForStore:(NSURL *)storeURL
{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    //显示迁移的进度条给用户 在界面上
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController *)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:YES completion:nil];
    //在后台数据迁移。因此不能冻结 ui
    //这样的方式，进度才能被现实给用户
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        BOOL done = [self migrationStore:storeURL];
        if (done) {
            
            //当迁移完成。增加新的迁移存储区
            dispatch_async(dispatch_get_main_queue(), ^{
               
                NSError *error = nil;
                
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                if (!_store) {
                    
                    NSLog(@"添加迁移区失败:%@",error);
                    abort();
                }else
                {
                    NSLog(@"添加迁移区成功:%@",_store);
                    [self.migrationVC dismissViewControllerAnimated:YES completion:nil];
                    self.migrationVC = nil;
                }
            });
        }
    });
}
#pragma mark -- VALIDATION ERROR HANDLING
-(void)showValidationError:(NSError *)anError
{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        
        NSArray *errors = nil;//所有的错误
        NSString *text = @"";//错误提示信息
        
        //错误信息添加到数组中
        if (anError.code == NSValidationMultipleErrorsError) {
            
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }else
        {
            errors = [NSArray arrayWithObject:anError];
        }
        
        //陈列这些错误信息
        if (errors && errors.count > 0) {
            
            for (NSError *error  in errors) {
                
                NSString *entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                
                NSString *property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                        
                    case NSValidationRelationshipDeniedDeleteError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 删除被拒绝因为还在关联着：%@-%ld",entity,property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationRelationshipLacksMinimumCountError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 关联的数量太小：%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationRelationshipExceedsMaximumCountError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 关联的数量太大：%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationMissingMandatoryPropertyError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 属性丢失:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationNumberTooSmallError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 数量太小：%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationNumberTooLargeError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 数量太大:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationDateTooSoonError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 时间太快:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationDateTooLateError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 时间太迟:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationInvalidDateError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 时间是无效的:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationStringTooLongError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 信息太长:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationStringTooShortError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 信息太短:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSValidationStringPatternMatchingError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 信息不符合特殊的格式:%ld",property,(long)error.code];
                    }
                        break;
                        
                    case NSManagedObjectValidationError:
                    {
                        text = [text stringByAppendingFormat:@"%@ 生成验证错误:%ld",property,(long)error.code];
                    }
                        break;
                        
                    default:
                    {
                        text = [text stringByAppendingFormat:@"在当前方法里没有处理错误信息:%ld",(long)error.code];
                        
                    }
                        break;
                }
            }
            
            NSLog(@"%@===text===%@",self.class,text);
            // display error message txt message
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"Validation Error"
             
                                       message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards",text]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK",nil];
            [alertView show];
        }
    }
}
#pragma mark --DATA IMPORT
-(void)setDefaultDataStoreAsInitialStore
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:self.storeURL.path]) {
        NSURL *defaultURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DefaultData" ofType:@"sqlite"]];
        NSError *error ;
        if (![manager copyItemAtURL:defaultURL toURL:[self storeURL] error:&error]) {
            NSLog(@"神拷贝失败");
        }else
        {
            NSLog(@"神拷贝成功：%@",self.storeURL.path);
        }
    }
}
-(BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL *)url ofType:(NSString *)type
{
    
    NSError *error ;
    NSDictionary *dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:url options:nil error:&error];
    if (error) {
        
        NSLog(@"信息出错:%@",error.localizedDescription);
    }else
    {
        NSNumber *defaultDataImported = (NSNumber *)[dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataImported boolValue]) {
            return NO;
        }
    }
        return YES;
}
-(void)checkIfDefaultDataNeedsImporting
{
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL] ofType:NSSQLiteStoreType]) {
        
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            
//        }];
//        
//        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            
//        }];
//        
//        self.importAlertView = [UIAlertController alertControllerWithTitle:@"倒入默认数据" message:@"如果倒入默认数据会很快帮你理解这个应用，如果你在别的设备上做了这个事情那就不需要倒入了" preferredStyle:UIAlertControllerStyleAlert];
//
//        [self.importAlertView addAction:sureAction];
//        [self.importAlertView addAction:noAction];
//        
//      [self presentViewController:self.importAlertView animated:YES completion:nil];
        self.importAlertView = [[UIAlertView alloc] initWithTitle:@"需要导入数据？" message:@"如果倒入默认数据会很快帮你理解这个应用，如果你在别的设备上做了这个事情那就不需要倒入了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [self.importAlertView show];
    }
}
/**
 *   解析XML
 *
 *  @param url
 */
-(void)importFromXML:(NSURL *)url
{
    self.parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    self.parser.delegate = self;
    [self.parser parse];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SomethingChanged" object:nil];
    
}

//防止多次重复导入数据，需要设置 开关。
-(void)setDefaultDataAsImportedForStore:(NSPersistentStore *)aStore
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
}
//触发深拷贝
-(void)deepCopyFromPersistentStore:(NSURL *)url
{
    [_sourceContext performBlock:^{
       
        //开始神拷贝
        NSArray *entitiesToCopy = [NSArray arrayWithObjects:@"LocationAtShop",@"LocationAtHome",@"Unit",@"Item", nil];
        CoreDataImporter *importer =[[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
        [importer deepCopyEntity:entitiesToCopy fromContext:_sourceContext toContext:_importContext];
        
        [_context performBlock:^{
           
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
        }];
    }];
}
#pragma mark -- DELEGATE :NSXMLParser
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"DELEGATE :NSXMLParser %@",parseError.localizedDescription);
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    //  1.
    if ([elementName isEqualToString:@"item"]) {
        //2.
        CoreDataImporter *importer = [[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
        //3.a
        NSManagedObject *item = [importer insertBasicObjectInTargetEntity:@"Item" targetEntityAttributeValue:@"name" sourceXMLAttribute:@"name" attributeDict:attributeDict context:_importContext];
        //3.b
        NSManagedObject *unit = [importer insertBasicObjectInTargetEntity:@"Unit" targetEntityAttributeValue:@"name" sourceXMLAttribute:@"unit" attributeDict:attributeDict context:_importContext];
        //3.c
        NSManagedObject *locationAtHome = [importer insertBasicObjectInTargetEntity:@"LocationAtHome" targetEntityAttributeValue:@"storeIn" sourceXMLAttribute:@"locationathome" attributeDict:attributeDict context:_importContext];
        //3.d
        NSManagedObject *locationAtShop = [importer insertBasicObjectInTargetEntity:@"LocationAtShop" targetEntityAttributeValue:@"aisle" sourceXMLAttribute:@"locationatshop" attributeDict:attributeDict context:_importContext];
        //4.
        [item setValue:@NO forKey:@"listed"];
        
        //5. 创建关联关系
        [item setValue:unit forKey:@"unit"];
        [item setValue:locationAtHome forKey:@"locationAtHome"];
        [item setValue:locationAtShop forKey:@"locationAtShop"];
        //6.将新的对象保存到存储区
        [CoreDataImporter saveContext:_importContext];
        
        //7.把对象转换成默认数据，节省内存
        [_importContext refreshObject:unit mergeChanges:NO];
        [_importContext refreshObject:item mergeChanges:NO];
        [_importContext refreshObject:locationAtShop mergeChanges:NO];
        [_importContext refreshObject:locationAtHome mergeChanges:NO];
    }
}
#pragma mark --DELETE :AlertView 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.importAlertView) {
        
        if (buttonIndex == 1) {
            
//            [_importContext performBlockAndWait:^{
//                
//                [self importFromXML:[[NSBundle mainBundle] URLForResource:@"DefaultData" withExtension:@"xml"]];
//            }];

            [self loadSourceStore];
            [self deepCopyFromPersistentStore:[self sourceStoreURL]];
            
        }else
        {}
       [self setDefaultDataAsImportedForStore:_store];
    }
    
}
#pragma mark -- UIQUE ATTRIBUTE SELECTION 
-(NSDictionary *)selectedUniqueAttributes
{
    NSMutableArray *entities = [NSMutableArray array];
    NSMutableArray *attributes = [NSMutableArray array];
    [entities addObject:@"Item"]; [attributes addObject:@"name"];
    [entities addObject:@"Unit"]; [attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"]; [attributes addObject:@"storeIn"];
    [entities addObject:@"LocationAtShop"]; [attributes addObject:@"aisle"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
    return dictionary;
}
@end

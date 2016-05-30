//
//  CoreDataImporter.m
//  购物车
//
//  Created by lanmao on 16/1/13.
//  Copyright © 2016年 小霸道. All rights reserved.
//

#import "CoreDataImporter.h"

@implementation CoreDataImporter

+(void)saveContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
       
        if ([context hasChanges]) {
            
            NSError *error =nil;
            if ([context save:&error]) {
                NSLog(@"保存成功");
            }else
            {
                 NSLog(@"保存失败");
            }
            
        }else{ NSLog(@"没有需要保存的");}
    }];
}
-(CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes
{
    if (self = [super init]) {
        
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        
        if (self.entitiesWithUniqueAttributes) {
            return self;
        }else{
            return nil;
        }
    }
    return nil;
}
-(NSString *)uniqueAttributeForEntity:(NSString *)entity
{
    return [self.entitiesWithUniqueAttributes objectForKey:entity];
}
-(NSManagedObject *)existingObjectInContext:(NSManagedObjectContext *)context forEntity:(NSString *)entity withUniqueAttributeValue:(NSString *)uniqueAttributeValue
{
    NSString *uniqueAttribute = [self.entitiesWithUniqueAttributes objectForKey:entity];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@",uniqueAttribute,uniqueAttributeValue];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"查询实体出错");
    }
    if (objects.count > 0) {
        return [objects lastObject];
    }else
    {
        return nil;
    }
}
-(NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity uniqueAttributeValue:(NSString *)uniqueAttributeValue attributeValues:(NSDictionary *)attributesValues inContext:(NSManagedObjectContext *)context
{
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject *existingObject = [self existingObjectInContext:context forEntity:entity withUniqueAttributeValue:uniqueAttributeValue];
        if (existingObject) {
            return existingObject;
        }else
        {
            NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributesValues];
            return newObject;
        }
    }else
    {
        NSLog(@"uniqueAttributeValue.length为零");
    }
    return nil;
}
-(NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity targetEntityAttributeValue:(NSString *)targetEntityAttributeValue sourceXMLAttribute:(NSString *)sourceXMLAttribute attributeDict:(NSDictionary *)attributeDict context:(NSManagedObjectContext *)context
{
    NSArray *attributes = [NSArray arrayWithObject:targetEntityAttributeValue];
    NSArray *values = [NSArray arrayWithObject:[attributeDict objectForKey:sourceXMLAttribute]];
    NSDictionary *attributesValues = [NSDictionary dictionaryWithObjects:values forKeys:attributes];
    return [self insertUniqueObjectInTargetEntity:entity uniqueAttributeValue:[attributeDict objectForKey:sourceXMLAttribute] attributeValues:attributesValues inContext:context];
}
#pragma mark -- DEEP
/**
 *  通过托管对象返回包含实体 唯一属性 及唯一属性值的字符串
 *
 *  @param object
 *
 *  @return
 */
-(NSString *)objectInfo:(NSManagedObject *)object
{
    if (!object) {
        return nil;
    }
    
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniquewAttibuteValue = [object valueForKey:uniqueAttribute];
    
    return [NSString stringWithFormat:@"%@ '%@'",entity,uniquewAttibuteValue];
}
/**
 *  通过给定的实体 上下文 谓词 返回含有托管对象的数组
 *
 *  @param entity    实体
 *  @param context   上下文
 *  @param predicate 谓词
 *
 *  @return 托管对象的数组
 */
-(NSArray *)arrayWithEntity :(NSString *)entity inContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setPredicate:predicate];
    
    [request setFetchBatchSize:50];
    
    NSError *error ;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"信息错去");
    }
    return array;
}
//把对象拷贝到给定的上下文之中，确保每个对象只拷贝一次
-(NSManagedObject *)copyUniqueObject:(NSManagedObject *)object toContext:(NSManagedObjectContext *)targetContext
{
    if (!object || !targetContext) {
        
        NSLog(@"拷贝失败");
        return nil;
    }
    NSString *entity = object.entity.name;
    NSString *uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    if (uniqueAttributeValue.length >0) {
        
        NSMutableDictionary *attributeValuesToCopy = [NSMutableDictionary new];
        for (NSString *attribute in object.entity.attributesByName) {
            
            [attributeValuesToCopy setValue:[[object valueForKey:attribute] copy] forKey:attribute];
        }
        
        NSManagedObject *copiesObject = [self insertUniqueObjectInTargetEntity:entity uniqueAttributeValue:uniqueAttributeValue attributeValues:attributeValuesToCopy inContext:targetContext];
        return copiesObject;
    }
    return nil;
}
//建立一对一关系
-(void)establishToOneRelationship:(NSString *)relationshipName fromObject:(NSManagedObject *)object toObject:(NSManagedObject *)relatedObject
{
    if (!relationshipName || !object || !relatedObject) {
        return;
    }
    NSManagedObject *exitingRelationship = [object valueForKey:relationshipName];
    if (exitingRelationship) {
        return;
    }
    NSDictionary *relationships = [object.entity relationshipsByName];
    NSRelationshipDescription *relationship = [relationships objectForKey:relationshipName];
    
    if (![relationship.entity isEqual:relationship.destinationEntity ]) {
        
        return;
    }
    [object setValue:relatedObject forKey:relationshipName];
    
    //编辑到磁盘后 从内存中移除relationship
    [CoreDataImporter saveContext:relatedObject.managedObjectContext];
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    [relatedObject.managedObjectContext refreshObject:relatedObject mergeChanges:NO];
    
}
//建立一对多关系
-(void)establishToManyRelationship:(NSString *)relastionshipName fromObject:(NSManagedObject *)object withSourceSet:(NSMutableSet *)sourceSet
{
    if (!object || !relastionshipName || !sourceSet) {
        [self objectInfo:object];
        return;
    }
    
    
    NSMutableSet *copiesSet = [object mutableSetValueForKey:relastionshipName];
    
    for (NSManagedObject *relatedObject in sourceSet) {
        
        NSManagedObject *copiesRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiesRelatedObject) {
            
            [copiesSet addObject:copiesRelatedObject];
        }
    }
    
    //
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

//建立有序一对多关系
-(void)establishOrderedToManyRelationship:(NSString *)relastionshipName fromObject:(NSManagedObject *)object withSourceSet:(NSMutableOrderedSet *)sourceSet
{
    if (!object || !relastionshipName || !sourceSet) {
        return;
    }
    NSMutableOrderedSet *copiesSet = [object mutableOrderedSetValueForKey:  relastionshipName];
    for (NSManagedObject *relatedObject in sourceSet) {
        
        NSManagedObject *copiesRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiesRelatedObject) {
            
            [copiesSet addObject:copiesRelatedObject];
        }
    }
    
    //
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}
//拷贝关系
//把源上下文里某个对象的全部关系都拷贝到目标上下文里的等价对象中。
-(void)copiesRelationshipsFromObject:(NSManagedObject *)sourceObject toContext:(NSManagedObjectContext *)targetContext
{
    if (!sourceObject || !targetContext) {
        return;
    }
    
    NSManagedObject *copiesObject = [self copyUniqueObject:sourceObject toContext:targetContext];
    
    if (!copiesObject) {
        return;
    }
    //拷贝映射关系
    NSDictionary *relationships = [sourceObject.entity relationshipsByName];
    for (NSString *relatedshipName in relationships) {
        
        NSRelationshipDescription *relationship = [relationships objectForKey:relatedshipName];
        
        if ([sourceObject valueForKey:relatedshipName]) {
            
            if (relationship.isToMany && relationship.isOrdered) {
                
                //有序的拷贝一对多
                NSMutableOrderedSet *sourceSet = [sourceObject mutableOrderedSetValueForKey:relatedshipName];
                
                [self establishOrderedToManyRelationship:relatedshipName fromObject:copiesObject withSourceSet:sourceSet];
                
            }else if (relationship.isToMany && !relationship.isOrdered)
            {
                //拷贝一对多
                NSMutableSet *sourceSet = [sourceObject mutableSetValueForKey:relatedshipName];
                
                [self establishToManyRelationship:relatedshipName fromObject:sourceObject withSourceSet:sourceSet];
            }else
            {
                //拷贝一对一关系
                NSManagedObject *relatedSourceObject = [sourceObject valueForKey:relatedshipName];
                
                NSManagedObject *relatedCopiesObject = [self copyUniqueObject:relatedSourceObject
                        toContext:targetContext];
                
                [self establishToOneRelationship:relatedshipName
                                      fromObject:copiesObject toObject:relatedCopiesObject];
            }
        }
    }
}
//根据给定的实体把全部对象从一个上下文拷贝到另一个上下文中
//把对象和关系一并导入
-(void)deepCopyEntity:(NSArray *)entities fromContext:(NSManagedObjectContext *)sourceContext
            toContext:(NSManagedObjectContext *)targetContext
{
    for (NSString *entity in entities) {
        
        NSArray *sourceObjects = [self arrayWithEntity:entity inContext:sourceContext withPredicate:nil];
        
        for (NSManagedObject *sourceObject in sourceObjects) {
            
            if (sourceObject) {
                
                //系统在数据倒入过程中可以定期释放内存
                @autoreleasepool {
                    
                    [self copyUniqueObject:sourceObject toContext:targetContext];
                    [self copiesRelationshipsFromObject:sourceObject toContext:targetContext];
                }
            }
        }
    }
}
@end

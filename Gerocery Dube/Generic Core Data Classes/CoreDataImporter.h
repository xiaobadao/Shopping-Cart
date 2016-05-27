//
//  CoreDataImporter.h
//  Gerocery Dube
//
//  Created by lanmao on 16/1/13.
//  Copyright © 2016年 Tim Roadley. All rights reserved.
//
/**
 *  此类导入互不相同的托管对象
 */
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataImporter : NSObject
/**
 *  保存每个目标实体与unique 属性名称之间的映射关系
 */
@property (nonatomic,strong) NSDictionary *entitiesWithUniqueAttributes;

+(void)saveContext:(NSManagedObjectContext *)context;
/**
 *  创建CoreDataImporter的实例
 *
 *  @param uniqueAttributes  保存每个目标实体与unique 属性名称之间的映射关系

 *
 *  @return
 */
-(CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes;
/**
 *  根据指定的实体查找出与之对应的unique 属性
 *
 *  @param entity 给定的实体
 *
 *  @return 返回与之对应的unique 属性
 */
-(NSString *)uniqueAttributeForEntity:(NSString *)entity;
/**
 *  Description
 *
 *  @param entity
 *  @param uniqueAttributeValue
 *  @param attributesValues
 *  @param context
 *
 *  @return
 */
-(NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity
                    uniqueAttributeValue:(NSString *)uniqueAttributeValue
                                     attributeValues:(NSDictionary *)attributesValues
                                     inContext:(NSManagedObjectContext *)context;
/**
 *  
 *
 *  @param entity
 *  @param targetEntityAttributeValue
 *  @param sourceXMLAttribute
 *  @param attributeDict
 *  @param context
 *
 *  @return
 */
-(NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity  targetEntityAttributeValue:(NSString *)targetEntityAttributeValue
                                 sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                      attributeDict:(NSDictionary *)attributeDict context:(NSManagedObjectContext *)context;
//根据给定的实体把全部对象从一个上下文拷贝到另一个上下文中
-(void)deepCopyEntity:(NSArray *)entities
          fromContext:(NSManagedObjectContext *)sourceContext
            toContext:(NSManagedObjectContext *)targetContext;

@end

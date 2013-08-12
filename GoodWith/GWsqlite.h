//
//  GWsqlite.h
//  GoodWith
//
//  Created by Adam Wilson on 6/16/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface GWsqlite : NSObject
{
    sqlite3 *dataBase;
    NSString *dbPath;
}
@property (nonatomic, strong) NSString *ingredient;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSDictionary *plist;

@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) NSMutableDictionary *resultsDict;

-(id)init;
-(void)saveIngredients;
-(BOOL)findIngredient:(NSString *)ing;
@end

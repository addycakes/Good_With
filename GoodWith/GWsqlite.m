//
//  GWsqlite.m
//  GoodWith
//
//  Created by Adam Wilson on 6/16/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import "GWsqlite.h"

static sqlite3_stmt *initial_statement = nil;

@implementation GWsqlite

-(id)init
{
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        self.plist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        
        const char *path = [dbPath UTF8String];
        
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = [dirPaths objectAtIndex:0];
        
        // Build the path to the database file
        dbPath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"GoodWith.sqlite"]];
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        if ([filemgr fileExistsAtPath: dbPath] == NO){
            if (sqlite3_open(path, &dataBase) == SQLITE_OK){
                NSLog(@"Database Opened");
            }else{
                NSLog(@"Database failed to open");
            }
        }
    }
    //[self saveIngredients];
    //[self findIngredient];

    return self;
}


-(void)saveIngredients
{
    sqlite3_stmt *stmt;

    for (NSString *key in self.plist) {
        //replace "space" with "-" for sqlite table naming convention
        NSMutableString *spacelessKey = [NSMutableString stringWithString:key];
        
       [spacelessKey replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, key.length)];
        
        NSString *newTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, ingredient TEXT, count INTEGER)", spacelessKey];
        const char *sql_stmt = [newTable UTF8String];
            
        sqlite3_prepare_v2(dataBase, sql_stmt, -1, &initial_statement, NULL);
        
        //add ingredients from plist to sqlite database
        char *errMsg;        
                
        if (sqlite3_exec(dataBase, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            NSLog(@"Failed to create table: %s", errMsg);
        }else{
            NSLog(@"%@ tabled created", key);
        }
        
        NSDictionary *gwDict = [self.plist objectForKey:key];
        for (NSString *newKey in gwDict) {
            NSMutableString *spacelessNewKey = [NSMutableString stringWithString:newKey];
            [spacelessNewKey replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newKey.length)];

            if (![newKey isEqualToString:@"Recipes"]) {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO %@ (ingredient, count) VALUES (\"%@\", %d)", spacelessKey, spacelessNewKey, [[gwDict objectForKey:newKey] intValue]];
                const char *insert_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(dataBase, insert_stmt, -1, &stmt, NULL);
                if (sqlite3_step(stmt) == SQLITE_DONE){
                    NSLog(@"added");
                }else {
                    NSLog(@"Failed to add");
                }
            }else {
                NSArray *recipes = [gwDict objectForKey:newKey];
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO %@ (ingredient, count) VALUES (\"Recipes\", %d)", spacelessKey, [recipes count]];
                const char *insert_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(dataBase, insert_stmt, -1, &stmt, NULL);
                if (sqlite3_step(stmt) == SQLITE_DONE){
                    NSLog(@"added");
                }else {
                    NSLog(@"Failed to add");
                }

            }
        }
        
    }
    sqlite3_finalize(stmt);
    sqlite3_finalize(initial_statement);
    sqlite3_close(dataBase);
    
}

-(BOOL)findIngredient:(NSString *)ing
{
    BOOL found = NO;
    self.resultsArray = [[NSMutableArray alloc] init];
    self.resultsDict = [[NSMutableDictionary alloc] init];
    
    const char *path = [dbPath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(path, &dataBase) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM %@", ing];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(dataBase, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            found = YES;
            while ((sqlite3_step(statement) == SQLITE_ROW)) {
                NSString *ingredient = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                
                NSNumber *count = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
                
                if (![ingredient isEqualToString:@"recipes"]) {
                    [self.resultsArray addObject:ingredient];
                }
                
                [self.resultsDict setObject:count forKey:ingredient];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(dataBase);
    }
    return found;
}

@end

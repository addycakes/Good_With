//
//  GWBreakdownTVC.m
//  GoodWith
//
//  Created by Adam Wilson on 5/10/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//
// Had to manually parse the html data from BigOven until they grant me access to their
// xml or json api site.  The method's a bit of a hack but it should perform as
// intended even if they expand/edit their glossary list.  (see connectionDidFinishLoading:)
//
// Might add didSelectRowAtIndexPath: method that opens BigOven Glossary webview for ingredient
// that has been selected from the tableview

#import "GWBreakdownTVC.h"
#import "GWCell.h"
#import "GWsqlite.h"

@interface GWBreakdownTVC ()
{
    GWsqlite *sqlite;
}
@end

@implementation GWBreakdownTVC

//connect to BigOven and create glossary of terms
-(void)showBreakdown:(NSString *)term
{
    sqlite = [[GWsqlite alloc] init];
    [sqlite findIngredient:term];

    self.resultsDict = [NSMutableDictionary dictionaryWithDictionary:sqlite.resultsDict];
    self.count = [self.resultsDict objectForKey:@"Recipes"];
    [self.resultsDict removeObjectForKey:@"Recipes"];
    self.resultsArray = [self.resultsDict keysSortedByValueUsingSelector:@selector(compare:)];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Often";
    }else if (section == 1) {
        return @"Sometimes";
    }else {
        return @"Rarely";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsDict.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GWCell";
    GWCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - 1)];
    NSNumber *count = [self.resultsDict objectForKey:food];

    float percent = 100 * ([count intValue] / [self.count floatValue]);
    
    // Configure the cell...
    [[cell ingredientLabel] setText:food];
    [[cell percentLabel] setText:[NSString stringWithFormat:@"%.02f%%", percent]];

    return cell;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.count = nil;
    self.resultsDict = nil;
    self.resultsArray = nil;
}

@end

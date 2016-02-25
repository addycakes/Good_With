//
//  recipesTableViewController.h
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "recipe.h"

@interface recipesTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    //for (datasource)
    NSString *ingredient;
    NSString *currentRecipeURL;
    NSString *nextPageURL;
    
    NSMutableArray *results;
    NSMutableDictionary *resultsDict;
    
    //for recipeWebView
    NSURL *recipeURL;
    NSString *recipeTitle;
}
@property (nonatomic, strong) NSMutableArray *recipeFilters; //for breakdown to update tableview title
@property (nonatomic) BOOL searching;
@property (nonatomic) BOOL paging;

@end

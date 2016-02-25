//
//  recipesTableViewController+datasource.h
//  GoodWith
//
//  Created by Adam Wilson on 10/6/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "recipesTableViewController.h"

@interface recipesTableViewController (datasource)

-(void)startBackgroundFetching;
-(void)loadNextPage;
-(void)filterRecipes:(NSString *)filterIngredient;
@end

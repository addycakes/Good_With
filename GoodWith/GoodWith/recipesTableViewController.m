//
//  recipesTableViewController.m
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//
//  BigOven api_key - dvx2X6iIe8KT53yZWNsL4j6cJ2O40vF4

#import "recipesTableViewController.h"
#import "recipesTableViewController+datasource.h"
#import "recipeCell.h"
#import "recipeWebView.h"

@implementation recipesTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    results = [[NSMutableArray alloc] init];            //the recipes displayed in tableview
    resultsDict = [[NSMutableDictionary alloc] init];   //backup for quick reload

    recipeURL = [[NSURL alloc] init];                   //url for recipeWebView
    recipeTitle = [[NSString alloc] init];              //title for recipeWebView
    
    self.recipeFilters = [[NSMutableArray alloc] init];
    self.searching = YES;                               //for activity spinner when loading results
    self.paging = NO;                                   //for tableview when loading multiple pages
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //prepare ingredient for web use
    ingredient = [self.parentViewController.navigationItem.title stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    //kick off recipe background fetching
    [self performSelectorInBackground:@selector(startBackgroundFetching) withObject:nil];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString stringWithFormat:@"Recipes with: %@",self.parentViewController.navigationItem.title];
    
    //for each ingredient in the filter, append to the tableview title
    if (self.recipeFilters.count > 0) {
        for (NSString *ing in self.recipeFilters) {
            title = [title stringByAppendingString:[NSString stringWithFormat:@", %@",ing]];
        }
    }
   
    return title;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (results.count == 0){
        return 1;
    }else {
        return results.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    recipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
    // Configure the cell...
    [cell.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.titleLabel setNumberOfLines:3];
    
    if (results.count == 0 && self.searching == YES){           //background recipes fetch in progress
        [cell.loadingSpinner startAnimating];
        [cell.titleLabel setText:@""];
        [cell.thumbnail setImage:[[UIImage alloc]init]];
    }else if (results.count == 0 && self.searching == NO) {     //no recipes found
        [cell.titleLabel setText:@"No Recipes"];
        [cell.thumbnail setImage:[[UIImage alloc]init]];
    }else{                                                      //recipes found, in results
        recipe *r = [results objectAtIndex:indexPath.row];
        NSMutableString *cellText = [NSMutableString stringWithFormat:@"%@",r.recipeTitle];
        [cell.titleLabel setText:[cellText stringByReplacingOccurrencesOfString:@"-" withString:@" "]];
        [cell.thumbnail setImage:[UIImage imageWithData:r.imageData]];
    }
    
    //if user reaches last cell, load more recipes
    if (indexPath.row == [results count] - 1 && self.paging == NO)
    {
        self.paging = YES;
        [self performSelectorInBackground:@selector(loadNextPage) withObject:nil];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell only interactable if there are recipes
    if (!results.count == 0) {
        recipe *r = [results objectAtIndex:indexPath.row];
        
        //store data for segue
        recipeTitle = r.recipeTitle;
        recipeURL = r.recipeURL;
        
        //init the viewcontroller
        recipeWebView *rwv = [self.storyboard instantiateViewControllerWithIdentifier:@"web"];
        
        UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"webview" source:self destination:rwv  performHandler:^{
            [self.navigationController pushViewController:rwv animated:YES];
        }];
        
        [self prepareForSegue:segue sender:self];
        [segue perform];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (recipeURL) {
        if ([segue.identifier isEqualToString:@"webview"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(displayWebsite:)]) {
                [segue.destinationViewController setTitle:recipeTitle];
                [segue.destinationViewController performSelector:@selector(displayWebsite:) withObject:recipeURL];
            }
        }
    }
}


@end

//
//  recipesTableViewController+datasource.m
//  GoodWith
//
//  Created by Adam Wilson on 10/6/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "recipesTableViewController+datasource.h"

@implementation recipesTableViewController (datasource)

-(void)startBackgroundFetching
{
    if (results.count == 0) {
        currentRecipeURL = [NSString stringWithFormat:@"http://www.bigoven.com/recipes/search?any_kw=%@", ingredient];
        NSURL *searchResultsURL = [NSURL URLWithString:currentRecipeURL];
        NSString *searchResultsHTML = [NSString stringWithContentsOfURL:searchResultsURL encoding:NSUTF8StringEncoding error:nil];

        [self parseHTML:(NSMutableString*)searchResultsHTML];
    }
    
    //reload to start activity spinner
    [self.tableView reloadData];
}

-(void)parseHTML:(NSMutableString *)html
{
    [html enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        //get all recipes on page
        if ([line rangeOfString:@"data-url="].location != NSNotFound) {
            
            //get recipe URL
            NSRange urlRange;
            urlRange.location = ([line rangeOfString:@"data-url"].location + 10); //start of the url
            urlRange.length = ([line rangeOfString:@"\"><div"].location - urlRange.location); //the full range of url
            
            NSString *urlString = [line substringWithRange:urlRange];
            
            //get Recipe Title
            NSRange titleRange;
            titleRange.location = [urlString rangeOfString:@"recipe/"].location + 7;//start of recipe title
            titleRange.length = [urlString rangeOfString:@"/" options:NSBackwardsSearch].location - titleRange.location; //end of recipe
            
            NSString *titleString = [urlString substringWithRange:titleRange];;
            
            //get image data
            NSRange imgRange;
            imgRange.location = [line rangeOfString:@"src=\""].location + 5;
            imgRange.length = [line rangeOfString:@".jpg"].location + 4 - imgRange.location;

            NSString *imgURL = [line substringWithRange:imgRange];
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
            
            //create recipe object and set url and title properties
            recipe *r = [[recipe alloc] init];
            r.recipeURL = [NSURL URLWithString:urlString];
            r.recipeTitle = titleString;
            r.imageData = [NSData dataWithData:imgData];
            
            [results addObject:r];
        }
        
        [self getNextPage:html];
    }];
    
    //create dictionary of result arrays for quick reload during filtering
    if (resultsDict.count == 0) {
        NSArray *array = [NSArray arrayWithArray:results];
        [resultsDict setObject:array forKey:ingredient];
    }
    
    //after page is parsed, stop searching and paging and reload data to display recipes
    self.searching = NO;
    self.paging = NO;
    [self.tableView reloadData];
}

-(void)getNextPage:(NSMutableString *)html
{
    [html enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        //get url of next page for more recipes
        if ([line rangeOfString:@"rel=\"next\""].location != NSNotFound) {
            NSRange urlRange;
            urlRange.location = ([line rangeOfString:@"rel=\"next\" href=\""].location + 17); //start of the url
            
            line = [line substringFromIndex:urlRange.location];
            
            urlRange.length = ([line rangeOfString:@"\" ><span"].location); //the full range of url
            urlRange.location = 0;
            NSString *nextURL = [NSString stringWithFormat:@"http://www.bigoven.com%@", [line substringWithRange:urlRange]];
            
            nextPageURL = [NSString stringWithString:nextURL];
        }
    }];
}

-(void)loadNextPage
{
    //update currentRecipeURL
    currentRecipeURL = nextPageURL;

    NSURL *url = [NSURL URLWithString:nextPageURL];
    NSString *searchResultsHTML = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    [self parseHTML:(NSMutableString*)searchResultsHTML];
}

-(void)filterRecipes:(NSString *)filterIngredient
{
    //create entry in resultsDict for new set of results
    NSMutableString *dictKey = [NSMutableString stringWithString:ingredient];
    if (self.recipeFilters.count > 0) {
        for (NSString *fi in self.recipeFilters) {
            [dictKey appendString:fi];
        }
    }
    
    //remove the page section of url to reset to page one if multiple pages loaded
    if ([currentRecipeURL rangeOfString:@"/page/"].location != NSNotFound) {
        if ([currentRecipeURL rangeOfString:@"best"].location != NSNotFound) {
            currentRecipeURL = [NSString stringWithFormat:@"http://www.bigoven.com/recipes/search?any_kw=%@", ingredient];
        }else{
            NSRange pageRange;

            pageRange.location = [currentRecipeURL rangeOfString:@"/page/"].location;
            pageRange.length = [currentRecipeURL rangeOfString:@"?any"].location - pageRange.location;
            NSString *page = [currentRecipeURL substringWithRange:pageRange];
            
            currentRecipeURL = [currentRecipeURL stringByReplacingOccurrencesOfString:page withString:@""];
        }
    }
    
    //create new url including filters
    NSString *urlString;
    filterIngredient = [filterIngredient stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if ([self.recipeFilters containsObject:filterIngredient]) {
        //check for pages in url. If present, reset the currentRecipeURL
        urlString = [NSString stringWithFormat:@"%@&include_ing=%@",currentRecipeURL,filterIngredient];
    }else{
        urlString = [currentRecipeURL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&include_ing=%@",filterIngredient] withString:@""];
    }
    
    NSURL *filterURL = [NSURL URLWithString:urlString];
    
    //update currentRecipeURL
    currentRecipeURL = urlString;

    //empty results
    [results removeAllObjects];

    //update recipes with tableview data is available, else load new page
    if ([resultsDict valueForKey:dictKey]) {
        [results addObjectsFromArray:[resultsDict objectForKey:dictKey]];
        [self.tableView reloadData];

        //reset the next page to load upon scrolling
        NSString *searchResultsHTML = [NSString stringWithContentsOfURL:[NSURL URLWithString:currentRecipeURL] encoding:NSUTF8StringEncoding error:nil];
        [self getNextPage:(NSMutableString *)searchResultsHTML];
    }else{
        //display activity indicator in tableview
        self.searching = YES;
        [self.tableView performSelector:@selector(reloadData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];

        //parse new url
        NSString *searchResultsHTML = [NSString stringWithContentsOfURL:filterURL encoding:NSUTF8StringEncoding error:nil];
        [self parseHTML:(NSMutableString*)searchResultsHTML];
        
        //add results into temporary dict
        NSArray *array = [NSArray arrayWithArray:results];
        [resultsDict setObject:array forKey:dictKey];
    }
    
}

@end

//
//  breakdownVC.m
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "breakdownVC.h"
#import "piechartView.h"
#import "linesView.h"
#import "recipesTableViewController.h"
#import "recipesTableViewController+datasource.h"
#import "sliceOutlineView.h"

@interface breakdownVC ()
{
    NSString *ingredient;
    NSMutableArray *divisionLines;
    NSMutableArray *sliceOutlines;
    NSMutableArray *results;
    recipesTableViewController *tableView;

    int totalCount;
}
@end

@implementation breakdownVC

-(void)showBreakdown:(NSString *)term
{
    ingredient = [NSString stringWithString:term];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    divisionLines = [[NSMutableArray alloc] init];
    sliceOutlines = [[NSMutableArray alloc] init];
    [self.navigationController.navigationBar setAlpha:0];

    //remove recipes array and self-identity item
    [self.resultsDict removeObjectForKey:@"Recipes"];
    if ([self.resultsDict objectForKey:ingredient]) {
        [self.resultsDict removeObjectForKey:ingredient];
    }
    
    //sort by the most frequently occurring ingredient to the least
    results = [[NSMutableArray alloc] initWithArray:[self.resultsDict keysSortedByValueUsingSelector:@selector(compare:)]];
    
    //get instance of recipesTableViewController
    if (!tableView) {
        for (id obj in self.childViewControllers) {
            tableView = (recipesTableViewController *)obj;
        }
        
        [self getTopTenResults];
        [self drawViews];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //navigation bar appearance
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //swipe back to return to home screen
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    [self.view addGestureRecognizer:swipe];
}

//top ten ingredients found on recipes with the search-ingredient
-(void)getTopTenResults
{
    NSMutableArray *topTen = [[NSMutableArray alloc] init];  //temporary holder of top 10
    totalCount = 0;
    
    //check the count of results
    int t;
    if (results.count >= 10) {
        t = 10;
    }else {
        t = (int)results.count;
    }
    
    //keep track of totalCount in the value for each key, used to determine pie slice sizes
    for (int i = 1; i <= t; i++){
        [topTen addObject:[results objectAtIndex:results.count-i]];
        totalCount += [[self.resultsDict objectForKey:[results objectAtIndex:results.count-i]] integerValue];
    }
    
    //store top 10 in results array
    [results removeAllObjects];
    [results addObjectsFromArray:topTen];
}

-(void)drawViews
{
    //animation for piechart
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.piechart setAlpha:1];
    } completion:^(BOOL complete){
        //animate piechart divisions and title label
        [UIView animateWithDuration:1 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self createDivisions];
            [self.navigationController.navigationBar setAlpha:1];
        } completion:^(BOOL complete){
            //animate result labels
            [UIView animateWithDuration:1 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self drawLabels];
                for (UILabel *obj in self.view.subviews){
                    if ([obj isKindOfClass:[UILabel class]]) {
                        [obj setAlpha:1];
                    }
                }
            } completion:^(BOOL complete){
                //animate recipes tableview
                [UIView animateWithDuration:1 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [tableView.tableView setAlpha:1];
                } completion: nil];
            }];
        }];
    }];
}

//lines on the piechart.
-(void)createDivisions
{
    float angle = 0;
    for (int i = 0; i < results.count; i++) { //this loop will use count of ingredients in results array
        //first division of pie chart rotate
        angle += ([[self.resultsDict objectForKey:[results objectAtIndex:i]] floatValue]/totalCount);
        linesView *lines = [[linesView alloc] initWithFrame:self.piechart.frame];
        [lines setBackgroundColor:[UIColor clearColor]];
        [lines setAngle:(angle * 360)*(M_PI/180)]; // this value will determine the angle of rotation. radians
        [self.view addSubview:lines];
        [lines setTag:i];
        [divisionLines addObject:lines];
    }
}

#define RESULT_LABEL_WIDTH 85
#define RESULT_LABEL_HEIGHT 45

-(void)drawLabels
{
    //every line gets a label
    for (int n = 0; n < results.count; n++) {
        UILabel *resultIngredient;
        
        if (n < (results.count/2) || results.count <= 5) {
            CGRect resultIngredientFrame = CGRectMake(self.view.frame.size.width - RESULT_LABEL_WIDTH - 10,  (40 * (n)) + 60, RESULT_LABEL_WIDTH, RESULT_LABEL_HEIGHT);
            resultIngredient = [[UILabel alloc] initWithFrame:resultIngredientFrame];
        }else {
            CGRect resultIngredientFrame = CGRectMake(10,  220 - (40 * (n - (results.count/2))), RESULT_LABEL_WIDTH, RESULT_LABEL_HEIGHT);
            resultIngredient = [[UILabel alloc] initWithFrame:resultIngredientFrame];
        }
        
        //label style properties
        [resultIngredient setText:[results objectAtIndex:n]];
        [resultIngredient setFont:[UIFont fontWithName:@"Malayalam Sangam MN" size:12]];
        [resultIngredient setAdjustsFontSizeToFitWidth:YES];
        [resultIngredient setNumberOfLines:2];
        [resultIngredient setLineBreakMode:NSLineBreakByWordWrapping];
        [resultIngredient setTextColor:[UIColor colorWithRed:0 green:.3 blue:0 alpha:1]];
        [resultIngredient setTextAlignment:NSTextAlignmentCenter];

        //label actions
        [resultIngredient setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectIngredient:)];
        [resultIngredient addGestureRecognizer:tapGesture];
        
        //initially hide the view for animation to fade in
        [resultIngredient setAlpha:0];
        [self.view addSubview:resultIngredient];
        [resultIngredient setTag:n];
    }
}

-(IBAction)selectIngredient:(UITapGestureRecognizer *)sender
{
    UILabel *label = (UILabel *)sender.view;
    NSString *filterIngredient = label.text;
    
    //label is only interactable if there are less than 5 labels selected, or the label has already been
    //selected.
    if (tableView.recipeFilters.count < 5  || [tableView.recipeFilters containsObject:filterIngredient]) {
        sliceOutlineView *sliceOutline;
        if (![tableView.recipeFilters containsObject:filterIngredient]) {   //selecting filter ingredient
            //outline the selected ingredient's pie slice
            for (linesView *l in divisionLines) {
                if (l.tag == sender.view.tag) {
                    sliceOutline = [[sliceOutlineView alloc] initWithFrame:self.piechart.frame];
                    [sliceOutline setBackgroundColor:[UIColor clearColor]];
                    [sliceOutline setAlpha:0];

                    if (l.tag == 0) {
                        [sliceOutline outlineSlice:[divisionLines objectAtIndex:l.tag] and:[divisionLines lastObject]];
                    }else{
                        [sliceOutline outlineSlice:[divisionLines objectAtIndex:l.tag] and:[divisionLines objectAtIndex:l.tag-1]];
                    }
                    
                    [sliceOutline setTag:l.tag];
                    [sliceOutlines addObject:sliceOutline];
                    [self.view addSubview: sliceOutline];
                    [self.view bringSubviewToFront:sliceOutline];

                    [UIView animateWithDuration:.5 animations:^{
                        [sliceOutline setAlpha:1];;
                    }];
                }
            }

            [tableView.recipeFilters addObject:filterIngredient];
            [label setFont:[UIFont fontWithName:@"Malayalam Sangam MN-Bold" size:12]];
        }else{                                                              //deselecting filter ingredient
            //remove outline around pie slice
            for (sliceOutlineView *o in sliceOutlines) {
                if (o.tag == sender.view.tag) {
                    sliceOutline = o;
                }
            }
            [UIView animateWithDuration:.5 animations:^{
                [sliceOutline setAlpha:0];
            } completion:^(BOOL finished) {
                [sliceOutline removeFromSuperview];
                [sliceOutlines removeObject:sliceOutline];
            }];
            
            [tableView.recipeFilters removeObject:filterIngredient];
            [label setFont:[UIFont fontWithName:@"Malayalam Sangam MN" size:12]];
        }
        [tableView performSelectorInBackground:@selector(filterRecipes:) withObject:filterIngredient];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [results removeAllObjects];
}

@end

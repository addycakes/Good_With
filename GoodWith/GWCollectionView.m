//
//  GWCollectionView.m
//  GoodWith
//
//  Created by Adam Wilson on 6/25/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import "GWCollectionView.h"
#import "GWCollectionCell.h"
#import "GWCollectionHeader.h"

@interface GWCollectionView ()
{
    GWsqlite *sqlite;
}
@end

@implementation GWCollectionView

-(void)showBreakdown:(NSString *)term
{
    searchTerm = [NSString stringWithString:term];
    
    sqlite = [[GWsqlite alloc] init];
    if ([sqlite findIngredient:term]){        
        self.resultsDict = [NSMutableDictionary dictionaryWithDictionary:sqlite.resultsDict];
        self.count = [self.resultsDict objectForKey:@"Recipes"];
        [self.resultsDict removeObjectForKey:@"Recipes"];
        self.resultsArray = [self.resultsDict keysSortedByValueUsingSelector:@selector(compare:)];
        self.resultsFilter = [[NSMutableArray alloc] initWithObjects:term, nil];
    }else{
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Not Found" message:@"The ingredient is not in the database.  Would you like to submit it for addition to database?" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Yes", nil];
        
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //move to new view for user to enter ingredient and pairings
        [self performSegueWithIdentifier:@"Email Form" sender:self];
    }else {
        //return to root search view
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    GWCollectionHeader *cheader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GWCollectionHeader" forIndexPath:indexPath];
    //modify your header
    if (indexPath.section == 0){
        [[cheader header] setText:@"75 Percentile"];
    }else if (indexPath.section == 1){
        [[cheader header] setText:@"50 Percentile"];
    }else {
        [[cheader header] setText:@"Rest"];
    }

    return cheader;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0){
        return self.resultsArray.count * .25;
    }else if (section == 1){
        return self.resultsArray.count * .25;
    }else{
        return self.resultsArray.count * .5;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GWCollectionCell";
    GWCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *food = [[NSString alloc] init];
    
    if (indexPath.section == 0) {
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - 1)];
    }else if (indexPath.section == 1){
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - (self.resultsArray.count * .25 + 1))];
    }else{
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - (self.resultsArray.count * .5 + 1))];
    }
    
    [[cell ingredientLabel] setText:food];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GWCell.png"]];
    
    if ([self.resultsFilter containsObject:cell.ingredientLabel.text]) {
        cell.backgroundView.alpha = 1;
    }else cell.backgroundView.alpha = .1;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *food = [[NSString alloc] init];
    if (indexPath.section == 0) {
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - 1)];
    }else if (indexPath.section == 1){
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - (self.resultsArray.count * .25 + 1))];
    }else{
        food = [self.resultsArray objectAtIndex:(self.resultsArray.count - indexPath.row - (self.resultsArray.count * .5 + 1))];
    }
    
    if (cell.backgroundView.alpha == 1) {
        cell.backgroundView.alpha = .1;
        [self.resultsFilter removeObjectIdenticalTo:food];
    }else {
        [self.resultsFilter addObject:food];
        cell.backgroundView.alpha = 1;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UICollectionViewController class]]) {
        if ([segue.identifier isEqualToString:@"Email Form"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(sendEmail:)]) {
                [segue.destinationViewController setTitle:[NSString stringWithFormat:@"%@", searchTerm]];
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.resultsDict = nil;
    self.resultsArray = nil;
    self.count = 0;
    sqlite = nil;
}


@end

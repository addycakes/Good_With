//
//  GWSearchVC.m
//  GoodWith
//
//  Created by Adam Wilson on 5/10/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import "GWSearchVC.h"

@interface GWSearchVC ()
{
}
@end

@implementation GWSearchVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //reset search field & term when view appears
    self.ingredient = nil;
    [self.searchField setText:@""];
    [self.searchField resignFirstResponder];
    
}

-(void)textFieldReturn:(id)sender
{
    //only kick off search if text has been entered
    if (![self.searchField.text isEqual: @""]) {
        self.ingredient = self.searchField.text;
    
        //cv = [[GWCollectionView alloc] init];
        [self performSegueWithIdentifier:@"Show Breakdown" sender:self];

    }
    
    [sender resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIViewController class]]) {
        if (self.ingredient) {
            if ([segue.identifier isEqualToString:@"Show Breakdown"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(showBreakdown:)]) {
                    [segue.destinationViewController performSelector:@selector(showBreakdown:) withObject:self.ingredient];
                    [segue.destinationViewController setTitle:self.ingredient];
                }
            }
        }
    }
}


@end

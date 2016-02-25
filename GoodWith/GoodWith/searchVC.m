//
//  searchVC.m
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "searchVC.h"
#import "breakdownVC.h"
#import "tutorialVC.h"

@interface searchVC ()
{
    NSDictionary *plistDict;
    NSMutableArray *autocomplete;
    NSMutableString *autocompleteSuggestion;
}
@end

@implementation searchVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //init plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
    plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if (!plistDict) {
        NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:pathToFile];
        [plistDict writeToFile:filePath atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        
        //since its the first time opening the app, run the tutorial
        [self runTutorial];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //animate initial layout
    [UITextField animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.searchField setAlpha:1];} completion:nil];
    [UILabel animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{[self.autocompleteLabel setAlpha:.25];} completion:nil];
    [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.background setAlpha:1];} completion:nil];
    
    // Do additional setup after loading the view.
    [self.searchField resignFirstResponder];
    [self.searchField setDelegate:self];
    [self.searchField setText:@""];
    self.searchTerm = nil;
    
    //fill placeholder with random ingredient from database
    autocomplete = [[NSMutableArray alloc] init];
    [self.autocompleteLabel setText:[NSString stringWithString:[[plistDict allKeys] objectAtIndex:arc4random()%[[plistDict allKeys] count]]]];
    
    //swipe to the right to run the tutorial
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(runTutorial)];
    [self.view addGestureRecognizer:swipe];
}

- (IBAction)textFieldIsEditing:(UITextField *)sender
{
    //enable tap to complete
    [self.searchField addTarget:self action:@selector(selectAutocompleteSuggestion) forControlEvents:UIControlEventTouchDown];
    
    //check against keys in plist for autocomplete (ghost text)
    for (autocompleteSuggestion in plistDict.allKeys) {
        NSRange substringRange = [autocompleteSuggestion rangeOfString:sender.text];
        if (substringRange.location == 0) {
            NSString *spacer = [@"" stringByPaddingToLength:substringRange.length withString: @" " startingAtIndex:0];
            NSMutableString *autocompleteString = [NSMutableString stringWithString:autocompleteSuggestion];
            [autocompleteString replaceCharactersInRange:substringRange withString:spacer];
            [self.autocompleteLabel setFont:self.searchField.font];
            [self.autocompleteLabel setText:autocompleteString];
            break;
        }else{
            [self.autocompleteLabel setText:@""];
        }
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //adjust view for iphone 4s (works on 5 and later)
    if (self.view.frame.size.height == 480) {
        CGRect currentFrame = self.view.frame;

        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.view setFrame:CGRectMake(currentFrame.origin.x, currentFrame.origin.y - 80, currentFrame.size.width, currentFrame.size.height)];} completion:nil];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //adjust view for iphone 4s (works on 5 and later)
    if (self.view.frame.size.height == 480) {
        CGRect currentFrame = self.view.frame;

        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.view setFrame:CGRectMake(currentFrame.origin.x, currentFrame.origin.y + 80, currentFrame.size.width, currentFrame.size.height)];} completion:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    
    CGPoint tap = [t locationInView:self.searchField];
    if (!CGRectContainsPoint(self.searchField.frame, tap)) {
        [self.searchField endEditing:YES];
        if ([self.searchField.text isEqualToString:@""]) {
            [self.autocompleteLabel setText:[NSString stringWithString:[[plistDict allKeys] objectAtIndex:arc4random()%[[plistDict allKeys] count]]]];
        }else{
            [self.autocompleteLabel setText:@""];
        }
    }
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //disable tap to complete
    [self.searchField removeTarget:self action:@selector(selectAutocompleteSuggestion) forControlEvents:UIControlEventTouchDown];
    return YES;
}

-(void)textFieldReturn:(id)sender
{
    self.searchTerm = [self.searchField.text stringByTrimmingCharactersInSet:
                                             [NSCharacterSet whitespaceCharacterSet]];
    
    //only kick off search if text has been entered and search term is in plistDict
    if (![self.searchTerm isEqual: @""] && [plistDict objectForKey:self.searchTerm] != nil) {
        [self cleanUp];
    }else{
        //future improvement: log searchTerm that aren't in database to add
        //display floating alert view
        [self ingredientNotFound];
    }
    [sender resignFirstResponder];
}

-(void)ingredientNotFound
{
    //label rises from bottom then fades away
    [UILabel animateWithDuration:1 animations:^{self.notFoundLabel.alpha = .5;} completion:^(BOOL finished) {
     [UILabel animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{self.notFoundLabel.alpha = 0;} completion:nil];
    }];
}

-(void)selectAutocompleteSuggestion
{
    [self.searchField endEditing:YES];
    self.searchField.text = autocompleteSuggestion;
    [self.autocompleteLabel setText:@""];
    [self textFieldReturn:self.searchField];
}

-(void)runTutorial
{
    //init tutorialVC
    tutorialVC *tutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    [self.navigationController pushViewController:tutVC animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.searchTerm) {
        if ([segue.identifier isEqualToString:@"Transition"]) {
            if ([segue.destinationViewController respondsToSelector:@selector(showBreakdown:)]) {
                [segue.destinationViewController setTitle:self.searchTerm];
                [segue.destinationViewController performSelector:@selector(showBreakdown:) withObject:self.searchTerm];
            }
        }
    }
}

-(void)cleanUp
{
    //init breakdownVC and set ingredient and results array
    breakdownVC *bdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Breakdown"];
    bdvc.resultsDict = [NSMutableDictionary dictionaryWithDictionary:[plistDict objectForKey:self.searchTerm]];
    
    UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"Transition" source:self destination:bdvc  performHandler:^{
        [UITextField animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.searchField setAlpha:0];} completion:nil];
        
        [UILabel animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.autocompleteLabel setAlpha:0];} completion:nil];
        
        [UIImageView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{[self.background setAlpha:0];} completion:^(BOOL complete){[self.navigationController pushViewController:bdvc animated:NO];}];
        }];
    
    [self prepareForSegue:segue sender:self];
    [segue perform];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [self.autocompleteLabel setText:@""];;
    [self.searchField setText:@""];
    autocompleteSuggestion = nil;
}

@end

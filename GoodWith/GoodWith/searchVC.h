//
//  searchVC.h
//  GoodWith
//
//  Created by Adam Wilson on 6/2/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface searchVC : UIViewController <UITextFieldDelegate>
{
    
}
//views
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UILabel *autocompleteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *notFoundLabel;

@property (nonatomic, strong) NSString *searchTerm;

-(IBAction)textFieldReturn:(id)sender;
-(void)selectAutocompleteSuggestion;
@end

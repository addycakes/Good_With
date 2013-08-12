//
//  GWEmailFormViewController.m
//  GoodWith
//
//  Created by Adam Wilson on 6/30/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import "GWEmailFormViewController.h"

@interface GWEmailFormViewController ()

@end

@implementation GWEmailFormViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //reset search field & term when view appears
    [pair1 setText:@""];
    [pair2 setText:@""];
    [pair3 setText:@""];
    [pair4 setText:@""];
    [pair5 setText:@""];
    [pair6 setText:@""];
    [pair7 setText:@""];
    [pair8 setText:@""];

    [addition setText:self.navigationItem.title];
    
    self.pairingsArray = [[NSMutableArray alloc]initWithObjects:pair1, pair2, pair3, pair4, pair5, pair6, pair7, pair8, nil];
    
}

-(IBAction)sendEmail:(id)sender
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;

    NSLog(@"New Addition: %@", addition.text);
    
    if (![addition.text isEqualToString:@""]) {
        NSMutableString *form = [[NSMutableString alloc] init];
        
        //header to warn against altering the email
        [form appendString:@"Please do not alter the contents of this message.  It is specially formatted for entry into the GoodWith database\n\n"];

        //start adding formatted information from input to email
        [form appendString:[NSString stringWithFormat:@"<Nam>\n%@\n<Nam>\n</Summ>\n", addition.text]];
         
        for (UITextField *pair in self.pairingsArray) {
            if (![pair.text isEqualToString:@""]) {
                NSString *ingredient = [NSString stringWithString:pair.text];
                
                [form appendString:[NSString stringWithFormat:@"<IngR name=\"%@\" qty 1\n", ingredient]];
            }
        }
        
        [form appendString:@"<DirT>"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"goodwithdatabase@gmail.com",
                                 nil];
        
        [mailComposer setSubject:@"New Ingredient Addition"];
        [mailComposer setMessageBody:form isHTML:NO];
        [mailComposer setToRecipients:toRecipients];
        
        [self presentViewController:mailComposer animated:YES completion:nil];

    }else{
        NSLog(@"Must have new ingredient");
    }
    
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Thank you!");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

@end

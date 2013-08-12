//
//  GWEmailFormViewController.h
//  GoodWith
//
//  Created by Adam Wilson on 6/30/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface GWEmailFormViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UITextField *pair1;
    IBOutlet UITextField *pair2;
    IBOutlet UITextField *pair3;
    IBOutlet UITextField *pair4;
    IBOutlet UITextField *pair5;
    IBOutlet UITextField *pair6;
    IBOutlet UITextField *pair7;
    IBOutlet UITextField *pair8;

    IBOutlet UILabel *addition;
}
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *pairingsArray;

-(IBAction)textFieldReturn:(id)sender;
-(IBAction)sendEmail:(id)sender;
@end

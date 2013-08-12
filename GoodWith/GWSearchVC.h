//
//  GWSearchVC.h
//  GoodWith
//
//  Created by Adam Wilson on 5/10/13.
//  Copyright (c) 2013 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GWSearchVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) NSString *ingredient;

-(IBAction)textFieldReturn:(id)sender;
@end

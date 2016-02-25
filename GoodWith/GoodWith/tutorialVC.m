//
//  tutorialVC.m
//  GoodWith
//
//  Created by Adam Wilson on 10/24/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "tutorialVC.h"

@implementation tutorialVC
{
    int index;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //navigation bar appearance
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //set image as tut1
    [self.image setImage:[UIImage imageNamed:@"GoodWithTutorial1.png"]];
    index = 0;
    
    //swipe thru to return to home screen. swipe right to page back, left to page forward.
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnPageForward)];
    UISwipeGestureRecognizer *swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(turnPageBack)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipe2 setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
    [self.view addGestureRecognizer:swipe2];
}

-(void)turnPageForward
{
    if (index == 0) {
        index++;
        [self.image setImage:[UIImage imageNamed:@"GoodWithTutorial2.png"]];
    }else if (index == 1){
        index++;
        [self.image setImage:[UIImage imageNamed:@"GoodWithTutorial3.png"]];

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)turnPageBack
{
    if (index == 2) {
        index--;
        [self.image setImage:[UIImage imageNamed:@"GoodWithTutorial2.png"]];
    }else if (index == 1){
        index--;
        [self.image setImage:[UIImage imageNamed:@"GoodWithTutorial1.png"]];
    }
}


@end

//
//  recipeWebView.m
//  GoodWith
//
//  Created by Adam Wilson on 8/29/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import "recipeWebView.h"

@interface recipeWebView ()
{
    NSURLRequest *req;
}
@end

@implementation recipeWebView

-(void)displayWebsite:(NSURL *)url
{
    req = [NSURLRequest requestWithURL:url];  //create the url request
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView setDelegate:self];
    [self.webView loadRequest:req];
    
    //swipe back to return to home screen
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    [self.view addGestureRecognizer:swipe];
}

//set contentsize for swipe to work
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize scrollableSize = CGSizeMake(self.view.frame.size.width, self.webView.scrollView.contentSize.height);
    [self.webView.scrollView setContentSize:scrollableSize];
}

@end

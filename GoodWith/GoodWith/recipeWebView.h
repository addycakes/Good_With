//
//  recipeWebView.h
//  GoodWith
//
//  Created by Adam Wilson on 8/29/14.
//  Copyright (c) 2014 Adam Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface recipeWebView : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

-(void)displayWebsite:(NSURL *)url;
@end

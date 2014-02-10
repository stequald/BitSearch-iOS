//
//  ViewController.h
//  BitSearch
//
//  Created by Tim Lee on 2/8/14.
//  Copyright (c) 2014 Tim Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface ViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *QRCodeBarButtonItem;

@end

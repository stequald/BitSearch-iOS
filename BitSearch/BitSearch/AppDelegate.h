//
//  AppDelegate.h
//  BitSearch
//
//  Created by Tim Lee on 2/8/14.
//  Copyright (c) 2014 Tim Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

FOUNDATION_EXPORT NSString *const ZBAR_READ_SYMBOL_NOTIFICATION;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ZBarReaderViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) ZBarReaderView * readerView;
@property (retain, strong) IBOutlet UIView * modalView;
@property (retain, strong) IBOutlet UIView * modalContentView;
@property (retain, strong) id modalDelegate;

-(void)scanAccountQRCode;
+(AppDelegate*)instance;
@end

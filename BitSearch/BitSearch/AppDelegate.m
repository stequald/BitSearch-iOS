//
//  AppDelegate.m
//  BitSearch
//
//  Created by Tim Lee on 2/8/14.
//  Copyright (c) 2014 Tim Lee. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+Hardware.h"
#import "UncaughtExceptionHandler.h"

@implementation AppDelegate

NSString *const ZBAR_READ_SYMBOL_NOTIFICATION = @"ZBarReadSymbolNotification";

+(AppDelegate*)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

-(void)parseAccountQRCodeData:(NSString*)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:ZBAR_READ_SYMBOL_NOTIFICATION object:data];
}

- (void) readerView:(ZBarReaderView*)view didReadSymbols:(ZBarSymbolSet*)syms fromImage:(UIImage*)img {
    // do something uselful with results
    for(ZBarSymbol *sym in syms) {
        [self parseAccountQRCodeData:sym.data];
        [self.readerView stop];
        
        [self closeModal];
        break;
    }
    
    self.readerView = nil;
}

-(BOOL)isZBarSupported {
    NSUInteger platformType = [[UIDevice currentDevice] platformType];
    
    if (platformType ==  UIDeviceiPhoneSimulator || platformType ==  UIDeviceiPhoneSimulatoriPhone  || platformType ==  UIDeviceiPhoneSimulatoriPhone || platformType ==  UIDevice1GiPhone || platformType ==  UIDevice3GiPhone || platformType ==  UIDevice1GiPod || platformType ==  UIDevice2GiPod || ![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        return FALSE;
    }
    
    return TRUE;
}

-(void)scanAccountQRCode {
    if ([self isZBarSupported]) {
        self.readerView = [ZBarReaderView new];
        [self showModal:self.readerView];
        self.modalDelegate = self;
        [self.readerView start];
        [self.readerView setReaderDelegate:self];
    } else {
        //[self showModal:manualView];
    }
}

-(void)closeModal {
    [self.modalView removeFromSuperview];
    [self.modalContentView removeFromSuperview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.6f];
    [animation setType:kCATransitionFade];
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
    [[_window layer] addAnimation:animation forKey:@"HideModal"];
    
    if ([self.modalDelegate respondsToSelector:@selector(didDismissModal)])
        [self.modalDelegate didDismissModal];
    
    self.modalContentView = nil;
    self.modalView = nil;
    self.modalDelegate = nil;
}

-(IBAction)closeModalClicked:(id)sender {
    [self closeModal];
}

-(IBAction)modalBackgroundClicked:(id)sender {
    [self.modalView endEditing:FALSE];
}

-(void)showModal:(UIView*)contentView {
    @try {
        if (self.modalView) {
            [self closeModal];
        }
        
        [[NSBundle mainBundle] loadNibNamed:@"ModalView" owner:self options:nil];
        [self.modalContentView addSubview:contentView];
        contentView.frame = CGRectMake(0, 0, self.modalContentView.frame.size.width, self.modalContentView.frame.size.height);
        
        [_window addSubview:self.modalView];
        [_window endEditing:TRUE];
    } @catch (NSException * e) {
        [UncaughtExceptionHandler logException:e];
    }
    
    @try {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.6f];
        [animation setType:kCATransitionFade];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        [[_window layer] addAnimation:animation forKey:@"ShowModal"];
    } @catch (NSException * e) {
        NSLog(@"%@", e);
    }
}

-(void)didDismissModal {
    [self.readerView stop];
    self.readerView = nil;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

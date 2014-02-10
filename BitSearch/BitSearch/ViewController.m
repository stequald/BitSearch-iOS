//
//  ViewController.m
//  BitSearch
//
//  Created by Tim Lee on 2/8/14.
//  Copyright (c) 2014 Tim Lee. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString *const FRONT_PAGE_SEARCH_TERM = @"1";
static const CGFloat SEARCH_NAVBAR_HEIGHT = 20;

@interface ViewController () {
    NSInteger _previousScrollViewYOffset;
    UIImage* _QRCodeImage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTextField.returnKeyType = UIReturnKeyGo;
    self.searchTextField.delegate = self;
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    _previousScrollViewYOffset = self.webView.scrollView.contentOffset.y;
    self.searchTextField.text = FRONT_PAGE_SEARCH_TERM;
    [self launchWeb:[self searchRequest:FRONT_PAGE_SEARCH_TERM]];
    
    _QRCodeImage = [[UIImage imageNamed:@"qrcode20x20.png"]
                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.QRCodeBarButtonItem setImage:_QRCodeImage];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zbarReadSymbolNotification:) name:ZBAR_READ_SYMBOL_NOTIFICATION object:nil];
}

- (void)zbarReadSymbolNotification:(NSNotification*)note {
    NSString* data = [note object];
    self.searchTextField.text = data;
    [self launchWeb: [self searchRequest:self.searchTextField.text]];
}

- (NSString*) searchRequest: (NSString*)searchTerm {
    static const NSString* blockchainSearchRequest = @"https://blockchain.info/search?search=";
    return [NSString stringWithFormat:@"%@%@",blockchainSearchRequest, searchTerm];
}

- (void) launchWeb: (NSString*)urlAddress {
    NSLog(@"urlAddress: %@", urlAddress);
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (IBAction) scanButtonTapped {
    [[AppDelegate instance] scanAccountQRCode];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webView.frame = f;
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.QRCodeBarButtonItem setEnabled:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.QRCodeBarButtonItem setEnabled:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.QRCodeBarButtonItem setEnabled:YES];
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.searchTextField) {
        [textField resignFirstResponder];
        [self launchWeb:[self searchRequest:textField.text]];
        return NO;
    }
    return YES;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - (SEARCH_NAVBAR_HEIGHT+1);
    CGFloat framePercentageHidden = ((SEARCH_NAVBAR_HEIGHT - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - _previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        frame.origin.y = SEARCH_NAVBAR_HEIGHT;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        frame.origin.y = -size;
    } else {
        frame.origin.y = MIN(SEARCH_NAVBAR_HEIGHT, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateBarButtonItems:(1 - framePercentageHidden)];
    _previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling {
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < SEARCH_NAVBAR_HEIGHT) {
        [self animateNavBarTo:-(frame.size.height - (SEARCH_NAVBAR_HEIGHT+1))];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
    
    if (alpha)
        [self.QRCodeBarButtonItem setImage:_QRCodeImage];
    else
        self.QRCodeBarButtonItem.image = nil;
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

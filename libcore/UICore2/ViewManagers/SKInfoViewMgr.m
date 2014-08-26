//
//  SKInfoViewMgr.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKInfoViewMgr.h"

@implementation SKInfoViewMgr

- (void)intialiseViewOnMasterView:(UIView*)masterView_
{
    self.backgroundColor = [UIColor clearColor];
    self.wvWebView.delegate = self;
    
    self.masterView = masterView_;
    self.wvWebView.backgroundColor = [UIColor clearColor];
    self.wvWebView.opaque = NO;
    
    [self loadHtml];
}

-(void)performLayout
{
    self.wvWebView.frame = CGRectMake(10, 25, self.bounds.size.width - 20, self.bounds.size.height - 25 - 10);
}

-(void)loadHtml
{
    NSString *filePath;
    
    NSBundle *bundle=[NSBundle mainBundle];
    
    filePath = [bundle pathForResource:@"terms_of_use" ofType: @"htm"];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
    
    [self.wvWebView loadRequest:request];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.wvWebView.alpha = 0.0;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    if ([webView canGoBack] && _B_Back_Prop.alpha < 0.1)
    //        [UIView animateWithDuration:0.3
    //                              delay:0.3f
    //                            options:UIViewAnimationOptionCurveEaseOut
    //                         animations:^{
    //                             _B_Back_Prop.alpha = 0.5;
    //                             _WV_WebView.alpha = 1;
    //                         }
    //                         completion:^(BOOL finished){
    //                             if (finished) {
    //
    //                             }
    //                         }];
    //    else if (![webView canGoBack] && _B_Back_Prop.alpha > 0.2)
    //        [UIView animateWithDuration:0.3
    //                              delay:0.3f
    //                            options:UIViewAnimationOptionCurveEaseOut
    //                         animations:^{
    //                             _B_Back_Prop.alpha = 0.0;
    //                             _WV_WebView.alpha = 1;
    //                         }
    //                         completion:^(BOOL finished){
    //                             if (finished) {
    //
    //                             }
    //                         }];
    //    else
    [UIView animateWithDuration:0.3
                          delay:0.3f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.wvWebView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    //    if (![[[inRequest URL] absoluteString] hasPrefix:@"http"])
    //    {
    //        G_CurrentItem = [G_Resources[G_Group] findItemOnFile:[[inRequest URL] absoluteString]];
    //        if (G_CurrentItem == nil || G_CurrentItem->xGeo == 0)
    //        {
    //            self.navigationItem.rightBarButtonItem = nil;
    //        }
    //        else
    //            self.navigationItem.rightBarButtonItem = rightButton;
    //
    //        _WV_WebView.alpha = 0.0;
    //        return YES;
    //    }
    //
    //    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
    //        [[UIApplication sharedApplication] openURL:[inRequest URL]];
    //        return NO;
    //    }
    //    
    //    _WV_WebView.alpha = 0.0;
    return YES;
}

-(void)activate
{
}

-(void)deactivate
{
}

@end

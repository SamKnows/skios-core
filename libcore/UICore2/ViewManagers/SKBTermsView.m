//
//  SKBTermsView.m
//  SKCore
//
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBTermsView.h"

@interface SKBTermsView()
@property (weak, nonatomic) IBOutlet UIWebView *wvWebView;
@end

@implementation SKBTermsView
-(void)setColoursAndShowHideElements {
  
  self.backgroundColor = [UIColor clearColor];
  
  self.wvWebView.delegate = self;
  self.wvWebView.backgroundColor = [UIColor clearColor];
  self.wvWebView.opaque = NO;
  
  [self loadHtml];
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

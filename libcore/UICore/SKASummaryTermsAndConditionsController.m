//
//  SKASummaryTermsAndConditionsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKASummaryTermsAndConditionsController.h"

@implementation SKASummaryTermsAndConditionsController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = sSKCoreGetLocalisedString(@"Storyboard_SummaryTerms_Title");

  NSString *resource = @"terms_of_use";
  NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"htm"];
  NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  
  [self.webView.scrollView setBounces:NO];
  [self.webView setDataDetectorTypes:UIDataDetectorTypeNone];
  [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

@end

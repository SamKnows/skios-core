//
//  SKBTestResultsSharer.h
//  SKCore
//
//  Created by Pete Cole on 07/10/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import <MessageUI/MFMailComposeViewController.h>
#import "CActionSheet.h"
#import "SKTestResults.h"

#define C_SHARE_FACEBOOK    1
#define C_SHARE_TWITTER    2
#define C_SHARE_MAIL    3
#define C_SHARE_SAVE    4

@interface SKBTestResultsSharer : NSObject <pActionSheetDelegate, MFMailComposeViewControllerDelegate>

- (instancetype)initWithViewController:(UIViewController*)inViewController;

-(void)shareTest:(SKATestResults*)testResult;

@end


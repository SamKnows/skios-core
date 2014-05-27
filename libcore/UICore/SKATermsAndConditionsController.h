//
//  SKATermsAndConditionsController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKAActivationController.h"

@interface SKATermsAndConditionsController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, SKAActivationDelegate>

@property (weak, nonatomic) IBOutlet UITextView *dataLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblMain;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *viewDataCollector;
@property (weak, nonatomic) IBOutlet UITextField *txtData;

@property int  index;

- (IBAction)ctlBackgroundTap:(id)sender;
- (IBAction)txtFieldDoneEditing:(id)sender;

@end

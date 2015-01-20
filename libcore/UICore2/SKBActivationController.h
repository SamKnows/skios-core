//
//  SKBActivationController.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKAAppDelegate.h"

@protocol SKAActivationDelegate;

@interface SKBActivationController : UIViewController

@property  BOOL hidesBackButton;
@property (weak, nonatomic) IBOutlet UILabel *lTitle;
@property (weak, nonatomic) IBOutlet UILabel *lActivating;
@property (weak, nonatomic) IBOutlet UILabel *lDownloading;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerActivating;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerDownloading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerMain;

@property (atomic, strong) id <SKAActivationDelegate> delegate;

- (IBAction)done:(id)sender;

@end

#pragma mark - Delegate

@protocol SKAActivationDelegate

- (void)hasCompleted;

@end
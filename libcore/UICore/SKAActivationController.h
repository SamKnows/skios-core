//
//  SKAActivationController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKAAppDelegate.h"

@protocol SKAActivationDelegate;

@interface SKAActivationController : UIViewController
{
    id <SKAActivationDelegate> delegate;
    
    BOOL hidesBackButton;
}

@property (weak, nonatomic) IBOutlet UILabel *lblMain;

@property (weak, nonatomic) IBOutlet UIView *viewBG;

@property (weak, nonatomic) IBOutlet UILabel *lblActivating;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerActivating;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewActivate;

@property (weak, nonatomic) IBOutlet UILabel *lblDownloading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerDownloading;
@property (weak, nonatomic) IBOutlet UIImageView *imgviewDownload;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerMain;

@property (atomic, strong) id <SKAActivationDelegate> delegate;

@property (nonatomic, assign) BOOL hidesBackButton;

- (IBAction)done:(id)sender;

@end

#pragma mark - Delegate

@protocol SKAActivationDelegate

- (void)hasCompleted;

@end

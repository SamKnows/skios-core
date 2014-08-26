//
//  SKAActivationController2.h
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKAAppDelegate.h"

@protocol SKAActivationDelegate;

@interface SKAActivationController2 : UIViewController

@property (strong, nonatomic) UILabel *lTitle;
@property (strong, nonatomic) UILabel *lActivating;
@property (strong, nonatomic) UILabel *lDownloading;

@property (strong, nonatomic) UIActivityIndicatorView *spinnerActivating;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerDownloading;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerMain;

//@property (weak, nonatomic) IBOutlet UILabel *lblMain;
//@property (weak, nonatomic) IBOutlet UIView *viewBG;
//@property (weak, nonatomic) IBOutlet UILabel *lblActivating;
//@property (weak, nonatomic) IBOutlet UIImageView *imgviewActivate;
//@property (weak, nonatomic) IBOutlet UILabel *lblDownloading;
//@property (weak, nonatomic) IBOutlet UIImageView *imgviewDownload;

@property (atomic, strong) id <SKAActivationDelegate> delegate;
@property (nonatomic, assign) BOOL hidesBackButton;

- (IBAction)done:(id)sender;

@end

#pragma mark - Delegate

@protocol SKAActivationDelegate

- (void)hasCompleted;

@end
//
//  SKAAboutController.h
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKAAboutController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *downloadText;
@property (weak, nonatomic) IBOutlet UITextView *uploadText;
@property (weak, nonatomic) IBOutlet UITextView *latencyText;
@property (weak, nonatomic) IBOutlet UITextView *packetLossText;
@property (weak, nonatomic) IBOutlet UITextView *jitterText;

@end

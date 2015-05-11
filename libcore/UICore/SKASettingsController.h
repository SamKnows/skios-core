//
//  SKASettingsController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@interface SKASettingsController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

- (void)showDataCapEditor;

//// Simple labels
//@property (weak, nonatomic) IBOutlet UILabel *lblConfig;
//
//// Data values
//@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
//
//// Optional - not in all storyboards
//@property (weak, nonatomic) IBOutlet UILabel *lblClearAllData;
//@property (weak, nonatomic) IBOutlet UILabel *lblActivate;
//
// OLD app only!
@property (weak, nonatomic) IBOutlet UILabel *uniqueIdLabel;
//
//@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *longitudeValue;
//@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
//@property (weak, nonatomic) IBOutlet UILabel *latitudeValue;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateValue;
//
//// Added for New App
//@property (weak, nonatomic) IBOutlet UILabel *exportResultsLabel;
//@property (weak, nonatomic) IBOutlet UILabel *lblAboutCaption;
//@property (weak, nonatomic) IBOutlet UILabel *lblAboutVersion;

@end

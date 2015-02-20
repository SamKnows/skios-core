//
//  SKASettingsController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>

@interface SKASettingsController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

// Simple labels
@property (weak, nonatomic) IBOutlet UILabel *lblConfig;
@property (weak, nonatomic) IBOutlet UILabel *lblDataCap;
@property (weak, nonatomic) IBOutlet UILabel *lblDataUsage;

// Data values
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet UITextField *txtDataCap;
@property (weak, nonatomic) IBOutlet UILabel *lblDataMB;

// Optional - not in all storyboards
@property (weak, nonatomic) IBOutlet UILabel *lblClearAllData;
@property (weak, nonatomic) IBOutlet UILabel *lblActivate;

- (IBAction)showDataCapEditor:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *datacapSwitch;
- (IBAction)datacapSwitch:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *uniqueIdLabel;

@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeValue;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeValue;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateValue;

// Added for New App
@property (weak, nonatomic) IBOutlet UILabel *exportResultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblAboutCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblAboutVersion;

@end

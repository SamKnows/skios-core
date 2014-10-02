//
//  SKASettingsController.h
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKASettingsController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

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
@end

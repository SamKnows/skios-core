//
//  SKSettingsMgr.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKSettingsMgr.h"
#import "../Reusable/CActionSheet/cActionSheet.h"

@implementation SKSettingsMgr

- (void)intialiseViewOnMasterViewController:(UIViewController*)masterViewController_
{
  self.backgroundColor = [UIColor clearColor];
  
  self.masterViewController = masterViewController_;
  self.masterView = masterViewController_.view;
  
  [self.tDataCapValue setDelegate:self];
  [self.tDataCapValue addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
  
  self.btExport.hidden = ! [[SKAAppDelegate getAppDelegate] supportExportMenuItem];
}

-(void)setColoursAndShowHideElements
{
  self.backgroundColor = [UIColor clearColor];
  
  self.vSmallBackground.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
  self.vSmallBackground.layer.cornerRadius = [cTabController sGet_GUI_MULTIPLIER] * 3;
  self.vSmallBackground.layer.borderWidth = 0.5;
  self.vSmallBackground.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
  
  [cActionSheet formatView:self.btClearDB];
  
  [cActionSheet formatView:self.btExport];
  
  [cActionSheet formatView:self.tDataCapValue];
  self.tDataCapValue.layer.borderWidth = 1;
  self.tDataCapValue.layer.borderColor = [UIColor colorWithRed:26.0/255.0 green:160.0/255.0 blue:225.0/255.0 alpha:0.5].CGColor;
  self.tDataCapValue.textColor = [UIColor colorWithWhite:0.9 alpha:1];
  self.tDataCapValue.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
  self.tDataCapValue.text = @"";
  
  //    [self setTitle:sSKCoreGetLocalisedString(@"SETTINGS_Title")];
  [self.lMonthlyDataCap setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Cap")];
  [self.lCapUsed setText:sSKCoreGetLocalisedString(@"SETTINGS_Data_Usage")];
  self.lMonthlyDataCap.font = [UIFont fontWithName:@"Roboto-Light" size:15];
  self.lCapUsed.font = [UIFont fontWithName:@"Roboto-Light" size:15];
  
  self.lDataUsageValue.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
  self.tDataCapValue.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
  
  [self setDataCapFromUserSettings];
  
  if (self.lClearAllData != nil) {
    self.lClearAllData.text = sSKCoreGetLocalisedString(@"Settings_ClearAllResults");
  }
  
  BOOL canDisableDataCap = [[SKAAppDelegate getAppDelegate] canDisableDataCap];
  BOOL datacapEnabled = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
  
  self.swDataCapOnOff.hidden = !canDisableDataCap;
  self.swDataCapOnOff.on = datacapEnabled;
  self.tDataCapValue.enabled = datacapEnabled;
  
  if (datacapEnabled == YES) {
    self.tDataCapValue.alpha = 1.0;
  } else {
    self.tDataCapValue.alpha = 0.3;
  }

  self.tDataCapValue.delegate = self;
  self.btOK1.alpha = 0;

}

-(void)performLayout
{
  self.vSmallBackground.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, 30, [cTabController sGet_GUI_MULTIPLIER] * 300, 150);
  
  self.btClearDB.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, 200, [cTabController sGet_GUI_MULTIPLIER] * 300, 35);
  
  self.btExport.frame = CGRectMake([cTabController sGet_GUI_MULTIPLIER] * 10, 245, [cTabController sGet_GUI_MULTIPLIER] * 300, 35);
  
  self.tDataCapValue.frame = CGRectMake(187, self.lMonthlyDataCap.frame.origin.y - 5, 90, 26 + 10);
  
  self.btOK1.frame = CGRectMake(257, self.tDataCapValue.frame.origin.y, self.tDataCapValue.frame.size.height, self.tDataCapValue.frame.size.height);
  
  [self setColoursAndShowHideElements];
}

//return sSKCoreGetLocalisedString(@"Storyboard_Settings_Configuration");
//return sSKCoreGetLocalisedString(@"Storyboard_Settings_MonthlyData");
//[self.lblVersion setText:delegate.schedule.scheduleVersion];

//[self.lblConfig setText:sSKCoreGetLocalisedString(@"SETTINGS_Config")]; - out ?

- (void)setDataCapFromUserSettings
{
    int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
    mb = mb / CBytesInAMegabyte;
    [self.tDataCapValue setText:[NSString stringWithFormat:@"%d", (int)mb]];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.btOK1.alpha = 1;
        //self.tDataCapValue.frame = CGRectMake(160, self.lMonthlyDataCap.frame.origin.y - 5, 90, 26 + 10);
    }];
}

-(void)activate
{
    SKAAppDelegate *delegate = (SKAAppDelegate*)[UIApplication sharedApplication].delegate;
    int64_t bytesUsed = [delegate amdGetDataUsageBytes];
    
    NSString *valueString = [SKGlobalMethods bytesToString:(double)bytesUsed];
    [self.lDataUsageValue setText:valueString];
}

- (IBAction)B_OK1:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        [self finishEditingDataCap];
    }];
}

- (IBAction)B_ClearDatabase:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Title")
                          message:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Message")
                          delegate:self
                          cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                          otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),nil];
    alert.tag = ALERT_WIPEDATA;
    [alert show];
}

-(void)finishEditingDataCap
{
    [self.tDataCapValue resignFirstResponder];
    self.btOK1.alpha = 0;
    //self.tDataCapValue.frame = CGRectMake(187, self.lMonthlyDataCap.frame.origin.y - 5, 90, 26 + 10);
}

-(void)deactivate
{
    [UIView animateWithDuration:0.3 animations:^{
        [self finishEditingDataCap];
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_DATACAP) {

//        // after animation
//
//        UITextField *textField = [alertView textFieldAtIndex:0];
//        SK_ASSERT(textField != nil);
//        SK_ASSERT(textField.text != nil);
//
//        NSString *stringValue = textField.text;
//        int64_t value = [stringValue longLongValue];
//
//        self.txtDataCap.text = [NSString stringWithFormat:@"%ld", (long)value];
//
//        [self validateText];

    } else if (alertView.tag == ALERT_WIPEDATA) {
        if (buttonIndex != alertView.cancelButtonIndex) {

            [SKDatabase sEmptyTheDatabase];
            //TODO: It is better to place the notification in the DB Module
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"TestListNeedsUpdate"
             object:self];
            
        }
    } else {
        SK_ASSERT(false);
    }
}

// http://stackoverflow.com/questions/10307561/uikeyboardtypenumberpad-ipad
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSError *error = nil;
    
    if (string.length == 0) return YES;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"^[0-9]$"
                                  options:0
                                  error:&error];
    
    return ([regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)] > 0);
}

-(void)textChanged:(UITextField*)textField
{
    if (textField == self.tDataCapValue)
    {
        if (self.tDataCapValue.text.length > 7) //TODO: Constant
        {
            self.tDataCapValue.text = [self.tDataCapValue.text substringWithRange:NSMakeRange(0, 7)];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
  return YES; // return NO to disallow editing.
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if ([self.tDataCapValue.text length] == 0)
    {
        self.tDataCapValue.text = @"1";
    }
    else
    {
        int64_t value = [self.tDataCapValue.text longLongValue];
        if (value <= 0)
        {
            self.tDataCapValue.text = @"1";
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int64_t theValue = (int64_t)[self.tDataCapValue.text longLongValue];
    theValue *= CBytesInAMegabyte;
    [prefs setObject:[NSNumber numberWithLongLong:theValue] forKey:Prefs_DataCapValueBytes];
    [prefs synchronize];
}

-(IBAction)B_ExportResults:(id)sender
{
  SK_ASSERT ([[SKAAppDelegate getAppDelegate] supportExportMenuItem]);
  
  //TODO: Export body contains "FCC" word
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:sSKCoreGetLocalisedString(@"Export_Title")
                                                  message:sSKCoreGetLocalisedString(@"Export_Body")
                                                 delegate:nil
                                        cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
                                        otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK"),nil];
  
  [alert showWithBlock:^(UIAlertView *inView, NSInteger buttonIndex) {
    int items = 0;
    
    if ([SKAAppDelegate exportArchivedJSONFilesToZip:&items] == NO) {
      UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:sSKCoreGetLocalisedString(@"Export_Failed_Title")
                            message:sSKCoreGetLocalisedString(@"Export_Failed_Body")
                            delegate:nil
                            cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                            otherButtonTitles:nil];
      [alert show];
    } else {
      // Succeeded!
      // If there are no items, tell the user - otherwise, the zip file is malformed!
      if (items == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:sSKCoreGetLocalisedString(@"Export_NoItems_Title")
                              message:sSKCoreGetLocalisedString(@"Export_NoItems_Body")
                              delegate:nil
                              cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                              otherButtonTitles:nil];
        [alert show];
      } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY_MMM_dd_HH_mm_ss"];
        NSString *lpReadableDate = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *lpFileNameWithExtension = [NSString stringWithFormat:@"export_%@.zip",lpReadableDate];
        
        [self launchEmailWithAttachment:@""
                                subject:[NSString stringWithFormat:@"%@ - %@",
                                         sSKCoreGetLocalisedString(@"MenuExport_Mail_Subject"),
                                         lpReadableDate
                                         ]
                               bodyText:[NSString stringWithFormat:@"%@\n\n%@",
                                         sSKCoreGetLocalisedString(@"MenuExport_Mail_Body"),
                                         lpFileNameWithExtension
                                         ]
                           fileToAttach:[SKAAppDelegate getJSONArchiveZipFilePath]
                         attachWithName:lpFileNameWithExtension];
      }
    }
  } cancelBlock:^(UIAlertView *inView) {
    // Nothing to do!
  }];
  
}

- (bool)launchEmailWithAttachment:(NSString *)PpMailAddress subject:(NSString *)PpSubject bodyText:(NSString *)PpBodyText fileToAttach:(NSString *)PFileToAttach attachWithName:(NSString *)inAttachWithName
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:PpSubject];
    [picker setMessageBody:PpBodyText isHTML:NO];
    
    /*
     // Set up the recipients.
     NSArray *toRecipients = [NSArray arrayWithObjects:@"first@example.com",
     nil];
     NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com",
     @"third@example.com", nil];
     NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com",
     nil];
     [picker setToRecipients:toRecipients];
     [picker setCcRecipients:ccRecipients];
     [picker setBccRecipients:bccRecipients];
     */
    
    //  int lItems = (int)PFilesToAttach.count;
    //  int i;
    //  for (i = 0; i < lItems; i++)
    {
        //NSString *theFile = PFilesToAttach[i];
        NSString *theFile = PFileToAttach;
        SK_ASSERT(theFile != nil);
        NSURL *url = [NSURL fileURLWithPath:theFile];
        SK_ASSERT(url != nil);
        NSString *extension = [url pathExtension];
        
        NSString *nsMimeType = @"application/octet-stream";
        
        if ([extension isEqualToString:@"zip"]) {
            nsMimeType = @"application/zip";
        }
        
        // Use an autorelease pool to avoid leaks!
        @autoreleasepool {
            
            //NSData *myData = [NSData dataWithContentsOfFile:PFilesToAttach[i]];
            NSData *myData = [NSData dataWithContentsOfFile:PFileToAttach];
            
            NSString *lpFileNameWithExtension = [[url pathComponents] lastObject];
            
            if (inAttachWithName != nil) {
                lpFileNameWithExtension = inAttachWithName;
            }
            
            [picker addAttachmentData:myData mimeType:nsMimeType fileName:lpFileNameWithExtension];
        }
    }
    
    // Present the mail composition interface.
    [self.masterViewController presentModalViewController:picker animated:YES];
    // Can safely release the controller now.
    
    return true;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)datacapSwitch:(id)sender {
//    [[SKAAppDelegate getAppDelegate] setIsDataCapEnabled:self.datacapSwitch.on];
//
//    BOOL datacapEnabledNow = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
//
//    if (datacapEnabledNow == YES) {
//        self.txtDataCap.alpha = 1.0;
//    } else {
//        self.txtDataCap.alpha = 0.3;
//    }
//}

//enum {
//    ALERT_DATACAP = 1,
//    ALERT_WIPEDATA = 2,
//};

//- (IBAction)showDataCapEditor:(id)sender {
//
//    BOOL datacapEnabled = [[SKAAppDelegate getAppDelegate] isDataCapEnabled];
//    if (datacapEnabled == NO) {
//        // Datacap not enabled - don't allow editing!
//        return;
//    }
//
//    UIAlertView *alert =
//    [[UIAlertView alloc]
//     initWithTitle:sSKCoreGetLocalisedString(@"Title_MonthlyDataCap")
//     message:nil
//     delegate:self
//     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
//     otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK",nil), ];
//    alert.tag = ALERT_DATACAP;
//
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    UITextField *textField = [alert textFieldAtIndex:0];
//
//    textField.keyboardType = UIKeyboardTypeNumberPad;
//    // http://stackoverflow.com/questions/10307561/uikeyboardtypenumberpad-ipad
//    textField.delegate = self;
//
//    int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
//
//    mb = mb / CBytesInAMegabyte;
//
//    textField.text = [NSString stringWithFormat:@"%d", (int)mb];
//    textField.placeholder = sSKCoreGetLocalisedString(@"Settings_DataCap_Placeholder");
//
//    [alert show];
//}

//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//    cell.selected = NO;
//    if ([cell.reuseIdentifier isEqualToString:@"clear_all_results"]) {
//        // Optionally - clear the database - TODO!
//        NSLog(@"TODO - optionally, clear the database!");
//
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Title")
//                              message:sSKCoreGetLocalisedString(@"Settings_ClearAllResults_Message")
//                              delegate:self
//                              cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_Cancel")
//                              otherButtonTitles:sSKCoreGetLocalisedString(@"MenuAlert_OK",nil),];
//        alert.tag = ALERT_WIPEDATA;
//        [alert show];
//    } else if ([cell.reuseIdentifier isEqualToString:@"activate"]) {
//        [SKAAppDelegate setIsActivated:NO];
//        [self SKSafePerformSegueWithIdentifier:@"segueToActivateFromSettings" sender:self];
//    }
//}
@end

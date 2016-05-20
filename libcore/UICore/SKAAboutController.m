//
//  SKAAboutController.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKAAboutController.h"

@interface SKAAboutController ()

@end

@implementation SKAAboutController

#pragma mark - View Cycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (self.versionLabel != nil) {
    // Old-style About screen...
    
    NSString *appVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *bundleVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *displayVersion = [NSString stringWithFormat:@"%@: %@.%@", sSKCoreGetLocalisedString(@"About_Version"), appVersion, bundleVersion];
    self.versionLabel.text = displayVersion;
  }
  //self.title = sSKCoreGetLocalisedString(@"Storyboard_About_Title");
  //self.title = [NSString stringWithFormat:@"%@ %@", sSKCoreGetLocalisedString(@"Storyboard_About_Section_AppName"), displayVersion];,
  // "About MyAppName"
  self.title = [NSString stringWithFormat:@"%@ %@", sSKCoreGetLocalisedString(@"Storyboard_About_Title"),sSKCoreGetLocalisedString(@"Storyboard_About_Section_AppName")];
  
  self.downloadText.text = sSKCoreGetLocalisedString(@"Storyboard_About_Text_Download");
  self.uploadText.text = sSKCoreGetLocalisedString(@"Storyboard_About_Text_Upload");
  self.latencyText.text = sSKCoreGetLocalisedString(@"Storyboard_About_Text_Latency");
  self.packetLossText.text = sSKCoreGetLocalisedString(@"Storyboard_About_Text_PacketLoss");
  if (self.jitterText != nil) {
    self.jitterText.text = sSKCoreGetLocalisedString(@"Storyboard_About_Text_Jitter");
  }

}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section) {
  case 0:
    return sSKCoreGetLocalisedString(@"Storyboard_About_Section_Download"); // "Download"

  case 1:
    return sSKCoreGetLocalisedString(@"Storyboard_About_Section_Upload"); // "Upload"

  case 2:
    return sSKCoreGetLocalisedString(@"Storyboard_About_Section_Latency"); // "Latency"

  case 3:
    return sSKCoreGetLocalisedString(@"Storyboard_About_Section_PacketLoss"); // "Packet Loss"

  case 4:
    return sSKCoreGetLocalisedString(@"Storyboard_About_Section_Jitter"); // "Jitter"

  default:
    break;
  }

  SK_ASSERT(false);
  return nil;
}

@end

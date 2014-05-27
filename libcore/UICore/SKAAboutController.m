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
  
  self.title = NSLocalizedString(@"Storyboard_About_Title",nil);
  
  self.downloadText.text = NSLocalizedString(@"Storyboard_About_Text_Download",nil);
  self.uploadText.text = NSLocalizedString(@"Storyboard_About_Text_Upload",nil);
  self.latencyText.text = NSLocalizedString(@"Storyboard_About_Text_Latency",nil);
  self.packetLossText.text = NSLocalizedString(@"Storyboard_About_Text_PacketLoss",nil);
  if (self.jitterText != nil) {
    self.jitterText.text = NSLocalizedString(@"Storyboard_About_Text_Jitter",nil);
  }

  NSString *appVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  NSString *bundleVersion = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString *displayVersion = [NSString stringWithFormat:@"%@: %@.%@", NSLocalizedString(@"About_Version",nil), appVersion, bundleVersion];
  self.versionLabel.text = displayVersion;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBarHidden = NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  switch (section)
  {
    case 0:
    return NSLocalizedString(@"Storyboard_About_Section_AppName",nil); // "My Speed Test"
    
    case 1:
    return NSLocalizedString(@"Storyboard_About_Section_Download",nil); // "Download"
       
    case 2:
    return NSLocalizedString(@"Storyboard_About_Section_Upload",nil); // "Upload"
       
    case 3:
    return NSLocalizedString(@"Storyboard_About_Section_Latency",nil); // "Latency"
    
    case 4:
    return NSLocalizedString(@"Storyboard_About_Section_PacketLoss",nil); // "Packet Loss"
    
    case 5:
    return NSLocalizedString(@"Storyboard_About_Section_Jitter",nil); // "Jitter"
  }
  
  SK_ASSERT(false);
  return nil;
}

@end

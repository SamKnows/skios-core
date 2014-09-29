//
//  SKBSettingsViewController.h
//  SKCore
//
//  Created by Pete Cole on 29/09/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKSettingsMgr;

@interface SKBSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet SKSettingsMgr *settingsManagerView;

@end

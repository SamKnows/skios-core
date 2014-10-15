//
//  SKBSettingsTabViewController.m
//  SKCore
//
//  Created by Pete Cole on 15/10/2014.
//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKBSettingsTabViewController.h"

@interface SKBSettingsTabViewController ()

@end

@implementation SKBSettingsTabViewController

-(void) viewDidLoad {
  [super viewDidLoad];
  
  // The main background view...
  //self.view.backgroundColor = [UIColor clearColor];
  ((UIViewWithGradient*)self.view).innerColor = [SKAppColourScheme sGetInnerColor];
  ((UIViewWithGradient*)self.view).outerColor = [SKAppColourScheme sGetOuterColor];
}

@end

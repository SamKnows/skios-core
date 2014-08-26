//
//  SKMainViewController.m
//  SKCore
//

//  Copyright (c) 2014 SamKnows. All rights reserved.
//

#import "SKMainViewController.h"

@interface SKMainViewController ()

@end

@implementation SKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Brazilian
//    self.vC1.innerColor = [UIColor colorWithRed:56.0/255.0 green:53.0/255.0 blue:137.0/255.0 alpha:1];
//    self.vC1.outerColor = [UIColor colorWithRed:4.0/255.0 green:16.0/255.0 blue:91.0/255.0 alpha:1];

    //SamKnows
    self.vC1.innerColor = [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:227.0/255.0 alpha:1];
    self.vC1.outerColor = [UIColor colorWithRed:37.0/255.0 green:82.0/255.0 blue:164.0/255.0 alpha:1];
    
    self.vC2.innerColor = [UIColor colorWithRed:35.0/255.0 green:60.0/255.0 blue:200.0/255.0 alpha:1];
    self.vC2.outerColor = [UIColor colorWithRed:25.0/255.0 green:40.0/255.0 blue:120.0/255.0 alpha:1];
    
    self.vC3.innerColor = [UIColor colorWithRed:120.0/255.0 green:109.0/255.0 blue:227.0/255.0 alpha:1];
    self.vC3.outerColor = [UIColor colorWithRed:30.0/255.0 green:28.0/255.0 blue:64.0/255.0 alpha:1];
    
    self.vC4.innerColor = [UIColor colorWithRed:0 green:102.0/255.0 blue:255.0/255.0 alpha:1];
    self.vC4.outerColor = [UIColor colorWithRed:0 green:58.0/255.0 blue:145.0/255.0 alpha:1];
//    self.vC4.innerColor = [UIColor colorWithRed:200.0/255.00 green:0/255.0 blue:0/255.0 alpha:1];
//    self.vC4.outerColor = [UIColor colorWithRed:100.0/255.00 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    
    self.vC5.innerColor = [UIColor colorWithRed:56.0/255.0 green:53.0/255.0 blue:137.0/255.0 alpha:1];
    self.vC5.outerColor = [UIColor colorWithRed:4.0/255.0 green:16.0/255.0 blue:91.0/255.0 alpha:1];
    
    self.vHistory.masterViewController = self;
    self.vSettings.masterViewController = self;

    self.tabController = [cTabController globalInstance];
    [self.tabController initOnMasterView:self.view withContentsView:self.svContent andTabView:self.vTab andNumberOfOptions:5];
    
    [self.tabController addView:self.vRun withTitle:@"Test" andImage:[UIImage imageNamed:@"tab_home"] andColorView:self.vC1];
    [self.tabController addView:self.vHistory withTitle:@"Results" andImage:[UIImage imageNamed:@"tab_history"] andColorView:self.vC2];
    [self.tabController addView:self.vSummary withTitle:@"Summary" andImage:[UIImage imageNamed:@"tab_summary"] andColorView:self.vC3];
    [self.tabController addView:self.vSettings withTitle:@"Settings" andImage:[UIImage imageNamed:@"tab_settings"] andColorView:self.vC4];
    [self.tabController addView:self.vInfo withTitle:@"Info" andImage:[UIImage imageNamed:@"tab_info"] andColorView:self.vC5];
    
    [self.tabController performLayout];
    
    self.svContent.hidden = YES;
    self.vTab.hidden = YES;
    
    tmpActivated = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.vWelcomeView.frame = self.view.bounds;
    [self.vWelcomeView initializeWelcomeText];
    
//    if (!tmpActivated) return;
//    if (![[SKAAppDelegate getAppDelegate] isActivated]) return;
    
    self.svContent.hidden = NO;
    self.vTab.hidden = NO;
    if (isWelcomePerformed) self.vWelcomeView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (isWelcomePerformed) //Came back from activation
    {
        
    }
    else
    {
        isWelcomePerformed = YES;
        [self.vWelcomeView startAnimationOnCompletion:^{
            
            if (!tmpActivated)
            {
                tmpActivated = YES;
                [self SKSafePerformSegueWithIdentifier:@"segueActivate" sender:self];
                return;
            }
            if (![[SKAAppDelegate getAppDelegate] isActivated])
            {
                NSLog(@"Not");
                [self performSegueWithIdentifier:@"segueActivate" sender:self];
                return;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.vWelcomeView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                self.vWelcomeView.hidden = YES;
                
            }];
        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.vWelcomeView.hidden = YES;
}

- (IBAction)B_Layout:(id)sender {

}

@end

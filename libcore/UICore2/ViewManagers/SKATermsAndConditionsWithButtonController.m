//
//  SKATermsAndConditionsWithButtonController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKATermsAndConditionsWithButtonController.h"
#import "SKBActivationController.h"
#import "SKAActivationController.h"

@interface SKATermsAndConditionsWithButtonController()
//@property UIWebView* webView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *agreeButton;
@end

@implementation SKATermsAndConditionsWithButtonController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //self.title = sSKCoreGetLocalisedString(@"Storyboard_Terms_Title");
  self.title = sSKCoreGetLocalisedString(@"terms_of_use_title");
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  SK_ASSERT(self.webView != nil);
  NSString *resource = @"terms_of_use";
  NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"htm"];
  NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  
  [self.webView.scrollView setBounces:NO];
  [self.webView setDataDetectorTypes:UIDataDetectorTypeNone];
  [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
  
  self.webView.scalesPageToFit = [[SKAppBehaviourDelegate sGetAppBehaviourDelegate] getCanUserZoomTheTAndCView];
}

- (void)moveToActivationOrMainScreen
{
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isActivationSupported] == NO) {
    // Activation not required - return automatically to the main screen!
    [SKAAppDelegate sResetUserInterfaceBackToMainScreen];
  } else {
    // Activation required!
    [self SKSafePerformSegueWithIdentifier:@"segueToActivation" sender:self];
  }
}

- (IBAction)agreeButton:(id)sender {

  SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  if ([[SKAppBehaviourDelegate sGetAppBehaviourDelegate] isActivationSupported] == NO) {
    // Activation not required - so, we don't need to be online to continue...
  } else if ([appDelegate getIsConnected] == NO) {
    // On test stopped - if not connected, display an alert.
    // This covers e.g. if we lost connection and tests stopped automatically.
    // It will also stop a test re-running in the event of continuous testing.
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:nil
                               message:sSKCoreGetLocalisedString(@"Offline_message")
                              delegate:nil
                     cancelButtonTitle:sSKCoreGetLocalisedString(@"MenuAlert_OK")
                     otherButtonTitles: nil];
    
    [alert show];
    
    return;
  }
 
  // We've agreed to terms. Continue to activation (if required), or reurn to main screen.
  [SKAppBehaviourDelegate setHasAgreed:YES];
  [self performSelector:@selector(moveToActivationOrMainScreen) withObject:nil afterDelay:0.1];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.title = sSKCoreGetLocalisedString(@"Storyboard_Terms_Title");
 
  // Depending on if we're navigated to, or at start-up ...
  // show the "Agree" button which takes us to Activation!
  SKAppBehaviourDelegate *appDelegate = [SKAppBehaviourDelegate sGetAppBehaviourDelegate];
  
  BOOL bHideButton;
  if ([appDelegate getIsThisTheNewApp]) {
    bHideButton = [appDelegate hasNewAppAgreed];
  } else {
    bHideButton = [appDelegate hasAgreed];
  }
  
  if (bHideButton == YES) {
    //  UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    //  [backButton setImage:img forState:UIControlStateNormal];
    //  [backButton addTarget:self action:@selector(goToMain) forControlEvents:UIControlEventTouchDown];
    //
    //  UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //
    self.navigationItem.rightBarButtonItem = nil;
  } else {
    NSString *agreeButtonTitle = sSKCoreGetLocalisedString(@"I Agree");
    UIBarButtonItem *theAgreeButton = [[UIBarButtonItem alloc] initWithTitle:agreeButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(agreeButton:)];
    SK_ASSERT(self.navigationItem != nil);
    self.navigationItem.rightBarButtonItem = theAgreeButton;
  }
  
  SK_ASSERT(self.navigationController != nil);
  SK_ASSERT(self.navigationItem != nil);
  self.edgesForExtendedLayout = UIRectEdgeNone;
  self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"segueToActivation"]) {
   
#ifdef DEBUG
    NSLog(@"segue.destinationVieController=%@", [segue.destinationViewController description]);
#endif // DEBUG
    
    if ([segue.destinationViewController isKindOfClass:SKBActivationController.class]) {
      SKBActivationController *vc = (SKBActivationController*)segue.destinationViewController;
      vc.hidesBackButton = YES;
    }
  }
  
}

@end

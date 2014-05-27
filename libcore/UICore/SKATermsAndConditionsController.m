//
//  SKATermsAndConditionsController.m
//  SKA
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKATermsAndConditionsController.h"
#import "SKAAppDelegate.h"

@interface SKATermsAndConditionsController ()
@property BOOL hasFinished;

- (void)setContext;
- (void)setTitleLabel;
- (void)displayMessage:(NSString*)msg;
- (void)moveToNextScreen;
- (void)moveToActivationScreen;
- (void)showInformation:(int)screenIndex messageIndex:(int)messageIndex;

@end

@implementation SKATermsAndConditionsController

@synthesize hasFinished;
@synthesize index;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = NSLocalizedString(@"Storyboard_Terms_Title",nil);
  self.dataLabel.text = NSLocalizedString(@"Storyboard_Terms_DataLabel",nil);
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
 
  hasFinished = NO;
  
  //[self.navigationItem setHidesBackButton:self.hidesBackButton];
  
  [self addBackButton];
  [self setContext];
  [self setTitleLabel];
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  NSString *resource = [NSString stringWithFormat:@"notice%d", index+1];
  NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"htm"];
  NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
  
  [self.webView.scrollView setBounces:NO];
  [self.webView setDataDetectorTypes:UIDataDetectorTypeNone];
  [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  if (hasFinished)
  {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [SKAAppDelegate resetUserInterfaceBackToRunTestsScreenFromViewController];
  }
}

- (void)addBackButton
{
//  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                        [UIColor whiteColor],UITextAttributeTextColor,
//                        [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:12.0],UITextAttributeFont,
//                        nil];
//  
//  [[UIBarButtonItem appearance] setTitleTextAttributes:dict forState:UIControlStateNormal];
  
  // Back button name set in storyboard - see:
  // http://stackoverflow.com/questions/9871578/how-to-change-the-uinavigationcontroller-back-button-name
}


- (void)setContext
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  self.lblMain.text = (index == 2) ? NSLocalizedString(@"TC_Label_Data", nil) : NSLocalizedString(@"TC_Label", nil);
  
  if (index == 2)
  {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
    CGRect frmWeb = self.webView.frame;
    frmWeb.origin.y = self.viewDataCollector.frame.origin.y + self.viewDataCollector.frame.size.height;
    frmWeb.size.height = frmWeb.size.height - self.viewDataCollector.frame.size.height;
    self.webView.frame = frmWeb;
    
    int64_t mb = [[[NSUserDefaults standardUserDefaults] objectForKey:Prefs_DataCapValueBytes] longLongValue];
    SK_ASSERT(mb >= 0);
    
    mb = mb / CBytesInAMegabyte;
    
    SK_ASSERT(mb >= 0);
    
    self.txtData.text = [NSString stringWithFormat:@"%d", (int)mb];
  }
}

- (void)setTitleLabel
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,45,45)];
  label.font = [[SKAAppDelegate getAppDelegate] getSpecialFontOfSize:17];
  label.textColor = [UIColor blackColor];
  
  label.backgroundColor = [UIColor clearColor];
  label.text = NSLocalizedString(@"TC_Title", nil);
  [label sizeToFit];
  self.navigationItem.titleView = label;
}

- (void)displayMessage:(NSString*)msg
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"MenuAlert_OK",nil)
                                        otherButtonTitles: nil];
  [alert show];
}

#pragma mark - Activation Delegate

- (void)hasCompleted
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  hasFinished = YES;
}

-(void) validateText {
  
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  if ([self.txtData.text length] == 0)
  {
    self.txtData.text = @"1";
  }
  else
  {
    int64_t value = [self.txtData.text longLongValue];
    
    if (value <= 0)
    {
      self.txtData.text = @"1";
    }
  }
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  int64_t theValue = (int64_t)[self.txtData.text longLongValue];
  theValue *= CBytesInAMegabyte;
  [prefs setObject:[NSNumber numberWithLongLong:theValue] forKey:Prefs_DataCapValueBytes];
  [prefs synchronize];
}

#pragma mark - Resign Responder

- (IBAction)txtFieldDoneEditing:(id)sender
{
	[sender resignFirstResponder];
  
  [self validateText];
}

- (IBAction)ctlBackgroundTap:(id)sender
{
	[self.txtData resignFirstResponder];
  
  [self validateText];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self validateText];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  // NSLog(@"MPC error: %@", [error description]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  // NSLog(@"MPC request.URL.schemd=%@", request.URL.scheme);
  
  if ([request.URL.scheme isEqualToString:@"inapp"])
  {
    // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
    
    NSString *host = request.URL.host;
    
    if ([host hasPrefix:@"msg"])
    {
      // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
      
      NSRange range = [host rangeOfString:@"_"];
      int msgIdx = [[host substringFromIndex:range.location+1] intValue];
      [self showInformation:index messageIndex:msgIdx];
    }
    else if ([host hasPrefix:@"move"])
    {
      // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
      
      if ([host hasSuffix:@"next"])
      {
        [self performSelector:@selector(moveToNextScreen) withObject:nil afterDelay:0.1];
      }
      else if ([host hasSuffix:@"agree"])
      {
        if (!hasFinished)
        {
          // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
          NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
          [prefs setObject:[SKCore getToday] forKey:Prefs_DataDate];
          [prefs synchronize];
          
          [SKAAppDelegate setHasAgreed:YES];
          [self performSelector:@selector(moveToActivationScreen) withObject:nil afterDelay:0.1];
        }
        else
        {
          // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
          [self displayMessage:NSLocalizedString(@"TC_App_Activated", nil)];
        }
      }
    }
    
    return NO;
  }
  
  return YES;
}

#pragma mark - Move to next T&C screen

- (void)moveToNextScreen
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  //[NSException raise:NSInvalidArgumentException format:@"This is a test exception thrown by Pete, in moveToNextScreen!"];
  
  // This is how you perform a seque to self with a storyboard...
  // http://stackoverflow.com/questions/9226983/storyboard-segue-from-view-controller-to-itself
  UIStoryboard *storyboard = [SKAAppDelegate getStoryboard];
  SKATermsAndConditionsController *dest = [storyboard instantiateViewControllerWithIdentifier:@"SKATermsAndConditionsController"];
  dest.index = self.index+1;
  
  @try {
    [self.navigationController pushViewController:dest animated:YES];
  } @catch (NSException *ex) {
    if ([ex.name isEqualToString:NSInvalidArgumentException]) {
#ifdef DEBUG
      NSLog(@"DEBUG: WARNING: Trapped rare runtime error on iOS - see the documentaiton for pushViewController ...");
#endif //  DEBUG
      SK_ASSERT(false);
    } else {
      @throw ex;
    }
  }
}

- (void)moveToActivationScreen
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  [self performSegueWithIdentifier:@"segueToActivation" sender:self];
  //SKAActivationController *cnt = [[SKAActivationController alloc] initWithNibName:@"SKAActivationController" bundle:nil];
  //[cnt setDelegate:self];
  //[cnt setHidesBackButton:YES];
  //[self.navigationController pushViewController:cnt animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  // NSLog(@"MPC segue.identifer=%@", segue.identifier);
  
  if ([segue.identifier isEqualToString:@"segueToActivation"]) {
    
    UINavigationController *nc = (UINavigationController*)segue.destinationViewController;
    SKAActivationController *cnt = (SKAActivationController*)nc.viewControllers[0];
    [cnt setDelegate:self];
    
  } else {
    SK_ASSERT(false);
  }
  
}

#pragma mark - Show Information

- (void)showInformation:(int)screenIndex messageIndex:(int)messageIndex
{
  // NSLog(@"MPC %s %d", __FUNCTION__, __LINE__);
  
  NSString *idx = [NSString stringWithFormat:@"Msg_%d_%d", screenIndex, messageIndex];
  
  [self displayMessage:NSLocalizedString(idx, nil)];
}

@end

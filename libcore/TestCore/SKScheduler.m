//
//  SKScheduler.m
//  SamKnows
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

@interface SKScheduler ()

// PRIVATE properties.
//@property UIBackgroundTaskIdentifier btid;

@end

@implementation SKScheduler

//@synthesize btid;
@synthesize xmlData;
@synthesize scheduleVersion;
@synthesize submit_dcs;
@synthesize tests_alarm_type;
@synthesize location_service;
@synthesize onfail_test_action;
@synthesize dataCapMB;
@synthesize original_tests;
@synthesize communications;
@synthesize hosts;
@synthesize data_collector;
@synthesize conditions;
@synthesize tests;
@synthesize displayTests;
@synthesize bShouldRunAutoTests;

#pragma mark - Init

- (id)initWithXmlData:(NSData*)xmlData_
{
  self = [super init];
  
  if (self)
  {
    SK_ASSERT(bShouldRunAutoTests == NO);
    
    //NSString *myString1 = [[NSString alloc] initWithData:xmlData_ encoding:NSUTF8StringEncoding];
    //NSLog(@"xmlData_ = %@", myString1);
    
    xmlData = [[NSData alloc] initWithData:xmlData_];
    
    //NSString *myString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    //NSLog(@"xmlData = %@", myString);
    
    [self populateFromXml:xmlData];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(memoryWarning:)
//                                                 name:UIApplicationDidReceiveMemoryWarningNotification
//                                               object:nil];
    
    //        [[NSNotificationCenter defaultCenter] addObserver:self 
    //                                                 selector:@selector(autoTestingChanged:) 
    //                                                     name:@"AutoTestingChanged"
    //                                                   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadCompleted:)
                                                 name:@"UploadComplete"
                                               object:nil];
  }
  
  return self;
}

#pragma mark - Notifications

- (void)uploadCompleted:(NSNotification*)notification
{    
  //    if (btid != UIBackgroundTaskInvalid) {
  //        [[UIApplication sharedApplication] endBackgroundTask:btid];
  //        btid = UIBackgroundTaskInvalid;
  //    }
}

//- (void)autoTestingChanged:(NSNotification*)notification
//{
//}

//#pragma mark - HTTP Test Method
//
//- (void)testDidFail
//{
//  NSLog(@"Closest Target Test Did Fail");
//}
//
//- (void)didCompleteTest:(NSString*)target latency:(double)latency
//{
//  NSLog(@"Closest Target Test Did Complete : %@ latency=%g", target, latency);
//}
//
//- (void)didSendPacket:(NSUInteger)bytes
//{
//}

#pragma mark - Methods

- (NSArray*)getArrayOfTests
{
  return tests;
}

- (NSString*)getClosestTargetName:(NSString*)dns
{
  if (hosts == nil) {
    SK_ASSERT(false);
    return dns;
  }
  
  if ([hosts count] == 0) {
    SK_ASSERT(false);
    return dns;
  }
  
  bool bFound = false;
  NSString *result = nil;
  for (int m=0; m<[hosts count]; m++)
  {
    if (bFound) {
      break;
    }
    NSDictionary *dict = hosts[m];
    
    if (nil != dict)
    {
      if (dict[@"dns_name"] && dict[@"display_name"])
      {
        NSString *dns_name = dict[@"dns_name"];
        NSString *display_name = dict[@"display_name"];
        
        if ([dns isEqualToString:dns_name])
        {
          bFound = true;
          result = display_name;
        }
      }
    }
  }
  
  if (bFound)
  {
    return result;
  }
 
  // To reach here, we couldn't find a suitable display name!
  // Return the original name (typically: an IP address)
  //SK_ASSERT(false);
  
  return dns;
}

//- (int)getDisplayTestCount
//{
//    if (nil == displayTests)
//    {
//        return 0;
//    }
//    else 
//    {
//        return [displayTests count];
//    }
//}
//
//- (NSDictionary*)getTestCellInfo:(int)index
//{
//    if ([self getDisplayTestCount] > 0)
//    {
//        NSDictionary *dict = [displayTests objectAtIndex:index];
//        
//        if (nil != dict)
//        {
//            SKTestConfig *test = [[SKTestConfig alloc] initWithDictionary:dict];
//            
//            if (test)
//            {
//                int nThreads = 0;
//                
//                if ([test paramObjectForKey:@"numberofthreads"])
//                {
//                    nThreads = [[test paramObjectForKey:@"numberofthreads"] intValue]; 
//                }
//                
//                NSDictionary *td = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                    test.displayName, @"displayName",
//                                    test.type, @"type",
//                                    [NSNumber numberWithInt:nThreads], @"numberofthreads", nil];
//                
//                return td;
//            }
//            
//            return nil;
//        }
//    }
//    
//    return nil;
//}

- (SKTestConfig*)getTestConfig:(NSString*)type_
{
  if (tests == nil) {
    return nil;
  }
  
  if ([tests count] == 0) {
    return nil;
  }

  for (int j=0; j<[tests count]; j++)
  {
    NSDictionary *dict = tests[j];
    
    if (nil != dict)
    {
      if (dict[@"type"])
      {
        NSString *type = dict[@"type"];
        
        if ([type isEqualToString:type_])
        {
          SKTestConfig *test = [[SKTestConfig alloc] initWithDictionary:dict];
          return test;
        }
      }
    }
  }
  
  return nil;
}

- (SKTestConfig*)getTestConfig:(NSString*)type_ name:(NSString*)name_
{
  if (tests == nil) {
    return nil;
  }
  
  if ([tests count] == 0) {
    return nil;
  }
  
  for (int j=0; j<[tests count]; j++)
  {
    NSDictionary *dict = tests[j];
    
    if (nil != dict)
    {
      if (dict[@"type"] && dict[@"displayName"])
      {
        NSString *type = dict[@"type"];
        NSString *displayName = dict[@"displayName"];
        
        if ([type isEqualToString:type_] && [displayName isEqualToString:name_])
        {
          SKTestConfig *test = [[SKTestConfig alloc] initWithDictionary:dict];                    
          return test;
        }
      }
    }
  }
  
  return nil;
}

- (BOOL)hasValidInitTests
{
  BOOL result = NO;
  
  if (self.original_tests != nil)
  {
    if ([self.original_tests count] > 0)
    {
      result = YES;
    }
  }
  return result;
}

- (int)getInitTestCount
{
  int result = 0;
  
  if (self.original_tests != nil)
  {
    result = (int)[self.original_tests count];
  }
  
  return result;
}

- (NSString*)getInitTestName:(int)index
{
  return original_tests[index];
}

- (NSDictionary*)getCommunication:(NSString*)id_
{
  NSDictionary *dict = nil;
  
  if (nil != communications)
  {
    if ([communications count] > 0)
    {
      for (int j=0; j<[communications count]; j++)
      {
        dict = communications[j];
        
        if (dict[@"id"])
        {
          NSString *theId = dict[@"id"];
          
          if ([theId isEqualToString:id_])
          {
            break;
          }
        }
      }
    }
  }
  
  if (dict)
  {
    //NSLog(@"COMMS : %@", dict);
  }
  
  return dict;
}

- (NSString*)parseTime:(NSString*)time
{
  if (nil == time) return @"0";
  if ([time length] == 0) return @"0";
  
  if ([time hasSuffix:@"s"])
  {
    NSRange range = [time rangeOfString:@"s"];
    NSString *sTime = [time substringToIndex:range.location];
    
    return sTime;
  }
  else if ([time hasSuffix:@"m"]) 
  {
    NSRange range = [time rangeOfString:@"m"];
    NSString *t = [time substringToIndex:range.location];
    
    int mTime = [t intValue] * 60;
    NSString *sTime = [NSString stringWithFormat:@"%d", mTime];
    
    return sTime;
  }
  else if ([time hasSuffix:@"h"])
  {
    NSRange range = [time rangeOfString:@"h"];
    NSString *t = [time substringToIndex:range.location];
    
    int hTime = [t intValue] * 60 * 60;
    NSString *sTime = [NSString stringWithFormat:@"%d", hTime];
    
    return sTime;
  }
  else if ([time hasSuffix:@"d"]) 
  {
    NSRange range = [time rangeOfString:@"d"];
    NSString *t = [time substringToIndex:range.location];
    
    int dTime = [t intValue] * 60 * 60 * 24;
    NSString *sTime = [NSString stringWithFormat:@"%d", dTime];
    
    return sTime;
  }
  
  return @"0";
}

#pragma mark - Main XML Population Method

-(BOOL) shouldSortTests {
  return NO;
}

-(BOOL) shouldStoreScheduleVersion {
  return YES;
}

- (void)populateFromXml:(NSData*)xmlData_
{
  if (nil == xmlData_) return;
  if ([xmlData_ length] == 0) return;
	
  NSError *error;
	SMXMLDocument *document = [SMXMLDocument documentWithData:xmlData_ error:&error];
  
  if (error)
  {
    NSLog(@"Error while parsing the document: %@", error);
    return;
  }
  
  // NSString* newStr = [[NSString alloc] initWithData:xmlData_ encoding:NSUTF8StringEncoding];
  // NSLog(@"XML : %@", newStr);
  
  SMXMLElement *elemGlobal = [document.root childNamed:@"global"];
  if (nil != elemGlobal)
  {
    if ([self shouldStoreScheduleVersion] == YES)
    {
      if ([elemGlobal childNamed:@"schedule-version"])
      {
        scheduleVersion = [[NSString alloc] initWithString:[[elemGlobal childNamed:@"schedule-version"] attributeNamed:@"value"]];
      }
    }
    
    if ([elemGlobal childNamed:@"submit-dcs"])
    {
      submit_dcs = [[NSString alloc] initWithString:[[elemGlobal childNamed:@"submit-dcs"] attributeNamed:@"host"]];
    }
    
    if ([elemGlobal childNamed:@"tests-alarm-type"])
    {
      tests_alarm_type = [[NSString alloc] initWithString:[[elemGlobal childNamed:@"tests-alarm-type"] attributeNamed:@"type"]];
    }
    
    if ([elemGlobal childNamed:@"location-service"])
    {
      location_service = [[NSString alloc] initWithString:[[elemGlobal childNamed:@"location-service"] attributeNamed:@"type"]];
    }
    
    if ([elemGlobal childNamed:@"onfail-test-action"])
    {
      NSString *delay = [self parseTime:[[elemGlobal childNamed:@"onfail-test-action"] attributeNamed:@"delay"]];
      
      onfail_test_action = [@{@"type" : [[elemGlobal childNamed:@"onfail-test-action"] attributeNamed:@"type"],
              @"delay" : delay} mutableCopy];
    }
    
    if ([elemGlobal childNamed:@"data-cap-default"])
    {
      NSString *cap = [[elemGlobal childNamed:@"data-cap-default"] attributeNamed:@"value"];
      dataCapMB = [cap longLongValue];
    }
    else
    {
      dataCapMB = 0;
    }
    
    
    SMXMLElement *elemComms = [elemGlobal childNamed:@"communications"];
    if (nil != elemComms)
    {
      NSArray *comms = [elemComms childrenNamed:@"communication"];
      
      if (nil != comms)
      {
        communications = [[NSMutableArray alloc] init];
        
        for (int j=0; j<[comms count]; j++)
        {
          SMXMLElement *com = comms[j];
          
          if (nil != com)
          {
            if ([com attributeNamed:@"id"] && [com attributeNamed:@"type"] && [com attributeNamed:@"content"])
            {
              NSString *comId = [com attributeNamed:@"id"];
              NSString *comType = [com attributeNamed:@"type"];
              NSString *comContent = [com attributeNamed:@"content"];
              
              NSMutableDictionary *comDict = [[NSMutableDictionary alloc] init];
              comDict[@"id"] = comId;
              comDict[@"type"] = comType;
              comDict[@"content"] = comContent;
              
              [communications addObject:comDict];
            }
          }
        }
      }
    }
    
//    SMXMLElement *elemInit = [elemGlobal childNamed:@"init"];
//    if (nil != elemInit)
//    {
//      NSArray *initTests = [elemInit childrenNamed:@"test"];
//      
//      if (nil != initTests)
//      {
//        original_tests = [[NSMutableArray alloc] init];
//        
//        for (int j=0; j<[initTests count]; j++)
//        {
//          SMXMLElement *test = [initTests objectAtIndex:j];
//          
//          if (nil != test)
//          {
//            NSString *testType = [test attributeNamed:@"type"];
//            
//            if (nil != testType)
//            {
//              [original_tests addObject:testType];
//            }
//          }
//        }
//      }
//    }
    
    SMXMLElement *elemHosts = [elemGlobal childNamed:@"hosts"];
    if (nil != elemHosts)
    {
      NSArray *tmpHosts = [elemHosts childrenNamed:@"host"];
      
      if (nil != tmpHosts)
      {
        hosts = [[NSMutableArray alloc] init];
        
        for (int j=0; j<[tmpHosts count]; j++)
        {
          SMXMLElement *host = tmpHosts[j];
          
          if (nil != host)
          {
            NSString *dnsName = [host attributeNamed:@"dnsName"];
            NSString *displayName = [host attributeNamed:@"displayName"];
            
            if (nil != dnsName && nil != displayName)
            {
              NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
              dict[@"dns_name"] = dnsName;
              dict[@"display_name"] = displayName;
              [hosts addObject:dict];
              dict = nil;
            }
          }
        }
      }
    }
    
    SMXMLElement *elemCollector = [document.root childNamed:@"data-collector"];
    if (nil != elemCollector)
    {
      NSString *collectorType = [elemCollector attributeNamed:@"type"];
      NSString *collectorTime = [self parseTime:[elemCollector attributeNamed:@"time"]];
      NSString *collectorDelay = [self parseTime:[elemCollector attributeNamed:@"listenerDelay"]];
      NSString *collectorEnabled = [elemCollector attributeNamed:@"enabled"];
      
      if (collectorType!=nil && collectorTime!=nil && collectorDelay!=nil && collectorEnabled!=nil)
      {
        data_collector = [@{@"type" : collectorType,
                @"time" : collectorTime,
                @"listenerDelay" : collectorDelay,
                @"enabled" : collectorEnabled} mutableCopy];
      }
    }
    
    SMXMLElement *elemCondition = [document.root childNamed:@"conditions"];
    if (nil != elemCondition)
    {
      NSArray *conditionGroups = [elemCondition childrenNamed:@"condition-group"];
      if (nil != conditionGroups)
      {
        conditions = [[NSMutableArray alloc] init];
        
        for (int j=0; j<[conditionGroups count]; j++)
        {
          SMXMLElement *condition = conditionGroups[j];
          if (nil != condition)
          {
            NSString *condition_id = [condition attributeNamed:@"id"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"id"] = condition_id;
            
            NSArray *tmpTypes = [condition childrenNamed:@"condition"];
            if (nil != tmpTypes)
            {
              NSMutableArray *conditionTypes = [[NSMutableArray alloc] init];
              
              for (int m=0; m<[tmpTypes count]; m++)
              {
                SMXMLElement *conditionType = tmpTypes[m];
                
                if (nil != conditionType)
                {
                  NSMutableDictionary *typeDict = [[NSMutableDictionary alloc] init];
                  
                  NSString *condition_type = [conditionType attributeNamed:@"type"];
                  
                  if ([condition_type isEqualToString:@"NetworkType"])
                  {
                    NSString *networkType = [conditionType attributeNamed:@"value"];
                    typeDict[@"networkType"] = networkType;
                    [conditionTypes addObject:typeDict];
                  }
                  
                  // extract this information, but we cant utilise it on iOS :(
                  if ([condition_type isEqualToString:@"NetActivity"])
                  {
                    NSString *maxByteIn = [conditionType attributeNamed:@"maxByteIn"];
                    NSString *maxByteOut = [conditionType attributeNamed:@"maxByteOut"];
                    NSString *time = [self parseTime:[conditionType attributeNamed:@"time"]];
                    
                    typeDict[@"type"] = condition_type;
                    typeDict[@"maxByteIn"] = maxByteIn;
                    typeDict[@"maxByteOut"] = maxByteOut;
                    typeDict[@"time"] = time;
                    [conditionTypes addObject:typeDict];
                  }
                  
                  if ([condition_type isEqualToString:@"CpuActivity"])
                  {
                    NSString *maxAvg = [conditionType attributeNamed:@"maxAvg"];
                    NSString *time = [self parseTime:[conditionType attributeNamed:@"time"]];
                    
                    typeDict[@"type"] = condition_type;
                    typeDict[@"maxAvg"] = maxAvg;
                    typeDict[@"time"] = time;
                    [conditionTypes addObject:typeDict];
                  }
                  
                  if ([condition_type isEqualToString:@"LocationAvailable"])
                  {
                    NSString *waitTime = [self parseTime:[conditionType attributeNamed:@"waitTime"]];
                    
                    typeDict[@"type"] = condition_type;
                    typeDict[@"waitTime"] = waitTime;
                    [conditionTypes addObject:typeDict];
                  }
                  
                  if ([condition_type isEqualToString:@"ParamExpired"])
                  {
                    NSString *paramName = [conditionType attributeNamed:@"paramName"];
                    NSString *expireTime = [self parseTime:[conditionType attributeNamed:@"expireTime"]];
                    
                    typeDict[@"type"] = condition_type;
                    typeDict[@"paramName"] = paramName;
                    typeDict[@"expireTime"] = expireTime;
                    [conditionTypes addObject:typeDict];
                  }
                }
              }
              
              if (nil != conditionTypes)
              {
                dict[@"condition_types"] = conditionTypes;
              }
            }
            
            [conditions addObject:dict];
          }
        }
      }
    }
    
    
    SMXMLElement *elemTests = [document.root childNamed:@"tests"];
    if (nil != elemTests)
    {
      NSArray *testsArray = [elemTests childrenNamed:@"test"];
      
      if (nil != testsArray)
      {
        tests = [[NSMutableArray alloc] init];
        displayTests = [[NSMutableArray alloc] init];
        
        for (int k=0; k<[testsArray count]; k++)
        {
          SMXMLElement *elemTest = testsArray[k];
          if (nil != elemTest)
          {
            NSMutableDictionary *dictTest = [[NSMutableDictionary alloc] init];
            
            NSString *type = [elemTest attributeNamed:@"type"];
            NSString *condId = [elemTest attributeNamed:@"condition-group-id"];
            NSString *displayName = [elemTest attributeNamed:@"displayName"];
            
            dictTest[@"type"] = type;
            dictTest[@"condition_group_id"] = condId;
            dictTest[@"displayName"] = displayName;
            
            SMXMLElement *elemExecuteAt = [elemTest childNamed:@"executeAt"];
            if (nil != elemExecuteAt)
            {
              NSArray *tmpExecutes = [elemExecuteAt childrenNamed:@"time"];
              
              if (nil != tmpExecutes)
              {
                NSMutableArray *tmpTimes = [[NSMutableArray alloc] init];
                
                for (int j=0; j<[tmpExecutes count]; j++)
                {
                  SMXMLElement *elemTime = tmpExecutes[j];
                  if (nil != elemTime)
                  {
                    [tmpTimes addObject:[elemTime value]];
                  }
                }
                dictTest[@"executeAt"] = tmpTimes;
              }
            }
            else
            {
              // No execute times found in the XML, insert a default.
              // Although the iOS app is currently not doing scheduled tests, it might be possible in the future,
              // so the check for the executeAt times remains here, and defaulted when missing.
              // The functionality to schedule the tests around these values is in place, but essentialy ignored
              // as we never actually 'schedule' anything, we just run the auto tests when we go on the background.
              // Update :: we no longer run tests on push to background.. EAQ only want MANUAL tests.
              dictTest[@"executeAt"] = @[@"23:39"];
            }
            
            SMXMLElement *elemParams = [elemTest childNamed:@"params"];
            if (nil != elemParams)
            {
              NSArray *tmpParams = [elemParams childrenNamed:@"param"];
              if (nil != tmpParams)
              {
                NSMutableArray *params = [[NSMutableArray alloc] init];
                
                for (int c=0; c<[tmpParams count]; c++)
                {
                  SMXMLElement *elemParam = tmpParams[c];
                  if (nil != elemParam)
                  {
                    if ([elemParam attributeNamed:@"name"] && [elemParam attributeNamed:@"value"])
                    {
                      NSString *name = [elemParam attributeNamed:@"name"];
                      NSString *value = [elemParam attributeNamed:@"value"];
                      
                      NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
                      paramDict[name] = value;
                      
                      [params addObject:paramDict];
                    }
                  }
                }
                
                dictTest[@"params"] = params;
              }
            }
            
            SMXMLElement *elemOutput = [elemTest childNamed:@"ouput"];
            if (nil != elemOutput)
            {
              NSArray *tmpFields = [elemOutput childrenNamed:@"field"];
              if (nil != tmpFields)
              {
                NSMutableDictionary *outputDict = [[NSMutableDictionary alloc] init];
                
                for (int x=0; x<[tmpFields count]; x++)
                {
                  SMXMLElement *elemField = tmpFields[x];
                  if (nil != elemField)
                  {
                    if ([elemField attributeNamed:@"name"] && [elemField attributeNamed:@"position"])
                    {
                      NSString *name = [elemField attributeNamed:@"name"];
                      NSString *position = [elemField attributeNamed:@"position"];
                      
                      outputDict[name] = position;
                    }
                  }
                }
                
                dictTest[@"output"] = outputDict;
              }
            }
            
            // Add the conditons for the test..
            if (dictTest[@"condition_group_id"])
            {
              NSString *cid = dictTest[@"condition_group_id"];
              
              if (nil != conditions)
              {
                if ([conditions count] > 0)
                {
                  for (int m=0; m<[conditions count]; m++)
                  {
                    NSDictionary *d = conditions[m];
                    
                    if (d[@"id"])
                    {
                      if ([cid isEqualToString:d[@"id"]])
                      {
                        dictTest[@"conditions"] = d;
                        break;
                      }
                    }
                  }
                }
              }
            }
            
            [tests addObject:dictTest];
            
            if (![type isEqualToString:@"closestTarget"])
            {
              [displayTests addObject:dictTest];
            }
            
            dictTest = nil;
          }
        }
        
        if ([self shouldSortTests] == YES) {
          // it is necessary now to sort the tests in the RIGHT order!
          // NSLog(@"tests before sort=%@", tests);
          
          [tests sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDictionary *dict1 = obj1;
            NSDictionary *dict2 = obj2;
            
            SKTestConfig *config1 = [[SKTestConfig alloc] initWithDictionary:dict1];
            SKTestConfig *config2 = [[SKTestConfig alloc] initWithDictionary:dict2];
            
            NSString *tstType1 = config1.type;
            NSString *tstType2 = config2.type;
            
            int order1 = 0;
            if ([tstType1 isEqualToString:@"closestTarget"]) {
              order1 = 0;
            } else if ([tstType1 isEqualToString:@"latency"]) {
              order1 = 1;
            } else if ([tstType1 isEqualToString:@"downstreamthroughput"]) {
              order1 = 2;
            } else if ([tstType1 isEqualToString:@"upstreamthroughput"]) {
              order1 = 3;
            }
            
            int order2 = 0;
            if ([tstType2 isEqualToString:@"closestTarget"]) {
              order2 = 0;
            } else if ([tstType2 isEqualToString:@"latency"]) {
              order2 = 1;
            } else if ([tstType2 isEqualToString:@"downstreamthroughput"]) {
              order2 = 2;
            } else if ([tstType2 isEqualToString:@"upstreamthroughput"]) {
              order2 = 3;
            }
            
            if (order1 > order2) {
              return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (order1 < order2) {
              return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult) NSOrderedSame;
          }];
          
          //NSLog(@"tests after sort=%@", tests);
        }
      }
    }
  }
}

- (void)dealloc
{
#ifdef DEBUG
  NSLog(@"DEBUG: SKScheduler - dealloc");
#endif // DEBUG
  
//  [[NSNotificationCenter defaultCenter]
//   removeObserver:self
//   name:UIApplicationDidReceiveMemoryWarningNotification 
//   object:nil];
  
  //  [[NSNotificationCenter defaultCenter]
  //   removeObserver:self
  //   name:@"AutoTestingChanged" 
  //   object:nil];
  
  [[NSNotificationCenter defaultCenter]
   removeObserver:self
   name:@"UploadComplete"
   object:nil];
  
  
  xmlData = nil;
  submit_dcs = nil;
  scheduleVersion = nil;
  tests_alarm_type = nil;
  location_service = nil;
  onfail_test_action = nil;
  original_tests = nil;
  hosts = nil;
  data_collector = nil;
  conditions = nil;
  tests = nil;
  displayTests = nil;
  
  communications = nil;
}

@end

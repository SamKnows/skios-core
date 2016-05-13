//
//  SKScheduleParser.m
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SKScheduleParser.h"
#import "SKTestRunner.h"

// https://developer.apple.com/library/mac/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html
// This is how you access Swift class code!
//#import <SKKit/SKKit-Swift.h>

#import "SKCore.h"
#import "SKKitTest.h"

@interface SKScheduleHost()
@property NSString *dnsName;
@property NSString *displayName;
@end

@implementation SKScheduleHost
- (instancetype)init
{
  self = [super init];
  if (self) {
    self.dnsName = @"";
    self.displayName = @"";
  }
  return self;
}

- (NSString *)getDnsName {
  return self.dnsName;
}

- (NSString *)getDisplayName {
  return self.displayName;
}
@end

//====

@interface SKKitTestDescriptor()
@property NSString *mId;
@property SKKitTestType mType;
@end

@implementation SKKitTestDescriptor
- (instancetype)initWithId:(NSString*)identifier TestType:(SKKitTestType)testType{

  self = [super init];
  if (self) {
    self.mId = identifier;
    self.mType = testType;
  }
  return self;
}

- (NSString *)getId {
  return self.mId;
}

- (SKKitTestType)getType {
  return self.mType;
}


-(NSString*) getDisplayName {
  switch (self.mType) {
    case SKKitTestType_Closest:
      return @"Closest";
    case SKKitTestType_Download:
      return @"Download";
    case SKKitTestType_Upload:
      return @"Upload";
    case SKKitTestType_Latency:
    defualt:
      return @"Latency";
  }
}
@end


@implementation SKKitTestDescriptor_ClosestTarget
- (instancetype)initWithId:(NSString*)identifier
{
  self = [super initWithId:identifier TestType:SKKitTestType_Closest];
  if (self) {
    self.mTargetArray = [NSMutableArray new];
  }
  return self;
}
@end

@implementation SKKitTestDescriptor_Download

- (instancetype)initWithId:(NSString*)identifier
{
  self = [super initWithId:identifier TestType:SKKitTestType_Download];
  if (self) {
    self.mTarget = @"";
    self.mPort = 0;
    self.mFile = @"";
    self.mWarmupMaxTimeSeconds = 0.0;
    self.mTransferMaxTimeSeconds = 0.0;
    self.mWarmupMaxBytes = 0;
    self.mTransferMaxBytes = 0;
    self.mNumberOfThreads = 0;
    self.mBufferSizeBytes = 0;
  }
  return self;
}
@end


@implementation SKKitTestDescriptor_Latency

- (instancetype)initWithId:(NSString*)identifier
{
  self = [super initWithId:identifier TestType:SKKitTestType_Latency];
  if (self) {
    self.mTarget = @"";
    self.mPort = 0;
    //public var mFile:String = "";
    self.mInterPacketTimeSeconds = 0.0;
    self.mDelayTimeoutSeconds = 0.0;
    self.mNumberOfPackets = 0;
    self.mPercentile = 0;
    self.mMaxTimeSeconds = 0;
  }
  return self;
}
@end


@implementation SKKitTestDescriptor_Upload

- (instancetype)initWithId:(NSString*)identifier
{
  self = [super initWithId:identifier TestType:SKKitTestType_Upload];
  if (self) {
    self.mTarget = @"";
    self.mPort = 0;
    //public var mFile:String = @"";
    self.mWarmupMaxTimeSeconds = 0.0;
    self.mTransferMaxTimeSeconds = 0.0;
    self.mWarmupMaxBytes = 0;
    self.mTransferMaxBytes = 0;
    self.mNumberOfThreads = 0;
    //public var mBufferSizeBytes = 0;
    self.mSendDataChunkSizeBytes = 0;
    self.mPostDataLengthBytes = 0;
  }
  return self;
}
@end

//==============

@interface SKScheduleParser()
@property NSString * closestTargetId; //  = "1"

@property NSString * mSubmitDcsHost; // String = "dcs.samknows.com" // Default value!
@property NSMutableArray * mHostArray; // :Array<SKScheduleHost> = []
@property NSMutableArray * mTestArray; // :Array<SKKitTestDescriptor> = []
@property NSMutableArray * mManualTestArray; // :Array<String> = []
@property double mDataCapMbps;
@property BOOL mbParseError;

@property BOOL mbInInitBlock;
@property BOOL mbInTestsBlock;
@property BOOL mbInManualTestsBlock;
@property BOOL mbInScheduledTestsBlock;
@property SKKitTestDescriptor_ClosestTarget *mInTest_ClosestTarget;
@property SKKitTestDescriptor_Download *mInTest_Download;
@property SKKitTestDescriptor_Upload *mInTest_Upload;
@property SKKitTestDescriptor_Latency *mInTest_Latency;
@end

@implementation SKScheduleParser
@synthesize closestTargetId;
@synthesize mSubmitDcsHost;
@synthesize mHostArray;
@synthesize mTestArray;
@synthesize mManualTestArray;
@synthesize mDataCapMbps;
@synthesize mbParseError;

@synthesize mbInInitBlock;
@synthesize mbInTestsBlock;
@synthesize mbInManualTestsBlock;
@synthesize mbInScheduledTestsBlock;
@synthesize mInTest_ClosestTarget;
@synthesize mInTest_Download;
@synthesize mInTest_Upload;
@synthesize mInTest_Latency;

- (instancetype)initFromXMLString:(NSString *)fromXMLString {
  self = [super init];
  if (self) {
    closestTargetId = @"1";
    mSubmitDcsHost = @"dcs.samknows.com"; // Default value!
    mHostArray = [NSMutableArray new];
    mTestArray = [NSMutableArray new];
    mManualTestArray = [NSMutableArray new];
    mDataCapMbps = 0.0;
    mbParseError = false;
    
    mbInInitBlock = false;
    mbInTestsBlock = false;
    mbInManualTestsBlock = false;
    mbInScheduledTestsBlock = false;
    mInTest_ClosestTarget = nil;
    mInTest_Download = nil;
    mInTest_Upload = nil;
    mInTest_Latency = nil;
    
    if (SK_VERIFY([self parseXmlString:fromXMLString]) == false) {
      //NSLog(@"FAILED CONSTRUCTION FROM XML!")
      return self;
    }
    
    //NSLog(@"SUCCESSFUL CONSTRUCTION FROM XML!")
    
    [self tidyUpScheduleBeforeUse];
  }
  return self;
}

- (NSArray *)getHostArray {
  return mHostArray;
}

- (NSArray *)getTestArray {
  return mTestArray;
}

- (double)getDataCapMbps {
  return mDataCapMbps;
}

-(BOOL)parseXmlString:(NSString*)fromXmlString {
  NSData *decodedData = [fromXmlString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion:false];
  
  if (decodedData != nil)
  {
    mbParseError = false;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:decodedData];
    parser.shouldProcessNamespaces = false;
    parser.shouldReportNamespacePrefixes = false;
    parser.shouldResolveExternalEntities = false;
    parser.delegate = self;
    [parser parse];
  } else {
    SK_ASSERT(false);
    return false;
  }
  
  // All done!
  if (mbParseError) {
    SK_ASSERT(false);
    return false;
  }
  
  // Success!
  //    if (SK_VERIFY(true) == false) {
  //      #ifdef DEBUG
  //        print("DEBUG: fix some import data...")
  //      #endif // DEBUG
  //      return false
  //    }
  
  return true;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  //print("DEBUG: XML DID END elementName: \(elementName)")
  if ([elementName isEqualToString:@"init"]) {
    mbInInitBlock = false;
  } else if ([elementName isEqualToString:@"tests"]) {
    mbInTestsBlock = false;
  } else if ([elementName isEqualToString:@"manual-tests"]) {
    mbInManualTestsBlock = false;
  } else if ([elementName isEqualToString:@"scheduled-tests"]) {
    mbInScheduledTestsBlock = false;
  } else if ([elementName isEqualToString:@"test"]) {
    mInTest_ClosestTarget = nil;
    mInTest_Download = nil;
    mInTest_Upload = nil;
    mInTest_Latency = nil;
  }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  //print("DEBUG: XML DID START elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
  if ([elementName isEqualToString:@"init"]) {
    mbInInitBlock = true;
  } else if ([elementName isEqualToString:@"tests"]) {
    
    // IGNORE this block if it is in scheduled-tests!
    if (mbInScheduledTestsBlock == false) {
      mbInTestsBlock = true;
    }
  } else if ([elementName isEqualToString:@"manual-tests"]) {
    mbInManualTestsBlock = true;
    SK_ASSERT(mbInScheduledTestsBlock == false);
  } else if ([elementName isEqualToString:@"scheduled-tests"]) {
    mbInScheduledTestsBlock = true;
    SK_ASSERT(mbInManualTestsBlock == false);
  }
  //print("Element's name is \(elementName)")
  //print("Element's attributes are \(attributeDict)")
  
  // We might get outer FXM element
  // We might get inner UNIT elements
  
  if ([elementName isEqualToString:@"config"]) {
    // Ignore this!
  } else if ([elementName isEqualToString:@"global"]) {
  } else if ([elementName isEqualToString:@"schedule-version"]) {
    NSLog(@"schedule-version...");
    // Ignore this!
  } else if ([elementName isEqualToString:@"submit-dcs"]) {
    // Ignore this!
    NSString *tHost = [attributeDict objectForKey:@"host"];
#ifdef DEBUG
    NSString *tDummy = [attributeDict objectForKey:@"dummy"];
#endif // DEBUG
    SK_ASSERT(tHost != nil);
#ifdef DEBUG
    SK_ASSERT(tDummy == nil);
#endif // DEBUG
    if (tHost != nil) {
      SK_ASSERT(tHost.length > 0);
      mSubmitDcsHost = tHost;
    }
  } else if ([elementName isEqualToString:@"tests-alarm-type"]) {
  } else if ([elementName isEqualToString:@"location-service"]) {
  } else if ([elementName isEqualToString:@"onfail-test-action"]) {
  } else if ([elementName isEqualToString:@"init"]) {
  } else if ([elementName isEqualToString:@"hosts"]) {
  } else if ([elementName isEqualToString:@"communications"]) {
  } else if ([elementName isEqualToString:@"communication"]) {
  } else if ([elementName isEqualToString:@"data-collector"]) {
  } else if ([elementName isEqualToString:@"params"]) {
  } else if ([elementName isEqualToString:@"ouput"]) { // This is NOT a typo!
  } else if ([elementName isEqualToString:@"field"]) {
  } else if ([elementName isEqualToString:@"tests"]) {
    // This block contains a list of "test" items with type="..."
  } else if ([elementName isEqualToString:@"manual-tests"]) {
    // This block contains a list of "test" items with id="...".
    // The order of the items in here, is used purely to tell us the order to use for the items.
  } else if ([elementName isEqualToString:@"scheduled-tests"]) {
    // Items associated with background processing (which is IGNORED on iOS...)
  } else if ([elementName isEqualToString:@"batch"]) {
    // This is for background processing. Ignore on iOS!
  } else if ([elementName isEqualToString:@"executeAt"]) {
    // This is for background processing. Ignore on iOS!
  } else if ([elementName isEqualToString:@"time"]) {
    // This is for background processing. Ignore on iOS!
  } else if ([elementName isEqualToString:@"test"]) {
    NSLog(@"test");
    NSLog(@"DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)");
    
    if (mbInTestsBlock == true) {
      // We're in the tests block.
      NSString *tTestType = [attributeDict objectForKey:@"type"];
      SK_ASSERT(tTestType != nil);
      
      // Extract the test id.
      // "downstreamthroughput\" test-id=\"2\"
      NSString *tTestId = [attributeDict objectForKey:@"test-id"];
      SK_ASSERT(tTestId != nil);
      
      SKKitTestDescriptor *theTest = nil;
      
      if ([tTestType isEqualToString:@"closestTarget"]) {
        // These are never given an id. So, we give them an arbitrary id!
        tTestId = closestTargetId;
        
        SKKitTestDescriptor_ClosestTarget *thisTest = [[SKKitTestDescriptor_ClosestTarget alloc] initWithId:tTestId];
        theTest = thisTest;
        mInTest_ClosestTarget = thisTest;
      } else if ([tTestType isEqualToString:@"downstreamthroughput"]) {
        SK_ASSERT(tTestId != nil);
        SKKitTestDescriptor_Download*thisTest = [[SKKitTestDescriptor_Download alloc] initWithId:tTestId];
        theTest = thisTest;
        mInTest_Download = thisTest;
      } else if ([tTestType isEqualToString:@"upstreamthroughput"]) {
        SK_ASSERT(tTestId != nil);
        SKKitTestDescriptor_Upload*thisTest = [[SKKitTestDescriptor_Upload alloc] initWithId:tTestId];
        theTest = thisTest;
        mInTest_Upload = thisTest;
      } else if ([tTestType isEqualToString:@"latency"]) {
        SK_ASSERT(tTestId != nil);
        SKKitTestDescriptor_Latency*thisTest = [[SKKitTestDescriptor_Latency alloc] initWithId:tTestId];
        theTest = thisTest;
        mInTest_Latency = thisTest;
      } else {
        // Unrecognised test!
#ifdef DEBUG
        SK_ASSERT(false);
#endif // DEBUG
      }
      
      if (theTest != nil) {
        // Verify that this doesn't already exist with a matching test id...
#ifdef DEBUG
        for (SKKitTestDescriptor *checkTest in mTestArray) {
          SK_ASSERT(![[checkTest getId] isEqualToString:[theTest getId]]);
        }
#endif // DEBUG
        
        // Simply store this value for later sorting by tidyUpScheduleBeforeUse()...
        [mTestArray addObject:theTest];
      }
    } else if (mbInManualTestsBlock == true) {
      // We are in the manual-tests block!
      // "<manual-tests>\n",
      // "<test id=\"2\" />\n",
      // "<test id=\"3\" />\n",
      // "<test id=\"4\" />\n",
      // "</manual-tests>\n",
      // Simply store this value for later sorting by tidyUpScheduleBeforeUse()...
      NSString *tTestId = [attributeDict objectForKey:@"id"];
      SK_ASSERT(tTestId != nil);
      if (tTestId != nil) {
        [mManualTestArray addObject:tTestId];
      }
    } else if (mbInInitBlock == true) {
      // This is OK
    } else if (mbInScheduledTestsBlock == true) {
      // This is OK - ignore it
    } else {
      // We in some unexpected block!
      SK_ASSERT(false);
    }
    
  } else if ([elementName isEqualToString:@"host"]) {
#ifdef DEBUG
    NSLog(@"DEBUG: host");
#endif // DEBUG
    SKScheduleHost *theHost = [[SKScheduleHost alloc] init];
    NSString *tDnsName = [attributeDict objectForKey:@"dnsName"];
    if (tDnsName != nil) {
      theHost.dnsName = tDnsName;
    } else {
      SK_ASSERT(false);
    }
    NSString *tDisplayName = [attributeDict objectForKey:@"displayName"];
    if (tDisplayName != nil) {
      theHost.displayName = tDisplayName;
    } else {
      SK_ASSERT(false);
    }
    [mHostArray addObject:theHost];
#ifdef DEBUG
    NSLog(@"DEBUG: got Host: \(theHost)");
#endif // DEBUG
    
  } else if ([elementName isEqualToString:@"data-cap-default"]) {
    NSLog(@"data-cap-default");
    // Extract the data cap, if any.
    // "downstreamthroughput\" test-id=\"2\"
    NSString *tDataCap = [attributeDict objectForKey:@"value"];
    if (SK_VERIFY(tDataCap != nil) == true) {
      mDataCapMbps = tDataCap.doubleValue;
      SK_ASSERT(mDataCapMbps > 0);
    }
  } else if ([elementName isEqualToString:@"param"]) {
    
    //print("DEBUG: param: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
    NSString *tName = [attributeDict objectForKey:@"name"];
    SK_ASSERT(tName != nil);
    NSString *valueString = [attributeDict objectForKey:@"value"];
    if (valueString != nil)
    {
      if (mInTest_ClosestTarget != nil) {
        [mInTest_ClosestTarget.mTargetArray addObject:valueString];
      } else if (mInTest_Download != nil) {
        if ([tName isEqualToString:@"target"]) {
          mInTest_Download.mTarget = valueString;
        } else if ([tName isEqualToString:@"port"]) {
          mInTest_Download.mPort = valueString.integerValue;
        } else if ([tName isEqualToString:@"file"]) {
          mInTest_Download.mFile = valueString;
        } else if ([tName isEqualToString:@"warmupmaxtime"]) {
          mInTest_Download.mWarmupMaxTimeSeconds = valueString.doubleValue;
          mInTest_Download.mWarmupMaxTimeSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"transfermaxtime"]) {
          mInTest_Download.mTransferMaxTimeSeconds = valueString.doubleValue;
          mInTest_Download.mTransferMaxTimeSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"warmupmaxbytes"]) {
          mInTest_Download.mWarmupMaxBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"transfermaxbytes"]) {
          mInTest_Download.mTransferMaxBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"numberofthreads"]) {
          mInTest_Download.mNumberOfThreads = valueString.integerValue;
        } else if ([tName isEqualToString:@"buffersize"]) {
          mInTest_Download.mBufferSizeBytes = valueString.integerValue;
        } else {
          SK_ASSERT(false);
        }
      } else if (mInTest_Upload != nil) {
        if ([tName isEqualToString:@"target"]) {
          mInTest_Upload.mTarget = valueString;
        } else if ([tName isEqualToString:@"port"]) {
          mInTest_Upload.mPort = valueString.integerValue;
        } else if ([tName isEqualToString:@"warmupmaxtime"]) {
          mInTest_Upload.mWarmupMaxTimeSeconds = valueString.doubleValue;
          mInTest_Upload.mWarmupMaxTimeSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"warmupmaxbytes"]) {
          mInTest_Download.mWarmupMaxBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"transfermaxbytes"]) {
          mInTest_Download.mTransferMaxBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"transfermaxtime"]) {
          mInTest_Upload.mTransferMaxTimeSeconds = valueString.doubleValue;
          mInTest_Upload.mTransferMaxTimeSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"numberofthreads"]) {
          mInTest_Upload.mNumberOfThreads = valueString.integerValue;
          //          } else if (tName == "buffersize") {
          //             mInTest_Upload.mBufferSizeBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"sendDataChunk"]) {
          mInTest_Upload.mSendDataChunkSizeBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"postdatalength"]) {
          mInTest_Upload.mPostDataLengthBytes = valueString.integerValue;
        } else if ([tName isEqualToString:@"file"]) {
          // Ignore this!
        } else {
          SK_ASSERT(false);
        }
      } else if (mInTest_Latency != nil) {
        if ([tName isEqualToString:@"target"]) {
          mInTest_Latency.mTarget = valueString;
        } else if ([tName isEqualToString:@"port"]) {
          mInTest_Latency.mPort = valueString.integerValue;
        } else if ([tName isEqualToString:@"interPacketTime"]) {
          mInTest_Latency.mInterPacketTimeSeconds = valueString.doubleValue;
          mInTest_Latency.mInterPacketTimeSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"delayTimeout"]) {
          mInTest_Latency.mDelayTimeoutSeconds = valueString.doubleValue;
          mInTest_Latency.mDelayTimeoutSeconds /= 1000000.0;
        } else if ([tName isEqualToString:@"numberOfPackets"]) {
          mInTest_Latency.mNumberOfPackets = valueString.integerValue;
        } else if ([tName isEqualToString:@"percentile"]) {
          mInTest_Latency.mPercentile = valueString.integerValue;
        } else if ([tName isEqualToString:@"maxTime"]) {
          mInTest_Latency.mMaxTimeSeconds = valueString.doubleValue;
          mInTest_Latency.mMaxTimeSeconds /= 1000000.0;
        } else {
          SK_ASSERT(false);
        }
      }
    } else {
      SK_ASSERT(false);
    }
    
  } else if ([elementName isEqualToString:@"condition"]) {
    //print("TODO: condition? For Android: but not on iOS")
    //print("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
  } else if ([elementName isEqualToString:@"conditions"]) {
    //print("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
  } else if ([elementName isEqualToString:@"condition-group"]) {
    //print("TODO: condition-group? For Android: but not on iOS")
    //print("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
  } else {
    
#ifdef DEBUG
    NSLog(@"DEBUG: UNKNOWN XML elementName: \(elementName) ATTRIBUTES: \(attributeDict)");
    SK_ASSERT(false);
#endif // DEBUG
  }
}

-(void) tidyUpScheduleBeforeUse {
  
#ifdef DEBUG
  NSLog(@"DEBUG: tidyUpScheduleBeforeUse()");
  NSLog(@"DEBUG: PRE sort: mTestArray=\(mTestArray)");
#endif // DEBUG
  
  NSMutableArray *sortedArray = [NSMutableArray new]; // :Array<SKKitTestDescriptor> = []
  
  // We MUST ensure that we always have a closest target test, and that it is always run first!
  // So: if we have a closest target test, make it first in our sorted array.
  // If we don't have a closest target test, add one, and make it first in our sorted array.
  BOOL foundClosestTargetTest = false;
  for (SKKitTestDescriptor *theTest in mTestArray) {
    if ([theTest getType] == SKKitTestType_Closest) {
      // We have a closest target test!
      // Always make it first!
      [sortedArray addObject:theTest];
      foundClosestTargetTest = true;
      break;
    }
  }
  if (foundClosestTargetTest == false) {
    // There was no closest target test.
    // Make sure we always have one, and make it first!
    SK_ASSERT(false);
    SKKitTestDescriptor_ClosestTarget *thisTest = [[SKKitTestDescriptor_ClosestTarget alloc] initWithId:closestTargetId];
    [mTestArray addObject:thisTest];
    [sortedArray addObject:thisTest];
  }
  
  //
  // Now, run through test in the preferred sort order, and add to the sorted array if not already there.
  //
  for (NSString *manualTestId in mManualTestArray) {
    BOOL foundThisTest = false;
    for (SKKitTestDescriptor *theTest in mTestArray) {
      if ([[theTest getId] isEqualToString: manualTestId]) {
        // Got the test!
        foundThisTest = true;
        
        // Don't add it, if we already have it in the array...
        BOOL alreadyListed = false;
        for (SKKitTestDescriptor *sortedArrayItem in sortedArray) {
          if ([manualTestId isEqualToString:[sortedArrayItem getId]]) {
            alreadyListed = true;
            SK_ASSERT(false);
            break;
          }
        }
        
        if (alreadyListed == false) {
          [sortedArray addObject:theTest];
        }
        break;
      }
    }
    
    SK_ASSERT(foundThisTest == true);
  }
  
  // Finally, add any tests we've not already got...
  // Note that there should not be any of these...
  for (SKKitTestDescriptor *theTest in mTestArray) {
    BOOL foundThisTest = false;
    for (SKKitTestDescriptor *sortedTest in sortedArray) {
      if ([[sortedTest getId] isEqualToString:[theTest getId]]) {
        foundThisTest = true;
        break;
      }
    }
    
    if (foundThisTest == true) {
      // Already got it.
    } else {
      // It was missing from the manual-test list... looks like a problem with the schedule.
      // Make sure we keep the test, however...
      SK_ASSERT(false);
      [sortedArray addObject:theTest];
    }
  }
  
  //
  // Now, use the sorted array in preference.
  //
  SK_ASSERT(sortedArray.count == mTestArray.count);
  mTestArray = sortedArray;
  
  //    mTestArray.sort { (T1, T2) -> Bool in
  //      // What order should we use?!
  //      // If T1 < T2, then return false (etc.)
  //      // What do we know? If T1 comes before T2 in the
  //      T1.getId()
  //      T2.getId()
  //      return true
  //    }
  
  //print("POST sort: mTestArray=\(mTestArray)")
  
}
  
  
// The following method, is the only way to create an instance of SKTestRunner.
// This guarantees that the "test plan" is properly constructed, properly ordered etc.
// Actually, this will create and return the SKTestManager instance
-(SKTestRunner*)createTestRunner {
  [self tidyUpScheduleBeforeUse];

  return [[SKTestRunner alloc] initFromScheduleParser:self];
}

- (void)helloWorld {
  NSLog(@"helloWorld");
}
@end
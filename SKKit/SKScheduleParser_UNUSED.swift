//
//  SKScheduleParser.swift
//  SKKit
//
//  Created by Pete Cole on 26/01/2015.
//  Copyright (c) 2015 SamKnows. All rights reserved.
//

// This file was written originally to be used within SKKit, but was re-written in Objective-C
// (see SKScheduleParser.m etc.), in order to allow it to be used from within the static library.

import Foundation

@objc
public class SKScheduleHost {
  private var dnsName:String = "" // forKey:@"dns_name"];
  private var displayName:String = "" // forKey:@"display_name"];
  
  public func getDnsName() -> String {
    return dnsName
  }
  public func getDisplayName() -> String {
    return displayName
  }
}

@objc
public class SKScheduleTest {
  private let mId:String
  private let mType:Type
  
  public enum Type : UInt {
    case Closest=0
    case Download=1
    case Upload=2
    case Latency=3
  }
  
  private init(identifier:String, type:Type) {
    mId = identifier
    mType = type
  }
  
  public func getId() -> String {
    return mId
  }
  
  public func getType() -> Type {
    return mType
  }
  
  public func getDisplayName() -> String {
    switch (mType) {
    case .Closest:
      return "Closest"
    case .Download:
      return "Download"
    case .Upload:
      return "Upload"
    case .Latency:
      return "Latency"
    }
  }
}

@objc
public class SKScheduleTest_Descriptor_ClosestTarget : SKScheduleTest
{
  public var mTargetArray:Array<String> = []
  
  init(identifier: String) {
    super.init(identifier:identifier, type:.Closest)
  }
}

@objc
public class SKScheduleTest_Descriptor_Download : SKScheduleTest
{
  public var mTarget = ""
  public var mPort = 0
  public var mFile = ""
  public var mWarmupMaxTimeSeconds:NSTimeInterval = 0.0
  public var mTransferMaxTimeSeconds:NSTimeInterval = 0.0
  public var mNumberOfThreads = 0
  public var mBufferSizeBytes = 0

  init(identifier: String) {
    super.init(identifier:identifier, type:.Download)
  }
}

@objc
public class SKScheduleTest_Descriptor_Upload : SKScheduleTest
{
  public var mTarget = ""
  public var mPort = 0
  //public var mFile:String = ""
  public var mWarmupMaxTimeSeconds:NSTimeInterval = 0.0
  public var mTransferMaxTimeSeconds:NSTimeInterval = 0.0
  public var mNumberOfThreads = 0
  //public var mBufferSizeBytes = 0
  public var mSendDataChunkSizeBytes = 0
  public var mPostDataLengthBytes = 0

  init(identifier: String) {
    super.init(identifier:identifier, type:.Upload)
  }
}

@objc
public class SKScheduleTest_Descriptor_Latency : SKScheduleTest
{
  public var mTarget = ""
  public var mPort = 0
  //public var mFile:String = ""
  public var mInterPacketTimeSeconds:NSTimeInterval = 0.0
  public var mDelayTimeoutSeconds:NSTimeInterval = 0.0
  public var mNumberOfPackets = 0
  public var mPercentile = 0
  public var mMaxTimeSeconds:NSTimeInterval = 0

  init(identifier: String) {
    super.init(identifier:identifier, type:.Latency)
  }
}

@objc
public class SKScheduleParser : NSObject, NSXMLParserDelegate {
  // A test schedule may be constructed manually, or may be constructed from and XML description.
  // Optional constructor - as it might fail!
  public init?(fromXMLString:String) {
    super.init()
    
    if (SK_VERIFY(parseXmlString(fromXMLString)) == false) {
      //println("FAILED CONSTRUCTION FROM XML!")
      return nil
    }
    
    //println("SUCCESSFUL CONSTRUCTION FROM XML!")
    
    tidyUpScheduleBeforeUse()
  }
  
  deinit {
  }
  
  private let closestTargetId = "1"

  private var mSubmitDcsHost:String = "dcs.samknows.com" // Default value!
  private var mHostArray:Array<SKScheduleHost> = []
  private var mTestArray:Array<SKScheduleTest> = []
  private var mManualTestArray:Array<String> = []
  
  public func getHostArray() -> Array<SKScheduleHost> {
    return mHostArray
  }
  
  public func getTestArray() -> Array<SKScheduleTest> {
    return mTestArray
  }
 
  private var mDataCapMbps  = 0.0
  public func getDataCapMbps() -> Double {
    return mDataCapMbps
  }
  
  private var mbParseError:Bool = false
  
  func parseXmlString(xmlString:String) -> Bool {
    let decodedData = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:false)
    
    if (decodedData != nil)
    {
      mbParseError = false
      
      var parser = NSXMLParser(data: decodedData)
      parser.shouldProcessNamespaces = false
      parser.shouldReportNamespacePrefixes = false
      parser.shouldResolveExternalEntities = false
      parser.delegate = self
      parser.parse()
    } else {
      assert(false)
      return false
    }
    
    // All done!
    if (mbParseError) {
      assert(false)
      return false
    }
    
    // Success!
//    if (SK_VERIFY(true) == false) {
//      #if DEBUG
//        println("DEBUG: fix some import data...")
//      #endif // DEBUG
//      return false
//    }
    
    return true
  }
  
  // MARK: – NSXMLParserDelegate methods
  
  /*
  NOTE: I think that the following field from closest targets block is redundant - so, we ignore it
          <field name="closest" position="3"/>
  */
  
  var mbInInitBlock = false
  var mbInTestsBlock = false
  var mbInManualTestsBlock = false
  var mbInScheduledTestsBlock = false
  
  var mInTest_ClosestTarget:SKScheduleTest_Descriptor_ClosestTarget? = nil
  var mInTest_Download:SKScheduleTest_Descriptor_Download? = nil
  var mInTest_Upload:SKScheduleTest_Descriptor_Upload? = nil
  var mInTest_Latency:SKScheduleTest_Descriptor_Latency? = nil

  public func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
    //println("DEBUG: XML DID END elementName: \(elementName)")
    if (elementName == "init") {
      mbInInitBlock = false
    } else if (elementName == "tests") {
      mbInTestsBlock = false
    } else if (elementName == "manual-tests") {
      mbInManualTestsBlock = false
    } else if (elementName == "scheduled-tests") {
      mbInScheduledTestsBlock = false
    } else if (elementName == "test") {
      mInTest_ClosestTarget = nil
      mInTest_Download = nil
      mInTest_Upload = nil
      mInTest_Latency = nil
    }
  }
  
  func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!) {
    //println("DEBUG: XML DID START elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
    if (elementName == "init") {
      mbInInitBlock = true
    } else if (elementName == "tests") {
      
      // IGNORE this block if it is in scheduled-tests!
      if (mbInScheduledTestsBlock == false) {
        mbInTestsBlock = true
      }
    } else if (elementName == "manual-tests") {
      mbInManualTestsBlock = true
      SK_ASSERT(mbInScheduledTestsBlock == false)
    } else if (elementName == "scheduled-tests") {
      mbInScheduledTestsBlock = true
      SK_ASSERT(mbInManualTestsBlock == false)
    }
    //println("Element's name is \(elementName)")
    //println("Element's attributes are \(attributeDict)")
    
    // We might get outer FXM element
    // We might get inner UNIT elements
    
    switch (elementName) {
    case "config":
      // Ignore this!
      break
    case "global":
      break
    case "schedule-version":
      println("schedule-version...")
      // Ignore this!
      break
    case "submit-dcs":
      // Ignore this!
      var tHost = attributeDict.objectForKey("host") as String?
      var tDummy = attributeDict.objectForKey("dummy") as String?
      SK_ASSERT(tHost != nil)
      SK_ASSERT(tDummy == nil)
      if (tHost != nil) {
        SK_ASSERT(tHost!.isEmpty == false)
        mSubmitDcsHost = tHost!
      }
      break
    case "tests-alarm-type":
      // Ignore this!
      break
    case "location-service":
      // Ignore this!
      break
    case "onfail-test-action":
      // Ignore this!
      break
    case "init":
      // Ignore this!
      break
    case "hosts":
      // Ignore this!
      break
    case "communications":
      // Ignore this!
      break
    case "communication":
      // Ignore this!
      break
    case "data-collector":
      // Ignore this!
      break
    case "params":
      // Ignore this!
      break
    case "ouput": // This is NOT a typo!
      // Ignore this!
      break
    case "field": // This is NOT a typo!
      // Ignore this!
      break
    case "tests":
      // This block contains a list of "test" items with type="..."
      // Ignore this!
      break
    case "manual-tests":
      // This block contains a list of "test" items with id="...".
      // The order of the items in here, is used purely to tell us the order to use for the items.
      break;
      
      // Items associated with background processing (which is IGNORED on iOS...)
    case "scheduled-tests":
      // This block contains a list of "test" items with id="...".
      // This is for background processing. Ignore on iOS!
      break;
    case "batch":
      // This is for background processing. Ignore on iOS!
      break;
    case "executeAt":
      // This is for background processing. Ignore on iOS!
      break;
    case "time":
      // This is for background processing. Ignore on iOS!
      break;
      
    case "test":
      println("test")
      println("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      
      if (mbInTestsBlock == true) {
        // We're in the tests block.
        var tTestType = attributeDict.objectForKey("type") as String?
        SK_ASSERT(tTestType != nil)
        
        // Extract the test id.
        // "downstreamthroughput\" test-id=\"2\"
        var tTestId = attributeDict.objectForKey("test-id") as String?
        SK_ASSERT(tTestId != nil)
        
        var theTest:SKScheduleTest? = nil
        
        if (tTestType == "closestTarget") {
          // These are never given an id. So, we give them an arbitrary id!
          tTestId = closestTargetId
          
          let thisTest = SKScheduleTest_Descriptor_ClosestTarget(identifier:tTestId!)
          theTest = thisTest
          mInTest_ClosestTarget = thisTest
        } else if (tTestType == "downstreamthroughput") {
          SK_ASSERT(tTestId != nil)
          let thisTest = SKScheduleTest_Descriptor_Download(identifier: tTestId!)
          theTest = thisTest
          mInTest_Download = thisTest
        } else if (tTestType == "upstreamthroughput") {
          SK_ASSERT(tTestId != nil)
          let thisTest = SKScheduleTest_Descriptor_Upload(identifier: tTestId!)
          theTest = thisTest
          mInTest_Upload = thisTest
        } else if (tTestType == "latency") {
          SK_ASSERT(tTestId != nil)
          let thisTest = SKScheduleTest_Descriptor_Latency(identifier: tTestId!)
          theTest = thisTest
          mInTest_Latency = thisTest
        } else {
          // Unrecognised test!
          #if DEBUG
            SK_ASSERT(false)
          #endif // DEBUG
        }
        
        if (theTest != nil) {
          // Verify that this doesn't already exist with a matching test id...
          for checkTest in mTestArray {
            SK_ASSERT(checkTest.getId() != theTest!.getId())
          }
          
          // Simply store this value for later sorting by tidyUpScheduleBeforeUse()...
          mTestArray.append(theTest!)
        }
      }
      else if (mbInManualTestsBlock == true) {
        // We are in the manual-tests block!
          // "<manual-tests>\n",
          // "<test id=\"2\" />\n",
          // "<test id=\"3\" />\n",
          // "<test id=\"4\" />\n",
          // "</manual-tests>\n",
        // Simply store this value for later sorting by tidyUpScheduleBeforeUse()...
        var tTestId = attributeDict.objectForKey("id") as String?
        SK_ASSERT(tTestId != nil)
        mManualTestArray.append(tTestId!)
      } else if (mbInInitBlock == true) {
        // This is OK
      } else if (mbInScheduledTestsBlock == true) {
        // This is OK - ignore it
      } else {
        // We in some unexpected block!
        SK_ASSERT(false)
      }
      
    case "host":
      #if DEBUG
      println("DEBUG: host")
      #endif // DEBUG
      let theHost = SKScheduleHost()
      var tDnsNameValue:AnyObject? = attributeDict.objectForKey("dnsName")
      if let theDnsName = tDnsNameValue as? String {
        theHost.dnsName = theDnsName
      } else {
        SK_ASSERT(false)
      }
      var tDisplayNameValue:AnyObject? = attributeDict.objectForKey("displayName")
      if let theDisplayName = tDisplayNameValue as? String {
        theHost.displayName = theDisplayName
      } else {
        SK_ASSERT(false)
      }
      mHostArray.append(theHost)
      #if DEBUG
      println("DEBUG: got Host: \(theHost)")
      #endif // DEBUG
      
    case "data-cap-default":
      println("data-cap-default")
      // Extract the data cap, if any.
      // "downstreamthroughput\" test-id=\"2\"
      var tDataCap = attributeDict.objectForKey("value") as String?
      if (SK_VERIFY(tDataCap != nil) == true) {
        mDataCapMbps = tDataCap!.skDoubleValue
        SK_ASSERT(mDataCapMbps > 0)
      }
      break
      
    case "param":
      //println("DEBUG: param: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      var tName:String? = attributeDict.objectForKey("name") as? String
      SK_ASSERT(tName != nil)
      var tValue:AnyObject? = attributeDict.objectForKey("value")
      if let valueString = tValue as? String {
        if (mInTest_ClosestTarget != nil) {
           mInTest_ClosestTarget!.mTargetArray.append(valueString)
        } else if (mInTest_Download != nil) {
          if (tName == "target") {
            mInTest_Download!.mTarget = valueString
          } else if (tName == "port") {
            mInTest_Download!.mPort = valueString.skIntValue
          } else if (tName == "file") {
            mInTest_Download!.mFile = valueString
          } else if (tName == "warmupmaxtime") {
            let valueNumber = tValue as NSString
            mInTest_Download!.mWarmupMaxTimeSeconds = valueString.skDoubleValue
            mInTest_Download!.mWarmupMaxTimeSeconds /= 1000000.0
          } else if (tName == "transfermaxtime") {
            mInTest_Download!.mTransferMaxTimeSeconds = valueString.skDoubleValue
            mInTest_Download!.mTransferMaxTimeSeconds /= 1000000.0
          } else if (tName == "numberofthreads") {
            mInTest_Download!.mNumberOfThreads = valueString.skIntValue
          } else if (tName == "buffersize") {
            mInTest_Download!.mBufferSizeBytes = valueString.skIntValue
          } else {
            SK_ASSERT(false)
          }
        } else if (mInTest_Upload != nil) {
          if (tName == "target") {
            mInTest_Upload!.mTarget = valueString
          } else if (tName == "port") {
            mInTest_Upload!.mPort = valueString.skIntValue
          } else if (tName == "warmupmaxtime") {
             mInTest_Upload!.mWarmupMaxTimeSeconds = valueString.skDoubleValue
             mInTest_Upload!.mWarmupMaxTimeSeconds /= 1000000.0
          } else if (tName == "transfermaxtime") {
             mInTest_Upload!.mTransferMaxTimeSeconds = valueString.skDoubleValue
             mInTest_Upload!.mTransferMaxTimeSeconds /= 1000000.0
          } else if (tName == "numberofthreads") {
             mInTest_Upload!.mNumberOfThreads = valueString.skIntValue
//          } else if (tName == "buffersize") {
//             mInTest_Upload!.mBufferSizeBytes = valueString.skIntValue
          } else if (tName == "sendDataChunk") {
             mInTest_Upload!.mSendDataChunkSizeBytes = valueString.skIntValue
          } else if (tName == "postdatalength") {
             mInTest_Upload!.mPostDataLengthBytes = valueString.skIntValue
          } else {
            SK_ASSERT(false)
          }
        } else if (mInTest_Latency != nil) {
          if (tName == "target") {
            mInTest_Latency!.mTarget = valueString
          } else if (tName == "port") {
            mInTest_Latency!.mPort = valueString.skIntValue
          } else if (tName == "interPacketTime") {
             mInTest_Latency!.mInterPacketTimeSeconds = valueString.skDoubleValue
             mInTest_Latency!.mInterPacketTimeSeconds /= 1000000.0
          } else if (tName == "delayTimeout") {
             mInTest_Latency!.mDelayTimeoutSeconds = valueString.skDoubleValue
             mInTest_Latency!.mDelayTimeoutSeconds /= 1000000.0
          } else if (tName == "numberOfPackets") {
             mInTest_Latency!.mNumberOfPackets = valueString.skIntValue
          } else if (tName == "percentile") {
             mInTest_Latency!.mPercentile = valueString.skIntValue
          } else if (tName == "maxTime") {
             mInTest_Latency!.mMaxTimeSeconds = valueString.skDoubleValue
             mInTest_Latency!.mMaxTimeSeconds /= 1000000.0
          } else {
            SK_ASSERT(false)
          }
        }
      } else {
        SK_ASSERT(false)
      }
      
    case "condition":
      //println("TODO: condition? For Android: but not on iOS")
      //println("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      break
      
    case "conditions":
      //println("TODO: conditions? For Android: but not on iOS")
      //println("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      break
      
    case "condition-group":
      //println("TODO: condition-group? For Android: but not on iOS")
      //println("DEBUG: elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      break
      
    default:
      #if DEBUG
      println("DEBUG: UNKNOWN XML elementName: \(elementName) ATTRIBUTES: \(attributeDict)")
      SK_ASSERT(false)
      #endif // DEBUG
      break
    }
  }
  
  private func tidyUpScheduleBeforeUse() {
   
#if DEBUG 
    println("DEBUG: tidyUpScheduleBeforeUse()")
    println("DEBUG: PRE sort: mTestArray=\(mTestArray)")
#endif // DEBUG 
    
    var sortedArray:Array<SKScheduleTest> = []
   
    // We MUST ensure that we always have a closest target test, and that it is always run first!
    // So: if we have a closest target test, make it first in our sorted array.
    // If we don't have a closest target test, add one, and make it first in our sorted array.
    var foundClosestTargetTest = false
    for theTest in mTestArray {
      if let theClosestTargetTest = theTest as? SKScheduleTest_Descriptor_ClosestTarget {
        // We have a closest target test!
        // Always make it first!
        sortedArray.append(theClosestTargetTest)
        foundClosestTargetTest = true
        break
      }
    }
    if (foundClosestTargetTest == false) {
      // There was no closest target test.
      // Make sure we always have one, and make it first!
      SK_ASSERT(false)
      let thisTest = SKScheduleTest_Descriptor_ClosestTarget(identifier:closestTargetId)
      mTestArray.append(thisTest)
      sortedArray.append(thisTest)
    }
    
    //
    // Now, run through test in the preferred sort order, and add to the sorted array if not already there.
    //
    for manualTestId in mManualTestArray {
      var foundThisTest = false
      for theTest in mTestArray {
        if theTest.getId() == manualTestId {
          // Got the test!
          foundThisTest = true

          // Don't add it, if we already have it in the array...
          var alreadyListed = false
          for sortedArrayItem in sortedArray {
            if (manualTestId == sortedArrayItem.getId()) {
              alreadyListed = true
              SK_ASSERT(false)
              break;
            }
          }
          
          if (alreadyListed == false) {
            sortedArray.append(theTest)
          }
          break
        }
      }
      
      SK_ASSERT(foundThisTest == true)
    }
    
    // Finally, add any tests we've not already got...
    // Note that there should not be any of these...
    for theTest in mTestArray {
      var foundThisTest = false
      for sortedTest in sortedArray {
        if (sortedTest.getId() == theTest.getId()) {
          foundThisTest = true
          break
        }
      }
      
      if (foundThisTest == true) {
        // Already got it.
      } else {
        // It was missing from the manual-test list... looks like a problem with the schedule.
        // Make sure we keep the test, however...
        SK_ASSERT(false)
        sortedArray.append(theTest)
      }
    }
  
    //
    // Now, use the sorted array in preference.
    //
    SK_ASSERT(sortedArray.count == mTestArray.count)
    mTestArray = sortedArray
    
//    mTestArray.sort { (T1, T2) -> Bool in
//      // What order should we use?!
//      // If T1 < T2, then return false (etc.)
//      // What do we know? If T1 comes before T2 in the
//      T1.getId()
//      T2.getId()
//      return true
//    }
    
    //println("POST sort: mTestArray=\(mTestArray)")
    
  }
 
  // The following method, is the only way to create an instance of SKTestRunner.
  // This guarantees that the "test plan" is properly constructed, properly ordered etc.
  // Actually, this will create and return the SKTestManager instance
  public func createTestRunner() -> (SKTestRunner) {
    tidyUpScheduleBeforeUse()
    
    return SKTestRunner(fromScheduleParser:self)
  }
  
  // TODO: unit test to verify that the closest target test is always first in the schedule,
  //       whether that comes from the build-in test schedule, or those that are downloaded dynamically.
  
  public func helloWorld() {
    println("SKKit: helloWorld!")
  }
}

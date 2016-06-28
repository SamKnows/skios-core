//
//  SKKitTestHTTP.swift
//  SKKit
//
//  Created by Pete Cole on 27/06/2016.
//  Copyright © 2016 SamKnows. All rights reserved.
//

import UIKit

public class SKHttpTestResult {
  public let mSuccess:Bool
  
  // TCP connect time: The time taken to execute the "connect(...)" system call
  public let mTimeToConnect:NSTimeInterval

  // Time to first byte: Time taken from connect() to the end of the first recv() call
  public let mTimeToFirstByte:NSTimeInterval
  
  // HTML page load time: Time taken for the whole transaction (from connect() to the last byte being received)
  public let mTimeToPageLoad:NSTimeInterval
  
  public init(success:Bool, timeToConnect:NSTimeInterval, timeToFirstByte:NSTimeInterval, timeToPageLoad:NSTimeInterval) {
    mSuccess = success
    mTimeToConnect = timeToConnect
    mTimeToFirstByte = timeToFirstByte
    mTimeToPageLoad = timeToPageLoad

  }
}

public class SKKitTestHTTP: NSObject, SKKitTestProtocol {
  
  public var mSKHttpTestResult = SKHttpTestResult(success:false, timeToConnect:0.0, timeToFirstByte:0.0, timeToPageLoad:0.0)
  
  private var mHostName:String = ""
  private var mPort:Int = 0
  private var mTimeoutSeconds:Int = 0
  public  private(set) var mBytesRead:Int = 0

  public init(hostname:String, port:Int, timeoutSeconds:Int) {
    super.init()
    
    mHostName = hostname
    mPort = port
    mTimeoutSeconds = timeoutSeconds
    
    SK_ASSERT(mTimeoutSeconds > 1)
  }
  
  public func testHTTPQuery() -> SKHttpTestResult {
    
    print ("Test HTTP Query from \(mHostName), port=\(mPort)")
    let client:TCPClient = TCPClient(addr:mHostName, port:mPort)
    
    let startConnect = NSDate()
    let (success, errmsg) = client.connect(timeout: mTimeoutSeconds)
    
    if (success == false) {
      //print("Error=\(errmsg)")
      SK_ASSERT(false)
      return mSKHttpTestResult
    } else {
      let doneConnect = NSDate()
      let timeToConnect = doneConnect.timeIntervalSinceDate(startConnect)
      SK_ASSERT(Int(timeToConnect) < mTimeoutSeconds)
      print ("TCP connection time seconds = \(String(format:"%0.6f", timeToConnect))")
      
      let startFirstByte = NSDate()
      let (success, errmsg) = client.send(str:"GET / HTTP/1.0\n\n" )
      if (success == false) {
        //print("Error=\(errmsg)")
        SK_ASSERT(false)
        return mSKHttpTestResult
      } else {
        
        let readData = NSMutableData()
        
        var data = client.read(1, timeout:mTimeoutSeconds)
        guard let d = data else {
          SK_ASSERT(false)
          return mSKHttpTestResult
        }
        if (d.count != 1) {
          SK_ASSERT(false)
          return mSKHttpTestResult
        }
        
        let doneFirstByte = NSDate()
          
        self.mBytesRead += d.count
        readData.appendBytes(d, length: d.count)
        
        let timeSoFar = NSDate().timeIntervalSinceDate(startConnect)
        if (timeSoFar > Double(mTimeoutSeconds)) {
          // Timeout!
          SK_ASSERT(false)
          return mSKHttpTestResult
        }
          
        var keepGoing = true
        while (keepGoing) {
          data = client.read(1024*10, timeout: mTimeoutSeconds)
          guard let d = data else {
            SK_ASSERT(false)
            return mSKHttpTestResult
          }
         
          if (d.count > 0) {
            self.mBytesRead += d.count
            readData.appendBytes(d, length:d.count)
            //let str = String(bytes:d, length: d.count, encoding: NSUTF8StringEncoding)
            let timeSoFar = NSDate().timeIntervalSinceDate(startConnect)
            if (timeSoFar > Double(mTimeoutSeconds)) {
              // Timeout!
              SK_ASSERT(false)
              return mSKHttpTestResult
            }
          } else {
            let donePageLoad = NSDate()
            print("data end reached!")
            
            let timeToFirstByte = doneFirstByte.timeIntervalSinceDate(startFirstByte)
            print ("TCP time to first byte time seconds = \(String(format:"%0.6f", timeToFirstByte))")
            let timeToPageLoad = donePageLoad.timeIntervalSinceDate(startConnect)
            print ("TCP time to page load time seconds = \(String(format:"%0.6f", timeToFirstByte))")
            
            //let readString = String(data:readData, encoding:NSUTF8StringEncoding)
            //print ("Final read data = \(readString)")
            
            keepGoing = false
            mSKHttpTestResult = SKHttpTestResult(success:true, timeToConnect:timeToConnect, timeToFirstByte:timeToFirstByte, timeToPageLoad:timeToPageLoad)
            
            SK_ASSERT(mSKHttpTestResult.mSuccess == true)
            SK_ASSERT(mSKHttpTestResult.mTimeToConnect == timeToConnect)
            SK_ASSERT(Int(mSKHttpTestResult.mTimeToConnect) < mTimeoutSeconds)
            SK_ASSERT(mSKHttpTestResult.mTimeToFirstByte == timeToFirstByte)
            SK_ASSERT(mSKHttpTestResult.mTimeToPageLoad == timeToPageLoad)
            
            SK_ASSERT(mSKHttpTestResult.mTimeToConnect > 0.0)
            SK_ASSERT(mSKHttpTestResult.mTimeToFirstByte > 0.0)
            SK_ASSERT(mSKHttpTestResult.mTimeToPageLoad > mSKHttpTestResult.mTimeToConnect)
            
            SK_ASSERT(self.mBytesRead > 0)
            SKAppBehaviourDelegate.sGetAppBehaviourDelegate().amdDoUpdateDataUsage(Int32(self.mBytesRead))
            
            return mSKHttpTestResult
          }
        }
      }
    }
    
    SK_ASSERT(false)
    return mSKHttpTestResult
  }
  
  public func cancel() {
    // Nothing can be done here, as the test call is blocking...
  }
  
  public func getTestResultsDictionary() -> [NSObject : AnyObject]! {
    
    // Return dictionary of test results!
    
    let results:Dictionary<String,AnyObject> = [
      "type":"HTML",
      "datetime":SKGlobalMethods.sGetDateAsIso8601String(NSDate()),
      "timestamp":"\(Int(NSDate().timeIntervalSince1970))",
      "success":mSKHttpTestResult.mSuccess,
      "hostname":mHostName,
      "port":mPort,
      "timeout_seconds":mTimeoutSeconds,
      "time_to_connect_seconds":mSKHttpTestResult.mTimeToConnect,
      "time_to_first_byte_seconds":mSKHttpTestResult.mTimeToFirstByte,
      "time_to_page_load_seconds":mSKHttpTestResult.mTimeToPageLoad
    ]
    
    return results
  }
}

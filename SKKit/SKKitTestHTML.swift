//
//  SKKitTestHTML.swift
//  SKKit
//
//  Created by Pete Cole on 27/06/2016.
//  Copyright © 2016 SamKnows. All rights reserved.
//

import UIKit

public class SKHTMLTestResult {
  
  public var mTimestamp = Int(Date().timeIntervalSince1970)
  
  // Set to var to allow mocking!
  public var mSuccess:Bool = false
  
  // TCP connect time: The time taken to execute the "connect(...)" system call
  public var mTimeToConnect:TimeInterval = 0

  // Time to first byte: Time taken from connect() to the end of the first recv() call
  public var mTimeToFirstByte:TimeInterval = 0
  
  // HTML page load time: Time taken for the whole transaction (from connect() to the last byte being received)
  public var mTimeToPageLoad:TimeInterval = 0
  
  public init(success:Bool, timeToConnect:TimeInterval, timeToFirstByte:TimeInterval, timeToPageLoad:TimeInterval) {
    mSuccess = success
    mTimeToConnect = timeToConnect
    mTimeToFirstByte = timeToFirstByte
    mTimeToPageLoad = timeToPageLoad

  }
}

public class SKKitTestHTML: NSObject, SKKitTestProtocol {

  public var mSKHTMLTestResult = SKHTMLTestResult(success:false, timeToConnect:0.0, timeToFirstByte:0.0, timeToPageLoad:0.0)
  
  private var mHostName:String = ""
  private var mPort:Int = 0
  private var mTimeoutSeconds:Int = 0
  private var mUrlToGet = "/"
  public  private(set) var mBytesRead:Int = 0
  
  public func getHostName() -> String {
    return mHostName
  }

  public init(hostname:String, port:Int, timeoutSeconds:Int, urlToGet:String? = "/") {
    super.init()
    
    mHostName = hostname
    mPort = port
    mTimeoutSeconds = timeoutSeconds
    mUrlToGet = urlToGet!
    
    SK_ASSERT(mTimeoutSeconds >= 1)
  }
  
  public func testHTMLQuery() -> SKHTMLTestResult {
    
    mSKHTMLTestResult.mTimestamp = Int(Date().timeIntervalSince1970)
    
    print ("Test HTTP Query from \(mHostName), port=\(mPort)")
    let client:TCPClient = TCPClient(addr:mHostName, port:mPort)
    
    let startConnect = Date()
    let (success, errmsg) = client.connect(timeout: mTimeoutSeconds)
    
    if (success == false) {
      print("Error=\(errmsg)")
      SK_ASSERT(false)
      return mSKHTMLTestResult
    } else {
      let doneConnect = Date()
      let timeToConnect = doneConnect.timeIntervalSince(startConnect)
      SK_ASSERT(Int(timeToConnect) < (mTimeoutSeconds + 3)) // Sometimes the timeout is ignored by iOS!
      print ("TCP connection time seconds = \(String(format:"%0.6f", timeToConnect))")
      
      let (success,  _ /* errmsg*/ ) = client.send(str:"GET \(mUrlToGet) HTTP/1.0\n\n" )
      if (success == false) {
        //print("Error=\(errmsg)")
        SK_ASSERT(false)
        return mSKHTMLTestResult
      } else {
        
        let readData = NSMutableData()
        
        var data = client.read(1, timeout:mTimeoutSeconds)
        guard let d = data else {
          SK_ASSERT(false)
          return mSKHTMLTestResult
        }
        if (d.count != 1) {
          SK_ASSERT(false)
          return mSKHTMLTestResult
        }
        
        let doneFirstByte = Date()
          
        self.mBytesRead += d.count
        readData.append(d, length: d.count)
        
        let timeSoFar = Date().timeIntervalSince(startConnect)
        if (timeSoFar > Double(mTimeoutSeconds)) {
          // Timeout!
          SK_ASSERT(false)
          return mSKHTMLTestResult
        }
          
        var keepGoing = true
        while (keepGoing) {
          data = client.read(1024*10, timeout: mTimeoutSeconds)
          guard let d = data else {
            SK_ASSERT(false)
            return mSKHTMLTestResult
          }
         
          if (d.count > 0) {
            self.mBytesRead += d.count
            readData.append(d, length:d.count)
            //let str = String(bytes:d, length: d.count, encoding: NSUTF8StringEncoding)
            let timeSoFar = Date().timeIntervalSince(startConnect)
            if (timeSoFar > Double(mTimeoutSeconds) + 0.2) {
              // Timeout!
              SK_ASSERT(false)
              return mSKHTMLTestResult
            }
          } else {
            let donePageLoad = Date()
            print("data end reached!")
            
            let timeToFirstByte = doneFirstByte.timeIntervalSince(startConnect)
            print ("TCP time to first byte time seconds = \(String(format:"%0.6f", timeToFirstByte))")
            let timeToPageLoad = donePageLoad.timeIntervalSince(startConnect)
            print ("TCP time to page load time seconds = \(String(format:"%0.6f", timeToFirstByte))")
            
            //let readString = String(data:readData, encoding:NSUTF8StringEncoding)
            //print ("Final read data = \(readString)")
            
            keepGoing = false
            mSKHTMLTestResult = SKHTMLTestResult(success:true, timeToConnect:timeToConnect, timeToFirstByte:timeToFirstByte, timeToPageLoad:timeToPageLoad)
            
            SK_ASSERT(mSKHTMLTestResult.mSuccess == true)
            SK_ASSERT(mSKHTMLTestResult.mTimeToConnect == timeToConnect)
            SK_ASSERT(Int(mSKHTMLTestResult.mTimeToConnect) < mTimeoutSeconds)
            SK_ASSERT(mSKHTMLTestResult.mTimeToFirstByte > mSKHTMLTestResult.mTimeToConnect)
            SK_ASSERT(mSKHTMLTestResult.mTimeToPageLoad == timeToPageLoad)
            
            SK_ASSERT(mSKHTMLTestResult.mTimeToConnect > 0.0)
            SK_ASSERT(mSKHTMLTestResult.mTimeToFirstByte > 0.0)
            SK_ASSERT(mSKHTMLTestResult.mTimeToPageLoad > mSKHTMLTestResult.mTimeToConnect)
            
            SK_ASSERT(self.mBytesRead > 0)
            SKAppBehaviourDelegate.sGet()?.amdDoUpdateDataUsage(Int32(self.mBytesRead))
            
            return mSKHTMLTestResult
          }
        }
      }
    }

  }
  
  public func getTestResultValueString() -> String! {
    
    if (mSKHTMLTestResult.mSuccess) {
      return "\(Int(mSKHTMLTestResult.mTimeToPageLoad * 1000.0)) ms"
    }
    
    return "Failed"
  }
  
  public func getTestResultStatus() -> SKKitTestResultStatus {
    return SKKitTestResultStatus_Passed_Green // TODO!
  }
  
  //SK_ASSERT(false)
  //return mSKHTMLTestResult
  public func cancel() {
    // Nothing can be done here, as the test call is blocking...
  }
  
  public func getTestType() -> SKKitTestType {
    return SKKitTestType_Html
  }
  
  public func getTestResultsDictionary() -> [AnyHashable : Any]! {
    
    // Return dictionary of test results!
    
    let datetime = SKGlobalMethods.sGetDate(asIso8601String: Date())!
    
    let results:Dictionary<String,Any> = [
      "type":"WWW",
      "datetime":datetime,
      "timestamp":"\(mSKHTMLTestResult.mTimestamp)",
      "success":mSKHTMLTestResult.mSuccess,
      "hostname":mHostName,
      "port":mPort,
      "timeout":Int(mTimeoutSeconds*1000000), // Microseconds!
      "time_to_connect":Int(mSKHTMLTestResult.mTimeToConnect*1000000.0), // Microseconds!
      "time_to_first_byte":Int(mSKHTMLTestResult.mTimeToFirstByte*1000000.0), // Microseconds!
      "time_to_page_load":Int(mSKHTMLTestResult.mTimeToPageLoad*1000000.0) // Microseconds!
    ]
    
    return results as [NSObject : Any]
  }
}

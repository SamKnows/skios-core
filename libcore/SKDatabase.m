//
//  SKDatabase.m
//
//  Copyright (c) 2011-2014 SamKnows Limited. All rights reserved.
//

#import "SKDatabase.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "SKTestResults.h"

#import <AddressBook/AddressBook.h>

@implementation SKDatabase

+ (NSString *)dbPath
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
  NSString *docDirectory = [paths objectAtIndex:0];
  return [docDirectory stringByAppendingPathComponent:@"datastore.sqlite"];
}

+(void) sEmptyTheDatabase {
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM latency"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM packetloss"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM jitter"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM download"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM upload"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM test_data"];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"DELETE FROM metrics;"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return;
}

// https://stackoverflow.com/questions/7408828/ios-sqlite3-open-fails-the-50th-time-that-is-called

+(FMDatabase*) openDatabase {
  FMDatabase *db = [FMDatabase databaseWithPath:[SKDatabase dbPath]];
  if (db == NULL) {
    SK_ASSERT(false);
  }
  
  if ([db open]) {
    return db;
  }
      
  SK_ASSERT(false);
  
  NSLog(@"Could not open DB");
  
  return NULL;
}

#pragma mark - Database Creation

+ (BOOL)createEmptyDatabaseIfItDoesNotExist {
  if ([[NSFileManager defaultManager] fileExistsAtPath:[SKDatabase dbPath]]) {
    // Database already exists - nothing to do.
    return YES;
  }
  
  // Does not already exist - create (empty) database and open it!
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return NO;
  }
  
  BOOL bRes;
  
  // Latency
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE latency ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "test_id INTEGER NULL, "
          "test_name TEXT NULL, "
          "latency DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  // Packet Loss
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE packetloss ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "test_id INTEGER NULL, "
          "test_name TEXT NULL, "
          "packet_loss DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  
  // Jitter
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE jitter ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "test_id INTEGER NULL, "
          "test_name TEXT NULL, "
          "jitter DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  
  
  // Download
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE download ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "test_id INTEGER NULL, "
          "test_name TEXT NULL, "
          "bitrate DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  
  // Upload
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE upload ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "test_id INTEGER NULL, "
          "test_name TEXT NULL, "
          "bitrate DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  
  // Batch Test Data
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE test_data ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "valid INTEGER NOT NULL DEFAULT 1, "
          "date DATETIME NOT NULL, "
          "day TEXT NOT NULL, "
          "target TEXT NOT NULL, "
          "latitude DOUBLE NOT NULL, "
          "longitude DOUBLE NOT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  
  // Passive Metrics
  // These are not used in the EAQ app.
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"CREATE TABLE metrics ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
          "test_id INTEGER NOT NULL, "
          "device TEXT NULL, "
          "os TEXT NULL, "
          "carrier_name TEXT NULL, "
          "country_code TEXT NULL, "
          "iso_country_code TEXT NULL, "
          "network_code TEXT NULL)"];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  NSLog(@"Created DB");
  
  return YES;
}

// Create database - and upgrade it!
+ (void)createDatabase
{
  if ([SKDatabase createEmptyDatabaseIfItDoesNotExist] == NO) {
    SK_ASSERT(false);
    return;
  }
  
  // Now that we are sure that the database exists - try to upgrade it!
  [SKDatabase updateDatabase];
}

+(BOOL)checkExistsTable:(NSString*)table Column:(NSString*)column
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return NO;
  }
  
  sqlite3_stmt *selectStmt;
  
  BOOL bExists = NO;
  NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@", column, table];
  if(sqlite3_prepare_v2(db.sqliteHandle, [query UTF8String], -1, &selectStmt, NULL) == SQLITE_OK)
  {
    bExists = YES;
  }
  
  BOOL bRes;
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return bExists;
}

+ (void)updateDatabase {
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"wifi_ssid"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN wifi_ssid TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"municipality"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN municipality TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"country_string"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN country_string TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"latitude"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN latitude DOUBLE NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"longitude"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN longitude DOUBLE NULL"];
    SK_ASSERT(bRes);
    
    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"wlan_carrier"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN wlan_carrier TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"Public_IP"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN public_ip TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"Submission_ID"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN submission_id TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"network_type"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN network_type TEXT NULL"];
    SK_ASSERT(bRes);

    bRes = [db commit];
    SK_ASSERT(bRes);
  }
  
  if ([SKDatabase checkExistsTable:@"metrics" Column:@"radio_type"] == NO) {
    
    // New column that was not always present in the old version of the application.
    
    bRes = [db beginTransaction];
    SK_ASSERT(bRes);
    
    bRes = [db executeUpdate:@"ALTER TABLE metrics ADD COLUMN radio_type TEXT NULL"];
    SK_ASSERT(bRes);
    
    bRes = [db commit];
    SK_ASSERT(bRes);
  }

  // We don't want 'NULL' for the new column, as that would affect joins.
  bRes = [db executeUpdate:@"UPDATE metrics SET network_type = 'mobile' WHERE network_type IS NULL"];
  SK_ASSERT(bRes);
  
  // We don't want 'NULL' for the new column, as that would affect joins.
  bRes = [db executeUpdate:@"UPDATE metrics SET radio_type = 'Unknown' WHERE radio_type IS NULL"];
  SK_ASSERT(bRes);

  bRes = [db close];
  SK_ASSERT(bRes);
  
#ifdef DEBUG
  NSLog(@"DEBUG: Updated DB");
#endif // DEBUG
}

+ (NSNumber*)storeBatchTestMapData:(double)latitude longitude:(double)longitude target:(NSString*)target
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSNumber numberWithInt:0];
  }
  
  NSDate *dateTime = [SKCore getToday];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
 
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
   @"INSERT INTO test_data (date, day, latitude, longitude, target) values (?,?,?,?,?)",
   dateTime,
   [formatter stringFromDate:dateTime],
   [NSNumber numberWithDouble:latitude],
   [NSNumber numberWithDouble:longitude],
   target];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  FMResultSet *rs = [db executeQuery:@"SELECT MAX(id) from test_data"];
  
  int maxID = 0;
  while ([rs next])
  {
    maxID  = [rs intForColumnIndex:0];
    //NSLog(@"maxID : %d", maxID);
  }
  
  NSNumber *num = [NSNumber numberWithInt:maxID];
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return num;
}

//
// Save individual test values (download, upload, etc.)
//

// TODO - the following inserts must be modified, to insert a success code, where success is defined
// such that 0 is failure, and non-zero is success!

// The 'bitrate' value stored in the data base was calculated like this:
// bitrate = bytes * 8 / (1024 / 1024)
// The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
// bytes = (bitrate * 1024 * 1024) / 8
+ (void)storeDownload:(NSDate*)dateTime BitrateMbps1024Based:(double)bitrateMbps1024Based testId:(NSNumber*)testId testName:(NSString*)testName;
{
  if (testId == nil || testName == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"INSERT INTO download (date, day, bitrate, test_id, test_name) values (?,?,?,?,?)",
          dateTime,
          [formatter stringFromDate:dateTime],
          [NSNumber numberWithDouble:bitrateMbps1024Based],
          testId,
          testName];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

// The 'bitrate' value stored in the data base was calculated like this:
// bitrate = bytes * 8 / (1024 / 1024)
// The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
// bytes = (bitrate * 1024 * 1024) / 8
+ (void)storeUpload:(NSDate*)dateTime BitrateMbps1024Based:(double)bitrateMbps1024Based testId:(NSNumber*)testId testName:(NSString*)testName;
{
  if (testId == nil || testName == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"INSERT INTO upload (date, day, bitrate, test_id, test_name) values (?,?,?,?,?)",
          dateTime,
          [formatter stringFromDate:dateTime],
          [NSNumber numberWithDouble:bitrateMbps1024Based],
          testId,
          testName];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (void)storeLatency:(NSDate*)dateTime latency:(double)latency testId:(NSNumber*)testId testName:(NSString*)testName;
{
  if (testId == nil || testName == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"INSERT INTO latency (date, day, latency, test_id, test_name) values (?,?,?,?,?)",
          dateTime,
          [formatter stringFromDate:dateTime],
          [NSNumber numberWithDouble:latency],
          testId,
          testName];
  SK_ASSERT(bRes);
  
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (void)storePacketLoss:(NSDate*)dateTime packetLoss:(double)packetLoss testId:(NSNumber*)testId testName:(NSString*)testName;
{
  if (testId == nil || testName == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
   @"INSERT INTO packetloss (date, day, packet_loss, test_id, test_name) values (?,?,?,?,?)",
   dateTime,
   [formatter stringFromDate:dateTime],
   [NSNumber numberWithDouble:packetLoss],
   testId,
   testName];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (void)storeJitter:(NSDate*)dateTime jitter:(double)jitter testId:(NSNumber*)testId testName:(NSString*)testName;
{
  if (testId == nil || testName == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:
          @"INSERT INTO jitter (date, day, jitter, test_id, test_name) values (?,?,?,?,?)",
          dateTime,
          [formatter stringFromDate:dateTime],
          [NSNumber numberWithDouble:jitter],
          testId,
          testName];
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

// The 'bitrate' value stored in the data base was calculated like this:
// bitrate = bytes * 8 / (1024 / 1024)
// The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
// bytes = (bitrate * 1024 * 1024) / 8
+ (NSDictionary*)getDownloadResultsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = @"SELECT bitrate, test_name FROM download WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    double result = [rs doubleForColumnIndex:0];
    NSString *testName = [rs stringForColumnIndex:1];
  
    // result = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:[NSNumber numberWithDouble:result] forKey:@"RESULT"];
    [dict setObject:testName forKey:@"DISPLAY_NAME"];
  }
  
   
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

// The 'bitrate' value stored in the data base was calculated like this:
// bitrate = bytes * 8 / (1024 / 1024)
// The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
// bytes = (bitrate * 1024 * 1024) / 8
+ (NSDictionary*)getUploadResultsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = @"SELECT bitrate, test_name FROM upload WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    double result = [rs doubleForColumnIndex:0];
    NSString *testName = [rs stringForColumnIndex:1];
    
    // result = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:[NSNumber numberWithDouble:result] forKey:@"RESULT"];
    [dict setObject:testName forKey:@"DISPLAY_NAME"];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

+ (NSDictionary*)getLatencyResultsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = @"SELECT latency, test_name FROM latency WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    double result = [rs doubleForColumnIndex:0];
    NSString *testName = [rs stringForColumnIndex:1];
    
    // result = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:[NSNumber numberWithDouble:result] forKey:@"RESULT"];
    [dict setObject:testName forKey:@"DISPLAY_NAME"];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

+ (NSDictionary*)getLossResultsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = @"SELECT packet_loss, test_name FROM packetloss WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    double result = [rs doubleForColumnIndex:0];
    NSString *testName = [rs stringForColumnIndex:1];
    
    // result = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:[NSNumber numberWithDouble:result] forKey:@"RESULT"];
    [dict setObject:testName forKey:@"DISPLAY_NAME"];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}


+ (NSDictionary*)getJitterResultsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = @"SELECT jitter, test_name FROM jitter WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    double result = [rs doubleForColumnIndex:0];
    NSString *testName = [rs stringForColumnIndex:1];
    
    // result = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:[NSNumber numberWithDouble:result] forKey:@"RESULT"];
    [dict setObject:testName forKey:@"DISPLAY_NAME"];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

// Used only by SKA project, as EAQ project doesn't save metrics!
+ (NSMutableDictionary*)getMetricsForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return nil;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  NSString *sql = nil;
  
  sql = @"SELECT device, os, carrier_name, country_code, iso_country_code, network_code, network_type, radio_type FROM metrics WHERE test_id=?;";
  
  FMResultSet *rs = [db executeQuery:sql, testId];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    NSString *device = [rs stringForColumnIndex:0];
    NSString *os = [rs stringForColumnIndex:1];
    NSString *carrier_name = [rs stringForColumnIndex:2];
    NSString *country_code = [rs stringForColumnIndex:3];
    NSString *iso_country_code = [rs stringForColumnIndex:4];
    NSString *network_code = [rs stringForColumnIndex:5];
    NSString *network_type = [rs stringForColumnIndex:6];
    NSString *radio_type = [rs stringForColumnIndex:7];
   
    if (device == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:device              forKey:@"DEVICE"];
    }
    
    if (os == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:os                  forKey:@"OS"];
    }
    
    if (carrier_name == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:carrier_name        forKey:@"CARRIER_NAME"];
    }
    
    if (country_code == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:country_code        forKey:@"COUNTRY_CODE"];
    }
    
    if (iso_country_code == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:iso_country_code    forKey:@"ISO_CODE"];
    }
    
    if (network_code == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:network_code        forKey:@"NETWORK_CODE"];
    }
    
    if (network_type == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:network_type        forKey:@"NETWORK_TYPE"];
    }
    
    if (radio_type == nil) {
      SK_ASSERT(false);
    } else {
      [dict setObject:radio_type          forKey:@"RADIO_TYPE"];
    }
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

/*
In Android, we save a metric of type "activenetworktype" with a value equal to one of the
following string values...
... noting that we only display values which are for the value of type 'Mobile'
(ACTIVENETWORKTYPE == 'Mobile'...)...!
 
public static String convertConnectivityType(int type) {
  int string_id = R.string.unknown;
  switch (type) {
    case ConnectivityManager.TYPE_BLUETOOTH:
      string_id = R.string.bluetooth;
      break;
    case ConnectivityManager.TYPE_ETHERNET:
      string_id = R.string.ethernet;
      break;
    case ConnectivityManager.TYPE_MOBILE_DUN:
      string_id = R.string.mobile_dun;
      break;
    case ConnectivityManager.TYPE_MOBILE_HIPRI:
      string_id = R.string.mobile_hipri;
      break;
    case ConnectivityManager.TYPE_MOBILE_MMS:
      string_id = R.string.mobile_mms;
      break;
    case ConnectivityManager.TYPE_MOBILE_SUPL:
      string_id = R.string.mobile_supl;
      break;
    case ConnectivityManager.TYPE_WIFI:
      string_id = R.string.wifi;
      break;
    case ConnectivityManager.TYPE_MOBILE:
      string_id = R.string.mobile;
      break;
    case ConnectivityManager.TYPE_WIMAX:
      string_id = R.string.wimax;
      break;
      
  }
  return SK2AppSettings.getInstance().getResourceString(string_id);
}
*/


+ (void)updateMetricForTestId:(NSNumber*)testId
              MetricColumn:(NSString*)metricColumn
                 MetricValue:(NSString*)metricValue
{
  if (testId == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if ( ([metricColumn isEqualToString:@"Public_IP"])  ||
       ([metricColumn isEqualToString:@"Submission_ID"])
      )
  {
    // Column is one we expect!
  }
  else
  {
    // Not OK!
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  NSString *theSql = [NSString stringWithFormat:@"UPDATE metrics set %@=? where test_id=?", metricColumn];
  
  bRes = [db executeUpdate:
          theSql,
          metricValue,
          testId];
  
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+(void) forTestId:(NSNumber*)testId WriteLocation:(CLLocation*)location Municipality:(NSString*)municipality AndCountryString:(NSString*)countryString {
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  if (location != nil) {
    bRes = [db executeUpdate:
            @"UPDATE metrics SET longitude = ?, latitude = ? WHERE test_id=?", [NSNumber numberWithDouble:location.coordinate.longitude], [NSNumber numberWithDouble:location.coordinate.latitude], testId];
    SK_ASSERT(bRes);
  }
 
  if (municipality != nil && municipality.length > 0) {
    bRes = [db executeUpdate:
            @"UPDATE metrics SET municipality = ? WHERE test_id=?", municipality, testId];
    SK_ASSERT(bRes);
  }
  
  if (countryString != nil && countryString.length > 0) {
    bRes = [db executeUpdate:
            @"UPDATE metrics SET country_string = ? WHERE test_id=?", countryString, testId];
    SK_ASSERT(bRes);
  }
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+(void) forTestId:(NSNumber*)testId WriteWlanCarrier:wlanCarrier {
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  if (wlanCarrier != nil) {
    bRes = [db executeUpdate:
            @"UPDATE metrics SET wlan_carrier = ? WHERE test_id=?", wlanCarrier, testId];
    SK_ASSERT(bRes);
  }
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (void)storeMetrics:(NSNumber*)testId
              device:(NSString*)device
                  os:(NSString*)os
         carrierName:(NSString*)carrierName
         countryCode:(NSString*)countryCode
             isoCode:(NSString*)isoCode
         networkCode:(NSString*)networkCode
         networkType:(NSString*)networkType
           radioType:(NSString*)radioType
              target:(NSString*)target
{
  if (testId == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  SK_ASSERT([networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE] || [networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI]);
  
  NSString *wifi_ssid = [SKGlobalMethods sCurrentWifiSSID];
  if (wifi_ssid == nil) {
    wifi_ssid = @"";
  }
  
  SK_ASSERT([networkType isEqualToString:C_NETWORKTYPEASSTRING_WIFI] || [networkType isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]);
  
  bRes = [db executeUpdate:
          @"INSERT INTO metrics (test_id, device, os, carrier_name, country_code, iso_country_code, network_code, network_type, radio_type, wifi_ssid) values (?,?,?,?,?,?,?,?,?,?)",
          testId,
          device,
          os,
          carrierName,
          countryCode,
          isoCode,
          networkCode,
          networkType,
          radioType,
          wifi_ssid
          ];
  
  SK_ASSERT(bRes);
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  if ([CLLocationManager locationServicesEnabled]) {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    SK_ASSERT(locationManager != nil);
    SK_ASSERT(locationManager.location != nil);
    
    CLLocation *location = locationManager.location;
    if (location != nil) {
      
      CLGeocoder *geocoder = [[CLGeocoder alloc] init];
      
      [geocoder reverseGeocodeLocation:location completionHandler:
       ^(NSArray* placemarks, NSError* error){
         SK_ASSERT([NSThread isMainThread]);
         
         for (CLPlacemark *placemark in placemarks) {
           NSString *municipality = @"";
           NSString *countryString = @"";
           
           if (placemark.addressDictionary != nil) {
             NSString *cityString = [placemark.addressDictionary objectForKey:(NSString*) kABPersonAddressCityKey];
             
             if (cityString != nil) {
               municipality = cityString;
             }
           }
           if (placemark.country != nil) {
             countryString = placemark.country;
           }
           
           [SKDatabase forTestId:testId WriteLocation:location Municipality:municipality AndCountryString:countryString];
           
           break;
         }
       }];
    }
  }
  
  // TODO - change this query for the wlan_carrier!
  dispatch_async(dispatch_get_main_queue(), ^{
    [SKNSURLAsyncQuery fireURLRequest:@"http://ipinfo.io/json" InjectDictionaryIntoHeader:nil JsonCallback:^(NSError *error, NSInteger responseCode, NSDictionary *jsonResponse,  NSDictionary *responseHeaders) {
      
      if (jsonResponse == nil) {
        
        SK_ASSERT(false);
        
      } else {
        
        if([jsonResponse objectForKey:@"org"] == nil) {
          SK_ASSERT(false);
        } else {
          __block NSString *wlanCarrier = jsonResponse[@"org"];
          
          dispatch_async(dispatch_get_main_queue(), ^{
            [SKDatabase forTestId:testId WriteWlanCarrier:wlanCarrier];
          });
        }
      }
    }];
  });
}

+ (void)removeTestDataForTestId:(NSNumber*)testId
{
  if (testId == nil) {
    SK_ASSERT(false);
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  bRes = [db executeUpdate:@"UPDATE test_data SET valid=? WHERE id=?;", [NSNumber numberWithInt:0], testId];
  SK_ASSERT(bRes);
  
  
  //                [db executeUpdate:@"DELETE FROM download WHERE test_id=?;", testId];
  //                [db executeUpdate:@"DELETE FROM upload WHERE test_id=?;", testId];
  //                [db executeUpdate:@"DELETE FROM latency WHERE test_id=?;", testId];
  //                [db executeUpdate:@"DELETE FROM packetloss WHERE test_id=?;", testId];
  //                [db executeUpdate:@"DELETE FROM jitter WHERE test_id=?;", testId];
  //                [db executeUpdate:@"DELETE FROM test_data WHERE id=?;", testId];
  //                [db commit];
  //                [db close];
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (void)storeData:(NSDictionary*)data dataType:(TestDataType)dataType
{
  if ([FMDatabase isThreadSafe]) {
    NSLog(@"FMDatabase is thread safe!");
  } else {
    NSLog(@"FMDatabase is NOT thread safe!!!");
    SK_ASSERT(false);
  }
  
  if (data == nil) {
    SK_ASSERT(false);
    return;
  }
  
  if ([data count] == 0) {
    // Nothing to save!
    return;
  }
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return;
  }
  
  NSString *sql = nil;
  
  // The 'bitrate' value stored in the data base was calculated like this:
  // bitrate = bytes * 8 / (1024 / 1024)
  // The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
  // bytes = (bitrate * 1024 * 1024) / 8
  if (dataType == DOWNLOAD_DATA)
  {
    sql = @"INSERT INTO download (date, day, bitrate) values (?,?,?);";
  }
  else if (dataType == UPLOAD_DATA)
  {
    sql = @"INSERT INTO upload (date, day, bitrate) values (?,?,?);";
  }
  else if (dataType == LATENCY_DATA)
  {
    sql = @"INSERT INTO latency (date, day, latency) values (?,?,?);";
  }
  else if (dataType == LOSS_DATA)
  {
    sql = @"INSERT INTO packetloss (date, day, packet_loss) values (?,?,?);";
  }
  else if (dataType == JITTER_DATA)
  {
    sql = @"INSERT INTO jitter (date, day, jitter) values (?,?,?);";
  }
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  
  BOOL bRes;
  
  bRes = [db beginTransaction];
  SK_ASSERT(bRes);
  
  NSEnumerator *enumerator = [data keyEnumerator];
  id key;
  
  while ((key = [enumerator nextObject]))
  {
    NSString *strDate = (NSString*)key;
    NSDate *date = [formatter dateFromString:strDate];
    
    NSString *value = [data valueForKey:key];
    NSNumber *doubleValue = [NSNumber numberWithDouble:[value doubleValue]];
    
    [db executeUpdate:sql, date, strDate, doubleValue];
  }
  
  bRes = [db commit];
  SK_ASSERT(bRes);
  
  bRes = [db close];
  SK_ASSERT(bRes);
}

+ (double)getAverageTestDataJoinToMetrics:(NSDate*)fromDate toDate:(NSDate*)toDate testDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals  {
  return [SKDatabase getAverageTestDataJoinToMetrics:fromDate toDate:toDate testDataType:testDataType WhereNetworkTypeAsStringEquals:whereNetworkTypeAsStringEquals RetCount:NULL];
}

+ (double)getAverageTestDataJoinToMetrics:(NSDate*)fromDate toDate:(NSDate*)toDate testDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals  RetCount:(int*)retCount
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return 0.0;
  }
  
  NSString *sql = nil;
  double result = 0;
  
  NSString *joinClause = @"";
  if (whereNetworkTypeAsStringEquals != nil) {
    if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
      
      // WiFi
      joinClause = @" AS A, metrics WHERE a.test_id = metrics.test_id AND network_type = 'network' AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      
      // mobile
      joinClause = @" AS A, metrics WHERE a.test_id = metrics.test_id AND network_type = 'mobile' AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      joinClause = @" AS A WHERE A.date BETWEEN ? AND ? ";
      
    } else {
      SK_ASSERT(false);
    }
  }
 
  // TODO - this must be modified, to query ONLY where "success <> 0", where success is defined
  // as a non-zerovalue (failure is zero)!!
  // The 'bitrate' value stored in the data base was calculated like this:
  // bitrate = bytes * 8 / (1024 / 1024)
  // The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
  // bytes = (bitrate * 1024 * 1024) / 8
  if (testDataType == DOWNLOAD_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT AVG(bitrate), COUNT(bitrate) FROM download %@ ORDER BY date DESC;", joinClause];
  }
  else if (testDataType == UPLOAD_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT AVG(bitrate), COUNT(bitrate) FROM upload %@ ORDER BY date DESC;", joinClause];
  }
  else if (testDataType == LATENCY_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT AVG(latency), COUNT(latency) FROM latency %@ ORDER BY date DESC;", joinClause];
  }
  else if (testDataType == LOSS_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT AVG(packet_loss), COUNT(packet_loss) FROM packetloss %@ ORDER BY date DESC;", joinClause];
  }
  else if (testDataType == JITTER_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT AVG(jitter), COUNT(jitter) FROM jitter %@ ORDER BY date DESC;", joinClause];
  }
  else
  {
    SK_ASSERT(false);
  }
  
  FMResultSet *rs = [db executeQuery:sql, fromDate, toDate];
  SK_ASSERT(rs != nil);
 
  int count = 1;
  while ([rs next])
  {
    result = [rs doubleForColumnIndex:0];
    if (retCount != nil) {
      *retCount = [rs intForColumnIndex:1];
    }
    //NSLog(@"VALUE : %f", result);
    
    count++;
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return result;
}

+ (NSMutableArray*)getTestMetaDataWhereNetworkTypeEquals:(NSString*)whereNetworkTypeAsStringEquals
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableArray new];
  }
  
  NSString *joinClause = @"";
  if (whereNetworkTypeAsStringEquals != nil) {
    if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
      
      // WiFi
      joinClause = @", metrics WHERE td.id = metrics.test_id AND network_type = 'network' ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      
      // mobile
      joinClause = @", metrics WHERE td.id = metrics.test_id AND network_type = 'mobile' ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      joinClause = @" ";
      
    } else {
      SK_ASSERT(false);
    }
  }
  
  NSString * sql = [NSString stringWithFormat:@"SELECT td.id, td.date, td.target FROM test_data AS td %@ ORDER BY td.id DESC;", joinClause];
  
#ifdef DEBUG
  NSLog(@"DEBUG %s: sql=%@", __FUNCTION__, sql);
#endif // DEBUG
  
  NSMutableArray *results = [NSMutableArray array];
  
  FMResultSet *rs = [db executeQuery:sql];
  SK_ASSERT(rs != nil);
  
  //NSLog(@" ");
  while ([rs next])
  {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    int testId = [rs intForColumnIndex:0];
    NSNumber *date = [NSNumber numberWithDouble:[rs doubleForColumnIndex:1]];
    NSString *trg = [rs stringForColumnIndex:2];
    
    [dict setObject:[NSNumber numberWithInt:testId] forKey:@"TEST_ID"];
    [dict setObject:date forKey:@"DATE"];
    [dict setObject:trg forKey:@"TARGET"];
    
    //NSLog(@"SQL : %@", sql);
    //NSLog(@"Date: %@, ID: %d, Target : %@", date, testId, trg);
    
    [results addObject:dict];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return results;
}

//###HG

+ (NSMutableArray*)getTestDataForNetworkType:(NSString*)networkType_ afterDate:(NSDate*)minDate_
{
  SKATestResults* testResult;
  
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableArray new];
  }
  
  NSString *whereClause = @"";
  if (networkType_ != nil) {
    if ([networkType_ isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
      // WiFi
      whereClause = @"WHERE mt.network_type = 'network' ";
      
    } else if ([networkType_ isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      // mobile
      whereClause = @"WHERE mt.network_type = 'mobile' ";
      
    } else if ([networkType_ isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      whereClause = @"";
    } else {
      SK_ASSERT(false);
    }
  }
  
  if (minDate_ != nil) //Where caluse for date
  {
    if (whereClause.length > 0) whereClause = [NSString stringWithFormat:@"%@ AND ", whereClause];
    else
      whereClause = [NSString stringWithFormat:@"WHERE "];
    
    whereClause = [NSString stringWithFormat:@"%@%@", whereClause, @"td.date > ?"];
  }
  
  NSString * sql = [NSString stringWithFormat:@"SELECT td.id, td.date, td.target, dw.bitrate, ul.bitrate, lt.latency, ls.packet_loss, j.jitter, mt.device, mt.os, mt.carrier_name, mt.country_code, mt.iso_country_code, mt.network_code, mt.network_type, mt.radio_type, mt.public_ip, mt.submission_id, mt.wifi_ssid, mt.municipality, mt.country_string, mt.wlan_carrier FROM test_data AS td LEFT JOIN metrics AS mt ON td.id = mt.test_id LEFT JOIN download AS dw ON td.id = dw.test_id LEFT JOIN upload AS ul ON td.id = ul.test_id LEFT JOIN latency AS lt ON td.id = lt.test_id LEFT JOIN packetloss as ls ON td.id = ls.test_id LEFT JOIN jitter as j ON td.id = j.test_id %@ ORDER BY td.id DESC", whereClause];
  
  NSMutableArray *results = [NSMutableArray array];
  
  FMResultSet *rs = [db executeQuery:sql, minDate_];
  SK_ASSERT(rs != nil);
  
  while ([rs next])
  {
    testResult = [[SKATestResults alloc] init];
    testResult.testId = [rs intForColumnIndex:0];
    testResult.testDateTime = [NSDate dateWithTimeIntervalSince1970:[rs doubleForColumnIndex:1]];
    testResult.target = [rs stringForColumnIndex:2];
    
    if ([rs objectForColumnIndexReturnsNullNotNil:3] == [NSNull null])
      testResult.downloadSpeed1000Based = -1;
    else {
      double bitrate1024Based =  [rs doubleForColumnIndex:3];
      double bitrate1000Based = [SKGlobalMethods convertMbps1024BasedToMBps1000Based:bitrate1024Based];
      testResult.downloadSpeed1000Based = bitrate1000Based;
    }
    
    if ([rs objectForColumnIndexReturnsNullNotNil:4] == [NSNull null])
      testResult.uploadSpeed1000Based = -1;
    else {
      double bitrate1024Based = [rs doubleForColumnIndex:4];
      double bitrate1000Based = [SKGlobalMethods convertMbps1024BasedToMBps1000Based:bitrate1024Based];
      testResult.uploadSpeed1000Based = bitrate1000Based;
    }
    
    if ([rs objectForColumnIndexReturnsNullNotNil:5] == [NSNull null])
      testResult.latency = -1;
    else
      testResult.latency = [rs doubleForColumnIndex:5];
    
    if ([rs objectForColumnIndexReturnsNullNotNil:6] == [NSNull null])
      testResult.loss = -1;
    else {
      testResult.loss = [rs doubleForColumnIndex:6];
    }
    
    if ([rs objectForColumnIndexReturnsNullNotNil:7] == [NSNull null])
      testResult.jitter = -1;
    else
      testResult.jitter = [rs doubleForColumnIndex:7];
    
    NSMutableDictionary *metricsDictionary = [NSMutableDictionary new];
    if ([rs objectForColumnIndexReturnsNullNotNil:8] != [NSNull null]) {
      [metricsDictionary setObject:[rs stringForColumnIndex:8] forKey:SKB_TESTVALUERESULT_C_PM_DEVICE];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:9] != [NSNull null]) {
      [metricsDictionary setObject:[rs stringForColumnIndex:9] forKey:SKB_TESTVALUERESULT_C_PM_OS];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:10] != [NSNull null]) {
      [metricsDictionary setObject:[rs stringForColumnIndex:10] forKey:SKB_TESTVALUERESULT_C_PM_CARRIER_NAME];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:11] != [NSNull null]) {
      NSString *countryCode = [rs stringForColumnIndex:11];
      [metricsDictionary setObject:countryCode forKey:SKB_TESTVALUERESULT_C_PM_CARRIER_COUNTRY];
      NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:countryCode];
      if (countryName != nil) {
        [metricsDictionary setObject:countryName forKey:SKB_TESTVALUERESULT_C_PM_COUNTRY_NAME];
      }
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:12] != [NSNull null]) {
      NSString *isoCountryCode = [rs stringForColumnIndex:12];
      [metricsDictionary setObject:isoCountryCode forKey:SKB_TESTVALUERESULT_C_PM_ISO_COUNTRY_CODE];
      NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:isoCountryCode];
      if (countryName != nil) {
        [metricsDictionary setObject:countryName forKey:SKB_TESTVALUERESULT_C_PM_COUNTRY_NAME];
      }
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:13] != [NSNull null]) {
      [metricsDictionary setObject:[rs stringForColumnIndex:13] forKey:SKB_TESTVALUERESULT_C_PM_CARRIER_NETWORK];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:14] != [NSNull null]) {
      [metricsDictionary setObject:[rs stringForColumnIndex:14] forKey:SKB_TESTVALUERESULT_C_PM_NETWORK_TYPE];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:15] != [NSNull null]) {
      NSString *value = [rs stringForColumnIndex:15];
      SK_ASSERT([value isEqualToString:C_NETWORKTYPEASSTRING_WIFI] || [value isEqualToString:C_NETWORKTYPEASSTRING_MOBILE] ||[value isEqualToString:@"NA"]);
      [metricsDictionary setObject:value forKey:SKB_TESTVALUERESULT_C_PM_RADIO_TYPE];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:16] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:16] forKey:SKB_TESTVALUERESULT_C_PM_PUBLIC_IP];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:17] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:17] forKey:SKB_TESTVALUERESULT_C_PM_SUBMISSION_ID];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:18] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:18] forKey:SKB_TESTVALUERESULT_C_PM_WIFI_SSID];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:19] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:19] forKey:SKB_TESTVALUERESULT_C_PM_MUNICIPALITY];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:20] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:20] forKey:SKB_TESTVALUERESULT_C_PM_COUNTRY_NAME];
    }
    if ([rs objectForColumnIndexReturnsNullNotNil:21] != [NSNull null])
    {
      [metricsDictionary setObject:[rs stringForColumnIndex:21] forKey:SKB_TESTVALUERESULT_C_PM_WLAN_CARRIER];
    }
    
    testResult.metricsDictionary = metricsDictionary;
    
    [results addObject:testResult];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return results;
}

//+ (NSMutableArray*)getTestData:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals
+ (NSMutableArray*)getNonAveragedTestData:(NSDate*)fromDate ToDate:(NSDate*)toDate TestDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableArray new];
  }
  
  NSString *joinClause = @"";
  if (whereNetworkTypeAsStringEquals != nil) {
    if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
      
      // WiFi
      joinClause = @", metrics WHERE A.test_id = B.id AND A.test_id = metrics.test_id AND network_type = 'network'  AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      
      // mobile
      joinClause = @", metrics WHERE A.test_id = B.id AND A.test_id = metrics.test_id AND network_type = 'mobile'  AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      joinClause = @", metrics WHERE A.test_id = B.id AND A.test_id = metrics.test_id AND A.date BETWEEN ? AND ? ";
      
    } else {
      SK_ASSERT(false);
    }
  }
  
  NSString *sql = nil;
  
  // The 'bitrate' value stored in the data base was calculated like this:
  // bitrate = bytes * 8 / (1024 / 1024)
  // The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
  // bytes = (bitrate * 1024 * 1024) / 8
  if (testDataType == DOWNLOAD_DATA)
  {
    sql =[NSString stringWithFormat:@"SELECT A.date, AVG(A.bitrate), A.test_id, B.target, metrics.network_type FROM download AS A, test_data AS B %@ GROUP BY A.date ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == UPLOAD_DATA)
  {
    sql =[NSString stringWithFormat:@"SELECT A.date, AVG(A.bitrate), A.test_id, B.target, metrics.network_type FROM upload AS A, test_data AS B %@ GROUP BY A.date ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == LATENCY_DATA)
  {
    sql =[NSString stringWithFormat:@"SELECT A.date, AVG(A.latency), A.test_id, B.target, metrics.network_type FROM latency AS A, test_data AS B %@ GROUP BY A.date ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == LOSS_DATA)
  {
    sql =[NSString stringWithFormat:@"SELECT A.date, AVG(A.packet_loss), A.test_id, B.target, metrics.network_type FROM packetloss AS A, test_data AS B %@ GROUP BY A.date ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == JITTER_DATA)
  {
    sql =[NSString stringWithFormat:@"SELECT A.date, AVG(A.jitter), A.test_id, B.target,  metrics.network_type FROM jitter AS A, test_data AS B %@ GROUP BY A.date ORDER BY A.date DESC;", joinClause];
  }
  else // default
  {
    SK_ASSERT(false);
  }
  
  NSMutableArray *results = [NSMutableArray array];
 
#ifdef DEBUG
  NSLog(@"DEBUG %s: sql=%@", __FUNCTION__, sql);
#endif // DEBUG
  
  // FMResultSet *rs = [db executeQuery:sql];
  FMResultSet *rs = [db executeQuery:sql, fromDate, toDate];
  //SK_ASSERT(rs != nil);
  
  //NSLog(@" ");
  while ([rs next])
  {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    double doubleDate = [rs doubleForColumnIndex:0];
    NSNumber *nsNumberDate = [NSNumber numberWithDouble:doubleDate];
    SK_ASSERT((NSNull *)nsNumberDate != [NSNull null]);
    
    double val = [rs doubleForColumnIndex:1];
    int testId = [rs intForColumnIndex:2];
    NSString *trg = [rs stringForColumnIndex:3];
    NSString *networkType = [rs stringForColumnIndex:4];
    
    // val = 0.00499; // TODO - this is for debugging/testing ONLY!
    [dict setObject:nsNumberDate forKey:@"DATE"];
    [dict setObject:[SKGlobalMethods format2DecimalPlaces:val] forKey:@"RESULT"];
    [dict setObject:[NSNumber numberWithInt:testId] forKey:@"TEST_ID"];
    [dict setObject:trg forKey:@"TARGET"];
    [dict setObject:[NSNumber numberWithInt:testDataType] forKey:@"TEST_TYPE"];
    if (networkType != nil) {
      [dict setObject:networkType forKey:@"NETWORK_TYPE"];
    }
    
    //NSLog(@"SQL : %@", sql);
    //NSLog(@"Date: %@, Value: %f, Target : %@", date, [val floatValue], trg);
    
    [results addObject:dict];
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);

  return results;
}

+ (NSDate*)getLastRunDateWhereNetworkTypeEquals:(NSString*)whereNetworkTypeAsStringEquals {
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return nil;
  }

  NSString *sql = nil;

  NSString *joinClause = @"";
  if (whereNetworkTypeAsStringEquals != nil) {
    if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {

      // WiFi:
      //   SELECT MAX(date) FROM test_data AS A, metrics WHERE a.id = metrics.test_id AND network_type = 'network';
      joinClause = @", metrics WHERE a.id = metrics.test_id AND network_type = 'network'";

    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {

      // mobile:
      //   SELECT MAX(date) FROM test_data AS A, metrics WHERE a.id = metrics.test_id AND network_type = 'mobile';
      joinClause = @", metrics WHERE a.id = metrics.test_id AND network_type = 'mobile'";

    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      // All networks:
      //   SELECT MAX(date) FROM test_data AS A;

    } else {
      SK_ASSERT(false);
    }
  }

  sql = [NSString stringWithFormat:@"SELECT MAX(A.date) FROM test_data AS A %@", joinClause];

#ifdef DEBUG
  NSLog(@"DEBUG %s: sql=%@", __FUNCTION__, sql);
#endif // DEBUG

  FMResultSet *rs = [db executeQuery:sql];

  BOOL bFound = NO;

  NSDate *theMaxDate = nil;

  //NSLog(@" ");
  while ([rs next])
  {
    // We should find only (and only one) row, as we're querying for MAX(...) ...
    SK_ASSERT(bFound == NO);

    bFound = YES;
    //NSString *day = [rs stringForColumn:0];
    //theMaxDate = [rs dateForColumn:0];
    NSNumber *day = [rs objectForColumnIndexReturnsNullNotNil:0];

    if (day == (NSNumber*)[NSNull null]) {
      // Nothing found!
      // Keep going, to ensure we close the database!
      break;
    }

    //NSLog(@"DEBUG: SQL : %@", sql);
    //NSLog(@"Date: %@", day);
    theMaxDate = [NSDate dateWithTimeIntervalSince1970:[day doubleValue]];
    //NSLog(@"theMaxdate: %@", theMaxDate);
    // If we've got this far, we SHOULD have got just one row, and found the date!
    SK_ASSERT(theMaxDate != nil);
  }

  BOOL bRes = [db close];
  SK_ASSERT(bRes);

  return theMaxDate;
}

+ (NSMutableDictionary*)getDailyAveragedTestDataAsDictionaryKeyByDay:(NSDate*)fromDate ToDate:(NSDate*)toDate TestDataType:(TestDataType)testDataType WhereNetworkTypeAsStringEquals:(NSString*)whereNetworkTypeAsStringEquals
{
  FMDatabase *db = [SKDatabase openDatabase];
  if (db == NULL) {
    SK_ASSERT(false);
    return [NSMutableDictionary new];
  }
  
  NSString *sql = nil;
  
  NSString *joinClause = @"";
  if (whereNetworkTypeAsStringEquals != nil) {
    if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_WIFI]) {
      
      // WiFi
      joinClause = @", metrics WHERE a.test_id = metrics.test_id AND network_type = 'network' AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_MOBILE]) {
      
      // mobile
      joinClause = @", metrics WHERE a.test_id = metrics.test_id AND network_type = 'mobile' AND A.date BETWEEN ? AND ? ";
      
    } else if ([whereNetworkTypeAsStringEquals isEqualToString:C_NETWORKTYPEASSTRING_ALL]) {
      joinClause = @" WHERE A.date BETWEEN ? AND ? ";
      // joinClause = [NSString stringWithFormat:@" WHERE A.date BETWEEN %f AND %f ", fromDate.timeIntervalSince1970, toDate.timeIntervalSince1970];
      
    } else {
      SK_ASSERT(false);
    }
  }
  
  // The 'bitrate' value stored in the data base was calculated like this:
  // bitrate = bytes * 8 / (1024 / 1024)
  // The value returned for display, is calculated like this to return the ORIGINAL BYTE VALUE.
  // bytes = (bitrate * 1024 * 1024) / 8
  if (testDataType == DOWNLOAD_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT A.day, AVG(A.bitrate), COUNT(A.day) FROM download AS A %@ GROUP BY A.day ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == UPLOAD_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT A.day, AVG(A.bitrate), COUNT(A.day) FROM upload AS A %@ GROUP BY A.day ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == LATENCY_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT A.day, AVG(A.latency), COUNT(A.day) FROM latency AS A %@ GROUP BY  A.day ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == LOSS_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT A.day, AVG(A.packet_loss), COUNT(A.day) FROM packetloss AS A %@ GROUP BY A.day ORDER BY A.date DESC;", joinClause];
  }
  else if (testDataType == JITTER_DATA)
  {
    sql = [NSString stringWithFormat:@"SELECT A.day, AVG(A.jitter), COUNT(A.day) FROM jitter AS A %@ GROUP BY A.day ORDER BY A.date DESC;", joinClause];
  }
  else
  {
    SK_ASSERT(false);
  }
  
 #ifdef DEBUG
  NSLog(@"DEBUG %s: sql=%@", __FUNCTION__, sql);
#endif // DEBUG
  
  FMResultSet *rs = [db executeQuery:sql, fromDate, toDate];
  SK_ASSERT(rs != nil);
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  BOOL bFound = NO;
  
  //NSLog(@" ");
  while ([rs next])
  {
    bFound = YES;
    NSString *day = [rs stringForColumnIndex:0];
    double value  = [rs doubleForColumnIndex:1];
    //int count     = [rs intForColumnIndex:2];
    
    //NSLog(@"SQL : %@", sql);
    //NSLog(@"Date: %@, Value: %f", day, value);
    [dict setObject:[NSString stringWithFormat:@"%f", value] forKey:day];
  }
  
  if (!bFound)
  {
    [dict setObject:@"0" forKey:[SKGlobalMethods getTodaysDate]]; // default average to 0 if nothing found
  }
  
  BOOL bRes;
  
  bRes = [db close];
  SK_ASSERT(bRes);
  
  return dict;
}

+ (NSMutableDictionary*)getTestData:(NSDate*)fromDate toDate:(NSDate*)toDate testDataType:(TestDataType)testDataType {
  return [SKDatabase getDailyAveragedTestDataAsDictionaryKeyByDay:fromDate ToDate:toDate TestDataType:testDataType WhereNetworkTypeAsStringEquals:nil];
}

@end

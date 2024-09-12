//
//  RNNetPrinter.m
//  RNThermalReceiptPrinter
//
//  Created by MTT on 06/11/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNNetPrinter.h"
#import "GCDAsyncSocket.h"
#include <arpa/inet.h>
#include <ifaddrs.h>


NSString *const EVENT_SCANNER_RESOLVED = @"scannerResolved";
NSString *const EVENT_SCANNER_RUNNING = @"scannerRunning";

@interface PrivateIP : NSObject

@end

@implementation PrivateIP

- (NSString *)getIPAddress {

  NSString *address = @"error";
  struct ifaddrs *interfaces = NULL;
  struct ifaddrs *temp_addr = NULL;
  int success = 0;
  // retrieve the current interfaces - returns 0 on success
  success = getifaddrs(&interfaces);
  if (success == 0) {
    // Loop through linked list of interfaces
    temp_addr = interfaces;
    while (temp_addr != NULL) {
      if (temp_addr->ifa_addr->sa_family == AF_INET) {
        // Check if interface is en0 which is the wifi connection on the iPhone
        if ([[NSString stringWithUTF8String:temp_addr->ifa_name]
                isEqualToString:@"en0"]) {
          // Get NSString from C String
          address =
              [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)
                                                            temp_addr->ifa_addr)
                                                           ->sin_addr)];
        }
      }

      temp_addr = temp_addr->ifa_next;
    }
  }
  // Free memory
  freeifaddrs(interfaces);
  return address;
}

@end

@implementation RNNetPrinter

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents {
  return @[ EVENT_SCANNER_RESOLVED, EVENT_SCANNER_RUNNING ];
}

RCT_EXPORT_METHOD(init
                  : (RCTResponseSenderBlock)successCallback fail
                  : (RCTResponseSenderBlock)errorCallback) {
  connected_ip = nil;
  is_scanning = NO;
  _printerArray = [NSMutableArray new];
  successCallback(@[ @"Init successful" ]);
}

RCT_EXPORT_METHOD(getDeviceList
                  : (RCTResponseSenderBlock)successCallback fail
                  : (RCTResponseSenderBlock)errorCallback) {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handlePrinterConnectedNotification:)
             name:PrinterConnectedNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handleBLEPrinterConnectedNotification:)
             name:@"BLEPrinterConnected"
           object:nil];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
                   [self scan];
                 });

  successCallback(@[ _printerArray ]);
}

- (void)scan {
  @try {
    PrivateIP *privateIP = [[PrivateIP alloc] init];
    NSString *localIP = [privateIP getIPAddress];
    is_scanning = YES;
    [self sendEventWithName:EVENT_SCANNER_RUNNING body:@YES];
    _printerArray = [NSMutableArray new];

    NSString *prefix = [localIP
        substringToIndex:([localIP rangeOfString:@"." options:NSBackwardsSearch]
                              .location)];
    NSInteger suffix =
        [[localIP substringFromIndex:([localIP rangeOfString:@"."
                                                     options:NSBackwardsSearch]
                                          .location)] intValue];

    for (NSInteger i = 1; i < 255; i++) {
      if (i == suffix)
        continue;
      NSString *testIP = [NSString stringWithFormat:@"%@.%ld", prefix, (long)i];
      current_scan_ip = testIP;
      // [[PrinterSDK defaultPrinterSDK] connectIP:testIP];
      [NSThread sleepForTimeInterval:0.5];
    }

    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_printerArray];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    _printerArray = (NSMutableArray *)arrayWithoutDuplicates;

    [self sendEventWithName:EVENT_SCANNER_RESOLVED body:_printerArray];
  } @catch (NSException *exception) {
    NSLog(@"No connection");
  }
  // [[PrinterSDK defaultPrinterSDK] disconnect];
  is_scanning = NO;
  [self sendEventWithName:EVENT_SCANNER_RUNNING body:@NO];
}

- (void)handlePrinterConnectedNotification:(NSNotification *)notification {
  if (is_scanning) {
    [_printerArray addObject:@{@"host" : current_scan_ip, @"port" : @9100}];
  }
}

- (void)handleBLEPrinterConnectedNotification:(NSNotification *)notification {
  connected_ip = nil;
}

RCT_EXPORT_METHOD(connectPrinter
                  : (NSString *)host withPort
                  : (nonnull NSNumber *)port success
                  : (RCTResponseSenderBlock)successCallback fail
                  : (RCTResponseSenderBlock)errorCallback) {
  @try {
    NSLog(@"Connecting to printer %@:%@", host, port);
    // BOOL isConnectSuccess = [[PrinterSDK defaultPrinterSDK] connectIP:host];
    // !isConnectSuccess ? [NSException raise:@"Invalid connection"
    //                                 format:@"Can't connect to printer %@", host]
    //                   : nil;

    NSLog(@"Connected to printer %@", host);

    // connect to the printer
    [self connectToServerAtAddress:host port:[port intValue]];

    connected_ip = host;

    NSLog(@"Connected to printer %@", host, "Set connected_ip to", connected_ip);

    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"NetPrinterConnected"
                      object:nil];
    successCallback(
        @[ [NSString stringWithFormat:@"Connecting to printer %@", host] ]);

  } @catch (NSException *exception) {
    errorCallback(@[ exception.reason ]);
  }
}

RCT_EXPORT_METHOD(printRawData
                  : (NSString *)text printerOptions
                  // : (NSDictionary *)options fail
                  : (RCTResponseSenderBlock)errorCallback) {
  @try {
    // NSNumber *beepPtr = [options valueForKey:@"beep"];
    // NSNumber *cutPtr = [options valueForKey:@"cut"];

    // BOOL beep = (BOOL)[beepPtr intValue];
    // BOOL cut = (BOOL)[cutPtr intValue];

    NSLog(@"Printing text: %@", text, "Connected to printer", connected_ip);

    !connected_ip ? [NSException raise:@"Invalid connection"
                                format:@"Can't connect to printer"]
                  : nil;

    // [[PrinterSDK defaultPrinterSDK] printTestPaper];
    // [[PrinterSDK defaultPrinterSDK] printText:text];

    // print the data
    [self sendData:text];


    NSLog(@"Printed text: %@", text);
    // beep ? [[PrinterSDK defaultPrinterSDK] beep] : nil;
    // cut ? [[PrinterSDK defaultPrinterSDK] cutPaper] : nil;
  } @catch (NSException *exception) {
    errorCallback(@[ exception.reason ]);
  }
}

RCT_EXPORT_METHOD(closeConn) {
  @try {
    !connected_ip ? [NSException raise:@"Invalid connection"
                                format:@"Can't connect to printer"]
                  : nil;
    // [[PrinterSDK defaultPrinterSDK] disconnect];

    // close the connection
    [asyncSocket disconnect];

    connected_ip = nil;
  } @catch (NSException *exception) {
    NSLog(@"%@", exception.reason);
  }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize the async socket
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)connectToServerAtAddress:(NSString *)address port:(uint16_t)port {
    NSError *error = nil;
    if (![asyncSocket connectToHost:address onPort:port error:&error]) {
        NSLog(@"Error connecting: %@", error.localizedDescription);
    } else {
        NSLog(@"Connecting to %@:%d...", address, port);
    }
}

- (void)sendData:(NSString *)data {
    NSData *dataToSend = [data dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:dataToSend withTimeout:-1 tag:0];  // -1 timeout means no timeout
}

#pragma mark - GCDAsyncSocketDelegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Connected to %@:%d", host, port);
    
    // Start reading data once connected
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"Data sent");
    
    // After writing, read the next response from the server
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", response);
    
    // Keep reading for more data
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        NSLog(@"Disconnected with error: %@", err.localizedDescription);
    } else {
        NSLog(@"Disconnected");
    }
}

@end

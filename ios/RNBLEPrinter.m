//
//  RNBLEPrinter.m
//
//  Created by MTT on 06/10/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RNBLEPrinter.h"

@implementation RNBLEPrinter

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    successCallback(@[ @"Init successful" ]);
}

- (void)handleNetPrinterConnectedNotification:(NSNotification *)notification {
    m_printer = nil;
}

RCT_EXPORT_METHOD(getDeviceList
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    errorCallback(@[ @"This function is not supported" ]);
}

RCT_EXPORT_METHOD(connectPrinter
                  :(NSString *)innerMacAddress success
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    errorCallback(@[ @"This function is not supported" ]);
}

RCT_EXPORT_METHOD(printRawData
                  :(NSString *)text printerOptions
                  :(NSDictionary *)options fail
                  :(RCTResponseSenderBlock)errorCallback) {
    errorCallback(@[ @"This function is not supported" ]);
}

RCT_EXPORT_METHOD(closeConn) {
}

@end

//
//  RNNetPrinter.m
//  RNThermalReceiptPrinter
//
//  Created by MTT on 06/11/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "RNNetPrinter.h"

@implementation RNNetPrinter

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(init
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    _printerArray = [NSMutableArray new];
    successCallback(@[ @"Init successful" ]);
}

RCT_EXPORT_METHOD(getDeviceList
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    successCallback(@[ _printerArray ]);
}

RCT_EXPORT_METHOD(connectPrinter
                  :(NSString *)host withPort
                  :(nonnull NSNumber *)port success
                  :(RCTResponseSenderBlock)successCallback fail
                  :(RCTResponseSenderBlock)errorCallback) {
    errorCallback(@[ @"This function is not supported" ]);
}

RCT_EXPORT_METHOD(printRawData
                  :(NSString *)text printerOptions
                  :(RCTResponseSenderBlock)errorCallback) {
    errorCallback(@[ @"This function is not supported" ]);
}

RCT_EXPORT_METHOD(closeConn) {
   // Nothing
}

@end

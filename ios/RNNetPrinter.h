#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RNNetPrinter : RCTEventEmitter <RCTBridgeModule> {
    NSMutableArray *_printerArray;
}

@end

import { NativeModules } from 'react-native';
import { BasePrinter } from './base-printer';
import { IUSBPrinterIdentity } from '../models/usb-printer-identity';

const RNUSBPrinter = NativeModules.RNUSBPrinter;

export class USBPrinterWrapper extends BasePrinter<IUSBPrinterIdentity> {
  constructor() {
    super(RNUSBPrinter);
  }

  connectPrinter = (vendorId: string, productId: string, deviceName: string, serialNumber: string): Promise<IUSBPrinterIdentity> =>
    new Promise((resolve, reject) =>
      this.module.connectPrinter(
        vendorId,
        productId,
        deviceName,
        serialNumber,
        (printer: IUSBPrinterIdentity) => resolve(printer),
        (error: Error) => reject(error)
      )
    );
}

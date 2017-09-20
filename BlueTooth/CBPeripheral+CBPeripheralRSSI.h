//
//  CBPeripheral+CBPeripheralRSSI.h
//  BlueTooth
//
//  Created by 殷玉秋 on 2017/8/21.
//  Copyright © 2017年 殷玉秋. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (CBPeripheralRSSI)
@property (nonatomic,strong) NSNumber * RSSI_NEW;
@end

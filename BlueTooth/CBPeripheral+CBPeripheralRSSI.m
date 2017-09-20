//
//  CBPeripheral+CBPeripheralRSSI.m
//  BlueTooth
//
//  Created by 殷玉秋 on 2017/8/21.
//  Copyright © 2017年 殷玉秋. All rights reserved.
//

#import "CBPeripheral+CBPeripheralRSSI.h"
#import <objc/runtime.h>

@implementation CBPeripheral (CBPeripheralRSSI)

-(void)setRSSI_NEW:(NSNumber *)RSSI_NEW
{
    objc_setAssociatedObject(self, @"RSSI_NEW", RSSI_NEW, OBJC_ASSOCIATION_RETAIN);
}
-(NSNumber *)RSSI_NEW{
    return objc_getAssociatedObject(self, @"RSSI_NEW");
}

@end

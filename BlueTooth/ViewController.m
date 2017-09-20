//
//  ViewController.m
//  BlueTooth
//
//  Created by 殷玉秋 on 2017/4/11.
//  Copyright © 2017年 殷玉秋. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBPeripheral+CBPeripheralRSSI.h"
#define kCharacteristicSPP_TX_WriteUUID @"00010203-0405-0607-0809-0A0B0C0D2B11" //SPP TX
#define kCharacteristicSPP_RX_ReadUUID @"00010203-0405-0607-0809-0A0B0C0D2B10" //SPP RX

#define kCharacteristicNotifyUUID @"0x2A19"  //获取电池电量
#define kCharacteristicCPUSleepUUID @"EE0C2090-8786-40BA-AB96-99B91AC981D8"  //CPU休眠

@interface ViewController ()<CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate>

/* 中心管理者 */
@property (nonatomic, strong) CBCentralManager *cMgr;
 
 /* 连接到的外设 */
@property (nonatomic, strong) CBPeripheral *peripheral;
 //其他设备列表
@property (nonatomic, strong) NSMutableArray *commonPeripherals;
//嫌疑设备列表
@property (nonatomic, strong) NSMutableArray *suspicionPeripherals;


@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *consoleLabel;


@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;
@property (nonatomic, strong) CBCharacteristic *CPUsleepCharacteristic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.tableView addGestureRecognizer:longPress];
    
}
- (IBAction)scanNow:(id)sender {
    [self.cMgr scanForPeripheralsWithServices:nil options:nil];
//    NSLog(@"%d",self.cMgr.isScanning);
}
- (IBAction)writeTest1:(id)sender {
    if (self.writeCharacteristic) {
        [self.peripheral writeValue:[@"10" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.writeCharacteristic type:1];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"error for writeCharacteristic" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"okkkkkk", nil] show];
    }
}

- (void)writeValue:(NSString *)command option:(NSString *)option {
    
//    if (activePeripheral.state != CBPeripheralStateConnected) {
//        NSLog(@"peripheral disconnected");
//        return;
//    }
//    
//    NSData *data;
//    if (option.length > 0) {
//        data = [self command:command withOption:option];
//    } else {
//        data = [self dataFromHexString:command];
//    }
//    NSString *msg = [NSString stringWithFormat:@"Write command %@ on peripheral %@(%@)", data, activePeripheral.name, activePeripheral.identifier];
//    NSLogK(msg);
//    [activePeripheral writeValue:data forCharacteristic:controlCharacteristic type:CBCharacteristicWriteWithResponse];
}
//#pragma mark 发送和接收数据解析相关，以下是针对我目前项目中蓝牙功能的封装，不一定适用其他项目
//- (NSData *)command:(NSString *)hexCommand withOption:(NSString *)option{
//    
//    NSData *optionData = [option dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSInteger totalLength = optionData.length + 5;
//    
//    NSString *hexOptionString = [self dataToHex:optionData];
//    
//    NSString *lengthString = [NSString stringWithFormat:@"%X",(int)totalLength];
//    
//    //最长只支持 255 长度的命令
//    if (lengthString.length==1) {
//        lengthString = [NSString stringWithFormat:@"0%@",lengthString];
//    }
//    
//    NSString *hexCommandString = [NSString stringWithFormat:hexCommand,lengthString,hexOptionString];
//    
//    NSData *commandData = [self dataFromHexString:hexCommandString];
//    
//    return commandData;
//}
- (void)longPress :(UILongPressGestureRecognizer*)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[sender locationInView:self.tableView]];
    CBPeripheral *p ;
    if (indexPath.section ==0) {
        p = (CBPeripheral *)[self.suspicionPeripherals objectAtIndex:indexPath.row];
    }
    else{
        p = (CBPeripheral *)[self.commonPeripherals objectAtIndex:indexPath.row];
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"断开链接" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"断开" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.cMgr cancelPeripheralConnection:p];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identi = @"bbb";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
    if (cell ==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
        cell.textLabel.numberOfLines =10;
    }
    CBPeripheral *p ;
    if (indexPath.section ==0) {
        p = (CBPeripheral *)[self.suspicionPeripherals objectAtIndex:indexPath.row];
    }
    else{
        p = (CBPeripheral *)[self.commonPeripherals objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"名称：%@ \n %@ \n信号强度：%@",p.name,p,p.RSSI_NEW];
    //信号强度大于40
    if (p.RSSI_NEW.intValue>40) {
        cell.textLabel.textColor = [UIColor blueColor];
    }
    else{
        cell.textLabel.textColor = [UIColor grayColor];
    }
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0) {
        return self.suspicionPeripherals.count;
    }
    else{
        return self.commonPeripherals.count;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        self.peripheral = (CBPeripheral *)[self.suspicionPeripherals objectAtIndex:indexPath.row];
    }
    else{
        self.peripheral = (CBPeripheral *)[self.commonPeripherals objectAtIndex:indexPath.row];
    }
    [self.cMgr connectPeripheral:self.peripheral options:nil];
}
//只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
        }
            break;
        case 5:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            // 在中心管理者成功开启后再进行一些操作
            // 搜索外设
            [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                              options:nil]; // dict,条件
            // 搜索成功之后,会调用我们找到外设的代理方法
            // - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设
        }
            break;
        default:
            break;
    }
}
// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    if (self.commonPeripherals==nil) {
        self.commonPeripherals = [NSMutableArray array];
    }
    if (self.suspicionPeripherals==nil) {
        self.suspicionPeripherals = [NSMutableArray array];
    }
    //嫌疑设备
    if (peripheral.name.length>1) {
        if ([self.suspicionPeripherals indexOfObject:peripheral]==NSNotFound) {
            [self.suspicionPeripherals addObject:peripheral];
            //        peripheral.delegate =self;
            //        [peripheral readRSSI];
            peripheral.RSSI_NEW = RSSI;
        }
    }
    //其他设备
    else{
        if ([self.commonPeripherals indexOfObject:peripheral]==NSNotFound) {
            [self.commonPeripherals addObject:peripheral];
            //        peripheral.delegate =self;
            //        [peripheral readRSSI];
            peripheral.RSSI_NEW = RSSI;
        }
    }
    [self.tableView reloadData];
    NSLog(@"%s, line = %d, cetral = %@,peripheral = %@, advertisementData = %@, RSSI = %@", __FUNCTION__, __LINE__, central, peripheral, advertisementData, RSSI);
    /*
     peripheral = , advertisementData = {
     kCBAdvDataChannel = 38;
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = OBand;
     kCBAdvDataManufacturerData = <4c69616e 0e060678 a5043853 75>;
     kCBAdvDataServiceUUIDs =     (
     FEE7
     );
     kCBAdvDataTxPowerLevel = 0;
     }, RSSI = -55
     根据打印结果,我们可以得到运动手环它的名字叫 OBand-75
     
     */
    
    // 需要对连接到的外设进行过滤
    // 1.信号强度(40以上才连接, 80以上连接)
    // 2.通过设备名(设备字符串前缀是 OBand)
    // 在此时我们的过滤规则是:有OBand前缀并且信号强度大于35
    // 通过打印,我们知道RSSI一般是带-的
    
//    if ([peripheral.name hasPrefix:@"OBand"]) {
//        // 在此处对我们的 advertisementData(外设携带的广播数据) 进行一些处理
//        
//        // 通常通过过滤,我们会得到一些外设,然后将外设储存到我们的可变数组中,
//        // 这里由于附近只有1个运动手环, 所以我们先按1个外设进行处理
//        
//        // 标记我们的外设,让他的生命周期 = vc
//        self.peripheral = peripheral;
//        // 发现完之后就是进行连接
//        [self.cMgr connectPeripheral:self.peripheral options:nil];
//        NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
//    }
}

#pragma mark-//3.连接外围设备
//
//// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    // 连接成功之后,可以进行服务和特征的发现
    [self.cMgr stopScan];
    //  设置外设的代理
    self.peripheral.delegate = self;
    
    // 外设发现服务,传nil代表不过滤
    // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.peripheral discoverServices:nil];
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    self.consoleLabel.text = @"didDiscoverServices (外设发现服务)";
    for (CBService *service in self.peripheral.services) {
        //发现服务
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
//            NSLog(@"发现服务:%@", service.UUID);
//            [peripheral discoverCharacteristics:nil forService:service];
//            break;
//        }
        NSLog(@"发现服务:service =%@",service);
        self.consoleLabel.text = @"discoverCharacteristics (扫描特征)";
        //扫描特征
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}
//扫描特征回调方法w
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"搜索特征%@时发生错误:%@", service.UUID, [error localizedDescription]);
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
         NSLog(@"服务:%@ \n 特征:%@ \n ",service,characteristic);
        
        //发现特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicSPP_TX_WriteUUID]]) {
            self.writeCharacteristic =characteristic;
            if (self.writeCharacteristic.isNotifying ==NO) {
                NSLog(@"设置监听！");
                [self.peripheral setNotifyValue:YES forCharacteristic:self.writeCharacteristic];
            }
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicSPP_RX_ReadUUID]]) {
            self.notifyCharacteristic =characteristic;
//            [self.peripheral readValueForCharacteristic:self.notifyCharacteristic];
//            if (self.notifyCharacteristic.isNotifying ==NO) {
//                NSLog(@"设置监听！");
//                [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
//            }
        }

//        [self.peripheral readValueForCharacteristic:characteristic];
    }
}
#pragma mark-//6.从外围设备读数据
// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData * data = characteristic.value;
    NSString *dataToString =[self valueStringWithResponse:data];
    
    NSLog(@"特征：%@ \n descriptors = %@ \n data to string = %@ \n length = %lu",characteristic,characteristic.descriptors,dataToString,(unsigned long)dataToString.length);
    Byte * resultByte = (Byte *)[data bytes];
    for(int i=0;i<[data length];i++)
    {
        printf("resultByte[%d] = %d\n",i,resultByte[i]);
    }
//    if (characteristic == @"你要的特征的UUID或者是你已经找到的特征") {
//        //characteristic.value就是你要的数据
//    }
    self.consoleLabel.text = @"didUpdateValueForCharacteristic (外围设备读数据)";
    /*
     CBCharacteristicPropertyBroadcast												= 0x01,
     CBCharacteristicPropertyRead													= 0x02,
     CBCharacteristicPropertyWriteWithoutResponse									= 0x04,
     CBCharacteristicPropertyWrite													= 0x08,
     CBCharacteristicPropertyNotify													= 0x10,
     CBCharacteristicPropertyIndicate												= 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites								= 0x40,
     CBCharacteristicPropertyExtendedProperties										= 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)		= 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)	= 0x200
     */
}
//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%s, line = %d \n characteristic =%@ error =%@", __FUNCTION__, __LINE__,characteristic,error);
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
        return;
    }
//
    // Notification has started
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
//        [self updateLog:[NSString stringWithFormat:@"Notification stopped on %@.  Disconnecting", characteristic]];
        [self.cMgr cancelPeripheralConnection:self.peripheral];
    }
}
//
//#pragma mark-/7.给外围设备发送数据（也就是写入数据到蓝牙）这个方法你可以放在button的响应里面，也可以在找到特征的时候就写入，具体看你业务需求怎么用啦
//
//[self.peripherale writeValue:_batteryData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];//第一个参数是已连接的蓝牙设备 ；第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入
//// 需要注意的是特征的属性是否支持写数据
//- (void)yf_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic
//{
//    /*
//     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
//     CBCharacteristicPropertyBroadcast                                                = 0x01,
//     CBCharacteristicPropertyRead                                                    = 0x02,
//     CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
//     CBCharacteristicPropertyWrite                                                    = 0x08,
//     CBCharacteristicPropertyNotify                                                    = 0x10,
//     CBCharacteristicPropertyIndicate                                                = 0x20,
//     CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
//     CBCharacteristicPropertyExtendedProperties                                        = 0x80,
//     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
//     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)    = 0x200
//     };
//     
//     打印出特征的权限(characteristic.properties),可以看到有很多种,这是一个NS_OPTIONS的枚举,可以是多个值
//     常见的又read,write,noitfy,indicate.知道这几个基本够用了,前俩是读写权限,后俩都是通知,俩不同的通知方式
//     */
//    //    NSLog(@"%s, line = %d, char.pro = %d", __FUNCTION__, __LINE__, characteristic.properties);
//    // 此时由于枚举属性是NS_OPTIONS,所以一个枚举可能对应多个类型,所以判断不能用 = ,而应该用包含&
//}

// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    self.consoleLabel.text = @"didFailToConnectPeripheral (连接失败)";
}
//
// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    self.consoleLabel.text = @"didDisconnectPeripheral (断开连接)";
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error
{
    NSLog(@"%s(外设发现服务)", __FUNCTION__);
    self.consoleLabel.text = @"didDiscoverIncludedServices (didDiscoverIncludedServices)";
}

#pragma mark-信号强度
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    if (!error) {
        peripheral.RSSI_NEW = RSSI;
    }
    [self.tableView reloadData];
}

/*
 *   把返回命令里的传递值拿出来
 */
- (NSString *)valueStringWithResponse:(NSData *)data {
    //NSData *ad = [NSData dataWithBytes:0x00 length:2];
    if (data.length <= 5) {
        return nil;
    }
    NSData *tailData = [data subdataWithRange:NSMakeRange(data.length-1, 1)];
    if ([tailData isEqualToData:[NSData dataWithBytes:"\0" length:1]]) {
        if (data.length > 6) {
            NSData *valueData = [data subdataWithRange:NSMakeRange(4, data.length-5)];
            NSString *valueString = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
            return valueString;
        }
    } else {
        if (data.length > 5) {
            NSData *valueData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
            NSString *valueString = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
            return valueString;
        }
    }
    return nil;
}

@end

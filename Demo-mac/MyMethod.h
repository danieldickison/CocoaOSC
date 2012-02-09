//
//  MyMethod.h
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/13/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCDispatcher;
@class OSCPacket;


@interface MyMethod : NSObject <NSCoding>

@property OSCDispatcher *dispatcher;
@property (retain) OSCPacket *lastReceivedPacket;
@property (copy) NSDate *lastReceivedDate;
@property (copy) NSString *address;
+ (BOOL)validateAddress:(id *)ioAddress error:(NSError **)outError;
- (void)receivedPacket:(OSCPacket *)packet;

@end

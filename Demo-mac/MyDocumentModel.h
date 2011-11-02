//
//  MyDocumentModel.h
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/13/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyDocumentModel : NSObject <NSCoding>

@property (copy) NSString *localHost;
@property UInt16 localPort;
@property (copy) NSString *remoteHost;
@property UInt16 remotePort;
@property NSInteger protocol;

@property (readonly) NSMutableArray *methods;
@property (readonly) NSMutableArray *sentPackets;

@end

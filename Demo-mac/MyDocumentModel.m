//
//  MyDocumentModel.m
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/13/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import "MyDocumentModel.h"


@implementation MyDocumentModel

@synthesize localHost, localPort, remoteHost, remotePort, methods, sentPackets, protocol;

- (id)init
{
    if (self = [super init])
    {
        methods = [NSMutableArray array];
        sentPackets = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        methods = [decoder decodeObjectForKey:@"methods"];
        sentPackets = [decoder decodeObjectForKey:@"sentPackets"];
        localHost = [decoder decodeObjectForKey:@"localHost"];
        localPort = [decoder decodeIntForKey:@"localPort"];
        remoteHost = [decoder decodeObjectForKey:@"remoteHost"];
        remotePort = [decoder decodeIntForKey:@"remotePort"];
        protocol = [decoder decodeIntForKey:@"protocol"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:methods forKey:@"methods"];
    [encoder encodeObject:sentPackets forKey:@"sentPackets"];
    [encoder encodeObject:localHost forKey:@"localHost"];
    [encoder encodeInt:localPort forKey:@"localPort"];
    [encoder encodeObject:remoteHost forKey:@"remoteHost"];
    [encoder encodeInt:remotePort forKey:@"remotePort"];
    [encoder encodeInt:(int)protocol forKey:@"protocol"];
}

@end

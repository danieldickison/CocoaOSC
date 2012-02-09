//
//  MyMethod.m
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/13/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import "MyMethod.h"
#import "CocoaOSC.h"

@implementation MyMethod

@synthesize dispatcher, address, lastReceivedPacket, lastReceivedDate;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        address = [decoder decodeObjectForKey:@"address"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:address forKey:@"address"];
}

- (void)setDispatcher:(OSCDispatcher *)newDisp
{
    [self.dispatcher removeAllTargetMethods:self action:NULL];
    dispatcher = newDisp;
    if (address)
    {
        [self.dispatcher addMethodAddress:address target:self action:@selector(receivedPacket:)];
    }
}

- (void)setAddress:(NSString *)newAddr
{
    [self.dispatcher removeAllTargetMethods:self action:NULL];
    address = [newAddr copy];
    if (address)
    {
        [self.dispatcher addMethodAddress:newAddr target:self action:@selector(receivedPacket:)];
    }
}

+ (BOOL)validateAddress:(id *)ioAddress error:(NSError **)outError
{
    if (![OSCDispatcher splitAddressComponents:*ioAddress])
    {
        if (outError)
        {
            *outError = [NSError errorWithDomain:@"MyErrors" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Invalid method address." forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    return YES;
}
- (BOOL)validateAddress:(id *)ioAddress error:(NSError **)outError
{
    return [[self class] validateAddress:ioAddress error:outError];
}

- (void)receivedPacket:(OSCPacket *)packet
{
    self.lastReceivedPacket = packet;
    self.lastReceivedDate = [NSDate date];
}

@end

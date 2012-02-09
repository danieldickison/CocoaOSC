//
//  MyDocument.m
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/7/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import "MyDocument.h"
#import "MyDocumentModel.h"
#import "MyMethod.h"
#import "PacketViewController.h"
#import <CocoaOSC/CocoaOSC.h>


static OSCConnectionProtocol modelToOSCProtocol(NSInteger protocol);


@implementation MyDocument

@synthesize model;
@synthesize methodsController, sentPacketsController;
@synthesize methodsTable, sentPacketsTable;
@synthesize packetInspector, packetViewController;
@synthesize newPacketSheet, newPacketViewController;
@synthesize connected, listening;

static NSString * const KVO_CONTEXT = @"MyDocument_KVO_CONTEXT";

- (id)init
{
    self = [super init];
    if (self)
    {
        connection = [[OSCConnection alloc] init];
        connection.delegate = self;
        connection.continuouslyReceivePackets = YES;
        model = [[MyDocumentModel alloc] init];
    }
    return self;
}


- (void)close
{
    [connection disconnect];
    connection = nil;
}


- (NSString *)windowNibName
{
    return @"MyDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    [self.packetInspector setContentView:[self.packetViewController view]];
    [self.newPacketSheet setContentView:[self.newPacketViewController view]];
    [self.methodsTable setDoubleAction:@selector(methodsDoubleClickAction:)];
    [self.sentPacketsTable setDoubleAction:@selector(packetsDoubleClickAction:)];
    
    [self.methodsController addObserver:self forKeyPath:@"selectionIndex" options:0 context:KVO_CONTEXT];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != KVO_CONTEXT)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if (object == self.methodsController)
    {
        if (previousMethodTableSelection)
        {
            [previousMethodTableSelection removeObserver:self forKeyPath:@"lastReceivedPacket"];
        }
        NSArray *arrangedObjects = [self.methodsController arrangedObjects];
        NSInteger index = [self.methodsController selectionIndex];
        if (index != NSNotFound)
        {
            MyMethod *newMethod = [arrangedObjects objectAtIndex:index];
            [newMethod addObserver:self forKeyPath:@"lastReceivedPacket" options:NSKeyValueObservingOptionInitial context:KVO_CONTEXT];
            previousMethodTableSelection = newMethod;
        }
    }
    else if ([keyPath isEqualToString:@"lastReceivedPacket"])
    {
        [self.packetViewController setRepresentedObject:[object valueForKey:@"lastReceivedPacket"]];
    }
}


- (IBAction)tableClickAction:(NSTableView *)sender
{
}

- (IBAction)methodsDoubleClickAction:(NSTableView *)sender
{
    [self.packetInspector makeKeyAndOrderFront:self];
}

- (IBAction)packetsDoubleClickAction:(NSTableView *)sender
{
    NSDictionary *selected = [self.sentPacketsController.selectedObjects lastObject];
    if (selected)
    {
        OSCPacket *newPacket = [[selected objectForKey:@"packet"] copy];
        [self.newPacketViewController setRepresentedObject:newPacket];
        [NSApp beginSheet:self.newPacketSheet modalForWindow:[self windowForSheet] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    }
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [NSKeyedArchiver archivedDataWithRootObject:self.model];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [decoder setDelegate:self];
    self.model = [decoder decodeObjectForKey:@"root"];
    [decoder finishDecoding];
    return (self.model != nil);
}

- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id)object
{
    if ([object isKindOfClass:[MyMethod class]])
    {
        [object setDispatcher:connection.dispatcher];
    }
    return object;
}



- (BOOL)canConfigure
{
    return (!self.listening && !self.connected);
}

+ (NSSet *)keyPathsForValuesAffectingCanConfigure
{
    return [NSSet setWithObjects:@"listening", @"connected", nil];
}


- (IBAction)startServer:(NSButton *)sender
{
    NSError *error;
    NSString *host = ([self.model.localHost length] ? self.model.localHost : nil);
    OSCConnectionProtocol protocol = modelToOSCProtocol(self.model.protocol);
    if (protocol == OSCConnectionUDP)
    {
        if (![connection bindToAddress:host port:self.model.localPort error:&error])
        {
            [self presentError:error];
            return;
        }
        [connection receivePacket];
    }
    else
    {
        if (![connection acceptOnInterface:nil port:self.model.localPort protocol:protocol error:&error])
        {
            [self presentError:error];
            return;
        }
    }
    self.model.localHost = connection.localHost;
    self.listening = YES;
}


- (IBAction)connect:(NSButton *)sender
{
    NSError *error;
    if (![connection connectToHost:self.model.remoteHost port:self.model.remotePort protocol:modelToOSCProtocol(self.model.protocol) error:&error])
    {
        [self presentError:error];
        return;
    }
}


- (IBAction)addMethod:(NSButton *)sender
{
    MyMethod *method = [[MyMethod alloc] init];
    method.dispatcher = connection.dispatcher;
    method.address = @"/new_method";
    [self.methodsController addObject:method];
}

- (IBAction)removeSelectedMethod:(NSButton *)sender
{
    for (MyMethod *method in [self.methodsController selectedObjects])
    {
        [method.dispatcher removeAllTargetMethods:method action:NULL];
    }
    [self.methodsController remove:sender];
}


- (IBAction)newPacket:(NSButton *)sender
{
    OSCPacket *newPacket = [[OSCMutableMessage alloc] init];
    [self.newPacketViewController setRepresentedObject:newPacket];
    [NSApp beginSheet:self.newPacketSheet modalForWindow:[self windowForSheet] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}


- (void)sendPacket:(OSCPacket *)packet
{
    if (!packet) return;
    
    [self.sentPacketsController addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"date", packet, @"packet", nil]];
    if (self.connected)
    {
        [connection sendPacket:packet];
    }
    else
    {
        // This case is for UDP servers that have received a remote packet after which the remote address is saved in the model object.
        [connection sendPacket:packet toHost:self.model.remoteHost port:self.model.remotePort];
    }
    [NSApp endSheet:self.newPacketSheet];
    [self.newPacketSheet orderOut:nil];
}


#pragma mark OSCConnectionDelegate Methods

//- (void)oscConnectionWillConnect:(OSCConnection *)connection;
- (void)oscConnectionDidConnect:(OSCConnection *)conn
{
    // Update the model and UI with actual connection info.
    self.connected = YES;
    self.listening = NO;
    self.model.localHost = conn.localHost;
    self.model.localPort = conn.localPort;
    self.model.remoteHost = conn.connectedHost;
    self.model.remotePort = conn.connectedPort;
    
    [conn receivePacket];
}

- (void)oscConnectionDidDisconnect:(OSCConnection *)connection
{
    self.connected = NO;
}

//- (void)oscConnection:(OSCConnection *)connection willSendPacket:(OSCPacket *)packet;
//- (void)oscConnection:(OSCConnection *)connection didSendPacket:(OSCPacket *)packet;

- (void)maybeAddNewMethod:(NSString *)address
{
    if ([MyMethod validateAddress:&address error:NULL])
    {
        BOOL found = NO;
        for (MyMethod *method in model.methods)
        {
            if ([method.address isEqualToString:address])
            {
                found = YES;
                break;
            }
        }
        if (!found)
        {
            MyMethod *method = [[MyMethod alloc] init];
            method.dispatcher = connection.dispatcher;
            method.address = address;
            [self.methodsController addObject:method];
        }
    }
}

- (void)oscConnection:(OSCConnection *)conn didReceivePacket:(OSCPacket *)packet
{
    [self maybeAddNewMethod:packet.address];
}

- (void)oscConnection:(OSCConnection *)conn didReceivePacket:(OSCPacket *)packet fromHost:(NSString *)host port:(UInt16)port
{
    if (host)
    {
        self.model.remoteHost = host;
        self.model.remotePort = port;
    }
    [self maybeAddNewMethod:packet.address];
}
//- (void)oscConnection:(OSCConnection *)connection failedToReceivePacketWithError:(NSError *)error;

@end


OSCConnectionProtocol modelToOSCProtocol(NSInteger protocol)
{
    switch (protocol)
    {
        case 0: return OSCConnectionUDP;
        case 1: return OSCConnectionTCP_Int32Header;
        case 2: return OSCConnectionTCP_RFC1055;
    }
    return OSCConnectionUDP;
}


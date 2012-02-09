//
//  MyDocument.h
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/7/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CocoaOSC.h"

@class OSCConnection;
@class MyDocumentModel;
@class PacketViewController;
@class MyMethod;
@class OSCPacket;

@interface MyDocument : NSDocument <OSCConnectionDelegate, NSKeyedUnarchiverDelegate>
{
    OSCConnection *connection;
    
    // This ivar is a hack to work around the bug in NSArrayController where KVO notifications never contain the new or old value in the change dictionary.
    MyMethod *previousMethodTableSelection;
}

@property MyDocumentModel *model;

@property IBOutlet NSArrayController *methodsController;
@property IBOutlet NSArrayController *sentPacketsController;

@property IBOutlet NSTableView *methodsTable;
@property IBOutlet NSTableView *sentPacketsTable;

@property IBOutlet NSPanel *packetInspector;
@property IBOutlet PacketViewController *packetViewController;

@property IBOutlet NSWindow *newPacketSheet;
@property IBOutlet PacketViewController *newPacketViewController;

@property (getter=isConnected) BOOL connected;
@property (getter=isListening) BOOL listening;
@property (readonly) BOOL canConfigure;

- (IBAction)startServer:(NSButton *)sender;
- (IBAction)connect:(NSButton *)sender;
- (IBAction)addMethod:(NSButton *)sender;
- (IBAction)removeSelectedMethod:(NSButton *)sender;
- (IBAction)newPacket:(NSButton *)sender;

- (IBAction)tableClickAction:(NSTableView *)sender;
- (IBAction)methodsDoubleClickAction:(NSTableView *)sender;
- (IBAction)packetsDoubleClickAction:(NSTableView *)sender;

- (void)sendPacket:(OSCPacket *)packet;

@end

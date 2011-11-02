//
//  PacketViewController.h
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/17/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MyDocument;
@class OSCMutableMessage;


@interface PacketViewController : NSViewController

@property IBOutlet MyDocument *document;
@property (readonly) OSCMutableMessage *mutableMessage;

- (IBAction)addTextualArgument:(id)sender;
- (IBAction)addNullArgument:(id)sender;
- (IBAction)addImpulseArgument:(id)sender;
- (IBAction)addTrueArgument:(id)sender;
- (IBAction)addFalseArgument:(id)sender;
- (IBAction)addFileArgument:(id)sender;
- (IBAction)addClipboardArgument:(id)sender;
- (IBAction)sendPacket:(id)sender;

@property IBOutlet NSWindow *textInputSheet;
@property (copy) NSString *textInputString;
@property NSInteger textInputType;
- (IBAction)textAddAction:(id)sender;
- (IBAction)textCancelAction:(id)sender;

@end


@interface PacketArgumentCollectionView : NSCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object;

@end
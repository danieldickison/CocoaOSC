//
//  PacketViewController.m
//  CocoaOSC Mac Demo
//
//  Created by Daniel Dickison on 3/17/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import "PacketViewController.h"
#import "MyDocument.h"
#import <CocoaOSC/CocoaOSC.h>


@implementation PacketViewController

@synthesize document;
@synthesize textInputSheet, textInputString, textInputType;

- (OSCMutableMessage *)mutableMessage
{
    return (OSCMutableMessage *)[self representedObject];
}

- (IBAction)addTextualArgument:(id)sender
{
    NSInteger code = [NSApp runModalForWindow:self.textInputSheet];
    [self.textInputSheet orderOut:nil];
    if (code == 1)
    {
        switch (self.textInputType)
        {
            case 0:
                [self.mutableMessage addString:self.textInputString];
                break;
            case 1:
                [self.mutableMessage addInt:[self.textInputString intValue]];
                break;
            case 2:
                [self.mutableMessage addFloat:[self.textInputString floatValue]];
                break;
            case 3:
                [self.mutableMessage addBlob:[self.textInputString dataUsingEncoding:NSUTF8StringEncoding]];
                break;
        }
    }
}

- (IBAction)textAddAction:(id)sender
{
    [NSApp stopModalWithCode:1];
}

- (IBAction)textCancelAction:(id)sender
{
    [NSApp stopModalWithCode:0];
}

- (IBAction)addNullArgument:(id)sender
{
    [self.mutableMessage addNull];
}

- (IBAction)addImpulseArgument:(id)sender
{
    [self.mutableMessage addImpulse];
}

- (IBAction)addTrueArgument:(id)sender
{
    [self.mutableMessage addBool:YES];
}

- (IBAction)addFalseArgument:(id)sender
{
    [self.mutableMessage addBool:NO];
}

- (IBAction)addFileArgument:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:[[self view] window]
                      completionHandler:
     ^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton)
         {
             NSURL *url = [[openPanel URLs] objectAtIndex:0];
             NSData *data = [NSData dataWithContentsOfURL:url];
             [self.mutableMessage addBlob:data];
         }
     }];
}

- (IBAction)addClipboardArgument:(id)sender
{
    // TODO...
}

- (IBAction)sendPacket:(id)sender
{
    [self.document sendPacket:self.mutableMessage];
}

@end



@implementation PacketArgumentCollectionView

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
    NSCollectionViewItem *item = [[NSCollectionViewItem alloc] initWithNibName:nil bundle:nil];
    NSView *view;
    if ([object isKindOfClass:[OSCImpulse class]] ||
        [object isKindOfClass:[OSCBool class]] ||
        [object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]] ||
        [object isKindOfClass:[NSNull class]] ||
        [object isKindOfClass:[NSDate class]])
    {
        view = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [(NSTextField *)view setStringValue:[object description]];
        [(NSTextField *)view sizeToFit];
    }
    else if ([object isKindOfClass:[NSData class]])
    {
        NSImage *image = [[NSImage alloc] initWithData:object];
        if (image)
        {
            view = [[NSImageView alloc] initWithFrame:NSZeroRect];
            [(NSImageView *)view setImage:image];
            [(NSImageView *)view sizeToFit];
        }
        else
        {
            view = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 100, 50)];
            [(NSTextView *)view setString:[object description]];
        }
    }
    [item setView:view];
    return item;
}

@end
//
//  AppDelegate.m
//  CocoaOSC
//
//  Created by Daniel Dickison on 1/26/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import "AppDelegate.h"
#import "AsyncUdpSocket.h"
#import "CocoaOSC.h"


enum {
    kTagRemoteHost = 42,
    kTagRemotePort,
    kTagRemoteAddress,
    kTagSendValue,
    kTagType,
    kTagType2,
    kTagLocalPort,
    kTagLocalAddress,
    kTagReceivedValue
};


@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    connection = [[OSCConnection alloc] init];
    connection.delegate = self;
    connection.continuouslyReceivePackets = YES;
    NSError *error;
    if (![connection bindToAddress:nil port:0 error:&error])
    {
        NSLog(@"Could not bind UDP connection: %@", error);
    }
    [connection receivePacket];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ((UITextField *)[window viewWithTag:kTagRemoteHost]).text = [defaults stringForKey:@"remoteHost"];
    ((UITextField *)[window viewWithTag:kTagRemotePort]).text = [defaults stringForKey:@"remotePort"];
    ((UITextField *)[window viewWithTag:kTagRemoteAddress]).text = [defaults stringForKey:@"remoteAddress"];
    ((UITextField *)[window viewWithTag:kTagSendValue]).text = [defaults stringForKey:@"sendValue"];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)typeBarAction:(UISegmentedControl *)sender
{
    sendType = sender.selectedSegmentIndex;
    ((UISegmentedControl *)[window viewWithTag:kTagType2]).selectedSegmentIndex = -1;
}

- (IBAction)typeBar2Action:(UISegmentedControl *)sender
{
    sendType = 4 + sender.selectedSegmentIndex;
    ((UISegmentedControl *)[window viewWithTag:kTagType]).selectedSegmentIndex = -1;
}


- (IBAction)sendPacket
{
    NSString *remoteHost = ((UITextField *)[window viewWithTag:kTagRemoteHost]).text;
    NSString *remotePort = ((UITextField *)[window viewWithTag:kTagRemotePort]).text;
    NSString *remoteAddress = ((UITextField *)[window viewWithTag:kTagRemoteAddress]).text;
    NSString *sendValue = ((UITextField *)[window viewWithTag:kTagSendValue]).text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:remoteHost forKey:@"remoteHost"];
    [defaults setObject:remotePort forKey:@"remotePort"];
    [defaults setObject:remoteAddress forKey:@"remoteAddress"];
    [defaults setObject:sendValue forKey:@"sendValue"];
    
    NSLog(@"Host: %@", remoteHost);
    NSLog(@"Port: %@", remotePort);
    NSLog(@"Address: %@", remoteAddress);
    NSLog(@"Value: %@", sendValue);
    
    OSCMutableMessage *message = [[OSCMutableMessage alloc] init];
    message.address = remoteAddress;
    switch (sendType)
    {
        case 0: [message addString:sendValue]; break;
        case 1: [message addInt:[sendValue intValue]]; break;
        case 2: [message addFloat:[sendValue floatValue]]; break;
        case 3: [message addBlob:[sendValue dataUsingEncoding:NSUTF8StringEncoding]]; break;
        case 4: [message addTimeTag:[NSDate date]]; break;
        case 5: [message addBool:YES]; break;
        case 6: [message addBool:NO]; break;
        case 7: [message addImpulse]; break;
        case 8: [message addNull]; break;
    }
    [connection sendPacket:message toHost:remoteHost port:[remotePort intValue]];
    [message release];
}


- (void)oscConnection:(OSCConnection *)con didSendPacket:(OSCPacket *)packet;
{
    ((UITextField *)[window viewWithTag:kTagLocalPort]).text = [NSString stringWithFormat:@"%hu", con.localPort];
}

- (void)oscConnection:(OSCConnection *)con didReceivePacket:(OSCPacket *)packet fromHost:(NSString *)host port:(UInt16)port
{
    ((UITextField *)[window viewWithTag:kTagReceivedValue]).text = [packet.arguments description];
    ((UITextField *)[window viewWithTag:kTagLocalAddress]).text = packet.address;
}

@end

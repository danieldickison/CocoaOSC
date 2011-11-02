//
//  AppDelegate.h
//  CocoaOSC
//
//  Created by Daniel Dickison on 1/26/10.
//  Copyright 2010 Daniel_Dickison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCConnectionDelegate.h"

@class OSCConnection;

@interface AppDelegate : NSObject <UITextFieldDelegate, OSCConnectionDelegate>
{
    UIWindow *window;
    
    OSCConnection *connection;
    int sendType;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction)typeBarAction:(UISegmentedControl *)sender;
- (IBAction)typeBar2Action:(UISegmentedControl *)sender;
- (IBAction)sendPacket;

@end

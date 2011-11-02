/*
 *  main.c
 *  CocoaOSC
 *
 *  Created by Daniel Dickison on 1/26/10.
 *  Copyright 2010 Daniel_Dickison. All rights reserved.
 *
 */


#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

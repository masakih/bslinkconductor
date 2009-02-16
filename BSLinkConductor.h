//
//  BSLinkConductor.h
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSImagePreviewerInterface.h"

@class HMTemporaryFolder;

@interface BSLinkConductor : NSObject <BSImagePreviewerProtocol>
{
	AppDefaults *appDefaults;
	
	NSMutableArray *items;
	
	HMTemporaryFolder *tempFolder;
	NSMutableDictionary *tempFileDict;
	NSMutableDictionary *urlItemDict;
}

@end

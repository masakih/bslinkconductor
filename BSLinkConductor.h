//
//  BSLinkConductor.h
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BSImagePreviewerInterface.h"
#import "PSPreviewerInterface.h"

@class HMTemporaryFolder;

@interface BSLinkConductor : NSObject <BSImagePreviewerProtocol>
{
	AppDefaults *appDefaults;
	
	NSMutableArray *items;
	
	PreviewerSelector *previewSelector;
	NSArray *previewers;
	
	HMTemporaryFolder *tempFolder;
	NSMutableDictionary *tempFileDict;
	NSMutableDictionary *urlItemDict;
	
	IBOutlet NSWindow *window;
	IBOutlet NSProgressIndicator *progress;
}

- (PreviewerSelector *)previewSelector;
- (NSArray *)previewers;

@end

extern BSLinkConductor* BSLinkC;

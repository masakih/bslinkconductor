//
//  BSLCPreferences.h
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/13.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSLCPreferences : NSWindowController
{
	NSMutableArray *items;
	
	IBOutlet NSTableView *tableView;
	IBOutlet NSArrayController *itemsController;
}

+ (id)sharedInstance;
- (void)setItems:(NSMutableArray *)inItems;

- (IBAction)showHideWindow:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

extern NSString *BSLCItemsDidChangeNotification;

@end

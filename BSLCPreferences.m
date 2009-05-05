//
//  BSLCPreferences.m
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/13.
//  Copyright 2009 masakih. All rights reserved.
//

#import "BSLCPreferences.h"

#import "BSLinkConductorItem.h"
#import "BSLinkConductor.h"


#import <objc/objc-class.h>


@implementation BSLCPreferences

NSString *BSLCItemsDidChangeNotification = @"BSLCItemsDidChangeNotification";

static NSString *const BSLCPreferencesSeparetorItem = @"-- BSLCPreferences Separetor Item --";
static NSString *const BSLCPreferencesAddItem = @"Choose ...";
static BSLCPreferences *instance = nil;

static NSString *const BSLCPRowIndexType = @"BSLCPRowIndexType";

static BOOL (*orignalIMP)(id , SEL) ;

BOOL bslcIsSeparatorItem(id self, SEL _cmd)
{
	if([BSLCPreferencesSeparetorItem isEqualToString:[self title]]) return YES;
	
	return orignalIMP(self, _cmd);
}
static void bslcSwapMethod()
{
    Method method;
	
    method = class_getInstanceMethod([NSMenuItem class], @selector(isSeparatorItem));
	if(method) {
		orignalIMP = (BOOL (*)(id,SEL))method->method_imp;
		method->method_imp = (IMP)bslcIsSeparatorItem;
		NSLog(@"Swaped");
	}
}

+ (void)initialize
{
	static BOOL isFirst = YES;
	if(isFirst) {
		isFirst = NO;
		bslcSwapMethod();
	}
}

- (id)init
{
	if(self = [super initWithWindowNibName:@"BSLinkConductor"]) {
		//
	}
	
	return self;
}

+ (id)sharedInstance
{
	if(!instance) {
		@synchronized(self) {
			if(!instance) {
				instance = [[[self class] alloc] init];
			}
		}
	}
	
	return instance;
}


- (void)awakeFromNib
{
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:BSLCItemPastboardType]];
	
	[[self window] setFrameAutosaveName:@"com.masakih.BSLinkConductor.Preference"];
	
	[itemsController addObserver:self forKeyPath:@"selection.name" options:0 context:NULL];
	[itemsController addObserver:self forKeyPath:@"selection.regularExpression" options:0 context:NULL];
	[itemsController addObserver:self forKeyPath:@"selection.targetApplicationName" options:0 context:NULL];
	[itemsController addObserver:self forKeyPath:@"selection.openInBackground" options:0 context:NULL];
	[itemsController addObserver:self forKeyPath:@"selection.useLocalCopy" options:0 context:NULL];
}

- (void)notifyItemDidChange
{
	NSNotificationCenter *fc = [NSNotificationCenter defaultCenter];
	
	[fc postNotificationName:BSLCItemsDidChangeNotification object:self];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self notifyItemDidChange];
}
- (void)textDidChange:(NSNotification *)notification
{
	[self notifyItemDidChange];
}
- (void)textDidEndEditing:(NSNotification *)notification
{
	[self notifyItemDidChange];
}
- (void)setItems:(NSMutableArray *)inItems
{
	if(items == inItems) return;
	
	[items autorelease];
	items = [inItems retain];
}
- (NSMutableArray *)items
{
	return items;
}


- (NSArray *)applicationPullDownMenuItems
{
	NSMutableArray *result = [NSMutableArray array];
	
	[result addObject:BSLCPreferencesAddItem];
	
	if(![BSLinkC previewSelector]) return result;
	
	[result addObject:BSLCPreferencesSeparetorItem];
	
	NSArray *ps = [BSLinkC previewers];
	NSEnumerator *psIter = [ps objectEnumerator];
	id p;
	while(p = [psIter nextObject]) {
		[result addObject:[p displayName]];
	}
	[result addObject:BSLCPreferencesSeparetorItem];
	
	return result;
}


- (IBAction)showHideWindow:(id)sender
{
	if([[self window] isVisible]) {
		[[self window] orderOut:sender];
	} else {
		[self showWindow:sender];
	}
}
- (IBAction)add:(id)sender
{
	BSLinkConductorItem *item = [[[BSLinkConductorItem alloc] init] autorelease];
	UTILDebugWrite1(@"New item is %@", item);
	
	[self willChangeValueForKey:@"items"];
	[items addObject:item];
	[self didChangeValueForKey:@"items"];
	
	[self notifyItemDidChange];
	
	UTILDebugWrite1(@"Add item. new item count is %d", [items count]);
}
- (IBAction)remove:(id)sender
{
	int row = [tableView selectedRow];
	if(row == -1) return;
	
	id item = [items objectAtIndex:row];
	if(!item) return;
	
	[self willChangeValueForKey:@"items"];
	[items removeObjectAtIndex:row];
	UTILDebugWrite(@"Remove item");
	[self didChangeValueForKey:@"items"];
	
	[self notifyItemDidChange];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	[panel orderOut:self];
	
	if(NSCancelButton == returnCode) return;
	
	NSString *filename = [panel filename];
	filename = [filename lastPathComponent];
	filename = [filename stringByDeletingPathExtension];
	
	[itemsController setValue:filename forKeyPath:@"selection.targetApplicationName"];
}
	
- (void)chooseApplication:(id)sender
{
	NSString *selectedValue = [itemsController valueForKeyPath:@"selection.targetApplicationName"];
	
	if(![selectedValue isEqualToString:BSLCPreferencesAddItem]) return;
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	
	[panel beginSheetForDirectory:@"/Applications/"
							 file:@""
							types:[NSArray arrayWithObject:@"app"]
				   modalForWindow:[sender window]
					modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
					  contextInfo:NULL];
	
}
- (IBAction)menuDidChange:(id)sender
{
	NSLog(@"sender -> %@", sender);
	NSLog(@"selected value -> %@", [itemsController valueForKeyPath:@"selection.targetApplicationName"]);
	[self performSelector:@selector(chooseApplication:) withObject:sender afterDelay:0.0];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	if([rowIndexes count] != 1) return NO;
	
	unsigned int index = [rowIndexes firstIndex];
	
	[pboard declareTypes:[NSArray arrayWithObjects:BSLCItemPastboardType, BSLCPRowIndexType, nil] owner:nil];
	[pboard setData:[NSKeyedArchiver archivedDataWithRootObject:[items objectAtIndex:index]]
			forType:BSLCItemPastboardType];
	[pboard setPropertyList:[NSNumber numberWithUnsignedInt:index] forType:BSLCPRowIndexType];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)targetTableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	if(![[pboard types] containsObject:BSLCItemPastboardType]) {
		UTILDebugWrite(@"Pboard do not have BSLCItemPastboardType");
		return NSDragOperationNone;
	}
	
	if(dropOperation == NSTableViewDropOn) {
        [targetTableView setDropRow:row dropOperation:NSTableViewDropAbove];
	}
	
	unsigned int originalRow = [[pboard propertyListForType:BSLCPRowIndexType] unsignedIntValue];
	if(row == originalRow || row == originalRow + 1) {
		return NSDragOperationNone;
	}
	
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView*)tableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	if(![[pboard types] containsObject:BSLCItemPastboardType]) {
		UTILDebugWrite(@"Pboard do not have BSLCItemPastboardType");
		return NO;
	}
	
	if(row < 0) row = 0;
	
	unsigned int originalRow = [[pboard propertyListForType:BSLCPRowIndexType] unsignedIntValue];
	
	NSData *itemData = [pboard dataForType:BSLCItemPastboardType];
	BSLinkConductorItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
	if(![item isKindOfClass:[BSLinkConductorItem class]]) {
		UTILDebugWrite1(@"pboard object is not BSLinkConductorItem.(%@)", item);
		return NO;
	}
	
	[self willChangeValueForKey:@"items"];
	[items insertObject:item atIndex:row];
	if(originalRow > row) originalRow++;
	[items removeObjectAtIndex:originalRow];
	[self didChangeValueForKey:@"items"];
	
	[self notifyItemDidChange];
	
	return YES;
}

@end

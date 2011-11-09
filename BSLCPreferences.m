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

static NSString *const BSLCPreferencesSeparetorItem = @"-- BSLCPreferences Separetor Item --";

@implementation NSMenuItem (BSLCMethodExchange)
- (BOOL)isSeparatorItemBSLCCustom
{
	if([BSLCPreferencesSeparetorItem isEqualToString:[self title]]) return YES;
	
	return [self isSeparatorItemBSLCCustom];
}
@end

@implementation BSLCPreferences

NSString *BSLCItemsDidChangeNotification = @"BSLCItemsDidChangeNotification";

static NSString *const BSLCPreferencesAddItem = @"Choose ...";
static BSLCPreferences *instance = nil;

static NSString *const BSLCPRowIndexType = @"BSLCPRowIndexType";

static void bslcSwapMethod()
{
    Method method;
	
    method = class_getInstanceMethod([NSMenuItem class], @selector(isSeparatorItem));
	if(method) {
		Method newMethod = class_getInstanceMethod([NSMenuItem class], @selector(isSeparatorItemBSLCCustom));
		method_exchangeImplementations(method, newMethod);
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
	
	for(PSPreviewerItem *item in [BSLinkC previewers]) {
		[result addObject:[item displayName]];
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
	
	[self willChangeValueForKey:@"items"];
	[items addObject:item];
	[self didChangeValueForKey:@"items"];
	
	[self notifyItemDidChange];
}
- (IBAction)remove:(id)sender
{
	int row = [tableView selectedRow];
	if(row == -1) return;
	
	id item = [items objectAtIndex:row];
	if(!item) return;
	
	[self willChangeValueForKey:@"items"];
	[items removeObjectAtIndex:row];
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
//	NSLog(@"sender -> %@", sender);
//	NSLog(@"selected value -> %@", [itemsController valueForKeyPath:@"selection.targetApplicationName"]);
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
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	if(![[pboard types] containsObject:BSLCItemPastboardType]) {
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
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	if(![[pboard types] containsObject:BSLCItemPastboardType]) {
		return NO;
	}
	
	if(row < 0) row = 0;
	
	unsigned int originalRow = [[pboard propertyListForType:BSLCPRowIndexType] unsignedIntValue];
	
	NSData *itemData = [pboard dataForType:BSLCItemPastboardType];
	BSLinkConductorItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
	if(![item isKindOfClass:[BSLinkConductorItem class]]) {
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

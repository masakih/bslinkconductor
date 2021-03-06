//
//  BSLinkConductor.m
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import "BSLinkConductor.h"

#import <CocoaOniguruma/OnigRegexpUtility.h>
#import "BSLinkConductorItem.h"
#import "BSLCPreferences.h"

#import "HMTemporaryFolder.h"


#import "PSPreviewerItem.h"
#import "PSPreviewerInterface.h"

static NSString *const BSLCSavedItemsKey = @"com.masakih.BSLinkConductor.BSLCSavedItemsKey";

BSLinkConductor* BSLinkC;

@interface BSLinkConductor () <NSURLDownloadDelegate>

@end

@interface BSLinkConductor (BSLCPrivate)
- (BOOL)openLink:(NSURL *)anURL withItem:(BSLinkConductorItem *)item;

- (id)preferenceForKey:(NSString *)key;
- (void)setPreference:(id)value forKey:(NSString *)key;

- (void)setPreviewers:(NSArray *)previewer;

- (NSMutableArray *)savedItems;
- (void)storeItemsArray;

- (void)beginDownloadURL:(NSURL *)anURL;
@end

@implementation BSLinkConductor
- (id)initWithPreferences:(AppDefaults *)prefs
{
	if(self = [super init]) {
		BSLinkC = self;
		
		[self setPreferences:prefs];
		items = [[self savedItems] retain];
		
		tempFolder = [[HMTemporaryFolder alloc] init];
		tempFileDict = [[NSMutableDictionary alloc] init];
		urlItemDict = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationWillTerminate:)
													 name:NSApplicationWillTerminateNotification
												   object:NSApp];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(itemDidchanged:)
													 name:BSLCItemsDidChangeNotification
												   object:nil];
//		[items addObserver:self forKeyPath:@"name" options:0 context:NULL];
	}
	
	return self;
}
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[tempFolder release];
	[tempFileDict release];
	[urlItemDict release];
	[items release];
	[appDefaults release];
	
	[super dealloc];
}
	
- (AppDefaults *)preferences
{
	return appDefaults;
}
- (void)setPreferences:(AppDefaults *)aPreferences
{
	if(appDefaults == aPreferences) return;
	
	[appDefaults autorelease];
	appDefaults = [aPreferences retain];
}
- (BOOL)showImageWithURL:(NSURL *)imageURL
{
	NSString *urlString = [imageURL absoluteString];
	
	for(BSLinkConductorItem *item in items) {
		NSRange range = [urlString rangeOfRegexp:item.regularExpression];
		if(range.location != NSNotFound) {
			if(item.isUseLocalCopy) {
				[urlItemDict setObject:item forKey:imageURL];
				[self beginDownloadURL:imageURL];
				return YES;
			}
			return [self openLink:imageURL withItem:item];
		}
	}
	return NO;
}

- (BOOL)validateLink:(NSURL *)anURL
{
	NSString *urlString = [anURL absoluteString];
	
	for(BSLinkConductorItem *item in items) {
		NSRange range = [urlString rangeOfRegexp:item.regularExpression];
		if(range.location != NSNotFound) {
			return YES;
		}
	}
	
	return NO;
}

//- (IBAction)togglePreviewPanel:(id)sender
//{
//	BSLCPreferences *pref = [BSLCPreferences sharedInstance];
//	[pref setItems:items];
//	[pref showHideWindow:sender];
//}

// - (BOOL)showImagesWithURLs:(NSArray *)urls;
- (IBAction)showPreviewerPreferences:(id)sender
{
	BSLCPreferences *pref = [BSLCPreferences sharedInstance];
	[pref setItems:items];
	[pref showWindow:sender];
}

- (void)awakeByPreviewerSelector:(id <PSPreviewerInterface>)thePreviewerSelector
{
	previewSelector = [thePreviewerSelector retain];
	[self setPreviewers:[thePreviewerSelector previewerItems]];
}

#pragma mark #### NSApplication Delegate ####
- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self storeItemsArray];
	[tempFolder release];
}

#pragma mark -
- (NSString *)displayName
{
	static NSString *displayName = nil;
	if(displayName) return displayName;
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	displayName = [[bundle objectForInfoDictionaryKey:@"BSPreviewerDisplayName"] copy];
	
	return displayName;
}
- (PreviewerSelector *)previewSelector
{
	return previewSelector;
}
- (void)setPreviewers:(NSArray *)newArray
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSString *displayName = [self displayName];
	for(PSPreviewerItem *item in newArray) {
		if(![displayName isEqualToString:[item displayName]]) {
			[array addObject:item];
		}
	}
	previewers = [array copy];
}
- (NSArray *)previewers
{
	return previewers;
}

- (void)itemDidchanged:(NSNotification *)notification
{
	[self storeItemsArray];
}

- (BOOL)isPreviewerItem:(BSLinkConductorItem *)item
{
	return [[previewSelector previewerDisplayNames] containsObject:item.targetApplicationName];
}
- (BOOL)openLink:(NSURL *)anURL withItem:(BSLinkConductorItem *)item;
{
	if([self isPreviewerItem:item]) {
		return [previewSelector openURL:anURL inPreviewerByName:item.targetApplicationName];
	}
	
	NSWorkspaceLaunchOptions options = 0;
	
	if(!item) {
		return NO;
	}
	
	if(item.isOpenInBackground) {
		options |= NSWorkspaceLaunchWithoutActivation;
	}
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	BOOL result = [ws openURLs:[NSArray arrayWithObject:anURL]
	   withAppBundleIdentifier:item.targetIdentifier
					   options:options
additionalEventParamDescriptor:nil
			 launchIdentifiers:NULL];
	
	return result;
}


- (id)preferenceForKey:(NSString *)key
{
	return [[[self preferences] imagePreviewerPrefsDict] objectForKey:key];
}
- (void)setPreference:(id)value forKey:(NSString *)key
{
	[[[self preferences] imagePreviewerPrefsDict] setObject:value forKey:key];
}

- (NSMutableArray *)savedItems
{
	NSData *itemsData = [self preferenceForKey:BSLCSavedItemsKey];
	if(!itemsData) {
		return [NSMutableArray array];
	}
	
	NSArray *itemsArray = [NSKeyedUnarchiver unarchiveObjectWithData:itemsData];
	if(![itemsArray isKindOfClass:[NSArray class]]) {
		return [NSMutableArray array];
	}
	
	return [NSMutableArray arrayWithArray:itemsArray];
}
- (void)storeItemsArray
{
	NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:items];
	if(!itemsData) {
		return;
	}
	
	[self setPreference:itemsData forKey:BSLCSavedItemsKey];
}

- (NSString *)fileNameForURL:(NSURL *)anURL
{
	NSString *filename = [anURL absoluteString];
	NSArray *array = [filename componentsSeparatedByString:@"."];
	filename = [array componentsJoinedByString:@"-"];
	
	filename = [[tempFolder path] stringByAppendingPathComponent:filename];
	
	return filename;
}

#pragma mark #### download ####
- (void)loadProgressPanel
{
	if(window) return;
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	[bundle loadNibFile:@"BSLCProgressPanel"
	  externalNameTable:[NSDictionary dictionaryWithObject:self forKey:NSNibOwner]
			   withZone:[self zone]];
}
- (void)openProgressPanel
{
	[self loadProgressPanel];
	
	NSWindow *mainWindow = [NSApp mainWindow];
	
	[NSApp beginSheet:window
	   modalForWindow:mainWindow
		modalDelegate:nil
	   didEndSelector:Nil
		  contextInfo:NULL];
	
	[progress startAnimation:self];
}
- (void)closeProgressPanel
{
	[progress stopAnimation:self];
	[window orderOut:self];
	[NSApp endSheet:window];
}
- (void)beginDownloadURL:(NSURL *)anURL
{
	[self openProgressPanel];
	
	NSURLRequest *req;
	
	req = [NSURLRequest requestWithURL:anURL
						   cachePolicy:NSURLRequestUseProtocolCachePolicy
					   timeoutInterval:10];
	
	NSURLDownload *dl = [[NSURLDownload alloc] initWithRequest:req delegate:self];
	[dl autorelease];
}
- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
	NSString *path = [[tempFolder path] stringByAppendingPathComponent:filename];
	
	[download setDestination:path allowOverwrite:NO];
}
- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
	NSURLRequest *req = [download request];
	NSURL *targetURL = [req URL];
	
	[tempFileDict setObject:path forKey:targetURL];
}
- (void)downloadDidFinish:(NSURLDownload *)download
{
	NSURLRequest *req = [download request];
	NSURL *targetURL = [req URL];
	
	NSString *filepath = [[[tempFileDict objectForKey:targetURL] retain] autorelease];
	[tempFileDict removeObjectForKey:targetURL];
	
	id item = [[[urlItemDict objectForKey:targetURL] retain] autorelease];
	[urlItemDict removeObjectForKey:targetURL];
	
	NSURL *tagetFileURL = [NSURL fileURLWithPath:filepath];
	
	[self closeProgressPanel];
	
	[self openLink:tagetFileURL withItem:item];
}
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	NSURLRequest *req = [download request];
	NSURL *targetURL = [req URL];
	
	[tempFileDict removeObjectForKey:targetURL];
	[urlItemDict removeObjectForKey:targetURL];
	
	[self closeProgressPanel];
	
	NSBeep();
}
@end

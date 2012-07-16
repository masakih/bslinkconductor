//
//  BSLinkConductorItem.m
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import "BSLinkConductorItem.h"

NSString *BSLCItemPastboardType = @"BSLCItemPastboardType";

@interface BSLinkConductorItem (BSLCPrivate)
- (NSString *)defaultName;
@end

static NSString *const BSLCItemNameKey = @"BSLCItemNameKey";
static NSString *const BSLCItemREKey = @"BSLCItemREKey";
static NSString *const BSLCItemAppNameKey = @"BSLCItemAppNameKey";
static NSString *const BSLCItemOpenBGKey = @"BSLCItemOpenBGKey";
static NSString *const BSLCItemUserCopyKey = @"BSLCItemUserCopyKey";

@implementation BSLinkConductorItem

@synthesize name, regularExpression, targetApplicationName;
@synthesize targetIdentifier;
@synthesize openInBackground, useLocalCopy;

- (id)init
{
	if(self = [super init]) {
		[self setName:[self defaultName]];
		[self setRegularExpression:@"http://.*"];
		[self setTargetApplicationName:@""];
		[self setOpenInBackground:NO];
		[self setUseLocalCopy:NO];
	}
	
	return self;
}
- (void)dealloc
{
	self.name = nil;
	self.regularExpression = nil;
	self.targetApplicationName = nil;
	[targetIdentifier release];
	
	[super dealloc];
}

- (void)setTargetApplicationName:(NSString *)inAppName
{
	if([targetApplicationName isEqualToString:inAppName]) return;
	
	[targetApplicationName autorelease];
	targetApplicationName = [inAppName copy];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *fullPath = [ws fullPathForApplication:targetApplicationName];
	if(!fullPath) {
		targetIdentifier = nil;
		return;
	}
	NSBundle *bundle = [NSBundle bundleWithPath:fullPath];
	if(!bundle) {
		targetIdentifier = nil;
		return;
	}
	
	targetIdentifier = [[bundle bundleIdentifier] copy];
}

- (id)copyWithZone:(NSZone *)zone
{
	BSLinkConductorItem *result = [[[self class] allocWithZone:zone] init];
	[result setName:name];
	[result setRegularExpression:regularExpression];
	[result setTargetApplicationName:targetApplicationName];
	[result setOpenInBackground:openInBackground];
	[result setUseLocalCopy:useLocalCopy];
	
	return result;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:name forKey:BSLCItemNameKey];
	[aCoder encodeObject:regularExpression forKey:BSLCItemREKey];
	[aCoder encodeObject:targetApplicationName forKey:BSLCItemAppNameKey];
	[aCoder encodeBool:openInBackground forKey:BSLCItemOpenBGKey];
	[aCoder encodeBool:useLocalCopy forKey:BSLCItemUserCopyKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [self init];
	[self setName:[aDecoder decodeObjectForKey:BSLCItemNameKey]];
	[self setRegularExpression:[aDecoder decodeObjectForKey:BSLCItemREKey]];
	[self setTargetApplicationName:[aDecoder decodeObjectForKey:BSLCItemAppNameKey]];
	[self setOpenInBackground:[aDecoder decodeBoolForKey:BSLCItemOpenBGKey]];
	[self setUseLocalCopy:[aDecoder decodeBoolForKey:BSLCItemUserCopyKey]];
	
	return self;
}

- (id)description
{
	return [NSString stringWithFormat:@"%@<%p> {name = %@, regularExpression = %@, targetApplicationName = %@",
			NSStringFromClass([self class]), self, name, regularExpression, targetApplicationName];
}
	
@end

@implementation BSLinkConductorItem (BSLCPrivate)
- (NSString *)defaultName
{
	return @"Untitled";
}
@end

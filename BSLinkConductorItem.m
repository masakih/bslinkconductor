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

- (NSString *)name
{
	return name;
}
- (void)setName:(NSString *)inName
{
	if([name isEqualToString:inName]) return;
	
	[name autorelease];
	name = [inName copyWithZone:[self zone]];
}
- (NSString *)regularExpression
{
	return regularExpression;
}
- (void)setRegularExpression:(NSString *)inRegularExpression
{
	if([regularExpression isEqualToString:inRegularExpression]) return;
	
	[regularExpression autorelease];
	regularExpression = [inRegularExpression copyWithZone:[self zone]];
}
- (NSString *)targetApplicationName
{
	return targetApplicationName;
}
- (void)setTargetApplicationName:(NSString *)inAppName
{
	if([targetApplicationName isEqualToString:inAppName]) return;
	
	[targetApplicationName autorelease];
	targetApplicationName = [inAppName copyWithZone:[self zone]];
	
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
	
	targetIdentifier = [[bundle bundleIdentifier] copyWithZone:[self zone]];
}

- (NSString *)targetIdentifier
{
	return targetIdentifier;
}

- (BOOL)isOpenInBackground
{
	return openInBackground;
}
- (void)setOpenInBackground:(BOOL)flag
{
	openInBackground = flag;
}
- (BOOL)isUseLocalCopy
{
	return useLocalCopy;
}
- (void)setUseLocalCopy:(BOOL)flag
{
	useLocalCopy = flag;
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

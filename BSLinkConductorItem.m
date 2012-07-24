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

@synthesize name = _name, regularExpression = _regularExpression, targetApplicationName = _targetApplicationName;
@synthesize targetIdentifier = _targetIdentifier;
@synthesize openInBackground = _openInBackground, useLocalCopy = _useLocalCopy;

- (id)init
{
	if(self = [super init]) {
		self.name = [self defaultName];
		self.regularExpression = @"http://.*";
		self.targetApplicationName = @"";
//		self.openInBackground = NO;
//		self.useLocalCopy = NO;
	}
	
	return self;
}
- (void)dealloc
{
	[_name release];
	[_regularExpression release];
	[_targetApplicationName release];
	[_targetIdentifier release];
	
	[super dealloc];
}

- (void)setTargetApplicationName:(NSString *)inAppName
{
	if([_targetApplicationName isEqualToString:inAppName]) return;
	
	[_targetApplicationName release];
	_targetApplicationName = [inAppName copy];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *fullPath = [ws fullPathForApplication:_targetApplicationName];
	if(!fullPath) {
		_targetIdentifier = nil;
		return;
	}
	NSBundle *bundle = [NSBundle bundleWithPath:fullPath];
	if(!bundle) {
		_targetIdentifier = nil;
		return;
	}
	
	_targetIdentifier = [[bundle bundleIdentifier] copy];
}

- (id)copyWithZone:(NSZone *)zone
{
	BSLinkConductorItem *result = [[[self class] allocWithZone:zone] init];
	result.name = self.name;
	result.regularExpression = self.regularExpression;
	result.targetApplicationName = self.targetApplicationName;
	result.openInBackground = self.isOpenInBackground;
	result.useLocalCopy = self.isUseLocalCopy;
	
	return result;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:BSLCItemNameKey];
	[aCoder encodeObject:self.regularExpression forKey:BSLCItemREKey];
	[aCoder encodeObject:self.targetApplicationName forKey:BSLCItemAppNameKey];
	[aCoder encodeBool:self.isOpenInBackground forKey:BSLCItemOpenBGKey];
	[aCoder encodeBool:self.isUseLocalCopy forKey:BSLCItemUserCopyKey];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [self init];
	self.name = [aDecoder decodeObjectForKey:BSLCItemNameKey];
	self.regularExpression = [aDecoder decodeObjectForKey:BSLCItemREKey];
	self.targetApplicationName = [aDecoder decodeObjectForKey:BSLCItemAppNameKey];
	self.openInBackground = [aDecoder decodeBoolForKey:BSLCItemOpenBGKey];
	self.useLocalCopy = [aDecoder decodeBoolForKey:BSLCItemUserCopyKey];
	
	return self;
}

- (id)description
{
	return [NSString stringWithFormat:@"%@<%p> {name = %@, regularExpression = %@, targetApplicationName = %@",
			NSStringFromClass([self class]), self, self.name, self.regularExpression, self.targetApplicationName];
}
	
@end

@implementation BSLinkConductorItem (BSLCPrivate)
- (NSString *)defaultName
{
	return @"Untitled";
}
@end

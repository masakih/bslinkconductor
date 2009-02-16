//
//  BSLinkConductorItem.h
//  BSLinkConductor
//
//  Created by Hori,Masaki on 09/02/11.
//  Copyright 2009 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSLinkConductorItem : NSObject <NSCoding, NSCopying>
{
	NSString *name;
	NSString *regularExpression;
	NSString *targetApplicationName;
	
	BOOL openInBackground;
	BOOL useLocalCopy;
	
	NSString *targetIdentifier;
}

- (NSString *)name;
- (void)setName:(NSString *)inName;
- (NSString *)regularExpression;
- (void)setRegularExpression:(NSString *)inRegularExpression;
- (NSString *)targetApplicationName;
- (void)setTargetApplicationName:(NSString *)inAppName;

- (NSString *)targetIdentifier;

- (BOOL)isOpenInBackground;
- (void)setOpenInBackground:(BOOL)flag;
- (BOOL)isUseLocalCopy;
- (void)setUseLocalCopy:(BOOL)flag;

extern NSString *BSLCItemPastboardType;

@end

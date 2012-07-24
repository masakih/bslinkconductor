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
	NSString *_name;
	NSString *_regularExpression;
	NSString *_targetApplicationName;
	
	BOOL _openInBackground;
	BOOL _useLocalCopy;
	
	NSString *_targetIdentifier;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *regularExpression;
@property (nonatomic, copy) NSString *targetApplicationName;
@property (readonly) NSString *targetIdentifier;
@property (nonatomic, getter=isOpenInBackground) BOOL openInBackground;
@property (nonatomic, getter=isUseLocalCopy) BOOL useLocalCopy;


extern NSString *BSLCItemPastboardType;

@end

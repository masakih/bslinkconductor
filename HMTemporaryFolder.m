//
//  HMTemporaryFolder.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/08/15.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "HMTemporaryFolder.h"


@implementation HMTemporaryFolder

-(NSString *)appName
{
	NSBundle *b = [NSBundle mainBundle];
	
	return [b objectForInfoDictionaryKey:@"CFBundleName"];
}

+(id)temporaryFolder
{
	return [[[[self class] alloc] init] autorelease];
}
-(id)init
{
	if( self = [super init] ) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *tmpDir = NSTemporaryDirectory();
		NSString *appName = [self appName];
		BOOL created = NO;
		
		do {
			NSString *folderName;
			folderName = [NSString stringWithFormat:@"%@-%@",
				appName, 
				[[NSCalendarDate dateWithTimeIntervalSinceNow:0.0]
							descriptionWithCalendarFormat:@"%Y%m%d%H%M%S%F"] ];
			_path = [tmpDir stringByAppendingPathComponent:folderName];
			
			if( ![fm fileExistsAtPath:_path] &&
				[fm createDirectoryAtPath:_path attributes:nil] ) {
				created = YES;
			}
		} while( !created );
		
		[_path retain];
	}
	
	return self;
}

-(void)dealloc
{
#ifdef DEBUG
	NSLog(@"Satrt Dealocate HMTemporaryFolder(%@)", self );
#endif
	
//	[fm  removeFileAtPath:_path handler:nil];
	NSTask *rmTask = [[NSTask alloc] init];
	
	[rmTask setLaunchPath:@"/bin/rm"];
	[rmTask setArguments:[NSArray arrayWithObjects:@"-rf", _path, nil]];
	[rmTask launch];
	[rmTask waitUntilExit];
	[rmTask release];
	
	[_path release];
	
#ifdef DEBUG
	NSLog(@"End Dealocate HMTemporaryFolder" );
#endif
	
	[super dealloc];
}

-(NSString *)path
{
	return [NSString stringWithString:_path];
}
-(NSURL *)url
{
	return [NSURL fileURLWithPath:_path];
}

-(id)description
{
	return [self path];
}

@end

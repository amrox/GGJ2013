//
//  Util.m
//  rant
//
//  Created by Andy Mroczkowski on 1/26/13.
//
//

#import "Util.h"


void PresentError( NSError* error )
{
	NSLog( @"%@:\n%@", error, [error userInfo] );
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"Present Error Title" )
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"OK", "OK Button")
										  otherButtonTitles:nil];
	[alert show];
}

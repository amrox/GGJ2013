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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog( @"%@:\n%@", error, [error userInfo] );
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"Present Error Title" )
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "OK Button")
                                              otherButtonTitles:nil];
        [alert show];
    });
}

NSString *GetUUID(void)
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}
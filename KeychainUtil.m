//
//  KeychainUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 07. 19.
//
//  last update: 13.04.02.
//

#import "KeychainUtil.h"



@implementation KeychainUtil

#pragma mark -
#pragma mark factory functions

+ (NSMutableDictionary*)dictionaryOfGenericPasswdForAccount:(NSString*)account
													service:(NSString*)service
												  passwdKey:(NSString*)key
												accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	
	NSData* identifier = [key dataUsingEncoding:NSUTF8StringEncoding];
	[dic setObject:identifier
			forKey:(id)kSecAttrGeneric];
	[dic setObject:account
			forKey:(id)kSecAttrAccount];
	[dic setObject:service
			forKey:(id)kSecAttrService];
	[dic setObject:(id)kSecClassGenericPassword
			forKey:(id)kSecClass];
	if(group)
		[dic setObject:group
				forKey:(id)kSecAttrAccessGroup];
	
	return [dic autorelease];
}

+ (NSMutableDictionary*)dictionaryOfGenericPasswdForAccount:(NSString*)account
													service:(NSString*)service
												  passwdKey:(NSString*)key
{
	return [KeychainUtil dictionaryOfGenericPasswdForAccount:account
													 service:service
												   passwdKey:key
												 accessGroup:nil];
}

#pragma mark -
#pragma mark C/R/U/D functions

+ (NSMutableDictionary*)searchDictionaryOfGenericPasswdForAccount:(NSString*)account
														  service:(NSString*)service
														passwdKey:(NSString*)key
													  accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil dictionaryOfGenericPasswdForAccount:account
																		 service:service
																	   passwdKey:key
																	 accessGroup:group];
	[dic setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[dic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	[dic setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	return dic;
}

+ (BOOL)saveGenericPasswd:(NSData*)data
			   forAccount:(NSString*)account
				  service:(NSString*)service
				passwdKey:(NSString*)key
			  accessGroup:(NSString*)group
				overwrite:(BOOL)overwrite
{
	NSMutableDictionary* dic = [KeychainUtil dictionaryOfGenericPasswdForAccount:account
																		 service:service
																	   passwdKey:key
																	 accessGroup:group];
	[dic setObject:data forKey:(id)kSecValueData];
	
	OSStatus status = SecItemAdd((CFDictionaryRef)dic, NULL);
	if(status == noErr)
	{
		return YES;
	}
	else if(status == errSecDuplicateItem && overwrite == YES)
	{
		return [KeychainUtil updateGenericPasswd:data
									  forAccount:account
										 service:service
									   passwdKey:key
									 accessGroup:group];
	}
	return NO;
}

+ (BOOL)saveGenericPasswd:(NSData*)data
			   forAccount:(NSString*)account
				  service:(NSString*)service
				passwdKey:(NSString*)key
				overwrite:(BOOL)overwrite
{
	return [KeychainUtil saveGenericPasswd:data
								forAccount:account
								   service:service
								 passwdKey:key
							   accessGroup:nil
								 overwrite:overwrite];
}

+ (BOOL)updateGenericPasswd:(NSData*)data
				 forAccount:(NSString*)account
					service:(NSString*)service
				  passwdKey:(NSString*)key
				accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil dictionaryOfGenericPasswdForAccount:account
																		 service:service
																	   passwdKey:key
																	 accessGroup:group];
	NSMutableDictionary* updateDic = [NSMutableDictionary dictionary];
	[updateDic setObject:data forKey:(id)kSecValueData];
	
	OSStatus status = SecItemUpdate((CFDictionaryRef)dic, (CFDictionaryRef)updateDic);
	if(status == noErr)
		return YES;
	else
		return NO;
}

+ (BOOL)updateGenericPasswd:(NSData*)data
				 forAccount:(NSString*)account
					service:(NSString*)service
				  passwdKey:(NSString*)key
{
	return [KeychainUtil updateGenericPasswd:data
								  forAccount:account
									 service:service
								   passwdKey:key
								 accessGroup:nil];
}

+ (NSMutableDictionary*)loadDictionaryOfGenericPasswdForAccount:(NSString*)account
														service:(NSString*)service
													  passwdKey:(NSString*)key
													accessGroup:(NSString*)group
{
	NSMutableDictionary* searchDic = [KeychainUtil searchDictionaryOfGenericPasswdForAccount:account
																					 service:service
																				   passwdKey:key
																				 accessGroup:group];
	NSMutableDictionary* dic = nil;
	
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDic, (CFTypeRef*)&dic);
	if(status == noErr)
		return [dic autorelease];
	else
		return nil;
}

+ (NSData*)loadGenericPasswdForAccount:(NSString*)account
							   service:(NSString*)service
							 passwdKey:(NSString*)key
						   accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil loadDictionaryOfGenericPasswdForAccount:account
																			 service:service
																		   passwdKey:key
																		 accessGroup:group];
	if(dic)
		return [KeychainUtil dataFromDictionary:dic];
	else
		return nil;
}

+ (NSString*)loadPasswdStringForAccount:(NSString*)account
								service:(NSString*)service
							  passwdKey:(NSString*)key
							accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil loadDictionaryOfGenericPasswdForAccount:account
																			 service:service
																		   passwdKey:key
																		 accessGroup:group];
	if(dic)
	{
		NSString* resultString = [[NSString alloc] initWithData:[dic objectForKey:(id)kSecValueData] encoding:NSUTF8StringEncoding];
		return [resultString autorelease];
	}
	else
		return nil;
}

+ (NSString*)loadPasswdStringForAccount:(NSString*)account
								service:(NSString*)service
							  passwdKey:(NSString*)key
{
	return [KeychainUtil loadPasswdStringForAccount:account
											service:service
										  passwdKey:key
										accessGroup:nil];
}

+ (NSData*)loadPasswdDataForAccount:(NSString*)account
							service:(NSString*)service
						  passwdKey:(NSString*)key
						accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil loadDictionaryOfGenericPasswdForAccount:account
																			 service:service
																		   passwdKey:key
																		 accessGroup:group];
	if(dic)
		return [dic objectForKey:(id)kSecValueData];
	else
		return nil;
}

+ (NSData*)loadPasswdDataForAccount:(NSString*)account
							service:(NSString*)service
						  passwdKey:(NSString*)key
{
	return [KeychainUtil loadPasswdDataForAccount:account
										  service:service
										passwdKey:key
									  accessGroup:nil];
}

+ (BOOL)deleteGenericPasswdForAccount:(NSString*)account
							  service:(NSString*)service
							passwdKey:(NSString*)key
						  accessGroup:(NSString*)group
{
	NSMutableDictionary* dic = [KeychainUtil dictionaryOfGenericPasswdForAccount:account
																		 service:service
																	   passwdKey:key
																	 accessGroup:group];
	
	OSStatus status = SecItemDelete((CFDictionaryRef)dic);
	if(status == noErr)
		return YES;
	else
		return NO;
}

+ (BOOL)deleteGenericPasswdForAccount:(NSString*)account
							  service:(NSString*)service
							passwdKey:(NSString*)key
{
	return [KeychainUtil deleteGenericPasswdForAccount:account
											   service:service
											 passwdKey:key
										   accessGroup:nil];
}

+ (BOOL)genericPasswdExistsForAccount:(NSString*)account
							  service:(NSString*)service
							passwdKey:(NSString*)key
						  accessGroup:(NSString*)group
{
	NSMutableDictionary* searchDic = [KeychainUtil searchDictionaryOfGenericPasswdForAccount:account
																					 service:service
																				   passwdKey:key
																				 accessGroup:group];
	NSMutableDictionary* dic = nil;
	
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDic, (CFTypeRef*)&dic);
	[dic release];
	if(status == noErr)
		return YES;
	else if(status == errSecItemNotFound)
		return NO;
	else
		return NO;
}

+ (BOOL)genericPasswdExistsForAccount:(NSString*)account
							  service:(NSString*)service
							passwdKey:(NSString*)key
{
	return [KeychainUtil genericPasswdExistsForAccount:account
											   service:service
											 passwdKey:key
										   accessGroup:nil];
}

#pragma mark -
#pragma mark helper functions

+ (NSData*)dataFromDictionary:(NSMutableDictionary*)dic
{
	if(dic == nil)
		return nil;

	NSString* errorString;
	NSData* data = [NSPropertyListSerialization dataFromPropertyList:dic
															  format:NSPropertyListBinaryFormat_v1_0
													errorDescription:&errorString];
	return data;
}

+ (NSMutableDictionary*)dictionaryFromData:(NSData*)data
{
	if(data == nil)
		return nil;

	NSString* errorString;
	NSMutableDictionary* dic = [NSPropertyListSerialization propertyListFromData:data
																mutabilityOption:NSPropertyListMutableContainersAndLeaves
																		  format:NULL
																errorDescription:&errorString];
	return dic;
}

+ (NSString*)fetchStatus:(OSStatus)status
{
	if(status == 0)
		return @"success";
	else if(status == errSecNotAvailable)
		return @"no trust results available";
	else if(status == errSecItemNotFound)
		return @"the item cannot be found";
	else if(status == errSecParam)
		return @"parameter error";
	else if(status == errSecAllocate)
		return @"memory allocation error";
	else if(status == errSecInteractionNotAllowed)
		return @"user interaction not allowd";
	else if(status == errSecUnimplemented)
		return @"not implemented";
	else if(status == errSecDuplicateItem)
		return @"item already exists";
	else if(status == errSecDecode)
		return @"unable to decode data";
	else
		return [NSString stringWithFormat:@"%ld", status];
}

#pragma mark -
#pragma mark functions for debug purpose
//from: https://devforums.apple.com/message/123846#123846

+ (void)resetCredentials
{
    OSStatus err;
    err = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
										  (id)kSecClassIdentity, kSecClass, 
										  nil]);
    assert(err == noErr);

    err = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
										  (id)kSecClassCertificate, kSecClass, 
										  nil]);
    assert(err == noErr);

    err = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
										  (id)kSecClassKey, kSecClass, 
										  nil]);
    assert(err == noErr);

    err = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
										   (id)kSecClassGenericPassword, kSecClass, 
										  nil]);
    assert(err == noErr);
	
    err = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
										  (id)kSecClassInternetPassword, kSecClass, 
										   nil]);
    assert(err == noErr);
}

+ (void)_printCertificate:(SecCertificateRef)certificate attributes:(NSDictionary *)attrs indent:(int)indent
{
	CFStringRef summary;	
	NSString* label;
	NSData* hash;

	summary = SecCertificateCopySubjectSummary(certificate);
	assert(summary != NULL);

	label = [attrs objectForKey:(id)kSecAttrLabel];
	if (label != nil)
	{
		fprintf(stderr, "%*slabel   = '%s'\n", indent, "", [label UTF8String]);
	}
	
	fprintf(stderr, "%*ssummary = '%s'\n", indent, "", [(NSString *)summary UTF8String]);

	hash = [attrs objectForKey:(id)kSecAttrPublicKeyHash];
	if (hash != nil)
	{
		fprintf(stderr, "%*shash    = %s\n", indent, "", [[hash description] UTF8String]);
	}

	CFRelease(summary);
}

+ (void)_printKey:(SecKeyRef)key
	   attributes:(NSDictionary *)attrs
		   indent:(int)indent
{
#pragma unused(key)
	NSString* label;	
	CFTypeRef keyClass;

	label = [attrs objectForKey:(id)kSecAttrLabel];
	if (label != nil)
	{
		fprintf(stderr, "%*slabel     = '%s'\n", indent, "", [label UTF8String]);
	}
	
	label = [attrs objectForKey:(id)kSecAttrApplicationLabel];
	if (label != nil)
	{
		fprintf(stderr, "%*sapp label = %s\n", indent, "", [[label description] UTF8String]);
	}
	
	label = [attrs objectForKey:(id)kSecAttrApplicationTag];
	if (label != nil)
	{
		fprintf(stderr, "%*sapp tag = %s\n", indent, "", [[label description] UTF8String]);
	}
	
	//test
//	NSArray* keys = [attrs allKeys];
//	for(int i=0; i<[keys count]; i++)
//	{
//		NSLog(@"key: %@ => value: %@", [keys objectAtIndex:i], [attrs objectForKey:[keys objectAtIndex:i]]);
//	}
	
	keyClass = (CFTypeRef) [attrs objectForKey:(id)kSecAttrKeyClass];
	if (keyClass != nil)
	{
		const char* keyClassStr;

		// keyClass is a CFNumber whereas kSecAttrKeyClassPublic (and so on)
		// are CFStrings.  Gosh, that makes things hard <rdar://problem/6914637>. 
		// So I compare their descriptions.  Yuck!
		if ([[(id)keyClass description] isEqual:(id)kSecAttrKeyClassPublic])
		{
			keyClassStr = "kSecAttrKeyClassPublic";
		}
		else if ([[(id)keyClass description] isEqual:(id)kSecAttrKeyClassPrivate])
		{
			keyClassStr = "kSecAttrKeyClassPrivate";
		}
		else if ([[(id)keyClass description] isEqual:(id)kSecAttrKeyClassSymmetric])
		{
			keyClassStr = "kSecAttrKeyClassSymmetric";
		}
		else 
		{
			keyClassStr = "?";
		}
		fprintf(stderr, "%*skey class = %s\n", indent, "", keyClassStr);
	}
}

+ (void)_printIdentity:(SecIdentityRef)identity
			attributes:(NSDictionary *)attrs
{	
	OSStatus err;
	SecCertificateRef certificate;
	SecKeyRef key;

	err = SecIdentityCopyCertificate(identity, &certificate);	
    assert(err == noErr);

	err = SecIdentityCopyPrivateKey(identity, &key);
	assert(err == noErr);

	fprintf(stderr, "    certificate\n");
	[self _printCertificate:certificate
				 attributes:attrs
					 indent:6];
	
	fprintf(stderr, "    key\n");
	[self _printKey:key
		 attributes:attrs
			 indent:6];

	CFRelease(key);
	CFRelease(certificate);
}

+ (void)_printPassword:(CFStringRef)password
			attributes:(NSDictionary *)attrs
				indent:(int)indent
{
	NSString* generic;
	NSString* account;
	NSString* label;
	NSString* value;

	generic = [attrs objectForKey:(id)kSecAttrGeneric];	
	if (generic != nil)
	{
		fprintf(stderr, "%*sgeneric   = '%s'\n", indent, "", [[generic description] UTF8String]);	
	}
	
	account = [attrs objectForKey:(id)kSecAttrAccount];
	if (account != nil)
	{
		fprintf(stderr, "%*saccount   = '%s'\n", indent, "", [account UTF8String]);
	}
	
	label = [attrs objectForKey:(id)kSecAttrLabel];
	if (label != nil)
	{
		fprintf(stderr, "%*slabel   = '%s'\n", indent, "", [label UTF8String]);
	}
	
	value = [attrs objectForKey:(id)kSecValueData];
	if (value != nil) 
	{
		NSString* valueStr = [[NSString alloc] initWithData:(NSData*)value
												   encoding:NSUTF8StringEncoding];
		fprintf(stderr, "%*svalue    = %s\n", indent, "", [value UTF8String]);
		[valueStr release];
	}
}

+ (void)_printCertificate:(SecCertificateRef)certificate
			   attributes:(NSDictionary *)attrs
{
	[self _printCertificate:certificate
				 attributes:attrs
					 indent:4];
}

+ (void)_printKey:(SecKeyRef)key
	   attributes:(NSDictionary *)attrs
{
	[self _printKey:key
		 attributes:attrs
			 indent:4];
}

+ (void)_printPassword:(CFStringRef)password
			attributes:(NSDictionary *)attrs
{
	[self _printPassword:password
			  attributes:attrs
				  indent:4];
}

+ (void)_dumpCredentialsOfSecClass:(CFTypeRef)secClass
					 printSelector:(SEL)printSelector
{
	OSStatus err;
	CFArrayRef result;
	CFIndex resultCount;
	CFIndex resultIndex;

	result = NULL;
	err = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
												(id)secClass, kSecClass, 
												kSecMatchLimitAll, kSecMatchLimit, 
												kCFBooleanTrue, kSecReturnRef, 
												kCFBooleanTrue, kSecReturnAttributes, 
												nil], 
							  (CFTypeRef *) &result);
	if (result != NULL)
	{
		assert( CFGetTypeID(result) == CFArrayGetTypeID() );

		resultCount = CFArrayGetCount(result);		
		for (resultIndex = 0; resultIndex < resultCount; resultIndex++)
		{
			NSDictionary *  thisResult;

			fprintf(stderr, "  %zd\n", (ssize_t) resultIndex);
			
			thisResult = (NSDictionary *) CFArrayGetValueAtIndex(result, resultIndex);			
			if ((secClass == kSecClassGenericPassword) || (secClass == kSecClassInternetPassword))
			{
				[self performSelector:printSelector withObject:[thisResult objectForKey:(NSString *)kSecValueData] withObject:thisResult];	
			}
			else
			{
				[self performSelector:printSelector withObject:[thisResult objectForKey:(NSString *)kSecValueRef] withObject:thisResult];
			}
		}

		CFRelease(result);
	}
}

+ (void)dumpCredentials
{
    fprintf(stderr, "identities:\n");	
    [self _dumpCredentialsOfSecClass:kSecClassIdentity
					   printSelector:@selector(_printIdentity:attributes:)];

    fprintf(stderr, "certificates:\n");	
    [self _dumpCredentialsOfSecClass:kSecClassCertificate
					   printSelector:@selector(_printCertificate:attributes:)];

    fprintf(stderr, "keys:\n");
    [self _dumpCredentialsOfSecClass:kSecClassKey
					   printSelector:@selector(_printKey:attributes:)];

    fprintf(stderr, "generic passwords:\n");	
    [self _dumpCredentialsOfSecClass:kSecClassGenericPassword
					   printSelector:@selector(_printPassword:attributes:)];

    fprintf(stderr, "internet passwords:\n");
    [self _dumpCredentialsOfSecClass:kSecClassInternetPassword
					   printSelector:@selector(_printPassword:attributes:)];
}

@end

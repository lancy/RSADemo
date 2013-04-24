//
//  GLViewController.m
//  RSADemo
//
//  Created by Lancy on 24/4/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import "GLViewController.h"
#import "CryptoUtil.h"
#import "Base64.h"


@interface GLViewController ()

@end

@implementation GLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"key" ofType:@"txt"];
    NSString *publicKeyString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", publicKeyString);
    SecKeyRef publicKey = [CryptoUtil RSAPublicKeyRefFromBase64String:publicKeyString withTag:@"com.gracelancy.tag"];
    NSData *encryptData = [CryptoUtil encryptString:@"hello world" RSAPublicKey:publicKey padding:kSecPaddingNone];
    NSLog(@"%@", [encryptData base64EncodedString]);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

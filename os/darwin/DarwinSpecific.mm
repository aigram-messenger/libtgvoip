//
// libtgvoip is free and unencumbered public domain software.
// For more information, see http://unlicense.org or the UNLICENSE file
// you should have received with this source code distribution.
//

#include "DarwinSpecific.h"
#include "../../VoIPController.h"

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

using namespace tgvoip;

void DarwinSpecific::GetSystemName(char* buf, size_t len){
	NSString* v=[[NSProcessInfo processInfo] operatingSystemVersionString];
	strcpy(buf, [v UTF8String]);
	//[v getCString:buf maxLength:sizeof(buf) encoding:NSUTF8StringEncoding];
}

void DarwinSpecific::SetCurrentThreadPriority(int priority){
	NSThread* thread=[NSThread currentThread];
	if([thread respondsToSelector:@selector(setQualityOfService:)]){
		NSQualityOfService qos;
		switch(priority){
			case THREAD_PRIO_USER_INTERACTIVE:
				qos=NSQualityOfServiceUserInteractive;
				break;
			case THREAD_PRIO_USER_INITIATED:
				qos=NSQualityOfServiceUserInitiated;
				break;
			case THREAD_PRIO_UTILITY:
				qos=NSQualityOfServiceUtility;
				break;
			case THREAD_PRIO_BACKGROUND:
				qos=NSQualityOfServiceBackground;
				break;
			case THREAD_PRIO_DEFAULT:
			default:
				qos=NSQualityOfServiceDefault;
				break;
		}
		[thread setQualityOfService:qos];
	}else{
		double p;
		switch(priority){
			case THREAD_PRIO_USER_INTERACTIVE:
				p=1.0;
				break;
			case THREAD_PRIO_USER_INITIATED:
				p=0.8;
				break;
			case THREAD_PRIO_UTILITY:
				p=0.4;
				break;
			case THREAD_PRIO_BACKGROUND:
				p=0.2;
				break;
			case THREAD_PRIO_DEFAULT:
			default:
				p=0.5;
				break;
		}
		[NSThread setThreadPriority:p];
	}
}

CellularCarrierInfo DarwinSpecific::GetCarrierInfo(){
	CellularCarrierInfo info;
#if TARGET_OS_IOS
	CTTelephonyNetworkInfo* netinfo=[CTTelephonyNetworkInfo new];
	CTCarrier* carrier=[netinfo subscriberCellularProvider];
	if(carrier && [carrier carrierName]){
    	info.name=[[carrier carrierName] cStringUsingEncoding:NSUTF8StringEncoding];
    	info.mcc=[[carrier mobileCountryCode] cStringUsingEncoding:NSUTF8StringEncoding];
    	info.mnc=[[carrier mobileNetworkCode] cStringUsingEncoding:NSUTF8StringEncoding];
    	info.countryCode=[[[carrier isoCountryCode] uppercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
	}
#endif
	return info;
}

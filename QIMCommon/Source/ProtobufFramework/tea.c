//
//  tea.c
//  qtalkstream
//
//  Created by may on 16/8/11.
//  Copyright © 2016年 qtalkteam. All rights reserved.
//

#include "tea.h"
#include <string.h>
_Bool smallEndian(){
    int n=1;
    return *(char *)&n;
}

uint32_t EndianIntConvertBToLittle(uint32_t InputNum) {
    if (!smallEndian()) {
        char *p = (char*)&InputNum;
        for (int i = 0; i<sizeof(InputNum); i++) {
            //      QIMDebugLog("%d",p[i]);
        }
        uint32_t num,num1,num2,num3,num4;
        num1=(uint32_t)(*p)<<24;
        num2=((uint32_t)*(p+1))<<16;
        num3=((uint32_t)*(p+2))<<8;
        num4=((uint32_t)*(p+3));
        num=num1+num2+num3+num4;
        //QIMDebugLog("num is %d",num);
        char * q = (char *)num;
        for (int i = 0; i<sizeof(num); i++) {
            // QIMDebugLog("%d",q[i]);
        }
        return num;
    }
    return InputNum;
}

int32_t EndianIntConvertLToBig(int32_t InputNum) {
    //return InputNum;
    if (smallEndian()) {
        char *p = (char*)&InputNum;
        //printf("S");
        //for (int i = 0; i<sizeof(InputNum); i++) {
            //      QIMDebugLog("%d",p[i]);
        //  printf("%d\n",p[i]);
        //}
        char r[4];
        r[3] = p[0];
        r[2] = p[1];
        r[1] = p[2];
        r[0] = p[3];
        int32_t num;
        memcpy(&num,r,4);
       /* int32_t num,num1,num2,num3,num4;
        num1=(int32_t)(*p)<<24;
        num2=((int32_t)*(p+1))<<16;
        num3=((int32_t)*(p+2))<<8;
        num4=((int32_t)*(p+3));
        num=num1+num2+num3+num4;*/
        //QIMDebugLog("num is %d",num);
        char * q = (char *)&num;
        //printf("R");
        //for (int i = 0; i<sizeof(num); i++) {
            // QIMDebugLog("%d",q[i]);
            //printf("%d\n",q[i]);
        //}
        return num;
    }
    return InputNum;
}

void tea_encrypt (uint32_t* v, uint32_t* k) {
    //printf("%.8x,%.8x\n",v[0],v[1]);
    uint32_t v0=EndianIntConvertLToBig(v[0]), v1=EndianIntConvertLToBig(v[1]),/*vn0=v[0],vn1=v[1],*/ sum=0, i;
    //printf("%.8x,%.8x\n",v0,v1);
    /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=EndianIntConvertBToLittle(k[0]), k1=EndianIntConvertBToLittle(k[1]), k2=EndianIntConvertBToLittle(k[2]), k3=EndianIntConvertBToLittle(k[3]);   /* cache key */
    for (i=0; i < 32; i++) {                       /* basic cycle start */
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        //printf("Big %.8x,%.8x\n",v0,v1);
        //vn0 += ((vn1<<4) + k0) ^ (vn1 + sum) ^ ((vn1>>5) + k1);
        //vn1 += ((vn0<<4) + k2) ^ (vn0 + sum) ^ ((vn0>>5) + k3);
        //printf("Big %.8x,%.8x\n",vn0,vn1);
    }
    /* end cycle */
    //printf("s %.8x,%.8x\n",v0,v1);
    v[0]=EndianIntConvertLToBig(v0); v[1]=EndianIntConvertLToBig(v1);
    //printf("r %.8x,%.8x\n",v[0],v[1]);
}

void tea_decrypt (uint32_t* v, uint32_t* k) {
    uint32_t v0=EndianIntConvertLToBig(v[0]), v1=EndianIntConvertLToBig(v[1]), sum=0xC6EF3720, i;  /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t k0=EndianIntConvertBToLittle(k[0]), k1=EndianIntConvertBToLittle(k[1]), k2=EndianIntConvertBToLittle(k[2]), k3=EndianIntConvertBToLittle(k[3]);   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=EndianIntConvertLToBig(v0); v[1]=EndianIntConvertLToBig(v1);
}

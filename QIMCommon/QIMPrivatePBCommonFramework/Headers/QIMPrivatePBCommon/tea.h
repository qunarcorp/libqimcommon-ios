//
//  tea.h
//  qtalkstream
//
//  Created by may on 16/8/11.
//  Copyright © 2016年 qtalkteam. All rights reserved.
//

#ifndef tea_h
#define tea_h

#include <stdio.h>
#include <stdint.h>
int32_t EndianIntConvertLToBig(int32_t InputNum);
void tea_encrypt (uint32_t* v, uint32_t* k);
void tea_decrypt (uint32_t* v, uint32_t* k);

#endif /* tea_h */

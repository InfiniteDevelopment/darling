// Modified by Lubos Dolezel for Darling
/*
 * Copyright (c) 2007 Apple Inc. All rights reserved.
 * Copyright (c) 2003-2006 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */
 
 
 #include <machine/cpu_capabilities.h>
 
#ifdef DARLING
#	define _sys_icache_invalidate sys_icache_invalidate
#	define _sys_dcache_flush sys_dcache_flush
#endif

    .text
    .align (2<<4), 0x00

/* void sys_icache_invalidate(addr_t start, int length) */

	.globl	_sys_icache_invalidate
_sys_icache_invalidate:
	// This is a NOP on intel processors, since the intent of the API
	// is to make data executable, and Intel L1Is are coherent with L1D.
	ret


/* void sys_dcache_flush(addr_t start, int length)  */

	.globl	_sys_dcache_flush
_sys_dcache_flush:
	testq	%rsi,%rsi		// length 0?
	jz	2f			// yes
	mfence				// ensure previous stores make it to memory
	clflush	-1(%rdi,%rsi)		// make sure last line is flushed
1:
	clflush	(%rdi)			// flush a line
	addq	$64,%rdi
	subq	$64,%rsi
	ja	1b
	mfence				// make sure memory is updated before we return
2:
	ret

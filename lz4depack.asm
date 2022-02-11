#Licensed under the 3-Clause BSD License
#Copyright 2021, Martin Wendt
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
#3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
#TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
#CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#======================================================
#Sytax for RV32IC
#The C extention is optional but the code is written with that in mind

depack:
   #in: a0 is source
   #    a1 is destination
   #used: a0,a1,a2,a3,a4,a5 for compliance with C-extension
   #      a6,t0 additional registers that don't have to be saved

   srcptr = a0
   dstptr = a1

   srcend = a2
   cpysrc = a3
   cpylen = a4
   c_tmp  = a5				#should be RVC-friendly
   token  = a6				#RVC not needed
   alt_ra = t0

   mv alt_ra, ra			#save return address
   lhu srcend, 0(srcptr)		#read size from header
   addi srcptr, srcptr, 2
   add srcend, srcend, srcptr		#current pos+size=end
fetch_token:
   lbu token, 0(srcptr)
   addi srcptr, srcptr, 1
   srli cpylen, token, 4		#cpylen = literal length
   beqz cpylen, fetch_offset
   jal fetch_length

   mv cpysrc, srcptr
   jal copy_data			#literal copy cpysrc to dstptr
   mv srcptr, cpysrc
   bge srcptr, srcend, ret		#reached end of data? lz4 always ends with a literal

fetch_offset:
   lbu c_tmp, 0(srcptr)			#offset is halfword but at byte alignment
   sub cpysrc, dstptr, c_tmp
   lbu c_tmp, 1(srcptr)
   addi srcptr, srcptr, 2		#placed here for pipeline
   slli c_tmp, c_tmp, 8
   sub cpysrc, cpysrc, c_tmp
   andi cpylen, token, 0x0f		#get offset
   jal fetch_length
   addi cpylen, cpylen, 4		#match length is >4 bytes
   jal copy_data
   j fetch_token
ret:
   jr alt_ra				#return

fetch_length:
   xori c_tmp, cpylen, 0xf
   bnez c_tmp, _done			#0x0f indicates further bytes

_loop:   
   lbu c_tmp, 0(srcptr)
   addi srcptr, srcptr, 1
   add cpylen, cpylen, c_tmp
   xori c_tmp, c_tmp, 0xff		#0xff indicates further bytes
   beqz c_tmp, _loop
_done:
   ret

copy_data:
   lbu c_tmp, 0(cpysrc)
   addi cpysrc, cpysrc, 1		#placed here for pipeline
   sb c_tmp, 0(dstptr)
   addi dstptr, dstptr, 1
   addi cpylen, cpylen, -1
   bnez cpylen, copy_data
   ret

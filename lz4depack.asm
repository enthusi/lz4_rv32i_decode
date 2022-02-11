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
   #used: a1,a2,a3,a4,a5,a6 for compliance with C-extension
   
   addi	sp,sp,-16
   sw	ra, 0(sp)
   lhu a2, 0(a0)        #read size from header
   addi a0, a0 ,2
   add a3, a2, a0       #current pos+size=end
fetch_token:
   lbu a4, 0(a0)
   addi a0, a0, 1
   srli a5, a4, 4       #a5 = literal length
   beqz a5, fetch_offset
   jal fetch_length

   mv a2, a0
   jal copy_data        #literal copy a2 to a1
   mv a0, a2

fetch_offset:
   lbu s1, 0(a0)        #offset is halfword but at byte alignment
   sub a2, a1, s1
   lbu s1, 1(a0)
   addi a0, a0, 2       #placed here for pipeline
   slli s1, s1, 8
   sub a2, a2, s1 
   andi a5, a4, 0x0f    #get offset
   jal fetch_length
   addi a5, a5, 4       #match length is >4 bytes
   jal copy_data
   bge a3, a0, fetch_token #reached end of data?
   lw ra, 0(sp)
   addi sp, sp, 16
   ret

fetch_length:
   xori s1, a5, 0xf
   bnez s1, _done       #0x0f indicates further bytes

_loop:   
   lbu s1, 0(a0)
   addi a0, a0, 1
   add a5, a5, s1
   xori s1, s1, 0xff    #0xff indicates further bytes
   beqz s1, _loop
_done:
   ret

copy_data:
   lbu a6, 0(a2)
   addi a2, a2, 1       #placed here for pipeline
   sb a6, 0(a1)
   addi a1, a1, 1
   addi a5, a5, -1
   bnez a5, copy_data
   ret

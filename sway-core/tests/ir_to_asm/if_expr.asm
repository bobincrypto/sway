.program:
ji   i4
noop
DATA_SECTION_OFFSET[0..32]
DATA_SECTION_OFFSET[32..64]
lw   $ds $is 1
add  $$ds $$ds $is
lw   $r0 data_0               ; literal instantiation
jnei $r0 $one i11
lw   $r0 data_1               ; literal instantiation
move $r1 $r0
ji   i13
lw   $r0 data_2               ; literal instantiation
move $r1 $r0
ret  $r1
noop                          ; word-alignment of data section
.data:
data_0 .bool 0x00
data_1 .u64 0xf4240
data_2 .u64 0x2a

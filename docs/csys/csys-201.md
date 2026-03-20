### Information Storage

Most computers use the *byte* as the smallest addressable unit of
memory (instead of working with individual bits). This does not mean
however that the smallest space that is stored in the hardware is
actually one byte, that depends on the *word size*. The byte being the
smallest addressable unit of memory simply means that, when writing
programs, this is the smallest value we can work with.

A program views memory as a very large array of bytes called *virtual
memory*. Each byte has an address and the size of the address is
dictated by the word size. Most computers nowadays have a word size of
64 bits meaning memory addresses are also the same size: 8 bytes.

Program objects that span more than one byte are stored *contiguosly*
in memory. Byte ordering, least significant byte to most significant,
or most significant to least, is dictated by the machine being little
endian or big endian respectively.

Max unsigned value for *b* bits: $2^b - 1$

Example for a byte: $2⁸-1=255$

Important numbers (note that for signed min, the sign bit is set to 1
while all others are set to 0):

| Value        | 8 bits      | 16 bits          | 32 bits                     |
| ------------ | ----------- | ---------------- | --------------------------- |
| Unsigned max | 0xFF (255)  | 0xFFFF (65,535)  | 0xFFFFFFFF (4,294,967,295)  |
| Signed min   | 0x80 (-128) | 0x8000 (-32,768) | 0x80000000 (-2,147,483,648) |
| Signed max   | 0x7F (127)  | 0x7FFF (32,767)  | 0x7FFFFFFF (2,147,483,647)  |
| -1           | 0xFF        | 0xFFFF           | 0xFFFFFFFF                  |
| 0            | 0x00        | 0x0000           | 0x00000000                  |


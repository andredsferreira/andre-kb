*ASCII characters* are encoded using values in the range [0,127].
Meaning, if you are trying to use the char to represent an ASCII
character it doesn't really matter if its signed or unsigned.

*Arithmetic* in C always undergoes *integer promotion* for types smaller
than int. For example having two chars "a" and "b", and a char sum = a
+ b, the chars first get converted to integers, then the sum happens,
then the sum gets converted back to char.

Keep shift amounts less than word size, i.e, don't do this, assuming
"a" is a byte: a << 16, a << 8, a << 7. In general avoid w << b, where
b > w (this also applies to right shifts >>).

In logical operations, *if one operand is unsigned C implicitly*
*converts all operands to unsigned*. This can give rise to bugs if
special attention is not paid. For example, considering that both
operands are 8 bits long (char): 1U > -1 will yield false (-1 will be
converted to unsigned since the first operand is unsigned and -1
converted to unsigned is 255).

When converting size and sign at the same time, the C standard
establishes that first the size is converted then the sign is
converted. For example, converting *short x = -12345* (0xCFC7) to an
*unsigned int* yields 4294954951 (0xFFFFCFC7) decimal. Due to sign
extension left bytes were set to F, giving a very large unsigned
result.
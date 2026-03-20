*ASCII characters* are encoded using values in the range [0,127].
Meaning, if you are trying to use the char to represent an ASCII
character it doesn't really matter if its signed or unsigned.

Keep shift amounts less than word size, i.e, don't do this, assuming
"a" is a byte: a << 16, a << 8, a << 7. In general avoid w << b, where
b > w (this also applies to right shifts >>).

C implicitly converts signed values to unsigned when performing
logical operations between them (when performing "<", ">", or "==" for
example). This gives rise to weird evaluations, the following for
example will wield false: *214748364U > INT_MIN (-2147483648) == 0*.
The second operand is converted to unsigned.

*PP-3.1*

| Operand        | Value |
| -------------- | ----- |
| %rax           | 0x100 |
| 0x104          | 0xAB  |
| $0x108         | 0x108 |
| (%rax)         | 0xFF  |
| 4(%rax)        | 0xAB  |
| 9(%rax,%rdx)   | 0x11  |
| 260(%rcx,%rdx) | 0x13  |
| 0xFC(,%rcx,4)  | 0xFF  |
| (%rax,%rdx,4)  | 0x11  |

*PP-3.6*

| Instruction               | Result     |
| ------------------------- | ---------- |
| leaq 9(%rdx), %rax        | 9 + q      |
| leaq (%rdx,%rbx), %rax    | p + q      |
| leaq (%rdx,%rbx,3), %rax  | q + 3p     |
| leaq 2(%rbx,%rbx,7), %rax | 2 + 8p     |
| leaq 0xE(,%rdx,3), %rax   | 14 + 3q    |
| leaq 6(%rbx,%rdx,7), %rax | 3 + p + 7q |

*PP-3.8*

| Instruction              | Destination | Value |
| ------------------------ | ----------- | ----- |
| addq %rcx, (%rax)        | 0x100       | 0x100 |
| subq %rdx, 8(%rax)       | 0x108       | 0xA8  |
| imulq €16, (%rax,%rdx,8) | 0x118       | 0x110 |
| incq 16(%rax)            | 0x110       | 0x14  |
| decq %rcx                | %rcx        | 0x0   |
| subq %rdx,%rax           | %rax        | 0xFD  |

*PP-3.9*




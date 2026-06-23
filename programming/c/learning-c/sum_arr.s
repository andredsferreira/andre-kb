.global sum_arr

.text

# Sums first three elements on an array

sum_arr:
    movl $0, %eax
    movq $0, %rdx

    addl (%rdi,%rdx,4), %eax
    incq %rdx

    addl (%rdi,%rdx,4), %eax
    incq %rdx

    addl (%rdi,%rdx,4), %eax

    ret

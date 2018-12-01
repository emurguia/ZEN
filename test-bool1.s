	.text
	.file	"Zen"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$1, 4(%rsp)
	leaq	.Lint_fmt(%rip), %rdi
	movl	$1, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	xorl	%eax, %eax
	popq	%rcx
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr_fmt,@object       # @str_fmt
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr_fmt:
	.asciz	"%s\n"
	.size	.Lstr_fmt, 4

	.type	.Lfmt,@object           # @fmt
.Lfmt:
	.asciz	"%g\n"
	.size	.Lfmt, 4

	.type	.Lint_fmt,@object       # @int_fmt
.Lint_fmt:
	.asciz	"%d\n"
	.size	.Lint_fmt, 4


	.section	".note.GNU-stack","",@progbits

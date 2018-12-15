	.text
	.file	"Zen"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	movabsq	$4609434218613702656, %rax # imm = 0x3FF8000000000000
	movq	%rax, -32(%rsp)
	movabsq	$4612811918334230528, %rcx # imm = 0x4004000000000000
	movq	%rcx, -24(%rsp)
	movq	%rcx, -8(%rsp)
	movq	%rax, -16(%rsp)
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

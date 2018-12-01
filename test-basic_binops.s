	.text
	.file	"Zen"
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3               # -- Begin function main
.LCPI0_0:
	.quad	4615851848082705613     # double 3.8500000000000001
	.text
	.globl	main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$48, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -16
	movabsq	$4613374868287651840, %rax # imm = 0x4006000000000000
	movq	%rax, 40(%rsp)
	movabsq	$4607632778762754458, %rax # imm = 0x3FF199999999999A
	movq	%rax, 32(%rsp)
	movabsq	$4615851848082705613, %rax # imm = 0x400ECCCCCCCCCCCD
	movq	%rax, 24(%rsp)
	movabsq	$4613994113236415284, %rax # imm = 0x4008333333333334
	movq	%rax, 16(%rsp)
	movabsq	$4612811918334230528, %rax # imm = 0x4004000000000000
	movq	%rax, 8(%rsp)
	movabsq	$4610109758557808230, %rax # imm = 0x3FFA666666666666
	movq	%rax, (%rsp)
	leaq	.Lfmt(%rip), %rbx
	movsd	.LCPI0_0(%rip), %xmm0   # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	movsd	16(%rsp), %xmm0         # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	movsd	8(%rsp), %xmm0          # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	movsd	(%rsp), %xmm0           # xmm0 = mem[0],zero
	movb	$1, %al
	movq	%rbx, %rdi
	callq	printf@PLT
	xorl	%eax, %eax
	addq	$48, %rsp
	popq	%rbx
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

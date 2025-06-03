# ===========================================================================
# Lexical scanner
#
# This file implements a lexical scanner with a simple greedy matcher.
# While this approach is less general than a DFA, it is more readable and
# easier to craft by hand.
#
# This scanner is designed to be driven by the parser. The scanner uses
# global state to simplify the implementation.
#
# The function Init must be called before calling Scan.
# ===========================================================================

# ===========================================================================
# Design
#
# A property of Primordial that makes scanning very easy is that the first
# character fully determines the class. Once that one has been matched, we
# can greedily consume characters until we get an unexpected character.
#
# This approximation isn't perfect:
#
# - IDs and keywords need to be put in the same class because they overlap,
#   and then disambiguated by checking against the list of keywords.
#
# - We separate between separators (which are a single character and cannot
#   be combined with anything else) and operators (which can contain one or
#   more characters). Operators are greedily matched and then compared
#   against a table at the end, similar to keywords.
#
# The latter point has two added benefits:
#
#   1. There are never doubts about where operators start and end, which
#      can happen in languages like C (think something like `x>>=--b`).
#      Because they are parsed greedily, the language forces the user to
#      separate them (which would be at least a hypothetical `x>>= --b`).
#
#   2. Adding new operators to the language, or to a derived language, will
#      not break the scanning of older source files.
# ===========================================================================

#include <compat.S>
#include <millicode.S>
#include <safe_str.S>
#include <slice.S>
#include "compile/scanner.S"


# ===========================================================================
# Constants
# ===========================================================================

.section .rodata

# Keyword list.
#
# Token types must be listed the in same order as inc/scanner.S.
Xalign
keywords_data:
safe_str_slice if_kw
safe_str_slice for_kw
safe_str_slice func_kw
.equiv keywords_size, 3

# Operator list.
#
# Token types must be listed the in same order as inc/scanner.S.
Xalign
operators_data:
safe_str_slice plus_op
safe_str_slice minus_op
safe_str_slice mult_op
safe_str_slice div_op
.equiv operators_size, 4

# Keyword strings.
Xalign
safe_str if_kw, "if"
safe_str for_kw, "for"
safe_str func_kw, "func"

# Operator strings.
safe_str plus_op, "+"
safe_str minus_op, "-"
safe_str mult_op, "*"
safe_str div_op, "/"

# Separator characters. Note that separators are always one character long.
#
# Token types must be listed the in same order as inc/scanner.S.
safe_str separator_list, "(),.;?@[]{}"

# Characters that can be part of an operator.
safe_str operator_chars, "!%&*+-/:<=>\^|~"

# Characters used by symbols and quoting: "$'`

# Characters used by comments: #

# ===========================================================================
# Global state
# ===========================================================================

.section .bss

Xalign
.lcomm scanner, Scanner_size


# ===========================================================================
# Constructors
# ===========================================================================

.section .text

# Initialise the scanner.
#
# Input:
#   a0 -> Pointer to the start of the input
#   a1 -> Size of the input
.global "compile/scanner.Init"
"compile/scanner.Init":
	# Arguments.
	#define input_size a0
	#define input_data a1

	# Temporary registers.
	#define scanner_ptr t1
	#define input_end   t2

	.cfi_startproc
	la scanner_ptr, scanner

	# Store the start position.
	sx input_data, Scanner.pos(scanner_ptr)

	# Store the end pointer to simplify checking for EOF.
	add input_end, input_data, input_size
	sx input_end, Scanner.end(scanner_ptr)

	# Initialize line:column.
	li t0, 1
	sx t0, Scanner.line(scanner_ptr)
	sx t0, Scanner.column(scanner_ptr)

	ret
	.cfi_endproc


# ===========================================================================
# Scanner
# ===========================================================================

# Scan the next token.
#
# Output:
#   a0 -> token_type (0 if none)
#   a1 -> token_size
#   a2 -> token_start
#   a3 -> token_line
#   a4 -> token_column
.global "compile/scanner.Scan"
"compile/scanner.Scan":
	# Temporary registers.
	#define scanner_ptr t1

	# Callee-preserved registers.
	#
	# loop_pos is only used by this function. It must be the first to
	# allow children function to use it for other purposes.
	#define loop_pos      s1
	#define ch            s2
	#define pos           s3
	#define end           s4
	#define line          s5
	#define column        s6
	#define token_start   s7
	#define token_end     s8
	#define token_line    s9
	#define token_column  s10

	.cfi_startproc
	save_10

	# Load global state.
	la scanner_ptr, scanner
	lx pos, "Scanner.pos"(scanner_ptr)
	lx end, "Scanner.end"(scanner_ptr)
	lx line, "Scanner.line"(scanner_ptr)
	lx column, "Scanner.column"(scanner_ptr)

	# Load the current character once instead of in every iteration,
	# even if we need to repeat the EOF guard.
	beq pos, end, .LScan.EOF
	lbu ch, 0(pos)

.LScan.match:
	beq pos, end, .LScan.EOF

	# Call all the possible skippers in sequence.
	#
	# They merely consume input and cannot generate tokens, but we still
	# need to check their result to see if we need to apply them more,
	# because multiple skippers may need to be applied (e.g., whitespace
	# followed by comments, followed by whitespace on the next line).
	call skip_whitespace
	bnez a0, .LScan.match

	call skip_comments
	bnez a0, .LScan.match

	# Call all the possible accepters in sequence.
	# They will update pos on match.
	#
	# The token accepters return the recognised token type (0 if none).
	call accept_type_id
        bnez a0, .Lscan_OK

	call accept_value_id_or_kw
	bnez a0, .Lscan_OK

	call accept_separator
	bnez a0, .Lscan_OK

	call accept_operator
	bnez a0, .Lscan_OK

	call accept_number
	bnez a0, .Lscan_OK

	# Discard bad character and report error.
	call start_token
	call consume
	li a0, TK_BAD_CHAR

	# Fall through.

.Lscan_OK:
	# a0 was set by an accepter and is the token type (or 0 if none).
	sub a1, token_end, token_start
	mv a2, token_start
	mv a3, token_line
	mv a4, token_column

	# Fall through.

.Lscan_end:
	# scanner_ptr must be reloaded because it uses a temporary register.
	la scanner_ptr, scanner

	# Persist global state.
	sx pos, "Scanner.pos"(scanner_ptr)
	sx line, "Scanner.line"(scanner_ptr)
	sx column, "Scanner.column"(scanner_ptr)

	restore_10

.LScan.EOF:
	# a0 == 0: no tokens were found.
	li a0, 0
	j .Lscan_end

	.cfi_endproc


# ===========================================================================
# Character and token helpers
# ===========================================================================

# Subfunction to start a new token.
#
# It must be called before consuming the first character.
start_token:
	.cfi_startproc
	mv token_start, pos
	mv token_end, pos
	mv token_line, line
	mv token_column, column
	ret
	.cfi_endproc

# Subfunction to consume the current character and advance pos.
#
# Outputs:
#   a0: 1 if a character was read, 0 if we reached EOF.
consume:
	.cfi_startproc

	# This needs to happen before incrementing `pos` to handle an LF
	# at the very start of the file.
	addi t0, ch, -'\n'
	beqz t0, .Lconsume.LF

	# We stay on the same line: increase the column position.
	addi column, column, 1

.Lconsume.advance:
	addi pos, pos, 1

	# Increase token_end every char.
	# Not very efficient, but it saves us having to do it on
	# every accepter.
	addi token_end, token_end, 1

	bgeu pos, end, .Lconsume.EOF

	lbu ch, 0(pos)

.Lconsume.OK:
	# Signal that a character was read.
	li a0, 1
	ret

.Lconsume.LF:
	# New lines are special for tracking line and column.
	addi line, line, 1
	li column, 1
	j .Lconsume.advance

.Lconsume.EOF:
	# Defensive programming: set ch to NUL to ease debugging.
	li ch, 0

	# Signal that no characters were read.
	li a0, 0
	ret

	.cfi_endproc


# ===========================================================================
# Skippers
#
# These are a special kind of term accepter that does not return tokens.
# Instead, they ignore characters (whitespace and comments) and return 1 if
# any character was skipped, 0 otherwise.
#
# All token accepters can assume that ch contains the character at pos.
# To preserve this invariant, only use consume to move through the input.
# ===========================================================================

# Skip contiguous whitespace.
skip_whitespace:
	.cfi_startproc
	save_0

	# If the first char is rejected, return 0.
	call is_supported_space
	beqz a0, .Lwhitespace.reject

.Lwhitespace.loop:
	# From this point onwards, always return 1.
	call consume
	beqz a0, .Lwhitespace.accept

	call is_supported_space
	bnez a0, .Lwhitespace.loop

.Lwhitespace.accept:
	li a0, 1
	restore_0

.Lwhitespace.reject:
	li a0, 0

	restore_0
	.cfi_endproc


# Skip a '#' and any other trailing characters until we reach
# a newline or the end of the input.
skip_comments:
	.cfi_startproc
	save_1

	lbu ch, 0(pos)
	li t0, '#'
	bne t0, ch, .Lcomment.reject

	# Keep it in a saved register to prevent re-initialization.
	li s1, '\n'

.Lcomment.loop:
	call consume
	beqz a0, .Lcomment.accept
	bne s1, ch, .Lcomment.loop

.Lcomment.accept:
	li a0, 1
	restore_1

.Lcomment.reject:
	li a0, 0
	restore_1

	.cfi_endproc


# ===========================================================================
# Token accepters
#
# All token accepters can assume that ch contains the character at pos.
# To preserve this invariant, only use consume to move through the input.
#
# Outputs: (except skip functions)
#   a0: token_type (0 if no token was recognised)
# ===========================================================================

accept_type_id:
	.cfi_startproc
	save_0

	mv a0, ch
	call "ascii.IsUpper"
	beqz a0, .Ltype_id.return

	call start_token

.Ltype_id.loop:
	call consume
	beqz a0, .Ltype_id.accept

	call continues_id_or_kw
	bnez a0, .Ltype_id.loop

.Ltype_id.accept:
	li a0, TK_TYPE_ID

.Ltype_id.return:
	restore_0
	.cfi_endproc


accept_value_id_or_kw:
	.cfi_startproc
	save_0

	call starts_value_id_or_kw
	bnez a0, .Lvalue_id.started

	# Reject (a0 is already 0 by construction).
	j .Lvalue_id.return

.Lvalue_id.started:
	call start_token

.Lvalue_id.loop:
	call consume
	beqz a0, .Lvalue_id.detect_keywords

	call continues_id_or_kw
	bnez a0, .Lvalue_id.loop

.Lvalue_id.detect_keywords:
	# Recognise keywords. If none is found, return an identifier.
	sub a0, token_end, token_start
	mv a1, token_start
	li a2, keywords_size
	la a3, keywords_data
	call "mem.Index"
	bltz a0, .Lvalue_id.return_id

	# Obtain the token type.
	#
	# Exploit the fact that keywords_data is sorted in the same order
	# used by the operator token IDs.
	add a0, a0, TK_KEYWORD_BASE

	j .Lvalue_id.return

.Lvalue_id.return_id:
	li a0, TK_VALUE_ID

.Lvalue_id.return:
	restore_0
	.cfi_endproc


accept_operator:
	.cfi_startproc
	save_0

	call is_operator_char
	bnez a0, .Loperator_started

	# Reject (a0 is already 0 by construction).
	j .Loperator_return

.Loperator_started:
	call start_token

.Loperator.loop:
	call consume
	beqz a0, .Loperator_detect

	call is_operator_char
	bnez a0, .Loperator.loop

.Loperator_detect:
	# Recognise operators.
	sub a0, token_end, token_start
	mv a1, token_start
	li a2, operators_size
	la a3, operators_data
	call "mem.Index"
	beqz a1, .Loperator_error

	# Obtain the token type.
	#
	# Exploit the fact that operators_data is sorted in the same order
	# used by the operator token IDs.
	addi a0, a0, TK_OPERATOR_BASE

.Loperator_return:
	restore_0

.Loperator_error:
	li a0, TK_BAD_OPERATOR
	j .Loperator_return

	.cfi_endproc


accept_separator:
	.cfi_startproc
	save_1

	# Callee-preserved registers.
	# Use s1 because other registers are used by start_token and consume.
	#define found_pos s1

	# Temporary registers.
	#define token_type_ptr t1

	# If the matching fails, jump to the return section.
	# In that case, a0 will be 0 (TK_NONE) by construction.
	mv a0, ch
	la a1, separator_list_data
	li a2, separator_list_size
	call "ascii.Index"
	bltz a0, .Lseparator_fail

	mv found_pos, a0

	call start_token
	call consume

	# Obtain the token type.
	#
	# Exploit the fact that operators_data is sorted in the same order
	# used by the operator token IDs.
	addi a0, found_pos, TK_SEPARATOR_BASE

.Lseparator_end:
	restore_1

.Lseparator_fail:
	li a0, 0
	j .Lseparator_end

	.cfi_endproc


accept_number:
	.cfi_startproc
	save_0

	mv a0, ch
	call "ascii.IsDigit"
	beqz a0, .Lnumber.return

	call start_token

.Lnumber.loop:
	call consume
	beqz a0, .Lnumber.accept

	mv a0, ch
	call "ascii.IsDigit"
	bnez a0, .Lnumber.loop

.Lnumber.accept:
	li a0, TK_NUMBER

.Lnumber.return:
	restore_0
	.cfi_endproc


# ===========================================================================
# Character class tests
# ===========================================================================

# Match: [_a-z]
starts_value_id_or_kw:
	.cfi_startproc
	save_0

	mv a0, ch
	call "ascii.IsLetter"
	bnez a0, .Lstarts_value_id_or_kw.end

	# c == '_'
	addi t0, ch, -'_'
	seqz a0, t0

.Lstarts_value_id_or_kw.end:
	restore_0
	.cfi_endproc


# Match: [_a-zA-B0-9]
continues_id_or_kw:
	.cfi_startproc
	save_0

	mv a0, ch
	call "ascii.IsLetter"
	bnez a0, ".Lstarts_value_id_or_kw.end"

	mv a0, ch
	call "ascii.IsDigit"
	bnez a0, ".Lstarts_value_id_or_kw.end"

	# c == '_'
	addi t0, ch, -'_'
	seqz a0, t0

".Lstarts_value_id_or_kw.end":
	restore_0
	.cfi_endproc


# Match operator characters.
#
# We could use binary search here, but why bother.
is_operator_char:
	.cfi_startproc
	save_0

	mv a0, ch
	la a1, operator_chars_data
	li a2, operator_chars_size
	call "ascii.Index"

	# Return 0 if Index returns negative, 1 otherwise.
	sltz a0, a0
	xori a0, a0, 1

	restore_0
	.cfi_endproc


# Match the spaces that are acceptable in a source file.
#
# Line feed and vertical tab are excluded because they would be confusing.
# CR has been removed because for simplicity we only accept LF as newline.
is_supported_space:
	.cfi_startproc

	li t0, ' '
	beq t0, ch, .Lis_supported_space.match

	li t0, '\t'
	beq t0, ch, .Lis_supported_space.match

	li t0, '\n'
	beq t0, ch, .Lis_supported_space.match

.Lis_supported_space.reject:
	li a0, 0
	ret

.Lis_supported_space.match:
	li a0, 1
	ret

	.cfi_endproc

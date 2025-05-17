SECTIONS
{
    .test_cases : ALIGN(CONSTANT(MAXPAGESIZE)) {
        PROVIDE(__start_test_cases = .);
        *(.test_cases)
        PROVIDE(__end_test_cases = .);
    }
    .bss : ALIGN(CONSTANT(MAXPAGESIZE)) { *(.bss) }
}
INSERT AFTER .text;

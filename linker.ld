SECTIONS
{
    .test_cases : {
        PROVIDE(__start_test_cases = .);
        *(.test_cases)
        PROVIDE(__end_test_cases = .);
    }
}
INSERT AFTER .text;


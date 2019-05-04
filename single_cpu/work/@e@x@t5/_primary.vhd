library verilog;
use verilog.vl_types.all;
entity EXT5 is
    port(
        Imm_5           : in     vl_logic_vector(4 downto 0);
        EXTOp_5         : in     vl_logic;
        Imm32_5         : out    vl_logic_vector(31 downto 0)
    );
end EXT5;

----------------------------------------------------------------------------------
-- Engineer: AZR
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: 
-- Target Devices: xc7a35t
-- Tool Versions: 16.1
-- Description: core
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity baud_gen is
	generic( BAUD_DIV   : std_logic_vector(5 downto 0) :=  "000000");                  
	port(                            
            clk_i      : in std_logic;                                             
            rstn_i     : in std_logic;                                            
            rstart_i   : in std_logic;    
            baud_rx_o  : out std_logic;     
            baud_tx_o  : out std_logic       
         
    );
end entity baud_gen;

architecture rtl of baud_gen is

constant CLK_DIV     : std_logic_vector(11 downto 0) := conv_std_logic_vector(216,12);   
signal mcount        : std_logic_vector(11 downto 0);
signal count         : std_logic_vector(6 downto 0);   
signal clk_434       : std_logic;  
signal baud_o        : std_logic;  
signal clk_baud      : std_logic;  


    attribute mark_debug : string;
    attribute mark_debug of clk_baud : signal is "true";

begin 

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            mcount  <= (others => '0');
            clk_434 <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if rstart_i = '1' then
                mcount  <= (others => '0');
                clk_434 <= '1';
            elsif mcount < CLK_DIV then
                mcount  <= mcount+1;
                clk_434 <= '0';
            else    
                mcount  <= (others => '0');
                clk_434 <= '1';
            end if;
        end if;
    end process;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            count  <= (others => '0');
            baud_o <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if clk_434 = '1' then
                if count < BAUD_DIV+1 then
                    count  <= count+1;
                    baud_o <= '0';
                else    
                    baud_o <= clk_434;
                    count  <= (others => '0');
                end if;
            else
                baud_o <= '0';
            end if;
        end if;
    end process;
    

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            clk_baud <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if baud_o = '1' then
                clk_baud  <= not clk_baud;
            end if;
        end if;
    end process;
  
  baud_tx_o <= baud_o when (clk_baud = '1') else '0';
  baud_rx_o <= baud_o;

end architecture;
		

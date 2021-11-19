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


entity uart_tx is              
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            valid_i  : in std_logic;  
            byte_i   : in std_logic_vector(7 downto 0);    
            busy_o   : out std_logic;        
            tx_o     : out std_logic       
         
    );
end entity uart_tx;

architecture rtl of uart_tx is
 
signal txbuff    : std_logic_vector(10 downto 0);
signal count     : std_logic_vector(3 downto 0);
signal s_valid   : std_logic;
signal s_busy    : std_logic;
signal s_valid_buff : std_logic;


begin 

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            txbuff  <= (others => '0');
        elsif clk_i'event and clk_i = '0' then 
            if valid_i = '1' then
                txbuff  <= '1' & byte_i & "01";
            elsif baud_i = '1' then
                txbuff <= '1' & txbuff(10 downto 1);
            end if;
        end if;
    end process;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_valid_buff  <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if s_busy = '1' then
                if valid_i = '1' then
                    s_valid_buff  <= '1';
                end if;
            elsif s_valid = '1' then
                s_valid_buff  <= '0';
            end if;
        end if;
    end process;

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_valid  <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if s_busy = '0' then
                s_valid <= valid_i or s_valid_buff;
            end if;
        end if;
    end process;
    
    

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            count  <= (others => '0');
        elsif clk_i'event and clk_i = '0' then 
            if valid_i = '1' then
                count  <= conv_std_logic_vector(12,4);
            elsif baud_i = '1' then
                if count > "0000" then   
                    count  <= count-1;
                end if;
            end if;
        end if;
    end process;
    
   
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            tx_o  <= '1';
        elsif clk_i'event and clk_i = '0' then 
            if baud_i = '1' then
                tx_o <= txbuff(0);
            end if;
        end if;
    end process;
    
   
    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_busy  <= '0';
        elsif clk_i'event and clk_i = '0' then 
            if count = "0000" then
                s_busy  <= '0';
            else
                s_busy  <= '1';
            end if;
        end if;
    end process;
    
    busy_o <= s_busy;
  

end architecture;
		

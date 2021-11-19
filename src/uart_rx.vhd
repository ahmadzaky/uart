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


entity uart_rx is              
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            valid_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
         
    );
end entity uart_rx;

architecture rtl of uart_rx is
 
signal rxbuff       : std_logic_vector(9 downto 0);
signal rxbuffd      : std_logic_vector(9 downto 0);
signal count        : std_logic_vector(3 downto 0);
signal start_detect : std_logic;
signal start_v      : std_logic;
signal byte_v       : std_logic;
signal receiving_v  : std_logic;
signal receiving_d  : std_logic;
signal s_rx         : std_logic;
signal s_rxd        : std_logic;
signal s_rxdd       : std_logic;
signal clk_baud     : std_logic;
signal clk_baud_d   : std_logic;
signal rx_baud      : std_logic;


    attribute mark_debug : string;
    attribute mark_debug of rxbuffd : signal is "true";
    attribute mark_debug of count   : signal is "true";

begin 

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            s_rx    <= '1';
            s_rxd   <= '1';
            s_rxdd  <= '1';
        elsif clk_i'event and clk_i = '1' then 
            if baud_i = '1' then
                s_rx    <= rx_i;
            end if;
            s_rxd   <= s_rx;
            s_rxdd  <= s_rxd;
        end if;
    end process;
    
    rx_baud <= clk_baud when (clk_baud_d = '0') else '0';
    byte_v  <= receiving_d when (receiving_v = '0') else '0';

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            clk_baud   <= '0';
            clk_baud_d <= '0';
        elsif clk_i'event and clk_i = '1' then 
            if baud_i = '1' then 
                if receiving_v = '1' then
                    clk_baud <= not clk_baud;
                else
                    clk_baud   <= '0';
                end if;
            end if;
            clk_baud_d <= clk_baud;
        end if;
    end process;


    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            receiving_v <= '0';
            receiving_d <= '0';
            valid_o     <= '0';
        elsif clk_i'event and clk_i = '1' then 
            if start_v = '1' then
                receiving_v <= '1';
            elsif count = "0000" then
                receiving_v <= '0';
            end if;
            receiving_d <= receiving_v;
            valid_o     <= byte_v;
        end if;
    end process;


    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            start_v <= '0';
        elsif clk_i'event and clk_i = '1' then 
            if receiving_v = '1' then
                start_v <= '0';
            else
                start_v <= start_detect;
            end if;
        end if;
    end process;
    
    
    start_detect <= s_rxdd when (s_rxd = '0') else '0';

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            count  <= (others => '0');
        elsif clk_i'event and clk_i = '1' then 
            if start_v = '1' then
                count  <= conv_std_logic_vector(10,4);
            elsif rx_baud = '1' then
                if count > "0000" then   
                    count  <= count-1;
                end if;
            end if;
        end if;
    end process;


   process(rstn_i, clk_i)
   begin
       if rstn_i = '0' then
           rxbuff <= (others => '1');
       elsif clk_i'event and clk_i = '1' then 
           if start_v = '1' then
                rxbuff <= (others => '1');
           elsif rx_baud = '1' then
               rxbuff <= s_rxd & rxbuff(9 downto 1);
           end if;
       end if;
   end process;
 
  busy_o <= receiving_v;
  
  

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            rxbuffd    <= (others => '0');
        elsif clk_i'event and clk_i = '1' then 
            rxbuffd <= rxbuff;
        end if;
    end process;
  

    process(rstn_i, clk_i)
    begin
        if rstn_i = '0' then
            byte_o    <= (others => '0');
        elsif clk_i'event and clk_i = '1' then 
            if byte_v = '1' then
                byte_o <= rxbuffd(8 downto 1);
            end if;
        end if;
    end process;

end architecture;
		

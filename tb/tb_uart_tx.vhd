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


entity tb_uart_tx is

end entity tb_uart_tx;	

architecture tb of tb_uart_tx is


    component baud_gen
        generic( BAUD_DIV   : std_logic_vector(5 downto 0) :=  "000000");                  
        port(                            
                clk_i      : in std_logic;                                             
                rstn_i     : in std_logic;                                            
                rstart_i   : in std_logic;    
                baud_rx_o  : out std_logic;     
                baud_tx_o  : out std_logic      
        );
    end component;

    component uart_tx              
        port(                            
                clk_i    : in std_logic;                                             
                rstn_i   : in std_logic;   
                baud_i   : in std_logic;  
                valid_i  : in std_logic;  
                byte_i   : in std_logic_vector(7 downto 0);    
                busy_o   : out std_logic;        
                tx_o     : out std_logic       
            
        );
    end component;
    
    component uart_rx          
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            valid_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
    );
    end component;


    component uart_buff  
        generic( buffsize : integer := 8);
        port(                            
                clk_i    : in std_logic;                                             
                rstn_i   : in std_logic;   
                byte_i   : in std_logic_vector(7 downto 0);   
                valid_i  : in std_logic;   
                busy     : in std_logic;  
                valid_o  : out std_logic;  
                byte_o   : out std_logic_vector(7 downto 0)   
            
        );
    end component;

    component rx_fsm is              
	port(                            
            clk_i    : in std_logic;                                             
            rstn_i   : in std_logic;   
            baud_i   : in std_logic;  
            rx_i     : in std_logic;  
            valid_o  : out std_logic;  
            start_o  : out std_logic;  
            byte_o   : out std_logic_vector(7 downto 0);    
            busy_o   : out std_logic      
         
    );
    end component;


    signal s_clk        : std_logic;
    signal s_rstn       : std_logic;
    signal s_baud_i     : std_logic;
    signal s_baud_tx_o  : std_logic;
    signal s_baud_rx_o  : std_logic;
    signal s_tx_o       : std_logic;
    signal s_busy_o     : std_logic;
    signal s_valid_i    : std_logic;
    signal s_valid_buf  : std_logic;
    signal start_v      : std_logic;
    signal s_byte_i     : std_logic_vector(7 downto 0);
    signal s_buff_o     : std_logic_vector(7 downto 0);

begin



        
        
        BDT : baud_gen
        generic map( BAUD_DIV   => "001010")               
        port map(                          
                clk_i      => s_clk,                                       
                rstn_i     => s_rstn,                                     
                rstart_i   => '0', 
                baud_tx_o  => s_baud_tx_o    
        );
        
        BDR : baud_gen 
        generic map( BAUD_DIV   => "001010")               
        port map(                          
                clk_i      => s_clk,                                       
                rstn_i     => s_rstn,                                 
                rstart_i   => start_v, 
                baud_rx_o  => s_baud_rx_o   
        );
        
        TX : uart_tx              
        port map(                            
                clk_i    =>   s_clk,                                       
                rstn_i   =>   s_rstn,
                baud_i   =>   s_baud_tx_o,
                valid_i  =>   s_valid_buf,
                byte_i   =>   s_buff_o,  
                busy_o   =>   s_busy_o,      
                tx_o     =>   s_tx_o 
        );
    
    
        RX :  uart_rx          
        port map(                            
                clk_i    =>  s_clk,          --: in std_logic;                                             
                rstn_i   =>  s_rstn,          --: in std_logic;   
                baud_i   =>  s_baud_rx_o,          --: in std_logic;  
                rx_i     =>  s_tx_o--,          --: in std_logic;  
          --      valid_o  =>  ,          --: out std_logic;  
         --       byte_o   =>  ,          --: out std_logic_vector(7 downto 0);    
          --      busy_o   =>            --: out std_logic      
        );
        
        
        BF : uart_buff  
        generic map( buffsize => 8)
        port map(                            
                clk_i    => s_clk, --: in std_logic;                                             
                rstn_i   => s_rstn, --: in std_logic;   
                byte_i   => s_byte_i, --: in std_logic_vector(7 downto 0);   
                valid_i  => s_valid_i, --: in std_logic;   
                busy     => s_busy_o, --: in std_logic;  
                valid_o  => s_valid_buf, --: out std_logic;  
                byte_o   => s_buff_o --: out std_logic_vector(7 downto 0)   
        );    
        
        
        RXv2 : rx_fsm             
        port map(                            
            clk_i    =>   s_clk , --: in std_logic;                                             
            rstn_i   =>   s_rstn , --: in std_logic;   
            baud_i   =>   s_baud_rx_o , --: in std_logic;  
            start_o  =>  start_v,
            rx_i     =>   s_tx_o  --: in std_logic;  
         --   valid_o  =>    , --: out std_logic;  
         --   byte_o   =>    , --: out std_logic_vector(7 downto 0);    
         --   busy_o   =>      --: out std_logic      
         
        );

    process
    begin
        s_rstn <= '0';
        wait for 5000 ns;
        s_rstn <= '1';
        wait;
    end process;
    
    process
    begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process;
    
    
    
    process
    begin
        s_byte_i <= "00000000";
        wait for 5000 ns;
        s_byte_i <= X"41";
        wait for 200000 ns;
        s_byte_i <= X"4B";
        wait for 100000 ns;
        s_byte_i <= X"31";
        wait for 10000 ns;
        s_byte_i <= X"32";
        wait for 10000 ns;
        s_byte_i <= X"33";
        wait for 10000 ns;
        wait;
    end process;
    
    process
    begin
        s_valid_i <= '0';
        wait for 6000 ns;
        s_valid_i <= '1';
        wait for 20 ns;
        s_valid_i <= '0';
        wait for 200000 ns;
        s_valid_i <= '1';
        wait for 20 ns;
        s_valid_i <= '0';
        wait for 100000 ns;
        s_valid_i <= '1';
        wait for 20 ns;
        s_valid_i <= '0';
        wait for 10000 ns;
        s_valid_i <= '1';
        wait for 20 ns;
        s_valid_i <= '0';
        wait for 10000 ns;
        s_valid_i <= '1';
        wait for 20 ns;
        s_valid_i <= '0';
        wait for 10000 ns;
        wait;
    end process;
    
    
end tb;
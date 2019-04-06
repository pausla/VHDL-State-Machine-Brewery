--PT 13:15 Paulina S³awiñska 238992 "browar"

library IEEE; --biblioteki
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uut is --deklaracja portów, entity
	Port( woda: in STD_LOGIC; --wejscia
			clk: in STD_LOGIC;
			reset: in STD_LOGIC;
			postep: out STD_LOGIC); --wyjscie
end uut;

architecture uut_arch of uut is --architektura

type STANY is (stop, dostawa_butelek, dostawa_ch_sl, warzenie, kapslowanie, magazyn); --deklaracja typu wyliczeniowego
signal stan, stan_nast : STANY;
signal chmiel :std_logic_vector(1 downto 0); --sygna³: chmiel 2-bitowy
signal slod :std_logic_vector(1 downto 0); --sygna³: slod 2-bitowy
signal skrzynka :std_logic_vector(1 downto 0); --sygna³: skrzynka 2-bitowy
signal butelki :std_logic_vector(1 downto 0); --sygna³: butelki 2-bitowy
begin

reg:process(clk, reset) --proces czu³y na reset i clock
begin
	if (reset='0') then --jesli reset aktywny
		stan <=stop; --automat jet w stanie stop
	elsif(clk'Event and clk='1') then --jesli zbocze narastaj¹ce zegara,
		stan<=stan_nast; --to stan zmienia siê na stan nastêpny
	end if;
end process reg;  

komb:process(stan,woda,chmiel,slod,butelki) --proces wrazliwy na sygnaly stan, woda, chmiel, slod, butelki
begin
	stan_nast<= stan;
	case stan is
		when stop=>
			if (woda='1') then --kiedy stan jest stop i woda jest 1
				stan_nast<=dostawa_butelek; -- stan zmienia siê na dostawa_butelek
			end if;
		when dostawa_butelek=> --kiedy stan jest dostawa_butelek i woda jest 1
			if (woda='1') then -- stan zmienia siê na dostawa_ch_sl
				stan_nast<=dostawa_ch_sl;
		elsif (woda='0') then -- stan zmienia siê
				stan_nast<=stop;
			end if;			
		when dostawa_ch_sl=> --kiedy stan jest dostawa_ch_sl i woda jest 1
			if (woda='1') then -- stan zmienia siê na warzenie
				stan_nast<=warzenie;
			elsif (woda='0') then -- stan zmienia siê
				stan_nast<=stop;
			end if;
		when warzenie=>
			if (butelki/="00") then --kiedy stan jest warzenie i s¹ butelki
				stan_nast<=kapslowanie; --stan zmienia siê na kapslowanie
				else
				stan_nast<=dostawa_butelek; --nie ma butelek, powrot do dostawy butelek
			end if;
		when kapslowanie=>
			if (woda='1') then --jak woda jest rowna jeden wysylka do magazynu
				stan_nast<=magazyn;		
			end if;
			when magazyn=>
			if (butelki/="00" and woda='1') then --jesli dalej sa butelki to powrot do stanu dostawa chmielu i slodu
				stan_nast<=dostawa_ch_sl;
				elsif(butelki="00" and woda='1') then
				stan_nast<=dostawa_butelek; --jesli nie ma butelek to powrot do dostawy butelek
				elsif(woda = '0') then
				stan_nast<=stop; 
			end if;		
	end case;
end process komb;

licznik_piwa:process(clk,reset) --licznik chmielu i slodu
begin
	if (reset='0') then
		chmiel<= "00"; --gdy reset aktywny to chmiel i slod jest rowny 0
		slod<= "00";		
	elsif (clk'event and clk='1') then --gdy zbocze narastajace
		if(stan=warzenie) then --i stan warzenie
			chmiel<= chmiel-"11"; --wykorzystuje sie caly chmiel i slod
			slod<= slod-"10";
		elsif(stan=dostawa_ch_sl) then --jesi dostawa
			chmiel<= "11"; --chmiel i slod zostaje uzupelniony
			slod<= "10";
		end if;
	end if;
end process licznik_piwa;

licznik_butelek:process(clk,reset) --licznik butelek
begin
	if reset='0' then --jak reset jest aktywny
		butelki<= "00";		--to brak butelek
	elsif (clk'event and clk='1') then --gdy zbocze narastajace
		if(stan=kapslowanie) then  --i stan kapslowanie
			butelki<= butelki-1; --odejmujemy z zapasu butelek jedna butelke
		elsif(stan=dostawa_butelek) then --gdy dostawa butelek
			butelki<= "11"; --sygnal butelki jest rowny "11111111"
		end if;
	end if;
end process licznik_butelek;

licznik_skrzynki:process(clk,reset) --licznik butelek w skrzynce
begin
	if reset='0' then
		skrzynka<= "00";		--jak reset jest aktywny to skrzynka jest pusta
	elsif (clk'event and clk='1') then --gdy zbocze narastajace
		if(stan=magazyn) then --stan magazyn
			skrzynka<= skrzynka+1; --dodaje 1 do skrzynki, 1 zapakowana butelka
		elsif(stan=stop) then --kiedy stan jest stop to skrzynka jest pusta
			skrzynka<= "00";
		end if;
	end if;
end process licznik_skrzynki;

postep <= '1' when skrzynka = "11" else '0'; --kiedy skrzynka jest pelna, sa 3 piwa, postêp produkcji jest rowny 1 
end uut_arch;


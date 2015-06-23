-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : Ics307Values-p.vhdl
-- Owner       : Rainer Kastl
-- Description : Constants for Ics307Configurator
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Ics307Values is
	constant cCrystalLoadCapacitance_C_48MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cReferenceDivider_RDW_48MHz : std_ulogic_vector(6 downto 0) := "0000011";
	constant cVcoDividerWord_VDW_48MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cOutputDutyCycleVoltage_TTL_48MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_48MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_48MHz : std_ulogic_vector(2 downto 0) := "100";

	constant cCrystalLoadCapacitance_C_25MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_25MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_25MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_25MHz : std_ulogic_vector(2 downto 0) := "000";
	constant cVcoDividerWord_VDW_25MHz : std_ulogic_vector(8 downto 0) := "000000111";
	constant cReferenceDivider_RDW_25MHz : std_ulogic_vector(6 downto 0) := "0000001";

	constant cCrystalLoadCapacitance_C_50MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_50MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_50MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_50MHz : std_ulogic_vector(2 downto 0) := "010";
	constant cVcoDividerWord_VDW_50MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cReferenceDivider_RDW_50MHz : std_ulogic_vector(6 downto 0) := "0000001";

	constant cCrystalLoadCapacitance_C_100MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDutyCycleVoltage_TTL_100MHz : std_ulogic := '1';
	constant cClkFunctionSelect_R_100MHz : std_ulogic_vector(1 downto 0) := "00";
	constant cOutputDivide_S_100MHz : std_ulogic_vector(2 downto 0) := "011";
	constant cVcoDividerWord_VDW_100MHz : std_ulogic_vector(8 downto 0) := "000010000";
	constant cReferenceDivider_RDW_100MHz : std_ulogic_vector(6 downto 0) := "0000001";

end package Ics307Values;


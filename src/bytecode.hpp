//
//  Copyright (C) 2019  Nick Gasson
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#pragma once

#include "util.h"
#include "vcode.h"
#include "printer.hpp"

#include <iosfwd>

class Machine {
public:
   Machine(const char *name, int num_regs, int result_reg);
   Machine(const Machine&) = default;
   Machine(Machine&&) = default;
   virtual ~Machine() {}

   const char *name() const { return name_; }
   int num_regs() const { return num_regs_; }
   int result_reg() const { return result_reg_; }

   int32_t read_i32(const uint8_t *p) const;

   virtual const char *fmt_reg(int reg) const;

private:
   const char *const name_;
   const int         num_regs_;
   const int         result_reg_;
};

class InterpMachine : public Machine {
public:
   static const InterpMachine& get();

private:
   InterpMachine();
};

class Bytecode {
public:
   enum OpCode : uint8_t {
      NOP  = 0x00,     // Do nothing
      MOVC = 0x01,     // Move 32-bit constant to register
      RET  = 0x02,     // Return from function
      ADD  = 0x03,     // Add two registers
      MOVR = 0x04,     // Move register to another register
      ADDI = 0x05,     // Add 32-bit imeddiate to register
   };

   static Bytecode *compile(const Machine& m, vcode_unit_t unit);

   const uint8_t *bytes() const { return bytes_; }
   size_t length() const { return len_; }
   const Machine& machine() const { return machine_; }

   void dump(Printer&& printer = StdoutPrinter()) const;
   void dump(Printer& printer) const;
   void set_bytes(const uint8_t *bytes, size_t len);

private:
   explicit Bytecode(const Machine& m);
   Bytecode(const Bytecode&) = delete;
   ~Bytecode();

   uint8_t       *bytes_ = nullptr;
   size_t         len_ = 0;
   const Machine  machine_;
};

std::ostream& operator<<(std::ostream& os, const Bytecode& b);

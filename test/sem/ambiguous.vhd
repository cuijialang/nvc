entity e is
end entity;

architecture a of e is
    type foo is (a, b, c);
    type bar is (a, b, c);

    signal x : foo := a;
    signal y : bar := b;
begin

    process is
    begin
        x <= c;
        y <= a;
    end process;

    process is
    begin
        x <= foo'(a);
        y <= bar'(a);
    end process;

    process is
        type baz is (a, b, c, d);
        variable z : baz := b;
    begin
        z := d;
        z := a;
        x <= a;
    end process;

    process is
    begin
        x <= bar'(c);                   -- Error!
    end process;

    process is
        type small is range 10 downto -5;
        variable z : small := -5;
        variable a : boolean;
    begin
        a := z = -5;
        a := -5 = z;
    end process;

    process is
        variable a : bit_vector(3 downto 0);
        variable x : character;
        variable b : boolean;
    begin
        b := x = '1';                   -- OK
        b := '1' = x;                   -- OK
        b := a = ('0', '1', '0', '1');  -- OK
        b := ('0', '1', '0', '1') = a;  -- OK
        b := ('0', '1') = ('0', '1');   -- Error
    end process;

    process is
        subtype some_foo is foo range a to b;
        subtype less_foo is some_foo range a to a;
        subtype all_foo is foo;
        variable f : some_foo;
        variable g : all_foo;
        variable h : less_foo;
    begin
        f := a;                         -- OK
        f := c;                         -- OK at semantic check
        g := f;                         -- OK
        g := h;                         -- OK
    end process;

    process is
        type weird is ( '�', '�' );
        variable x : weird;
        variable y : character;
    begin
        x := '�';
        y := '�';
        report "foo�bar";
    end process;

    process is
        type t is (false, true);
    begin
        for i in false to false loop    -- Error
        end loop;
    end process;

    process is
        function now return integer;
    begin
        for i in now to now loop    -- Error
        end loop;
    end process;

    process is
        function false return integer is
        begin
            return 1;
        end function;
    begin
        for i in false to false loop    -- Error
        end loop;
    end process;

    process is
        function "="(a, b : foo) return boolean is
        begin
            return false;
        end function;

        variable x, y : foo;
    begin
        assert x = y;                   -- OK
    end process;

end architecture;

package pack is
    type my_int is range 1 to 10;
end package;

use work.pack.all;

package pack2 is
    function "<"(a, b: my_int) return boolean;
end package;

use work.pack.all;
use work.pack2.all;

architecture a2 of e is
    function ">"(a, b: my_int) return boolean;
begin

    process is
        variable x, y : my_int;
    begin
        assert x > y;                   -- OK
        assert x < y;                   -- Error
    end process;

end architecture;

architecture a3 of e is
    type unsigned is array (natural range <>) of bit;

    function "*"(a, b : unsigned) return bit_vector;
    function "*"(a, b : bit_vector) return bit_vector;
    function "*"(a, b : unsigned) return unsigned;

    function "+"(a, b : unsigned) return bit_vector;
    function "+"(a, b : bit_vector) return bit_vector;
    function "+"(a, b : unsigned) return unsigned;

    signal x, y, z : bit_vector(7 downto 0);
begin

    x <= unsigned(y) * unsigned(z) + unsigned(z);

end architecture;

-- Test case reduced from Altera model
architecture a4 of e is
    function resolved (x : bit_vector) return bit;

    subtype rbit is resolved bit;

    type rbit_vector is array (natural range <>) of rbit;

    function "and" (x, y : rbit_vector) return rbit_vector;

    signal mdio_wr  : rbit;
    signal reg_addr : rbit_vector(15 downto 0);
begin

    process is
    begin
        assert ((X"0000" & mdio_wr) and reg_addr) /= X"0000";
    end process;

end architecture;

-- -*- coding: latin-1; -*-

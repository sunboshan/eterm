# ETerm

Understand Erlang Terms.

## Compile C code

Change `ERL_INCLUDE_PATH` in `Makefile`. After get the dependency `elixir_make`, every time run `mix compile`, it will also invoke `make` to compile C code if necessary.

## Use as library

In `mix.exs`
```
  defp deps do
    [
      {:eterm, git: "https://github.com/sunboshan/eterm.git"},
    ]
  end
```
Then `mix do deps.get, deps.compile`.

## Usage

```
$ iex -S mix
iex> ETerm.show(1)
0x000000000000001f      immediate       1
00000000_00000000_00000000_00000000_00000000_00000000_00000000_00011111        small int

iex> ETerm.show([])
0xfffffffffffffffb      immediate       []
11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111011        nil

iex> ETerm.show({1, 2, 3})
0x000000001921500a      boxed   {1, 2, 3}
00000000_00000000_00000000_00000000_00011001_00100001_01010000_00001010        boxed
0x0000000019215008      header  tuple_size: 3
00000000_00000000_00000000_00000000_00000000_00000000_00000000_11000000        arity val
0x0000000019215010      body    1
00000000_00000000_00000000_00000000_00000000_00000000_00000000_00011111        small int
0x0000000019215018      body    2
00000000_00000000_00000000_00000000_00000000_00000000_00000000_00101111        small int
0x0000000019215020      body    3
00000000_00000000_00000000_00000000_00000000_00000000_00000000_00111111        small int
```

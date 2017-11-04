defmodule ETerm do
  @moduledoc """
  Understand Erlang Terms.
  """

  @on_load :load_nif

  def load_nif do
    :erlang.load_nif('priv/eterm', 0)
  end

  def parse(_) do
    raise "NIF parse/1 not implemented"
  end

  def show([_ | _] = term) do
    {:list, val, {car, car_v}, {cdr, cdr_v}} = parse(term)
    [h | t] = term
    IO.puts([val, ?\t, "list", ?\t, inspect(term)])
    IO.puts(transform(val))
    IO.puts([car, ?\t, "head", ?\t, inspect(h)])
    IO.puts(transform(car_v))
    IO.puts([cdr, ?\t, "tail", ?\t, inspect(t)])
    IO.puts(transform(cdr_v))
  end

  def show(term) when is_tuple(term) do
    {:boxed, val, {header, header_v}, body} = parse(term)
    IO.puts([val, ?\t, "boxed", ?\t, inspect(term)])
    IO.puts(transform(val))
    IO.puts([header, ?\t, "header", ?\t, "tuple_size: #{tuple_size(term)}"])
    IO.puts(transform(header_v))
    Stream.with_index(body)
    |> Enum.each(fn {{k, v}, i} ->
      IO.puts([k, ?\t, "body", ?\t, inspect(elem(term, i))])
      IO.puts(transform(v))
    end)
  end

  def show(term) do
    case parse(term) do
      {:immediate, val} ->
        IO.puts([val, ?\t, "immediate", ?\t, inspect(term)])
        IO.puts(transform(val))
      {:boxed, val, {header, header_v}, body} ->
        IO.puts([val, ?\t, "boxed", ?\t, inspect(term)])
        IO.puts(transform(val))
        IO.puts([header, ?\t, "header"])
        IO.puts(transform(header_v))
        Enum.each(body, fn {k, v} ->
          IO.puts([k, ?\t, "body"])
          IO.puts(transform(v))
        end)
    end
  end

  defp transform([h, ?3]) do
    IO.ANSI.format([to_b(h), :magenta, to_b(?3), :reset, ?\t, "pid"])
  end
  defp transform([h, ?7]) do
    IO.ANSI.format([to_b(h), :magenta, to_b(?7), :reset, ?\t, "port"])
  end
  defp transform([h, ?f]) do
    IO.ANSI.format([to_b(h), :magenta, to_b(?f), :reset, ?\t, "small int"])
  end
  defp transform([h, ?b]) do
    case to_b(h) do
      [a, b, ?0, ?0] ->
        IO.ANSI.format([a, b, :magenta, '00', to_b(?b), :reset, ?\t, "atom"])
      [a, b, ?0, ?1] ->
        IO.ANSI.format([a, b, :magenta, '01', to_b(?b), :reset, ?\t, "catch"])
      [a, b, ?1, ?1] ->
        IO.ANSI.format([a, b, :magenta, '11', to_b(?b), :reset, ?\t, "nil"])
    end
  end
  defp transform([h, t]) do
    case to_b(t) do
      [_, _, ?0, ?0] ->
        get_header(to_b(h), to_b(t))
      [a, b, ?0, ?1] ->
        IO.ANSI.format([to_b(h), a, b, :magenta, '01', :reset, ?\t, "list"])
      [a, b, ?1, ?0] ->
        IO.ANSI.format([to_b(h), a, b, :magenta, '10', :reset, ?\t, "boxed"])
    end
  end
  defp transform([?0, ?x | t]) do
    transform(t)
  end
  defp transform([a, b | t]) do
    [to_b(a), to_b(b), ?_ | transform(t)]
  end

  defp get_header([a, b, ?0, ?0], [?0, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0000', :magenta, '00', :reset, ?\t, "arity val"])
  end
  defp get_header([a, b, ?0, ?0], [?0, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0001', :magenta, '00', :reset, ?\t, "binary matchstate"])
  end
  defp get_header([a, b, ?0, ?0], [?1, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0010', :magenta, '00', :reset, ?\t, "pos bignum"])
  end
  defp get_header([a, b, ?0, ?0], [?1, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0011', :magenta, '00', :reset, ?\t, "neg bignum"])
  end
  defp get_header([a, b, ?0, ?1], [?0, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0100', :magenta, '00', :reset, ?\t, "ref"])
  end
  defp get_header([a, b, ?0, ?1], [?0, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0101', :magenta, '00', :reset, ?\t, "fun"])
  end
  defp get_header([a, b, ?0, ?1], [?1, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0110', :magenta, '00', :reset, ?\t, "float"])
  end
  defp get_header([a, b, ?0, ?1], [?1, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '0111', :magenta, '00', :reset, ?\t, "export"])
  end
  defp get_header([a, b, ?1, ?0], [?0, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1000', :magenta, '00', :reset, ?\t, "refc binary"])
  end
  defp get_header([a, b, ?1, ?0], [?0, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1001', :magenta, '00', :reset, ?\t, "heap binary"])
  end
  defp get_header([a, b, ?1, ?0], [?1, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1010', :magenta, '00', :reset, ?\t, "sub binary"])
  end
  defp get_header([a, b, ?1, ?1], [?0, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1100', :magenta, '00', :reset, ?\t, "external pid"])
  end
  defp get_header([a, b, ?1, ?1], [?0, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1101', :magenta, '00', :reset, ?\t, "external port"])
  end
  defp get_header([a, b, ?1, ?1], [?1, ?0, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1110', :magenta, '00', :reset, ?\t, "external ref"])
  end
  defp get_header([a, b, ?1, ?1], [?1, ?1, _, _]) do
    IO.ANSI.format([a, b, :cyan, '1111', :magenta, '00', :reset, ?\t, "map"])
  end

  defp to_b(?0), do: '0000'
  defp to_b(?1), do: '0001'
  defp to_b(?2), do: '0010'
  defp to_b(?3), do: '0011'
  defp to_b(?4), do: '0100'
  defp to_b(?5), do: '0101'
  defp to_b(?6), do: '0110'
  defp to_b(?7), do: '0111'
  defp to_b(?8), do: '1000'
  defp to_b(?9), do: '1001'
  defp to_b(?a), do: '1010'
  defp to_b(?b), do: '1011'
  defp to_b(?c), do: '1100'
  defp to_b(?d), do: '1101'
  defp to_b(?e), do: '1110'
  defp to_b(?f), do: '1111'
end

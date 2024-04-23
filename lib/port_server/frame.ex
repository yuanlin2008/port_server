defmodule PortServer.Frame do
  def serialize(:call, pid, tag, payload) do
    pid = :erlang.term_to_binary(pid)
    tag = :erlang.term_to_binary(tag)
    [0, <<byte_size(pid)::16>>, pid, <<byte_size(tag)::16>>, tag, payload]
  end

  def serialize(:cast, pid, payload) do
    pid = :erlang.term_to_binary(pid)
    [1, <<byte_size(pid)::16>>, pid, payload]
  end

  def serialize(:down, pid) do
    pid = :erlang.term_to_binary(pid)
    [2, <<byte_size(pid)::16>>, pid]
  end

  def deserialize(bin) do
    <<type::8, rest::binary>> = bin

    case type do
      0 ->
        <<pid_size::16, pid_bin::binary-size(pid_size), tag_size::16,
          tag_bin::binary-size(tag_size), payload::binary>> = rest

        {:call, :erlang.binary_to_term(pid_bin), :erlang.binary_to_term(tag_bin), payload}

      1 ->
        <<pid_size::16, pid_bin::binary-size(pid_size), payload::binary>> = rest
        {:cast, :erlang.binary_to_term(pid_bin), payload}

      2 ->
        <<pid_size::16, pid_bin::binary-size(pid_size)>> = rest
        {:monitor, :erlang.binary_to_term(pid_bin)}
    end
  end
end

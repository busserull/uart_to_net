defmodule UT.Serial do
  use GenServer

  @stx 0x02
  @etx 0x03

  # Public API

  def start_link(settings) do
    GenServer.start_link(__MODULE__, settings, name: __MODULE__)
  end

  def send(message) do
    GenServer.call(__MODULE__, {:send, message})
  end

  # Callbacks

  def init([interface: interface, speed: speed]) do
    {:ok, uart_pid} = Nerves.UART.start_link
    Nerves.UART.open(uart_pid, interface, speed: speed, active: false)

    :timer.send_after(100, :poll)

    {:ok, %{buffer: << >>, uart_pid: uart_pid}}
  end

  def handle_info(:poll, state) do
    %{uart_pid: uart_pid} = state
    {:ok, message} = Nerves.UART.read(uart_pid, 0)

    new_state = state
                |> Map.update!(:buffer, &(&1 <> message))
                |> flush_buffer

    :timer.send_after(10, :poll)
    {:noreply, new_state}
  end

  def handle_call({:send, message}, _from, state) do
    %{uart_pid: uart_pid} = state

    {status, payload} = add_header(message)

    if status == :ok do
      Nerves.UART.write(uart_pid, payload)
    end

    {:reply, :ok, state}
  end

  # Helpers

  defp flush_buffer(%{buffer: buffer, uart_pid: uart_pid}) do
    case buffer do
      << >> ->
        %{buffer: buffer, uart_pid: uart_pid}

      << @stx >> ->
        %{buffer: buffer, uart_pid: uart_pid}

      << @stx, _rest :: binary-size(1) >> ->
        %{buffer: buffer, uart_pid: uart_pid}

      << @stx, _rest :: binary-size(2) >> ->
        %{buffer: buffer, uart_pid: uart_pid}

      << @stx, length_field :: binary-size(2), data_and_tail :: binary >> ->
        length = :binary.decode_unsigned(length_field)

        {status, message, rest} = extract_data(length, data_and_tail)
        case status do
          :ok ->
            UT.Translator.send_to_net(message)
            flush_buffer(%{buffer: rest, uart_pid: uart_pid})
          :error ->
            flush_buffer(%{buffer: rest, uart_pid: uart_pid})
          :incomplete ->
            %{buffer: buffer, uart_pid: uart_pid}
        end

      << _not_stx :: binary-size(1), rest :: binary >> ->
        flush_buffer(%{buffer: rest, uart_pid: uart_pid})
    end
  end

  defp extract_data(length, buffer) do
    case buffer do
      << data :: binary-size(length), @etx, rest :: binary >> ->
        {:ok, data, rest}

      << _faulty_data :: binary-size(length),
      not_etx :: binary-size(1), rest :: binary >> ->
        {:error, nil, << not_etx >> <> rest}

      _ ->
        {:incomplete, nil, buffer}
    end
  end

  defp add_header(message) do
    message_length = message
                     |> byte_size()
                     |> :binary.encode_unsigned()

    case byte_size(message_length) do
      1 ->
        {
          :ok,
          << @stx, 0x00 >>
          <> message_length
          <> message
          <> << @etx >>
        }

      2 ->
        {
          :ok,
          << @stx >>
          <> message_length
          <> message
          <> << @etx >>
        }

      _ ->
        {:error, << >>}
    end
  end

end

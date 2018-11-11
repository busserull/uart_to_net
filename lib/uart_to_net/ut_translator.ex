defmodule UT.Translator do

  @channel "web:controller"

  @type_score 0x10
  @type_position 0x12
  @type_lives 0x14

  @type_new_game 0x11
  @type_set_position 0x13
  @type_fire 0x15

  # Public API

  def send_to_net(message) do
    << type :: binary-size(1), rest :: binary >> = message

    {state, {event, payload}} = case :binary.decode_unsigned(type) do
      @type_score ->
        {
          :ok,
          {"score", :binary.decode_unsigned(rest)}
        }

      @type_position ->
        {
          :ok,
          {"position", :binary.decode_unsigned(rest)}
        }

      @type_lives ->
        {
          :ok,
          {"lives", :binary.decode_unsigned(rest)}
        }

      _ ->
        {:error, {"", << >>}}
    end

    if state == :ok do
      UTWeb.Endpoint.broadcast(@channel, event, %{payload: payload})
    end
  end

  def send_to_uc(type, payload) do
    {state, message} = case type do
      "new_game" ->
        {:ok, << @type_new_game >>}

      "set_position" ->
        {:ok, << @type_set_position >> <> encode_position(payload)}

      "fire" ->
        {:ok, << @type_fire >>}

      _ ->
        {:error, << >>}
    end

    if state == :ok do
      UT.Serial.send(message)
    end
  end

  # Helpers

  defp encode_position(payload) do
    encoded_payload = :binary.encode_unsigned(payload)
    case byte_size(encoded_payload) do
      1 ->
        << 0x00 >> <> encoded_payload
      _ ->
        encoded_payload
    end
  end

end

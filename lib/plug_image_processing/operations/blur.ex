defmodule PlugImageProcessing.Operations.Blur do
  @moduledoc false

  import PlugImageProcessing.Options

  defstruct image: nil, sigma: nil

  def new(image, params, _config) do
    with {:ok, sigma} <- cast_float(params["blur"] || params["sigma"]) do
      {:ok, struct!(__MODULE__, %{image: image, sigma: sigma})}
    end
  end

  defimpl PlugImageProcessing.Operation do
    def valid?(operation) do
      cond do
        is_nil(operation.sigma) ->
          {:error, :missing_sigma}

        operation.sigma <= 0 ->
          {:error, :invalid_sigma}

        true ->
          true
      end
    end

    def process(operation, _config) do
      Vix.Vips.Operation.gaussblur(operation.image, operation.sigma)
    end
  end
end
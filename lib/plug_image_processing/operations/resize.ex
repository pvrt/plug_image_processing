defmodule PlugImageProcessing.Operations.Resize do
  @moduledoc false

  import PlugImageProcessing.Options
  alias Vix.Vips.Image

  defstruct image: nil, width: nil, height: nil

  def new(image, params, _config) do
    with {:ok, width} <- cast_integer(params["w"] || params["width"]),
         {:ok, height} <- cast_integer(params["h"] || params["height"]) do
      {:ok,
       struct!(__MODULE__, %{
         image: image,
         width: width,
         height: height
       })}
    end
  end

  defimpl PlugImageProcessing.Operation do
    def valid?(operation) do
      if operation.width || operation.height do
        true
      else
        {:error, :missing_dimension}
      end
    end

    def process(operation, _config) do
      image_width = Image.width(operation.image) * 1.0
      image_height = Image.height(operation.image) * 1.0

      scale =
        cond do
          operation.width && operation.height ->
            min(operation.width / image_width, operation.height / image_height)

          operation.width ->
            operation.width / image_width

          operation.height ->
            operation.height / image_height
        end

      Vix.Vips.Operation.resize(operation.image, scale)
    end
  end
end
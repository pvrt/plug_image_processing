defmodule PlugImageProcessing.Operations.ThumbnailTest do
  use ExUnit.Case, async: true

  alias PlugImageProcessing.Config
  alias PlugImageProcessing.Operations.Thumbnail
  alias Vix.Vips.Image

  setup do
    {:ok, image} = Image.new_from_file("test/support/image.jpg")
    config = %Config{path: "/imageproxy"}
    {:ok, image: image, config: config}
  end

  describe "new/3" do
    test "creates thumbnail operation", %{image: image, config: config} do
      {:ok, operation} =
        Thumbnail.new(image, %{"width" => "100", "height" => "100"}, config)

      assert %Thumbnail{} = operation
      assert operation.width == 100
      assert operation.height == 100
      assert operation.gravity == "center"
    end
  end

  describe "valid?/1" do
    test "returns error when height is missing", %{image: image, config: config} do
      {:ok, operation} = Thumbnail.new(image, %{"width" => "100"}, config)
      assert PlugImageProcessing.Operation.valid?(operation) == {:error, :missing_dimensions}
    end
  end

  describe "process/2" do
    test "creates cover thumbnail with center crop", %{image: image, config: config} do
      {:ok, operation} =
        Thumbnail.new(image, %{"width" => "100", "height" => "100"}, config)

      {:ok, result_image} = PlugImageProcessing.Operation.process(operation, config)

      assert %Image{} = result_image
      assert Image.width(result_image) == 100
      assert Image.height(result_image) == 100
    end

    test "creates cover thumbnail with smart crop", %{image: image, config: config} do
      {:ok, operation} =
        Thumbnail.new(
          image,
          %{"width" => "100", "height" => "100", "gravity" => "smart"},
          config
        )

      {:ok, result_image} = PlugImageProcessing.Operation.process(operation, config)

      assert %Image{} = result_image
      assert Image.width(result_image) == 100
      assert Image.height(result_image) == 100
    end
  end
end